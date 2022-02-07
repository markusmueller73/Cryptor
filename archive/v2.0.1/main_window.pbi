﻿;  * CRYPTOR;  *;  * main_window.pbi;  *;-------------------------------------------------;- workaround for MenuItem() and #PB_AnyEnumeration 11  #MNU_FILE_NEW  #MNU_FILE_OPEN  #MNU_FILE_SAVE  #MNU_FILE_SAVEAS  #MNU_FILE_ENC_SAVE  #MNU_FILE_ENC_SAVEAS  #MNU_FILE_PRINT  #MNU_FILE_CLOSE  #MNU_FILE_QUIT  #MNU_HELP_ABOUTEndEnumeration;-------------------------------------------------;- main window imagesStructure MAIN_WINDOW_IMAGES  app.i  show.i  hide.i  web.i  copy.i  makepwd.i  locked.i  unlocked.i  new.i  open.i  close.i  save.i  save_as_xml.i  save_as_enc.i  print.i  quit.i  about.iEndStructure;- main window menu structureStructure MAIN_WINDOW_MENU  id.i  file_new.i  file_open.i  file_save.i  file_save_as.i  file_encrypted_save_as.i  file_print.i  file_close.i  file_quit.i  help_about.iEndStructure;- main window structureStructure MAIN_WINDOW  id.i  mnu.MAIN_WINDOW_MENU  stb.i  lst.i  cnt.i  scr.i  txt_company.i  str_company.i  txt_address.i  str_address.i  txt_username.i  str_username.i  txt_email.i  str_email.i  txt_password.i  str_password.i  txt_password2.i  str_password2.i  txt_comment.i  str_comment.i  btn_show.i  btn_web.i  btn_copy_pass.i  btn_copy_name.i  btn_copy_mail.i  btn_make.i  btn_new.i  btn_edit.i  btn_save.i  btn_del.i  img.MAIN_WINDOW_IMAGESEndStructure; only for testing purposes, leave commented; Global v_main_window.MAIN_WINDOW ;: InitializeStructure(@v_main_window, MAIN_WINDOW);-------------------------------------------------;- global varsGlobal.i APP_COLOR_HIGHLIGHT;-------------------------------------------------;- function declarationsDeclare.l get_system_hilite_color()Declare   main_window_load_icons ( *img.MAIN_WINDOW_IMAGES )Declare   main_window_gadget_event_cb() ; this is the callback for nicier input gadgetsDeclare   main_window_resize( *w.MAIN_WINDOW ) ; unsure if needed in future;-------------------------------------------------;- the main windowProcedure.i main_window_open( *w.MAIN_WINDOW , X.l = #PB_Ignore , Y.l = #PB_Ignore )    Protected.l flags, n    ;-- set window flags  flags = #PB_Window_MinimizeGadget ; #PB_Window_SizeGadget    With *w        If IsWindow(\id)      warn("Main window already open.")      ProcedureReturn 0    EndIf        main_window_load_icons(*w\img)        ;-- create window    \id = OpenWindow(#PB_Any, X, Y, #APP_WINDOW_WIDTH, #APP_WINDOW_HEIGHT, #APP_NAME, #PB_Window_SystemMenu|#PB_Window_Invisible|flags)    If IsWindow(\id)            ;--- create menu      \mnu\id = CreateImageMenu(#PB_Any, WindowID(\id))      If IsMenu(\mnu\id)                \mnu\file_new               = #MNU_FILE_NEW        \mnu\file_open              = #MNU_FILE_OPEN        \mnu\file_save              = #MNU_FILE_SAVE        \mnu\file_save_as           = #MNU_FILE_SAVEAS        \mnu\file_encrypted_save_as = #MNU_FILE_ENC_SAVEAS        \mnu\file_print             = #MNU_FILE_PRINT        \mnu\file_close             = #MNU_FILE_CLOSE        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS          \mnu\file_quit = #PB_Menu_Quit          \mnu\help_about = #PB_Menu_About        CompilerElse          \mnu\file_quit = #MNU_FILE_QUIT          \mnu\help_about = #MNU_HELP_ABOUT        CompilerEndIf                MenuTitle(LANGUAGE("MENU_FILE"))        MenuItem(\mnu\file_new, LANGUAGE("MENU_FILE_NEW"), ImageID(\img\new))        MenuBar()        MenuItem(\mnu\file_open, LANGUAGE("MENU_FILE_OPEN") + "...", ImageID(\img\open))        MenuBar()        MenuItem(\mnu\file_save, LANGUAGE("MENU_FILE_SAVE"), ImageID(\img\save))        ; -------------------------------        ; remove it in final version        MenuItem(\mnu\file_save_as, LANGUAGE("MENU_FILE_SAVE_AS") + "...", ImageID(\img\save_as_xml))        ; -------------------------------        MenuItem(\mnu\file_encrypted_save_as, LANGUAGE("MENU_FILE_SAVE_AS_ENC") + "...", ImageID(\img\save_as_enc))        MenuBar()        MenuItem(\mnu\file_print, LANGUAGE("MENU_FILE_PRINT") + "...", ImageID(\img\print))        MenuBar()        MenuItem(\mnu\file_close, LANGUAGE("MENU_FILE_CLOSE"), ImageID(\img\close))                CompilerIf #PB_Compiler_OS = #PB_OS_MacOS          MenuItem(\mnu\file_quit, LANGUAGE("MENU_FILE_QUIT"))          MenuItem(\mnu\help_about, LANGUAGE("MENU_HELP_ABOUT") + Space(1) + #APP_NAME)        CompilerElse          MenuBar()          MenuItem(\mnu\file_quit, LANGUAGE("MENU_FILE_QUIT"), ImageID(\img\quit))          MenuTitle(LANGUAGE("MENU_HELP"))          MenuItem(\mnu\help_about, LANGUAGE("MENU_HELP_ABOUT") + Space(1) + #APP_NAME, ImageID(\img\about))        CompilerEndIf              Else        warn("Can't create menu.")        CloseWindow(\id)        ProcedureReturn 0      EndIf            ;--- create statusbar      \stb = CreateStatusBar(#PB_Any, WindowID(\id))      If IsStatusBar(\stb)        AddStatusBarField(30)        AddStatusBarField(#PB_Ignore)      Else        warn("Can't create statusbar.")        CloseWindow(\id)        ProcedureReturn 0      EndIf            ;--- create list      \lst = ListViewGadget(#PB_Any, 10, 10, 200, WindowHeight(\id) - MenuHeight() - StatusBarHeight(\stb) - 20)            ;--- here begins the container      \cnt = ContainerGadget(#PB_Any, GadgetX(\lst) + GadgetWidth(\lst) + 10, 10, WindowWidth(\id) - GadgetWidth(\lst) - 30, GadgetHeight(\lst))      ;---- here begins the scroll area      \scr = ScrollAreaGadget(#PB_Any, 5, 5, GadgetWidth(\cnt)-10, GadgetHeight(\cnt) - #APP_BUTTON_HEIGHT - 20, GadgetWidth(\cnt)-40, GadgetHeight(\cnt)-#APP_BUTTON_HEIGHT*2, 10)            Protected.l w_cnt = GadgetWidth(\cnt)-40      \txt_company   = TextGadget(#PB_Any,     0,   5, w_cnt,   20, LANGUAGE("TXT_DATA_COMPANY") + ":", #PB_Text_Center)            Protected.l w_txt_c = GadgetWidth(\txt_company)-10      \str_company   = StringGadget(#PB_Any,  10,  40, w_txt_c, 20, "", #PB_Text_Center)      w_txt_c = GadgetWidth(\txt_company)-150            \txt_address   = TextGadget(#PB_Any,    10,  70, 140,     20, LANGUAGE("TXT_DATA_HOMEPAGE") + ":")      \str_address   = StringGadget(#PB_Any, 150,  70, w_txt_c-50, 20, "")            \txt_username  = TextGadget(#PB_Any,    10, 100, 140,     20, LANGUAGE("TXT_DATA_USERNAME") + ":")      \str_username  = StringGadget(#PB_Any, 150, 100, w_txt_c-50, 20, "")            \txt_email     = TextGadget(#PB_Any,    10, 130, 140,     20, LANGUAGE("TXT_DATA_EMAIL") + ":")      \str_email     = StringGadget(#PB_Any, 150, 130, w_txt_c-50, 20, "")            \txt_password  = TextGadget(#PB_Any,    10, 160, 140,     20, LANGUAGE("TXT_DATA_PASSWORD") + ":")      \str_password  = StringGadget(#PB_Any, 150, 160, w_txt_c-100, 20, "", #PB_String_Password)            \txt_password2 = TextGadget(#PB_Any,    10, 190, 140,     20, LANGUAGE("TXT_DATA_PASSWORD2") + ":")      \str_password2 = StringGadget(#PB_Any, 150, 190, w_txt_c-100, 20, "", #PB_String_Password)            \txt_comment   = TextGadget(#PB_Any,    10, 220, w_cnt,   20, LANGUAGE("TXT_DATA_COMMENT") + ":")            w_txt_c = GadgetWidth(\txt_company)-10      ;\str_comment   = EditorGadget(#PB_Any,  10, 250, w_txt_c, 120, #PB_Editor_WordWrap)      \str_comment   = TextGadget(#PB_Any,  10, 250, w_txt_c, 120, "", #PB_Text_Border)            \btn_web = ButtonImageGadget(#PB_Any, GadgetX(\str_address)+GadgetWidth(\str_address)+15, GadgetY(\str_address)-2, 24, 24, ImageID(\img\web))            \btn_copy_name = ButtonImageGadget(#PB_Any, GadgetX(\str_username)+GadgetWidth(\str_username)+15, GadgetY(\str_username)-2, 24, 24, ImageID(\img\copy))      \btn_copy_mail = ButtonImageGadget(#PB_Any, GadgetX(\str_email)+GadgetWidth(\str_email)+15, GadgetY(\str_email)-2, 24, 24, ImageID(\img\copy))            \btn_copy_pass = ButtonImageGadget(#PB_Any, GadgetX(\str_password)+GadgetWidth(\str_password)+15, GadgetY(\str_password)-2, 24, 24, ImageID(\img\copy))      \btn_make      = ButtonImageGadget(#PB_Any, GadgetX(\str_password)+GadgetWidth(\str_password)+15, GadgetY(\str_password2)-2, 24, 24, ImageID(\img\makepwd))            \btn_show      = ButtonImageGadget(#PB_Any, GadgetX(\str_password)+GadgetWidth(\str_password)+55, GadgetY(\str_password), 45, 50, 0, #PB_Button_Toggle)      SetGadgetAttribute(\btn_show, #PB_Button_Image, ImageID(\img\show))      SetGadgetAttribute(\btn_show, #PB_Button_PressedImage, ImageID(\img\hide))      SetGadgetState(\btn_show, #True)            CloseGadgetList()      ;---- end of scroll area      ;--- here we are back in the container       \btn_del = ButtonGadget(#PB_Any, 0, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, LANGUAGE("BTN_DATA_DEL"))            \btn_new = ButtonGadget(#PB_Any, GadgetWidth(\cnt) - #APP_BUTTON_WIDTH, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, LANGUAGE("BTN_DATA_NEW"))      \btn_edit = ButtonGadget(#PB_Any, GadgetX(\btn_new) - #APP_BUTTON_WIDTH - 3, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, LANGUAGE("BTN_DATA_EDIT"))      \btn_save = ButtonGadget(#PB_Any, GadgetX(\btn_edit) - #APP_BUTTON_WIDTH - 3, GadgetY(\scr) + GadgetHeight(\scr) + 10, #APP_BUTTON_WIDTH, #APP_BUTTON_HEIGHT, LANGUAGE("BTN_DATA_SAVE"))      CloseGadgetList()      ;--- container closed            ;--- generate tooltips      GadgetToolTip(\btn_web, LANGUAGE("TOOLTIP_DATA_START_BROWSER"))      GadgetToolTip(\btn_show, LANGUAGE("TOOLTIP_DATA_SHOW_PASSWORD"))      GadgetToolTip(\btn_copy_name, LANGUAGE("TOOLTIP_DATA_COPY_USERNAME"))      GadgetToolTip(\btn_copy_mail, LANGUAGE("TOOLTIP_DATA_COPY_EMAIL"))      GadgetToolTip(\btn_copy_pass, LANGUAGE("TOOLTIP_DATA_COPY_PASSWORD"))      GadgetToolTip(\btn_make, LANGUAGE("TOOLTIP_DATA_GENERATE_PASSWORD"))            ;--- disable the string gadgets      DisableGadget(\str_address,   #True)      DisableGadget(\str_company,   #True)      DisableGadget(\str_email,     #True)      DisableGadget(\str_password,  #True)      DisableGadget(\str_password2, #True)      DisableGadget(\str_username,  #True)      DisableGadget(\btn_make,      #True)      SetGadgetAttribute(\str_comment, #PB_Editor_ReadOnly, #True)            ;--- disable the button gadgets      DisableGadget(\btn_del, #True)      DisableGadget(\btn_edit, #True)      DisableGadget(\btn_save, #True)      DisableGadget(\btn_new, #True)            SetActiveGadget(\btn_new)            APP_COLOR_HIGHLIGHT = get_system_hilite_color()            BindEvent(#PB_Event_Gadget, @main_window_gadget_event_cb(), \id)          Else      warn("Can't create main window.")      ProcedureReturn 0    EndIf      EndWith    ProcedureReturn *w\id  EndProcedure;- callback function for the string gadgetsProcedure main_window_gadget_event_cb()  Select EventType()    Case #PB_EventType_Focus      SetGadgetColor(EventGadget(), #PB_Gadget_BackColor, APP_COLOR_HIGHLIGHT)    Case #PB_EventType_LostFocus      SetGadgetColor(EventGadget(), #PB_Gadget_BackColor, #PB_Default)  EndSelectEndProcedure;- additional needed functions for the windowProcedure main_window_resize( *w.MAIN_WINDOW )  EndProcedureProcedure main_window_load_icons ( *img.MAIN_WINDOW_IMAGES )  With *img    \app          = CatchImage(#PB_Any, ?ICON_APP)    \hide         = CatchImage(#PB_Any, ?ICON_HIDE)    \show         = CatchImage(#PB_Any, ?ICON_SHOW)    \web          = CatchImage(#PB_Any, ?ICON_WEB)    \copy         = CatchImage(#PB_Any, ?ICON_COPY)    \makepwd      = CatchImage(#PB_Any, ?ICON_MAKEPWD)    \new          = CatchImage(#PB_Any, ?ICON_NEW)    \open         = CatchImage(#PB_Any, ?ICON_OPEN)    \save         = CatchImage(#PB_Any, ?ICON_SAVE)    \save_as_xml  = CatchImage(#PB_Any, ?ICON_SAVEAS)    \save_as_enc  = CatchImage(#PB_Any, ?ICON_SAVEAS_ENC)    \close        = CatchImage(#PB_Any, ?ICON_CLOSE)    \print        = CatchImage(#PB_Any, ?ICON_PRINT)    \quit         = CatchImage(#PB_Any, ?ICON_QUIT)    \about        = CatchImage(#PB_Any, ?ICON_ABOUT)  EndWithEndProcedure;-------------------------------------------------;- OS specific functionsProcedure.l get_system_color ( win_ColorIndex.l , mac_ColorName.s )    CompilerSelect #PB_Compiler_OS          CompilerCase #PB_OS_MacOS            Protected.i       NSColor      Protected.CGFloat R, G, B, A            NSColor = CocoaMessage(#Null, #Null, "NSColor colorWithCatalogName:$",@"System","colorName:$",@mac_ColorName)            If NSColor                  NSColor = CocoaMessage(#Null, NSColor, "colorUsingColorSpaceName:$",@"NSCalibratedRGBColorSpace")                If NSColor                    CocoaMessage(@R, NSColor, "redComponent")          CocoaMessage(@G, NSColor, "greenComponent")          CocoaMessage(@B, NSColor, "blueComponent")          CocoaMessage(@A, NSColor, "alphaComponent")                    ProcedureReturn (RGBA(Int(R*255), Int(G*255), Int(B*255), Int(A*255)) & $FFFFFFFF)                  EndIf              EndIf            ProcedureReturn -1          CompilerCase #PB_OS_Windows            Protected.l SysColor = GetSysColor_(win_ColorIndex)            If SysColor = 0        ProcedureReturn -1      Else        ProcedureReturn SysColor      EndIf          CompilerDefault            ProcedureReturn -1        CompilerEndSelect  EndProcedureProcedure.l get_system_hilite_color()    Protected.l result    CompilerIf  #PB_Compiler_OS = #PB_OS_MacOS        result = get_system_color ( #Null , "selectedTextBackgroundColor" )      CompilerElseIf #PB_Compiler_OS = #PB_OS_Windows        result = get_system_color ( #COLOR_HIGHLIGHT , #Null$ )      CompilerElse    result = -1  CompilerEndIf    If result = -1    result = #APP_COLOR_HIGHLIGHT  EndIf    ProcedureReturn result  EndProcedure;-------------------------------------------------;- gadget specific functionsProcedure main_window_enable_gadgets( *w.MAIN_WINDOW , mode.b = #APP_DATASET_NEW )    Protected.l x, y, w, h  Protected.s comment    x = GadgetX(*w\str_comment)  y = GadgetY(*w\str_comment)  w = GadgetWidth(*w\str_comment)  h = GadgetHeight(*w\str_comment)    comment = GetGadgetText(*w\str_comment)    DisableGadget(*w\str_address,   #False)  If mode = #APP_DATASET_NEW    DisableGadget(*w\str_company,   #False)  EndIf  DisableGadget(*w\str_email,     #False)  DisableGadget(*w\str_password,  #False)  DisableGadget(*w\str_password2, #False)  DisableGadget(*w\str_username,  #False)  DisableGadget(*w\btn_make,      #False)    DisableGadget(*w\lst, #True)    ;SetGadgetAttribute(*w\str_comment, #PB_Editor_ReadOnly, #False)    OpenGadgetList(*w\scr)  FreeGadget(*w\str_comment)  *w\str_comment = EditorGadget(#PB_Any, x, y, w, h, #PB_Editor_WordWrap)  SetGadgetText(*w\str_comment, comment)  CloseGadgetList()    If mode = #APP_DATASET_NEW    SetActiveGadget(*w\str_company)  Else    SetActiveGadget(*w\str_address)  EndIf  EndProcedureProcedure main_window_disable_gadgets( *w.MAIN_WINDOW , mode.b = #APP_DATASET_NEW )    Protected.l x, y, w, h  Protected.s comment    x = GadgetX(*w\str_comment)  y = GadgetY(*w\str_comment)  w = GadgetWidth(*w\str_comment)  h = GadgetHeight(*w\str_comment)    comment = GetGadgetText(*w\str_comment)    DisableGadget(*w\str_address,   #True)  If mode = #APP_DATASET_NEW    DisableGadget(*w\str_company,   #True)  EndIf  DisableGadget(*w\str_email,     #True)  DisableGadget(*w\str_password,  #True)  DisableGadget(*w\str_password2, #True)  DisableGadget(*w\str_username,  #True)  DisableGadget(*w\btn_make,      #True)    DisableGadget(*w\lst, #False)    ;SetGadgetAttribute(*w\str_comment, #PB_Editor_ReadOnly, #True)    OpenGadgetList(*w\scr)  FreeGadget(*w\str_comment)  *w\str_comment = TextGadget(#PB_Any, x, y, w, h, "", #PB_Text_Border)  SetGadgetText(*w\str_comment, comment)  CloseGadgetList()    SetGadgetColor(*w\str_address,   #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(*w\str_comment,   #PB_Gadget_BackColor, #PB_Default)  If mode = #APP_DATASET_NEW    SetGadgetColor(*w\str_company,   #PB_Gadget_BackColor, #PB_Default)  EndIf  SetGadgetColor(*w\str_email,     #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(*w\str_password,  #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(*w\str_password2, #PB_Gadget_BackColor, #PB_Default)  SetGadgetColor(*w\str_username,  #PB_Gadget_BackColor, #PB_Default)    SetActiveGadget(*w\lst)  EndProcedureProcedure main_window_get_data( *d.DATASET , *w.MAIN_WINDOW )    *d\Address   = GetGadgetText(*w\str_address)  *d\Comment   = GetGadgetText(*w\str_comment)  *d\Company   = GetGadgetText(*w\str_company)  *d\Email     = GetGadgetText(*w\str_email)  *d\Id        = GetGadgetData(*w\str_company)  *d\Password  = GetGadgetText(*w\str_password)  *d\Password2 = GetGadgetText(*w\str_password2)  *d\Username  = GetGadgetText(*w\str_username)  EndProcedureProcedure main_window_set_data( *d.DATASET , *w.MAIN_WINDOW )    SetGadgetText(*w\str_address,   *d\address)  ClearGadgetItems(*w\str_comment)  SetGadgetText(*w\str_comment,   *d\comment)  SetGadgetText(*w\str_company,   *d\company)  SetGadgetData(*w\str_company,   *d\Id)  SetGadgetText(*w\str_email,     *d\email)  SetGadgetText(*w\str_password,  *d\password)  SetGadgetText(*w\str_password2, *d\password2)  SetGadgetText(*w\str_username,  *d\username)  EndProcedureProcedure main_window_del_data( *w.MAIN_WINDOW )    SetGadgetText(*w\str_address,   "")  ClearGadgetItems(*w\str_comment)  SetGadgetText(*w\str_company,   "")  SetGadgetData(*w\str_company,   #APP_DATASET_NEW)  SetGadgetText(*w\str_email,     "")  SetGadgetText(*w\str_password,  "")  SetGadgetText(*w\str_password2, "")  SetGadgetText(*w\str_username,  "")  EndProcedureProcedure main_window_set_list( List d.DATASET() , *w.MAIN_WINDOW )    Protected.l i = 0    If CountGadgetItems(*w\lst) > 0    ClearGadgetItems(*w\lst)  EndIf    If ListSize(d()) > 0        ;SortStructuredList(d(), #PB_Sort_Ascending, OffsetOf(DATASET\company), #PB_String)        ForEach d()      AddGadgetItem(*w\lst, i, d()\company)      SetGadgetItemData(*w\lst, i, d()\id)      i+1    Next      Else    AddGadgetItem(*w\lst, 0, "...empty.")  EndIf  EndProcedureProcedure.b main_window_sel_list_by_id( List d.DATASET() , *w.MAIN_WINDOW , id.l )    Protected.b found = 0  Protected.l pos    For pos = 0 To CountGadgetItems(*w\lst)-1    If GetGadgetItemData(*w\lst, pos) = id      found = 1      SetGadgetState(*w\lst, pos)      ForEach d()        If id = d()\id          found = 2          main_window_set_data(d(), *w)          Break;--return from ForEach        EndIf      Next      Break;--return from For    EndIf  Next    If found = 1    warn("Found ID in gadget, but not in list.")  ElseIf found = 0    warn("Didn't found ID.")  EndIf    ProcedureReturn found  EndProcedureProcedure.b main_window_sel_list_by_pos( List d.DATASET() , *w.MAIN_WINDOW , position.l )    Protected.l id    If position > ListSize(d())-1    warn("Position [" + Str(position) + "] is higher then listsize.")    ProcedureReturn #False  EndIf    SetGadgetState(*w\lst, position)  id = GetGadgetItemData(*w\lst, position)    ForEach d()    If id = d()\id      main_window_set_data(d(), *w)      Break    EndIf  Next    ProcedureReturn #True  EndProcedureProcedure main_window_switch_pwd_gadgets( *w.MAIN_WINDOW , state.b , disabled.b )  Protected.l x1, y1, w, h, x2, y2  Protected.s t1, t2  With *w    x1 = GadgetX(\str_password)    y1 = GadgetY(\str_password)    w  = GadgetWidth(\str_password)    h  = GadgetHeight(\str_password)    x2 = GadgetX(\str_password2)    y2 = GadgetY(\str_password2)    t1 = GetGadgetText(\str_password)    t2 = GetGadgetText(\str_password2)    FreeGadget(\str_password)    FreeGadget(\str_password2)    OpenGadgetList(\scr)    If state      \str_password  = StringGadget(#PB_Any, x1, y1, w, h, t1)      \str_password2 = StringGadget(#PB_Any, x2, y2, w, h, t2)    Else      \str_password  = StringGadget(#PB_Any, x1, y1, w, h, t1, #PB_String_Password)      \str_password2 = StringGadget(#PB_Any, x2, y2, w, h, t2, #PB_String_Password)    EndIf    DisableGadget(\str_password,  disabled)    DisableGadget(\str_password2, disabled)    t1 = #Null$ : t2 = #Null$    CloseGadgetList()  EndWithEndProcedure;-------------------------------------------------;- menu specific functions; IDE Options = PureBasic 5.73 LTS (Windows - x64); CursorPosition = 469; FirstLine = 372; Folding = f+--; EnableXP; UseMainFile = main.pb; CompileSourceDirectory; EnablePurifier; EnableCompileCount = 0; EnableBuildCount = 0; EnableExeConstant