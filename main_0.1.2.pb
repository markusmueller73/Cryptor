EnableExplicit

UsePNGImageDecoder()
UseMD5Fingerprint()

#APP_NAME  = "Cryptor"
#APP_MAJOR = 1
#APP_MINOR = 0
#APP_EXT   = ".pwdf"
#APP_EXT_L = $50574446
#APP_BYTE_SIZE = 16
#APP_REQUESTER_PATTERN_S = #APP_NAME + " file (*" + #APP_EXT + ")|*" + #APP_EXT
#APP_REQUESTER_PATTERN_L = #APP_REQUESTER_PATTERN_S + "|Text files (*.txt)|*.txt|All files (*.*)|*.*"
#APP_WINDOW_WIDTH  = 550
#APP_WINDOW_HEIGHT = 600
#APP_BUTTON_WIDTH  = 80
#APP_BUTTON_HEIGHT = 30

Enumeration 1
  #WND_MAIN
  #FNT_EDITOR
  #EDT_MAIN
  #TXT_MAIN
  #BTN_INFO
  #BTN_CLEAR
  #BTN_CLOSE
  #BTN_LOAD
  #BTN_SAVE
  #IMG_MAIN
EndEnumeration

Enumeration 1
  #ICON_LOCK
EndEnumeration

Macro void : : EndMacro
Macro info( msg ) : Debug ( "[" + #PB_Compiler_Procedure + "] warning: " + msg ) : EndMacro
Macro ClearMem( memory ) : FillMemory(memory, #APP_BYTE_SIZE) : EndMacro

Declare.l Main( void ) : Define.l RESULT = Main() : End RESULT

Procedure.i Str2Mem( string.s , *mem )
  
  Protected.i i
  Protected.s s
  
  If Len(string) = 0
    info("empty string")
    ProcedureReturn 0
  EndIf
  
  s = StringFingerprint(string, #PB_Cipher_MD5)
  
  If Len(s) <> 32
    info("can't create valid key string")
    ProcedureReturn 0
  EndIf
  
  If *mem = 0
    info("memory isn't allocated")
    ProcedureReturn 0
  EndIf
  
  For i = 0 To 15
    PokeB(*mem + i, Val("$"+Mid(s, i*2+1, 2)))
  Next
  
  ProcedureReturn @*mem
  
EndProcedure

Procedure.i GetPassword( *key , ask_twice.b = #False )
  
  Protected.s pwd1, pwd2, text1
  
  If ask_twice
    text1 = "Type in the password to lock your file:"
  Else
    text1 = "Type in the password to unlock your file:"
  EndIf
  
  pwd1 = InputRequester("Password Requester", text1, "", #PB_InputRequester_Password)
  If pwd1 = #Null$
    info("no password input")
    ProcedureReturn 0
  EndIf
  
  If ask_twice
    
    pwd2 = InputRequester("Password Requester", "Type in the password again:", "", #PB_InputRequester_Password)
    If CompareMemoryString(@pwd1, @pwd2) = #PB_String_Equal
      Str2Mem(pwd2, *key)
      pwd1 = #Null$ : pwd2 = #Null$
    Else
      pwd1 = #Null$ : pwd2 = #Null$
      info("passwords didn't match")
      ProcedureReturn 0
    EndIf
    
  Else
    Str2Mem(pwd1, *key) : pwd1 = #Null$
  EndIf
  
  ProcedureReturn @*key
  
EndProcedure

Procedure.l SetFilename( newFilename.s )
  If IsGadget(#TXT_MAIN); And newFilename <> #Null$
    SetGadgetText(#TXT_MAIN, "File: " + newFilename)
  EndIf
EndProcedure

Procedure.l ShowCryptionImage( show.l = #True )
  If show
    SetGadgetState(#IMG_MAIN, ImageID(#ICON_LOCK))
  Else
    SetGadgetState(#IMG_MAIN, 0)
  EndIf
  ProcedureReturn show
EndProcedure

Procedure.s LoadButton_Clicked( filename.s , *vec , *key )
  
  Protected.l file_size, content_size, null_byte = StringByteLength(Str($0), #PB_Unicode)
  Protected.i handle, str_format, *content, *encrypted
  Protected.s old_filename, text
  
  If filename = ""
    old_filename = "my_password"+#APP_EXT
  Else
    old_filename = filename
  EndIf
  
  filename = OpenFileRequester("Select decrypted file:", old_filename, #APP_REQUESTER_PATTERN_L, 0)
  
  If filename = ""
    info("load file requester aborted.")
    ProcedureReturn #Null$
  EndIf
  
  file_size = FileSize(filename)
  If file_size <= 0
    info("file '" + filename + "' does not exist.")
    ProcedureReturn #Null$
  EndIf
  
  handle = ReadFile(#PB_Any, filename)
  If IsFile(handle)
    
    If ReadLong(handle) = #APP_EXT_L
      
      If *vec = 0
        info("memory isn't allocated (*vec)")
        ProcedureReturn #Null$
      EndIf
      
      ReadData(handle, *vec, 16)
      
      content_size = ReadLong(handle)
      
      *content = AllocateMemory(content_size + null_byte)
      *encrypted = AllocateMemory(content_size + null_byte)
      
      ReadData(handle, *content, content_size + null_byte)
      
      CloseFile(handle)
      
      GetPassword(*key)
      
      If AESDecoder(*content, *encrypted, content_size, *key, 128, *vec)
        ClearMem(*key)
        text = PeekS(*encrypted, content_size + null_byte, #PB_Unicode)
        FreeMemory(*encrypted) : FreeMemory(*content)
      Else
        ClearMem(*key)
        FreeMemory(*encrypted) : FreeMemory(*content)
        info("can't decrypt the content")
        ProcedureReturn #Null$
      EndIf
      
      ClearGadgetItems(#EDT_MAIN)
      SetGadgetText(#EDT_MAIN, text)
      ShowCryptionImage()
      
    Else
      
      Select ReadStringFormat(handle)
        ;Case #PB_Ascii     : str_format = #PB_Ascii
        Case #PB_UTF8      : str_format = #PB_UTF8
        Case #PB_Unicode   : str_format = #PB_Unicode ; = UTF 16 (little endian)
        Case #PB_UTF16BE   : info("unsupported string format: UTF 16 big endian")
        Case #PB_UTF32     : info("unsupported string format: UTF 32 little endian")
        Case #PB_UTF32BE   : info("unsupported string format: UTF 32 big endian")
        Default            : str_format = #PB_UTF8
      EndSelect
      
      *content = AllocateMemory(file_size)
      
      FileSeek(handle, 0)
      ReadData(handle, *content, file_size)
      
      CloseFile(handle)
      
      text = PeekS(*content, file_size, str_format)
      FreeMemory(*content)
      
      ClearGadgetItems(#EDT_MAIN)
      SetGadgetText(#EDT_MAIN, text)
      ShowCryptionImage(#False)
      
    EndIf
    
  Else
    info("can't open file '"+filename+"'")
    ProcedureReturn #Null$
  EndIf
  
  ProcedureReturn filename
  
EndProcedure

Procedure.s SaveButton_Clicked( filename.s , *key , *vec )
  
  Protected.l content_size, null_byte = StringByteLength(Str($0), #PB_Unicode)
  Protected.i handle, *content, *decrypted
  Protected.s text
  
  If *key = 0
    info("memory not allocated (*key)")
    ProcedureReturn #Null$
  EndIf
  
  If *vec = 0
    info("memory not allocated (*vec)")
    ProcedureReturn #Null$
  EndIf
  
  If filename = ""
    info("filename was #Null$")
    filename = "my_password"+#APP_EXT
  EndIf
  
  fileName = SaveFileRequester("Select path and filename:", fileName, #APP_REQUESTER_PATTERN_S, 0)
  
  If fileName = ""
    info("save file selection aborted")
    ProcedureReturn #Null$
  EndIf
  
  text = GetGadgetText(#EDT_MAIN)
  If Len(text) = 0
    info("editor is empty, no text available")
    ProcedureReturn #Null$
  EndIf
  
  content_size = StringByteLength(text, #PB_Unicode)
  *content = AllocateMemory(content_size + null_byte)
  If *content = 0
    info("can't allocate memory (*content)")
    ProcedureReturn #Null$
  EndIf
  PokeS(*content, text, content_size + null_byte, #PB_Unicode)
  
  *decrypted = AllocateMemory(content_size + null_byte)
  If *decrypted = 0
    FreeMemory(*content)
    info("can't allocate memory (*decrypted)")
    ProcedureReturn #Null$
  EndIf
  
  If GetPassword(*key, #True) = 0
    info("no valid password set")
    ProcedureReturn #Null$
  EndIf
  
  If AESEncoder(*content, *decrypted, content_size, *key, 128, *vec)
    
    FreeMemory(*content) : ClearMem(*key)
    
    handle = CreateFile(#PB_Any, filename)
    If IsFile(handle)
      
      WriteLong(handle, #APP_EXT_L)
      WriteData(handle, *vec, 16)
      WriteLong(handle, content_size)
      WriteData(handle, *decrypted, content_size + null_byte)
      
      CloseFile(handle)
      
      FreeMemory(*decrypted)
      
      ShowCryptionImage()
      
    Else
      FreeMemory(*decrypted)
      info("can't create file '" + filename + "'")
      ProcedureReturn #Null$
    EndIf
    
  Else
    FreeMemory(*content)
    FreeMemory(*decrypted)
    info("can't create decrypted data")
    ProcedureReturn #Null$
  EndIf
  
  ProcedureReturn filename
  
EndProcedure

Procedure.l Editor_Clicked( evtType.l )
  
  Protected.l hasChanged = #False
  
  Select evtType
    
    Case #PB_EventType_Focus
      ;
      
    Case #PB_EventType_LostFocus
      ;
      
    Case #PB_EventType_Change
      hasChanged = #True
      
    Default
      ProcedureReturn 0
      
  EndSelect
  
  ProcedureReturn hasChanged
  
EndProcedure

Procedure.l MainWindow_Open( x.l=#PB_Ignore , y.l =#PB_Ignore )
  
  Protected.l ww = #APP_WINDOW_WIDTH, wh = #APP_WINDOW_HEIGHT, bw = #APP_BUTTON_WIDTH, bh = #APP_BUTTON_HEIGHT
  
  If OpenWindow(#WND_MAIN, x, y, ww, wh, #APP_NAME + " v" + Str(#APP_MAJOR) + "." + Str(#APP_MINOR), #PB_Window_SystemMenu|#PB_Window_Invisible)
    
    CatchImage(#ICON_LOCK, ?ICON_LOCK) 
    
    ButtonGadget(#BTN_LOAD,  10,                        wh-bh-10, bw, bh, "Load...")
    ButtonGadget(#BTN_SAVE,  GadgetX(#BTN_LOAD)+bw+10,  wh-bh-10, bw, bh, "Save as...")
    ButtonGadget(#BTN_CLOSE, ww-bw-10,                  wh-bh-10, bw, bh, "Close")
    ButtonGadget(#BTN_CLEAR, GadgetX(#BTN_CLOSE)-bw-10, wh-bh-10, bw, bh, "Clear")
    
    ButtonGadget(#BTN_INFO,  ww-bh-10,                  10,       bh, bh, "?")
    TextGadget(#TXT_MAIN, 10, 15, ww-bh-bh, bh, "File:")
    ImageGadget(#IMG_MAIN, ww-bh-bh-20 , 10, bh, bh, 0)
    
    EditorGadget(#EDT_MAIN, 10, GadgetY(#BTN_INFO)+bh+10, WindowWidth(#WND_MAIN)-20, WindowHeight(#WND_MAIN)-bh-70, #PB_Editor_WordWrap)
    If LoadFont(#FNT_EDITOR, "Courier New", 12, #PB_Font_HighQuality)    
      SetGadgetFont(#EDT_MAIN, FontID(#FNT_EDITOR))
    EndIf
    
  Else
    ProcedureReturn 0
  EndIf
  
  HideWindow(#WND_MAIN, #False)
  
  ProcedureReturn 1
  
EndProcedure

Procedure.l Main( void )
  
  Protected.l doLoop = #True, errorCode = 0, contentChanged = #False
  Protected.i wndEvt, evtGadget, evtType, *vector, *key
  Protected.s fileName, editContent
  
  *key = AllocateMemory(#APP_BYTE_SIZE)
  *vector = AllocateMemory(#APP_BYTE_SIZE)
  
  Str2Mem(#APP_DEFAULT_VECTOR, *vector)
  
  MainWindow_Open()
  
  Repeat
    
    wndEvt = WaitWindowEvent()
    
    Select wndEvt
        
      Case #PB_Event_CloseWindow
        doLoop = #False
        
      Case #PB_Event_Gadget
        
        evtGadget = EventGadget()
        Select evtGadget
            
          Case #EDT_MAIN
            contentChanged = Editor_Clicked(EventType())
            
          Case #BTN_LOAD
            fileName = LoadButton_Clicked(fileName, *key, *vector)
            SetFilename(fileName)
            
          Case #BTN_SAVE
            fileName = SaveButton_Clicked(fileName, *key, *vector)
            SetFilename(fileName)
            
          Case #BTN_CLEAR
            ClearGadgetItems(#EDT_MAIN)
            fileName = #Null$
            SetFilename(fileName)
            ShowCryptionImage(#False)
            
          Case #BTN_CLOSE
            doLoop = #False
            
          Case #BTN_INFO
            MessageRequester(#APP_NAME, #APP_NAME + " v " + #APP_MAJOR + "." + #APP_MINOR + "." + #PB_Editor_BuildCount + " " + #CRLF$ + Chr(169) + " 2020 by Makke")
            
        EndSelect
        
      Default 
        ; uncatched events
        
    EndSelect
    
  Until doLoop = #False
  
  CloseWindow(#WND_MAIN)
  
  ProcedureReturn errorCode
  
EndProcedure

DataSection
  ICON_LOCK:
  IncludeBinary "images"+#PS$+"lock_icon.png"
  END_ICON_LOCK:
EndDataSection
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 434
; Folding = ng-
; EnableXP
; UseIcon = images/cryptor_icon.png
; Executable = Cryptor.app
; EnablePurifier
; EnableCompileCount = 105
; EnableBuildCount = 2
; EnableExeConstant
; Constant = #APP_DEFAULT_VECTOR = "1AE544183C0C3E6FE05F1CD83EB0383E"