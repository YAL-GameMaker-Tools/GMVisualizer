package matcher;
import data.BBStyle;
import matcher.MatchNode;
import Code;
/**
 * ...
 * @author YellowAfterlife
 */
class Match {
	/**
	 * Creates a MatchNode list from given code.
	 * Supported tags are:
	 * "@w": Optional "for *" prefix
	 * "@r": Optional "relative "
	 * "@N": Optional "not "
	 * "@[word1|word2]": Value set (any of listed)
	 * "@L": String spanning until the end of line.
	 * "@i": Resource index (or "<undefined>")
	 * "@c": A 24-bit color (BBGGRR)
	 * "@e": An expression
	 * "@{code}": Multi-line expression
	 * "@{eu}": "cautious" expression (stops at the next text node)
	 * "@{su}": "cautious" string (ditto above)
	 * @param	s	Code to parse from
	 */
	public static function parse(s:String):Array<MatchNode> {
		var pos:Int = 0;
		var len:Int = s.length;
		var ofs:Int = 0;
		var nodes = [];
		while (pos < len) {
			var c = s.charCodeAt(pos);
			if (c == "\n".code) {
				if (pos > ofs) nodes.push(MnText(s.substring(ofs, pos)));
				nodes.push(MnLN);
				pos++;
				ofs = pos;
			} else if (c == "@".code) {
				if (pos > ofs) nodes.push(MnText(s.substring(ofs, pos)));
				pos++;
				switch (s.charCodeAt(pos++)) {
				case "r".code: nodes.push(MnRelative);
				case "N".code: nodes.push(MnNot);
				case "L".code: nodes.push(MnEOL);
				case "i".code: nodes.push(MnResource);
				case "w".code: nodes.push(MnWith);
				case "c".code: nodes.push(MnColor);
				case "]".code: nodes.push(MnSpaces);
				case "e".code:
					nodes.push(MnExpr);
					if (s.charCodeAt(pos) == " ".code) {
						pos++;
						nodes.push(MnSpaces);
					}
				case "{".code:
					ofs = pos;
					pos = s.indexOf("}", ofs);
					switch (s.substring(ofs, pos++)) {
					case "code": nodes.push(MnCode);
					case "su": nodes.push(MnStringUntil);
					case "ml": nodes.push(MnMultiline);
					case "eu":
						nodes.push(MnExprUntil);
						if (s.charCodeAt(pos) == " ".code) {
							pos++;
							nodes.push(MnSpaces);
						}
					default: throw "Unknown {type} " + s.substring(ofs, pos);
					}
				case "[".code:
					ofs = pos;
					pos = s.indexOf("]", ofs);
					nodes.push(MnSet(s.substring(ofs, pos).split("|")));
					pos++;
				default: throw "Unknown type " + s.charAt(pos - 1);
				}
				ofs = pos;
			} else pos++;
		}
		if (pos > ofs) nodes.push(MnText(s.substring(ofs, pos)));
		return nodes;
	}
	
	public static function read(r:StringReader, nodes:Array<MatchNode>):MatchResult {
		var r_str = r.str;
		var out:MatchResult = { };
		var values:Array<Dynamic> = null;
		inline function add(value:Dynamic) {
			if (values == null) {
				out.values = values = [value];
			} else values.push(value);
		}
		//
		inline function substr(pos:Int, len:Int):String {
			return r_str.substr(pos, len);
		}
		//
		var node:MatchNode;
		var nn = nodes.length;
		for (ni in 0 ... nn)
		switch (node = nodes[ni]) {
		case MnText(s):
			var n:Int = s.length;
			if (substr(r.pos, n) != s) return null;
			r.pos += n;
		case MnSpaces: r.readWhileIn(" \t");
		case MnLN:
			switch (r.curr) {
			case "\r".code:
				r.pos++;
				if (r.curr == "\n".code) r.pos++;
			case "\n".code: r.pos++;
			default: return null;
			}
		case MnSet(list):
			var c:Int = list.length;
			var i:Int = 0;
			while (i < c) {
				var item:String = list[i];
				var n:Int = item.length;
				if (substr(r.pos, n) == item) {
					r.pos += n;
					add(item);
					break;
				} else i++;
			}
			if (i >= c) return null;
		case MnWith:
			if (substr(r.pos, 4) == "for ") {
				r.pos += 4;
				if (substr(r.pos, 4) == "all ") {
					r.pos += 4;
					var p0 = r.pos;
					out.with = r.readUntilIn("\n:");
					if (r.curr == ":".code) {
						r.pos++;
						r.readWhileIn(" \t");
					} else r.pos = p0;
				} else if (substr(r.pos, 13) == "other object:") {
					r.pos += 13;
					out.with = "other";
					r.readWhileIn(" \t");
				}
			}
		case MnNot:
			if (substr(r.pos, 4) == "not ") {
				r.pos += 4; out.not = true;
			}
		case MnRelative:
			if (substr(r.pos, 9) == "relative ") {
				r.pos += 9; out.relative = true;
			}
		case MnColor:
			var c = r.curr;
			if (c >= "0".code && c <= "9".code) {
				var ofs = r.pos;
				do {
					r.pos++;
					c = r.curr;
				} while (c >= "0".code && c <= "9".code);
				add(Std.parseInt(r_str.substring(ofs, r.pos)));
			} else return null;
		case MnEOL:
			add(r.readUntilChar("\n".code));
		case MnStringUntil, MnMultiline:
			var s:String = "\n";
			if (ni + 1 < nn) switch (nodes[ni + 1]) {
			case MnText(s1): s = s1;
			default:
			}
			var sl = s.length;
			var c1 = s.charCodeAt(0);
			var p0 = r.pos;
			var noML = (node == MnStringUntil);
			while (r.cond) {
				var c = r.curr;
				if (c == c1 && substr(r.pos, sl) == s) {
					add(r_str.substring(p0, r.pos));
					break;
				} else if (noML && (c == "\n".code || c == "\r".code)) {
					return null;
				} else r.pos++;
			}
			if (r.eof) return null;
		case MnExpr:
			var list = [];
			Code.readExpr(r, list, 0);
			add(list);
		case MnExprUntil:
			var list = [];
			if (ni + 1 < nn) switch (nodes[ni + 1]) {
			case MnSpaces:
				if (ni + 2 < nn) switch (nodes[ni + 2]) {
				case MnText(s): Code.end = s;
				default:
				}
			case MnText(s): Code.end = s;
			default:
			}
			Code.readExpr(r, list, 0);
			Code.end = null;
			add(list);
		case MnCode:
			var list = [];
			Code.multiline = true;
			Code.readLines(r, list);
			Code.multiline = false;
			add(list);
		case MnResource:
			var c = r.curr;
			if((c >= "a".code && c <= "z".code)
			|| (c >= "A".code && c <= "Z".code)
			|| (c == "_".code)) {
				var ofs = r.pos;
				do {
					r.pos++;
					c = r.curr;
				} while ((c == "_".code)
				|| (c >= "a".code && c <= "z".code)
				|| (c >= "A".code && c <= "Z".code)
				|| (c >= "0".code && c <= "9".code));
				add(r_str.substring(ofs, r.pos));
			} else if (c == "<".code) {
				var inner = r.readUntilIn(">\n");
				if (r.curr == ">".code) {
					r.pos++;
					add(inner + ">");
				} else return null;
			} else return null;
		}
		return out;
	}
	public static function print(nodes:Array<MatchNode>, m:MatchResult, mode:OutputMode):String {
		var values = m.values;
		var vi:Int = 0;
		var r:String = "";
		inline function next():Dynamic {
			return values[vi++];
		}
		switch (mode) {
		case OutputMode.OmHTML:
			inline function htmlEscape(text:String):String {
				return StringTools.htmlEscape(text);
			}
			for (n in nodes) switch (n) {
			case MnText(s): r += htmlEscape(s);
			case MnSet(_):
				var s = next();
				r += '<span class="set">' + htmlEscape(s) + '</span>';
			case MnNot: if (m.not) r += '<span class="not">not</span> ';
			case MnRelative: if (m.relative) r += '<span class="relative">relative</span> ';
			case MnSpaces: r += " ";
			case MnLN: r += "<br>";
			case MnWith:
				var m_with = m.with;
				if (m_with == null) continue;
				r += '<span class="with">';
				if (m_with == "other") {
					r += 'for <span class="other">other object</span>: ';
				} else {
					r += 'for all <span class="ri">' + htmlEscape(m_with) + '</span>: ';
				}
				r += '</span>';
			case MnExpr, MnCode, MnExprUntil:
				var list:Array<CodeNode> = next();
				r += '<span class="code">';
				for (codenode in list) r += Code.print(codenode, mode);
				r += '</span>';
			case MnColor:
				var c:Int = next();
				var s:String = '(' + (c & 255) + ", " + ((c >> 8) & 255) + ", " + (c >> 16) + ')';
				r += '<span class="colorbox" title="$s" style="background-color:rgb$s">$c</span>';
			case MnResource: r += '<span class="ri">' + htmlEscape(next()) + '</span>';
			case MnEOL, MnStringUntil, MnMultiline: r += htmlEscape(next());
			}
		case OutputMode.OmBB:
			inline function bbs(s:String, v:String) {
				return BBStyle.get(s, v);
			}
			for (n in nodes) switch (n) {
			case MnText(s): r += s;
			case MnSpaces: r += " ";
			case MnLN: r += "\n";
			case MnSet(_): r += bbs("set", next());
			case MnNot: if (m.not) r += bbs("not", "not") + " ";
			case MnRelative: if (m.relative) r += bbs("relative", "relative") + " ";
			case MnWith:
				var m_with = m.with;
				if (m_with == "other") {
					r += bbs("with", "for " + bbs("other", "other object")) + ": ";
				} else if (m_with != null) {
					r += bbs("with", "for all " + bbs("ri", m_with)) + ": ";
				}
			case MnExpr, MnCode, MnExprUntil:
				var list:Array<CodeNode> = next(), s = "";
				for (n in list) s += Code.print(n, mode);
				r += bbs("expr", s);
			case MnColor:
				r += next();
			case MnResource: r += bbs("ri", next());
			case MnEOL, MnStringUntil, MnMultiline: r += next();
			}
		default:
			for (n in nodes) switch (n) {
			case MnText(s): r += s;
			case MnSpaces: r += " ";
			case MnLN: r += "\n";
			case MnSet(_): r += next();
			case MnNot: r += "not ";
			case MnRelative: if (m.relative) r += "relative ";
			case MnWith:
				var m_with = m.with;
				if (m_with == "other") r += "for other object: ";
				else if (m_with != null) r += 'for all $m_with: ';
			case MnExpr, MnCode, MnExprUntil:
				var codeList:Array<CodeNode> = next();
				for (codeNode in codeList) r += Code.print(codeNode, mode);
			case MnColor: r += next();
			case MnResource: r += next();
			case MnEOL, MnStringUntil, MnMultiline: r += next();
			}
		} // switch (mode)
		return r;
	} // function print
}
