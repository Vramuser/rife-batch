:: barely works tbh. You have to edit the file itself. One day I'll resume this product and make a config.txt file or something like that ugggg.
@echo off
setlocal

:: Version of rife you want to use! 
set "RIFE_VERSION=rife-anime"

if "%~1"=="" (
    echo No input video file provided.
    pause
    exit /b
)

:: Set your rife path right here! 
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
"%rife_exe%" -i "%~dp1input_frames" -o "%~dp1output_frames" -m "%rife_model_path%"
echo RIFE interpolation completed.

if not exist "%~dp1output_frames\00000001.png" (
    echo No output frames found in output_frames directory.
    pause
    exit /b
)

:: change framerate [value] to desired value (FPS)  
echo Processing with FFmpeg
ffmpeg -framerate 120 -i "%~dp1output_frames\%%08d.png" -i %audio_output% -c:a copy -crf 20 -c:v libx264 -pix_fmt yuv420p %final_output%
echo FFmpeg processing completed.

if not exist "%final_output%" (
    echo The final output video was not created. Please check for errors in the FFmpeg command.
    pause
    exit /b
)

endlocal
pause
