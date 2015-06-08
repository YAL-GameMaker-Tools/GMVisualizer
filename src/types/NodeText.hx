package types;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeText extends NodeType {
	override public function print(v:Node, mode:OutputMode):String {
		var r = super.print(v, mode);
		switch (mode) {
		case OutputMode.OmGML:
			return 'todo: /* $r */';
		default: return r;
		}
	}
}