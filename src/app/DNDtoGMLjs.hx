package app;

import js.Browser;
import js.html.AnchorElement;
import js.html.Blob;
import js.html.DivElement;
import js.html.DragEvent;
import js.html.Element;
import js.html.Event;
import js.html.FileList;
import js.html.FileReader;
import js.html.InputElement;
import js.html.SelectElement;
import js.html.TextAreaElement;
import js.html.UListElement;
import js.Lib;
import js.html.URL;
import types.NodeEvent;

/**
 * ...
 * @author YellowAfterlife
 */

class DNDtoGMLjs {
	static inline function findId<T:Element>(id:String, ?c:Class<T>):T {
		return cast Browser.document.getElementById(id);
	}
	//
	var source:TextAreaElement = findId("source");
	var outText:TextAreaElement = findId("out_text");
	var outHTML:DivElement = findId("out_html");
	var codeStyle:SelectElement = findId("codestyle");
	var picker:InputElement = findId("picker");
	var saver:AnchorElement = findId("saver");
	//
	function load() {
		var ls = Browser.window.localStorage;
		if (ls == null) return;
		var s:String;
		//
		s = ls.getItem("gmvisualizer.gmlIndentMode");
		if (s != null) codeStyle.selectedIndex = Std.parseInt(s);
		//
	}
	function save() {
		var ls = Browser.window.localStorage;
		if (ls == null) return;
		//
		ls.setItem("gmvisualizer.gmlIndentMode", "" + Conf.gmlIndentMode);
		#if (debug)
		ls.setItem("gmvisualizer.source", source.value);
		#end
	}
	function update() {
		Conf.gmlIndentMode = codeStyle.selectedIndex;
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
		// buttons:
		var filename = "some.object.gmx";
		var objectURL = null;
		function proc() {
			update();
			var inf = new Info();
			inf.optPostFix = false; // dont cut single-action brackets (for now)
			inf.readString(source.value);
			var gmx = inf.print(OutputMode.OmGmxGml);
			outText.value = gmx;
			//
			saver.download = filename;
			try {
				var blob = new Blob([gmx], { type: "xml" });
				if (objectURL != null) URL.revokeObjectURL(objectURL);
				objectURL = URL.createObjectURL(blob);
				saver.href = objectURL;
			} catch (_:Dynamic) {
				saver.href = "data:application/xml;charset=utf-8," + StringTools.urlEncode(gmx);
			}
			// prepend just-actions output so that it highlights:
			if (inf.nodes.length > 0 && inf.nodes[0].nodes == null) gmx = "```\n" + gmx;
			// show highlighted preview:
			var inf2 = Info.fromString(gmx);
			outHTML.innerHTML = inf2.print(OutputMode.OmHTML);
		}
		source.addEventListener("change", function(_) proc());
		codeStyle.addEventListener("change", function(_) proc());
		//
		load();
		//
		function readFiles(files:FileList) {
			for (file in files) {
				var reader = new FileReader();
				reader.onloadend = function(_) {
					filename = file.name;
					source.value = reader.result;
					proc();
					return;
				};
				reader.readAsText(file);
			}
		}
		picker.addEventListener("change", function(_) readFiles(picker.files));
		//
		function cancelDefault(e:Event) {
			e.preventDefault();
			return false;
		}
		Browser.document.body.addEventListener("dragover", cancelDefault);
		Browser.document.body.addEventListener("dragenter", cancelDefault);
		Browser.document.body.addEventListener("drop", function(e:DragEvent) {
			e.preventDefault();
			readFiles(e.dataTransfer.files);
			return false;
		});
		// auto-test:
		#if (debug)
		(function() {
			var src = Browser.window.localStorage.getItem("gmvisualizer.source");
			if (src != null) source.value = src;
		})();
		#end
		if (source.value != "") proc();
	}
	static function main() {
		Info.init();
		new DNDtoGMLjs();
	}
}
