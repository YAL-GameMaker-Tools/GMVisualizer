package types.code;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeCode extends NodeAction {
	public function printCode(nodes:Array<Code.CodeNode>, v:Node, mode:OutputMode):String {
		var b:StringBuf = new StringBuf();
		switch (mode) {
		case OmHTML:
			for (n in nodes) b.add(Code.print(n, mode, true));
			return b.toString();
		case OmBB:
			for (n in nodes) b.add(Code.print(n, mode, true));
			var code = b.toString();
			if (v.indent > 0) {
				var lines = b.toString().split("\n");
				var indent = Conf.bbGetIndent(v.indent);
				b = new StringBuf();
				for (i in 0 ... lines.length) {
					if (i > 0) b.addChar("\n".code);
					b.add(indent);
					b.add(data.BBStyle.get("code mono", lines[i]));
				}
				return b.toString();
			} else return data.BBStyle.get("code mono", b.toString());
		default: return super.printText(v, mode);
		}
	}
	override public function printText(v:Node, mode:OutputMode):String {
		var r:String = printCode(v.match.values[0], v, mode);
		return switch (mode) {
		case OmHTML: '<pre class="code mono">\n$r\n</pre>';
		default: r;
		}
	}
}
