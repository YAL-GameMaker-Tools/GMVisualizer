package types.gmx;

import matcher.MatchResult;
import types.NodeEvent;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeGmxEvent extends NodeEvent {
	public var text:String;
	public function new(code:String, icon:Int, name:String) {
		super(code, icon);
		text = name + ":";
	}
	override public function read(s:StringReader):Node {
		var node = super.read(s);
		if (node == null) return null;
		var mt = node.match;
		var values = mt.values;
		var xml = values[values.length - 1];
		var info = new Info();
		info.optIndent = false;
		info.readString(xml);
		node.extra = mt;
		node.nodes = info.nodes;
		node.match = { };
		return node;
	}
	override public function printText(v:Node, mode:OutputMode):String {
		return text;
	}
	/*override public function print(v:Node, mode:OutputMode):String {
		var r = super.print(v, mode);
		var values = v.match.values;
		var xml = values[values.length - 1];
		var info = Info.fromString(xml);
		r += "\n";
		r += Info.printNodes(info.nodes, mode, 1);
		return r;
	}*/
}

class NodeGmxCollisionEvent extends NodeGmxEvent {
	override public function printText(v:Node, mode:OutputMode):String {
		var mt:MatchResult = v.extra;
		return "Collision Event with object " + mt.values[0] + ":";
	}
}

class NodeGmxEventAny extends NodeGmxEvent {
	override public function read(s:StringReader):Node {
		var p = s.pos;
		var r = super.read(s);
		if (r != null) {
			s.pos = p;
			super.read(s);
		}
		return r;
	}
	override public function printText(v:Node, mode:OutputMode):String {
		var mt:MatchResult = v.extra;
		var values = mt.values;
		return "Unknown Event (" + values[0] + ":" + values[1] + "):";
	}
}
