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
		while (--i >= 0) switch (args[i]) {
			case "/Q", "/q": quiet = true; args.splice(i, 1);
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
		FileSystem.createDirectory(obj0);
		//
		Info.init();
		//
		for (lp in FileSystem.readDirectory(obj1)) {
			if (StringTools.endsWith(lp.toLowerCase(), ".object.gmx")) {
				var op = '$obj1/$lp';
				File.copy(op, '$obj0/$lp');
				var inf = new Info();
				inf.optPostFix = false;
				var gmx = File.getContent(op);
				inf.readString(gmx);
				File.saveContent(op, inf.print(OutputMode.OmGmxGml));
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
