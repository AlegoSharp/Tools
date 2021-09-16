@echo off
set adbPath=C:\Program Files (x86)\Android\android-sdk\platform-tools
set checkExistInPath="adb"
set tab2="<TAB><TAB>"
where /q %checkExistInPath%
IF ERRORLEVEL 1 (
    call :error "%checkExistInPath%.exe is missing. Ensure it is installed and placed in your PATH."
	REM set adbPath = <TAB> and '%adbPath%'
    call :color Yellow "%adbPath%"
    EXIT
) ELSE (
    call :color Green "adb.exe has been found"
)

set  stamp=%DATE:/=%

echo __________________________

CALL :title PARAMETERS
@echo:
IF "%~1" == "" (
	CALL :error "Android device serial is empty" false
	EXIT
)
IF "%~2" == "" (
	CALL :error "Package Name is empty" false
	EXIT
)
IF "%~3" == "" (
	CALL :error "Db file name is empty" false
	EXIT
)


REM Device Serial
echo|set /p="Android device serial : "
call :title "%1"

REM Package Name
echo|set /p="Package Name : "
call :title "		%2"

REM Db file name
echo|set /p="Db file name : "
call :title "		%3"


echo __________________________

@echo:
CALL :color "Yellow" "Removing last %3.db file from downloads ..."
CALL :removeDbFromDownloads %1 %2 %3

@echo:
CALL :color "Yellow" "Copying %3.db file to downloads ..."
CALL :copyDbToDeviceDownloads %1 %2 %3

@echo:
CALL :color "Yellow" "Pulling %3.db file to PC ..."
CALL :pullDbToPc %1 %2 %3

@echo:
if exist "%3.backup.db" (
	call :color Green success
	EXIT
) else (
	call :error "Error while retrieving DB"
	EXIT
)

REM pause
REM rm "/data/user/0/ORCAB_WS_Android_Natif.ORCAB_WS_Android_Natif/databases/DWS.db"
REM pause

REM ##############################
:removeDbFromDownloads
	call :runAdb "adb -s %1 exec-out run-as %2 rm "/storage/emulated/0/Download/%3.db"" true true
EXIT /B 0
REM ##############################



REM ##############################
:copyDbToDeviceDownloads
	call :runAdb "adb -s %1 exec-out run-as %2 cp "/data/user/0/%2/databases/%3.db" "/storage/emulated/0/Download/%3.db"" false true
EXIT /B 0
REM ##############################



REM ##############################
:pullDbToPc
	call :runAdb "adb -s %1 pull "/storage/emulated/0/Download/%3.db"  "./%3.backup.db"" false false
EXIT /B 0
REM ##############################

:runAdb
for /f "tokens=*" %%i in ('%1') do (
	set RESULT=%%i
)
if "%2" == "true" (
	call :color Green Done
) else (
	if "%3" == "true" (
		if "%RESULT%" == "" (
			call :color Green Done
			EXIT /B 0
		) else (
			call :error "Error while running : " false
			call :color DarkYellow "Command :"
			call :error %1 true
			call :color DarkYellow "Error message :"
			call :error "%RESULT%" true
			EXIT
		)
	) else (
		call :color Green Done
	)
)

set RESULT = ""
EXIT /B 0

:error
if %2 == true (
	powershell.exe write-host -foregroundcolor Red `t '%~1'
) else (
	powershell.exe write-host -foregroundcolor Red '%~1'
)
EXIT /B 0


:color
powershell.exe write-host -foregroundcolor %1 '%2'
EXIT /B 0

:title
powershell.exe write-host -backgroundcolor White -foregroundcolor Black '%1'
EXIT /B 0