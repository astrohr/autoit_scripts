; RunMaxImDL
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
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




$button = MsgBox($MB_OKCANCEL + $MB_ICONWARNING + $MB_DEFBUTTON1 + $MB_TASKMODAL + $MB_SETFOREGROUND,	$sTitle,	"Open 2 SSH connections to TCS and do:" & @LF & @LF & " • d init" & @LF &	" • d api run" & @LF & @LF & "Do this before continuing!")

if $button == $IDCANCEL Then
	MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TASKMODAL + $MB_SETFOREGROUND, $sTitle, "Canceled")
	Exit
EndIf



$sTTPath = "D:\Pictures\TT"

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



Run("C:\Program Files (x86)\Diffraction Limited\MaxIm DL V6\MaxIm_DL.exe", "C:\Users\operator\Documents\MaxIm DL 6\")

$started = WinWaitActive("MaxIm DL Pro 6", "", 10)
If Not $started Then _Exitonerror("MaxIm failed to start!")

$hWin = WinGetHandle("MaxIm DL Pro 6")
