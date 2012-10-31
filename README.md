# Sli Video

A tool for creating HTML5-ready video

## What it does

Sli Video takes a directory of high quality MP4 source videos and converts them into derivatives for use
with the HTML5 video tag. Derivatives produced for each video include an MP4, using HandBrake, and
WebM and PNG, using ffmpeg. The MP4 and WebM can be used as sources for the video element and the PNG
taken from the first frame can be used as the poster image.

Because some browsers do not know about HTML5 video and this script does not create an OGV for other
browsers that do, the suggestion is to use a Flash fallback in conjunction with these video sources.

## Requirements

The script wraps other commandline tools.

- A *nix system (requires `cat`)
- ffmpeg
- HandBrakeCLI
- There may be other required libraries needed to create H.264 MP4s, WebMs, and PNGs?

## Installation

This is not yet ready for rubygems, so run it from source or do the following to install it.

```
rake build
gem install 'pkg/sli_video-0.0.1.gem'
```

## Usage

Use the sli_video_setup.rb script to create the necessary workflow directories. Make certain that
the storage volume has sufficient space for video originals, derivative
PNGs, MP4s, and WebM files as well as intermediary temporary files.

```
mkdir ~/tmp/my_video_workflow #or whatever you want to name it
sli_video_setup.rb ~/tmp/my_video_workflow
```

To append a common snippet of video to the end of each video, place a file endscreen.mpg
(an MPEG-1 file) at ~/tmp/my_video_workflow/endscreen.mpg. At this point the script relies
on this file being present

Put some video to be processed within ~/tmp/my_video_workflow/to-process. (I use MP4 source files.)
Then run the processing script.

```
sli_video.rb ~/tmp/my_workflow_directory /path/to_ship/videos
```

## Filenaming

In my setup I have a remove volume mounted as my video workflow directory. Other folks also have
access to the directory and can place videos to be processed in the to-process directory.
Then there is a remote directory where the videos are served up from (known as the "ship_directory" here).
I am using this script for an oral history project so all filenames start with a last name and a dash like
"name-title_of_clip.mp4". When I ship (or move) the files up to the web server, they get organized by
the name and then full filename. So if the original filename is "name-title_of_clip.mp4" then you get the
following directory structure.

```
ship_directory
└── name
    └── name-title_of_clip
        ├── name-title_of_clip.mp4
        ├── name-title_of_clip.png
        └── name-title_of_clip.webm
```

# Author

Jason Ronallo

# License

See LICENSE.