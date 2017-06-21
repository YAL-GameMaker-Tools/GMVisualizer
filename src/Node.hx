package;
import matcher.*;
/**
 * Represents a parsed node, such as an action or line of text.
 * @author YellowAfterlife
 */
class Node {
	/// node type
	public var type:NodeType;
	/// matched values
	public var match:MatchResult;
	/// indentation level
	public var indent(default, set):Int = 0;
	private function set_indent(v) {
		indent = v;
		return v;
	}
	/// child nodes (for event type)
	public var nodes:Array<Node>;
	/// purpose-specific data
	public var extra:Any = null;
	
	public function new(type:NodeType, ?match:MatchResult) {
		this.type = type;
		if (match != null) {
			this.match = match;
		} else this.match = { };
	}
	
	public var name(get, never):String;
	inline function get_name() return type.name;
	
	public var isIndent(get, never):Bool;
	inline function get_isIndent() return type.isIndent;
}
