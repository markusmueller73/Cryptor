;  * CRYPTOR
;  *
;  * main.pb
;  *
;  * Copyright 2020 by Markus Mueller <markus.mueller.73@hotmail.de>
;  *
;  * This program is free software; you can redistribute it and/or modify
;  * it under the terms of the GNU General Public License As published by
;  * the Free Software Foundation; either version 2 of the License, or
;  * (at your option) any later version.
;  *
;  * This program is distributed in the hope that it will be useful,
;  * but WITHOUT ANY WARRANTY; without even the implied warranty of
;  * MERCHANTABILITY or FITNESS for A PARTICULAR PURPOSE.  See the
;  * GNU General Public License for more details.
;  *
;  * You should have received a copy of the GNU General Public License
;  * along with this program; if not, write to the Free Software
;  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;  * MA 02110-1301, USA.
;  *
;--------------------------------------------------------------------------------
;- set environment

EnableExplicit

XIncludeFile "header.pbi"

;--------------------------------------------------------------------------------
;- macros
Macro _set_btns(new, edt, del, sav)
  DisableGadget(wnd\btn_new,  1-new)
  DisableGadget(wnd\btn_edit, 1-edt)
  DisableGadget(wnd\btn_del,  1-del)
  DisableGadget(wnd\btn_save, 1-sav)
EndMacro
Macro _click_mnu_new()
  
  If fileName <> #Null$
    fileName = #Null$
  EndIf
  
  _reset_cfg(cfg)
  If ListSize(dat()) > 0
    ClearList(dat())
  EndIf
  
  _set_btns(1, 0, 0, 0)
  
  SetWindowTitle(wnd\id, #APP_NAME + " - " + "untitled.xml" + " [*]") : inputChanged = #True : dataType = #APP_DATA_ENCODED
  
  info("created new database.")
  
EndMacro
Macro _click_mnu_open()
  
  lastFileName = fileName
  fileName = OpenFileRequester("Choose file" + "...", GetUserDirectory(#PB_Directory_Documents) + "*" + #APP_EXT, #APP_REQUESTER_PATTERN_L, 0)
  
  If fileName = ""
    
    info("open file requester aborted.")
    
    fileName = lastFileName
    
  Else
    
    If ("." + LCase(GetExtensionPart(fileName))) = #APP_EXT
      
      If xml_load_crypted(fileName, *vector, @cfg, dat())
        
        main_window_set_list(dat(), wnd)
          
        FirstElement(dat())
        SetGadgetItemState(wnd\lst, 0, 1)
        
        main_window_set_dataset(dat(), wnd)
        SetGadgetState(wnd\lst, 0)
        
        _set_btns(1, 1, 1, 0)
        
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
        
        dataType = #APP_DATA_ENCODED
        
      EndIf
      
    Else
      
      If xml_load(fileName, @cfg, dat())
        
        main_window_set_list(dat(), wnd)
        
        FirstElement(dat())
        SetGadgetItemState(wnd\lst, 0, 1)
        
        main_window_set_dataset(dat(), wnd) : SetGadgetState(wnd\lst, 0)
        
        _set_btns(1, 1, 1, 0)
        
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
        
        dataType = #APP_DATA_XML
        
      EndIf
      
    EndIf
    
  EndIf
  
  lastFileName = #Null$
  
EndMacro
Macro _click_mnu_saveas()
  
  lastFileName = fileName
  
  If fileName = #Null$
    fileName = SaveFileRequester("Save XML database...", "untitled.xml", "XML file (*.xml)|*.xml", 0)
  Else
    fileName = SaveFileRequester("Save XML database...", fileName, "XML file (*.xml)|*.xml", 0)
  EndIf
  
  If fileName
    
    If xml_save(fileName, @cfg, dat(), #False)
      SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
      info("XML file saved successfully: '" + fileName + "'.")
    Else
      warn("can't save XML file: '" + fileName + "'.")
    EndIf
    
  Else
    
    fileName = lastFileName
    lastFileName = #Null$
    
    If inputChanged
      
      If fileName = #Null$
        SetWindowTitle(wnd\id, #APP_NAME + " - " + "untitled.xml" + " [*]")
      Else
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName + " [*]")
      EndIf
      
    Else
      SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
    EndIf
    
  EndIf
  
EndMacro
Macro _click_mnu_enc_saveas()
  
  lastFileName = fileName
  
  If fileName = #Null$
    fileName = SaveFileRequester("Save encrypted database...", "untitled" + #APP_EXT, #APP_REQUESTER_PATTERN_S, 0)
  Else
    fileName = SaveFileRequester("Save encrypted database...", fileName, #APP_REQUESTER_PATTERN_S, 0)
  EndIf
  
  If fileName
    
    If xml_save_crypted(fileName, *vector, @cfg, dat(), #False)
      SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
      info("Encrypted file saved successfully: '" + fileName + "'.")
    Else
      warn("Can't save encrypted file: '" + fileName + "'.")
    EndIf
    
  Else
    
    fileName = lastFileName
    lastFileName = #Null$
    
    If inputChanged
      
      If fileName = #Null$
        SetWindowTitle(wnd\id, #APP_NAME + " - " + "untitled" + #APP_EXT + " [*]")
      Else
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName + " [*]")
      EndIf
      
    Else
      SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
    EndIf
    
  EndIf
  
EndMacro
Macro _click_mnu_save()
  
  If fileName <> #Null$
    
    If dataType = #APP_DATA_ENCODED
      
      If xml_save_crypted(fileName, *vector, @cfg, dat())
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
        info("Encoded file saved successfully: '" + fileName + "'.")
      Else
        warn("can't save encoded file: '" + fileName + "'.")
      EndIf
      
    ElseIf dataType = #APP_DATA_XML
      
      If xml_save(fileName, @cfg, dat())
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
        info("XML file saved successfully: '" + fileName + "'.")
      Else
        warn("can't save XML file: '" + fileName + "'.")
      EndIf
      
    EndIf
    
    SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
    
  Else
    
    MessageRequester(#APP_NAME, "The database is new and wasn't saved before." + #NL + "Select a new name And directory in the following dialog.", #PB_MessageRequester_Info)
    If dataType = #APP_DATA_ENCODED Or dataType = #APP_DATA_NONE
      _click_mnu_enc_saveas()
    ElseIf dataType = #APP_DATA_XML
      _click_mnu_saveas()
    EndIf
    
  EndIf
  
EndMacro
Macro _click_mnu_close()
  
  _reset_cfg(cfg)
  _reset_lst(dat())
  
  _set_btns(0, 0, 0, 0)
  
  _main_window_clear_data(wnd)
  
  ClearGadgetItems(wnd\lst)
  
  SetWindowTitle(wnd\id, #APP_NAME) : inputChanged = #False : dataType = #APP_DATA_NONE
  
EndMacro
Macro _click_mnu_print()
  print_database( dat() )
EndMacro

;--------------------------------------------------------------------------------

Define.l RESULT = main( CountProgramParameters() )
logger("program closed", #APP_LOGTYPE_INFO)
End RESULT

;--------------------------------------------------------------------------------
;- main() function
Procedure.l main( argc.l=0 )
  
  Protected.b doLoop = #True, errorCode = 0, inputChanged = #False, dataType = #APP_DATA_NONE, disabled = #True
  Protected.i wndEvt, evtMenu, evtGadget, evtType, *vector, *key
  Protected.s fileName, lastFileName, inputPwd
  
  Protected.CONFIGURATION cfg
  Protected.MAIN_WINDOW wnd
  
  NewList dat.DATASET()
  
  ;-- set memory vector and key
  *key    = AllocateMemory(#APP_BYTE_SIZE)
  *vector = AllocateMemory(#APP_BYTE_SIZE)
  
  string_to_mem(#APP_DEFAULT_VECTOR, *vector)
  
  ;-- open window
  main_window_open(@wnd)
  
  ;-- test for program parameters
  If argc > 0
    
    fileName = ProgramParameter()
    
    If FileSize(fileName) < 0
      
      ;---- program arg was set, but is no file
      MessageRequester(#APP_NAME, "The file:" + #NL + fileName + #NL + "did not exist or you have insufficient rights to open it.", #PB_MessageRequester_Warning)
      warn("program arg '" + fileName + "' was set, but file did not exist.")
      
      fileName = #Null$
      
    Else
      
      ;---- program arg was set and file exist
      info("program arg '" + fileName + "' was set.")
      
      ;---- try to load
      If xml_load(fileName, @cfg, dat())
        
        ;----- loading successful
        main_window_set_list(dat(), @wnd)
        
        FirstElement(dat())
        SetGadgetItemState(wnd\lst, 0, 1)
        
        main_window_set_dataset(dat(), @wnd)
        
        _set_btns(1, 1, 1, 0)
        
      Else
        
        ;----- can't load the file
        MessageRequester(#APP_NAME, "The file:" + #NL + fileName + #NL + "can't be opened or you have insufficient rights to open it.", #PB_MessageRequester_Info)
        warn("can't open the file '" + fileName + "'.")
        fileName = #Null$
        
      EndIf
      
    EndIf
    
    If fileName <> #Null$
      SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
    EndIf
    
  EndIf
  
  HideWindow(wnd\id, #False)
  
  ;-- start main loop
  Repeat
    
    wndEvt = WaitWindowEvent()
    
    Select wndEvt
        
      ;--- default window events
      Case #PB_Event_CloseWindow
        doLoop = #False
        
      ;--- check menu
      Case #PB_Event_Menu 
        
        evtMenu = EventMenu()
        Select evtMenu
            
          Case wnd\mnu\file_new
            _click_mnu_new()
            
          Case wnd\mnu\file_open
            _click_mnu_open()
            
          Case wnd\mnu\file_save
            _click_mnu_save()
            
          Case wnd\mnu\file_save_as
            _click_mnu_saveas()
            
          Case wnd\mnu\file_encrypted_save_as
            _click_mnu_enc_saveas()
            
          Case wnd\mnu\file_print
            _click_mnu_print()
            
          Case wnd\mnu\file_close
            _click_mnu_close()
            
          Case wnd\mnu\file_quit
            doLoop = #False
            
          Case wnd\mnu\help_about
            about_window_open(wnd\id)
            
          Default
            ; uncatched menu event
            ;info("uncatched menu #" + Str(evtMenu))
            
        EndSelect
        
      ;--- check gadgets
      Case #PB_Event_Gadget
        
        evtGadget = EventGadget()
        evtType = EventType()
        Select evtGadget
            
          Case wnd\lst
            ForEach dat()
              If GetGadgetItemData(wnd\lst, GetGadgetState(wnd\lst)) = dat()\id
                main_window_set_dataset(dat(), @wnd)
                Break
              EndIf
            Next
            
          Case wnd\cnt, wnd\scr
            ; not used at all
            
          Case wnd\btn_new
            main_window_new_dataset(dat(), @wnd)
            disabled = #False
            
          Case wnd\btn_edit
            main_window_edit_dataset(dat(), @wnd)
            disabled = #False
            
          Case wnd\btn_del
            main_window_delete_dataset(dat(), @wnd)
            
          Case wnd\btn_save
            main_window_save_dataset(dat(), @wnd)
            disabled = #True
            
          Case wnd\btn_show
            If GetGadgetState(wnd\btn_show)
              ; "LOCK"
              main_window_switch_pwd_gadgets(@wnd, 0, disabled)
            Else
              ; "UNLOCK"
              main_window_switch_pwd_gadgets(@wnd, 1, disabled)
            EndIf
            
          Case wnd\btn_copy
            If GetGadgetText(wnd\str_password) <> ""
              SetClipboardText(GetGadgetText(wnd\str_password))
            Else
              info("No password set, nothing to copy.")
            EndIf
            
          Case wnd\btn_make
            If GetGadgetText(wnd\str_password) <> ""
              If MessageRequester(#APP_NAME, "There is already a password, do you want to overwrite?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                SetGadgetText(wnd\str_password, gen_pwd(16, 4, 4, 3, 3, #BEGIN_WITH_UPPER_CASE))
                SetGadgetText(wnd\str_password2, GetGadgetText(wnd\str_password))
              EndIf
            Else
              SetGadgetText(wnd\str_password, gen_pwd(16, 4, 4, 3, 3, #BEGIN_WITH_UPPER_CASE))
              SetGadgetText(wnd\str_password2, GetGadgetText(wnd\str_password))
            EndIf
            
          Case wnd\txt_address, wnd\txt_comment, wnd\txt_company, wnd\txt_email, wnd\txt_password, wnd\txt_password2, wnd\txt_username
            ; not used at all
            
          Case wnd\str_address, wnd\str_comment, wnd\str_company, wnd\str_email, wnd\str_username
            ; not used here, look at function: main_window_gadget_event_cb()
            
          Case wnd\str_password
            If evtType = #PB_EventType_Change
              If GetGadgetText(wnd\str_password) <> GetGadgetText(wnd\str_password2)
                SetGadgetColor(wnd\str_password2, #PB_Gadget_BackColor, #APP_COLOR_WARNING)
              Else
                SetGadgetColor(wnd\str_password2, #PB_Gadget_BackColor, #PB_Default)
              EndIf
            EndIf
            
          Case wnd\str_password2
            If evtType = #PB_EventType_Change Or evtType = #PB_EventType_Focus
              If GetGadgetText(wnd\str_password) <> GetGadgetText(wnd\str_password2)
                SetGadgetColor(wnd\str_password2, #PB_Gadget_BackColor, #APP_COLOR_WARNING)
              Else
                SetGadgetColor(wnd\str_password2, #PB_Gadget_BackColor, #APP_COLOR_HIGHLIGHT)
              EndIf
            EndIf
            
          Default
            ; unknown/uncatched gadget
            ;info("uncatched gadget #" + Str(evtGadget))
            
        EndSelect
        
      Default 
        ; uncatched events
        ;info("uncatched window event #" + Str(wndEvt))
        
    EndSelect
    
  Until doLoop = #False
  
  ;-- check for unsaved data
  If inputChanged
    If MessageRequester(#APP_NAME, "You have add or edit data, but didn't save the changes." + #NL + "Would you save it now?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      _click_mnu_save()
    EndIf
  EndIf
  
  ;-- end loop
  CloseWindow(wnd\id)
  
  ProcedureReturn errorCode
  
EndProcedure
;- end of main()
;--------------------------------------------------------------------------------

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 432
; FirstLine = 194
; Folding = A9
; EnableXP
; UseIcon = icons/cryptor_icon.png
; CommandLine = testfile.xml
; CompileSourceDirectory
; EnablePurifier
; EnableCompileCount = 106
; EnableBuildCount = 0
; EnableExeConstant