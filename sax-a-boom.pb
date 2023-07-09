; Sax-A-Boom
; Alex, 9.7.2023

; Configuration
Global maxSounds = 8
Global loop = #True

; #################################################### Main ####################################################

; Variables
Global MainWindow
Global lastSound
dataBegin.i
dataEnd.i
sound.i
event.i
Enumeration 100
  #gadgetLoop
  #gadgetPicture
  #picture
EndEnumeration

; Declarations
Declare play(value)
Declare button(value)
Declare playThread(value)
Declare getKeypress(windowID, message, wParam, lParam)

; Initiale JPEG-decoder
UseJPEGImageDecoder()
CatchImage(#picture, ?picture)

; Initialize sound
UseOGGSoundDecoder()
If InitSound() = 0
  MessageRequester("Error", "Unable to initialize Sound!", #PB_MessageRequester_Error)
  End
EndIf

; Load sounds
Restore sounds
dataBegin = 0
For sound = 1 To maxSounds
  If dataBegin = 0
    Read.i dataBegin
  Else
    dataBegin = dataEnd
  EndIf
  Read.i dataEnd
  Debug "Loading Sound " + Str(sound) + ": " + Str(dataBegin) + " To " + Str(dataEnd)
  CatchSound(sound, dataBegin, dataEnd-dataBegin)
Next

; Window
MainWindow = OpenWindow(#PB_Any, 0, 0, 20 * maxSounds + 20, 75+ImageHeight(#picture), "Sax-A-Boom", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
SetWindowCallback(@getKeypress())
; Picture
ImageGadget(#gadgetPicture, 0, 0, ImageWidth(#picture), ImageHeight(#picture), ImageID(#picture))
; Buttons
For sound = 1 To maxSounds
  ButtonGadget(sound, 20 * (sound-1) + 10, 10+ImageHeight(#picture), 20, 20, Str(sound), #PB_Button_Toggle)
Next
ButtonGadget(0, 10, 30+ImageHeight(#picture), 20 * maxSounds, 20, "Stop")
CheckBoxGadget(#gadgetLoop, 10, 50+ImageHeight(#picture), 20 * maxSounds, 20, "Loop")
; Initial loop-state
If loop 
  SetGadgetState(#gadgetLoop, #PB_Checkbox_Checked)
Else
  SetGadgetState(#gadgetLoop, #PB_Checkbox_Unchecked)
EndIf

; Loop until window closed
Repeat
  ;Debug "Wait for Window Event " + FormatDate("%hh:%ii:%ss", Date())
  event = WaitWindowEvent()
  If event=#PB_Event_Gadget
    value = EventGadget()
    Debug "Button " + Str(value)
    CreateThread(@playThread(), value)
    SetFocus_(WindowID(MainWindow)) ; Receive keypress
  EndIf
Until event = #PB_Event_CloseWindow

; Cleanup
StopSound(#PB_All)
For sound = 1 To maxSounds
  FreeSound(sound)
Next
FreeImage(#picture)
End

; ################################################## Routines ##################################################

Procedure play(sound)
  If sound > 0 And sound < maxSounds+1
    Debug "Current sound " + Str(sound) + ", last sound " + Str(lastSound)
    ; Stop Current Sound
    If lastSound <> 0
      Debug "Stopping " + Str(lastSound)
      StopSound(lastSound)
    EndIf
    ; Play new sound
    Debug "Playing Sound " + Str(sound)
    If GetGadgetState(#gadgetLoop) = #PB_Checkbox_Checked
      PlaySound(sound, #PB_Sound_Loop)
    Else
      PlaySound(sound)
    EndIf
    lastSound = sound
  ; Stop all sounds
  ElseIf sound = 0
    Debug "Stopping Sounds"
    StopSound(#PB_All)
  Else
    Debug "Unknown Sound " + Str(sound)
  EndIf
EndProcedure

Procedure button(sound)
  If sound > 0 And sound < maxSounds+1
    ; Toggle old button
    For i = 1 To maxSounds
      SetGadgetState(i, 0)
    Next
    ; Toggle button
    SetGadgetState(sound, 1)
  ; Stop all sounds
  ElseIf sound = 0
    For sound = 1 To maxSounds
      SetGadgetState(sound, 0)
    Next
  Else
    Debug "Unknown Sound " + Str(sound)
  EndIf
EndProcedure

Procedure playThread(value)
  Debug "Thread started"
  play(value)
  button(value)
  Debug "Thread ended"
EndProcedure

Procedure getKeypress(windowID, message, wParam, lParam)
  Result = #PB_ProcessPureBasicEvents
  Debug "getKeypress " + Str(message)
  If message = #WM_KEYDOWN
    Debug wParam
    Debug Str(wParam) + ", " + Str(lParam)
    value = Val(Chr(wParam))
    ; Number pad
    If value = 0 And wParam > 96
      value = wParam-96
    EndIf
    Debug "Pressed " + Chr(wParam) + " = " + Str(value)
    play(value)
    button(value)
  EndIf
  ProcedureReturn Result
EndProcedure

; #################################################### Data ####################################################

; Sounds
DataSection
  sound1:
    IncludeBinary "sounds\1.ogg"
  sound2:
    IncludeBinary "sounds\2.ogg"
  sound3:
    IncludeBinary "sounds\3.ogg"
  sound4:
    IncludeBinary "sounds\4.ogg"
  sound5:
    IncludeBinary "sounds\5.ogg"
  sound6:
    IncludeBinary "sounds\6.ogg"
  sound7:
    IncludeBinary "sounds\7.ogg"
  sound8:
    IncludeBinary "sounds\8.ogg"
  sounds:
    Data.i ?sound1, ?sound2, ?sound3, ?sound4, ?sound5, ?sound6, ?sound7, ?sound8, ?sounds
  picture:
    IncludeBinary "assets\picture.jpg"
EndDataSection

; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 1
; FirstLine = 1
; Folding = -
; EnableThread
; EnableXP
; DPIAware
; UseIcon = assets\icon.ico
; Executable = sax-a-boom.exe
; DisableDebugger