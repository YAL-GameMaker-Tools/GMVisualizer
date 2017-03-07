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
		//node.match = { };
		return node;
	}
	override public function printText(v:Node, mode:OutputMode):String {
		return text;
	}
	override public function print(v:Node, mode:OutputMode):String {
		switch (mode) {
			case OutputMode.OmGmxGml: {
				var vals = v.match.values;
				var last = vals.length - 1;
				var prev = vals[last];
				vals[last] = ''
				+ '\n      <action>'
				+ '\n        <libid>1</libid>'
				+ '\n        <id>603</id>'
				+ '\n        <kind>7</kind>'
				+ '\n        <userelative>0</userelative>'
				+ '\n        <isquestion>0</isquestion>'
				+ '\n        <useapplyto>-1</useapplyto>'
				+ '\n        <exetype>2</exetype>'
				+ '\n        <functionname></functionname>'
				+ '\n        <codestring></codestring>'
				+ '\n        <whoName>self</whoName>'
				+ '\n        <relative>0</relative>'
				+ '\n        <isnot>0</isnot>'
				+ '\n        <arguments>'
				+ '\n          <argument>'
				+ '\n            <kind>1</kind>'
				+ '\n            <string>' + Info.printNodes(v.nodes, OutputMode.OmGML, 0) + '</string>'
				+ '\n          </argument>'
				+ '\n        </arguments>'
				+ '\n      </action>'
				+ '\n    ';
				var r = super.printText(v, mode);
				vals[last] = prev;
				return r;
			};
			default: return super.print(v, mode);
		}
	}
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
