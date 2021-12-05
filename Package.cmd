@ECHO off

SET modName=FS22_AdminToolBox
SET filename=%modName%.zip

IF EXIST %filename% (
    DEL  %filename% > NUL
)

"7z" a -tzip %filename% ^
   -i!*.lua ^
   -i!*.dds ^
   -i!*.xml ^
   -xr!resources ^
   -xr!.vscode ^
   -xr!.idea ^
   -xr!.git ^
   -aoa -r ^

IF %ERRORLEVEL% NEQ 0 ( exit 1 )

exit
