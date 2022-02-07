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
;  * MERCHANTABILITY Or FITNESS for A PARTICULAR PURPOSE.  See the
;  * GNU General Public License for more details.
;  *
;  * You should have received a copy of the GNU General Public License
;  * along with this program; if not, write to the Free Software
;  * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;  * MA 02110-1301, USA.
;  *

EnableExplicit

XIncludeFile "header.pbi"

; -----------------------------------------------
;- macros
Macro _free_xml(ptr)
  FreeXML(ptr\id)
  prt\xml  = 0
  ptr\root = 0
  ptr\cfg  = 0
  ptr\dat  = 0
EndMacro
Macro _click_mnu_new()
  
  If fileName <> #Null$
    fileName = #Null$
  EndIf
  
  If IsXML(xml\id)
    FreeXML(xml\id)
    info("XML file was already open, cleared memory.")
  EndIf
  
  If ListSize(dat()) > 0
    ClearList(dat())
  EndIf
  
  xml_create_new(@xml)
  
  SetWindowTitle(wnd\id, #APP_NAME + " - " + "untitled.xml" + " [*]") : inputChanged = #True
  
  info("created new and clean XML database.")
  
EndMacro
Macro _click_mnu_open()
  
  lastFileName = fileName
  fileName = OpenFileRequester("Choose file" + "...", "*.xml", "XML file (*.xml)|*.xml", 0)
  
  If fileName = ""
    
    info("open file requester aborted.")
    
    fileName = lastFileName
    
  Else
    
    xml\id = xml_load(fileName)
    If xml\id <> 0
      
      If xml_parse(dat(), xml) <> 0 
        
        main_window_set_list(dat(), wnd)
        
        FirstElement(dat())
        SetGadgetItemState(wnd\lst, 0, 1)
        
        main_window_set_dataset(dat(), wnd)
        
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
        
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
    
    If xml_create_database(dat(), @xml)
      
      If xml_save(xml\id, fileName, #True)
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
        info("XML file saved successfully: '" + fileName + "'.")
      Else
        warn("can't save XML file: '" + fileName + "'.")
      EndIf
      
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
Macro _click_mnu_save()
  
  If fileName <> #Null$
    
    If xml_create_database(dat(), @xml)
      
      If xml_save(xml\id, fileName, #True)
        SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
        info("XML file saved successfully: '" + fileName + "'.")
      Else
        warn("can't save XML file: '" + fileName + "'.")
      EndIf
      
    EndIf
    
    SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName) : inputChanged = #False
    
  Else
    
    MessageRequester(#APP_NAME, "The XML database is new and wasn't seved before." + #NL + "Select a new name And directory in the following dialog.", #PB_MessageRequester_Info)
    _click_mnu_saveas()
    
  EndIf
  
EndMacro
Macro _click_mnu_enc_save()
  
EndMacro
Macro _click_mnu_enc_saveas()
  
EndMacro
Macro _click_mnu_close()
  
EndMacro
Macro _click_mnu_about()
  
EndMacro
; -----------------------------------------------

Define.l RESULT = Main( CountProgramParameters() )
logger("program closed", #APP_LOGTYPE_INFO)
End RESULT

; -----------------------------------------------
;- main() function
Procedure.l main( argc.l=0 )
  
  Protected.b doLoop = #True, errorCode = 0, inputChanged = #False
  Protected.i wndEvt, evtMenu, evtGadget, evtType, *vector, *key
  Protected.s fileName, lastFileName
  
  Protected.MAIN_WINDOW wnd
  Protected.XML_NODES xml
  
  NewList dat.DATASET()
  
  *key    = AllocateMemory(#APP_BYTE_SIZE)
  *vector = AllocateMemory(#APP_BYTE_SIZE)
  
  ; ---------------------------------------------
  ;- open window
  main_window_open(@wnd)
  
  ; ---------------------------------------------
  ;- test for program parameters
  If argc > 0
    
    fileName = ProgramParameter()
    
    If FileSize(fileName) < 0
      
      MessageRequester(#APP_NAME, "The file:" + #NL + fileName + #NL + "did not exist or you have insufficient rights to open it.", #PB_MessageRequester_Warning)
      warn("program arg '" + fileName + "' was set, but file did not exist.")
      fileName = #Null$
      
    Else
      
      info("program arg '" + fileName + "' was set.")
      
      xml\id = xml_load(fileName)
      If xml\id = 0
        
        MessageRequester(#APP_NAME, "The file:" + #NL + fileName + #NL + "can't be opened or you have insufficient rights to open it.", #PB_MessageRequester_Info)
        warn("can't open the file '" + fileName + "'.")
        fileName = #Null$
        
      Else
        
        If xml_parse(dat(), @xml) = 0
          
          MessageRequester(#APP_NAME, "The file:" + #NL + fileName + #NL + "can't be parsed, it is not valid.", #PB_MessageRequester_Info)
          warn("can't parse file '" + fileName + "'.")
          fileName = #Null$
          
          FreeXML(xml\id)
          
        Else
          
          main_window_set_list(dat(), @wnd)
          
          FirstElement(dat())
          SetGadgetItemState(wnd\lst, 0, 1)
          
          main_window_set_dataset(dat(), @wnd)
          
        EndIf
        
      EndIf
      
    EndIf
    
    If fileName <> #Null$
      SetWindowTitle(wnd\id, #APP_NAME + " - " + fileName)
    EndIf
    
  EndIf
  
  ; ---------------------------------------------
  ;- begin loop
  HideWindow(wnd\id, #False)
  
  Repeat
    
    wndEvt = WaitWindowEvent()
    
    Select wndEvt
        
      ; ---------------------------------------------
      ;- default window events
      Case #PB_Event_CloseWindow
        doLoop = #False
        
      ; ---------------------------------------------
      ;- check menu
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
            
          Case wnd\mnu\file_encrypted_save
            _click_mnu_enc_save()
            
          Case wnd\mnu\file_encrypted_save_as
            _click_mnu_enc_saveas()
            
          Case wnd\mnu\file_close
            _click_mnu_close()
            
          Case wnd\mnu\file_quit
            doLoop = #False
            
          Case wnd\mnu\help_about
            _click_mnu_about()
            
        EndSelect
        
      ; ---------------------------------------------
      ;- check gadgets
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
            
          Case wnd\btn_new
            main_window_new_dataset(dat(), @wnd)
            
          Case wnd\btn_edit
            main_window_edit_dataset(dat(), @wnd)
            
          Case wnd\btn_del
            main_window_delete_dataset(dat(), @wnd)
            
          Case wnd\btn_save
            main_window_save_dataset(dat(), @wnd)
            
          Default
            ; unknown/uncatched gadget
            info("uncatched gadget event #" + Str(evtGadget))
            
        EndSelect
        
      Default 
        ; uncatched events
        
    EndSelect
    
  Until doLoop = #False
  
  ; ---------------------------------------------
  ;- end loop
  CloseWindow(wnd\id)
  
  ProcedureReturn errorCode
  
EndProcedure

; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 30
; FirstLine = 16
; Folding = --
; EnableXP
; UseIcon = icons/cryptor_icon.png
; CommandLine = testfile.xml
; CompileSourceDirectory
; EnablePurifier
; EnableCompileCount = 106
; EnableBuildCount = 0
; EnableExeConstant