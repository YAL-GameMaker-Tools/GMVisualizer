package types.gmx;

import matcher.MatchResult;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeGmxObject extends NodeType {
	private var eventsParam:Int;
	public function new(code:String, eventsParam:Int) {
		super(code);
		this.eventsParam = eventsParam;
	}
	override public function print(v:Node, mode:OutputMode):String {
		var vals = v.match.values;
		var events = vals[eventsParam];
		var r:String = "";
		if (events != null) {
			var info = new Info();
			info.optPostFix = mode != OmGML;
			info.optIndent = false;
			info.readString(events);
			r += Info.printNodes(info.nodes, mode, 1);
		}
		if (mode == OutputMode.OmGmxGml) {
			if (events != null) {
				r = "\n    " + r + "\n  ";
				vals[eventsParam] = r;
			}
			r = super.print(v, mode);
			if (events != null) vals[eventsParam] = events;
		}
		return r;
	}
}
