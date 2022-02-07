;  * CRYPTOR
;  *
;  * about_window.pbi
;  *

Procedure about_window_open( parent_window.i )
  
  Protected.s text
  
  If IsWindow(parent_window)
    
    text = #APP_NAME + " v " + #APP_MAJOR + "." + #APP_MINOR + "." + #PB_Editor_BuildCount + #NL + #NL
    
    text + Chr(169) + " 2020 by markus.mueller.73 at hotmail dot de" + #NL + #NL
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux   : text + "Linux version" + " "
      CompilerCase #PB_OS_MacOS   : text + "Mac version" + " "
      CompilerCase #PB_OS_Windows : text + "Windows version" + " "
    CompilerEndSelect
    
    CompilerSelect #PB_Compiler_Processor
      CompilerCase #PB_Processor_x64  : text + "(64-bit)" + #NL
      CompilerCase #PB_Processor_x86  : text + "(32-bit)" + #NL
    CompilerEndSelect
    
    text + "compiled " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", #PB_Compiler_Date) + #NL
    
    MessageRequester("About...", text, #PB_MessageRequester_Ok)
    
  EndIf
  
EndProcedure
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 13
; FirstLine = 1
; Folding = -
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant