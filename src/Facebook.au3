#include <lib\_HttpRequest.au3>
#include <Util.au3>

Func _Facebook_RemoveFriend($__sUsers, $__sUidRemove)
	$__sUrl = "https://m.facebook.com/a/removefriend.php?friend_id=" & $__sUidRemove ;
	$__sParamPost = _
			"m_sess=" & _
			"&fb_dtsg=" & $__sUsers[3] & _
			"&jazoest=" & _Util_StrRand(4, 5) & _
			"&__csr=" & _
			"&__req=" & _Util_StrRand(5, 1) & _
			"&__user=" & $__sUsers[4] ;
	$__sBody = _HttpRequest(2, $__sUrl, _Data2SendEncode($__sParamPost), $__sUsers[0]) ;
	Return True ;
EndFunc   ;==>_Facebook_RemoveFriend

Func _Facebook_Follow($__sUsers, $__sUidFollow)
	$__sUrl = "https://www.facebook.com/ajax/follow/follow_profile.php" ;
	$__sParamPost = _
			"profile_id=" & $__sUidFollow & _
			"&location=1" & _
			"&feed_blacklist_action=show_followee_on_follow" & _
			"&__user=" & $__sUsers[4] & _
			"&__a=1" & _
			"&__dyn=" & _Util_StrRand(7, 305, "_-") & _
			"&__csr=" & _
			"&__req=" & _Util_StrRand(1, 1) & _
			"&__beoa=0" & _
			"&__pc=PHASED%3ADEFAULT" & _
			"&dpr=1" & _
			"&__rev=" & _Util_StrRand(4, 10) & _
			"&__s=" & _Util_StrRand(7, 6) & ":" & _Util_StrRand(7, 6) & ":" & _Util_StrRand(7, 6) & _
			"&__hsi=" & _Util_StrRand(4, 19) & "-0" & _
			"&__comet_req=0" & _
			"&fb_dtsg=" & $__sUsers[3] & _
			"&jazoest=" & _Util_StrRand(4, 5) & _
			"&__spin_r=" & _Util_StrRand(4, 10) & _
			"&__spin_b=trunk" & _
			"&__spin_t=" & _Util_StrRand(4, 10) ;

	$__sBody = _HttpRequest(2, $__sUrl, _Data2SendEncode($__sParamPost), $__sUsers[0], "https://www.facebook.com/" & $__sUsers[4]) ;
	$__jBody = __Facebook_BodyToJson($__sBody) ;
	;
	$__sUrl = "https://www.facebook.com/feed/profile/sub_follow/" ;
	$__sParamPost &= "&action=see_first&id=" & $__sUidFollow ;
	$__sBody = _HttpRequest(2, $__sUrl, _Data2SendEncode($__sParamPost), $__sUsers[0]) ;
	$__jBody2 = __Facebook_BodyToJson($__sBody) ;

	Return IsObj($__jBody) And IsObj($__jBody.onload) And IsObj($__jBody2) ;
EndFunc   ;==>_Facebook_Follow


Func _Facebook_SetRemove($__jFriend, $__nScoreReact = 1, $__nScoreCmt = 1, $__nScoreOut = 1, $__nGenderRemove = 0)
	$__sKeys = $__jFriend.keys() ;
	For $__i = 0 To $__sKeys.length() - 1
		;
		$__sKey = $__sKeys.index($__i) ;
		;
		$__sValueGender = $__jFriend.get($__sKey & ".gender") ;
		$__nValueReact = $__jFriend.get($__sKey & ".reaction") ;
		$__nValueCmt = $__jFriend.get($__sKey & ".comment") ;
		;
		$__nTotalScore = $__nValueReact * $__nScoreReact + $__nValueCmt * $__nScoreCmt ;
		;
		$__jFriend.set($__sKey & ".total_score", $__nTotalScore) ;
		$__jFriend.set($__sKey & ".remove", False) ;
		;
		$__nValueGender = __Facebook_GenderToNumber($__sValueGender) ;
		$__bRemove = ($__nValueGender == $__nGenderRemove Or $__nGenderRemove == 0) And $__nTotalScore < $__nScoreOut ;
		;
		$__jFriend.set($__sKey & ".remove", $__bRemove) ;
	Next
	Return $__jFriend ;
EndFunc   ;==>_Facebook_SetRemove


Func _Facebook_SetScore($__sUsers, $__sFriends) ;
	$__sUrl = "https://www.facebook.com/api/graphql/" ;
	$__sParamPost = _
			"fb_dtsg=" & $__sUsers[3] & _
			"&q=" & _URIEncode("node(" & $__sUsers[4] & "){timeline_feed_units.first(500).after(){page_info,edges{node{id,creation_time,feedback{reactors{nodes{id}},commenters{nodes{id}}}}}}}") ;
	;
	$__sBody = _HttpRequest(2, $__sUrl, _Data2SendEncode($__sParamPost), $__sUsers[0]) ;
	$__jBody = __Facebook_BodyToJson($__sBody) ;
	;
	If IsObj($__jBody) Then
		_Util_Debug("> _SetScore => Get Data Feed DONE") ;
		;
		$__jFriend = _HttpRequest_ParseJson("{}") ;
		For $__i = 0 To UBound($__sFriends) - 1
			$__sJsonAdd = '{"name": "' & $__sFriends[$__i][0] & '", "gender": "' & $__sFriends[$__i][1] & '", "reaction": 0, "comment": 0}' ;
			$__jFriend.set(String($__sFriends[$__i][2]), $__sJsonAdd) ;
		Next
		;
		$__jNodeFeed = $__jBody.get($__sUsers[4] & ".timeline_feed_units.edges") ;
		If IsObj($__jNodeFeed) Then
			_Util_Debug("> _SetScore => get edges timeline done!") ;
			;
			For $__i = 0 To $__jNodeFeed.length() - 1
				;
				$__jNodesReact = $__jNodeFeed.index($__i).node.feedback.reactors.nodes ;
				For $__j = 0 To $__jNodesReact.length() - 1 ;
					$__sKey = $__jNodesReact.index($__j).id ;
					If IsObj($__jFriend.get($__sKey)) Then
						$__sValue = $__jFriend.get($__sKey & ".reaction") ;
						$__jFriend.set($__sKey & ".reaction", $__sValue + 1) ;
					EndIf
				Next
				;
				$__jNodesCmt = $__jNodeFeed.index($__i).node.feedback.commenters.nodes ;
				For $__j = 0 To $__jNodesCmt.length() - 1 ;
					$__sKey = $__jNodesCmt.index($__j).id ;
					If IsObj($__jFriend.get($__sKey)) Then
						$__sValue = $__jFriend.get($__sKey & ".comment") ;
						$__jFriend.set($__sKey & ".comment", $__sValue + 1) ;
					EndIf
				Next
				;
			Next
			_Util_Debug("> _SetScore => DONE") ;
			Return $__jFriend ;
		EndIf
		_Util_Debug("! _SetScore => get edges timeline FAIL") ;
	EndIf
	_Util_Debug("! _SetScore => Get Data Feed FAIL") ;
	Return False ;
EndFunc   ;==>_Facebook_SetScore


Func _Facebook_GetFriends($__sUsers)
	;return [[name, gender, id], ...]
	$__sUrl = "https://graph.facebook.com/me/friends?fields=gender,name&limit=5000&access_token=" & $__sUsers[1];
	$__sBody = _HttpRequest(2, $__sUrl) ;
	$__jBody = _HttpRequest_ParseJson($__sBody) ;
	If IsObj($__jBody) And IsObj($__jBody.data) Then
		Local $__sFriends[$__jBody.data.length()][3] ;
		For $__i = 0 To UBound($__sFriends) - 1
			$__sFriends[$__i][0] = $__jBody.data.index($__i).name    ;
			$__sFriends[$__i][1] = $__jBody.data.index($__i).gender    ;
			$__sFriends[$__i][2] = $__jBody.data.index($__i).id    ;
		Next
		Return $__sFriends ;
	EndIf
	_Util_Debug("! _Facebook_GetFriends => Lấy danh sách bạn bè thất bại!") ;
	Return False ;
EndFunc   ;==>_Facebook_GetFriends


Func _Facebook_Login($__sCookie)
	;return [cookie, token, name, fb_dtsg, uid_me]
	$__sUrl = "https://mbasic.facebook.com/profile.php" ;
	$__sCookie = __Facebook_CookieCleaner($__sCookie) ;
	If $__sCookie <> False Then
		$__sBody = _HttpRequest(2, $__sUrl, "", $__sCookie) ;
		$__sNames = StringRegExp($__sBody, "\<title\>(.+?)\<\/title\>", 3) ;
		$__sFb_dtsgs = StringRegExp($__sBody, 'name\=\"fb\_dtsg\"\svalue\=\"(.+?)\"', 3) ;
		$__sUidMes = StringRegExp($__sBody, 'name\=\"target\"\svalue\=\"([0-9]+?)\"', 3) ;
		$__sToken = __Facebook_GetToken($__sCookie) ;
		If $__sNames <> 1 And $__sFb_dtsgs <> 1 And $__sUidMes <> 1 And $__sToken <> False Then
			Dim $aRes = [ _
					$__sCookie, _
					$__sToken, _
					$__sNames[0], _
					$__sFb_dtsgs[0], _
					$__sUidMes[0] _
					] ;
			Return $aRes ;
		EndIf
	EndIf
	_Util_Debug("! _CheckCookie => Không thể đăng nhập bằng cookie!") ;
	Return False ;
EndFunc   ;==>_Facebook_Login



;####################################################################################


Func __Facebook_BodyToJson($__sBody)
	$__sBody = StringReplace($__sBody, "for (;;);", "") ;
	$__jBody = _HttpRequest_ParseJson($__sBody) ;
	$__jBody = IsObj($__jBody) ? $__jBody : False ;
	Return $__jBody ;
EndFunc   ;==>__Facebook_BodyToJson


Func __Facebook_GenderToNumber($__sGender)
	Switch $__sGender
		Case "male"
			Return 1 ;
		Case Else
			Return -1 ;
	EndSwitch
EndFunc   ;==>__Facebook_GenderToNumber

Func __Facebook_GetToken($__sCookie)
	$__sUrl = "https://m.facebook.com/composer/ocelot/async_loader/?publisher=feed" ;
	$__sHeader = "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" ;
	$__sReferer = "https://facebook.com/" ;
	$__sBody = _HttpRequest(2, $__sUrl, "", $__sCookie, $__sReferer, $__sHeader) ;
	$__sTokens = StringRegExp($__sBody, "(EAAAA.+?ZD)", 3) ;
	If $__sTokens <> 1 Then
		Return $__sTokens[0] ;
	EndIf
	_Util_Debug("! __Facebook_GetToken => Không tìm thấy Regex=(EAAAA.+?ZD)!") ;
	Return False ;
EndFunc   ;==>__Facebook_GetToken



Func __Facebook_CookieCleaner($__sCookie)
	$__sFrs = StringRegExp($__sCookie, "(fr=.+?;)", 3) ;
	$__sXss = StringRegExp($__sCookie, "(xs=.+?;)", 3) ;
	$__sDatrs = StringRegExp($__sCookie, "(datr=.+?;)", 3) ;
	$__sC_users = StringRegExp($__sCookie, "(c_user=[0-9]+?;)", 3) ;
	If $__sFrs <> 1 And $__sXss <> 1 And $__sDatrs <> 1 And $__sC_users <> 1 Then
		Return $__sFrs[0] & $__sXss[0] & $__sDatrs[0] & $__sC_users[0] ;
	EndIf
	_Util_Debug("! __Facebook_CookieCleaner => Cookie sai định dạng!") ;
	Return False ;
EndFunc   ;==>__Facebook_CookieCleaner
