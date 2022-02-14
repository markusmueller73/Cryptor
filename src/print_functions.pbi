;  * CRYPTOR
;  *
;  * print_functions.pbi
;  *
;--------------------------------------------------------------------------------

;- helper functions
Procedure.s set_string(str.s, len.l)
  Protected i.l, s.s
  For i = 1 To len : s + str : Next
  ProcedureReturn s
EndProcedure

;- printing functions
Declare.i print_drawingmode(List d.DATASET())
Declare.i print_vectormode(List d.DATASET())

Procedure.i  print_database( List d.DATASET() )
  
  Protected.i pages
  
  If ListSize(d()) > 0
    
    If PrintRequester()
      
      ;pages = print_drawingmode(d())
      pages = print_vectormode(d())
      
    Else
      info("No printer installed or user cancelled the requester.")
      ProcedureReturn 0
    EndIf
    
  Else
    
    info("Nothing to print, database is empty.")
    MessageRequester(#APP_NAME, "There is nothing to print." + #NL + "Load a database or create a new one.", #PB_MessageRequester_Info)
    ProcedureReturn 0
    
  EndIf
  
  ProcedureReturn pages
  
EndProcedure

Procedure.i print_drawingmode(List d.DATASET())
  
  Protected.i h_font, h_fontb, y, i = 1
  
  h_font  = LoadFont(#PB_Any, #APP_FIXED_FONT, 48, #PB_Font_HighQuality)
  h_fontb = LoadFont(#PB_Any, #APP_FIXED_FONT, 48, #PB_Font_HighQuality|#PB_Font_Bold)
  
  If StartPrinting(#APP_NAME + " - Database")
    
    If StartDrawing(PrinterOutput())
      
      BackColor(#White)
      FrontColor(#Black)
      
      Box(0, 0, PrinterPageWidth(), PrinterPageHeight(), #White)
      
      DrawingFont(FontID(h_fontb))
      
      DrawText(0, y, #APP_NAME + " database") : y + 80
      DrawText(0, y, set_string("-", Len(#APP_NAME + " database"))) : y + 160
      
      DrawingFont(FontID(h_font))
      ForEach d()
        
        If y > 6000 
          y = 0 : i + 1
          NewPrinterPage()
          Box(0, 0, PrinterPageWidth(), PrinterPageHeight(), #White)
        EndIf
          
        DrawText(0, y, d()\Company) : y + 80
        DrawText(0, y, set_string("-", Len(d()\Company))) : y + 160
        If d()\Username <> "" : DrawText(0, y, "Username: " + d()\Username) : y + 80 : EndIf
        If d()\Email <> "" : DrawText(0, y, "Email: " + d()\Email) : y + 80 : EndIf
        If d()\Password <> "" : DrawText(0, y, "Password: " + d()\Password) : y + 80 : EndIf
        If d()\Address <> "" : DrawText(0, y, "Website: " + d()\Address) : y + 80 : EndIf
        If d()\Comment <> ""
          DrawText(0, y, "Comments:") : y + 80
          DrawText(0, y, d()\Comment) : y + 80
        EndIf
        
        y + 80
        
      Next
      
      StopDrawing()
      
    EndIf
    
    StopPrinting()
    
  Else
    warn("Can't start print process.")
    ProcedureReturn 0
  EndIf
  
  FreeFont(h_font)
  FreeFont(h_fontb)
  
  ProcedureReturn i
  
EndProcedure

Procedure.i print_vectormode( List d.DATASET() )
  
  Protected.l x, y, tbvh, page
  Protected.i h_font, h_fontb
  Protected.s text_block
  
  h_font  = LoadFont(#PB_Any, #APP_FIXED_FONT, 48, #PB_Font_HighQuality)
  h_fontb = LoadFont(#PB_Any, #APP_FIXED_FONT, 48, #PB_Font_HighQuality|#PB_Font_Bold)
  
  If StartPrinting(#APP_NAME + " - Database")
    
    If StartVectorDrawing(PrinterVectorOutput(#PB_Unit_Point))
      
      VectorFont(FontID(h_fontb), 12)
      VectorSourceColor(RGBA(0, 0, 0, 225))
      
      x = 40
      y = 40
      MovePathCursor(x, y)
      DrawVectorText(#APP_NAME + " password database")
      
      y + 15
      MovePathCursor(x, y)
      DrawVectorText(set_string("=", Len(#APP_NAME + " password database")))
      
      y + 45
      
      ForEach d()
        
        text_block = #NL + d()\Company + #NL + set_string("-", Len(d()\Company)) + #NL
        If d()\Address
          text_block + "(Web-)Address:  " + d()\Address + #NL
        EndIf
        If d()\Username
          text_block + "Username:       " + d()\Username + #NL
        EndIf
        If d()\Email
          text_block + "E-Mail address: " + d()\Email + #NL
        EndIf
        If d()\Password
          text_block + "Password:       " + d()\Password + #NL
        EndIf
        If d()\Comment
          text_block + #NL + "Comments:" + #NL + #NL + d()\Comment + #NL
        EndIf
        text_block + #NL + set_string("-", 70) + #NL
        
        
        tbvh = VectorParagraphHeight(text_block, VectorOutputWidth()-80, VectorOutputHeight())
        If y + tbvh > VectorOutputHeight()
          y = 40
          page + 1
          MovePathCursor(VectorOutputWidth()-60, VectorOutputHeight()-55)
          DrawVectorText("-" + Str(page) + "-")
          NewPrinterPage()
        EndIf
        
        MovePathCursor(x, y)
        DrawVectorParagraph(text_block, VectorOutputWidth()-80, tbvh)
        y + tbvh
        dbg("Printer page height: " + Str(PrinterPageHeight()) + "(" + Str(VectorOutputHeight()) + ")" + ", current position: " + Str(y) + ", current text block: " + Str(tbvh))
        
      Next
      
      MovePathCursor(VectorOutputWidth()-60, VectorOutputHeight()-55)
      DrawVectorText("-" + Str(page+1) + "-")
      
      StopVectorDrawing()
      
    EndIf
    
    StopPrinting()
    
  Else
    warn("Can't start print process.")
    ProcedureReturn 0
  EndIf
  
EndProcedure

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 153
; FirstLine = 126
; Folding = +
; EnableXP
; EnablePurifier
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant