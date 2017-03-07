package;

/**
 * ...
 * @author YellowAfterlife
 */
@:publicFields class Conf {
	static var iconURL:String = "./img/{id}.png";
	static inline function getIconURL(s:String) {
		return StringTools.replace(iconURL, "{id}", s);
	}
	static var miniIcons:Bool = true;
	static var resPfx(default, set):String;
	static function set_resPfx(v:String):String {
		if (resPfx != v) {
			resPfx = v;
			Code.resPfx = v.split("|");
		}
		return v;
	}
	//{ HTML options
	static var htmlIcon:Int = htmlIconSpan;
	static inline var htmlIconImg:Int = 0;
	static inline var htmlIconSpan:Int = 1;
	/// Whether to use CSS (as opposed to inline styles).
	static var htmlModern:Bool = true;
	/// Whether to fill out text inside the icons for copying.
	static var htmlIconText:Bool = false;
	//}
	//{ BB code options
	/// whether to use "[img=$s]" instead of "[img]$s[/img]".
	static var bbImgAlt:Bool = false;
	static function bbGetIndent(n:Int):String {
		var r:String = "";
		switch (bbIndentMode) {
		case bbIndentModeString:
			while (--n >= 0) r += bbIndentString;
		default:
		}
		return r;
	}
	/// whether to use ":GM#:" smileys for icons if possible
	static var bbGMC:Bool = false;
	///
	static var bbIndentMode:Int = 0;
	static inline var bbIndentModeString:Int = 0;
	static inline var bbIndentModeList:Int = 1;
	//
	static var bbIndentString:String = "    ";
	//
	static var bbListType:Int = 0;
	static inline var bbListTypeStar2:Int = 0;
	static inline var bbListTypeStar1:Int = 1;
	static inline var bbListTypeLi:Int = 2;
	//}
	//{ GML options
	static var gmlIndentString:String = "    ";
	static function gmlGetIndent(n:Int):String {
		var r:String = "";
		while (--n >= 0) r += gmlIndentString;
		return r;
	}
	static var gmlIndentMode:GmlIndentMode = KNR;
	//}
}
@:enum abstract GmlIndentMode(Int) from Int to Int {
	
	/** Allman, brace-on-new-line */
	var BSD = 0;
	
	/** K&R, brace-on-same-line*/
	var KNR = 1;
	
	/** Whitesmiths, brace-on-new-line-indented */
	var WSM = 2;
	
}
