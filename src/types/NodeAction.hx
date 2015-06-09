package types;
import data.BBStyle;
import matcher.*;
/**
 * ...
 * @author YellowAfterlife
 */
class NodeAction extends NodeType {
	public static var actions:Map<String, NodeAction> = new Map();
	public var iconId:Int;
	public var iconCol:Int;
	public var iconRow:Int;
	public var iconOffsetCSS:String;
	public var iconIdURL:String;
	public var gmlFunc:MatchResult->String;
	public function new(name:String, code:String, icon:Int) {
		super(code);
		var s:String = name, i:Int = 1;
		if (actions.exists(s)) {
			while (i < 100) {
				s = name + i;
				if (!actions.exists(s)) break;
				i++;
			}
		}
		actions.set(s, this);
		this.name = name;
		iconId = icon;
		iconCol = icon % 100;
		iconRow = Std.int(icon / 100);
	}
	public function printIcon(v:Node, mode:OutputMode):String {
		var r:String, s:String;
		switch (mode) {
		case OutputMode.OmHTML:
			if (Conf.htmlModern && Conf.htmlIcon == Conf.htmlIconSpan) {
				r = '<span class="action-icon"';
				if ((s = iconOffsetCSS) == null) {
					iconOffsetCSS = s = '-${iconCol * 32}px -${iconRow * 32}px';
				}
				r += 'style="background-position: $s"';
				r += 'title="$name"';
				r += '>';
				if (Conf.htmlIconText) r += '[$name] ';
				r += '</span>';
				return r;
			} else {
				if (Conf.htmlModern) {
					r = '<img class="action-icon"';
					if ((s = iconIdURL) == null) {
						iconIdURL = s = StringTools.lpad("" + iconId, "0", 3);
					}
					s = StringTools.replace(Conf.iconURL, "{id}", s);
					r += 'src="$s"';
					r += 'alt="$name"';
					r += '/>';
					return r;
				} else {
					r = '<img src=';
					return r;
				}
			}
			/*if (Conf.htmlModern)
			'<span class="action-icon"'
				+ 'style="background-position: -' + (iconCol * 32) + 'px -' + (iconRow * 32) + 'px"'
				+ 'title="$name">'
				//+ '[' + name + ']&nbsp;'
				+ '</span> ';
			else '<img src="' + StringTools.replace(Conf.iconURL, "{id}", iconIds) + '"'
				+ ' alt="' + name + '"'
				+ ' style="display: inline-block; vertical-align: middle; margin-right: 4px">';*/
		case OmBB:
			if (Conf.bbGMC) {
				s = data.GMCIcons.action(iconId);
				if (s != null) return s + " ";
			}
			if ((s = iconIdURL) == null) {
				iconIdURL = s = StringTools.lpad("" + iconId, "0", 3);
			}
			return BBStyle.img(Conf.getIconURL(Conf.miniIcons ? 'm$s' : s)) + " ";
		default: return "";
		}
	}
	public function printText(v:Node, mode:OutputMode):String {
		switch (mode) {
		case OmGML:
			if (gmlFunc != null) {
				var r = v.match;
				var s = gmlFunc(r);
				var r_with = r.with;
				if (r_with != null && s != "") {
					if (v.type.isIndent) {
						s = 'var ifwith; ifwith = false'
						+ '\nwith ($r_with) $s { ifwith = true; break }'
						+ '\nif (ifwith)';
					} else {
						if (s.indexOf("\n") >= 0) {
							s = StringTools.replace(s, "\n", "\n\t");
							s = 'with ($r_with) {\n\t$s\n}';
						} else if (s.indexOf(";") >= 0) {
							s = 'with ($r_with) { $s }';
						} else s = 'with ($r_with) $s';
					}
				}
				s = StringTools.replace(s, "\t", Conf.gmlIndentString);
				return s;
			} else {
				return "todo: /* " + Match.print(nodes, v.match, mode) + " */";
			}
		default: return Match.print(nodes, v.match, mode);
		}
	}
	override public function print(v:Node, mode:OutputMode):String {
		var r = printIcon(v, mode) + printText(v, mode);
		switch (mode) {
		case OutputMode.OmHTML:
			return '<li class="action">$r</li>';
		default: return r;
		}
	}
}