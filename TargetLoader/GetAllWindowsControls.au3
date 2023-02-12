#include <Array.au3>
#include <WinAPI.au3>



; #FUNCTION# ====================================================================================================================
; Name ..........: GetAllWindowsControls
; Description ...:
; Syntax ........: GetAllWindowsControls($hCallersWindow[, $bOnlyVisible = Default[, $sStringIncludes = Default[, $sClass = Default]]])
; Parameters ....: $hCallersWindow      - a handle value.
;                  $bOnlyVisible        - [optional] a boolean value. Default is Default.
;                  $sStringIncludes     - [optional] a string value. Default is Default.
;                  $sClass              - [optional] a string value. Default is Default.
;                  $controlID           - [optional] an integer.
; Return values .: Array with Controls
; Author ........: jdelaney
; Modified ......: mLipok, frnhr
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/164226-get-all-windows-controls/
; Example .......: No
; ===============================================================================================================================
Func GetAllWindowsControls($hCallersWindow, $bOnlyVisible = Default, $sStringIncludes = Default, $sClass = Default, $controlID = Default)
	If Not IsHWnd($hCallersWindow) Then
		ConsoleWrite("$hCallersWindow must be a handle...provided=[" & $hCallersWindow & "]" & @CRLF)
		Return False
	EndIf

	; Get all list of controls
	If $bOnlyVisible = Default Then $bOnlyVisible = False
	If $sStringIncludes = Default Then $sStringIncludes = ""
	If $sClass = Default Then $sClass = ""
	If $controlID = Default Then $controlID = ""

	Local $sClassList = WinGetClassList($hCallersWindow)

	; Create array
	Local $aClassList = StringSplit($sClassList, @CRLF, 2)

	; Sort array
	_ArraySort($aClassList)
	_ArrayDelete($aClassList, 0)

	; Loop
	Local $iCurrentClass = ""
	Local $iCurrentCount = 1
	Local $iTotalCounter = 1

	If StringLen($sClass) > 0 Then
		For $i = UBound($aClassList) - 1 To 0 Step -1
			If $aClassList[$i] <> $sClass Then
				_ArrayDelete($aClassList, $i)
			EndIf
		Next
	EndIf

	Local $hControl = Null, $aControlPos
	Local $sControlText = ''
	Local $iControlID = 0
	Local $bIsVisible = False
	Local $aResult[0]

	For $iClass_idx = 0 To UBound($aClassList) - 1
		If $aClassList[$iClass_idx] = $iCurrentClass Then
			$iCurrentCount += 1
		Else
			$iCurrentClass = $aClassList[$iClass_idx]
			$iCurrentCount = 1
		EndIf


		$hControl = ControlGetHandle($hCallersWindow, "", "[CLASSNN:" & $iCurrentClass & $iCurrentCount & "]")
		$sControlText = StringRegExpReplace(ControlGetText($hCallersWindow, "", $hControl), "[\n\r]", "{@CRLF}")
		$aControlPos = ControlGetPos($hCallersWindow, "", $hControl)
		$iControlID = _WinAPI_GetDlgCtrlID($hControl)
		If $controlID And Int($controlID) <> $iControlID Then
			ContinueLoop
		EndIf
		$bIsVisible = ControlCommand($hCallersWindow, "", $hControl, "IsVisible")
		If $bOnlyVisible And Not $bIsVisible Then
			$iTotalCounter += 1
			ContinueLoop
		EndIf

		If StringLen($sStringIncludes) > 0 Then
			If Not StringInStr($sControlText, $sStringIncludes) Then
				$iTotalCounter += 1
				ContinueLoop
			EndIf
		EndIf

		_ArrayAdd($aResult, $hControl)

		If Not WinExists($hCallersWindow) Then ExitLoop
		$iTotalCounter += 1
	Next
	Return $aResult
EndFunc   ;==>GetAllWindowsControls