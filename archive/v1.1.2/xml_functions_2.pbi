﻿;  * CRYPTOR;  *;  * xml_functions.pbi;  *Macro check_xml_saving( filename )  FormatXML(h_xml, #PB_XML_ReFormat)  If SaveXML(h_xml, filename)    info("XML file " + GetFilePart(filename) + " saved successfully.")  Else    warn("can't save xml file '" + filename + "'")    ProcedureReturn 0  EndIfEndMacroMacro check_xml_database_node( node , lst , xml )  Select GetXMLNodeName(node)    Case #APP_DATATYPE_CFG      xml\cfg = node    Case #APP_DATATYPE_DB      xml\dat = node    Case #APP_DATATYPE_DATA      AddElement(lst)      lst\id = Val(GetXMLAttribute(node, #APP_DATATYPE_ID))    Case #APP_DATATYPE_ADDR      lst\address = GetXMLNodeText(node)    Case #APP_DATATYPE_CORP      lst\company = GetXMLNodeText(node)    Case #APP_DATATYPE_MAIL      lst\email = GetXMLNodeText(node)    Case #APP_DATATYPE_MISC      lst\comment = GetXMLNodeText(node)    Case #APP_DATATYPE_PWD1      lst\password = GetXMLNodeText(node)    Case #APP_DATATYPE_PWD2      lst\password2 = GetXMLNodeText(node)    Case #APP_DATATYPE_USER      lst\username = GetXMLNodeText(node)  EndSelectEndMacroMacro check_xml_config_node( node , lst , xml )  Select GetXMLNodeName(node)    Case #APP_DATATYPE_CFG      xml\cfg = node  EndSelectEndMacroProcedure xml_get_node ( node.i , List d.DATASET() , *x.XML_NODES )    Protected.i childNode    If node <> 0        If XMLNodeType(node) = #PB_XML_Normal            childNode = ChildXMLNode(node)            While childNode <> 0        Debug GetXMLNodeName(childNode)        ;check_xml_config_node(childNode , d(), *x)        check_xml_database_node(childNode, d(), *x)                If ChildXMLNode(node) <> 0          xml_get_node(childNode, d(), *x)        EndIf                childnode = NextXMLNode(childnode)              Wend          EndIf      EndIf  EndProcedureProcedure.i xml_parse( List d.DATASET() , *x.XML_NODES )    If ListSize(d()) > 0    info("linked list has " + Str(ListSize(d())) + " entries, clearing memory")    ClearList(d())  EndIf    If IsXML(*x\id)        *x\root = MainXMLNode(*x\id)        If *x\root <> 0            If XMLNodeType(*x\root) = #PB_XML_Normal                If GetXMLNodeName(*x\root) = #APP_NAME                    xml_get_node(*x\root, d(), *x)          info("XML file successfully parsed.")                  Else                    warn("root node is not valid: '" + GetXMLNodeName(*x\root) + "'.")          ProcedureReturn 0                  EndIf              Else                warn("root node is not a normal node, XML file broken?")        ProcedureReturn 0              EndIf          Else            warn("no valid root node found.")      ProcedureReturn 0          EndIf      Else        warn("no valid XML file in memory, aborting.")    ProcedureReturn 0      EndIf    ProcedureReturn *x\id  EndProcedureProcedure xml_add_dataset( *d.DATASET , *x.XML_NODES )  Protected.i x_set, x_item  With *x    If IsXML(\id) And *d\id > 0      If CompareMemoryString(@*d\password, @*d\password2) = #PB_String_Equal        x_set = CreateXMLNode(\dat, #APP_DATATYPE_DATA)        SetXMLAttribute(x_set, #APP_DATATYPE_ID, Str(*d\id));         x_item = CreateXMLNode(x_set, #APP_DATATYPE_ID);         SetXMLNodeText(x_item, Str(*d\id))        If CompareMemoryString(@*d\company, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_CORP)          SetXMLNodeText(x_item, *d\company)        EndIf        If CompareMemoryString(@*d\address, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_ADDR)          SetXMLNodeText(x_item, *d\address)        EndIf        If CompareMemoryString(@*d\username, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_USER)          SetXMLNodeText(x_item, *d\username)        EndIf        If CompareMemoryString(@*d\email, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_MAIL)          SetXMLNodeText(x_item, *d\email)        EndIf        If CompareMemoryString(@*d\password, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_PWD1)          SetXMLNodeText(x_item, *d\password)        EndIf        If CompareMemoryString(@*d\password2, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_PWD2)          SetXMLNodeText(x_item, *d\password2)        EndIf        If CompareMemoryString(@*d\comment, @"") <> 0          x_item = CreateXMLNode(x_set, #APP_DATATYPE_MISC)          SetXMLNodeText(x_item, *d\comment)        EndIf      Else        warn("passwords are not equal in dataset #" + *d\id + ".")      EndIf    Else      warn("The xml data isn't valid.")    EndIf  EndWithEndProcedureProcedure.i xml_create_database( List d.DATASET() , *x.XML_NODES )    With *x        If IsXML(\id)            If ListSize(d()) > 0                ForEach d()                    xml_add_dataset(@d(), *x)                  Next              Else        warn("Can't create XML database, list is empty.")      EndIf          Else      warn("The xml data isn't valid.")    EndIf      EndWith    ProcedureReturn *x\id  EndProcedureProcedure.i xml_create_new( *x.XML_NODES )    With *x        \id = CreateXML(#PB_Any)        If IsXML(\id)            \root = CreateXMLNode(RootXMLNode(\id), #APP_NAME)      \cfg = CreateXMLNode(\root, #APP_DATATYPE_CFG)      \dat = CreateXMLNode(\root, #APP_DATATYPE_DB)            ProcedureReturn \id          Else      warn("can't create xml root tree")      ProcedureReturn 0    EndIf      EndWith  EndProcedureProcedure.i xml_load( full_path_and_filename.s )    Protected.i h_xml    If FileSize(full_path_and_filename) < 0    info("file '" + full_path_and_filename + "' didn't exist")    ProcedureReturn 0  EndIf    h_xml = LoadXML(#PB_Any, full_path_and_filename)  If IsXML(h_xml)        If XMLStatus(h_xml) = #PB_XML_Success      info("XML file loaded without errors.")    Else      warn("XML file loaded with error: " + XMLError(h_xml) + "; at line " + XMLErrorLine(h_xml) + " and column " + XMLErrorPosition(h_xml))      FreeXML(h_xml)      ProcedureReturn 0    EndIf        ProcedureReturn h_xml      Else    warn("can't load xml file '" + GetFilePart(full_path_and_filename) + "'")    ProcedureReturn 0  EndIf  EndProcedureProcedure.i xml_save( h_xml.i , full_path_and_filename.s , overwrite.i = #False )    If IsXML(h_xml)        If FileSize(full_path_and_filename) >= 0            If overwrite                check_xml_saving(full_path_and_filename)              Else                info("xml file '" + GetFilePart(full_path_and_filename) + "' already exist, didn't save it in '" + GetPathPart(full_path_and_filename) + "'")        MessageRequester("Saving" + "...", "Can't save the xml file '" + full_path_and_filename + "'." + #CRLF$ + "File already exist.")        ProcedureReturn 0              EndIf          Else            check_xml_saving(full_path_and_filename)          EndIf      Else    info("no valid xml")    ProcedureReturn 0  EndIf    ProcedureReturn h_xml    EndProcedureProcedure.i xml_load_crypted( h_xml.i , full_path_and_filename.s )  EndProcedureProcedure.i xml_save_crypted( h_xml.i , full_path_and_filename.s , overwrite.i = #False )  EndProcedure; IDE Options = PureBasic 5.71 LTS (MacOS X - x64); CursorPosition = 61; FirstLine = 220; Folding = ---; EnableXP; UseMainFile = main.pb; CompileSourceDirectory; EnablePurifier; EnableCompileCount = 0; EnableBuildCount = 0; EnableExeConstant