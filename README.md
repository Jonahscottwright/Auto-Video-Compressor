# Auto-Video-Compressor
A tool written in PowerShell that allows you to more or less compress mp4s to a desired size using ffmpeg.

# Prerequisites for use :
For now, you need [ffmpeg](https://ffmpeg.zeranoe.com/builds/) (ffbrobe too!) executables installed in `C:\program files\ffmpeg\bin` (If anyone can come up with a solution to make it so the software finds ffmpeg automagically that'd be great)

# Making the PowerShell script executable :
In order to compile the PowerShell script into an executable I used [this](https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5). It's a pretty neat tool. Make sure to give it the `-noConsole`, `-noOutput` and `noError` parameters when making a final build.

