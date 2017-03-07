package types;
import data.BBStyle;

/**
 * ...
 * @author YellowAfterlife
 */
class NodeEvent extends NodeType {
	public static var eventTypes:Array<NodeEvent>;
	public var icon:Int;
	private var iconCssOffset:String;
	public function new(code:String, icon:Int) {
		super(code);
		this.icon = icon;
	}
	public function printText(v:Node, mode:OutputMode):String {
		return printNodes(v, mode);
	}
	override public function print(v:Node, mode:OutputMode):String {
		var d:String = printText(v, mode), r:String, s:String;
		switch (mode) {
			case OutputMode.OmHTML: {
				if (Conf.htmlModern && Conf.htmlIcon == Conf.htmlIconSpan) {
					r = '<span class="event-icon"';
					if ((s = iconCssOffset) == null) {
						iconCssOffset = s = '-${icon * 16}px -384px';
					}
					r += 'style="background-position: $s"';
					r += '></span>';
					return r + d;
				} else {
					if (Conf.htmlModern) {
						r = '<img class="event-icon"';
						s = Conf.getIconURL("t" + icon);
						r += 'src="$s"';
						r += 'width="16"height="16"';
						r += '/>';
						return r + d;
					} else {
						
					}
					return d;
				}
			};
			case OmBB: {
				s = null;
				if (Conf.bbGMC) s = data.GMCIcons.event(icon);
				if (s == null) s = BBStyle.img(Conf.getIconURL("t" + icon));
				return s + " " + d;
			};
			default: return d;
		}
	}
}
