;  * CRYPTOR
;  *
;  * header.pbi
;  *

;- load needed modules
UsePNGImageDecoder()
UseSHA2Fingerprint()
UseMD5Fingerprint()

;- set the randomizer
RandomSeed( ElapsedMilliseconds() )

;- OS specific constants
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux
    #NL = #LF$
    #APP_OS = "Linux"
    #APP_CONF_EXT = ".conf"
    #APP_FIXED_FONT = "Terminus"
    Global APP_LOG_DIR$ = GetHomeDirectory() + ".cryptor\"
    Global APP_CONF_DIR$ = APP_LOG_DIR$
  CompilerCase #PB_OS_MacOS
    #NL = #CR$
    #APP_OS = "MacOS"
    #APP_CONF_EXT = ".conf"
    #APP_FIXED_FONT = "Andale Mono"
    Global APP_LOG_DIR$ = GetHomeDirectory() + ".cryptor/"
    Global APP_CONF_DIR$ = APP_LOG_DIR$
  CompilerCase #PB_OS_Windows
    #NL = #CRLF$
    #APP_OS = "Windows"
    #APP_CONF_EXT = ".ini"
    #APP_FIXED_FONT = "Consolas"
    Global APP_LOG_DIR$ = GetHomeDirectory() + ".cryptor/"
    Global APP_CONF_DIR$ = APP_LOG_DIR$
  CompilerDefault
    End
CompilerEndSelect

;- application constants
#APP_NAME  = "Cryptor"
#APP_MAJOR = 2
#APP_MINOR = 3
#APP_MICRO = 0
#APP_VER   = 230
#APP_VERSION = "ver. " + #APP_MAJOR + "." + #APP_MINOR + "." + #APP_MICRO + "." + #PB_Editor_BuildCount
#APP_EXT   = ".pwdx"
#APP_EXT_L = $50574458
#APP_ENCODING  = #PB_UTF8

;- encryption constants
#APP_AES_SIZE = 256
#APP_SHA2_SIZE = 256
#APP_KEY_SIZE = 32
#APP_KEY_LEN = #APP_KEY_SIZE * 2
#APP_VEC_SIZE = 16
#APP_VEC_LEN = #APP_VEC_SIZE * 2

;- language constants
#APP_LANGUAGE_FILE = "languages.xml"
#APP_LANGUAGE_MAIN = "Cryptor-Languages"
#APP_LANGUAGE_LANGUAGES = "Languages"
#APP_LANGUAGE_LANGUAGE = "Language"
#APP_LANGUAGE_ENTRY = "Entry"
#APP_LANGUAGE_PLACEHOLDER = "%s"

;- file requester constants
#APP_REQUESTER_PATTERN_S = #APP_NAME + " files (*" + #APP_EXT + ")|*" + #APP_EXT
#APP_REQUESTER_PATTERN_L = #APP_REQUESTER_PATTERN_S + "|eXtended Markup Language files (*.xml)|*.xml;*.XML|All files (*.*)|*.*"

;- window constants
#APP_WINDOW_WIDTH  = 800
#APP_WINDOW_HEIGHT = 500
#APP_BUTTON_WIDTH  = 140
#APP_BUTTON_HEIGHT = 30
#APP_COLOR_WARNING   = $8080C0
#APP_TIMER_ID = 5

;- special MacOS constants
#APP_EVENT_MACOS_FINDER_FILELIST = #PB_Event_FirstCustomValue

;- application logging constants
Enumeration 1
  #APP_LOGTYPE_INFO
  #APP_LOGTYPE_WARNING
  #APP_LOGTYPE_ERROR
  #APP_LOGTYPE_DEBUG
EndEnumeration

;- password generator constants
Enumeration 0
  #BEGIN_WITH_RANDOM
  #BEGIN_WITH_UPPER_CASE
  #BEGIN_WITH_LOWER_CASE
  #BEGIN_WITH_NUMBER
  #BEGIN_WITH_SPECIAL_CHAR
EndEnumeration
#SPECIAL_CHARS = 29
#PASSWORD_IMAGE_WIDTH  = 380
#PASSWORD_IMAGE_HEIGHT = 120

;- application data constants
Enumeration 0
  #APP_DATA_NONE
  #APP_DATA_XML
  #APP_DATA_ENCODED
EndEnumeration

;- datatype name constants
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

;- dataset function constants
#APP_DATASET_NEW = -1
#APP_DATASET_NONE = 0
#APP_DATASET_DEL = 1
#APP_DATASET_CANCEL = 2
#APP_DATASET_EDIT = 3

;- application structures
Structure APP_SETTINGS
  version.l
  pos_x.l
  pos_y.l
  width.l
  height.l
  pw_len.l
  pw_start.l
  pw_uc.l
  pw_lc.l
  pw_num.l
  pw_special.l
  pw_valids.l
  pw_hyphen.l
  language.s
  lastFilename.s
EndStructure

Structure CONFIGURATION
  StrFormat.i
  Vector.s
  DefName.s
  DefEmail.s
  LastPath.s
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
  
  Protected.i h_log
  Protected.s text
  
  If start_logging
    write_log = #True
    set_once = #True
    If FileSize(APP_LOG_DIR$) = -1 Or FileSize(APP_LOG_DIR$) <> -2
      If CreateDirectory(APP_LOG_DIR$) = 0
        MessageRequester(#APP_NAME + " - ERROR", "Can't create directory: " + #NL + APP_LOG_DIR$ + #NL + "Insufficient rights? Exiting program.", #PB_MessageRequester_Error)
        End
      EndIf
    EndIf
    start_time = ElapsedMilliseconds()
    h_log = CreateFile(#PB_Any, APP_LOG_DIR$ + LCase(#APP_NAME) + ".log")
    text = format_timer(ElapsedMilliseconds()-start_time) + Space(2)
    WriteStringN(h_log, text + "start logging on " + #APP_OS + " " + #APP_VERSION)
    CloseFile(h_log)
  EndIf
  
  text = format_timer(ElapsedMilliseconds()-start_time) + Space(2)
  
  Select type
    Case #APP_LOGTYPE_INFO    : text + "[INFO]" + Space(1)
    Case #APP_LOGTYPE_WARNING : text + "[WARNING]" + Space(1)
    Case #APP_LOGTYPE_ERROR   : text + "[ERROR]" + Space(1)
    Case #APP_LOGTYPE_DEBUG   : text + "[DEBUG]" + Space(1)
  EndSelect
  
  CompilerIf #PB_Compiler_Debugger
    Debug text + message
  CompilerEndIf
  
  If write_log And type <> #APP_LOGTYPE_DEBUG
    h_log = OpenFile(#PB_Any, APP_LOG_DIR$ + LCase(#APP_NAME) + ".log")
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
Macro dbg( msg )  : logger("<" + #PB_Compiler_Procedure + "> : " + msg, #APP_LOGTYPE_DEBUG) : EndMacro
Macro StrH( long ) : RSet(Hex(long, #PB_Long), 8, "0") : EndMacro
Macro EnableGadget( Gadget ) : DisableGadget( Gadget , #False ) : EndMacro

;- add includes
XIncludeFile "language.pbi"
XIncludeFile "macos_functions.pbi"
XIncludeFile "conf_functions.pbi"
XIncludeFile "mem_functions.pbi"
XIncludeFile "pwd_functions.pbi"
XIncludeFile "xml_functions.pbi"
XIncludeFile "print_functions.pbi"
XIncludeFile "main_window.pbi"
XIncludeFile "about_window.pbi"
XIncludeFile "conf_window.pbi"

;- function declarations
Declare.l main( argc.l=0 )

;- application data section for icons
DataSection
  ICON_APP:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "cryptor_icon.png"
  ICON_HIDE:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_hide.png"
  ICON_SHOW:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_show.png"
  ICON_COPY:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_copy.png"
  ICON_WEB:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_web.png"
  ICON_MAKEPWD:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_makepwd.png"
  ICON_NEW:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_new.png"
  ICON_OPEN:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_open.png"
  ICON_SAVE:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_save.png"
  ICON_SAVEAS:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_saveas_xml.png"
  ICON_SAVEAS_ENC:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_saveas_lock.png"
  ICON_CLOSE:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_close.png"
  ICON_PRINT:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_print.png"
  ICON_QUIT:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_quit.png"
  ICON_ABOUT:
  IncludeBinary ".." + #PS$ + "res" + #PS$ + "icon_about.png"
EndDataSection
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 65
; FirstLine = 50
; Folding = +-
; EnableXP
; UseMainFile = main.pb
; CompileSourceDirectory
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant