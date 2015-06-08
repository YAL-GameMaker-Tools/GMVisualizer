package types;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeSeparator extends NodeType {
	public static var inst:NodeSeparator;
	public function new() {
		super("______________________________________________________");
	}
	override public function print(v:Node, mode:OutputMode):String {
		return "";
	}
}