﻿;  * CRYPTOR;  *;  * mem_functions.pbi;  *Macro clear_mem( memory , size = #APP_BYTE_SIZE )  FillMemory(memory, size)EndMacroProcedure.i string_to_mem( string.s , *mem )    Protected.i i  Protected.s s    If Len(string) = 0    info("empty string")    ProcedureReturn 0  EndIf    s = StringFingerprint(string, #PB_Cipher_MD5)    If Len(s) <> 32    info("can't create valid key string")    ProcedureReturn 0  EndIf    If *mem = 0    warn("memory isn't allocated")    ProcedureReturn 0  EndIf    For i = 0 To 15    PokeB(*mem + i, Val("$"+Mid(s, i*2+1, 2)))  Next    ProcedureReturn @*mem  EndProcedure; IDE Options = PureBasic 5.72 (Windows - x64); CursorPosition = 22; Folding = -; EnableXP; UseMainFile = main.pb; CompileSourceDirectory; EnablePurifier; EnableCompileCount = 0; EnableBuildCount = 0; EnableExeConstant