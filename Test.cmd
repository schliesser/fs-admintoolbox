@ECHO off

SET modName=FS22_AdminTools
SET gameProfile="D:\Dokumente\My Games\FarmingSimulator2022\"
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

ECHO Copy file to mod folder
COPY %filename% %gameProfile%mods\


ECHO Start game
start steam://rungameid/1248130

@REM Available FS19 start params
@REM -cheats (enables cheats in the console)
@REM -autoStartSavegameId 3 (loads the savegame automatically | *Replace "3" with the savegame ID of your choice)
@REM -restart (prevents intro videos from playing | will also keep logging the game to the logfile)
@REM -disableFramerateLimiter (removes the FPS cap | not recommended )

exit
