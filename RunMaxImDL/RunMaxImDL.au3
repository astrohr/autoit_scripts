#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=MaxIm_DL_264.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; RunMaxImDL
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <GuiTab.au3>
#include <File.au3>
#include <Constants.au3>
#include <WinAPI.au3>
#include <GUIConstants.au3>

$sTitle = "MaxIm DL Launcher"

Func _Exitonerror($sText)
    MsgBox(16, $sTitle, $sText)
    Exit
EndFunc

If ProcessExists("MaxIm_DL.exe") Then
	WinActivate("MaxIm DL Pro 6")
	Exit
EndIf



$sTTPath = IniRead("C:\Users\operator\Documents\AutoIt_scripts\dagor_scripts.ini", "General", "PhotoFolder", "D:\Pictures\TT")


$aFitsList = _FileListToArray($sTTPath, "*.fit", $FLTA_FILES, True)

If Not @error Then

	$button = MsgBox(	$MB_YESNO + $MB_ICONWARNING + $MB_DEFBUTTON1 + $MB_TASKMODAL + $MB_SETFOREGROUND,	$sTitle,	"Number of FITS images in " & $sTTPath & " directory:  " & $aFitsList[0] & @LF & @LF & "These images will be deleted! (subfolders not affected)" & @LF & @LF & "Is that OK?")

	If $button == $IDNO Then
		MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TASKMODAL + $MB_SETFOREGROUND, $sTitle, "Canceled")
		Exit
	EndIf


	For $i = 1 To $aFitsList[0]
		$sFitFile = $aFitsList[$i]
		FileDelete($sFitFile)
	Next
EndIf



Run("C:\Program Files (x86)\Diffraction Limited\MaxIm DL 6\MaxIm_DL.exe", "C:\Users\operator\Documents\MaxIm DL 6\")

$started = WinWaitActive("MaxIm DL Pro 6", "", 10)
If Not $started Then _Exitonerror("MaxIm failed to start!")

$hWin = WinGetHandle("MaxIm DL Pro 6")
