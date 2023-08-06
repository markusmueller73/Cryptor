; * CRYPTOR
;  *
;  * conf_window.pbi
;  *
;--------------------------------------------------------------------------------
;- structures
Structure CONFIG_WINDOW
  id.i
  img.i
  frm.i
  txt.i
  spn.i
  txt_start.i
  cmb_start.i
  chk_upper.i
  chk_lower.i
  chk_num.i
  chk_special.i
  chk_valids.i
  chk_hyphen.i
  btn_gen.i
  btn_use.i
  btn_close.i
  pwd_image.i
EndStructure

;- functions

Procedure.i gen_pwd_image( image_gadget.i , password$ = #Null$ , defaultColor.l = $F0FFFF )
  
  Protected.l part1_len, part2_len, img_width, img_height, txt_width, txt_height, font_size = 30
  Protected.i img_h, font_h
  Protected   pwd_part1$, pwd_part2$
  
  part1_len = Round(Len(password$), #PB_Round_Up)
  part2_len = Round(Len(password$), #PB_Round_Down)
  
  If IsGadget(image_gadget)
    img_width  = GadgetWidth(image_gadget)
    img_height = GadgetHeight(image_gadget)
  Else
    info("Password image gadget not exists.")
    img_width  = #PASSWORD_IMAGE_WIDTH
    img_height = #PASSWORD_IMAGE_HEIGHT
  EndIf
  
  img_h = CreateImage(#PB_Any, img_width, img_height, 24, defaultColor)
  If IsImage(img_h)
    
    info("Image with handle [0x"+Hex(img_h)+"] created.")
    
    font_h = LoadFont(#PB_Any, #APP_FIXED_FONT, font_size, #PB_Font_HighQuality)
    info("Using font '"+#APP_FIXED_FONT+"'.")
    
    StartDrawing(ImageOutput(img_h))
    DrawingFont(FontID(font_h))
    Box(0, 0, img_width, img_height, defaultColor)
    txt_width  = TextWidth(password$)
    StopDrawing()
    
    While txt_width > img_width
      FreeFont(font_h)
      font_size - 2
      font_h = LoadFont(#PB_Any, #APP_FIXED_FONT, font_size, #PB_Font_HighQuality)
      StartDrawing(ImageOutput(img_h))
      DrawingFont(FontID(font_h))
      txt_width = TextWidth(password$)
      StopDrawing()
    Wend
    info("Found a suitable font size of " + Str(font_size) + "px.")
    
    StartDrawing(ImageOutput(img_h))
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(font_h))
    txt_height = TextHeight(password$)
    DrawText((img_width-txt_width)/2, (img_height-txt_height)/2, password$, RGB(192, 192, 0))
    StopDrawing()
    
    FreeFont(font_h)
    
  Else
    warn("Can't create image.")
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn img_h
  
EndProcedure


Procedure.i open_conf_window( parent_window.i , *w.CONFIG_WINDOW , *p.APP_SETTINGS )
  
  Protected.l flags = #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible
  
  If IsWindow(*w\id)
    warn("Preference window is already open, closing.")
    CloseWindow(*w\id)
  EndIf
  
  If IsWindow(parent_window)
    
    *w\id = OpenWindow(#PB_Any, 0, 0, 400, 420, LANGUAGE("DIALOG_PWDPREFS_TITLE"), flags, WindowID(parent_window))
    If IsWindow(*w\id)
      
      info("Opened preference window with handle [0x"+Hex(*w\id, #PB_Long)+"].")
      
      *w\pwd_image = gen_pwd_image(*w\img)
      
      *w\img = ImageGadget(#PB_Any, 10, 10, #PASSWORD_IMAGE_WIDTH, #PASSWORD_IMAGE_HEIGHT, ImageID(*w\pwd_image))
    
      *w\frm = FrameGadget(#PB_Any, 10, 140, 380, 190, LANGUAGE("DIALOG_PWDPREFS_TITLE") + ":")
    
      *w\txt = TextGadget(#PB_Any, 20, 170, 150, 25, LANGUAGE("DIALOG_PWDPREFS_PWD_LEN") + ":")
      *w\spn = SpinGadget(#PB_Any, 20, 195, 150, 25, 0, 128, #PB_Spin_Numeric)
      
      *w\txt_start = TextGadget(#PB_Any, 20, 270, 150, 25, LANGUAGE("DIALOG_PWDPREFS_STARTWITH") + ":")
      *w\cmb_start = ComboBoxGadget(#PB_Any, 20, 295, 150, 25)
      AddGadgetItem(*w\cmb_start, 0, LANGUAGE("DIALOG_PWDPREFS_UCHAR"))
      AddGadgetItem(*w\cmb_start, 1, LANGUAGE("DIALOG_PWDPREFS_LCHAR"))
      AddGadgetItem(*w\cmb_start, 2, LANGUAGE("DIALOG_PWDPREFS_NUMBER"))
      AddGadgetItem(*w\cmb_start, 3, LANGUAGE("DIALOG_PWDPREFS_SPECIAL"))
    
      *w\chk_upper   = CheckBoxGadget(#PB_Any, 180, 170, 200, 25, LANGUAGE("DIALOG_PWDPREFS_UPPERS") + "?")
      *w\chk_lower   = CheckBoxGadget(#PB_Any, 180, 195, 200, 25, LANGUAGE("DIALOG_PWDPREFS_LOWERS") + "?")
      *w\chk_num     = CheckBoxGadget(#PB_Any, 180, 220, 200, 25, LANGUAGE("DIALOG_PWDPREFS_NUMBERS") + "?")
      *w\chk_special = CheckBoxGadget(#PB_Any, 180, 245, 200, 25, LANGUAGE("DIALOG_PWDPREFS_SPECIAL_CHARS") + "?")
      *w\chk_valids  = CheckBoxGadget(#PB_Any, 180, 270, 200, 25, LANGUAGE("DIALOG_PWDPREFS_REGULAR_CHARS") + "?")
      *w\chk_hyphen  = CheckBoxGadget(#PB_Any, 180, 295, 200, 25, LANGUAGE("DIALOG_PWDPREFS_ADD_HYPHEN") + "?")
    
      *w\btn_gen   = ButtonGadget(#PB_Any,  10, 340, 160, 30, LANGUAGE("DIALOG_PWDPREFS_GENERATE"))
      *w\btn_use   = ButtonGadget(#PB_Any, 230, 340, 160, 30, LANGUAGE("DIALOG_PWDPREFS_USE_PWD"))
      *w\btn_close = ButtonGadget(#PB_Any, 230, 380, 160, 30, LANGUAGE("MENU_FILE_CLOSE"))
      
      SetGadgetState(*w\spn, *p\pw_len)
      SetGadgetText(*w\spn, Str(*p\pw_len))
      
      SetGadgetState(*w\cmb_start, *p\pw_start - 1)
      If *p\pw_uc > 0 : SetGadgetState(*w\chk_upper, #True) : EndIf
      If *p\pw_lc > 0 : SetGadgetState(*w\chk_lower, #True) : EndIf
      If *p\pw_num > 0 : SetGadgetState(*w\chk_num, #True) : EndIf
      If *p\pw_special > 0
        SetGadgetState(*w\chk_special, #True)
      Else 
        DisableGadget(*w\chk_valids, #True)
      EndIf
      If *p\pw_valids : SetGadgetState(*w\chk_valids, #True) : EndIf
      If *p\pw_hyphen : SetGadgetState(*w\chk_hyphen, #True) : EndIf
      
      HideWindow(*w\id, #False)
      
    Else
      warn("Can't create tool window.")
      ProcedureReturn 0
    EndIf
    
  Else
    warn("The parent window [0x" + Hex(parent_window, #PB_Long) + "] didn't exist.")
    ProcedureReturn 0
  EndIf
  
  ProcedureReturn *w\id
  
EndProcedure
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 136
; FirstLine = 100
; Folding = -
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant