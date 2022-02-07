;  * CRYPTOR
;  *
;  * header.pbi
;  *

UsePNGImageDecoder()
UseMD5Fingerprint()

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux
    #NL = #LF$
  CompilerCase #PB_OS_MacOS
    #NL = #CR$
  CompilerCase #PB_OS_Windows
    #NL = #CRLF$
  CompilerDefault
    End
CompilerEndSelect

#APP_NAME  = "Cryptor"
#APP_MAJOR = 1
#APP_MINOR = 1
#APP_EXT   = ".pwdf"
#APP_EXT_L = $50574446
#APP_BYTE_SIZE = 16
#APP_REQUESTER_PATTERN_S = #APP_NAME + " file (*" + #APP_EXT + ")|*" + #APP_EXT
#APP_REQUESTER_PATTERN_L = #APP_REQUESTER_PATTERN_S + "|Text files (*.txt)|*.txt|Rich text format (*.rtf)|*.rtf|All files (*.*)|*.*"
#APP_WINDOW_WIDTH  = 800
#APP_WINDOW_HEIGHT = 500
#APP_BUTTON_WIDTH  = 120
#APP_BUTTON_HEIGHT = 30

Enumeration 1
  #APP_LOGTYPE_INFO
  #APP_LOGTYPE_WARNING
  #APP_LOGTYPE_ERROR
EndEnumeration

#APP_DATATYPE_CFG     = "Configuration"
#APP_DATATYPE_DB      = "Database"
#APP_DATATYPE_DATA    = "Dataset"
#APP_DATATYPE_ID      = "ID"
#APP_DATATYPE_CORP    = "Company"
#APP_DATATYPE_ADDR    = "Address"
#APP_DATATYPE_NAME    = "Name"
#APP_DATATYPE_MAIL    = "Email"
#APP_DATATYPE_USER    = "Username"
#APP_DATATYPE_PWD1    = "Password"
#APP_DATATYPE_PWD2    = "Password2"
#APP_DATATYPE_MISC    = "Comment"
;#APP_DATATYPE_NUMKEY  = "NumericKey"
;#APP_DATATYPE_KEY     = "MiscKey"
;#APP_DATATYPE_DESC    = "Description"
;#APP_DATATYPE_MISC    = "Miscellaneous"

Structure CONFIG
  defaultUsername.s
  defaultEmail.s
EndStructure

Structure DATASET
  id.l
  company.s
  address.s
  username.s
  email.s
  password.s
  password2.s
  comment.s
EndStructure

Structure XML_NODES
  id.i
  root.i
  cfg.i
  dat.i
EndStructure

Procedure.s format_timer( time_in_ms.l )
  Protected.l h, m, s, ms
  Protected.s result
  If time_in_ms > 3600000
    h = Int(time_in_ms / 3600000)
    time_in_ms - (h * 3600000)
  EndIf
  If time_in_ms > 60000
    m = Int(time_in_ms / 60000)
    time_in_ms - (m * 60000)
  EndIf
  If time_in_ms > 1000
    s = Int(time_in_ms / 1000)
    time_in_ms - (s * 1000)
  EndIf
  ms = time_in_ms
  result = RSet(Str(h),2,"0") +":" + RSet(Str(m),2,"0") + ":" + RSet(Str(s),2,"0") + "." +RSet(Str(ms),3,"0")
  ProcedureReturn result
EndProcedure

Procedure logger( message.s , type.b , start_logging.b = #False)
  
  Static.b write_log = #False, set_once = #False
  Static.l start_time
  
  Protected.i h_log
  Protected.s text
  
  If start_logging
    write_log = #True
    set_once = #True
    start_time = ElapsedMilliseconds()
    h_log = CreateFile(#PB_Any, #APP_NAME + ".log")
    CloseFile(h_log)
  EndIf
  
  text = format_timer(ElapsedMilliseconds()-start_time) + Space(2)
  
  Select type
    Case #APP_LOGTYPE_INFO    : text + "[INFO]" + Space(1)
    Case #APP_LOGTYPE_WARNING : text + "[WARNING]" + Space(1)
    Case #APP_LOGTYPE_ERROR   : text + "[ERROR]" + Space(1)
  EndSelect
  
  CompilerIf #PB_Compiler_Debugger
    Debug text + message
  CompilerEndIf
  
  If write_log
    h_log = OpenFile(#PB_Any, #APP_NAME + ".log")
    While Eof(h_log)
      ReadString(h_log)
    Wend
    WriteStringN(h_log, text + message)
    CloseFile(h_log)
  EndIf
  
EndProcedure:logger("start logging", #APP_LOGTYPE_INFO)

Macro void : : EndMacro
Macro info( msg ) : logger("<" + #PB_Compiler_Procedure + "> : " + msg, #APP_LOGTYPE_INFO) : EndMacro
Macro warn( msg ) : logger("<" + #PB_Compiler_Procedure + "> : " + msg, #APP_LOGTYPE_WARNING) : EndMacro

XIncludeFile "mem_functions.pbi"
XIncludeFile "xml_functions.pbi"
XIncludeFile "main_window.pbi"

Declare.l main( argc.l=0 )

DataSection
  ICON_LOCK:
  IncludeBinary "icons" + #PS$ + "lock_icon.png"
EndDataSection
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 55
; FirstLine = 43
; Folding = 9-
; EnableXP
; UseMainFile = main.pb
; CompileSourceDirectory
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant