@ECHO OFF
REM Usage: asm.bat program.asm
if %1asdf==asdf goto usage
customasm.exe -i instruction-set.txt -o %1.bin -f binary %1 -s %1.sym
goto end
:usage
ECHO Usage: asm.bat program.asm
:end
