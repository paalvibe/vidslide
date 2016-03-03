require 'RMagick'
require 'fileutils'
require 'CSV'

def clean_temp(dir)
  FileUtils.rm_rf(dir) if File.exists?(dir)
end

def syscmd(cmd)
  puts "Run sys cmd: #{cmd}"
  puts `#{cmd}`
  # sys cmd with continuous output, for some reason this runs way slower, so comment out
  # IO.popen(cmd).each do |fd|
  #   puts(fd.readline)
  # end
end

def prepare_face_vid()
  # Crop the video to make it slimmer. Vid was recorded with quicktime using macbook camera (quality high, not maximum)
  # By making it slimmer it fits better alongside slides.
  syscmd('rm -f slimface.mov ; ffmpeg -i face.mov -filter:v "crop=in_w-400:in_h" -preset veryfast -c:a copy slimface.mov')
end

def create_img_concat_file()
  # convert csv to ffmpeg input format
  #
  # csv format:
  # file,time
  # img00.png,00:00
  # img01.png,00:21
  # img02.png,00:45
  #
  # output format (note that last line must be repeated):
  #
  # ffconcat version 1.0
  # file temp/img00.png
  # duration 1
  # file temp/img00.png
  # duration 21
  # file temp/img01.png
  # duration 24
  # file temp/img02.png
  # duration 24
  # file temp/img02.png
  # duration 1

  output = "ffconcat version 1.0
"
  last_time_in_secs = 0
  last_row = nil
  is_first_row = true
  CSV.foreach("in.ffconcat.csv", :headers => true) do |row|
    if is_first_row # start time of second row must be applied to first row's file name, so skip first row
      is_first_row = false
      last_time_in_secs = 0
      last_row = row
      next
    end
    min_sec = row["time"].scan(/(.*):(.*)/).first
    time_in_secs = (min_sec[0].to_i * 60 + min_sec[1].to_i)
    duration_in_secs =  time_in_secs - last_time_in_secs
    last_time_in_secs = time_in_secs
    # time of this row must be applied to last row's file name
    output << "file temp/#{last_row["file"]}
duration #{duration_in_secs}
"
    last_row = row
  end
  # add footer
  output << "file temp/#{last_row["file"]}
duration 1
"

  File.write('in.ffconcat', output)
end

def prepare_slides_vid()
  # did this manually # syscmd("convert -density 150 input.pdf temp/img%02d.png")
  create_img_concat_file
  FileUtils.rm_f('slides.mp4')
  syscmd("ffmpeg -i in.ffconcat slides.mp4")
end

def combine_vids()
  # decided on using absolute coordinates to combine vids. slides.mp4 has dimensions 1500:840.
  syscmd('ffmpeg -i slimface.mov -vf "[in] scale=440:360, pad=iw+1500:844 [left]; movie=slides.mp4, scale=iw:ih [right]; [left][right] overlay=440:0 [out]" -c:v libx264 -crf 22 -preset veryfast output.mp4')
end

dir = './temp'
clean_temp(dir)
Dir.mkdir(dir)

FileUtils.rm_f('output.mp4')

prepare_face_vid
prepare_slides_vid
combine_vids

# optional step: trim start and finish
# `ffmpeg -i output.mp4 -ss 00:00:08 -t 00:45:47 -async 1 cut.mp4`