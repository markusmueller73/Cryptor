;  * CRYPTOR
;  *
;  * pwd_functions.pbi
;  *


;--------------------------------------------------------------------------------
Procedure.i get_pwd( *key , ask_twice.b = #False )
  
  ;- begin get_pwd()
  Protected.i pwd_len
  Protected   dlg_txt$, _pwd1$, _pwd2$
  
  ;- set dialog message
  If ask_twice
    dlg_txt$ = LANGUAGE("DIALOG_PASSWORD_LOCK_FILE") + ":"
  Else
    dlg_txt$ = LANGUAGE("DIALOG_PASSWORD_UNLOCK_FILE") + ":"
  EndIf
  
  ;- first password input
  _pwd1$ = InputRequester(LANGUAGE("DIALOG_PASSWORD_TYPE") + ":", dlg_txt$, "", #PB_InputRequester_Password)
  If _pwd1$ = #Null$
    ;-- break-> no password input
    warn("No password input in first try.")
    ProcedureReturn 0
  EndIf
  
  If ask_twice
    
    ;-- second password input
    _pwd2$ = InputRequester(LANGUAGE("DIALOG_PASSWORD_TYPE_AGAIN") + ":", dlg_txt$, "", #PB_InputRequester_Password)
    
    If CompareMemoryString(@_pwd1$, @_pwd2$) = #PB_String_Equal
      
      ;--- process the second password
      _pwd1$ = #Null$
      pwd_len = Len(_pwd2$)
      sha2string_to_mem(_pwd2$, *key)
      _pwd2$ = #Null$
      
    Else
      
      ;--- passwords didn't match
      _pwd1$ = #Null$
      _pwd2$ = #Null$
      warn("The passwords didn't match.")
      ProcedureReturn 0
      
    EndIf
    
  Else
    
    ;-- process the first password
    pwd_len = Len(_pwd1$)
    sha2string_to_mem(_pwd1$, *key)
    _pwd1$ = #Null$
    
  EndIf
  
  ProcedureReturn pwd_len
  
  ;- end get_pwd()
EndProcedure
;--------------------------------------------------------------------------------
Procedure.s gen_pwd( Length.l , UpperCase.l = 0 , LowerCase.l = 0 , Numbers.l = 0 , SpecialSigns.l = 0 , BeginWith.l = #BEGIN_WITH_RANDOM , OnlyValidSpecials = #True , FormatWithHyphen = #True)
  
  ;-- check for valid params
  If Length < 0
    warn("Password length was negative.")
    ProcedureReturn #Null$
  ElseIf Length > 128
    warn("Password length was too big (>128).")
    ProcedureReturn #Null$
  EndIf
  
  If UpperCase = -1 And LowerCase = -1 And Numbers = -1 And SpecialSigns = -1
    warn("All chartypes were negative, can't create password.")
    ProcedureReturn #Null$
  EndIf
  
  If UpperCase < -1 Or LowerCase < -1 Or Numbers < -1 Or SpecialSigns < -1
    warn("The parameter of one of the chars was negative.")
    ProcedureReturn #Null$
  EndIf
  
  ;-- declare vars
  Protected.b no_uchar, no_lchar, no_num, no_special
  Protected.l i, j, nb_of_specials, calc_len, hyphen_1, hyphen_2
  Protected   new_pwd$
  
  ;-- check environment
  If UpperCase = -1    : no_uchar   = #True : EndIf
  If LowerCase = -1    : no_lchar   = #True : EndIf
  If Numbers = -1      : no_num     = #True : EndIf
  If SpecialSigns = -1 : no_special = #True : EndIf
  
  If OnlyValidSpecials : nb_of_specials = 6 : Else : nb_of_specials = #SPECIAL_CHARS : EndIf
  
  ;-- get special chars
  Dim sc.s(nb_of_specials-1)
  Restore SPECIAL_CHARS
  For i = 0 To nb_of_specials-1 : Read.s sc(i) : Next
  
  ;-- recalc password content
  If no_uchar = #False   : calc_len + UpperCase    : EndIf
  If no_lchar = #False   : calc_len + LowerCase    : EndIf
  If no_num = #False     : calc_len + Numbers      : EndIf
  If no_special = #False : calc_len + SpecialSigns : EndIf
  
  ;-- find positions for the hyphen
  If FormatWithHyphen
    hyphen_1 = Int(Length / 3)
    hyphen_2 = Length - hyphen_1 + 1
    calc_len + 2
  EndIf
  
  While calc_len < Length
    
    i = Random(#BEGIN_WITH_SPECIAL_CHAR, #BEGIN_WITH_UPPER_CASE)
    
    If i = #BEGIN_WITH_UPPER_CASE And no_uchar = #False
      UpperCase + 1
      calc_len + 1
    ElseIf i = #BEGIN_WITH_LOWER_CASE And no_lchar = #False
      LowerCase + 1
      calc_len + 1
    ElseIf i = #BEGIN_WITH_NUMBER And no_num = #False
      Numbers + 1
      calc_len + 1
    ElseIf i = #BEGIN_WITH_SPECIAL_CHAR And no_special = #False
      SpecialSigns + 1
      calc_len + 1
    EndIf
    
  Wend
  
  ;-- check type of passwords first char
  If BeginWith = #BEGIN_WITH_RANDOM
    
    While #True
      
      i = Random(#BEGIN_WITH_SPECIAL_CHAR, #BEGIN_WITH_UPPER_CASE)
      
      If i = #BEGIN_WITH_UPPER_CASE And no_uchar = #False
        BeginWith = #BEGIN_WITH_UPPER_CASE : Break
      ElseIf i = #BEGIN_WITH_LOWER_CASE And no_lchar = #False
        BeginWith = #BEGIN_WITH_LOWER_CASE : Break
      ElseIf i = #BEGIN_WITH_NUMBER And no_num = #False
        BeginWith = #BEGIN_WITH_NUMBER : Break
      ElseIf i = #BEGIN_WITH_SPECIAL_CHAR And no_special = #False
        BeginWith = #BEGIN_WITH_SPECIAL_CHAR : Break
      EndIf
      
    Wend
    
  EndIf
  
  ;-- set first char
  Select BeginWith
    Case #BEGIN_WITH_UPPER_CASE   : new_pwd$ = Chr(Random(90, 65))             : UpperCase - 1
    Case #BEGIN_WITH_LOWER_CASE   : new_pwd$ = Chr(Random(122, 97))            : LowerCase - 1
    Case #BEGIN_WITH_NUMBER       : new_pwd$ = Str(Random(9))                  : Numbers - 1
    Case #BEGIN_WITH_SPECIAL_CHAR : new_pwd$ = sc( Random(nb_of_specials-1) )  : SpecialSigns - 1
    Default
      info("Unknown param in {BeginWith}.")
      ProcedureReturn #Null$
  EndSelect
  
  ;-- set each char until it reaches the password length
  j = 2
  While Len(new_pwd$) < Length
    
    If FormatWithHyphen
      If j = hyphen_1 Or j = hyphen_2
        new_pwd$ + "-"
        j + 1
        Continue
      EndIf
    EndIf
    
    i = Random(#BEGIN_WITH_SPECIAL_CHAR, #BEGIN_WITH_UPPER_CASE)
    
    If i = #BEGIN_WITH_UPPER_CASE And no_uchar = #False And UpperCase > 0
      new_pwd$ + Chr(Random(90, 65))
      UpperCase - 1
      j + 1
    ElseIf i = #BEGIN_WITH_LOWER_CASE And no_lchar = #False And LowerCase > 0
      new_pwd$ + Chr(Random(122, 97))
      LowerCase - 1
      j + 1
    ElseIf i = #BEGIN_WITH_NUMBER And no_num = #False And Numbers > 0
      new_pwd$ + Str(Random(9))
      Numbers - 1
      j + 1
    ElseIf i = #BEGIN_WITH_SPECIAL_CHAR And no_special = #False And SpecialSigns > 0
      new_pwd$ + sc( Random(nb_of_specials-1) )
      SpecialSigns - 1
      j + 1
    EndIf
    
  Wend
  
  ;-- free the array for the special signs
  FreeArray(sc())
  
  info("Password with length of "+Str(Len(new_pwd$))+" signs successful created.")
  ProcedureReturn new_pwd$
  
EndProcedure

;--------------------------------------------------------------------------------
DataSection
  SPECIAL_CHARS:
  Data.s "!","§","$","%","&","/","(",")","=","?","\","[","]","{","}",",",".",";",":","-","_","<",">","|","+","*","#","'","~"
EndDataSection
; IDE Options = PureBasic 5.71 LTS (MacOS X - x64)
; CursorPosition = 81
; FirstLine = 64
; Folding = -
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant