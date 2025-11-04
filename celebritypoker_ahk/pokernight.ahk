; Copyright (c) 2025 kristoff kounlavong
; SPDX-License-Identifier: MIT

; Script for auto playing Poker Night at the Inventory (800x600 resolution required)

/*
NOTES:
	straight flush requires suited connectors or gappers up to three.
	connectors are consecutive hole cards, 
	n-gappers have n missing ranks between cards, i.e., 69 = two-gapper

	for quads play all hands, pocket pairs just has higher odds.
*/

#Requires AutoHotkey v2+
#SingleInstance

#include "%A_ScriptDir%\ShinsImageScanClass-main\AHKv2\ShinsImageScanClass.ahk"

; Default coordinate mode is client
SetTitleMatchMode 1 ; Window title must start with [WinTitle]
SetDefaultMouseSpeed 0 ; Speed is 2 when undefined
SetControlDelay 0 ; -1 is no delay, 0 is minimal delay

; CelebrityPoker.exe is the executable name for Poker Night 1
celebPoker := "Poker Night at the Inventory"

; global gameState := 'scan'
global windowActiveFlag := false
global pauseProcessFlag := false

; Values for 800x600 resolution
callBttn := "200 500"
dealNew  := "400 500"


;TODO: make optimized str8 flush script using image/text recognition
variance := 0
scan := ShinsImageScanClass(celebPoker)
scan.AutoUpdate := 0 ; We want to work on single frames, will update manually.

; VERSION: regular autoplay script
; Main timer
SetTimer(MainProcess, 100)

; Constantly right click while game window is active
; 333ms ~= 3 clicks per second
SetTimer(SkipDialogue, 250)

; Hotkey definitions start
Pause:: {
	; Toggle pause state variable
	global pauseProcessFlag := not pauseProcessFlag
	if pauseProcessFlag {
		ToolTip("PNscript paused: Press Pause to continue")
	} else {
		if WinExist(celebPoker) {
			WinActivate(celebPoker)
			ToolTip("PNscript resumed")
		} else {
			pauseProcessFlag := true
			ToolTip("Error: gamewindow not found! [F4] to exit")
		}
	}
	; Clear tooltip after 2 seconds.
	SetTimer(() => ToolTip(), -1750)
}
F4::ExitApp()

return ; === END OF AUTO-EXECUTE SECTION ===


; === Function Defintions ===
MainProcess() {
	static gameState := 'scan'
	
	global windowActiveFlag := WinActive(celebPoker) ? true : false

	if pauseProcessFlag or !windowActiveFlag   
	{ 
		; Reset gameState and exit process for next try
		gameState := 'scan'
		return
	}

	switch gameState {
		case 'scan':
			gameState := 'call'
		case 'call':
			Click(callBttn)
			gameState := 'deal'
		case 'deal':
			Click(dealNew)
			gameState := 'scan'
		case 'fold':
			;
		default:
			MsgBox Format("undefined gameState: ", gameState)
	}
}

SkipDialogue() {
	; Only runs when cursor is over Active window.
	; pokerHWID := WinExist(celebPoker)

	; if not pokerHWID
	; 	global pauseProcessFlag := true

	; MouseGetPos(&x, &y, &HwndUnderMouse)

	; if windowActiveFlag and HwndUnderMouse == pokerHWID
	; 	Click('R')
	;------------------------------------------------------

	; ControlClick to free the mouse for usage
	; THIS WILL FORCE THE GAME TO RUN IN BACKGROUND
	try
		ControlClick(, celebPoker,, "R")
	catch TargetError as te
		; game window does not exist, silently ignore
		return
}
