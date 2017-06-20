package;

/**
 * ...
 * @author YellowAfterlife
 */
class Code {
	public static var isFunc:Map<String, Bool>;
	public static var isVar:Map<String, Bool>;
	public static var isInst:Map<String, Bool>;
	public static var isStd:Map<String, Bool>;
	public static var resPfx:Array<String> = [];
	public static var end:String = null;
	public static function init() {
		var t:Array<String>, m:Map<String, Bool>;
		//
		isFunc = m = new Map();
		t = data.BuiltinFunctions.get().split("|");
		for (s in t) m[s] = true;
		//
		isVar = m = new Map();
		isInst = new Map();
		t = data.BuiltinVariables.global().split("|");
		for (s in t) m[s] = true;
		t = data.BuiltinVariables.instance().split("|");
		for (s in t) {
			m[s] = true;
			isInst[s] = true;
		}
		t = data.BuiltInConstants.get().split("|");
		for (s in t) m[s] = true;
		//
		isStd = m = new Map();
		for (s in isVar.keys()) m[s] = isVar[s];
		for (s in isFunc.keys()) m[s] = isFunc[s];
	}
	public static var multiline:Bool = false;
	public static var node:CodeNode;
	public static function readNode(s:StringReader, list:Array<CodeNode>):Bool {
		var ofs:Int;
		inline function add(v:CodeNode):Bool {
			list.push(node = v);
			return false;
		}
		inline function part(start:Int, end:Int):String {
			return s.str.substring(start, end);
		}
		while (!s.eof) {
			var last:Int = s.pos;
			var c:Int = s.charAt(s.pos++);
			inline function addHex() {
				while (s.cond) {
					switch (s.charAt(++s.pos)) {
					case"0".code, "1".code, "2".code, "3".code, "4".code,
						"5".code, "6".code, "7".code, "8".code, "9".code,
						"a".code, "b".code, "c".code, "d".code, "e".code, "f".code,
						"A".code, "B".code, "C".code, "D".code, "E".code, "F".code:
						continue;
					default:
					}
					break;
				}
				return add(CoNumber(part(last, s.pos), CnHexadecimal));
			}
			switch (c) {
			case " ".code, "\t".code, "\r".code, "\n".code: //{
				if ((c == "\r".code || c == "\n".code) && !multiline) return true;
				s.pos--;
				while (!s.eof) {
					s.pos++;
					switch (s.curr) {
					case " ".code, "\t".code: continue;
					case "\r".code, "\n".code:
						if (multiline) continue;
					}; break;
				}; list.push(CoSpace(part(last, s.pos)));
				var e = end;
				if (e != null && s.skipEqual(e)) return true;
				if (multiline && s.str.substr(s.pos, 14) == "if expression ") {
					var s_pos = s.pos;
					var ln = s.str.indexOf("\n", s_pos);
					var i:Int = s.str.indexOf("is true\n", s_pos);
					if (i >= 0 && i < ln) {
						return true;
					} else {
						i = s.str.indexOf("is not true\n", s_pos);
						if (i >= 0 && i < ln) return true;
					}
				}
			//} whitespace
			case ".".code: //{
				c = s.curr;
				if (c >= "0".code && c <= "9".code) { // .05
					s.pos--; do {
						c = s.charAt(++s.pos);
					} while (c >= "0".code && c <= "9".code);
					return add(CoNumber(s.str.substring(last, s.pos), CnDecimal));
				} else return add(CoDot);
			//} "."
			case ",".code: return add(CoComma);
			case ";".code: return add(CoSemico);
			case ":".code:
				if (s.curr == "=".code) {
					s.pos++;
					return add(CoOp(":="));
				} else return add(CoColon);
			case "=".code:
				if (s.curr == "=".code) {
					s.pos++;
					return add(CoOp("=="));
				} else return add(CoAOp("="));
			case "!".code:
				if (s.curr == "=".code) {
					s.pos++;
					return add(CoOp("!="));
				} else return add(CoUOp("!"));
			case "+".code, "-".code:
				if (s.curr == c) { // ++/--
					return add(CoOp(part(last, ++s.pos)));
				} else if (s.curr == "=".code) {
					return add(CoAOp(part(last, ++s.pos)));
				} else return add(CoOp(part(last, s.pos)));
			case "*".code, "%".code:
				if (s.curr == "=".code) {
					s.pos++;
					return add(CoAOp(part(last, ++s.pos)));
				} else return add(CoOp(part(last, s.pos)));
			case "/".code: //{
				switch (s.curr) {
				case "=".code: s.pos++; return add(CoAOp("/="));
				case "/".code: // comment line
					while (s.cond) {
						switch (s.charAt(++s.pos)) {
						case "\r".code, "\n".code:
						default: continue;
						}
						break;
					}
					add(CoComment(part(last, s.pos)));
				case "*".code: // multi-line comment
					while (s.cond) {
						var c0 = c;
						c = s.charAt(++s.pos);
						if (c == "/".code && c0 == "*".code) break;
					}
					add(CoComment(part(last, ++s.pos)));
				default: return add(CoOp("/"));
				}
			//} "/"
			case "<".code, ">".code:
				if (s.curr == c || s.curr == "=".code) s.pos++;
				return add(CoOp(part(last, s.pos)));
			case "&".code, "|".code, "^".code:
				if (s.curr == "=".code) {
					return add(CoAOp(part(last, ++s.pos)));
				} else if (s.curr == c) s.pos++;
				return add(CoOp(part(last, s.pos)));
			case '"'.code, "'".code:
				while (!s.eof) {
					if (s.curr == c) break;
					s.pos++;
				}
				if (s.eof) return true;
				s.pos++;
				return add(CoString(part(last, s.pos)));
			case "$".code: s.pos--; return addHex();
			case "@".code, "#".code, "?".code: return add(CoAAC(c));
			case "~".code: return add(CoUOp("~"));
			case "(".code: return add(CoPar0);
			case ")".code: return add(CoPar1);
			case "[".code: return add(CoSqb0);
			case "]".code: return add(CoSqb1);
			case "{".code: return add(CoCub0);
			case "}".code: return add(CoCub1);
			default:
				if((c >= "a".code && c <= "z".code)
				|| (c >= "A".code && c <= "Z".code)
				|| (c == "_".code)) { // ident
					s.pos--;
					do {
						s.pos++;
						c = s.curr;
					} while ((c == "_".code)
					|| (c >= "a".code && c <= "z".code)
					|| (c >= "A".code && c <= "Z".code)
					|| (c >= "0".code && c <= "9".code));
					var word = s.str.substring(last, s.pos);
					switch (word) {
					case"var", "globalvar", "if", "then", "else",
						"exit", "return", "break", "continue", "goto",
						"for", "while", "do", "until", "repeat", "with",
						"switch", "case", "default", "enum",
						"todo":
						node = CoKeyword(word);
					case "self", "other", "global", "local", "all", "noone":
						node = CoWord(word, CwStdSpec);
					case "and", "or", "xor", "div", "mod":
						node = CoOp(word);
					case "not": node = CoUOp(word);
					default:
						if (isStd[word]) {
							node = CoWord(word, CwStdVar);
						} else {
							var res = false;
							for (v in resPfx) {
								if (StringTools.startsWith(word, v)) {
									res = true;
									break;
								}
							}
							node = CoWord(word, res ? CwResource : CwUserVar);
						}
					}
					list.push(node);
					return false;
				} else if ((c >= "0".code && c <= "9".code) || c == ".".code) {
					var dot = false;
					if (s.curr == "x".code) return addHex();
					s.pos--;
					do {
						c = s.charAt(++s.pos);
						if (c == ".".code && !dot) {
							dot = true;
							s.pos++;
							c = s.curr;
						}
					} while (c >= "0".code && c <= "9".code);
					node = CoNumber(s.str.substring(last, s.pos), CnDecimal);
					list.push(node);
					return false;
				} else return true;
			}
		}
		return true;
	}
	/// Forbid suffixes
	public static inline var NO_SFX:Int = 0x1;
	/// Forbid trailing operators
	public static inline var NO_OPS:Int = 0x2;
	/// Forbid func()
	public static inline var NO_CALL:Int = 0x4;
	/// Forbid post-increment/decrement
	public static inline var NO_PCR:Int = 0x8;
	/**
	 * Reads a single expression ("value").
	 * @param	s    StringReader to read from.
	 * @param	list List to push CodeNodes to.
	 * @param	dont Forbidden structures (see NO_*)
	 * @return
	 */
	public static function readExpr(s:StringReader, list:Array<CodeNode>, dont:Int = 0):Bool {
		//
		var pos0:Int, len0:Int;
		inline function store() { pos0 = s.pos; len0 = list.length; }
		inline function rewind() {
			s.pos = pos0;
			list.splice(len0, list.length - len0);
			return true;
		}
		//
		var pos1:Int, len1:Int;
		inline function storeAlt() { pos1 = s.pos; len1 = list.length; }
		inline function rewindAlt() {
			s.pos = pos1;
			list.splice(len1, list.length - len1);
			return true;
		}
		// prefix:
		store();
		do {
			if (readNode(s, list)) return rewind();
			switch (node) {
			case CoOp(s) :
				switch (s) {
				case "+", "-", "++", "--": continue;
				}
			case CoUOp(_): continue;
			default:
			}
			break;
		} while (!s.eof);
		// value:
		var index = list.length - 1;
		switch (node) {
		// constants:
		case CoNumber(_):
		case CoString(_):
		// potential variable/object/function:
		case CoWord(s, _):
		case CoPar0: //{ (expr)
			if (readExpr(s, list, 0)) return rewind();
			if (readNode(s, list)) return rewind();
			switch (node) {
			case CoPar1:
			default: return rewind();
			}
			dont |= NO_SFX;
		//}
		default: return rewind();
		}
		// suffix:
		var proc = true;
		while (proc && !s.eof) {
			store();
			/// rewinds to the last saved point, but does not terminate parsing.
			inline function sfx_rewind():Void {
				s.pos = pos0;
				list.splice(len0, list.length - len0);
				proc = false;
			}
			if (readNode(s, list)) {
				sfx_rewind();
				break;
			}
			switch (node) {
			case CoOp("++"), CoOp("--"): //{ ++/--
				if ((dont & NO_PCR) == 0) {
					dont |= NO_SFX | NO_PCR;
				} else {
					rewind();
					proc = false;
				}
				//}
			case CoOp(_), CoAOp("="): //{ + ...
				if ((dont & NO_OPS) == 0) {
					while (!s.eof) {
						if (readExpr(s, list, NO_OPS)) {
							sfx_rewind();
							break;
						}
						dont |= NO_SFX;
						store();
						if (s.eof) break;
						if (readNode(s, list)) {
							sfx_rewind();
							break;
						}
						switch (node) {
						case CoAOp("="): continue;
						case CoOp(_): continue;
						default:
						}
						sfx_rewind();
						break;
					}
				} else {
					rewind();
					proc = false;
				}
			//}
			case CoPar0: //{ func(...)
				if ((dont & (NO_SFX | NO_CALL)) == 0) {
					switch (list[index]) {
					case CoWord(id, t):
						var seenComma = true;
						while (proc && s.cond) {
							var ppos = s.pos;
							var plen = list.length;
							if (readNode(s, list)) return rewind();
							switch (node) {
							case CoComma: // ",": Error on duplicate commas, else OK
								if (seenComma) return rewind();
								seenComma = true;
								continue;
							case CoPar1: // "(": End parsing.
								proc = false;
							default: // step back and parse as an expression:
								s.pos = ppos;
								list.splice(plen, list.length - plen);
								if (readExpr(s, list, 0)) return rewind();
								seenComma = false;
								continue;
							}
							break;
						}
						switch (t) {
						case CwStdVar: list[index] = CoWord(id, CwStdFunc);
						case CwUserVar: list[index] = CoWord(id, CwUserFunc);
						default:
						}
						proc = true;
						dont |= NO_SFX;
					default: sfx_rewind();
					}
				} else sfx_rewind();
			//} func
			case CoDot: //{ expr.property
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoWord(id, t):
					switch (t) {
					case CwUserVar:
						list[list.length - 1] = CoWord(id, CwField);
					default:
					}
				default: return rewind();
				}
				dont |= NO_CALL;
			//} expr.property
			case CoSqb0: //{ expr[...]
				if ((dont & NO_SFX) == 0) {
					// check for array access chars:
					storeAlt();
					if (readNode(s, list)) return rewind();
					switch (node) {
					case CoAAC(_), CoOp("|"):
					default: rewindAlt();
					}
					//
					if (readExpr(s, list, 0)) return rewind();
					if (readNode(s, list)) return rewind();
					switch (node) {
					case CoComma: // [i, j]
						if (readExpr(s, list)) return rewind();
						if (readNode(s, list)) return rewind();
						switch (node) {
						case CoSqb1: dont |= NO_SFX;
						default: return rewind();
						}
					case CoSqb1: dont |= NO_SFX;
					default: return rewind();
					}
				} else sfx_rewind();
			//} expr[...]
			default: sfx_rewind();
			}
		}
		return false;
	}
	static function readSemico(s:StringReader, list:Array<CodeNode>):Void {
		var pos0:Int, len0:Int;
		inline function store() { pos0 = s.pos; len0 = list.length; }
		inline function rewind() {
			s.pos = pos0;
			list.splice(len0, list.length - len0);
			return true;
		}
		// catch semicolons:
		store();
		while (s.cond) {
			if (readNode(s, list)) {
				rewind();
				break;
			}
			switch (node) {
			case CoSemico:
				store();
				continue;
			default: rewind();
			}; break;
		}
	}
	/**
	 * Reads a "single-line" expression (function call, assignment, if-then-else, ...)
	 */
	public static function readLine(s:StringReader, list:Array<CodeNode>):Bool {
		//
		var pos0:Int, len0:Int;
		inline function store() { pos0 = s.pos; len0 = list.length; }
		inline function rewind() {
			s.pos = pos0;
			list.splice(len0, list.length - len0);
			return true;
		}
		//
		var pos1:Int, len1:Int;
		inline function storeAlt() { pos1 = s.pos; len1 = list.length; }
		inline function rewindAlt() {
			s.pos = pos1;
			list.splice(len1, list.length - len1);
			return true;
		}
		//
		store();
		if (readNode(s, list)) return rewind();
		switch (node) {
		case CoWord(_), CoPar0: //{ CoWord
			rewind();
			if (readExpr(s, list, NO_OPS | NO_CALL | NO_PCR)) return rewind();
			storeAlt();
			if (readNode(s, list)) {
				rewindAlt();
			} else switch (node) {
			case CoPar0, CoOp("++"), CoOp("--"): // "word("
				rewind();
				if (readExpr(s, list, 0)) return rewind();
			case CoAOp(_): // "word += "
				if (readExpr(s, list, 0)) return rewind();
			default: return rewind();
			}
		//}
		case CoOp("++"), CoOp("--"): //{ ++var, --var
			rewind();
			if (readExpr(s, list, NO_OPS | NO_CALL)) return rewind();
		//}
		case CoKeyword(kw): //{
			switch (kw) {
			case "break", "continue", "exit":
			case "return", "goto": //{ [word] expr
				if (readExpr(s, list)) return rewind();
			//}
			case "if": //{ if-then-else
				// condition:
				if (readExpr(s, list, 0)) return rewind();
				// "then" optional:
				storeAlt();
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoKeyword("then"):
				default: rewindAlt();
				}
				// then-expression:
				if (readLine(s, list)) return rewind();
				// "else"-branch (optional):
				storeAlt();
				if (readNode(s, list)) {
					rewindAlt();
				} else switch (node) {
				case CoKeyword("else"):
					// else-expression:
					if (readLine(s, list)) return rewind();
				default: rewindAlt();
				}
			//} if
			case "with", "repeat", "while": //{ kw (value) block;
				if (readExpr(s, list, 0)) return rewind();
				if (readLine(s, list)) return rewind();
			//}
			case "do": //{ do block until value
				if (readLine(s, list)) return rewind();
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoKeyword("until"):
					if (readExpr(s, list)) return rewind();
				default: return rewind();
				}
			//}
			case "for": //{ for (block; expr; block) block
				// "(":
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoPar0:
				default: return rewind();
				}
				// init:
				if (readLine(s, list)) return rewind();
				// cond:
				if (readExpr(s, list)) return rewind();
				readSemico(s, list);
				// post:
				if (readLine(s, list)) return rewind();
				// ")":
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoPar1:
				default: return rewind();
				}
				// in-loop:
				if (readLine(s, list)) return rewind();
			//}
			case "switch": //{ switch value ...
				if (readExpr(s, list)) return rewind();
				if (readLine(s, list)) return rewind();
			//}
			case "case": //{ case value:
				if (readExpr(s, list)) return rewind();
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoColon:
				default: return rewind();
				}
			//}
			case "default", "todo": //{ default:
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoColon:
				default: return rewind();
				}
			//}
			case "var", "globalvar": //{
				while (s.cond) {
					storeAlt();
					if (readNode(s, list)) {
						rewindAlt();
						break;
					}
					switch (node) {
					case CoComma: continue;
					case CoWord(_, _):
						var pos2 = s.pos;
						var len2 = list.length;
						inline function rewindVar() {
							s.pos = pos2;
							list.splice(len2, list.length - len2);
						}
						if (!readNode(s, list)) {
							switch (node) {
							case CoAOp(_): // name = value
								if (!readExpr(s, list, 0)) continue;
							case CoSemico:
								rewindVar();
								// [break]
							case CoPar0:
								rewindAlt();
								// [break]
							default:
								rewindVar();
								continue;
							}
						} else rewindAlt();
					default: rewindAlt();
					} // switch (node)
					break;
				}
			//}
			case "enum": //{ enum { v1, v2 = 10 }
				// enum name:
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoWord(_, _):
				default: return rewind();
				}
				// `{`:
				if (readNode(s, list)) return rewind();
				switch (node) {
				case CoCub0:
				default: return rewind();
				}
				while (s.cond) {
					if (readNode(s, list)) return rewind();
					switch (node) {
					case CoComma: continue;
					case CoWord(_, _):
						storeAlt();
						if (readNode(s, list)) return rewind();
						switch (node) {
						case CoAOp(_):
							if (readExpr(s, list)) return rewind();
						default: rewindAlt();
						}
						continue;
					case CoCub1: // advance
					default: return rewind();
					}
					break;
				}
			//}
			default: return rewind();
			}
		//} CoKeyword
		case CoCub0: //{ "{ ... }"
			if (readLines(s, list)) return rewind();
			if (readNode(s, list)) return rewind();
			switch (node) {
			case CoCub1:
			default: return rewind();
			}
		//}
		default: return rewind();
		}
		readSemico(s, list);
		return false;
	}
	public static function readLines(s:StringReader, list:Array<CodeNode>):Bool {
		//
		var pos0:Int, len0:Int;
		inline function store() { pos0 = s.pos; len0 = list.length; }
		inline function rewind() {
			s.pos = pos0;
			list.splice(len0, list.length - len0);
			return true;
		}
		//
		while (s.cond) {
			store();
			if (readNode(s, list)) {
				rewind();
				break;
			}
			switch (node) {
			case CoCub1: // "}"
				rewind();
				return false;
			default:
				rewind();
				if (!readLine(s, list)) continue;
			}; break;
		}
		// post-catch trailing comments
		store();
		var trail = true;
		while (trail && s.cond) {
			var start:Int = s.pos++;
			var c:Int = s.charAt(start);
			switch (c) {
			case " ".code, "\t".code, "\r".code, "\n".code:
				s.pos--;
				while (s.cond) {
					switch (s.charAt(++s.pos)) {
					case " ".code, "\t".code, "\r".code, "\n".code: continue;
					default:
					}; break;
				}; list.push(CoSpace(s.str.substring(start, s.pos)));
			case ";".code: list.push(CoSemico); store();
			case "/".code: //{
				switch (s.curr) {
				case "/".code:
					while (s.cond) {
						switch (s.charAt(++s.pos)) {
						case "\r".code, "\n".code: // [break]
						default: continue;
						}; break;
					}
					list.push(CoComment(s.str.substring(start, s.pos)));
					store();
				case "*".code:
					while (s.cond) {
						var c0 = c;
						c = s.charAt(++s.pos);
						if (c0 == "*".code && c == "/".code) break;
					}
					if (s.cond) {
						list.push(CoComment(s.str.substring(start, ++s.pos)));
						store();
					} else trail = false;
				default: trail = false;
				} // switch
			//} "/"
			default: trail = false;
			} // switch @ trail
		}
		rewind();
		//
		return false;
	}
	
	public static function print(node:CodeNode, mode:OutputMode, ?pre:Bool) {
		inline function escape(str:String) {
			return StringTools.htmlEscape(str);
		}
		var html = switch (mode) {
		case OmHTML: true;
		default: false;
		}
		inline function bbs(style:String, value:String) {
			return data.BBStyle.get(style, value);
		}
		inline function wrap(s:String, v:String) {
			return switch (mode) {
			case OmHTML: '<span class="$s">$v</span>';
			case OmBB: data.BBStyle.get('code $s', v);
			default: v;
			}
		}
		return switch (node) {
		case CoSpace(s):
			if (html) {
				if (!pre) {
					s = StringTools.replace(s, " ", "&nbsp;");
					s = StringTools.replace(s, "\n", "<br/>");
				}
				s;
			} else s;
		case CoComma: ',';
		case CoDot: '.';
		case CoColon: ':';
		case CoSemico: ';';
		case CoComment(s): wrap("co", escape(s));
		case CoWord(s, t):
			switch (t) {
			case CwNormal: wrap("id", s);
			case CwStdVar: wrap("sv", s);
			case CwStdFunc: wrap("sf", s);
			case CwStdSpec: wrap("sp", s);
			case CwUserVar: wrap("uv", s);
			case CwUserFunc: wrap("uf", s);
			case CwField: wrap("fd", s);
			case CwResource: wrap("ri", s);
			}
		case CoKeyword(s): wrap("kw", s);
		case CoNumber(s, t):
			switch (t) {
			case CnDecimal: wrap("nu", s);
			case CnHexadecimal: wrap("nx", s);
			}
		case CoString(s): wrap("st", escape(s));
		case CoAOp(s): wrap("op", html ? escape(s) : s);
		case CoOp(s), CoUOp(s):
			switch (s) {
			case "and", "or", "xor", "not", "div", "mod":
				wrap("kw", s);
			default: wrap("op", html ? escape(s) : s);
			}
		case CoAAC(c): wrap("op", String.fromCharCode(c));
		case CoPar0: "(";
		case CoPar1: ")";
		case CoSqb0: "[";
		case CoSqb1: "]";
		case CoCub0: "{";
		case CoCub1: "}";
		case CoHash: "#";
		}
	}
	public static function printNodes(nodes:Array<CodeNode>, mode:OutputMode):String {
		var r = "";
		for (node in nodes) r += print(node, mode);
		return r;
	}
}

enum CodeNode {
	CoSpace(s:String); // whitespace
	CoComma; // ,
	CoDot; // .
	CoColon; // :
	CoSemico; // ;
	CoComment(s:String); // "//" / "/* */"
	CoWord(s:String, t:CodeWordType); // word
	CoKeyword(s:String); // keyword
	CoNumber(s:String, t:CodeNumberType); // 34.1
	CoString(s:String); // "words"
	CoOp(s:String); // +
	CoAOp(s:String); // +=
	CoUOp(s:String); // ~/!/..
	CoAAC(c:Int); // array access chars
	CoPar0; // (
	CoPar1; // )
	CoSqb0; // [
	CoSqb1; // ]
	CoCub0; // {
	CoCub1; // }
	CoHash; // #
}

enum CodeNumberType {
	CnDecimal;
	CnHexadecimal;
}

enum CodeWordType {
	/// "id": Anything that doesn't fall into other category
	CwNormal;
	/// "sv": Built-in variable
	CwStdVar;
	/// "sf": Built-in function
	CwStdFunc;
	/// "sp": Built-in special (self/other/global/local/all/noone)
	CwStdSpec;
	/// "uv": User-defined variable
	CwUserVar;
	/// "uf": User-defined function
	CwUserFunc;
	/// "fd": Field access (inst.field)
	CwField;
	/// "ri": Resource index
	CwResource;
}
