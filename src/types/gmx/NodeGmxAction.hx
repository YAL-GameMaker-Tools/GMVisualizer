package types.gmx;
import matcher.MatchResult;
import types.NodeAction;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeGmxAction extends NodeType {
	public var action:NodeAction;
	public var arguments:String;
	public function new(code:String, node:NodeAction, args:String) {
		super(code);
		action = node;
		arguments = args;
	}
	override public function read(s:StringReader):Node {
		var r0 = super.read(s);
		if (r0 == null) return null;
		var xml:String = r0.match.values[0];
		var m:MatchResult = { };
		var pos:Int, end:Int, len:Int;
		var seek:String;
		if (xml.indexOf("<relative>-1</relative>") >= 0) m.relative = true;
		if (xml.indexOf("<isnot>-1</isnot>") >= 0) m.not = true;
		seek = "<whoName>";
		pos = xml.indexOf(seek);
		if (pos >= 0) {
			pos += seek.length;
			end = xml.indexOf("</whoName>", pos);
			var with = xml.substring(pos, end);
			if (with != "self") m.with = with;
		}
		var meta = arguments;
		seek = "<arguments>";
		pos = xml.indexOf(seek);
		if (meta != null && pos >= 0) {
			pos += seek.length;
			end = xml.indexOf("</arguments>");
			var xmlArgs = xml.substring(pos, end);
			// read arguments:
			var args:Array<String> = [];
			seek = "<kind>";
			len = seek.length;
			pos = xmlArgs.indexOf("<kind>");
			while (pos != -1) {
				pos = xmlArgs.indexOf("</kind>", pos + 6);
				pos = xmlArgs.indexOf(">", pos + 7) + 1;
				end = xmlArgs.indexOf("<", pos);
				args.push(xmlArgs.substring(pos, end));
				pos = xmlArgs.indexOf("<kind>", pos);
			}
			// parse arguments:
			var values:Array<Dynamic> = [];
			pos = 0;
			len = meta.length;
			while (pos < len) {
				var id = StringTools.fastCodeAt(meta, pos++) - "0".code;
				var data = args[id];
				if (data == null) data = "";
				var value:Dynamic;
				switch (StringTools.fastCodeAt(meta, pos++)) {
				case "e".code:
					var list = [];
					Code.readExpr(new StringReader(data), list);
					value = list;
				case "E".code:
					var list = [];
					Code.readLines(new StringReader(data), list);
					value = list;
				case "[".code:
					end = meta.indexOf("]", pos);
					var options = meta.substring(pos, end).split("|");
					pos = end + 1;
					value = options[Std.parseInt(data)];
					if (value == null) trace('Cannot get $data from $options');
				default:
					value = data;
				}
				values.push(value);
			}
			m.values = values;
		}
		return new Node(action, m);
	}
}