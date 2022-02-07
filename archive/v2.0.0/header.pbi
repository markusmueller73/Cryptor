;  * CRYPTOR
;  *
;  * header.pbi
;  *

;- load needed modules
UsePNGImageDecoder()
UseMD5Fingerprint()

;- set the randomizer
RandomSeed( ElapsedMilliseconds() )

;- OS specific constants
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

;- application constants
#APP_NAME  = "Cryptor"
#APP_MAJOR = 2
#APP_MINOR = 0
#APP_MICRO = 2
#APP_VERSION = "ver. " + #APP_MAJOR + "." + #APP_MINOR + "." + #APP_MICRO + "." + #PB_Editor_BuildCount
#APP_EXT   = ".pwdx"
#APP_EXT_L = $50574458
#APP_BYTE_SIZE = 16
#APP_ENCODING  = #PB_UTF8
#APP_REQUESTER_PATTERN_S = #APP_NAME + " files (*" + #APP_EXT + ")|*" + #APP_EXT
#APP_REQUESTER_PATTERN_L = #APP_REQUESTER_PATTERN_S + "|eXtended Markup Language files (*.xml)|*.xml;*.XML|All files (*.*)|*.*"
#APP_WINDOW_WIDTH  = 800
#APP_WINDOW_HEIGHT = 500
#APP_BUTTON_WIDTH  = 120
#APP_BUTTON_HEIGHT = 30
#APP_COLOR_HIGHLIGHT = $508050
#APP_COLOR_WARNING   = $8080C0
#APP_TIMER_ID = 5
#APP_EVENT_MACOS_FINDER_FILELIST = #PB_Event_FirstCustomValue

;- application logging constants
Enumeration 1
  #APP_LOGTYPE_INFO
  #APP_LOGTYPE_WARNING
  #APP_LOGTYPE_ERROR
EndEnumeration

;- application data constants
Enumeration 0
  #APP_DATA_NONE
  #APP_DATA_XML
  #APP_DATA_ENCODED
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

#APP_DATASET_NEW = -1

;- application structures
Structure CONFIGURATION
  StrFormat.i
  Vector.s
  DefName.s
  DefEmail.s
EndStructure

Structure DATASET
  Id.l
  Company.s
  Address.s
  Username.s
  Email.s
  Password.s
  Password2.s
  Comment.s
EndStructure

;- application variables
Global.b ALT_PARAMS_SET
Global.l PARAMS
Global NewList PARAMETER_LIST.s()

;- application logging functions
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
  Static   log_dir$
  
  Protected.i h_log
  Protected.s text
  
  If start_logging
    write_log = #True
    set_once = #True
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows : log_dir$ = GetCurrentDirectory()
      CompilerCase #PB_OS_MacOS   : log_dir$ = GetHomeDirectory() + ".cryptor/"
      CompilerCase #PB_OS_Linux   : log_dir$ = GetHomeDirectory() + ".cryptor/"
    CompilerEndSelect
    If FileSize(log_dir$) = -1 Or FileSize(log_dir$) <> -2
      If CreateDirectory(log_dir$) = 0
        MessageRequester(#APP_NAME + " - ERROR", "Can't create directory: " + #NL + log_dir$ + #NL + "Insufficient rights? Exiting program.", #PB_MessageRequester_Error)
        End
      EndIf
    EndIf
    start_time = ElapsedMilliseconds()
    h_log = CreateFile(#PB_Any, log_dir$ + #APP_NAME + ".log")
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
    h_log = OpenFile(#PB_Any, log_dir$ + #APP_NAME + ".log")
    While Eof(h_log) = 0
      ReadString(h_log)
    Wend
    WriteStringN(h_log, text + message)
    CloseFile(h_log)
  EndIf
  
EndProcedure:logger("start logging", #APP_LOGTYPE_INFO, #True)

;- global needed logging macros
Macro void : : EndMacro
Macro info( msg ) : logger("<" + #PB_Compiler_Procedure + "> : " + msg, #APP_LOGTYPE_INFO) : EndMacro
Macro warn( msg ) : logger("<" + #PB_Compiler_Procedure + "> : " + msg, #APP_LOGTYPE_WARNING) : EndMacro
Macro StrH( long ) : RSet(Hex(long, #PB_Long), 8, "0") : EndMacro

;- add includes
XIncludeFile "macos_functions.pbi"
XIncludeFile "mem_functions.pbi"
XIncludeFile "pwd_functions.pbi"
XIncludeFile "xml_functions.pbi"
XIncludeFile "print_functions.pbi"
XIncludeFile "main_window.pbi"
XIncludeFile "about_window.pbi"

;- function declarations
Declare.l main( argc.l=0 )

;- application data section for icons
DataSection
  ICON_APP:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "cryptor_icon.png"
  ICON_HIDE:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_hide.png"
  ICON_SHOW:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_show.png"
  ICON_COPY:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_copy.png"
  ICON_WEB:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_web.png"
  ICON_MAKEPWD:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_makepwd.png"
  ICON_NEW:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_new.png"
  ICON_OPEN:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_open.png"
  ICON_SAVE:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_save.png"
  ICON_SAVEAS:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_saveas_xml.png"
  ICON_SAVEAS_ENC:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_saveas_lock.png"
  ICON_CLOSE:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_close.png"
  ICON_PRINT:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_print.png"
  ICON_QUIT:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_quit.png"
  ICON_ABOUT:
  IncludeBinary ".." + #PS$ + ".." + #PS$ + "res" + #PS$ + "icon_about.png"
EndDataSection
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 72
; FirstLine = 45
; Folding = 9-
; EnableXP
; UseMainFile = main.pb
; CompileSourceDirectory
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant