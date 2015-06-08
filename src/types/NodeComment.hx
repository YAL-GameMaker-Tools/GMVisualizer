package types;

/**
 * Comment action (special printing rule)
 * @author YellowAfterlife
 */
class NodeComment extends NodeAction {
	override public function printText(v:Node, mode:OutputMode):String {
		switch (mode) {
		case OmHTML:
			return '<span class="comment">'
				+ '<span class="prefix">COMMENT: </span>'
				+ StringTools.htmlEscape(v.match.values[0])
				+ '</span>';
		case OmBB: return data.BBStyle.get("comment",
			data.BBStyle.get("comment prefix", "COMMENT: ") + v.match.values[0]);
		default: return super.printText(v, mode);
		}
	}
}