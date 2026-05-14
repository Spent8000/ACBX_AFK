#AutoIt3Wrapper_Icon=icon.ico
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <Constants.au3>

; =========================
; GLOBAL STATE
; =========================
Global $width = @DesktopWidth
Global $height = @DesktopHeight
Global $paused = False
Global $running = True
Global $potionFloor = 0
Global $email = ""
Global $last = 0

; =========================
; HOTKEYS
; =========================
HotKeySet("{F8}", "StopScript")
HotKeySet("{F9}", "TogglePause")

Func StopScript()
    $running = False
	Send("{F11}")
    Exit
EndFunc

Func TogglePause()
    $paused = Not $paused
EndFunc

; =========================
; SAFE PIXEL CLICK FUNCTION (NO DLLS)
; =========================
Func FindColorInArea($x1, $y1, $x2, $y2, $color, $tolerance = 10)

    Local $pos = PixelSearch($x1, $y1, $x2, $y2, $color, $tolerance)

    If Not @error Then
        MouseClick("left", $pos[0], $pos[1])
        Return True
    EndIf

    Return False

EndFunc

Func ClickIfCheck($color)
	Local $result = PixelSearch(@DesktopWidth * 0.711, @DesktopHeight * 0.925, @DesktopWidth * 0.723, @DesktopHeight * 0.947, $color)

	If Not @error Then
		MouseClick("left", @DesktopWidth * 0.715, @DesktopHeight * 0.93)
		Sleep(2000)
	EndIf
EndFunc

; =========================
; STARTUP GUI
; =========================
GUICreate("ACB", 800, 650)
GUISetBkColor(0x444444)

$title = GUICtrlCreateLabel("ACBX AFK", 267, 0, 400, 50)
GUICtrlSetColor($title, 0xdddddd)
GUICtrlSetFont($title, 40, 700, 0, "Arial")

$stop = GUICtrlCreateLabel("F8 = Force Close", 70, 65, 400, 40)
GUICtrlSetColor($stop, 0xdddddd)
GUICtrlSetFont($stop, 25, 700, 0, "Arial")

$pause = GUICtrlCreateLabel("F9 = Pause/Resume", 47, 105, 400, 40)
GUICtrlSetColor($pause, 0xdddddd)
GUICtrlSetFont($pause, 25, 700, 0, "Arial")

$info = GUICtrlCreateLabel("BETA - Enter your email if you want updates whenever your infinite fails:", 447, 65, 300, 150)
GUICtrlSetColor($info, 0xdddddd)
GUICtrlSetFont($info, 25, 700, 0, "Arial")

$info2 = GUICtrlCreateLabel("Place your current floor text against a uniform colored wall and do not have Roblox in fullscreen with F11 on when starting program", 50, 170, 300, 200)
GUICtrlSetColor($info2, 0xdddddd)
GUICtrlSetFont($info2, 20, 700, 0, "Arial")

$floor = GUICtrlCreateLabel("Last Scanned Floor: Unavailable", 427, 270, 300, 60, $SS_CENTER)
GUICtrlSetColor($floor, 0xdddddd)
GUICtrlSetFont($floor, 20, 700, 0, "Arial")

Local $input = GUICtrlCreateInput("", 450, 230, 250, 25)

Local $PotionFloor = GUICtrlCreateInput("", 275, 500, 250, 25)

$startBtn = GUICtrlCreateButton("START", 275, 550, 250, 40)
GUICtrlSetFont($startBtn, 20, 700, 0, "Arial")
GUICtrlSetBkColor($startBtn, 0x222222)
GUICtrlSetColor($startBtn, 0xdddddd)

$potionText = GUICtrlCreateLabel("Select which potions to use and the floor to start using them:", 150, 375, 500, 70, $SS_CENTER)
GUICtrlSetColor($potionText, 0xdddddd)
GUICtrlSetFont($potionText, 20, 700, 0, "Arial")

Global $corrupt = 0
Global $luck = 0
Global $star = 0
Global $boss = 0

Global $useCorrupt = GUICtrlCreateCheckbox("Corrupt Potion", 210, 450, 100, 30)
Global $useLuck = GUICtrlCreateCheckbox("Luck Potion", 310, 450, 100, 30)
Global $useStar = GUICtrlCreateCheckbox("Star Potion", 410, 450, 100, 30)
Global $useBoss = GUICtrlCreateCheckbox("Boss Potion", 510, 450, 100, 30)

GUICtrlSetColor($useCorrupt, 0xffffff)

GUISetState(@SW_SHOW)

GUICtrlSetState($useCorrupt, $GUI_UNCHECKED)
GUICtrlSetState($useLuck, $GUI_UNCHECKED)
GUICtrlSetState($useStar, $GUI_UNCHECKED)
GUICtrlSetState($useBoss, $GUI_UNCHECKED)

Func RunFloorScan($whichEmail)
	Local $cmd = @ScriptDir & '\dist\Email.exe "' & $whichEmail & '" "' & $last & '"'
	Local $pid = Run($cmd, "", @SW_HIDE, $STDOUT_CHILD)
	Local $output = ""

	While 1
		$output &= StdoutRead($pid)
		If @error Then ExitLoop
	WEnd

	$last = Int(StringStripWS($output, 3))
	GUICtrlSetData($floor, "Last Scanned Floor: " & $last)
	If $last>0 Then Return 1
	If $last=0 Then Return 0
EndFunc


While 1
    $msg = GUIGetMsg()

    If $msg = $GUI_EVENT_CLOSE Then Exit

    If $msg = $startBtn Then
		$email = GUICtrlRead($input)
		$potionFloor = Int(GUICtrlRead($PotionFloor))
		If GUICtrlRead($useCorrupt) = 1 Then GUICtrlSetState($useCorrupt, $GUI_CHECKED)
		If GUICtrlRead($useLuck) = 1 Then GUICtrlSetState($useLuck, $GUI_CHECKED)
		If GUICtrlRead($useStar) = 1 Then GUICtrlSetState($useStar, $GUI_CHECKED)
		If GUICtrlRead($useBoss) = 1 Then GUICtrlSetState($useBoss, $GUI_CHECKED)
        ExitLoop
    EndIf

    Sleep(10)
WEnd

If WinExists("Roblox") Then
    WinActivate("Roblox")
    WinWaitActive("Roblox", "", 2)

    ; Step 1: resize to windowed mode
    WinMove("Roblox", "", 100, 100, 800, 600)

    Sleep(300)

    ; Step 2: attempt fullscreen toggle
    Send("{F11}")
EndIf

; =========================
; MAIN LOOP
; =========================
While $running
	If BitAND(GUICtrlRead($useCorrupt), $GUI_CHECKED) Then $corrupt = 1
	If BitAND(GUICtrlRead($useLuck), $GUI_CHECKED) Then $luck = 1
	If BitAND(GUICtrlRead($useStar), $GUI_CHECKED) Then $star = 1
	If BitAND(GUICtrlRead($useBoss), $GUI_CHECKED) Then $boss = 1

	Local $msg = GUIGetMsg()

    ; Pause handling
    While $paused
        Sleep(100)
		$msg = GUIGetMsg()
		If $msg = $GUI_EVENT_CLOSE Then Exit
        If Not $running Then ExitLoop
    WEnd

	If WinExists("Roblox") Then
		WinActivate("Roblox")
		WinWaitActive("Roblox", "", 5)
	EndIf

	ClickIfCheck(0x00FF00)
	ClickIfCheck(0xFF0000)

	MouseClick("left", $width * 0.67, $height * 0.295)

	RunFloorScan($email)

	If ($last > $potionFloor) Then
		MouseClick("left", $width * 0.092, $height * 0.39)
		Sleep(1000)
		while RunFloorScan("")=1

			Local $cmd = @ScriptDir & '\dist\Potions\Potions.exe "' & $corrupt & '" "' & $luck & '" "' & $star & '" "' & $boss & '"'
			Local $pid2 = Run($cmd, "", @SW_HIDE, $STDOUT_CHILD)

			; wait until Python finishes
			ProcessWaitClose($pid2)

			; now read all output
			Local $output = StdoutRead($pid2)

			; update lines
			Local $lines = StringSplit(StringStripCR($output), @LF)

			ConsoleWrite(Ceiling(UBound($lines)/2)*2)

			For $i = 1 To (Ceiling(UBound($lines)/2)*2)-2 Step 2
				MouseClick("left", $width * Number($lines[$i]), $height * Number($lines[$i+1]))
				Sleep(100)
				MouseClick("left", $width * 485 / 2560, $height * 815 / 1440)
				Sleep(100)
			Next
			Sleep(225000)
		WEnd
		MouseClick("left", $width * 1900 / 2560, $height * 430 / 1440)
		Sleep(100)
	EndIf
WEnd