GLOBAL CONST $TAGFILETIME = "struct;dword Lo;dword Hi;endstruct"
GLOBAL CONST $TAGSYSTEMTIME = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
GLOBAL CONST $TAGEVENTLOGRECORD = "dword Length;dword Reserved;dword RecordNumber;dword TimeGenerated;dword TimeWritten;dword EventID;" & "word EventType;word NumStrings;word EventCategory;word ReservedFlags;dword ClosingRecordNumber;dword StringOffset;" & "dword UserSidLength;dword UserSidOffset;dword DataLength;dword DataOffset"
GLOBAL CONST $TAGGUID = "struct;ulong Data1;ushort Data2;ushort Data3;byte Data4[8];endstruct"
GLOBAL CONST $TAGWIN32_FIND_DATA = "dword dwFileAttributes;dword ftCreationTime[2];dword ftLastAccessTime[2];dword ftLastWriteTime[2];dword nFileSizeHigh;dword nFileSizeLow;dword dwReserved0;dword dwReserved1;wchar cFileName[260];wchar cAlternateFileName[14]"
GLOBAL CONST $TAGOSVERSIONINFO = "struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct"

MsgBox(262144 + 0, "Farbar FRST Downloader Updater", "This utility will now download the latest version of Farbar FRST from Bleeping Computer. " & @CRLF & "This utility was created by sly#7558 for the PC Help Hub Discord. "  & @CRLF & " " & @CRLF & "This message box will timeout after 5 seconds or select the OK button.", 5)

DIRCREATE("C:\FRST")
$FRSTDIR = "C:\FRST"
DIRCREATE("C:\FRST\logs")
$LPATH = "C:\FRST\logs\"
IF FILEEXISTS($LPATH & "up64") THEN FILEDELETE($LPATH & "up64")
$UP64 = INETGET("http://download.bleepingcomputer.com/farbar/up64", $LPATH & "up64", 1, 0)
IF NOT $UP64 OR NOT FILEEXISTS($LPATH & "up64") THEN MsgBox(262144 + 0, "Error 1 Updating FRST", "This message box will timeout after 10 seconds or select the OK button.", 10)
$VER1 = FILEREAD($LPATH & "up64")
FILEDELETE($LPATH & "up64")
FILEDELETE($LPATH & "FRSTupdate")
$RET = INETGET("http://www.bleepingcomputer.com/download/farbar-recovery-scan-tool/dl/82/", $LPATH & "FRSTupdate", 1, 0)
IF NOT $RET OR NOT FILEEXISTS($LPATH & "FRSTupdate") THEN RETURN MsgBox(262144 + 0, "Error 2 Updating FRST", "This message box will timeout after 10 seconds or select the OK button.", 10)
$PATH = FILEREAD($LPATH & "FRSTupdate")
$PATH = STRINGREGEXP($PATH, "(?i)url=(https://download.bleepingcomputer.com/dl/.+/farbar-recovery-scan-tool/FRST64.exe)", 1)
FILEDELETE($LPATH & "FRSTupdate")
IF NOT ISARRAY($PATH) THEN MsgBox($MB_SYSTEMMODAL, "Error 3 Updating FRST", "This message box will timeout after 10 seconds or select the OK button.", 10)
FILEDELETE($LPATH & "FRST64*.exe")
INETGET($PATH[0], $LPATH & "FRST64.exe", 1, 0)
DIRCREATE($FRSTDIR & "\FRST-OlderVersion")
FILEMOVE($FRSTDIR & "\" & "FRST64.exe", $FRSTDIR & "\FRST-OlderVersion", 1)
FILEMOVE($FRSTDIR & "\*FRST*.exe", $FRSTDIR & "\FRST-OlderVersion", 1)
FILEMOVE($LPATH & "FRST64.exe", $FRSTDIR & "\" & "FRST64.exe", 1)
FILEDELETE($LPATH & "FRST64.exe")
MSGBOX(262144 + 0, "FRST Downloader Updater", "FRST Downloaded to C:\FRST\"  & @CRLF &  "We will now launch FRST as admin")
SHELLEXECUTE($FRSTDIR & "\" & "FRST64.exe")
EXIT

FUNC _GETFILEPRO($PATH1)
	$PDATA = 0
	IF NOT _WINAPI_GETFILEVERSIONINFO($PATH1, $PDATA) THEN RETURN
	LOCAL $RET = _WINAPI_VERQUERYVALUE($PDATA)
	_WINAPI_FREEMEMORY($PDATA)
	RETURN $RET
ENDFUNC

FUNC _WINAPI_GETFILEVERSIONINFO($SFILEPATH, BYREF $PBUFFER, $IFLAGS = 0)
	LOCAL $ACALL
	IF _WINAPI_GETVERSION() >= 6 THEN
		$ACALL = DLLCALL("version.dll", "dword", "GetFileVersionInfoSizeExW", "dword", BITAND($IFLAGS, 3), "wstr", $SFILEPATH, "ptr", 0)
	ELSE
		$ACALL = DLLCALL("version.dll", "dword", "GetFileVersionInfoSizeW", "wstr", $SFILEPATH, "ptr", 0)
	ENDIF
	IF @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(@ERROR, @EXTENDED, 0)
	$PBUFFER = __HEAPREALLOC($PBUFFER, $ACALL[0], 1)
	IF @ERROR THEN RETURN SETERROR(@ERROR + 100, @EXTENDED, 0)
	LOCAL $INBBYTE = $ACALL[0]
	IF _WINAPI_GETVERSION() >= 6 THEN
		$ACALL = DLLCALL("version.dll", "bool", "GetFileVersionInfoExW", "dword", BITAND($IFLAGS, 7), "wstr", $SFILEPATH, "dword", 0, "dword", $INBBYTE, "ptr", $PBUFFER)
	ELSE
		$ACALL = DLLCALL("version.dll", "bool", "GetFileVersionInfoW", "wstr", $SFILEPATH, "dword", 0, "dword", $INBBYTE, "ptr", $PBUFFER)
	ENDIF
	IF @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(@ERROR + 10, @EXTENDED, 0)
	RETURN $INBBYTE
ENDFUNC
FUNC _WINAPI_GETVERSION()
	LOCAL $TOSVI = DLLSTRUCTCREATE($TAGOSVERSIONINFO)
	DLLSTRUCTSETDATA($TOSVI, 1, DLLSTRUCTGETSIZE($TOSVI))
	LOCAL $ACALL = DLLCALL("kernel32.dll", "bool", "GetVersionExW", "struct*", $TOSVI)
	IF @ERROR OR NOT $ACALL[0] THEN RETURN SETERROR(@ERROR, @EXTENDED, 0)
	RETURN NUMBER(DLLSTRUCTGETDATA($TOSVI, 2) & "." & DLLSTRUCTGETDATA($TOSVI, 3), 3)
ENDFUNC
FUNC _WINAPI_READFILE($HFILE, $PBUFFER, $ITOREAD, BYREF $IREAD, $TOVERLAPPED = 0)
	LOCAL $ACALL = DLLCALL("kernel32.dll", "bool", "ReadFile", "handle", $HFILE, "struct*", $PBUFFER, "dword", $ITOREAD, "dword*", 0, "struct*", $TOVERLAPPED)
	IF @ERROR THEN RETURN SETERROR(@ERROR, @EXTENDED, FALSE)
	$IREAD = $ACALL[4]
	RETURN $ACALL[0]
ENDFUNC