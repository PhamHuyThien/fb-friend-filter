#include-once
#include <FormMain.au3>
#include <Facebook.au3>
#include <Util.au3>

HotKeySet("!{F4}", "_Util_Exit");

;-------------------------------------------------------
Local $__sName = "Lọc Bạn Bè Không Tương Tác", _
		$__sVersion = "1.2", _
		$__sAuthor = "ThienDz", _
		$__sCreated = "2020" ;
;-------------------------------------------------------
Local $__sUsers = Null, _
		$__sFriends = Null ;
;-------------------------------------------------------
__ThienDz_Nov3Mber_LoveU__Main() ;
;-------------------------------------------------------
Func __ThienDz_Nov3Mber_LoveU__Main()
	_FormMain_Init($__sName, $__sVersion, $__sAuthor, $__sCreated) ;
	_FormMain_Show() ;
	_FormMain_WaitResult("__Main_Login", "__Main_Remove", "__Main_Contact") ;
EndFunc   ;==>__ThienDz_Nov3Mber_LoveU__Main
;-------------------------------------------------------

Func __Main_Login()
	$__sCookie = _Util_Trim(GUICtrlRead($_GUI_InpCookie)) ;
	If $__sCookie == "" Then
		_Util_MsgWarn("Bạn phải nhập cookie trước!") ;
		Return ;
	EndIf
	_FormMain_SetEnabled(False) ;
	_Util_ToolTip("Đang đăng nhập...", "Xin chờ ít giây...", $_GUI_Main) ;
	$__sUsers = _Facebook_Login($__sCookie) ;
	If $__sUsers == False Then
		GUICtrlSetState($_GUI_InpCookie, $GUI_ENABLE) ;
		GUICtrlSetState($_GUI_BtnLogin, $GUI_ENABLE) ;
		_Util_ToolTipReset() ;
		_Util_MsgErr("Cookie hết hạn!") ;
		Return ;
	EndIf
	_Util_ToolTip("Đang lấy danh sách bạn bè...", "Xin chờ ít giây...", $_GUI_Main) ;
	$__sFriends = _Facebook_GetFriends($__sUsers) ;
	If $__sFriends == False Then
		GUICtrlSetState($_GUI_InpCookie, $GUI_ENABLE) ;
		GUICtrlSetState($_GUI_BtnLogin, $GUI_ENABLE) ;
		_Util_ToolTipReset() ;
		_Util_MsgErr("Lấy danh sách bạn bè thất bại!") ;
		Return ;
	EndIf
	_Util_ToolTipReset() ;
	_FormMain_SetEnabled() ;
	_Util_MsgSucc("Đăng nhập thành công!" & @CRLF & "Xin chào " & $__sUsers[2] & "^^" & @CRLF & "Bạn hiện có " & UBound($__sFriends) & " bạn bè.") ;
EndFunc   ;==>__Main_Login


Func __Main_Remove()
	$__nScoreReact = _Util_Trim(GUICtrlRead($_GUI_InpScoreReact)) ;
	$__nScoreCmt = _Util_Trim(GUICtrlRead($_GUI_InpScoreCmt)) ;
	$__nScoreOut = _Util_Trim(GUICtrlRead($_GUI_InpScoreOut)) ;
	$__sGenderRemove = _Util_Trim(GUICtrlRead($_GUI_CbbGender)) ;
	$__nGenderRemove = $__sGenderRemove == "All" ? 0 : ($__sGenderRemove == "Male" ? 1 : -1) ;
	;
	If $__nScoreReact < 1 Then
		_Util_MsgWarn("Điểm Tương tác phải lớn hơn 0!") ;
		Return ;
	EndIf
	If $__nScoreCmt < 1 Then
		_Util_MsgWarn("Điểm Bình luận phải lớn hơn 0!") ;
		Return ;
	EndIf
	If $__nScoreOut < 1 Then
		_Util_MsgWarn("Điểm phải đạt phải lớn hơn 0!") ;
		Return ;
	EndIf
	;
	_FormMain_SetEnabled(False) ;
	_Util_ToolTip("Đang thông kê tương tác 500 bài gần nhất...", "Xin chờ ít phút...", $_GUI_Main) ;
	$__jFriend = _Facebook_SetScore($__sUsers, $__sFriends) ;
	If $__jFriend == False Then
		_Util_ToolTipReset() ;
		_Util_MsgErr("Thông kê tương tác thất bại!") ;
		Return ;
	EndIf
	_Util_ToolTip("Đang xác định bạn bè cần xóa...", "Xin chờ ít giây...", $_GUI_Main) ;
	$__jFriend = _Facebook_SetRemove($__jFriend, $__nScoreReact, $__nScoreCmt, $__nScoreOut, $__nGenderRemove) ;
	;
	_Util_ToolTipReset() ;
	$__sFriendRemoves = __Main_jBodyToArray($__jFriend) ;
	_Util_MsgSucc("Tổng có tất cả " & UBound($__sFriendRemoves) & " người không tương tác!" & @CRLF & @CRLF & "Sau đây là danh sách những người sẽ bị loại bỏ." & @CRLF & @CRLF & "Nhấn oke để xem danh sách...") ;
	_ArrayDisplay($__sFriendRemoves) ;
	$__nTypeRemove = MsgBox(32 + 3, "Cảnh báo", "Hãy chọn kiểu lọc bạn bè:" & @CRLF & @CRLF & "Yes: Xóa tự động (Không hỏi)" & @CRLF & @CRLF & "No: Xóa bán tự động (Hỏi trước khi xóa)" & @CRLF & @CRLF & "Canel: Hủy lọc bạn bè" & @CRLF & @CRLF & "Lưu ý: Lên chọn No đề phòng xóa nhầm người không mong muốn!") ;
	If $__nTypeRemove == 6 Or $__nTypeRemove == 7 Then
		For $__i = 0 To UBound($__sFriendRemoves) - 1
			$__nCheck = True ;
			If $__nTypeRemove == 7 Then
				$__nCheck = MsgBox(32 + 4, "Cảnh báo", "Bạn muốn xóa " & $__sFriendRemoves[$__i][0] & " (" & $__sFriendRemoves[$__i][1] & ") không?") == 6 ? True : False ;
			EndIf
			If $__nCheck Then
				If _Facebook_RemoveFriend($__sUsers, $__sFriendRemoves[$__i][1]) Then
					_Util_Tooltip("Thông báo", "Xóa " & $__sFriendRemoves[$__i][0] & " (" & $__sFriendRemoves[$__i][1] & ") Thành công!", $_GUI_Main) ;
				Else
					_Util_Tooltip("Thất bại!", "Xóa " & $__sFriendRemoves[$__i][0] & " (" & $__sFriendRemoves[$__i][1] & ") Thất bại!", $_GUI_Main) ;
				EndIf
				Sleep(1000) ;
			EndIf
		Next
	Else
		_FormMain_SetEnabled() ;
	EndIf
	_Util_ToolTipReset() ;
	_Util_MsgSucc("Lọc bạn bè không tương tác hoàn thành!") ;
EndFunc   ;==>__Main_Remove


Func __Main_Contact()
	_Util_OpenTabBrowser() ;
EndFunc   ;==>__Main_Contact

;-------------------------------------------------------
Func __Main_jBodyToArray($__jFriend)
	$__sKeys = $__jFriend.keys() ;
	Local $__sFriendRemoves[1][4] ;
	For $__i = 0 To $__sKeys.length() - 1
		$__sKey = $__sKeys.index($__i) ;
		$__jFriendScore = $__jFriend.get($__sKey) ;
		If $__jFriendScore.remove == True Then
			Dim $__sFriendRemove = [[$__jFriendScore.name, $__sKey, $__jFriendScore.gender, $__jFriendScore.total_score]] ;
			_ArrayAdd($__sFriendRemoves, $__sFriendRemove) ;
		EndIf
	Next
	_ArrayDelete($__sFriendRemoves, 0) ;
	Return $__sFriendRemoves ;
EndFunc   ;==>__Main_jBodyToArray

;-------------------------------------------------------






