package types.gmx;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeGmxComment extends NodeType {
	public function new() {
		super("<!--@{ml}-->");
	}
	override public function print(v:Node, mode:OutputMode):String {
		switch (mode) {
			case OutputMode.OmGmxGml: {
				return super.print(v, mode);
			};
			default: return "";
		}
	}
}
