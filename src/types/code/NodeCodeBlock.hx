package types.code;
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
	#if (dnd_to_gml)
	override public function print(v:Node, mode:OutputMode):String {
		switch (mode) {
			case OmHTML: return super.printText(v, mode);
			default: return super.print(v, mode);
		}
	}
	#end
}
