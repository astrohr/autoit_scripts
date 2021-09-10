#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=TargetLoader.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#include <Array.au3>
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
#include <GetAllWindowsControls.au3>


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Read data file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Global $aTargetNames[0]
Global $aTargetRas[0]
Global $aTargetDes[0]
Global $aTargetReps[0]
Global $aTargetExps[0]
Global $aTargetTime[0]

Local $dToday = _DateToDayValue(@YEAR, @MON, @MDAY), $Y, $M, $D

If @HOUR < 12 Then
	$dToday = _DayValueToDate($dToday - 1, $Y, $M, $D)
	$dToday = StringFormat("%04i-%02i-%02i", $Y, $M, $D)

Else
	$dToday = _DayValueToDate($dToday, $Y, $M, $D)
	$dToday = StringFormat("%04i-%02i-%02i", $Y, $M, $D)
EndIf

$sFileName = $dToday & "-log.txt"
$sTTPath = IniRead("C:\Users\operator\Documents\AutoIt_scripts\dagor_scripts.ini", "General", "PhotoFolder", "D:\Pictures\TT")
$sFileDir = $sTTPath & "\" & $dToday
$sFilePath = $sFileDir & "\" & $sFileName


;$hFileOpen = FileOpen($sFilePath, $FO_READ)
$hFileOpen = FileOpen($sFilePath, 0)
If $hFileOpen = -1 Then
	MsgBox($MB_SYSTEMMODAL, "", "An error occurred when reading the file. " & $sFilePath)
	Exit
EndIf

Func ParseObjectName($sLine)
	Local $aName
	$aName = StringRegExp($sLine, "^\s?\*\s?([a-zA-Z0-9_]{3,12})(?:[\s\t]+|$)", $STR_REGEXPARRAYMATCH)
	If UBound($aName) Then
		Return $aName[0]
	EndIf
	Return ""
EndFunc   ;==>ParseObjectName

Func ParseObjectRepeat($sLine)
	Local $aExpStr
	$aExpStr = StringRegExp($sLine, "^\s?\*\s?(?:[a-zA-Z0-9_]{3,12})(?:[\s\t]+)(?:[0-9]+\.[0-9]+[\s\t]+)?([0-9]{1,3})(?:[\s\t]+|$)", $STR_REGEXPARRAYMATCH)
	If UBound($aExpStr) Then
		Return $aExpStr[0]
	EndIf
	Return ""
EndFunc   ;==>ParseObjectRepeat

Func ParseObjectExposure($sLine)
	Local $aExpStr
	$aExpStr = StringRegExp($sLine, "^\s?\*\s?(?:[a-zA-Z0-9_]{3,12})(?:[\s\t]+)(?:[0-9]+\.[0-9]+[\s\t]+)?(?:[0-9]+\s{1,3})?x\s{1,3}([0-9]{1,4})(?:[\s\t]+|$)", $STR_REGEXPARRAYMATCH)
	If UBound($aExpStr) Then
		Return $aExpStr[0]
	EndIf
	Return ""
EndFunc   ;==>ParseObjectExposure

Func ParseCoords($sLine)
	Local $aRaDe[2]
	If StringMid($sLine, 1, 2) <> "20" Then
		Return
	EndIf
	$aRaDe[0] = StringMid($sLine, 19, 10)
	$aRaDe[1] = StringMid($sLine, 30, 10)
	Return $aRaDe
EndFunc   ;==>ParseCoords

Func ParseObjectTime($sLine)
	Local $aExpStr
	If StringMid($sLine, 1, 2) <> "20" Then
		Return
	EndIf
	$aExpStr = StringMid($sLine, 12, 4)
	Return $aExpStr
EndFunc   ;==>ParseObjectTime

Func ParseLine($sLine, $sObjectName, $sObjectRepeat, $sObjectExposure, $sObjectTime)
	Local $sNewName = ParseObjectName($sLine)
	Local $sNewRepeat = ParseObjectRepeat($sLine)
	Local $sNewExposure = ParseObjectExposure($sLine)
	Local $aRaDe[2]
	Local $sNewTime = ParseObjectTime($sLine)
	Local $aLineData[6]
	If $sNewName <> "" Then
		$aLineData[0] = $sNewName
		$aLineData[1] = Null  ; Ra
		$aLineData[2] = Null  ; De
		$aLineData[3] = $sNewRepeat
		$aLineData[4] = $sNewExposure
		$aLineData[5] = $sNewTime
	Else
		$aLineData[0] = $sObjectName
		$aLineData[3] = $sObjectRepeat
		$aLineData[4] = $sObjectExposure
		$aRaDe = ParseCoords($sLine)
		If UBound($aRaDe) == 2 Then
			$aLineData[1] = $aRaDe[0]
			$aLineData[2] = $aRaDe[1]
		EndIf
		$aLineData[5] = $sNewTime
	EndIf
	Return $aLineData
EndFunc   ;==>ParseLine


Local $sObjectName = ""
Local $sObjectRepeat = ""
Local $sObjectExp = ""
Local $sObjectTime = ""
For $i = 1 To _FileCountLines($sFilePath)
	Local $line
	Local $aRaDe[2]
	Local $aLineData[3]
	$line = FileReadLine($hFileOpen, $i)

	If StringMid($line, 1, 1) == "#" Then
		; comment, skip line
		ContinueLoop
	EndIf
	$aLineData = ParseLine($line, $sObjectName, $sObjectRepeat, $sObjectExp, $sObjectTime)

	$sObjectName = StringStripWS($aLineData[0], 8)
	$sObjectRepeat = StringStripWS($aLineData[3], 3)
	$sObjectExp = StringStripWS($aLineData[4], 4)
	$sObjectTime = StringStripWS($aLineData[5], 4)
	If StringLen($sObjectRepeat) < 1 Then
		$sObjectRepeat = "NN"
	EndIf
	If StringLen($sObjectExp) < 1 Then
		$sObjectExp = "??"
	EndIf

	If $aLineData[1] Then
		$aRaDe[0] = $aLineData[1]
		$aRaDe[1] = $aLineData[2]
	EndIf
	If $aRaDe[0] Then
		_ArrayAdd($aTargetNames, $sObjectName)
		_ArrayAdd($aTargetRas, $aLineData[1])
		_ArrayAdd($aTargetDes, $aLineData[2])
		_ArrayAdd($aTargetReps, $sObjectRepeat)
		_ArrayAdd($aTargetExps, $sObjectExp)
		_ArrayAdd($aTargetTime, $sObjectTime)
	EndIf

Next
FileClose($hFileOpen)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Present GUI target selector ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global $aLabelCtls[0]

$hGUI = GUICreate("TargetLoader", 560, 700, -1, -1)
$Btn_Start = GUICtrlCreateDummy()
For $i = 0 To UBound($aTargetNames) - 1
	$x = $i * 30 + 50
	$hLabel = GUICtrlCreateLabel(StringFormat("%-15s", $aTargetNames[$i]) & @TAB & $aTargetRas[$i] & @TAB & $aTargetDes[$i] & @TAB & $aTargetReps[$i] & " × " & $aTargetExps[$i] & " sec" & @TAB & $aTargetTime[$i], 40, $x, 480, 20)
	_ArrayAdd($aLabelCtls, $hLabel)
	GUICtrlSetCursor($hLabel, 0)
	GUICtrlSetFont($hLabel, 8.5, $FW_DONTCARE, 0, "Courier New")
Next
$Btn_End = GUICtrlCreateDummy()


GUISetState(@SW_SHOW, $hGUI)


_GUIScrollbars_Generate($hGUI, 350, $x + 50)


$lastLabel = ""

While 1

	$Msg = GUIGetMsg($hGUI)
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Btn_Start To $Btn_End
			$aLabelData = StringSplit(GUICtrlRead($Msg), @TAB)
			ExitLoop
	EndSwitch

	$aInfo = GUIGetCursorInfo($hGUI)
	Switch $aInfo[4]
		Case $Btn_Start To $Btn_End
			If $lastLabel <> $aInfo[4] Then
				For $i = 0 To UBound($aLabelCtls) - 1
					If $aLabelCtls[$i] == $aInfo[4] Then
						GUICtrlSetFont($aLabelCtls[$i], 8.5, $FW_DONTCARE, $GUI_FONTUNDER, "Courier New")
					Else
						GUICtrlSetFont($aLabelCtls[$i], 8.5, $FW_DONTCARE, 0, "Courier New")
					EndIf
				Next
				$lastLabel = $aInfo[4]
			EndIf
	EndSwitch

WEnd

GUIDelete($hGUI)


$sName = StringStripWS($aLabelData[1], 8)
$sRa = $aLabelData[2]
$sDe = $aLabelData[3]
$sRepXExp = StringSplit($aLabelData[4], " ")
$sRep = $sRepXExp[1]
$sExp = $sRepXExp[3]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; Fill data to MaxIm DL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$hObservatoryWnd = WinWait("Observatory", "Tab1", 3)

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
ControlSetText($hObservatoryWnd, "", $hCtrlRaText, $sRa)

$hCtrlDeText = ControlGetHandle($hObservatoryWnd, "", 1910)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No DE TextBox")
	Exit
EndIf
ControlSetText($hObservatoryWnd, "", $hCtrlDeText, $sDe)

$hCtrlJ2000Radio = ControlGetHandle($hObservatoryWnd, "", 3008)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No J2000 RadioButton")
	Exit
EndIf
ControlClick($hObservatoryWnd, "", $hCtrlJ2000Radio)


;$hCtrlMenuButton = GetAllWindowsControls($hObservatoryWnd, True, "" , "Button", 1877)[0]
;If @error Then
;	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No Menu Buton")
;	Exit
;EndIf
;ControlClick($hObservatoryWnd, "", $hCtrlMenuButton)
;WinWait("[class:#32768]")
;WinActivate("[class:#32768]")
;ControlSend($hObservatoryWnd, "", "[class:#32768]", "{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{ENTER}")
;Send("{DOWN}{DOWN}{DOWN}{DOWN}{DOWN}{ENTER}")
;Sleep(1000)

$hCameraWnd = WinWait("Camera Control", "Guide", 3)
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



$hAutosaveWnd = WinWait("Autosave Setup", "Autosave Filename", 3)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Autosave Setup window on found!")
	Exit
EndIf

$hfilenameTxt = ControlGetHandle($hAutosaveWnd, "", 2069)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "No Autosave Button")
Else
	ControlSetText($hAutosaveWnd, "", 2069, $sName)
EndIf


$hRepeatInput = ControlGetHandle($hAutosaveWnd, "", 2504)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Cannot find repeat input field!")
Else
	ControlSetText($hAutosaveWnd, "", $hRepeatInput, $sRep)
EndIf

$hExposureInput = ControlGetHandle($hAutosaveWnd, "", 2498)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Cannot find exposure input field!")
Else
	ControlSetText($hAutosaveWnd, "", $hExposureInput, $sExp)
EndIf

$hSuffixInput = ControlGetHandle($hAutosaveWnd, "", 2470)
If @error Then
	MsgBox($MB_OK + $MB_ICONWARNING, "LoadTarget", "Cannot find suffix input field!")
Else
	$sCurrentSuffix = ControlGetText($hAutosaveWnd, "", $hSuffixInput)
	$aSuffix = StringSplit($sCurrentSuffix, "_")
	$aSuffix[2] = $sExp
	$sSuffix = _ArrayToString($aSuffix, "_", 1)
	ControlSetText($hAutosaveWnd, "", $hSuffixInput, $sSuffix)
EndIf









