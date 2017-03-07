package;
import data.*;
import types.*;

/**
 * ...
 * @author YellowAfterlife
 */
class Info {
	public var nodes:Array<Node>;
	
	/** Whether to "unpack" single-action branches from begin/end blocks. */
	public var optPostFix:Bool = true;
	
	/** Whether to detect open/close blocks based on indentation changes. */ 
	public var optIndent:Bool = true;
	
	public function new() {
		nodes = [];
	}
	
	static function postfix(list:Array<Node>) {
		var i = list.length;
		while (--i >= 0) {
			var node:Node = list[i];
			if(i >= 2 && node.type == NodeClose.inst
			&& list[i - 2].type == NodeOpen.inst) {
				var expr = list[i - 1];
				expr.indent--;
				i -= 2;
				list.splice(i, 3);
				list.insert(i, expr);
			}
			if (node.nodes != null) postfix(node.nodes);
		}
	}
	
	public function read(s:StringReader) {
		var i:Int, n:Int;
		var atl = NodeType.nodeTypes;
		var atc = atl.length;
		var etl = types.NodeEvent.eventTypes;
		var etc = etl.length;
		var list = nodes;
		var tabs:Int = 0;
		var next:Int; // next indent level
		var atOpen = types.NodeOpen.inst;
		var atClose = types.NodeClose.inst;
		inline function unindent() {
			if (optIndent) while (next < tabs) {
				var acb = new Node(atClose);
				acb.indent = tabs;
				list.push(acb);
				tabs--;
			}
		}
		while (!s.eof) {
			s.readWhileIn("\r\n");
			next = 0;
			while (!s.eof) {
				var c = s.curr;
				if (c == " ".code) {
					next++;
					s.pos++;
				} else if (c == "\t".code) {
					next += 4;
					s.pos++;
				} else break;
			}
			next = Std.int(next / 6);
			//
			var pos = s.pos;
			var action:Node = null;
			i = 0; while (i < atc) {
				action = atl[i++].read(s);
				if (action == null) {
					s.pos = pos;
				} else break;
			}
			if (action != null) {
				if (optIndent) {
					if (next > tabs) {
						var d = next - tabs;
						if (!action.type.isIndent || d > 1)
						while (--d >= 0) {
							var acb = new Node(atOpen);
							var acp = list.length - d;
							list.insert(acp, acb);
							for (i in acp ... list.length) list[i].indent++;
							tabs++;
							acb.indent = tabs;
						}
					} else if (next < tabs) unindent();
				} else if (action.type == atClose) tabs--;
				action.indent = tabs;
				list.push(action);
				if (!optIndent && action.type == atOpen) tabs++;
			} else { // no action
				var event:Node = null;
				i = 0; while (i < etc) {
					event = etl[i++].read(s);
					if (event == null) {
						s.pos = pos;
					} else break;
				}
				if (event != null) {
					next = 0;
					unindent();
					list = event.nodes;
					if (list == null) {
						event.nodes = list = [];
					}
					nodes.push(event);
				} else { // no event
					if ((action = types.NodeHeader.inst.read(s)) != null) {
						// header
						next = 0;
						unindent();
						nodes.push(action);
						list = nodes;
					} else if ((action = types.NodeSeparator.inst.read(s)) != null) {
						// separator
						next = 0;
						unindent();
						list = nodes;
					} else {
						var text:String = s.readUntilChar("\n".code);
						if (text != "") {
							list.push(new Node(NodeType.nodeTypeText, { values: [text] } ));
						}
					}
				}
			}
		} // while (!s.eof)
		// fix unclosed indents:
		next = 0;
		unindent();
		// swipe to remove single-block openings:
		if (optPostFix) postfix(nodes);
	}
	public function readString(s:String) {
		var n:Int = s.length;
		while (n >= 0) {
			switch (s.charCodeAt(n)) {
			case "\r".code, "\n".code, " ".code:
				n--;
				continue;
			default:
			}
			break;
		}
		if (n < s.length) s = s.substring(0, n);
		s += "\n";
		read(new StringReader(s));
	}
	public static function fromString(s:String):Info {
		var r = new Info();
		r.readString(s);
		return r;
	}
	public static function printNodes(nodes:Array<Node>, mode:OutputMode, tabc:Int):String {
		var r:String = "", first:Bool = true, ln:String;
		if (nodes.length == 0) return r;
		switch (mode) {
		case OutputMode.OmHTML:
			ln = StringTools.rpad("\n", "\t", tabc + 1);
			for (node in nodes) {
				if (first) first = false; else r += ln;
				if (node.nodes == null) {
					r += node.type.print(node, mode);
				} else {
					r += '<div class="event"><p>'
						+ ln + '\t' + node.type.print(node, mode)
					+ ln + '</p><ul>'
						+ ln + '\t' + printNodes(node.nodes, mode, tabc + 1)
					+ ln + '</ul></div>';
				}
			}
		case OutputMode.OmBB:
			ln = "\n";
			if (Conf.bbIndentMode == Conf.bbIndentModeList) r += '[list]$ln';
			for (node in nodes) {
				if (first) first = false; else r += ln;
				if (node.nodes == null) {
					r += Conf.bbGetIndent(node.indent);
					r += BBStyle.get("node", node.type.print(node, mode));
				} else {
					r += BBStyle.get("event p", node.type.print(node, mode))
					+ ln + BBStyle.get("event ul", printNodes(node.nodes, mode, tabc + 1));
				}
			}
			if (Conf.bbIndentMode == Conf.bbIndentModeList) r += '$ln[/list]';
		case OutputMode.OmGML:
			ln = "\n";
			var last:Node = null;
			var indentMode:Int = Conf.gmlIndentMode;
			var index:Int = -1;
			while (++index < nodes.length) {
				var node:Node = nodes[index];
				var indentLevel:Int = node.indent;
				var concat:Bool = false;
				var result:String = null;
				switch (node.name) {
				case "control: Start Block":
					if (indentMode == 1 && last != null && last.type.isIndent) {
						concat = true;
					} else if (indentMode != 2) indentLevel--;
				case "control: End Block":
					if (indentMode != 2) indentLevel--;
				case "control: Else":
					if (indentMode == 1 && last != null && last.name == "control: End Block") {
						concat = true;
					}
				default:
					if (node.isIndent && last != null) {
						if (last.isIndent && node.match.with != null) {
							var i:Int = index;
							var brackets:Int = 0;
							var loop:Bool = true;
							while (loop && i < nodes.length) {
								switch (nodes[i].name) {
								case "control: Start Block": brackets++;
								case "control: End Block":
									if (--brackets == 0) {
										if (i + 1 < nodes.length
										&& nodes[i + 1].name == "control: Else") {
											
										} else loop = false;
									}
								} // switch (nodes[i].name)
								i++;
							} // while (i < nodes.length)
							var acb:Node;
							acb = new Node(NodeOpen.inst); acb.indent = node.indent;
							nodes.insert(index, acb);
							acb = new Node(NodeClose.inst); acb.indent = node.indent;
							nodes.insert(i + 1, acb);
							i += 2; while (--i >= index) nodes[i].indent++;
							index -= 1;
							continue;
						} else if (last.type.name == "control: Else") {
							concat = true;
						}
					} // if (node.isIndent && last != null)
				} // switch (node.name)
				var indent:String = Conf.gmlGetIndent(indentLevel);
				var prefix:String = concat ? " " : (first ? "" : ln) + indent;
				var s = result != null ? result : node.type.print(node, mode);
				var sl = s.length;
				//if (sl > 0 && s.charCodeAt(sl - 1) == "\n".code) s = s.substring(0, sl - 1);
				if (s.length > 0) {
					s = StringTools.replace(s, "\n", "\n" + indent);
					r += prefix + s;
					if (first) first = false;
				}
				if (node.nodes != null && node.nodes.length > 0) {
					r += ln + "execute code:" + ln;
					r += ln + printNodes(node.nodes, mode, tabc + 1);
				}
				//
				last = node;
			}
		default:
		}
		return r;
	}
	public function print(mode:OutputMode):String {
		var r = printNodes(nodes, mode, 0);
		switch (mode) {
		case OmHTML:
			return '<div class="gminfo">\n$r\n</div>';
		default: return r;
		}
	}
	
	public static function init() {
		Code.init();
		// register node types:
		var nodeTypes = new Array<NodeType>();
		DataActions.run(nodeTypes);
		DataGML.run();
		DataInfo.run(nodeTypes);
		NodeEvent.eventTypes = data.DataEvents.get();
		DataGMX.run(nodeTypes);
		NodeType.nodeTypes = nodeTypes;
		NodeType.nodeTypeText = new types.NodeText("@L");
		NodeType.nodeTypeText.name = "Text";
	}
}
