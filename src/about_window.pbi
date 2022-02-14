;  * CRYPTOR
;  *
;  * about_window.pbi
;  *

;-------------------------------------------------
;- about window structure
Structure ABOUT_WINDOW
  id.i
  img.i
  txt_name.i
  txt_ver.i
  txt_copy.i
  txt_email.i
  pnl.i
  pnl_gpl.i
  edt_gpl.i
  pnl_other.i
  edt_other.i
  btn_close.i
  icon_image.i
  font_fixed.i
EndStructure

;- functions
Procedure.b about_window_open( parent_window.i , *w.ABOUT_WINDOW )
  
  Protected.l flags = #PB_Window_SystemMenu|#PB_Window_Tool | #PB_Window_WindowCentered | #PB_Window_Invisible
  Protected   ver$ = "Version " + #APP_MAJOR + "." + #APP_MINOR + "." + #APP_MICRO
  Protected   comp$
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Linux   : comp$ = "Linux version" + " "
    CompilerCase #PB_OS_MacOS   : comp$ = "Mac version" + " "
    CompilerCase #PB_OS_Windows : comp$ = "Windows version" + " "
  CompilerEndSelect
  
  CompilerSelect #PB_Compiler_Processor
    CompilerCase #PB_Processor_x64  : comp$ + "(64-bit)" + ", "
    CompilerCase #PB_Processor_x86  : comp$ + "(32-bit)" + ", "
  CompilerEndSelect
    
  comp$ + "compiled " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", #PB_Compiler_Date)
  
  If IsWindow(*w\id)
    warn("About window is already open.")
    CloseWindow(*w\id)
    ResetStructure(*w, ABOUT_WINDOW)
  EndIf
  
  If IsWindow(parent_window)
    
    *w\id = OpenWindow(#PB_Any, 0, 0, 600, 400, LANGUAGE("MENU_HELP_ABOUT") + Space(1) + #APP_NAME, flags, WindowID(parent_window))
    If IsWindow(*w\id)
      
      info("Opened about window with handle [0x"+Hex(*w\id, #PB_Long)+"].")
      *w\font_fixed = LoadFont(#PB_Any, #APP_FIXED_FONT, 9)
      
      *w\icon_image = CatchImage(#PB_Any, ?ICON_APP) : ResizeImage(*w\icon_image, 80, 80, #PB_Image_Smooth)
      
      *w\img = ImageGadget(#PB_Any, 10, 10, 80, 80, ImageID(*w\icon_image))
      
      *w\txt_name = TextGadget(#PB_Any, 100, 10, 480, 20, #APP_NAME + " " + ver$)
      *w\txt_copy = TextGadget(#PB_Any, 100, 40, 180, 20, Chr(169) + "2020-2022 by Markus Mueller")
      *w\txt_email = HyperLinkGadget(#PB_Any, 280, 40, 300, 20, "> markus dot mueller dot 73 at hotmail dot de <", get_system_hilite_color())
      *w\txt_ver = TextGadget(#PB_Any, 100, 70, 480, 20, comp$)
      
      *w\pnl = PanelGadget(#PB_Any, 10, 100, 580, 260)
      
      *w\pnl_gpl = 0
      AddGadgetItem(*w\pnl, *w\pnl_gpl, #APP_NAME + Space(1) + LANGUAGE("DIALOG_ABOUT_LICENSE"))
      *w\edt_gpl = EditorGadget(#PB_Any, 10, 8, 560, 220, #PB_Editor_ReadOnly)
      If IsFont(*w\font_fixed) : SetGadgetFont(*w\edt_gpl, FontID(*w\font_fixed)) : EndIf
      SetGadgetText(*w\edt_gpl, PeekS(?LICENSE_GPL, ?LICENSE_GPL_END-?LICENSE_GPL, #PB_UTF8))
      info("Catched GPL license text with size of "+Str(?LICENSE_GPL_END-?LICENSE_GPL)+" bytes.")
      
      *w\pnl_other = 1
      AddGadgetItem(*w\pnl, *w\pnl_other, LANGUAGE("DIALOG_ABOUT_COMPONENTS") + Space(1) + LANGUAGE("DIALOG_ABOUT_LICENSES"))
      *w\edt_other = EditorGadget(#PB_Any, 10, 8, 560, 220, #PB_Editor_ReadOnly)
      If IsFont(*w\font_fixed) : SetGadgetFont(*w\edt_other, FontID(*w\font_fixed)) : EndIf
      SetGadgetText(*w\edt_other, PeekS(?LICENSE_OTHER, ?LICENSE_OTHER_END-?LICENSE_OTHER, #PB_UTF8))
      info("Catched other license text with size of "+Str(?LICENSE_OTHER_END-?LICENSE_OTHER)+" bytes.")
      
      CloseGadgetList()
      
      *w\btn_close = ButtonGadget(#PB_Any, 470, 365, 120, 30, LANGUAGE("MENU_FILE_CLOSE"))
      
      HideWindow(*w\id, #False)
      
    Else
      warn("Can't create a tool window.")
      ProcedureReturn #False
    EndIf
    
  Else
    warn("The parent window [0x" + Hex(parent_window, #PB_Long) + "] didn't exist.")
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

DataSection
  LICENSE_GPL:
  IncludeBinary ".." + #PS$ + "LICENSE"
  LICENSE_GPL_END:
  LICENSE_OTHER:
  IncludeBinary ".." + #PS$ + "LICENSES_COMP"
  LICENSE_OTHER_END:
EndDataSection
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 85
; FirstLine = 61
; Folding = -
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant