@echo off
setlocal

:: Version of RIFE you want to use!
set "RIFE_VERSION=rife-anime"

if "%~1"=="" (
    echo No input video file provided.
    pause
    exit /b
)

:: Set your RIFE path right here!
set rife_exe=C:\rife\rife-ncnn-vulkan.exe
set rife_model_path=C:\rife\%RIFE_VERSION%

if not exist "%rife_exe%" (
    echo RIFE .exe isn't at %rife_exe%. Please fix it! 
    pause
    exit /b
)

if not exist "%rife_model_path%" (
    echo RIFE model path couldn't be found %rife_model_path%. Please fix it! 
    pause
    exit /b
)

set input_video=%~1
set final_output=%~dp1output_%RIFE_VERSION%.mp4
set audio_output=%~dp1audio.m4a

mkdir "%~dp1output_frames"
mkdir "%~dp1input_frames"

for /f "tokens=2 delims=, fps=" %%a in ('ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate %input_video%') do (
    set fps=%%a
)

for /f "delims=/ tokens=1,2" %%a in ("%fps%") do (
    set /a fps=%%a/%%b
)

echo The input video's FPS is %fps%.

set /p custom_fps="Enter the desired FPS (leave blank to use the input video's FPS %fps%): "
if "%custom_fps%"=="" set custom_fps=%fps%

set /p frame_blending="Enable frame blending? (y/n): "
if "%frame_blending%"=="y" (
    set blend_option=-vf "minterpolate=mi_mode=mci:mc_mode=aobmc:vsbmc=1:fps=%custom_fps%"
) else (
    set blend_option=
)

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

echo Processing with FFmpeg
ffmpeg -framerate %custom_fps% -i "%~dp1output_frames\%%08d.png" -i %audio_output% -c:a copy -crf 20 -c:v libx264 -pix_fmt yuv420p %blend_option% %final_output%
echo FFmpeg processing completed.

if not exist "%final_output%" (
    echo The final output video was not created. Please check for errors in the FFmpeg command.
    pause
    exit /b
)

endlocal
pause
