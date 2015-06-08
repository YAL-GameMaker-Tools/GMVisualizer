package data;

/**
 * Handles mapping styles to BB code sequences.
 * @author YellowAfterlife
 */
class BBStyle {
	public static inline function img(url:String):String {
		if (Conf.bbImgAlt) {
			return '[img=$url]';
		} else {
			return '[img]$url[/img]';
		}
	}
	public static function get(name:String, v:String):String {
		return switch (name) {
		//
		case "h2": '[b]$v[/b]';
		case "event p": '[b]$v[/b]'; //'[quote="$v"]';
		case "event ul": '$v\n';// '$v[/quote]';
		case "node":
			if (Conf.bbIndentMode == Conf.bbIndentModeList) {
				switch (Conf.bbListType) {
				case Conf.bbListTypeStar2: '[*]$v[/*]';
				case Conf.bbListTypeStar1: '[*]$v';
				case Conf.bbListTypeLi: '[li]$v[/li]';
				default: v;
				}
			} else v;
		case "ri": '[color=#0078AA]$v[/color]';
		case "relative": '[color=#008800]$v[/color]';
		case "not": '[color=#008800]$v[/color]';
		case "set": '[color=#008800]$v[/color]';
		case "with": '[color=#777777]$v[/color]';
		case "comment": '[i]$v[/i]';
		case "comment prefix": '[color=#888888]$v[/color]';
		case "mono": '[font=monospace]$v[/font]';
		case "code mono": get("code", get("mono", v));
		case "code co": '[color=#888888]$v[/color]';
		case "code kw": '[b][color=#000088]$v[/color][/b]';
		case "code sp": '[b][color=#000088]$v[/color][/b]';
		case "code nu": '[color=#0000FF]$v[/color]';
		case "code nx": '[color=#0000FF]$v[/color]';
		case "code st": '[color=#0000FF]$v[/color]';
		case "code ri": '[color=#0078AA]$v[/color]';
		case "code sv": '[color=#880000]$v[/color]';
		case "code sf": '[color=#880000]$v[/color]';
		case "code uv": '[color=#440088]$v[/color]';
		case "code uf": '[color=#880088]$v[/color]';
		case "code fd": '[color=#440088]$v[/color]';
		case "code pp": '[color=#0078AA]$v[/color]';
		default: v;
		}
	}
}