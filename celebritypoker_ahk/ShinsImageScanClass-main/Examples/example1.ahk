#Requires AutoHotkey v2+
#SingleInstance

SetTitleMatchMode 1

#include "..\AHKv2\ShinsImageScanClass.ahk"  ;remove ..\ if the class file is in the same directory

;include the library assumed to be in the parent directory
;remove ../ if in same directory, or specify path

scan := ShinsImageScanClass() ;no title supplied so using desktop instead

;look for a pure red pixel anywhere on the desktop
x := 0, y := 0
if (scan.Pixel(0xFF0000, 20, &x, &y)) {
	MsgBox Format("Found a red pixel at {1}, {2}", x, y)
} else {
	MsgBox("Could not find a red pixel on the desktop!")
}

;count all the white pixels on the desktop screen
MsgBox Format("There are {1} white pixels on screen!", scan.PixelCount(0xFFFFFF))

exitapp
