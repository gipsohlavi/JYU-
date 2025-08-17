#Requires AutoHotkey v2.0
#UseHook
SendMode "Event"
A_HotkeyInterval := 0


;------------------------------------------------------------ キーのリマップ -----------------------------------------------------------
; カタカナひらがなキー の全角半角キーへの変換はPowerToysで設定
; 主な変更要素
; 1.Shiftキーはスペースキーで併用(SandS)
; 2.無変換キー(Ctrl)+i,j,k,lで矢印キー Shift同時押しで範囲選択可能
; 3.LShiftキー同時押しで数字+演算記号
; 4.変換キーをBackSpaceキーに変更
; 5.数字キーは括弧や記号に割り当て

;------------------------------------------------- 緊急解除キー -------------------------------------------------
$*RAlt:: {
	Critical
	Send "{Shift Up}"
	Send "{Ctrl Up}"
	Send "{Alt Up}"
}
;----------------------------------------------------------------------------------------------------------------
; ---------------------------------------------------- SandS ----------------------------------------------------
Spress := 0     ; スペースキーを押しているかどうか。
Sshifted := 0   ; スペースキー押下中に何かの印字可能文字を押したかどうか。
SpressedAt := 0 ; スペースキーを押した時間（msec）。
Stimeout := 200 ; pressedAt からこの時間が経過したら、もはや離したときにもスペースを発射しない。

Shook := InputHook() ; スペースキー押下中に何かの印字可能文字を押したかどうか捕捉するフック。

$*Space:: {
	global
	Send "{RShift Down}"
	if (Spress = 1) {
		Send "{RShift Up}"
		return
	}
	Sshifted := 0
	Spress := 1
	SpressedAt := A_TickCount

	; 何かのキーが押されたことを検知する
	; L1 はフックする文字数の上限を 1 にする
	; V はフックした入力をブロックしない
	; デフォルトで印字可能文字のみフックされる
	Shook := InputHook("L1 V")

	; 一文字待機し、待機中にスペースを離したとき以外、
	; シフト済みにする
	Shook.Start()
	Shook.Wait()
	if (Shook.EndReason == "Max") {
		Sshifted := 1
	}
}

$*Space up:: {
	global
	Send "{RShift Up}"
	Spress := 0

	; 待機キャンセル
	Shook.Stop()

	; 一定時間経過していたらスペースを発射しない
	if (A_TickCount - SpressedAt > Stimeout) {
		return
	}

	; シフト済みでなければスペースを発射する
	; 先に押してあるモディファイアキーと組み合わせられるように {Blind} をつける
	if (Sshifted == 0) {
		Send "{Blind}{Space}"
	}
}
;----------------------------------------------------------------------------------------------------------------
; ---------------------------------------------------- LSandS ----------------------------------------------------
Shiftpress := 0     ;どちらのShiftキーを押しているかどうか判定

$*LShift:: {
	global
	Critical
	if  GetKeyState("RCtrl")  { 	; LShiftが押されたときに、無変換キーが押されているか調べる
		Send "{RShift Down}"	; 無変換キーが押されていれば、RShiftキーを発射
		Shiftpress := 1
		return
	}
	else   {
		Send "{LShift}"	; 無変換キーが押されていなければ、LShiftキーを発射
	}
}

$*LShift Up:: {
	global
	if (Shiftpress = 1) {
		Send "{RShift Up}"     ; RShiftキー解除
		Shiftpress := 0
	}
}
;----------------------------------------------------------------------------------------------------------------

;--------------------------------------------- 基本キー + Space -------------------------------------------------
;	 <数字キーの段>
	; 左手側数字キーに括弧類を配置
	;1::最大化/解除
		; ----マウスカーソル位置のウィンドウを最大化/元のサイズに戻す----
		WinTitle := 0    ;ウィンドウタイトルを格納
		MinMax := 0      ;ウィンドウが最小/最大化しているか
		$1:: { 	 	 ;F13(1)キーに割り当て
		global
		MousegetPos , , &id
		WinTitle := WinGetTitle(id)
		if (WinTitle !== "") {
			MinMax := WinGetMinMax(WinTitle)
		}
		else {
			Exit
		}
		if (MinMax == 0) {
			WinMaximize(WinTitle)
		}
		else If  (MinMax == 1) {
			WinRestore(WinTitle)
		}

		WinTitle := 0
		MinMax := 0
		}
	
	ArryBrackets := Array() ;どの括弧を入力したか保存
	RemovedValue := 0 ;配列から削除した値を格納
	2:: {
		global
		Send "{Blind}{[}"  ; [
		ArryBrackets.Push 1
	}
	>+2::return
	3::{
		global
		Send "{Blind+}+{8}"  ; (
		ArryBrackets.Push 2
	}
	>+3::{
		global
		Send "{Blind+}+{[}"  ; {
		ArryBrackets.Push 3
	}
	4:: { ;入力した括弧に応じて順番に閉じ括弧を発射する
		global
		Try
		{
			RemovedValue := ArryBrackets.Pop() ;最後に入力した括弧の値を取り出す
		}
		Catch
		{
			return ;配列が空であれば何も発射しない
		}
		if (RemovedValue == 1) {
			Send "{Blind+}{]}" ; ]
		}
		else if (RemovedValue == 2) {
			Send "{Blind+}+{9}" ; )
		}
		else if (RemovedValue == 3) { ; }
			Send "{Blind+}+{]}"
		}
	}
	>+4::return
	5::return
	>+5::return
	6::SendText "←"
	>+6::SendText "↑"
	7::SendText "→"
	>+7::SendText "↓"
	8::'
	>+8::"
	^::return
	$*\::Send "{Blind}{Esc}"
	$*\ up::Send "{Blind}{Esc}"

	; <tabキーの段>
	F13::-
	>+F13::~
	F14::,
	>+F14::!
	F17::$
	>+F17::_
	; <CapssLockキーの段>
	$Vkf0::
	$<+CapsLock::
	$<+Vkf0:: {
		Send "{Enter}"
	}
	$>+CapsLock::
	$>+Vkf0:: {
		Send "+{Enter}"
	}	
	$^CapsLock::
	$^Vkf0:: {
		Send "^{Enter}"
	}
	$!CapsLock::
	$!Vkf0:: {
		Send "!{Enter}"
	}
	F15::.
	>+F15::?
	
	; <Shiftキーの段>
	F16::/
	>+F16::\
	; <最下段>	
	<!::return
	$vk1d::Rctrl ; 無変換キー :: Rctrl
	;Space::SandS
	;$vk1C::BackSpace  	; 変換キー :: BaxckSpace
	$>+vk1C::Delete  	; Space + 変換キー :: Delete
	; カタカナ/ひらがなキー :: 半角全角キー(PowerToys)
	;qRalt::緊急解除キー

;--------------------------------------------------------


;------------------------------------------------------ 無変換(RCtrl) ----------------------------------------------
; 無変換キー+右手側:矢印キー
	$>^j::Left
	$>^<+j::Left
	$>^>+j::+Left
	$>^l::Right
	$>^<+l::Right
	$>^>+l::+Right
	$>^i::Up
	$>^<+i::Up
	$>^>+i::+Up
	$>^k::Down
	$>^<+k::Down
	$>^>+k::+Down

; 無変換(RCtrl)キー+左手側:演算子

	;<数字キーの段>
	; 1 : FancyZones
	>^1::Send("{Blind^}#+F17")
	; 2 : Always On Top
	>^2::Send("{Blind}#^t")
	; 3 : 画面トリミング
	>^3:: Send("{Blind}#+^t")
	>^4::F2
	>^5::F4
	>^6::F5
	>^7::F6
	>^8::F7
	>^9::F8
	; 無変換+9:ショートカット（拡大）
	>^0::Send "{Blind}^{NumpadAdd}"
	; 無変換+0:ショートカット（縮小）
	>^-::Send "{Blind}^{NumpadSub}"
	; 無変換+F23:ショートカット（100%に戻す）
	>^^::Send "{Blind}^0"
	>^|::+CapsLock

	; <Tabキーの段>
	; 無変換+q:ショートカット（上書き保存）
	>^q::Send "{Blind}^s"
	; 無変換+w:ショートカット（元に戻す）
	>^w::Send "{Blind}^z"
	; 無変換+e:ショートカット（やり直し）
	>^e::Send "{Blind}^y"
	>^r::return
	>^t::return
	>^y::return
	>^u::PgUp
	>^o::PgDn
	>^p::return
	>^F17::return
	>^[::return

	; <CapssLockキーの段>
	>^a::Send "{Blind}^a"  ;全選択
	>^s::Send "{Blind}^x"	; 無変換+s:ショートカット（切り取り）
	>^d::Send "{Blind}^c"	; 無変換+d:ショートカット（コピー）
	>^f::Send "{Blind}^v"	; 無変換+f:ショートカット（貼り付け）
	>^g::Send("^f") ; 無変換+g:ショートカット（検索）
	>^h::return
	>^vkBB::return
	>^vkBA::return
	>^]::return

	; <Shiftキーの段>
	>^z::return
	>^x::return
	>^c::return
	>^v::return
	>^b::return
	>^n::return
	>^m::return
	;>^,:: 左の仮想デスクトップへ移動
		>^,:: {
			Send "{Blind}#^{Left}"
		}
	;>^.:: 右の仮想デスクトップへ移動
		>^.:: {
			Send "{Blind}#^{Right}"
		}
	>^/::^/ ;そのまま
	>^\::return

	; <最下段>	

;-------------------------------------------------------------------------------------------------------------------

;------------------------------------------------------ LShift -----------------------------------------------------
; LShitキー+右手側:数字
	<+n::0
	<+m::.
	<+j::1
	<+k::2
	<+l::3
	<+u::4
	<+i::5
	<+o::6
	<+8::7
	<+9::8
	<+0::9
; LShitキー+左手側:演算子
	; <数字キーの段>
	<+1::return
	<+2::return
	<+3::return
	<+4::return
	<+5::return
	<+6::return
	<+7::return
	<+-::return
	<+^::return
	<+|::return
	; <CapssLockキーの段>
	<+q::return
	<+w::=
	<+e::NumpadDiv
	<+r::NumpadMult
	<+t::+1
	<+y::return
	<+p::SendText "×"
	<+F17::SendText "○"
	<+[::return
	; Tabキーの段
	<+a::@
	<+s::+5
	<+d::NumpadSub
	<+f::NumpadAdd
	<+g::return
	<+h::#
	<+vkBB:: vkBA ;LShift + ; :: :
	<+vkBA::return
	<+]::return
	; Shiftキーの段
	<+z::&
	<+x::|
	<+c::`
	<+v::^
	<+b::return
	<+,::+,  ; <
	<+.::+.  ; >
	<+/::return
	<+\::return
;-------------------------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------------------------------------------

