@ECHO off

SET gameProfile="G:\Dokumente\My Games\FarmingSimulator2022\"

@REM Pack mod
CALL pack.cmd

IF %ERRORLEVEL% NEQ 0 ( exit 1 )

ECHO Copy file to mod folder
COPY %filename% %gameProfile%mods\
ECHO Copy file to remote PC
COPY %filename% \\DESKTOP-4IT0MJR\FarmingSimulator2022\mods\


@REM ECHO Starting game ...
@REM start steam://rungameid/1248130
@REM "C:\Program Files (x86)\Steam\steam.exe" -applaunch 1248130 -cheats -autoStartSavegameId 2

ECHO Happy Testing: %modName%

@REM Available FS19 start params
@REM -cheats (enables cheats in the console)
@REM -autoStartSavegameId 3 (loads the savegame automatically | *Replace "3" with the savegame ID of your choice)
@REM -restart (prevents intro videos from playing | will also keep logging the game to the logfile)
@REM -disableFramerateLimiter (removes the FPS cap | not recommended )
