# vidslide

Combine pdf and live presentation recording composed together in a video. Live presentation will be in upper left corner, presentation taking most of the space. Also pdf2vid.

Depends on ffmpeg, convert (ImageMagick).

Script is still rough.

This script supposes a video recorded with Quicktime using Macbook camera (quality high, not maximum) of face/person. This script supposes the video location in ```./face.mov```.

Slides should be in ```./input.pdf```. This script supposes slide dimensions 1500:840.

Example face video recording:

![Example face video recording](https://github.com/paalvibe/tree/master/vidslide/docs/face_vid_example.png)

Example composed output:

![Example composed output](https://github.com/paalvibe/vidslide/tree/master/docs/combined_vid_example.png)

The page change times of the slides are defined in in.ffconcat.csv. Example:

```
file,time
img00.png,00:00
img01.png,00:21
img02.png,00:45
img03.png,01:03
img04.png,02:20
img05.png,02:30
img06.png,02:54
img07.png,03:15
img08.png,03:25
img09.png,04:20
img10.png,05:00
img10.png,05:20
```

Note that last slide must be repeated to specify when its display ends.