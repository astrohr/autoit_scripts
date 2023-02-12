#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


$hWnd = WinActivate("dagor@tcs", "DesktopWindowXamlSource")

If $hWnd == 0 Then
	Run('wt  -p "TCS - Shell"')
	$hWnd = WinWait("[CLASS:CASCADIA_HOSTING_WINDOW_CLASS]", "DesktopWindowXamlSource", 1)
	WinMove($hWnd, "", 450,0,1060, 700)
	Sleep(100)
	Send("+!d")
	Sleep(100)
	Send("+!d")
	Sleep(200)
	Send("+!d")
	Sleep(200)
	Send("d stop")
	Send("!{LEFT}")
	Send("d lights 3")
	Send("!{LEFT}")
	Send("!{LEFT}")
	;Send("sudo tail -f /run/log/dagor-tracking.log{ENTER}")
	Send("d goto run")
	Send("!{RIGHT}")
	Send("sudo tail -f /run/log/dagor-api.log{ENTER}")
	Send("!{LEFT}")
	Send("!{LEFT}")
	Send("+!h")
	Sleep(200)
	Send("d dome up")
	Send("!{U}")
EndIf

WinMove($hWnd, "", 450,0,1960, 860)
