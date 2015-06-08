package types;

/**
 * "Information about object: " header
 * @author YellowAfterlife
 */
class NodeHeader extends NodeType {
	public static var inst:NodeHeader;
	public function new() {
		super("Information about object: @i");
	}
	override public function print(v:Node, mode:OutputMode):String {
		var r = matcher.Match.print(nodes, v.match, mode);
		switch (mode) {
		case OutputMode.OmHTML:
			return '<h2>$r</h2>';
		case OutputMode.OmBB:
			return data.BBStyle.get("h2", r);
		default: return r;
		}
	}
}