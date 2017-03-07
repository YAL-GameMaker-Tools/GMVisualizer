package;

import js.Browser;
import js.html.DivElement;
import js.html.DragEvent;
import js.html.Event;
import js.html.FileReader;
import js.html.InputElement;
import js.html.TextAreaElement;
import js.html.UListElement;
import js.Lib;
import types.NodeEvent;

/**
 * ...
 * @author YellowAfterlife
 */

class Main {
	inline function findId(id:String):Dynamic {
		return Browser.document.getElementById(id);
	}
	//
	var btHTMLc:InputElement;
	var btHTMLm:InputElement;
	var btBB:InputElement;
	var btGML:InputElement;
	var source:TextAreaElement;
	var outText:TextAreaElement;
	var outHTML:DivElement;
	//
	function load() {
		if (Browser.window.localStorage == null) return;
		var s:String;
		inline function f(k:String):Bool {
			return (s = Browser.window.localStorage.getItem(k)) != null;
		}
		inline function q(id:String):InputElement {
			return cast Browser.document.getElementById(id);
		}
		inline function r(id:String, v:String) q(id).value = v;
		inline function cb(id:String, v:Bool) q(id).checked = v;
		if (f("iconURL")) r("icon_url", s);
		if (f("miniIcons")) cb("small_icons", s == "1");
		if (f("resPfx")) r("res_pfx", s);
		//
		if (f("bbImgAlt")) cb("bb_img_alt", s == "1");
		if (f("bbGMC")) cb("bb_gmc_icons", s == "1");
		if (f("bbIndentMode")) cb("bb_indent_list", s == "1");
		if (f("bbIndentString")) r("bb_indent_text", s);
		if (f("bbListType")) switch (s) {
		case "0": cb("bb_list_mode_s2", true);
		case "1": cb("bb_list_mode_s1", true);
		case "2": cb("bb_list_mode_li", true);
		}
		//
		if (f("gmlIndentMode")) switch (s) {
		case "0": cb("gml_style_0", true);
		case "1": cb("gml_style_1", true);
		case "2": cb("gml_style_2", true);
		}
	}
	function save() {
		if (Browser.window.localStorage == null) return;
		inline function f(k:String, v:String) {
			Browser.window.localStorage.setItem(k, v);
		}
		inline function b(v:Bool) return v ? "1" : "0";
		//
		f("miniIcons", b(Conf.miniIcons));
		f("iconURL", Conf.iconURL);
		f("resPfx", Conf.resPfx);
		//
		f("bbImgAlt", b(Conf.bbImgAlt));
		f("bbGMC", b(Conf.bbGMC));
		f("bbIndentMode", "" + Conf.bbIndentMode);
		f("bbIndentString", Conf.bbIndentString);
		f("bbListType", "" + Conf.bbListType);
		//
		f("gmlIndentMode", "" + Conf.gmlIndentMode);
	}
	function update() {
		inline function q(id:String):InputElement {
			return cast Browser.document.getElementById(id);
		}
		inline function f(id:String):String return q(id).value;
		inline function cb(id:String):Bool return q(id).checked;
		var v:String;
		Conf.miniIcons = cb("small_icons");
		Conf.resPfx = f("res_pfx");
		Conf.iconURL = f("icon_url");
		//
		Conf.bbImgAlt = cb("bb_img_alt");
		Conf.bbGMC = cb("bb_gmc_icons");
		Conf.bbIndentMode = cb("bb_indent_list") ? Conf.bbIndentModeList : Conf.bbIndentModeString;
		Conf.bbIndentString = f("bb_indent_text");
		if (cb("bb_list_mode_s2")) Conf.bbListType = Conf.bbListTypeStar2;
		if (cb("bb_list_mode_s1")) Conf.bbListType = Conf.bbListTypeStar1;
		if (cb("bb_list_mode_li")) Conf.bbListType = Conf.bbListTypeLi;
		//
		if (cb("gml_style_0")) Conf.gmlIndentMode = 0;
		if (cb("gml_style_1")) Conf.gmlIndentMode = 1;
		if (cb("gml_style_2")) Conf.gmlIndentMode = 2;
		//
		save();
	}
	function regSection(name:String) {
		var cb:InputElement = findId(name + "_cb");
		var ul:UListElement = findId(name + "_ul");
		cb.onchange = function(_) {
			ul.style.display = cb.checked ? "" : "none";
		};
	}
	function new() {
		//
		source = findId("source");
		outText = findId("out_text");
		outHTML = findId("out_html");
		//
		regSection("bb_section");
		regSection("gml_section");
		// buttons:
		findId("print_clear").onclick = function(_) {
			outHTML.innerHTML = outText.value = "";
		};
		btHTMLm = findId("print_html_m");
		btHTMLm.onclick = function(_) {
			update();
			var inf = Info.fromString(source.value);
			outHTML.innerHTML = outText.value = inf.print(OutputMode.OmHTML);
		};
		btBB = findId("print_bb");
		btBB.onclick = function(_) {
			update();
			var inf = Info.fromString(source.value);
			var b0 = inf.print(OutputMode.OmBB);
			b0 = StringTools.replace(b0, "\t", "    ");
			// replace sequences of spaces with alternating #160-#32s:
			var i:Int = 0, n:Int = b0.length;
			var b1 = "";
			var nbsp = String.fromCharCode(160);
			while (i < n) {
				var c = b0.charAt(i++);
				switch (c) {
				case " ", "\n":
					switch (b0.charAt(i)) {
					case " ": // seq!
						var alt:Bool;
						if (c == "\n") {
							b1 += "\n" + nbsp;
							alt = true;
						} else {
							b1 += nbsp + " ";
							alt = false;
						}
						while (i < n) {
							c = b0.charAt(++i);
							switch (c) {
							case " ":
								alt = !alt;
								b1 += alt ? nbsp : " ";
								continue;
							default: 
							}; break;
						}
					default: b1 += c;
					}
				default: b1 += c;
				}
			}
			//
			outText.value = b1;
			outHTML.innerHTML = inf.print(OutputMode.OmHTML);
		};
		btGML = findId("print_gml");
		btGML.onclick = function(_) {
			update();
			var inf = new Info();
			inf.optPostFix = false; // dont cut single-action brackets (for now)
			inf.readString(source.value);
			var gml = inf.print(OutputMode.OmGML);
			outText.value = gml;
			// prepend just-actions output so that it highlights:
			if (inf.nodes.length > 0 && inf.nodes[0].nodes == null) gml = "```\n" + gml;
			// show highlighted preview:
			var inf2 = Info.fromString(gml);
			outHTML.innerHTML = inf2.print(OutputMode.OmHTML);
		}
		//
		load();
		//
		(function allowFileDragAndDrop() {
			function cancelDefault(e:Event) {
				e.preventDefault();
				return false;
			}
			Browser.document.body.addEventListener("dragover", cancelDefault);
			Browser.document.body.addEventListener("dragenter", cancelDefault);
			Browser.document.body.addEventListener("drop", function(e:DragEvent) {
				e.preventDefault();
				var dt = e.dataTransfer;
				for (file in dt.files) {
					var reader = new FileReader();
					reader.onloadend = function(_) {
						source.value = reader.result;
					};
					reader.readAsText(file);
				}
				return false;
			});
		})();
		// auto-test:
		if (source.value != "") btGML.onclick(null);
	}
	static function main() {
		Info.init();
		new Main();
	}
}
