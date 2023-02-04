;  * CRYPTOR
;  *
;  * window_functions.pbi
;  *
;--------------------------------------------------------------------------------
;- macros

Macro _hilite_gadget( gadget , color )
  If evtType = #PB_EventType_Focus And IsGadget(gadget)
    SetGadgetColor(gadget, #PB_Gadget_BackColor, color)
  EndIf
EndMacro

Macro _normalize_gadget( gadget )
  If evtType = #PB_EventType_LostFocus And IsGadget(gadget)
    SetGadgetColor(gadget, #PB_Gadget_BackColor, #PB_Default)
  EndIf
EndMacro

Macro _set_ui_to_no_file()
  
  If EDIT_MODE
    main_window_switch_edit_mode()
  EndIf
  
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_SAVE, #True)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_SAVEAS, #True)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_ENC_SAVEAS, #True)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_PRINT, #True)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_CLOSE, #True)
  
  DisableGadget(#BTN_DATA_NEW, #True)
  DisableGadget(#BTN_DATA_EDIT, #True)
  DisableGadget(#BTN_DATA_DEL, #True)
  
EndMacro

Macro _set_ui_to_file_present()
  
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_SAVE, #False)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_SAVEAS, #False)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_ENC_SAVEAS, #False)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_PRINT, #False)
  DisableMenuItem(#MNU_MAIN, #MNU_FILE_CLOSE, #False)
  
  DisableGadget(#BTN_DATA_NEW, #False)
  DisableGadget(#BTN_DATA_EDIT, #False)
  DisableGadget(#BTN_DATA_DEL, #False)
  
EndMacro

Macro _check_text_gadget(gadget, button)
  If IsGadget(gadget) And EDIT_MODE = #False
    If GetGadgetText(gadget) = ""
      DisableGadget(button, #True)
    Else
      DisableGadget(button, #False)
    EndIf
  EndIf
EndMacro


;- OS depended

Procedure.l get_system_color ( win_ColorIndex.l , mac_ColorName.s )
  
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_MacOS
      
      Protected.i       NSColor
      Protected.CGFloat R, G, B, A
      
      NSColor = CocoaMessage(#Null, #Null, "NSColor colorWithCatalogName:$",@"System","colorName:$",@mac_ColorName)
      
      If NSColor
          
        NSColor = CocoaMessage(#Null, NSColor, "colorUsingColorSpaceName:$",@"NSCalibratedRGBColorSpace")
        
        If NSColor
          
          CocoaMessage(@R, NSColor, "redComponent")
          CocoaMessage(@G, NSColor, "greenComponent")
          CocoaMessage(@B, NSColor, "blueComponent")
          CocoaMessage(@A, NSColor, "alphaComponent")
          
          ProcedureReturn (RGBA(Int(R*255), Int(G*255), Int(B*255), Int(A*255)) & $FFFFFFFF)
          
        EndIf
        
      EndIf
      
      ProcedureReturn -1
      
    CompilerCase #PB_OS_Windows
      
      Protected.l SysColor = GetSysColor_(win_ColorIndex)
      
      If SysColor = 0
        ProcedureReturn -1
      Else
        ProcedureReturn SysColor
      EndIf
      
    CompilerDefault
      
      ProcedureReturn -1
      
  CompilerEndSelect
  
EndProcedure

Procedure.l get_system_hilite_color()
  
  Protected.l result
  
  CompilerIf  #PB_Compiler_OS = #PB_OS_MacOS
    
    result = get_system_color ( #Null , "selectedTextBackgroundColor" )
    
  CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows
    
    result = get_system_color ( #COLOR_HIGHLIGHT , #Null$ )
    
  CompilerElse
    result = -1
  CompilerEndIf
  
  If result = -1
    result = #APP_COLOR_HIGHLIGHT
  EndIf
  
  ProcedureReturn result
  
EndProcedure

;- window functions

;- menu and gadget functions
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 135
; FirstLine = 34
; Folding = f+
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant