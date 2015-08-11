package types.gmx;

import matcher.MatchResult;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeGmxObject extends NodeType {
	override public function print(v:Node, mode:OutputMode):String {
		var xml:String = v.match.values[0];
		// todo: handle params
		var events = {
			var from = "<events>";
			var start = xml.indexOf(from);
			if (start != -1) {
				var end = xml.indexOf("</events>", start);
				xml.substring(start + from.length, end);
			} else "";
		};
		//
		var r:String = "";
		var info = new Info();
		info.optPostFix = mode != OmGML;
		info.readString(events);
		r += Info.printNodes(info.nodes, mode, 1);
		return r;
	}
}