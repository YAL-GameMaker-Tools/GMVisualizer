package;
import matcher.*;
/**
 * Represents a node type, determining 
 * @author YellowAfterlife
 */
class NodeType {
	public static var nodeTypes:Array<NodeType>;
	public static var nodeTypeText:NodeType;
	public var name:String;
	
	/// matching sequence
	public var nodes:Array<MatchNode>;
	
	/// Whether this node changes indentation
	public var isIndent:Bool = false;
	
	public function new(code:String) {
		nodes = Match.parse(code);
	}
	
	public function read(s:StringReader):Node {
		var m = Match.read(s, nodes);
		if (m == null) return null;
		return new Node(this, m);
	}
	
	private inline function printNodes(v:Node, mode:OutputMode):String {
		return Match.print(nodes, v.match, mode);
	}
	
	public function print(v:Node, mode:OutputMode):String {
		var r = printNodes(v, mode);
		switch (mode) {
		case OutputMode.OmHTML:
			return '<li class="text">$r</li>';
		default: return r;
		}
	}
}
