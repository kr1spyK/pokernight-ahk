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

global white := 0xFFFFFF ; pure white
global mocha := 0x6B2410 ; brownish-red like dutch cocoa powder
global dGold := 0xA3743D ; dark beige/gold

; Values for 800x600 resolution
callX := 200, callY := 500 ; call button hitbox
dealX := 	  dealY := 422 ; white pixel in Deal New Hand element @ end of round
dnewX :=	  dnewY := 500 ; new game button hitbox @ end of match
starX := 50,  starY := 490 ; mocha/dgold pixel to determine if action available
foldX := 100, foldY := 500 ; white pixel in Fold button, edge case for new scan @ action avail.
beginX := 10, beginY := 102 ; white pixel in top corner UI decoration, determines game active
endX := 10, endY := 100 ; mocha pixel in top UI bar, appears at end of match results

leftX := 69, leftY := 115
rightX := 747, rightY := 115
incX := 530, incY := 500
decX := 420, decY := 500

dnewBttn := dnewX . ' ' . dnewY
foldBttn := foldX . ' ' . foldY
callBttn := callX . ' ' . callY
raiseBttn := "300 500"
incBttn := incX . ' ' . incY
decBttn := decX . ' ' . decY
lBttn := leftX . ' ' . leftY
rBttn := rightX . ' ' . rightY

;TODO: make optimized str8 flush script using image/text recognition
variance := 0
try {
	scan := ShinsImageScanClass(celebPoker)
	scan.AutoUpdate := 0 ; We want to work on single frames, will update manually.
	scan.Update() ; Initalize frame buffer just in case.
} catch Error as OutputVar {
	MsgBox(OutputVar)
}

; Main timer
SetTimer(MainProcess, 100)
; Update scan buffer 0.5 second
SetTimer(FrameBuffer, 500)
; Constantly right click while game window is active
; 333ms ~= 3 clicks per second
SetTimer(SkipDialogue, 250)

; Hotkey definitions start
Pause::PauseTrigger()
F4::ExitApp()
#HotIf WinActive(celebPoker)
RCtrl::PokerKeyboard('fold')
Left:: PokerKeyboard('call')
Right::PokerKeyboard('raise')
Up::   PokerKeyboard('increase')
Down:: PokerKeyboard('decrease')

w::PokerKeyboard('increase')
s::PokerKeyboard('decrease')
a::PokerKeyboard('call')
d::PokerKeyboard('raise')
q::PokerKeyboard('fold')
#HotIf 

return ; === END OF AUTO-EXECUTE SECTION ===

; === Function Defintions ===
PokerKeyboard(keyName) {
	gameormenu := scan.PixelPosition(white, beginX, beginY) ? 1 :
				  scan.PixelPosition(white, rightX, rightY) ? 2 :
				  0
	if gameormenu == 0
		return
	switch keyName {
		case 'increase':
			if gameormenu == 1
				Click(incBttn)
			else
				Click(rBttn)
		case 'decrease':
			if gameormenu == 1
				Click(decBttn)
			else
				Click(lBttn)
		case 'fold': 
			if gameormenu == 1
				Click(foldBttn)
		case 'call': 
			if gameormenu == 1
				Click(callBttn)
			else
				Click(lBttn)
		case 'raise':
			if gameormenu == 1
				Click(raiseBttn)
			else
				Click(rBttn) 
	}
}

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
		; dark gold (A3 74 3D)
		; mocha (6B 24 10) 
		; white (FF FF FF) 

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
			if scan.PixelPosition(dGold, starX, starY) {
				gameState := 'cardsIdle'
				return
			}
			if scan.PixelPosition(white, foldX, foldY) {
				gameState := 'cardsIdle'
				return
			}

		case 'cardsIdle':
			if not scan.PixelPosition(white, beginX, beginY) {
				gameState := 'idle'
			}
			if scan.PixelPosition(mocha, starX, starY) {
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
			Click(callBttn)
			gameState := 'scan'

		case 'folded':
			; Click(skip)
			; gameState := 'roundEnd'

		case 'roundEnd':
			Click(dnewBttn)
			gameState := 'scan'
		default:
			MsgBox Format("undefined gameState: ", gameState)
	}
}

SkipDialogue() {
	; ControlClick to free the mouse for usage
	; THIS WILL FORCE THE GAME TO RUN IN BACKGROUND
	try
		ControlClick(, celebPoker,, "R")
	catch TargetError as te
		; game window does not exist, silently ignore
		return
}

PauseTrigger() {
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

FrameBuffer() {
	try
		scan.Update()
	catch Error  
		return
}
