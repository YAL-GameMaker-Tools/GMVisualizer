package types;
import data.BBStyle;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeCodeBlock extends NodeCode {
	override public function printText(v:Node, mode:OutputMode):String {
		var r:String = super.printText(v, mode);
		switch (mode) {
		case OmHTML:
			return "execute code:" + r;
		case OmBB:
			var t = "execute code:";
			if (r != "") {
				return t + "\n" + Conf.bbGetIndent(v.indent) + r;
			} else return t;
		default: return r;
		}
	}
}