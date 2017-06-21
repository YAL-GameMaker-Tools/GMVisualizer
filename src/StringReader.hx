package;

/**
 * ...
 * @author YellowAfterlife
 */
class StringReader {
	/// Input string
	public var str:String;
	/// Current position
	public var pos:Int;
	/// Input length
	public var len:Int;
	/// Charcode of the current symbol
	public var curr(get, never):Int;
	inline function get_curr() return StringTools.fastCodeAt(str, pos);
	/// Whether end of inupt has been reached yet
	public var eof(get, never):Bool;
	inline function get_eof() return pos >= len;
	/// Do you ever get a feeling that you only ever use "!eof"?
	public var cond(get, never):Bool;
	inline function get_cond() return pos < len;
	public function new(s:String) {
		str = StringTools.replace(s, "\r\n", "\n");
		pos = 0;
		len = str.length;
	}
	public inline function charAt(i:Int):Int return str.charCodeAt(i);
	public inline function skipEqual(s:String):Bool {
		var n = s.length;
		if (str.substr(pos, n) == s) {
			pos += n;
			return true;
		} else return false;
	}
	public function readWhileIn(chars:String):String {
		var p0:Int = pos;
		while (pos < len) {
			if (chars.indexOf(str.charAt(pos)) < 0) break;
			pos++;
		}
		return str.substring(p0, pos);
	}
	public function readUntilIn(chars:String):String {
		var p0:Int = pos;
		while (pos < len) {
			if (chars.indexOf(str.charAt(pos)) >= 0) break;
			pos++;
		}
		return str.substring(p0, pos);
	}
	public function readUntilChar(c:Int):String {
		var p0:Int = pos;
		while (pos < len) {
			if (str.charCodeAt(pos) == c) break;
			pos++;
		}
		return str.substring(p0, pos);
	}
}
