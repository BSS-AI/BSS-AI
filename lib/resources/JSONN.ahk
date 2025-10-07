class JSONN {
    static parse(str) {
        return JSONN_parse(str)
    }
    static stringify(obj, maxDepth := 15) {
        return JSONN_stringify(obj, maxDepth)
    }
}
JSONN_parse(str) {
	len:=StrLen(str),i:=1
	WS() {
	  while (i<=len) {
		switch SubStr(str,i,1) {
		  case " ","`t","`r","`n":++i
		  default:break
		}
	  }
	}
	get() {
	  WS()
	  switch SubStr(str,i,1) {
		case "[":
		  ++i,arr:=[]
		  while (i<=len) {
			WS()
			if (SubStr(str,i,1)=="]") {
			  ++i
			  return arr
			} else if (A_Index > 1) {
			  ++i
			}
			arr.Push(get())
		  }
		case "{":
		  ++i,obj:=Map()
		  while (i<=len) {
			WS()
			if (SubStr(str,i,1)=="}") {
			  ++i
			  return obj
			} else if (A_Index > 1) {
			  ++i
			}
			key:=get(),WS(),++i,value:=get()
			obj[key]:=value
			obj.%key%:=value ;support obj.property notation
		  }
		case "-","0","1","2","3","4","5","6","7","8","9":
		  b:=i,++i
		  while (i<=len) {
			switch SubStr(str,i,1) {
			  case ".","e","E","0","1","2","3","4","5","6","7","8","9":
				++i
				continue
			}
			break
		  }
		  return Number(SubStr(str,b,i-b))
		case "`"":
		  ++i,b:=i
		  _str:=""
		  while (i<=len) {
			switch SubStr(str,i,1) {
			  case "\":
				_str.=SubStr(str,b,i-b),++i
				switch SubStr(str,i,1) {
  case "`"":_str.="`""
  case "\":_str.="\"
  case "/":_str.="/"
  case "b":_str.="`b"
  case "f":_str.="`f"
  case "n":_str.="`n"
  case "r":_str.="`r"
  case "t":_str.="`t"
  case "u":_str.=Chr("0x" SubStr(str,i+1,4)),i+=4
				}
				++i,b:=i
				continue
			  case "`"":
				_str.=SubStr(str,b,i-b)
				++i
				return _str
			}
			++i
		  }
		case "t":return (i+=4,t("true"))
		case "f":return (i+=5,t("false"))
		case "n":return (i+=4,t("null"))
	  }
	}
	t(n)=>{Base:{__Class:n}}
	return get()
}
JSONN_stringify(obj, maxDepth := 5) {

    stringified := ""

    escape(str) {
        str:=StrReplace(str, "\", "\\", true)
        str:=StrReplace(str, "`t", "\t", true)
        str:=StrReplace(str, "`b", "\b", true)
        str:=StrReplace(str, "`n", "\n", true)
        str:=StrReplace(str, "`r", "\r", true)
        str:=StrReplace(str, "`f", "\f", true)
        str:=StrReplace(str, "`"", "\`"", true)
        return str
    }
    ok(obj, depth) {
        switch (Type(obj)) {
            case 'Map':
                if (depth > maxDepth) {
                    stringified.="`"[DEEP ...Map]`""
                } else {
                    stringified.="{"
                    for k, v in obj {
                        (A_Index > 1 && stringified.=",")
                        ;ESCAPE THIS, using java thingy
                        stringified.="`"" escape(k) "`": "
                        ok(v, depth+1)
                    }
                    stringified.="}"
                }
            case 'Object':
                if (depth > maxDepth) {
                    stringified.="`"[DEEP ...Object]`""
                } else {
                    stringified.="{"
                    for k, v in obj.OwnProps() {
                        (A_Index > 1 && stringified.=",")
                        ;ESCAPE THIS, using java thingy
                        stringified.="`"" escape(k) "`": "
                        ok(v, depth+1)
                    }
                    stringified.="}"
                }
            case 'Array':
                if (depth > maxDepth) {
                    stringified.="`"[DEEP ...Array]`""
                } else {
                    stringified.="["
                    for v in obj {
                        (A_Index > 1 && stringified.=",")
                        ok(v, depth+1)
                    }
                    stringified.="]"
                }
            case 'String':
                ; escape with java
                stringified.="`"" escape(obj) "`"" ;in order to escape \n and etc
            case "Integer", "Float":
                stringified.=obj
        }

    }
    ok(obj, 0)

    return stringified

}