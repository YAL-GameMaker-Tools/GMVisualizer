package app;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class DNDtoGML {
	public static function main():Int {
		var args = Sys.args();
		//
		var quiet = false;
		var output = true;
		inline function exit(code:Int) {
			if (!quiet) {
				Sys.println("Press any key to exit.");
				Sys.stdin().readByte();
			}
			Sys.exit(code);
			return code;
		}
		//
		var i = args.length;
		while (--i >= 0) switch (args[i].toLowerCase()) {
			case "/q": quiet = true; args.splice(i, 1);
			default: 
		}
		var path = args.shift();
		if (path == null) {
			Sys.println("Use: DNDtoGML [path to project]");
			Sys.println("Optional flags:");
			Sys.println("  /Q: Suspend 'Press any key to exit'");
			Sys.println("Dragging a .project.gmx over the executable works too.");
			return exit(0);
		}
		//
		if (!FileSystem.exists(path)) {
			Sys.println('Couldn\'t find a file or a directory at `$path`');
			return exit(1);
		}
		//
		if (!FileSystem.isDirectory(path)) {
			path = Path.directory(path);
			if (path == "") path = ".";
		}
		//
		var obj1 = Path.join([path, "objects"]);
		if (!FileSystem.exists(obj1)) {
			Sys.println('Couldn\'t find a directory at `$obj1`');
			return exit(1);
		}
		//
		var obj0 = Path.join([path, "objects@" + DateTools.format(Date.now(), "%Y-%m-%d_%H-%M-%S")]);
		if (output) FileSystem.createDirectory(obj0);
		//
		Info.init();
		// read "use new audio system" setting from config:
		var cfg = Path.join([path, "Configs", "Default.config.gmx"]);
		if (FileSystem.exists(cfg)) try {
			var xmlRoot = Xml.parse(File.getContent(cfg));
			for (xmlConfig in xmlRoot.elementsNamed("Config")) {
				for (xmlOptions in xmlConfig.elementsNamed("Options")) {
					for (xmlAudio in xmlOptions.elementsNamed("option_use_new_audio")) {
						switch (xmlAudio.firstChild().toString().toLowerCase()) {
							case "0", "false": Conf.gmlNewAudio = false;
							default: Conf.gmlNewAudio = true;
						}
					}
				}
			}
		} catch (_:Dynamic) {
			//
		}
		//
		for (lp in FileSystem.readDirectory(obj1)) {
			if (StringTools.endsWith(lp.toLowerCase(), ".object.gmx")) {
				var op = '$obj1/$lp';
				if (output) File.copy(op, '$obj0/$lp');
				var gmx0 = File.getContent(op);
				//
				var inf = new Info();
				inf.optPostFix = false;
				inf.readString(gmx0);
				var gmx1 = inf.print(OutputMode.OmGmxGml);
				//
				if (output) File.saveContent(op, gmx1);
			}
		}
		//
		return 0;
		/*var path = Sys.args()[0];
		if (path == null) {
			Sys.println("Use: 
		}*/
	}
}
