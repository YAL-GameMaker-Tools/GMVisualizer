package types.code;
import types.code.NodeCode;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeCodeRaw extends NodeCode {
	override public function print(v:Node, mode:OutputMode):String {
		var r = printText(v, mode);
		return switch (mode) {
		case OutputMode.OmHTML: r;
		default: r;
		}
	}
}