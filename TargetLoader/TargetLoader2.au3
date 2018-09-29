; Loader2
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=TargetLoader.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#include <Date.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <FontConstants.au3>
#include <GUIConstants.au3>
#include <guiconstantsex.au3>
#include "GUIScrollbars_Ex.au3"
#include <GuiTab.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <WinAPIFiles.au3>




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Read data file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Global $aTargetNames[0]
Global $aTargetRas[0]
Global $aTargetDes[0]

Local $dToday=_DateToDayValue(@YEAR, @MON, @MDAY),$Y, $M, $D

If @HOUR < 12 Then
	$dToday=_DayValueToDate($dToday-1, $Y, $M, $D)
	$dToday= StringFormat("%04i-%02i-%02i", $Y,  $M,  $D)
EndIf

$sFileName = $dToday & ".txt"
$sFileDir = "D:\Pictures\TT\" & $dToday
$sFilePath = $sFileDir & "\" & $sFileName


$hFileOpen = FileOpen($sFilePath, $FO_READ)
If $hFileOpen = -1 Then
	MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file.")
	Exit
EndIf


Func ParseObjectName($sLine)
	Local $aName
	$aName = StringRegExp($sLine, "^\s?\*\s?([a-zA-Z0-9]{5,12})(?:[\s\t]+|$)", $STR_REGEXPARRAYMATCH)
	if UBound($aName) Then
		Return $aName[0]
	EndIf
	Return ""

EndFunc

Func ParseCoords($sLine)
	Local $aRaDe[2]
	If StringMid($sLine, 1, 2) <> "20" Then
		Return
	EndIf
	$aRaDe[0] = StringMid($sLine, 19, 10)
	$aRaDe[1] = StringMid($sLine, 30, 10)
	Return $aRaDe
EndFunc


Func ParseLine($sLine, $sObjectName)
	Local $sNewName = ParseObjectName($sLine)
	Local $aRaDe[2]
	Local $aLineData[3]
	If $sNewName <> "" Then
		$aLineData[0] = $sNewName
	Else
		$aLineData[0] = $sObjectName
		$aRaDe = ParseCoords($sLine)
		If UBound($aRaDe) == 2 Then
			$aLineData[1] = $aRaDe[0]
			$aLineData[2] = $aRaDe[1]
		EndIf
	EndIf
	Return $aLineData
EndFunc

Global $aLines[0]
Global $aLineTargets[0]
Global $aLineRa[0]
Global $aLineDe[0]

Local $sObjectName = ""
For $i = 1 to _FileCountLines($sFilePath)
    Local $line
	Local $aRaDe[2]
	Local $aLineData[3]
	$line = FileReadLine($hFileOpen, $i)

	_ArrayAdd($aLines, $line);

	if StringMid($line, 1, 1) <> "#" Then

		$aLineData = ParseLine($line, $sObjectName)
		$sObjectName = $aLineData[0]

		If UBound($aLineData) > 1 Then
			_ArrayAdd($aLineTargets, $aLineData[0])
			_ArrayAdd($aLineRa, $aLineData[1])
			_ArrayAdd($aLineDe, $aLineData[2])
		Else
			_ArrayAdd($aLineTargets, False)
			_ArrayAdd($aLineRa, False)
			_ArrayAdd($aLineDe, $aLineData[2])
		EndIf
	EndIf

Next
FileClose($hFileOpen)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Present GUI target selector ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global $aLabelCtls[0]

$hGUI = GuiCreate("TargetLoader", 1000, 900, -1, -1 )
$Btn_Start = GUICtrlCreateDummy()
Local $x = 0
For $i = 0 To UBound($aLines) - 1
    $x = $i * 15 + 50
    $hLabel = GUICtrlCreateLabel($aLines[$i], 40, $x, 1000, 15)
	_ArrayAdd($aLabelCtls, $hLabel)
	If $aLineRa[$i] Then
		GUICtrlSetCursor($hLabel, 0)
	EndIf
	GUICtrlSetFont($hLabel, 8.5, $FW_DONTCARE, 0, "Courier New")
Next
$Btn_End = GUICtrlCreateDummy()


GUISetState(@SW_SHOW, $hGUI)


_GUIScrollbars_Generate($hGUI, 350, $x + 50)

$lastLabel = ""


Func GetIndex($hLabel)
	For $i=0 to UBound($aLabelCtls) - 1
		if $aLabelCtls[$i] == $hLabel Then
			Return $i
		EndIf
	Next
	Return -1
EndFunc


Global $iClicked = -1

While 1

    $hLabel = GUIGetMsg()
    Switch $hLabel
        Case $GUI_EVENT_CLOSE
            Exit
		Case $Btn_Start To $Btn_End
			$iClicked = GetIndex($hLabel)
            If $aLineRa[$iClicked] Then
				ExitLoop
			EndIf
	EndSwitch

    $aInfo = GUIGetCursorInfo($hGUI)
	$hLabel = $aInfo[4]
	Switch $hLabel
		Case $Btn_Start To $Btn_End
			$iHovered = GetIndex($hLabel)
			If $lastLabel <> $hLabel Then
				For $i = 0 To UBound($aLabelCtls) - 1
					If $i == $iHovered And $aLineRa[$i] Then
						GUICtrlSetFont($aLabelCtls[$i], 8.5, $FW_DONTCARE, $GUI_FONTUNDER, "Courier New")
					Else
						GUICtrlSetFont($aLabelCtls[$i], 8.5, $FW_DONTCARE, 0, "Courier New")
					EndIf
				Next
				$lastLabel = $hLabel
			EndIf
	EndSwitch

Wend

GUIDelete($hGUI)


$sName = $aLineTargets[$iClicked]
$sRa = $aLineRa[$iClicked]
$sDe = $aLineDe[$iClicked]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Fill data to MaxIm DL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$hObservatoryWnd = WinWait("Observatory", "Tab1", 1)

If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Observatory window on found!")
	Exit
EndIf

$hTab = ControlGetHandle($hObservatoryWnd, 'Tab1', 2746)
$tIndex = _GUICtrlTab_FindTab($hTab, 'Telescope', False, 0)
If $tIndex = -1 Then
    MsgBox(0, 'ERROR', 'Cannot Find Telescope Tab')
	Exit
Else
    _GUICtrlTab_SetCurFocus($hTab, $tIndex)
EndIf


$hCtrlRaText = ControlGetHandle($hObservatoryWnd, "", 1907)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No RA TextBox")
	Exit
EndIf

$hCtrlDeText = ControlGetHandle($hObservatoryWnd, "", 1910)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No DE TextBox")
	Exit
EndIf


ControlSetText($hObservatoryWnd, "", 1907, $sRa)
ControlSetText($hObservatoryWnd, "", 1910, $sDe)




$hCameraWnd = WinWait("Camera Control", "Guide", 1)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Camera Control window on found!")
	Exit
EndIf

$hTab = ControlGetHandle($hCameraWnd, "", "SysTabControl321")
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Cannot find tabs on Camera Control window!")
	Exit
EndIf

$tIndex = _GUICtrlTab_FindTab($hTab, "Expose", False, 0)
If $tIndex = -1 Then
    MsgBox(0, 'ERROR', 'Cannot Find Expose Tab')
	Exit
Else
    _GUICtrlTab_SetCurFocus($hTab, $tIndex)
EndIf


$hAutosaveBtn = ControlGetHandle($hCameraWnd, "", 2447)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No Autosave Button")
	Exit
EndIf
ControlClick($hCameraWnd, "", 2447)




$hAutosaveWnd = WinWait("Autosave Setup", "Autosave Filename", 1)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Autosave Setup window on found!")
	Exit
EndIf

$hfilenameTxt = ControlGetHandle($hAutosaveWnd, "", 2069)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No Autosave Button")
	Exit
EndIf
ControlSetText($hAutosaveWnd, "", 2069, $sName)












