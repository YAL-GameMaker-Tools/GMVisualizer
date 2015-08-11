package types.gmx;

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
		var values = node.match.values;
		var xml = values[values.length - 1];
		var info = Info.fromString(xml);
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

class NodeGmxEventAny extends NodeGmxEvent {
	override public function printText(v:Node, mode:OutputMode):String {
		var values = v.match.values;
		return "Event " + values[0] + ":" + values[1] + ":";
	}
}