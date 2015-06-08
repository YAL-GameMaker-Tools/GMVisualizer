package types;

/**
 * "start of a block" action
 * @author YellowAfterlife
 */
class NodeOpen extends NodeBracket {
	public static var inst:NodeOpen;
	override public function print(v:Node, mode:OutputMode):String {
		var r = super.print(v, mode);
		switch (mode) {
		case OutputMode.OmHTML:
			return '<ul>' + r;
		case OmBB:
			if (Conf.bbIndentMode == Conf.bbIndentModeList) r = '[list]\n$r';
			return r;
		default: return r;
		}
	}
}