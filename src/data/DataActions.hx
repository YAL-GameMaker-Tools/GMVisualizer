package data;
import types.NodeAction;
import types.*;

/**
 * ...
 * @author YellowAfterlife
 */
class DataActions {
	public static function run(list:Array<NodeType>):Void {
		/// Number comparison options (without brackets)
		var ncmp:String = "equal to|smaller than|larger than" // 8.x
			+ "|less than or equal to|greater than or equal to|less than|greater than";
		var r:NodeType;
		var section:String = "";
		///
		inline function id(name:String):String {
			return section + ": " + name;
		}
		/// Adds a node type.
		inline function add(name:String, code:String, ico:Int) {
			list.push(r = new NodeAction(id(name), code, ico));
		}
		/// Adds a control (indenting) node type.
		inline function ctl(name:String, code:String, ico:Int) {
			list.push(r = new NodeAction(id(name), code, ico));
			r.isIndent = true;
		}
		list.push(new NodeAction("Unknown Action", "Unknown Action", 008));
		//{ 01_move
		section = "move";
		add("Move Fixed", "@wstart moving in directions @e with speed set @rto @e", 000);
		add("Move Free", "@wset speed @rto @{eu} and direction to @e", 001);
		add("Move Towards", "@wstart moving @rin the direction of position (@e,@e) with speed @e", 002);
		add("Speed Horizontal", "@wset the horizontal speed @rto @e", 100);
		add("Speed Vertical", "@wset the vertical speed @rto @e", 101);
		add("Set Gravity", "@wset the gravity @rto @e in direction @e", 102);
		add("Reverse Horizontal", "@wreverse horizontal direction", 200);
		add("Reverse Vertical", "@wreverse vertical direction", 201);
		add("Set Friction", "@wset the friction @rto @e", 202);
		add("Jump to Position", "@wjump to @rposition (@e,@e)", 300); // GM8
		add("Jump to Position", "@wjump @rto position (@e,@e)", 300); // GMS
		add("Jump to Start", "@wjump to the start position", 301);
		add("Jump to Random", "@wjump to a random position with hor snap @{eu} and vert snap @e", 302);
		add("Align to Grid", "@walign position to a grid with cells of @e by @e pixels", 400);
		add("Wrap Screen", "@wwrap @[horizontal|vertical|in both directions] when an instance moves outside the room", 401);
		add("Move to Contact", "@wmove in direction @e at most @e till a contact with @[solid objects|all objects]", 500);
		add("Bounce", "@wbounce @[not precisely|precisely] against @[solid objects|all objects]", 501);
		add("Set Path", "@wset the @[relative|absolute] path to @i with speed @{eu} and at the end @[stop|continue from start|continue from here|reverse]", 600);
		add("End Path", "@wend the path", 601);
		add("Path Position", "@wset the position on the path @rto @e", 700);
		add("Path Speed", "@wset the speed for the path @rto @e", 701);
		add("Step Towards", "@wperform a step @rtowards position (@e,@e) with speed @e stop at @[solid only|all instances]", 800);
		add("Step Avoiding", "@wperform a step @rtowards position (@e,@e) with speed @e avoiding @[solid only|all instances]", 801);
		//}
		//{ 02_main1
		section = "main1";
		add("Create Moving", "@wcreate instance of object @i at @rposition (@e,@e) with speed @e in direction @e", 004);
		add("Create Instance", "@wcreate instance of object @i at @rposition (@e,@e)", 003);
		add("Create Random", "@wcreate instance of object @i, @i, @i, or @i at @rposition (@e,@e)", 005);
		add("Change Instance", "@wchange the instance into object @i, @[yes|not|no] performing events", 103);
		add("Destroy Instance", "@wdestroy the instance", 104);
		add("Destroy at Position", "kill all instances at @rposition (@e,@e)", 105);
		add("Change Sprite", "@wset the sprite to @i with subimage @{eu} and speed @e", 203);
		add("Transform Sprite", "@wscale the sprite with @e in the xdir, @e in the ydir, rotate over @e, and @[no mirroring|mirror horizontally|flip vertically|mirror and flip]", 204);
		add("Color Sprite", "@wblend the sprite with color @c and alpha value @e", 205);
		add("Play Sound", "@[Play|Loop] sound @i", 303);
		add("Play Sound", "play sound @i; looping: @[false|true]", 303);
		add("Stop Sound", "stop sound @i", 304);
		ctl("Check Sound", "if sound @i is @Nplaying", 305);
		{ // GM<=8.1 room actions
			var efl = "<no effect>|Create from left|Create from right|Create from top|Create from bottom|Create from center|Shift from left|Shift from right|Shift from top|Shift from bottom|Interlaced from left|Interlaced from right|Interlaced from top|Interlaced from bottom|Push from left|Push from right|Push from top|Push from bottom|Rotate left|Rotate right|Blend|Fade out and in";
			add("Previous Room", 'go to previous room with transition effect @[$efl]', 403);
			add("Next Room", 'go to next room with transition effect @[$efl]', 404);
			add("Restart Room", 'restart the current room with transition effect @[$efl]', 405);
			add("Different Room", 'go to room @i with transition effect @[$efl]', 503);
		}
		// GMS room actions:
		add("Previous Room", "Go to previous room", 403);
		add("Next Room", "Go to next room", 404);
		add("Restart Room", "Restart the current room", 405);
		add("Different Room", "Go to room @i", 503);
		ctl("Check Previous", "if previous room exists", 504);
		ctl("Check Next", "if next room exists", 505);
		//}
		//{ 03_main2
		section = "main2";
		add("Set Alarm", "@wset @[Alarm 0|Alarm 1|Alarm 2|Alarm 3|Alarm 4|Alarm 5|Alarm 6|Alarm 7|Alarm 8|Alarm 9|Alarm 10|Alarm 11] @rto @e", 006);
		add("Sleep", "sleep @e milliseconds; redrawing the screen: @[true|false]", 007);
		//
		add("Set Time Line", "@wset time line @i at position @e, @[Start Immediately|Don't Start] and @[Don't Loop|Loop]", 106);
		add("Time Line Position", "@wset the time line position @rto @e", 107);
		add("Time Line Speed", "@wset the speed of the time line @rto @e", 108);
		add("Start Time Line", "@wstart or resume the current time line", 206);
		add("Pause Time Line", "@wpause the current time line", 207);
		add("Stop Time Line", "@wstop and reset the current time line", 208);
		//
		add("Display Message", "display message: @L", 306);
		add("Show Info", "show the game info", 307);
		add("Open URL", "Open a URL: @L", 408);
		//
		add("Splash Text", "show the text in file @L", 406);
		add("Splash Image", "show the image in file @L", 407);
		add("Splash Web", "show the webpage @{su} in @[Game Window|Browser]", 408);
		add("Splash Video", "show the video in file @{su}  @[0|Don't Loop|Loop]", 506);
		add("Splash Settings", "change splash settings: caption: @{su}, @[Game Window|Normal Window|Full Screen], @[Show|Don't Show] close button, @[Close|Don't Close] on escape key, @[Close|Don't Close] on mouse button", 507);
		//
		add("Restart Game", "restart the game", 606);
		add("End Game", "end the game", 607);
		add("Save Game", "save the game in the file @L", 706);
		add("Load Game", "load the game from the file @L", 707);
		//
		add("Replace Sprite", "replace the sprite @i with the image in file @{su} with @e subimages", 806);
		add("Replace Sound", "replace the sound @i with the contents of file @L", 807);
		add("Replace Background", "replace the background @i with the image in file @L", 808);
		//}
		//{ 04_control
		section = "control";
		ctl("Check Empty", "@wif @rposition (@e,@e) is @Ncollision free for @[Only solid|solid|all] objects", 009);
		ctl("Check Collision", "@wif @rposition (@e,@e) gives @Na collision with @[Only solid|solid|all] objects", 010);
		ctl("Check Object", "@wif at @rposition (@e,@e) there is @Nobject @i", 011);
		ctl("Test Instance Count", "if number of objects @i is @N@[equal to|smaller than|larger than|Equal to|Smaller than|Larger than] @e", 109);
		ctl("Test Chance", "with a chance of 1 out of @e do @Nperform the next action", 110);
		// GMS uses a variant with duplicate spaces?:
		ctl("Test Chance", "with a chance of 1 out of @e do @N perform the next action", 110);
		ctl("Check Question", "if the player does @Nsay yes to the question: @L", 111);
		ctl("Test Expression", "@wif expression @e is @Ntrue", 209);
		ctl("Check Mouse", "if @[no|left|right|middle] mouse button is @Npressed", 210);
		ctl("Check Grid", "@wif object is @Naligned with grid with cells of @e by @e pixels", 211);
		r = types.NodeOpen.inst = new types.NodeOpen(id("Start Block"), "start of a block", 309);
		list.push(r);
		ctl("Else", "else", 310);
		add("Exit Event", "exit this event", 311);
		r = types.NodeClose.inst = new types.NodeClose(id("End Block"), "end of a block", 409);
		list.push(r);
		ctl("Repeat", "repeat next action (block) @e times", 410);
		add("Call Parent Event", "call the inherited event of the parent object", 411);
		list.push(new types.NodeCodeBlock(id("Execute Code"), "@wexecute code:\n\n@{code}", 509));
		//{
		add("Execute Script", "@wexecute script @i with arguments (,,,,)", 510);
		add("Execute Script", "@wexecute script @i with arguments (@e,,,,)", 510);
		add("Execute Script", "@wexecute script @i with arguments (@e,@e,,,)", 510);
		add("Execute Script", "@wexecute script @i with arguments (@e,@e,@e,,)", 510);
		add("Execute Script", "@wexecute script @i with arguments (@e,@e,@e,@e,)", 510);
		add("Execute Script", "@wexecute script @i with arguments (@e,@e,@e,@e,@e)", 510);
		//}
		list.push(new types.NodeComment(id("Comment"), "COMMENT: @L", 511));
		add("Set Variable", "@wset variable @e @rto @e", 609);
		add("Draw Variable", "@wat @rposition (@e,@e) draw the value of: @e", 611);
		//}
		//{ 05_score
		add("Set Score", "set the score @rto @e", 012);
		ctl("Test Score", 'if score is @N@[$ncmp] @e', 013);
		add("Draw Score", "at @rposition (@e,@e) draw the value of score with caption @L", 014);
		add("Show Highscore", "show the highscore table\n"
			+ "@]background: @i\n"
			+ "@]@[don't show|show] the border\n"
			+ "@]new color: @c, other color: @c\n"
			+ "@]Font: @{su},@e,@e,@e,@e,@e,@e", 112);
			// name,size,color,bold,italic,underline,strikeout
		add("Clear Highscore", "clear the highscore table", 113);
		add("Set Lives", "set the number of lives @rto @e", 212);
		ctl("Test Lives", 'If lives are @N@[$ncmp] @e', 213);
		add("Draw Lives", "at @rposition (@e,@e) draw the number of lives with caption @L", 214);
		add("Draw Life Images", "draw the lives @rat (@e,@e) with sprite @i", 312);
		add("Set Health", "set the health @rto @e", 412);
		ctl("Test Health", 'if health is @N@[$ncmp] @e', 413);
		add("Draw Health", "draw the health bar with @rsize (@e,@e,@e,@e) with back color @[none|black|gray|silver|white|maroon|green|olive|navy|purple|teal|red|lime|yellow|blue|fuchsia|aqua] and bar color @[green to red|white to black|black|gray|silver|white|maroon|green|olive|navy|purple|teal|red|lime|yellow|blue|fuchsia|aqua]", 414);
		add("Score Caption", "set the information in the window caption:\n"
			+ "@]@[don't show|show] score with caption @L\n"
			+ "@]@[don't show|show] lives with caption @L\n"
			+ "@]@[don't show|show] health with caption @L", 512);
		//}
		//{ 07_draw
		add("Draw Self", "@wDraw the instance", 018);
		add("Draw Sprite", "@wat @rposition (@e,@e) draw image @e of sprite @i", 018);
		add("Draw Background", "at @rposition (@e,@e) draw background @i; tiled: @[true|false]", 019);
		//
		add("Draw Text Scaled", "@wat @rposition (@e,@e) draw text: @{su} scaled horizontally with @e, vertically with @e, and rotated over @e degrees", 119);
		add("Draw Text", "@wat @rposition (@e,@e) draw text: @L", 118);
		//
		add("Draw Rectangle", "@wdraw rectangle with @rvertices (@e,@e) and (@e,@e), @[filled|outline]", 218);
		add("Horizontal Gradient", "@wdraw a horizontal gradient filled rectangle with @rvertices (@e,@e) and (@e,@e) and colors @c to @c", 219);
		add("Vertical Gradient", "@wdraw a vertical gradient filled rectangle with @rvertices (@e,@e) and (@e,@e) and colors @c to @c", 220);
		//
		add("Draw Ellipse", "@wdraw an ellipse with @rvertices (@e,@e) and (@e,@e), @[filled|outline]", 318);
		add("Gradient Ellipse", "@wdraw a gradient filled ellipse with @rvertices (@e,@e) and (@e,@e) and colors @c and @c", 319);
		//
		add("Draw Line", "@wdraw a line @rbetween (@e,@e) and (@e,@e)", 418);
		add("Draw Arrow", "@wdraw an arrow @rbetween (@e,@e) and (@e,@e) with size @e", 419);
		//
		add("Set Color", "set the drawing color to @c", 518);
		add("Set Font", "set the font for drawing text to @i and align @[left|center|right]", 519);
		add("Set Full Screen", "set screen mode to: @[switch|window|fullscreen]", 520);
		//
		add("Take Snapshot", "take a snapshot image of the game and store it in the file @L", 618);
		add("Create Effect", "@wcreate a @[small|medium|large] effect of type @[explosion|ring|ellipse|firework|smoke|smoke up|star|spark|flare|cloud|rain|snow] @rat (@e,@e) of@]color @c @[below objects|above objects]", 619);
		//}
		//{ low priority
		ctl("Test Variable", '@wif @e is @N@[$ncmp] @e', 610);
		//}
		//{ non-standard
		list.push(new NodeCodeRaw("GML block", "```\n@{code}", 509));
		list.push(new NodeCodeRaw("GML line", "```@e", 509));
		list.push(new NodeCodeScript("GML script", "#define @L\n@{code}", 509));
		//}
	}
}