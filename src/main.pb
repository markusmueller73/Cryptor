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
Macro _load_file_from_parameter( nbOfParams )
  
  If nbOfParams > 0
    
    If ALT_PARAMS_SET
      FirstElement(PARAMETER_LIST())
      fileName = PARAMETER_LIST()
    Else
      fileName = ProgramParameter(0)
    EndIf
    
    If FileSize(fileName) < 0
      
      ;---- program arg was set, but is no file
      MessageRequester(#APP_NAME, "The file:" + #NL + fileName + #NL + "did not exist or you have insufficient rights to open it.", #PB_MessageRequester_Warning)
      warn("program arg '" + fileName + "' was set, but file did not exist.")
      
      fileName = #Null$
      
    Else
      
      ;---- program arg was set and file exist
      info("program arg '" + fileName + "' was set.")
      
      ;---- check file type
      dataType = check_file(fileName)
      If dataType = #APP_DATA_XML
        
        If xml_load(fileName, @cfg, dat())
          loadSuccess = #True
        Else
          loadSuccess = #False
        EndIf
        
      ElseIf dataType = #APP_DATA_ENCODED
        
        If xml_load_crypted(fileName, *vector, @cfg, dat())
          loadSuccess = #True
        Else
          loadSuccess = #False
        EndIf
        
      Else
        loadSuccess = #False
      EndIf
      
      If loadSuccess
        ;----- loading successful
        
        If CountGadgetItems(wnd\lst) > 0
          ClearGadgetItems(wnd\lst)
        EndIf
        
        If ListSize(dat()) > 0
          
          n = 0
          ForEach dat()
            AddGadgetItem(wnd\lst, n, dat()\Company)
            SetGadgetItemData(wnd\lst, n, dat()\Id)
            n + 1
          Next
          
          FirstElement(dat()) : currentData = dat()
          SetGadgetItemState(wnd\lst, 0, 1)
          
          SetGadgetText(wnd\str_address,   currentData\address)
          SetGadgetText(wnd\str_comment,   currentData\comment)
          SetGadgetText(wnd\str_company,   currentData\company)
          SetGadgetData(wnd\str_company,   currentData\Id)
          SetGadgetText(wnd\str_email,     currentData\email)
          SetGadgetText(wnd\str_password,  currentData\password)
          SetGadgetText(wnd\str_password2, currentData\password2)
          SetGadgetText(wnd\str_username,  currentData\username)
          
        EndIf
        
        EnableGadget(wnd\btn_new)
        EnableGadget(wnd\btn_edit)
        EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_DEL")) : deleteState = #APP_DATASET_DEL
        DisableGadget(wnd\btn_save, #True)
        
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
    
  Else
    info("No program arguments set.")
  EndIf
  
EndMacro
Macro _copy_gadget_to_clipboard( gadget )
  If GetGadgetText(gadget) <> ""
    SetClipboardText(GetGadgetText(gadget))
    AddWindowTimer(wnd\id, #APP_TIMER_ID, #APP_TIMER_ID * 1000)
    info("Copy gadget (#" + gadget + ") content to clipboard and startet a " + Str(#APP_TIMER_ID) + " sec. timer.")
  Else
    info("Gadget " + gadget + " has no content, nothing To copy.")
  EndIf
EndMacro

;--------------------------------------------------------------------------------

Define.l RESULT = main( PARAMS )
logger("Program closed (errorcode: " + Str(RESULT) + ")", #APP_LOGTYPE_INFO)
End RESULT

;--------------------------------------------------------------------------------
;- main() function
Procedure.l main( argc.l=0 )
  
  Protected.b loadSuccess
  Protected.b doLoop = #True
  Protected.b errorCode = 0
  Protected.b inputChanged = #False
  Protected.b dataType = #APP_DATA_NONE
  Protected.b data_fields_disabled = #True
  Protected.b dataError
  Protected.b editState = #APP_DATASET_NONE
  Protected.b deleteState = #APP_DATASET_DEL
  
  Protected.i n
  Protected.i wndEvt
  Protected.i evtMenu
  Protected.i evtGadget
  Protected.i evtType
  Protected.i evtTimer
  Protected.i copyTimer
  Protected.i currentId
  Protected.i currentPos
  Protected.i *vector
  Protected.i *key
  
  Protected.s fileName
  Protected.s lastFileName
  Protected.s inputPwd
  
  Protected.CONFIGURATION cfg
  Protected.MAIN_WINDOW   wnd
  Protected.APP_SETTINGS  ini
  Protected.DATASET       currentData
  
  NewList dat.DATASET()
  
  ;-- set memory vector and key
  *key    = AllocateMemory(#APP_KEY_SIZE)
  *vector = AllocateMemory(#APP_VEC_SIZE)
  
  md5string_to_mem(#APP_DEFAULT_VECTOR, *vector)
  
  ;-- load app settings
  load_settings(ini)
  
  ;-- load language
  If load_language(ini\language) = 0
    MessageRequester("Error", "Can't load the the language '" + ini\language + "'." + #NL + "Try to delete the config file and start again", #PB_MessageRequester_Error)
    ProcedureReturn 1
  EndIf
  
  ;-- open window
  If main_window_open(@wnd, ini\pos_x, ini\pos_y)
    SetActiveWindow(wnd\id)
    dbg("Main window opened ($" + StrH(wnd\id) + ")")
  Else
    warn("Can't open a window.")
    ProcedureReturn 1
  EndIf
  
  ;-- test for program parameters
  _load_file_from_parameter(argc)
  
  ;-- open main window
  HideWindow(wnd\id, #False)
  
  ;-- start main loop
  Repeat
    
    wndEvt = WaitWindowEvent()
    
    Select wndEvt
        
      ;--- custom event only for MacOS
      Case #APP_EVENT_MACOS_FINDER_FILELIST
        _load_file_from_parameter(PARAMS)
        
      ;--- default window events
      Case #PB_Event_CloseWindow
        doLoop = #False
        
      ;--- check menu
      Case #PB_Event_Menu 
        
        evtMenu = EventMenu()
        Select evtMenu
            
          ;--- menu FILE->NEW
          Case wnd\mnu\file_new
            
            ;----- reset config and list
            _reset_cfg(cfg)
            _reset_lst(dat())
            
            ;----- set button state
            EnableGadget(wnd\btn_new)
            EnableGadget(wnd\btn_edit)
            EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_DEL")) : deleteState = #APP_DATASET_DEL
            DisableGadget(wnd\btn_save, #True)
            
            ;----- clear list gadget
            ClearGadgetItems(wnd\lst)
            
            ;----- set gadget state
            main_window_disable_gadgets(wnd)
            data_fields_disabled = #True
            
            ;----- clear gadget content
            main_window_del_data(wnd)
            
            ;----- set filename and window title
            fileName = "untitled" + #APP_EXT
            SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName + " [*]")
            dataType = #APP_DATA_ENCODED
            inputChanged = #True
            
            info("Created new database.")
            
          ;--- menu FILE->OPEN
          Case wnd\mnu\file_open
            
            lastFileName = fileName
            fileName = OpenFileRequester("Choose file" + "...", ini\lastFilename, #APP_REQUESTER_PATTERN_L, 0)
            
            If fileName = ""
              
              fileName = lastFileName
              info("Open file requester aborted.")
              
            Else
              
              If check_file(fileName) = #APP_DATA_ENCODED
                
                If xml_load_crypted(fileName, *vector, @cfg, dat())
                  
                  ;----- set button state
                  EnableGadget(wnd\btn_new)
                  EnableGadget(wnd\btn_edit)
                  EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_DEL")) : deleteState = #APP_DATASET_DEL
                  DisableGadget(wnd\btn_save, #True)
                  
                  ;----- clear list gadget
                  ClearGadgetItems(wnd\lst)
                  
                  ;----- set gadget state
                  main_window_disable_gadgets(wnd)
                  data_fields_disabled = #True
                  
                  ;----- clear gadget content
                  main_window_del_data(wnd)
                  
                  ;----- set list and data field content
                  FirstElement(dat())
                  currentData = dat()
                  currentPos  = 0
                  main_window_set_list(dat(), wnd)
                  SetGadgetState(wnd\lst, currentPos)
                  SetGadgetItemState(wnd\lst, currentPos, 1)
                  main_window_set_data(currentData, wnd)
                  
                  ;----- set filename and window title
                  SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
                  dataType = #APP_DATA_ENCODED
                  inputChanged = #False
                  
                  ini\lastFilename = fileName
                  
                EndIf
                
              Else
                
                If xml_load(fileName, @cfg, dat())
                  
                  ;----- set button state
                  EnableGadget(wnd\btn_new)
                  EnableGadget(wnd\btn_edit)
                  EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_DEL")) : deleteState = #APP_DATASET_DEL
                  DisableGadget(wnd\btn_save, #True)
                  
                  ;----- clear list gadget
                  ClearGadgetItems(wnd\lst)
                  
                  ;----- set gadget state
                  main_window_disable_gadgets(wnd)
                  data_fields_disabled = #True
                  
                  ;----- clear gadget content
                  main_window_del_data(wnd)
                  
                  ;----- set list and data field content
                  FirstElement(dat())
                  currentData = dat()
                  currentPos  = 0
                  main_window_set_list(dat(), wnd)
                  SetGadgetState(wnd\lst, currentPos)
                  SetGadgetItemState(wnd\lst, currentPos, 1)
                  main_window_set_data(currentData, wnd)
                  
                  ;----- set filename and window title
                  SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
                  dataType = #APP_DATA_XML
                  inputChanged = #False
                  
                  ini\lastFilename = fileName
                  
                EndIf
                
              EndIf
              
            EndIf
            
            lastFileName = #Null$
            
          ;--- menu FILE->SAVE
          Case wnd\mnu\file_save
            
            If fileName <> #Null$
              
              If dataType = #APP_DATA_ENCODED
                
                If xml_save_crypted(fileName, *vector, @cfg, dat())
                  SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
                  inputChanged = #False
                  info("Encoded file saved successfully: '" + fileName + "'.")
                Else
                  warn("can't save encoded file: '" + fileName + "'.")
                EndIf
                
              ElseIf dataType = #APP_DATA_XML
                
                If xml_save(fileName, @cfg, dat())
                  SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
                  inputChanged = #False
                  info("XML file saved successfully: '" + fileName + "'.")
                Else
                  warn("can't save XML file: '" + fileName + "'.")
                EndIf
                
              EndIf
              
              SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
              inputChanged = #False
              
            Else
              MessageRequester(#APP_NAME, LANGUAGE("DIALOG_DATABASE_WASNT_SAVED"), #PB_MessageRequester_Info)
            EndIf
            
          ;--- menu FILE->SAVE AS
          Case wnd\mnu\file_save_as
            
            lastFileName = fileName
            
            If fileName = #Null$
              fileName = SaveFileRequester(LANGUAGE("DIALOG_DATABASE_SAVE_XML"), "untitled.xml", "XML file (*.xml)|*.xml", 0)
            Else
              fileName = SaveFileRequester(LANGUAGE("DIALOG_DATABASE_SAVE_ENC"), fileName, "XML file (*.xml)|*.xml", 0)
            EndIf
            
            If fileName
              
              If xml_save(fileName, @cfg, dat(), #False)
                SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
                inputChanged = #False
                ini\lastFilename = fileName
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
            
          ;--- menu FILE->SAVE AS ENCRYPTED
          Case wnd\mnu\file_encrypted_save_as
            
            lastFileName = fileName
            
            If fileName = #Null$
              fileName = SaveFileRequester(LANGUAGE("DIALOG_DATABASE_SAVE_ENC"), "untitled" + #APP_EXT, #APP_REQUESTER_PATTERN_S, 0)
            Else
              fileName = SaveFileRequester(LANGUAGE("DIALOG_DATABASE_SAVE_ENC"), fileName, #APP_REQUESTER_PATTERN_S, 0)
            EndIf
            
            If fileName
              
              If xml_save_crypted(fileName, *vector, @cfg, dat(), #False)
                SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
                inputChanged = #False
                ini\lastFilename = fileName
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
            
          ;--- menu FILE->PRINT
          Case wnd\mnu\file_print
            
            print_database(dat())
            
          ;--- menu FILE->CLOSE
          Case wnd\mnu\file_close
            
            ;----- reset config and list
            _reset_cfg(cfg)
            _reset_lst(dat())
            
            ;----- set button state
            DisableGadget(wnd\btn_new,  #True)
            DisableGadget(wnd\btn_edit, #True)
            DisableGadget(wnd\btn_del, #True) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_CANCEL")) : deleteState = #APP_DATASET_CANCEL
            DisableGadget(wnd\btn_save, #True)
            
            ;----- clear list gadget
            ClearGadgetItems(wnd\lst)
            
            ;----- set gadget state
            main_window_disable_gadgets(wnd)
            data_fields_disabled = #True
            
            ;----- clear gadget content
            main_window_del_data(wnd)
            
            ;----- set filename and window title
            fileName = ""
            SetWindowTitle(wnd\id, #APP_NAME)
            dataType = #APP_DATA_NONE
            inputChanged = #False
            
          ;--- menu FILE->QUIT
          Case wnd\mnu\file_quit
            doLoop = #False
            
          ;--- menu HELP->ABOUT
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
            
          ;---- click LIST gadgets
          Case wnd\lst
            
            If editState = #APP_DATASET_NONE
              
              currentPos = GetGadgetState(wnd\lst)
              currentId = GetGadgetItemData(wnd\lst, currentPos)
              
              dbg("Selected list state: pos " + Str(currentPos) + " id " + Str(currentid))
              
              ;----- search for dataset
              ClearStructure(@currentData, DATASET)
              ForEach dat()
                If currentId = dat()\id
                  currentData = dat()
                  Break
                EndIf
              Next
              
              main_window_del_data(wnd)
              
              If currentId > 0
                main_window_set_data(currentData, wnd)
              EndIf
              
            EndIf
            
          Case wnd\cnt, wnd\scr
            ; not used at all
            
          ;---- click DATASET NEW button
          Case wnd\btn_new
            
            currentPos = GetGadgetState(wnd\lst)
            ;----- set button state
            DisableGadget(wnd\btn_new,  #True)
            DisableGadget(wnd\btn_edit, #True)
            EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_CANCEL")) : deleteState = #APP_DATASET_CANCEL
            EnableGadget(wnd\btn_save)
            ;----- set gadget state
            main_window_enable_gadgets(wnd)
            data_fields_disabled = #False
            ;----- clear gadget content
            main_window_del_data(wnd)
            ;----- set active gadget data
            SetGadgetData(wnd\str_company, #APP_DATASET_NEW)
            editState = #APP_DATASET_NEW
            
          ;---- click DATASET EDIT button
          Case wnd\btn_edit
            
            currentPos = GetGadgetState(wnd\lst)
            ;----- set button state
            DisableGadget(wnd\btn_new,  #True)
            DisableGadget(wnd\btn_edit, #True)
            EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_CANCEL")) : deleteState = #APP_DATASET_CANCEL
            EnableGadget(wnd\btn_save)
            ;----- set gadget state
            main_window_enable_gadgets(wnd, #APP_DATASET_EDIT)
            data_fields_disabled = #False
            ;----- get current id
            main_window_get_data(currentData, wnd)
            currentId = GetGadgetData(wnd\str_company)
            editState = #APP_DATASET_EDIT
            
          ;---- click DATASET DELETE button
          Case wnd\btn_del
            
            ;----- check for delete state
            If deleteState = #APP_DATASET_DEL ;----- delete state deleting
              
              ;------ get current id
              currentPos = GetGadgetState(wnd\lst)
              currentId = GetGadgetData(wnd\str_company)
              
              ;------ search for dataset
              n = 0
              ForEach dat()
                
                If currentId = dat()\id
                  
                  If MessageRequester(LANGUAGE("BTN_DATA_DEL"), LANGUAGE("DIALOG_DATASET_DELETE") + ":" + #NL + dat()\Company, #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                    
                    ;------- delete dataset
                    DeleteElement(dat(), 1)
                    main_window_del_data(wnd)
                    info("User decision: the dataset '" + dat()\Company + "' was deleted.")
                    
                    ;-------  set list and data view
                    If ListSize(dat()) > 0
                      
                      main_window_set_list(dat(), wnd)
                      SetGadgetState(wnd\lst, 0)
                      
                      ClearStructure(currentData, DATASET)
                      FirstElement(dat())
                      currentData = dat()
                      main_window_set_data(currentData, wnd)
                      
                    Else
                      ClearGadgetItems(wnd\lst)
                    EndIf
                    
                    inputChanged = #True
                    
                  Else
                    info("User decision: dataset '" + dat()\Company + "' didn't deleted.")
                  EndIf
                  
                  n = 1
                  
                  Break
                  
                EndIf
                
              Next
              
              ;------ dataset not found
              If n = 0
                main_window_sel_list_by_pos(dat(), wnd, currentPos)
                warn("The selected id " + Str(currentId) + " for dataset '" + GetGadgetText(wnd\str_company) + "' wasn't found in list.")
              EndIf
              
            ElseIf deleteState = #APP_DATASET_CANCEL;----- delete state cancel
              
              ;----- set button state
              EnableGadget(wnd\btn_new)
              EnableGadget(wnd\btn_edit)
              EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_DEL")) : deleteState = #APP_DATASET_DEL
              DisableGadget(wnd\btn_save, #True)
              ;----- set gadget state
              main_window_disable_gadgets(wnd, editState)
              data_fields_disabled = #False
              editState = #APP_DATASET_NONE
            
            EndIf
            
          ;---- click DATASET SAVE button
          Case wnd\btn_save
            
            dataError = #False
            
            If editState = #APP_DATASET_NEW
              ;----- check for valid data
              If GetGadgetText(wnd\str_company) = ""
                
                MessageRequester(LANGUAGE("DIALOG_ERROR"), LANGUAGE("DIALOG_DATASET_ERROR_COMPANY"))
                dataError = #True
                
              ;----- check if company name already exist
              Else 
                
                ForEach dat()
                  If dat()\Company = GetGadgetText(wnd\str_company)
                    MessageRequester(LANGUAGE("DIALOG_ERROR"), LANGUAGE("DIALOG_DATASET_COMPANY_EXIST"))
                    dataError = #True
                    Break
                  EndIf
                Next
                
              EndIf
              
            EndIf
            
            ;----- save only ist there is valid data
            If dataError = #False
              
              If editState = #APP_DATASET_NEW
                ;--- save data into list
                currentId = get_highest_id(dat()) + 1
                
                AddElement(dat())
                dat()\Id        = currentId
                dat()\Company   = GetGadgetText(wnd\str_company)
                dat()\Address   = GetGadgetText(wnd\str_address)
                dat()\Username  = GetGadgetText(wnd\str_username)
                dat()\Email     = GetGadgetText(wnd\str_email)
                dat()\Password  = GetGadgetText(wnd\str_password)
                dat()\Password2 = GetGadgetText(wnd\str_password2)
                dat()\Comment   = GetGadgetText(wnd\str_comment)
                
              ElseIf editState = #APP_DATASET_EDIT
                
                currentID = GetGadgetData(wnd\str_company)
                ForEach dat()
                  If currentId = dat()\Id
                    ;dat()\Company   = GetGadgetText(wnd\str_company)
                    dat()\Address   = GetGadgetText(wnd\str_address)
                    dat()\Username  = GetGadgetText(wnd\str_username)
                    dat()\Email     = GetGadgetText(wnd\str_email)
                    dat()\Password  = GetGadgetText(wnd\str_password)
                    dat()\Password2 = GetGadgetText(wnd\str_password2)
                    dat()\Comment   = GetGadgetText(wnd\str_comment)
                    Break
                  EndIf
                Next
                
              EndIf
              
              ;--- sort list
              SortStructuredList(dat(), #PB_Sort_Ascending, OffsetOf(DATASET\Company), #PB_String)
              
              ;--- set button state
              EnableGadget(wnd\btn_new)
              EnableGadget(wnd\btn_del) : SetGadgetText(wnd\btn_del, LANGUAGE("BTN_DATA_DEL")) : deleteState = #APP_DATASET_DEL
              EnableGadget(wnd\btn_edit)
              DisableGadget(wnd\btn_save, #True)
              data_fields_disabled = #True
              
              ;--- disable gadgets
              main_window_disable_gadgets(wnd, editState)
              
              ;--- set list and data fields
              main_window_set_list(dat(), wnd)
              main_window_sel_list_by_id(dat(), wnd, currentId)
              SetActiveGadget(wnd\lst)
              
              inputChanged = #True
              
              editState = #APP_DATASET_NONE
              
            EndIf
            
            dataError = #False
            
          ;---- click TOGGLE PASSWORD VISIBILITY button
          Case wnd\btn_show
            
            If GetGadgetState(wnd\btn_show)
              ; "LOCK"
              main_window_switch_pwd_gadgets(@wnd, 0, data_fields_disabled)
            Else
              ; "UNLOCK"
              main_window_switch_pwd_gadgets(@wnd, 1, data_fields_disabled)
            EndIf
            
          ;---- click START WEB BROWSER button
          Case wnd\btn_web
            
            If GetGadgetText(wnd\str_address) <> ""
              RunProgram(GetGadgetText(wnd\str_address))
            Else
              info("No web address present.")
            EndIf
            
          ;---- click COPY USERNAME button
          Case wnd\btn_copy_name
            _copy_gadget_to_clipboard(wnd\str_username)
            
          ;---- click COPY E-MAIL button
          Case wnd\btn_copy_mail
            _copy_gadget_to_clipboard(wnd\str_email)
            
          ;---- click COPY PASSWORD button
          Case wnd\btn_copy_pass
            _copy_gadget_to_clipboard(wnd\str_password)
            
          ;---- click CREATE PASSWORD button
          Case wnd\btn_make
            
            If GetGadgetText(wnd\str_password) <> ""
              If MessageRequester(#APP_NAME, LANGUAGE("DIALOG_DATASET_PASSWORD_EXIST"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                SetGadgetText(wnd\str_password, gen_pwd(ini\pw_len, ini\pw_uc, ini\pw_lc, ini\pw_num, ini\pw_special, ini\pw_start))
                SetGadgetText(wnd\str_password2, GetGadgetText(wnd\str_password))
              EndIf
            Else
              SetGadgetText(wnd\str_password, gen_pwd(ini\pw_len, ini\pw_uc, ini\pw_lc, ini\pw_num, ini\pw_special, ini\pw_start))
              SetGadgetText(wnd\str_password2, GetGadgetText(wnd\str_password))
            EndIf
            
          Case wnd\txt_address, wnd\txt_comment, wnd\txt_company, wnd\txt_email, wnd\txt_password, wnd\txt_password2, wnd\txt_username
            ; not used at all
            
          Case wnd\str_address, wnd\str_comment, wnd\str_email, wnd\str_username
            ; not used here, look at function: main_window_gadget_event_cb()
            
          Case wnd\str_company
            If editState = #APP_DATASET_EDIT
              
;               If evtType = #PB_EventType_Change
;                 MessageRequester(LANGUAGE("DIALOG_WARNING"), LANGUAGE("DIALOG_DONT_CHANGE_COMPANY"), #PB_MessageRequester_Warning)
;                 SetGadgetText(wnd\str_company, currentData\Company)
;                 SetActiveGadget(wnd\str_address)
;               EndIf
              
            EndIf
            
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
                SetGadgetColor(wnd\str_password2, #PB_Gadget_BackColor, APP_COLOR_HIGHLIGHT)
              EndIf
            EndIf
            
          Default
            ; unknown/uncatched gadget
            ;info("uncatched gadget #" + Str(evtGadget))
            
        EndSelect
        
      ;--- check timer
      Case #PB_Event_Timer
        
        Select EventTimer()
          Case #app_timer_ID
            ClearClipboard()
            RemoveWindowTimer(wnd\id, #APP_TIMER_ID)
            info("Timer end reached, clipboard cleared.")
          Default
            warn("Unknown timer throws event.")
            
        EndSelect
        
      Default 
        ; uncatched events
        ;info("uncatched window event #" + Str(wndEvt))
        
    EndSelect
    
  Until doLoop = #False
  
  ;-- check for unsaved data
  If inputChanged
    If MessageRequester(#APP_NAME, LANGUAGE("DIALOG_DATABASE_SAVE_CHANGED"), #PB_MessageRequester_Warning|#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      If fileName = ""
        fileName = GetUserDirectory(#PB_Directory_Documents) + "untitled.xml"
        dataType = #APP_DATA_XML
      EndIf
      If dataType = #APP_DATA_NONE
        dataType = #APP_DATA_XML
      EndIf
      If dataType = #APP_DATA_ENCODED
        If xml_save_crypted(fileName, *vector, @cfg, dat())
          MessageRequester(#APP_NAME, LANGUAGE("DIALOG_DATABASE_SAVE_SUCCESS_1") + ": " + fileName + #NL + LANGUAGE("DIALOG_DATABASE_SAVE_SUCCESS_2"), #PB_MessageRequester_Info)
          info("Encoded file saved successfully: '" + fileName + "'.")
        Else
          warn("Can't save encoded file: '" + fileName + "'.")
        EndIf
      ElseIf dataType = #APP_DATA_XML
        If xml_save(fileName, @cfg, dat())
          MessageRequester(#APP_NAME, LANGUAGE("DIALOG_DATABASE_SAVE_SUCCESS_1") + ": " + fileName + #NL + LANGUAGE("DIALOG_DATABASE_SAVE_SUCCESS_2"), #PB_MessageRequester_Info)
          info("XML file saved successfully: '" + fileName + "'.")
        Else
          warn("Can't save XML file: '" + fileName + "'.")
        EndIf
      EndIf
    Else
      warn("File '" + fileName + "' was changed, but didn't saved.")
    EndIf
  EndIf
  
  ;-- save settings
  ini\pos_x = WindowX(wnd\id)
  ini\pos_y = WindowY(wnd\id)
  save_settings(ini)
  
  ;-- end loop
  CloseWindow(wnd\id)
  
  ProcedureReturn errorCode
  
EndProcedure
;- end of main()
;--------------------------------------------------------------------------------
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 798
; FirstLine = 778
; Folding = 0
; EnableXP
; UseIcon = ../res/cryptor_icon.png
; Executable = ..\Cryptor.app
; EnablePurifier
; EnableCompileCount = 108
; EnableBuildCount = 1
; EnableExeConstant
; Constant = #APP_DEFAULT_VECTOR = "047BAC37170DFB3C63226B5646883BB1"