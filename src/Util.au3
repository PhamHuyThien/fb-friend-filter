#include-once
#include <IE.au3>

Func _Util_Exit()
	Exit;
EndFunc

Func _Util_TooltipReset()
	ToolTip("") ;
EndFunc   ;==>_Util_TooltipReset

Func _Util_Tooltip($__sTitle, $__sContent, $__hGUI)
	$__nPositions = WinGetPos($__hGUI) ;
	ToolTip($__sContent, $__nPositions[0], $__nPositions[1], $__sTitle, 1, 1) ;
EndFunc   ;==>_Util_Tooltip


Func _Util_MsgSucc($__sContent)
	MsgBox(64, "Thành công", $__sContent) ;
EndFunc   ;==>_Util_MsgSucc


Func _Util_MsgWarn($__sContent)
	MsgBox(48, "Cảnh báo", $__sContent) ;
EndFunc   ;==>_Util_MsgWarn


Func _Util_MsgErr($__sContent)
	MsgBox(16, "Lỗi", $__sContent) ;
EndFunc   ;==>_Util_MsgErr

Func _Util_Trim($__sString)
	Return StringStripWS($__sString, 1 + 2) ;
EndFunc   ;==>_Util_Trim

Func _Util_Debug($__sText)
	ConsoleWrite($__sText & @CRLF) ;
EndFunc   ;==>_Util_Debug


Func _Util_OpenTabBrowser($__sUrl = "https://facebook.com/ThienDz.SystemError")
	$__sParamShellChrome = $__sUrl & " --new-tab --full-screen" ;
	If ShellExecute("chrome.exe", $__sParamShellChrome) Then
		Return 1 ;
	EndIf
	If ShellExecute("C:\Users\" & @UserName & "\AppData\Local\CocCoc\Browser\Application\browser.exe", $__sParamShellChrome) Then
		Return 1 ;
	EndIf
	If IsObj(_IECreate($__sUrl)) Then
		Return 1 ;
	EndIf
	Return 0 ;
EndFunc   ;==>_Util_OpenTabBrowser


Func _Util_StrRand($iType = 7, $iLength = 25, $sAdd = "")
	$sLower = "qwertyuiopasdfghjklzxcvbnm" ;
	$sUpper = "QWERTYUIOPASDFGHJKLZXCVBNM" ;
	$iNumber = "1234567890" ;
	$sRand = $sAdd ;
	Switch $iType
		Case 1
			$sRand &= $sLower ;
		Case 2
			$sRand &= $sUpper ;
		Case 3
			$sRand &= $sLower & $sUpper ;
		Case 4
			$sRand &= $iNumber ;
		Case 5
			$sRand &= $iNumber & $sLower ;
		Case 6
			$sRand &= $iNumber & $sUpper ;
		Case Else
			$sRand &= $iNumber & $sLower & $sUpper ;
	EndSwitch
	$sResult = "" ;
	$aRand = StringSplit($sRand, "", 2) ;
	For $i = 1 To $iLength
		$sResult &= $aRand[Random(0, UBound($aRand) - 1)] ;
	Next
	Return $sResult ;
EndFunc   ;==>_Util_StrRand
