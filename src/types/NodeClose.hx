package types;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeClose extends NodeBracket {
	public static var inst:NodeClose;
	override public function print(v:Node, mode:OutputMode):String {
		var r = super.print(v, mode);
		switch (mode) {
		case OutputMode.OmHTML:
			return r + '</ul>';
		case OmBB:
			if (Conf.bbIndentMode == Conf.bbIndentModeList) r = '$r\n[/list]';
			return r;
		default: return r;
		}
	}
}