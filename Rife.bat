@echo off
setlocal

set "RIFE_VERSION=rife-anime"

if "%~1"=="" (
    echo No input video file provided.
    pause
    exit /b
)

set rife_exe=C:\rife\rife-ncnn-vulkan.exe
set rife_model_path=C:\rife\%RIFE_VERSION%
set input_video=%~1
set final_output=%~dp1output.mp4
set audio_output=%~dp1audio.m4a

mkdir "%~dp1output_frames"
mkdir "%~dp1input_frames"

ffprobe %input_video%

ffmpeg -i %input_video% -vn -acodec copy %audio_output%
echo Audio extraction completed.

ffmpeg -i %input_video% "%~dp1input_frames\frame_%%08d.png"
echo Frame decoding completed.

echo Running RIFE %RIFE_VERSION%
echo Command: "%rife_exe%" -i "%~dp1input_frames" -o "%~dp1output_frames" -m "%rife_model_path%"
"%rife_exe%" -i "%~dp1input_frames" -o "%~dp1output_frames" -m "%rife_model_path%" -f %~dp1output_frames\%08d.png
echo RIFE interpolation completed.

if not exist "%~dp1output_frames\00000000.png" (
    echo No output frames found in output_frames directory.
    pause
    exit /b
)

echo Processing with FFmpeg
ffmpeg -framerate 48 -i "%~dp1output_frames\%%08d.png" -i %audio_output% -c:a copy -crf 20 -c:v libx264 -pix_fmt yuv420p %final_output%
echo FFmpeg processing completed.

endlocal
pause
