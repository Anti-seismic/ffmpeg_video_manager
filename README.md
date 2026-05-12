## ffmpeg_video_manager
Compression, Rotation, Noise Reduction, Stabilisation, Sharpening

Copyright (c) 2026 Joël Kerléguer
Contact: joel.kerleguer@gmail.com


## Attribution
This tool is built on top of the **CODEX FFmpeg** builds provided by **Gyan Doshi**.

CODEX FFmpeg Sources:
- [https://www.ffmpeg.org/download.html#build-windows](https://www.ffmpeg.org/download.html#build-windows)  
- [https://www.gyan.dev/ffmpeg/builds/](https://www.gyan.dev/ffmpeg/builds/)  
- [https://github.com/BtbN/FFmpeg-Builds/releases](https://github.com/BtbN/FFmpeg-Builds/releases)  


## Dependencies
1. PowerShell 7+
2. FFmpeg

**Install FFmpeg (recommended method)**  
winget install ffmpeg

**Alternative installation methods**  
Full installation instructions and additional builds:  
[https://www.gyan.dev/ffmpeg/builds/](https://www.gyan.dev/ffmpeg/builds/)


## How to Use
**Drag & Drop Mode**
Drag and drop your video files or folders onto the PowerShell script.
If your system security settings block PowerShell script execution, simply drag and drop them onto the Batch (.bat) script instead.

**CLI Mode**
You can also automate your workflow by running the tool directly from the command line.


## Notes
- This tool relies on FFmpeg being installed and available in your system’s PATH.
- Built and tested on Windows environments using the CODEX FFmpeg builds.
