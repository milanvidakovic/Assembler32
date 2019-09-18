@ECHO OFF
REM Usage: asm.bat program.asm
if %1asdf==asdf goto usage
customasm.exe -i instruction-set.txt -o ram.hex -f hexstr2 %1
copy ram.hex ..\computer32.2
goto end
:usage
ECHO Usage: asm.bat program.asm
:end
