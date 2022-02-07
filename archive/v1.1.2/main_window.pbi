﻿;  * CRYPTOR;  *;  * main_window.pbi;  *;- workaround for MenuItem() and #PB_AnyEnumeration 11  #MNU_FILE_NEW  #MNU_FILE_OPEN  #MNU_FILE_SAVE  #MNU_FILE_SAVEAS  #MNU_FILE_ENC_SAVE  #MNU_FILE_ENC_SAVEAS  #MNU_FILE_CLOSE  #MNU_FILE_QUIT  #MNU_HELP_ABOUTEndEnumeration;- main window menu structureStructure MAIN_WINDOW_MENU  id.i  file_new.i  file_open.i  file_save.i  file_save_as.i  file_encrypted_save.i  file_encrypted_save_as.i  file_close.i  file_quit.i  help_about.iEndStructure;- main window structureStructure MAIN_WINDOW  id.i  mnu.MAIN_WINDOW_MENU  stb.i  lst.i  cnt.i  scr.i  txt_company.i  str_company.i  txt_address.i  str_address.i  txt_username.i  str_username.i  txt_email.i  str_email.i  txt_password.i  str_password.i  txt_password2.i  str_password2.i  txt_comment.i  str_comment.i  btn_new.i  btn_edit.i  btn_save.i  btn_del.iEndStructure; only for testing purposes, leave commented; Global v_main_window.MAIN_WINDOW ;: InitializeStructure(@v_main_window, MAIN_WINDOW);- macrosMacro _main_window_clear_data(ptr)  SetGadgetText(ptr\str_address,   "")  SetGadgetText(ptr\str_comment,   "")  SetGadgetText(ptr\str_company,   "")  SetGadgetText(ptr\str_email,     "")  SetGadgetText(ptr\str_password,  "")  SetGadgetText(ptr\str_password2, "")  SetGadgetText(ptr\str_username,  "")EndMacroMacro _main_window_enable_data(ptr)  DisableGadget(ptr\str_address,   #False)  ;DisableGadget(ptr\str_comment,   #False) ; this doesn't work for the edit gadget  SetGadgetAttribute(ptr\str_comment, #PB_Editor_ReadOnly, 0)  DisableGadget(ptr\str_company,   #False)  DisableGadget(ptr\str_email,     #False)  DisableGadget(ptr\str_password,  #False)  DisableGadget(ptr\str_password2, #False)  DisableGadget(ptr\str_username,  #False)  SetActiveGadget(ptr\str_company)EndMacroMacro _main_window_disable_data(ptr)  DisableGadget(ptr\str_address,   #True)  ;DisableGadget(ptr\str_comment,   #True) ; this doesn't work for the edit gadget  SetGadgetAttribute(ptr\str_comment, #PB_Editor_ReadOnly, 1)  DisableGadget(ptr\str_company,   #True)  DisableGadget(ptr\str_email,     #True)  DisableGadget(ptr\str_password,  #True)  DisableGadget(ptr\str_password2, #True)  DisableGadget(ptr\str_username,  #True)  SetGadgetColor(ptr\str_address,   #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(ptr\str_comment,   #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(ptr\str_company,   #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(ptr\str_email,     #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(ptr\str_password,  #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(ptr\str_password2, #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(ptr\str_username,  #PB_Gadget_BackColor, #PB_Default)  SetActiveGadget(ptr\lst)EndMacro;- function declarationsDeclare main_window_set_list( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_get_dataset( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_set_dataset( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_new_dataset( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_edit_dataset( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_save_dataset( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_delete_dataset( List d.DATASET() , *w.MAIN_WINDOW )Declare main_window_gadget_event_cb() ; this is the callback for nicier input gadgetsDeclare main_window_resize( *w.MAIN_WINDOW ) ; unsure if needed in future;- the main windowProcedure.i main_window_open( *w.MAIN_WINDOW )    With *w        If IsWindow(\id)      warn("main window already open")      ProcedureReturn 0    EndIf        \id = OpenWindow(#PB_Any, #PB_Ignore, #PB_Ignore, #APP_WINDOW_WIDTH, #APP_WINDOW_HEIGHT, #APP_NAME, #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_Invisible)    If IsWindow(\id)            \mnu\id = CreateMenu(#PB_Any, WindowID(\id))      If IsMenu(\mnu\id)                CompilerIf #PB_Compiler_OS = #PB_OS_Windows                    MenuTitle("File")          \mnu\file_new = MenuItem(#PB_Any, "New")          MenuBar()          \mnu\file_open = MenuItem(#PB_Any, "Open" + "...")          MenuBar()          ; -------------------------------          ; remove it in final version          \mnu\file_save = MenuItem(#PB_Any, "Save" + "(XML)")          \mnu\file_save_as = MenuItem(#PB_Any, "Save as" + "(XML)" + "...")          MenuBar()          ; -------------------------------          \mnu\file_encrypted_save = MenuItem(#PB_Any, "Save encrypted")          \mnu\file_encrypted_save_as = MenuItem(#PB_Any, "Save as enctrypted" + "...")          MenuBar()          \mnu\file_close = MenuItem(#PB_Any, "Close")          MenuBar()          \mnu\file_quit = MenuItem(#PB_Any, "Quit")          MenuTitle("Help")          \mnu\help_about = MenuItem(#PB_Any, "About" + Space(1) + #APP_NAME)        CompilerElse                    \mnu\file_new               = #MNU_FILE_NEW          \mnu\file_open              = #MNU_FILE_OPEN          \mnu\file_save              = #MNU_FILE_SAVE          \mnu\file_save_as           = #MNU_FILE_SAVEAS          \mnu\file_encrypted_save    = #MNU_FILE_ENC_SAVE          \mnu\file_encrypted_save_as = #MNU_FILE_ENC_SAVEAS          \mnu\file_close             = #MNU_FILE_CLOSE                    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS                        \mnu\file_quit = #PB_Menu_Quit            \mnu\help_about = #PB_Menu_About                      CompilerElse                        \mnu\file_quit = #MNU_FILE_QUIT            \mnu\help_about = #MNU_HELP_ABOUT                      CompilerEndIf                    MenuTitle("File")          MenuItem(\mnu\file_new, "New")          MenuBar()          MenuItem(\mnu\file_open, "Open" + "...")          MenuBar()          ; -------------------------------          ; remove it in final version          MenuItem(\mnu\file_save, "Save" + "(XML)")          MenuItem(\mnu\file_save_as, "Save as" + "(XML)" + "...")          MenuBar()          ; -------------------------------          MenuItem(\mnu\file_encrypted_save, "Save encrypted")          MenuItem(\mnu\file_encrypted_save_as, "Save as enctrypted" + "...")          MenuBar()          MenuItem(\mnu\file_close, "Close")                    CompilerIf #PB_Compiler_OS <> #PB_OS_MacOS            MenuBar()            MenuItem(\mnu\file_quit, "Quit")            MenuTitle("Help")            MenuItem(\mnu\help_about, "About" + Space(1) + #APP_NAME)          CompilerEndIf                  CompilerEndIf              Else        warn("can't create menu")        CloseWindow(\id)        ProcedureReturn 0      EndIf            \stb = CreateStatusBar(#PB_Any, WindowID(\id))      If IsStatusBar(\stb)        AddStatusBarField(30)        AddStatusBarField(#PB_Ignore)      Else        warn("can't create statusbar")        CloseWindow(\id)        ProcedureReturn 0      EndIf            \lst = ListViewGadget(#PB_Any, 10, 10, 200, WindowHeight(\id) - MenuHeight() - StatusBarHeight(\stb) - 20)            ; here begins the container      \cnt = ContainerGadget(#PB_Any, GadgetX(\lst) + GadgetWidth(\lst) + 10, 10, WindowWidth(\id) - GadgetWidth(\lst) - 30, GadgetHeight(\lst))      ; here begins the scroll area      \scr = ScrollAreaGadget(#PB_Any, 5, 5, GadgetWidth(\cnt)-10, GadgetHeight(\cnt) - #APP_BUTTON_HEIGHT - 30, GadgetWidth(\cnt)-40, GadgetHeight(\cnt)-#APP_BUTTON_HEIGHT*2, 10)      ; -------------------------------      Protected.l w_cnt = GadgetWidth(\cnt)-40      \txt_company   = TextGadget(#PB_Any,     0,   5, w_cnt,          20, "Company or Website name" + ":", #PB_Text_Center)      Protected.l w_txt_c = GadgetWidth(\txt_company)-10      \str_company   = StringGadget(#PB_Any,  10,  40, w_txt_c,  20, "")      w_txt_c = GadgetWidth(\txt_company)-120      \txt_address   = TextGadget(#PB_Any,    10,  70, 140,     20, "Homepage" + ":")      \str_address   = StringGadget(#PB_Any, 150,  70, w_txt_c, 20, "")      \txt_username  = TextGadget(#PB_Any,    10, 100, 140,     20, "Username" + ":")      \str_username  = StringGadget(#PB_Any, 150, 100, w_txt_c, 20, "")      \txt_email     = TextGadget(#PB_Any,    10, 130, 140,     20, "E-Mail" + ":")      \str_email     = StringGadget(#PB_Any, 150, 130, w_txt_c, 20, "")      \txt_password  = TextGadget(#PB_Any,    10, 160, 140,     20, "Password" + ":")      \str_password  = StringGadget(#PB_Any, 150, 160, w_txt_c, 20, "")      \txt_password2 = TextGadget(#PB_Any,    10, 190, 140,     20, "retype " + "Password" + ":")      \str_password2 = StringGadget(#PB_Any, 150, 190, w_txt_c, 20, "")      \txt_comment   = TextGadget(#PB_Any,    10, 220, w_cnt,   20, "Comments" + ":")      w_txt_c = GadgetWidth(\txt_company)-10      \str_comment   = EditorGadget(#PB_Any,  10, 250, w_txt_c, 120, #PB_Editor_WordWrap)      ; -------------------------------      CloseGadgetList()      ; here we are back in the container       \btn_del = ButtonGadget(#PB_Any, 10, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, "Delete Dataset")            \btn_new = ButtonGadget(#PB_Any, GadgetWidth(\cnt) - #APP_BUTTON_WIDTH - 10, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, "New Dataset")      \btn_edit = ButtonGadget(#PB_Any, GadgetX(\btn_new) - #APP_BUTTON_WIDTH - 10, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, "Edit Dataset")      \btn_save = ButtonGadget(#PB_Any, GadgetX(\btn_edit) - #APP_BUTTON_WIDTH - 10, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, "Save Dataset")      CloseGadgetList()      ; container closed            ; -------------------------------;       \btn_add = main_window_add_new_sheet(\scr, \btn_add, \dat());       SetGadgetState(\dat()\cmb_type, 0);       SetGadgetText(\dat()\str_desc, #APP_DATATYPE_USER);       \btn_add = main_window_add_new_sheet(\scr, \btn_add, \dat());       SetGadgetState(\dat()\cmb_type, 2);       SetGadgetText(\dat()\str_desc, #APP_DATATYPE_PASSWD)      ; -------------------------------            _main_window_disable_data(*w)            DisableGadget(\btn_del, #True)      DisableGadget(\btn_edit, #True)      DisableGadget(\btn_save, #True)            SetActiveGadget(\btn_new)            BindEvent(#PB_Event_Gadget, @main_window_gadget_event_cb(), \id)            ;HideWindow(\id, #False)          Else      warn("can't create main window")      ProcedureReturn 0    EndIf      EndWith    ProcedureReturn *w\id  EndProcedure;- additional needed functions for the windowProcedure main_window_gadget_event_cb()  Select EventType()    Case #PB_EventType_Focus      SetGadgetColor(EventGadget(), #PB_Gadget_BackColor, RGB(80, 128, 80))    Case #PB_EventType_LostFocus      SetGadgetColor(EventGadget(), #PB_Gadget_BackColor, #PB_Default)  EndSelectEndProcedureProcedure main_window_resize( *w.MAIN_WINDOW )  EndProcedureProcedure main_window_set_list( List d.DATASET() , *w.MAIN_WINDOW )  Protected.l i = 0  With *w    If CountGadgetItems(\lst) > 0      ClearGadgetItems(\lst)    EndIf    SortStructuredList(d(), #PB_Sort_Ascending, OffsetOf(DATASET\company), #PB_String)    ForEach d()      AddGadgetItem(\lst, i, d()\company)      SetGadgetItemData(\lst, i, d()\id)      i+1    Next  EndWithEndProcedure; Procedure main_window_clear_dataset( List d.DATASET() , *w.MAIN_WINDOW );     With *w;       SetGadgetText(\str_address,   "");       SetGadgetText(\str_comment,   "");       SetGadgetText(\str_company,   "");       SetGadgetText(\str_email,     "");       SetGadgetText(\str_password,  "");       SetGadgetText(\str_password2, "");       SetGadgetText(\str_username,  "");     EndWith; EndProcedure; Procedure main_window_show_dataset( List d.DATASET() , *w.MAIN_WINDOW );   If ListSize(d()) > 0;     With *w;       SetGadgetText(\str_address,   d()\address);       SetGadgetText(\str_comment,   d()\comment);       SetGadgetText(\str_company,   d()\company);       SetGadgetText(\str_email,     d()\email);       SetGadgetText(\str_password,  d()\password);       SetGadgetText(\str_password2, d()\password2);       SetGadgetText(\str_username,  d()\username);     EndWith;   Else;     main_window_clear_dataset(d(), *w);   EndIf; EndProcedureProcedure main_window_delete_dataset( List d.DATASET() , *w.MAIN_WINDOW )  If ListSize(d()) > 0    ;DeleteElement(d(), 1)  EndIf  With *w    DisableGadget(\btn_new, #False)    If ListSize(d()) > 0      DisableGadget(\btn_del, #False)      DisableGadget(\btn_edit, #False)    Else      DisableGadget(\btn_del, #True)      DisableGadget(\btn_edit, #True)    EndIf    DisableGadget(\btn_save, #True)  EndWith  main_window_set_dataset(d(), *w)  _main_window_disable_data(*w)EndProcedureProcedure main_window_save_dataset( List d.DATASET() , *w.MAIN_WINDOW )  With *w    DisableGadget(\btn_new, #False)    DisableGadget(\btn_del, #False)    DisableGadget(\btn_edit, #False)    DisableGadget(\btn_save, #True)  EndWith  main_window_get_dataset(d(), *w)  main_window_set_list(d(), *w)  _main_window_disable_data(*w)EndProcedureProcedure main_window_edit_dataset( List d.DATASET() , *w.MAIN_WINDOW )  With *w    DisableGadget(\btn_new, #True)    DisableGadget(\btn_del, #True)    DisableGadget(\btn_edit, #True)    DisableGadget(\btn_save, #False)  EndWith  _main_window_enable_data(*w)EndProcedureProcedure main_window_new_dataset( List d.DATASET() , *w.MAIN_WINDOW )  With *w    DisableGadget(\btn_new, #True)    DisableGadget(\btn_del, #True)    DisableGadget(\btn_edit, #True)    DisableGadget(\btn_save, #False)  EndWith  _main_window_enable_data(*w)  _main_window_clear_data(*w)  ;main_window_clear_dataset(d(), *w)EndProcedureProcedure main_window_get_dataset( List d.DATASET() , *w.MAIN_WINDOW )  With *w    AddElement(d())    d()\address   = GetGadgetText(\str_address)    d()\comment   = GetGadgetText(\str_comment)    d()\company   = GetGadgetText(\str_company)    d()\email     = GetGadgetText(\str_email)    d()\password  = GetGadgetText(\str_password)    d()\password2 = GetGadgetText(\str_password2)    d()\username  = GetGadgetText(\str_username)    d()\id        = ListSize(d())  EndWithEndProcedureProcedure main_window_set_dataset( List d.DATASET() , *w.MAIN_WINDOW )  ;main_window_clear_dataset(d(), *w)  _main_window_clear_data(*w)  With *w    SetGadgetText(\str_address,   d()\address)    SetGadgetText(\str_comment,   d()\comment)    SetGadgetText(\str_company,   d()\company)    SetGadgetText(\str_email,     d()\email)    SetGadgetText(\str_password,  d()\password)    SetGadgetText(\str_password2, d()\password2)    SetGadgetText(\str_username,  d()\username)  EndWithEndProcedure; IDE Options = PureBasic 5.71 LTS (MacOS X - x64); CursorPosition = 370; FirstLine = 150; Folding = w--; EnableXP; UseMainFile = main.pb; CompileSourceDirectory; EnablePurifier; EnableCompileCount = 0; EnableBuildCount = 0; EnableExeConstant