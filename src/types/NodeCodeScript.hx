package types;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeCodeScript extends NodeCode {
	override public function printText(v:Node, mode:OutputMode):String {
		var r:String = printCode(v.match.values[1], v, mode);
		var name:String = v.match.values[0];
		switch (mode) {
		case OmHTML:
			return '<pre class="code mono"><span class="pp">#define $name</span>'
				+ '\n$r</pre>';
		case OmBB:
			var t = data.BBStyle.get("code pp", '#define $name');
			if (r != "") {
				return t + "\n" + Conf.bbGetIndent(v.indent) + r;
			} else return t;
		default: return r;
		}
	}
	override public function print(v:Node, mode:OutputMode):String {
		return printText(v, mode);
	}
}