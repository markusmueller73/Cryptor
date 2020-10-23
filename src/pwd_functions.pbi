;  * CRYPTOR
;  *
;  * pwd_functions.pbi
;  *

#SPECIAL_CHARS = 29

Enumeration 0
  #BEGIN_WITH_RANDOM
  #BEGIN_WITH_UPPER_CASE
  #BEGIN_WITH_LOWER_CASE
  #BEGIN_WITH_NUMBER
  #BEGIN_WITH_SPECIAL_CHAR
EndEnumeration
;--------------------------------------------------------------------------------
Procedure.i get_pwd( *key , ask_twice.b = #False )
  
  ;- begin get_pwd()
  Protected.i pwd_len
  Protected   dlg_txt$, _pwd1$, _pwd2$
  
  ;- set dialog message
  If ask_twice
    dlg_txt$ = "Type in the password to lock your file:"
  Else
    dlg_txt$ = "Type in the password to unlock your file:"
  EndIf
  
  ;- first password input
  _pwd1$ = InputRequester("Type your password:", dlg_txt$, "", #PB_InputRequester_Password)
  If _pwd1$ = #Null$
    ;-- break-> no password input
    warn("No password input in first try.")
    ProcedureReturn 0
  EndIf
  
  If ask_twice
    
    ;-- second password input
    _pwd2$ = InputRequester("Type your password again:", dlg_txt$, "", #PB_InputRequester_Password)
    
    If CompareMemoryString(@_pwd1$, @_pwd2$) = #PB_String_Equal
      
      ;--- process the second password
      _pwd1$ = #Null$
      pwd_len = Len(_pwd2$)
      string_to_mem(_pwd2$, *key)
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
    string_to_mem(_pwd1$, *key)
    _pwd1$ = #Null$
    
  EndIf
  
  ProcedureReturn pwd_len
  
  ;- end get_pwd()
EndProcedure
;--------------------------------------------------------------------------------
Procedure.s gen_pwd( Length.l , UpperCase.l , LowerCase.l , Numbers.l , SpecialSigns.l , BeginWith.l = #BEGIN_WITH_UPPER_CASE )
  
  If Length < 0
    info("password length was negative.")
    ProcedureReturn #Null$
  EndIf
  
  If UpperCase < 0 Or LowerCase < 0 Or Numbers < 0 Or SpecialSigns < 0
    info("no valid param for upper, lower, number or special sings")
    ProcedureReturn #Null$
  EndIf
  
  Protected.l i
  Protected.s newPasswd = #Null$
  
  Dim sc.s(#SPECIAL_CHARS)
  Restore SPECIAL_CHARS
  For i = 0 To #SPECIAL_CHARS-1 : Read.s sc(i) : Next
  
  If (UpperCase + LowerCase + Numbers + SpecialSigns) < Length
    While (UpperCase + LowerCase + Numbers + SpecialSigns) < Length
      i = Random(#BEGIN_WITH_SPECIAL_CHAR, #BEGIN_WITH_UPPER_CASE)
      Select i
        Case #BEGIN_WITH_UPPER_CASE   : UpperCase + 1
        Case #BEGIN_WITH_LOWER_CASE   : LowerCase + 1
        Case #BEGIN_WITH_NUMBER       : Numbers + 1
        Case #BEGIN_WITH_SPECIAL_CHAR : SpecialSigns + 1
      EndSelect
    Wend
  EndIf
  
  If BeginWith = #BEGIN_WITH_RANDOM : BeginWith = Random(#BEGIN_WITH_SPECIAL_CHAR, #BEGIN_WITH_UPPER_CASE) : EndIf
  
  Select BeginWith
    Case #BEGIN_WITH_UPPER_CASE   : newPasswd = Chr(Random(90, 65))             : UpperCase - 1
    Case #BEGIN_WITH_LOWER_CASE   : newPasswd = Chr(Random(122, 97))            : LowerCase - 1
    Case #BEGIN_WITH_NUMBER       : newPasswd = Str(Random(9))                  : Numbers - 1
    Case #BEGIN_WITH_SPECIAL_CHAR : newPasswd = sc( Random(#SPECIAL_CHARS-1) )  : SpecialSigns - 1
    Default
      info("Unknown param in {BeginWith}.")
      ProcedureReturn #Null$
  EndSelect
  
  While Len(newPasswd) < Length
    
    i = Random(#BEGIN_WITH_SPECIAL_CHAR, #BEGIN_WITH_UPPER_CASE)
    
    Select i
      Case #BEGIN_WITH_UPPER_CASE
        If UpperCase > 0
          newPasswd + Chr(Random(90, 65))
          UpperCase - 1
        EndIf
      Case #BEGIN_WITH_LOWER_CASE
        If LowerCase > 0
          newPasswd + Chr(Random(122, 97))
          LowerCase - 1
        EndIf
      Case #BEGIN_WITH_NUMBER
        If Numbers > 0
          newPasswd + Str(Random(9))
          Numbers - 1
        EndIf
      Case #BEGIN_WITH_SPECIAL_CHAR
        If SpecialSigns > 0
          newPasswd + sc( Random(#SPECIAL_CHARS-1) )
          SpecialSigns - 1
        EndIf
    EndSelect
    
  Wend
  
  ProcedureReturn newPasswd
  
EndProcedure
;--------------------------------------------------------------------------------
DataSection
  SPECIAL_CHARS:
  Data.s "!","§","$","%","&","/","(",")","=","?","\","[","]","{","}",",",".",";",":","-","_","<",">","|","+","*","#","'","~"
EndDataSection

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 112
; FirstLine = 51
; Folding = -
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant