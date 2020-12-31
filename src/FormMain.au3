#include-once
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>


Global $_GUI_Main, $_GUI_BtnLogin, $_GUI_InpCookie, $_GUI_CbbGender, $_GUI_BtnContact, _
		$_GUI_InpScoreReact, $_GUI_InpScoreCmt, $_GUI_InpScoreOut, $_GUI_BtnRemove ;

Func _FormMain_Init($__sName, $__sVersion, $__sAuthor, $__sCreated)
	$_GUI_Main = GUICreate($__sName & " - v" & $__sVersion, 419, 289) ;
	GUISetBkColor(0xffffff) ;
	GUICtrlCreateLabel($__sName, 32, 8, 357, 35, $SS_CENTER) ;
	GUICtrlSetFont(-1, 20, 800, 0, "Times New Roman") ;
	GUICtrlCreateLabel("< Code by " & $__sAuthor & " - Thank LocMai />", 32, 48, 354, 22) ;
	GUICtrlSetFont(-1, 16, 400, 0, "Terminal") ;
	$_GUI_BtnLogin = GUICtrlCreateButton("Login", 320, 96, 83, 25) ;
	GUICtrlCreateGroup("Login With Cookie:", 8, 80, 401, 49) ;
	$_GUI_InpCookie = GUICtrlCreateInput("", 16, 96, 289, 21) ;
	GUICtrlCreateGroup("Config", 8, 136, 401, 105) ;
	GUICtrlCreateLabel("Score Rect: ", 16, 160, 64, 17) ;
	$_GUI_InpScoreReact = GUICtrlCreateInput("1", 80, 152, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER)) ;
	GUICtrlSetState(-1, $GUI_DISABLE) ;
	GUICtrlCreateLabel("Score Cmt:", 16, 184, 56, 17) ;
	$_GUI_InpScoreCmt = GUICtrlCreateInput("1", 80, 176, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER)) ;
	GUICtrlSetState(-1, $GUI_DISABLE) ;
	GUICtrlCreateLabel("Score Out:", 224, 160, 55, 17) ;
	$_GUI_InpScoreOut = GUICtrlCreateInput("1", 280, 152, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER)) ;
	GUICtrlSetState(-1, $GUI_DISABLE) ;
	GUICtrlCreateLabel("Gender: ", 224, 184, 45, 17) ;
	$_GUI_CbbGender = GUICtrlCreateCombo("All", 280, 176, 121, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL)) ;
	GUICtrlSetData(-1, "Male|Female") ;
	GUICtrlSetState(-1, $GUI_DISABLE) ;
	$_GUI_BtnRemove = GUICtrlCreateButton("Filter And Remove", 128, 208, 155, 25) ;
	GUICtrlSetState(-1, $GUI_DISABLE) ;
	GUICtrlCreateGroup("Contact", 8, 240, 401, 41) ;
	GUICtrlCreateLabel($__sName & " v" & $__sVersion & " @" & $__sCreated & " by " & $__sAuthor, 16, 256, 282, 17) ;
	$_GUI_BtnContact = GUICtrlCreateButton("Contact", 304, 256, 99, 17) ;
EndFunc   ;==>_FormMain_Init

Func _FormMain_Show()
	Return GUISetState(@SW_SHOW, $_GUI_Main) ;
EndFunc   ;==>_FormMain_Show


Func _FormMain_Hide()
	Return GUISetState(@SW_HIDE, $_GUI_Main) ;
EndFunc   ;==>_FormMain_Hide


Func _FormMain_WaitResult($__sFuncLogin = "", $__sFuncRemove = "", $__sFuncContact = "")
	While True
		$__nMsg = GUIGetMsg() ;
		Switch $__nMsg
			Case $GUI_EVENT_CLOSE
				Exit ;
			Case $_GUI_BtnLogin
				Call($__sFuncLogin) ;
			Case $_GUI_BtnRemove
				Call($__sFuncRemove) ;
			Case $_GUI_BtnContact
				Call($__sFuncContact) ;
		EndSwitch
	WEnd
EndFunc   ;==>_FormMain_WaitResult


Func _FormMain_SetEnabled($__bEnabled = True)
	$__bEnabled = $__bEnabled ? $GUI_ENABLE : $GUI_DISABLE ;
	GUICtrlSetState($_GUI_InpCookie, $__bEnabled) ;
	GUICtrlSetState($_GUI_BtnLogin, $__bEnabled) ;
	GUICtrlSetState($_GUI_InpScoreReact, $__bEnabled) ;
	GUICtrlSetState($_GUI_InpScoreCmt, $__bEnabled) ;
	GUICtrlSetState($_GUI_InpScoreOut, $__bEnabled) ;
	GUICtrlSetState($_GUI_CbbGender, $__bEnabled) ;
	GUICtrlSetState($_GUI_BtnRemove, $__bEnabled) ;
	GUICtrlSetState($_GUI_BtnContact, $__bEnabled) ;
EndFunc   ;==>_FormMain_SetEnable
