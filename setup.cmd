@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION



:PROCESS_CMD
    SET "utility_folder=%~dp0"
    SET "utility_software_folder=%utility_folder%software"
    SET "utility_sfx=%utility_folder%software.exe"
    SET "python_paths=%utility_software_folder%\install;%utility_software_folder%\install\Scripts"

    CALL "%utility_folder%..\utils\setup.cmd" cecho 7zip

    SET help_arg=false
    SET pack_arg=false
    SET unpack_arg=false

    SET current_arg=%1
    IF  [%current_arg%] EQU [-h]       SET help_arg=true
    IF  [%current_arg%] EQU [--help]   SET help_arg=true
    IF  [%current_arg%] EQU [--pack]   SET pack_arg=true
    IF  [%current_arg%] EQU [--unpack] SET unpack_arg=true

    IF  [%help_arg%] EQU [true] (
        CALL :SHOW_HELP
    ) ELSE (
        IF  [%pack_arg%] EQU [true]  (
            CALL :PACK
        ) ELSE (
            IF  [%unpack_arg%] EQU [true]  (
                CALL :UNPACK
            ) ELSE (
                CALL :MAIN %*
                IF !ERRORLEVEL! NEQ 0 (
                    EXIT /B !ERRORLEVEL!
                )
            )
        )
    )

    REM All changes to variables within this script, will have local scope. Only
    REM variables specified in the following block can propagates to the outside
    REM world (For example, a calling script of this script).
    ENDLOCAL & (
        SET "TOOLSET_PYTHON_PATH=%python_paths%"
        SET "PATH=%PATH%"
    )
EXIT /B 0



:MAIN
    CALL :UNPACK

    REM Check if the 'utility_software_folder' is not already in system path. If
    REM not, insert it.
    IF "!PATH:%python_paths%=!" EQU "%PATH%" (
        SET "PATH=%python_paths%;%PATH%"
        CALL :SHOW_INFO "Utility added to system path."
    )
EXIT /B 0



:PACK
    IF EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Packing utility files."
        7z u -uq0 -mx9 -sfx "!utility_sfx!" "!utility_software_folder!"
    )
EXIT /B 0

:UNPACK
    IF NOT EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Unpacking utility files."
        CALL "!utility_sfx!" -y -o"!utility_folder!"
    )
EXIT /B 0



:SHOW_INFO
    cecho {olive}[TOOLSET - UTILS - PYTHON]{default} INFO: %~1{\n}
EXIT /B 0

:SHOW_ERROR
    cecho {olive}[TOOLSET - UTILS - PYTHON]{red} ERROR: %~1 {default} {\n}
EXIT /B 0

:SHOW_HELP
    SET "script_name=%~n0%~x0"
    ECHO #######################################################################
    ECHO #                                                                     #
    ECHO #                      T O O L   S E T U P                            #
    ECHO #                                                                     #
    ECHO #              'PYTHON' is an interpreted, high-level, 
    ECHO #               general-purpose programming language.                 #
    ECHO #                                                                     #
    ECHO # TOOL   : PYTHON                                                     #
    ECHO # VERSION: 3.8.3                                                      #
    ECHO # ARCH   : x64                                                        #
    ECHO #                                                                     #
    ECHO # USAGE:                                                              #
    ECHO #   %SCRIPT_NAME% [-h^|--help^|--pack^|--unpack]                             #
    ECHO #                                                                     #
    ECHO # EXAMPLES:                                                           #
    ECHO #     %script_name%                                                       #
    ECHO #     %script_name% -h                                                    #
    ECHO #     %script_name% --pack                                                #
    ECHO #                                                                     #
    ECHO # ARGUMENTS:                                                          #
    ECHO #     -h^|--help    Print this help and exit.                          #
    ECHO #                                                                     #
    ECHO #     --pack    Pack the content of the software folder in one        #
    ECHO #         self-extract executable called 'software.exe'.              #
    ECHO #                                                                     #
    ECHO #     --unpack    Unpack the self-extract executable 'software.exe'   #
    ECHO #         to the software folder.                                     #
    ECHO #                                                                     #
    ECHO # EXPORTED ENVIRONMENT VARIABLES:                                     #
    ECHO #     TOOLSET_PYTHON_PATH    Absolute path where this tool is        #
    ECHO #         located.                                                    #
    ECHO #                                                                     #
    ECHO #     PATH    This tool will export all local changes that it made to #
    ECHO #         the path's environment variable.                            #
    ECHO #                                                                     #
    ECHO #     The environment variables will be exported only if this script  #
    ECHO #     executes without any error.                                     #
    ECHO #                                                                     #
    ECHO #######################################################################
EXIT /B 0