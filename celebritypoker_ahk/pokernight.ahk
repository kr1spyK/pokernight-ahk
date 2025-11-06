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
SetTitleMatchMode 3 ; Window title must match exactly
SetDefaultMouseSpeed 0 ; Speed is 2 when undefined
SetControlDelay 0 ; -1 is no delay, 0 is minimal delay

; CelebrityPoker.exe is the executable name for Poker Night 1
celebPoker := "Poker Night at the Inventory"

; global gameState := 'scan'
global windowActiveFlag := false
global pauseProcessFlag := false

global white := 0xFFFFFF
global mocha := 0x6B2410
global dGold := 0xA3743D

; Values for 800x600 resolution
callX := 200, callY := 500
dealX := 	  dealY := 422
dnewX :=	  dnewY := 500
starX := 50,  starY := 490
foldX := 100, foldY := 500
beginX := 10, beginY := 102
endX := 10, endY := 100

;TODO: make optimized str8 flush script using image/text recognition
variance := 0
scan := ShinsImageScanClass(celebPoker)
scan.AutoUpdate := 0 ; We want to work on single frames, will update manually.
scan.Update() ; Initalize frame buffer just in case.

; VERSION: regular autoplay script
; Main timer
SetTimer(MainProcess, 100)
; Update scan buffer 0.5 second
SetTimer(FrameBuffer, 500)
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
	static gameState := 'idle'
	static startPixel := 0xFFFFFF
	global windowActiveFlag := WinActive(celebPoker) ? true : false

	if !WinExist(celebPoker) {
		Sleep(10000)
		return
	}

	if pauseProcessFlag or !windowActiveFlag   
	{ 
		; Reset gameState and exit process for next try
		; gameState := 'scan'
		return
	}
	ToolTip(gameState)
	switch gameState {
		; gonna try updating buffer at 3 second intervals
		; sample pixel color at x500 y500:
		
		; dark gold (A3 74 3D) = action off
		; mocha (6B 24 10) = action on
		; white (FF FF FF) = game over, deal new@ 500 500
		; off white (F7 F7 F7) = deal new hand
		; 
		; try startPixel @50 490
		; 773 93 top right pixel check
		; white(FFFFFF) = game started
		case 'idle':
			if scan.PixelPosition(white, beginX, beginY) {
				gameState := 'scan'
			}
		case 'scan':
			if not scan.PixelPosition(white, beginX, beginY) {
				gameState := 'idle'
			}
			if scan.PixelPosition(mocha, endX, endY) {
				gameState := 'roundEnd'
				return
			}
			if scan.PixelPosition(white, dealX, dealY) {
				gameState := 'roundEnd'
				return
			}
			if scan.PixelPosition(dGold, starX, starY, 10) {
				gameState := 'cardsIdle'
				return
			}
			if scan.PixelPosition(white, foldX, foldY) {
				gameState := 'cardsIdle'
				return
			}
			; startPixel := scan.GetPixel(starX, starY)
			; ToolTip Format("{:X}", startPixel)
			
			; if startPixel == mocha or startPixel == dGold {
			; 	gameState := 'start'
			; 	return
			; }
		case 'cardsIdle':
			if not scan.PixelPosition(white, beginX, beginY) {
				gameState := 'idle'
			}
			if scan.PixelPosition(mocha, starX, starY, 10) {
				gameState := 'action'
			} else if scan.PixelPosition(white, dealX, dealY) {
				gameState := 'roundEnd'
			}
		case 'action':
			; TODO: readhand
			; if goodHand {
			;     Click(callX, callY)
			; } else {
			;     Click(foldX, foldY)
			;	  gameState := 'folded'
			; }
			Click(callX, callY)
			gameState := 'scan'

		case 'folded':
			; Click(skip)
			; gameState := 'roundEnd'

		case 'roundEnd':
			Click(dnewX, dnewY)
			gameState := 'scan'
		default:
			MsgBox Format("undefined gameState: ", gameState)
	}
	
}

FrameBuffer() {
	scan.Update()
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
