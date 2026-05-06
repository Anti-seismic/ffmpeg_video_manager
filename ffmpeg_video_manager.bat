@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ffmpeg_video_manager.ps1" %*
pause
