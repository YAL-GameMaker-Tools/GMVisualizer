package data;
import matcher.MatchResult;
import types.NodeAction;
import Code;
/**
 * ...
 * @author YellowAfterlife
 */
class DataGML {
	static var moveFixedDirs = [225, 270, 315, 180, 0, 0, 135, 90, 45];
	public static function run() {
		var section:String;
		var f:MatchResult->String;
		inline function add(name:String, func:MatchResult->String):Void {
			NodeAction.actions.get(section + ": " + name).gmlFunc = func;
		}
		inline function add2(s1:String, s2:String, f1:MatchResult->String) {
			f = f1;
			NodeAction.actions[section + ": " + s1].gmlFunc = f;
			NodeAction.actions[section + ": " + s2].gmlFunc = f;
		}
		inline function addx(s:String, func:MatchResult->String):Void {
			f = func;
			NodeAction.actions[section + ": " + s].gmlFunc = f;
			NodeAction.actions[section + ": " + s + "1"].gmlFunc = f;
		}
		//{
		inline function join(a:String, s:String, b:String) {
			return (a != "" && b != "") ? a + s + b : a + b;
		}
		/// conditional string
		inline function cs(c:Bool, s:String) return (c ? s : "");
		/// boolean->string
		inline function sb(c:Bool) return c ? "true" : "false";
		/// resource->string
		function sr(s:String) return s == "<undefined>" ? "-1" : s;
		/// string->string
		function ss(s:String) {
			if (s.indexOf('"') < 0) {
				return '"$s"';
			} else if (s.indexOf("'") < 0) {
				return "'" + s + "'";
			} else {
				return '/* $s */';
			}
		}
		
		//{
		/// value string
		inline function vs(m:MatchResult, i:Int):String return m.values[i];
		/// value boolean
		inline function vb(m:MatchResult, i:Int, s:String) return sb(m.values[i] == s);
		/// value resource
		inline function vr(m:MatchResult, i:Int) return sr(m.values[i]);
		/// value comparison
		function vcmp(m:MatchResult, i:Int) {
			return switch (vs(m, i)) {
			case "equal to": m.not ? "!=" : "==";
			case "smaller than", "less than": m.not ? ">=" : "<";
			case "larger than", "greater than": m.not ? "<=" : ">";
			case "less than or equal to": m.not ? ">" : "<=";
			case "greater than or equal to": m.not ? "<" : ">=";
			default: m.not ? "!?" : "?";
			}
		}
		/// value color (BGR 24-bit)
		inline function vcol(m:MatchResult, i:Int) {
			return "$" + StringTools.hex(m.values[i], 6);
		}
		inline function vstr(m:MatchResult, i:Int) return ss(vs(m, i));
		//}
		
		/// expression string
		inline function xs(m:MatchResult, i:Int) {
			return Code.printNodes(m.values[i], OutputMode.OmGML);
		}
		/// expression-value-assign
		function xva(m:MatchResult, s:String, i:Int) {
			var x:String = xs(m, i);
			return x != s ? '$s = $x' : '';
		}
		/// expression-relative-number
		function xrn(m:MatchResult, s:String, i:Int) {
			var x:String = xs(m, i);
			if (m.relative) {
				if (x.charCodeAt(0) == "-".code) {
					return s + " - " + x.substring(1);
				} else {
					return x != "0" ? s + " + " + x : s;
				}
			} else {
				return x;
			}
		}
		/// expression-relative-number-assign
		function xrna(m:MatchResult, s:String, i:Int) {
			var x:String = xs(m, i);
			if (m.relative) {
				if (x != "0") return '$s += $x';
			} else {
				if (x != s) return '$s = $x';
			}; return "";
		}
		
		inline function xn(m:MatchResult) return m.not ? "!" : "";
		//}
		//{ 01_move
		section = "move";
		add("Move Fixed", function(m) {
			var c:CodeNode = m.values[0][0];
			var s:String;
			switch (c) {
			case CoNumber(d, _) if (d.length == 9):
				inline function dc(i:Int):Bool {
					return (d.charCodeAt(i) == "1".code);
				}
				var n:Int = 0;
				var i:Int;
				i = -1; while (++i < 9) if (dc(i)) n++;
				if (n == 0) return "";
				var dcx = dc(4);
				if (dcx) {
					if (n == 1) return "speed = 0\ndirection = 0";
					s = xrna(m, "speed", 1);
					if (s != "") s += "\n\t";
					s = 'if (random($n) < 1) {\n\tspeed = 0\n\tdirection = 0\n} else {\n\t$s';
					n--;
				} else {
					s = xrna(m, "speed", 1);
					if (s != "") s += "\n";
				}
				if (n > 1) {
					s += "direction = choose(";
					n = 0; i = -1;
					while (++i < 9) if (i != 4 && dc(i)) {
						if (++n > 1) s += ", ";
						s += moveFixedDirs[i];
					}
					s += ")";
				} else {
					i = -1; while (++i < 9) if (i != 4 && dc(i)) {
						s += "direction = " + moveFixedDirs[i];
					}
				}
				if (dcx) s += "\n}";
				return s;
			default:
			}
			// this fallback should not ever trigger under normal conditions.
			s = 'action_move("' + xs(m, 0) + '", ' + xs(m, 1) + ')';
			if (m.relative) {
				s = 'argument_relative = true\n$s\nargument_relative = false';
			}
			return s;
		});
		add("Move Free", function(m) {
			var s = m.relative ? "motion_add" : "motion_set";
			return s + "(" + xs(m, 1) + ", " + xs(m, 0) + ")";
		});
		add("Move Towards", function(m) {
			return 'move_towards_point(${xrn(m, "x", 0)}, ${xrn(m, "y", 1)}, ${xs(m, 2)})';
		});
		add("Speed Horizontal", function(m) return xrna(m, "hspeed", 0));
		add("Speed Vertical", function(m) return xrna(m, "vspeed", 0));
		add("Set Gravity", function(m) {
			return join(xrna(m, "gravity", 0), "\n", xrna(m, "gravity_direction", 1));
		});
		add("Reverse Horizontal", function(_) return "hspeed *= -1");
		add("Reverse Vertical", function(_) return "vspeed *= -1");
		add("Set Friction", function(m) return xrna(m, "friction", 0));
		//
		addx("Jump to Position", function(m) {
			return join(xrna(m, "x", 0), "\n", xrna(m, "y", 1));
		});
		add("Jump to Start", function(_) return "x = xstart\ny = ystart");
		add("Jump to Random", function(m) {
			return "action_move_random(" + xs(m, 0) + ", " + xs(m, 1) + ")";
		});
		//
		add("Align to Grid", function(m) {
			return "action_snap(" + xs(m, 0) + ", " + xs(m, 1) + ")";
		});
		add("Wrap Screen", function(m) {
			var s = vs(m, 0);
			var i; switch (s) {
			case "horizontal": i = 0;
			case "vertical": i = 1;
			default: i = 2;
			}
			return 'action_wrap($i /* $s */)';
		});
		//
		add("Move to Contact", function(m) {
			return "move_contact_" + (vs(m, 2) == "all objects" ? "all" : "solid")
				+ "(" + xs(m, 0) + ", " + xs(m, 1) + ")";
		});
		add("Bounce", function(m) {
			return "move_bounce_" + (vs(m, 1) == "all objects" ? "all" : "solid")
				+ "(" + (vs(m, 0) == "precisely" ? "true" : "false") + ")";
		});
		//
		add("Set Path", function(m) {
			var s = vs(m, 3), i:Int, e:String;
			switch (s) {
			case "continue from start": i = 1; e = "restart";
			case "continue from here": i = 2; e = "continue";
			case "reverse": i = 3; e = "reverse";
			default: i = 0; e = "stop";
			}
			var pt = vr(m, 1);
			return 'path_start($pt, ${xs(m,2)}, $i /* $e */, ${vb(m,3,"absolute")})';
		});
		add("End Path", function(m) return "path_end()");
		add("Path Position", function(m) return xrna(m, "path_position", 0));
		add("Path Speed", function(m) return xrna(m, "path_speed", 0));
		//
		add("Step Towards", function(m) {
			return 'mp_linear_step(${xrn(m,"x",0)}, ${xrn(m,"x",1)}, ${xrn(m,"x",2)}, '
				+ vb(m, 3, "all instances") + ")";
		});
		add("Step Avoiding", function(m) {
			return 'mp_potential_step(${xrn(m,"x",0)}, ${xrn(m,"x",1)}, ${xrn(m,"x",2)}, '
				+ vb(m, 3, "all instances") + ")";
		});
		//}
		//{ 02_main1
		section = "main1";
		add("Create Instance", function(m) {
			return 'instance_create(${xrn(m,"x",1)}, ${xrn(m,"x",2)}, ${vr(m,0)})';
		});
		add("Create Moving", function(m) {
			return 'var newinst;'
				+'\nnewinst = instance_create(${xrn(m,"x",1)}, ${xrn(m,"x",2)}, ${vr(m,0)})'
				+'\nnewinst.speed = ${xs(m,3)}'
				+'\nnewinst.direction = ${xs(m,4)}';
		});
		add("Create Random", function(m) {
			var s = 'instance_create(${xrn(m,"x",4)}, ${xrn(m,"x",5)}, ';
			var i:Int;
			var args:Array<String> = [];
			var argc:Int = 0;
			var argf:Int = -1;
			var arg:String;
			i = 0; while (i < 4) {
				arg = vr(m, i);
				if (arg != "-1" && ++argc == 1) argf = i;
				args[i++] = arg;
			}
			if (argc == 0) return "";
			if (argc == 1) return s + args[argf] + ")";
			s += "choose(";
			i = 0; while (i < 4) {
				arg = args[i];
				if (arg != "-1") {
					if (i != argf) s += ", ";
					s += arg;
				}
				i++;
			}
			return s + "))";
		});
		add("Change Instance", function(m) return 'instance_change(${vr(m,0)}, ${vb(m,1,"yes")})');
		add("Destroy Instance", function(_) return "instance_destroy()");
		add("Destroy at Position", function(m) {
			return 'action_kill_position(${xrn(m,"x",0)}, ${xrn(m,"y",1)})';
		});
		add("Change Sprite", function(m) {
			return 'sprite_index = ${vr(m,0)}'
				+'\n${xva(m,"image_index",1)}'
				+'\n${xva(m,"image_speed",2)}';
		});
		add("Transform Sprite", function(m) {
			var x = xs(m, 0);
			var y = xs(m, 1);
			switch (vs(m, 3)) {
			case "mirror horizontally": x = "-" + x;
			case "flip vertically": y = "-" + y;
			case "mirror and flip": x = "-" + x; y = "-" + y;
			}
			if (StringTools.startsWith(x, "--")) x = x.substring(2);
			if (StringTools.startsWith(y, "--")) y = y.substring(2);
			return 'image_xscale = $x'
				+'\nimage_yscale = $y'
				+'\nimage_angle = ${xs(m,2)}';
		});
		add("Color Sprite", function(m) {
			return 'image_blend = ${vcol(m,0)}'
				+'\nimage_alpha = ${xs(m,1)}';
		});
		//
		add("Play Sound", function(m) return 'action_sound(${vr(m,1)}, ${vb(m,0,"Loop")})');
		add("Play Sound1", function(m) return 'action_sound(${vr(m,0)}, ${vb(m,1,"true")})');
		add("Stop Sound", function(m) return 'action_end_sound(${vr(m,0)})');
		add("Check Sound", function(m) return 'if (${xn(m)}action_if_sound(${vr(m,0)}))');
		// todo: pre-GMS transition actions
		add("Previous Room1", function(_) return 'room_goto_previous()');
		add("Next Room1", function(_) return 'room_goto_next()');
		add("Restart Room1", function(_) return 'room_restart()');
		add("Different Room1", function(m) return 'room_goto(${vr(m,0)})');
		//
		add("Check Previous", function(m) return 'if (${xn(m)}room_exists(room_previous(room)))');
		add("Check Next", function(m) return 'if (${xn(m)}room_exists(room_next(room)))');
		//}
		//{ 03_main2
		section = "main2";
		add("Set Alarm", function(m) {
			var ai:String = m.values[0];
			return xrna(m, "alarm[" + ai.substring(6) + "]", 1);
		});
		add("Sleep", function(m) return 'sleep(${xs(m,0)}');
		//
		add("Display Message", function(m) return 'show_message(${ss(vs(m,0))})');
		add("Show Info", function(_) return 'show_info()');
		add("Open URL", function(m) return 'url_open(${vstr(m,0)})');
		//
		add("Restart Game", function(m) return "game_restart()");
		add("End Game", function(m) return "game_end()");
		add("Save Game", function(m) return 'game_save(${ss(vs(m,0))})');
		add("Load Game", function(m) return 'game_load(${ss(vs(m,0))})');
		//}
		//{ 04_control
		section = "control";
		inline function check_func(m) {
			return "place_" + (vs(m, 2) == "all" ? "empty" : "free") + "("
				+ xrn(m, "x", 0) + ", " + xrn(m, "y", 1) + ")";
		}
		add("Check Empty", function(m) {
			return "if (" + cs(m.not, "!") + check_func(m) + ")";
		});
		add("Check Collision", function(m) {
			return "if (" + cs(!m.not, "!") + check_func(m) + ")";
		});
		add("Check Object", function(m) {
			return 'if (${xn(m)}place_meeting(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vr(m,2)}))';
		});
		//
		add("Test Instance Count", function(m) {
			return 'if (instance_number(${vr(m,0)}) ${vcmp(m,1)} ${xs(m,2)})';
		});
		addx("Test Chance", function(m) {
			return 'if (random(${xs(m,0)}) ${m.not ? "<" : ">="} 1)';
		});
		add("Check Question", function(m) {
			return 'if (${xn(m)}show_question("${vs(m,0)}"))';
		});
		//
		add("Test Expression", function(m) return 'if ${xn(m)}(${xs(m,0)})');
		add("Check Mouse", function(m) {
			var s = 'if (${xn(m)}mouse_check_button(';
			s += switch (vs(m, 0)) {
			case "no": "mb_none";
			case "right": "mb_right";
			case "middle": "mb_middle";
			default: "mb_left";
			}
			return s + '))';
		});
		add("Check Grid", function(m) {
			return 'if (${xn(m)}action_if_snapped(${xs(m,0)}, ${xs(m,1)}))';
		});
		//
		add("Start Block", function(_) return "{");
		add("Else", function(_) return "else");
		add("Exit Event", function(_) return "exit");
		add("End Block", function(_) return "}");
		add("Repeat", function(m) return "repeat (" + xs(m, 0) + ")");
		add("Call Parent Event", function(m) return "event_inherited()");
		//
		add("Execute Code", function(m) return xs(m, 0));
		//{
		add("Execute Script", function(m) {
			return '${vr(m,0)}()';
		});
		add("Execute Script1", function(m) {
			return '${vr(m,0)}(${xs(m,1)})';
		});
		add("Execute Script2", function(m) {
			return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)})';
		});
		add("Execute Script3", function(m) {
			return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)})';
		});
		add("Execute Script4", function(m) {
			return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)}, ${xs(m,4)})';
		});
		add("Execute Script5", function(m) {
			return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)})';
		});
		//}
		add("Comment", function(m) return "// " + m.values[0]);
		//
		add("Set Variable", function(m) {
			return xs(m, 0) + " " + cs(m.relative, "+") + "= " + xs(m, 1);
		});
		add("Test Variable", function(m) {
			return 'if (${xs(m, 0)} ${vcmp(m, 1)} ${xs(m, 2)})';
		});
		add("Draw Variable", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xs(m,2)})';
		});
		//}
		//{ 05_score
		add("Set Score", function(m) return xrna(m, "score", 0));
		add("Test Score", function(m) return 'if (score ${vcmp(m,0)} ${xs(m,1)})');
		add("Draw Score", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)} + string(score))';
		});
		//
		add("Show Highscore", function(m) {
			var s = vs(m, 4);
			if ('\'"'.indexOf(s.charAt(0)) < 0) s = '"$s"';
			var fs = Std.parseInt(xs(m, 7)) + Std.parseInt(xs(m, 8)) * 2;
			return 'highscore_set_background(${vr(m,0)})'
				+'\nhighscore_set_border(${vb(m,1,"show")})'
				+'\nhighscore_set_colors(c_white, ${vcol(m,2)}, ${vcol(m,3)})'
				+'\nhighscore_set_font($s, ${xs(m,5)}, $fs)'
				+'\nhighscore_show(score)';
		});
		add("Clear Highscore", function(m) return "highscore_clear()");
		//
		add("Set Lives", function(m) return xrna(m, "lives", 0));
		add("Test Lives", function(m) return 'if (lives ${vcmp(m,0)} ${xs(m,1)})');
		add("Draw Lives", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)} + string(lives))';
		});
		add("Draw Life Images", function(m) {
			return 'action_draw_life_images(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vr(m,2)})';
		});
		//
		add("Set Health", function(m) return xrna(m, "health", 0));
		add("Test Health", function(m) return 'if (health ${vcmp(m,0)} ${xs(m,1)})');
		add("Draw Health", function(m) {
			var s = 'draw_healthbar(${xrn(m,"x",0)}, ${xrn(m,"y",1)},'
				+ ' ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, health, ';
			var bc = vs(m, 4);
			switch (bc) {
			case "none": s += "-1";
			default: s += "c_" + bc;
			}
			s += ", ";
			var fc = vs(m, 5);
			switch (fc) {
			case "green to red": s += "c_red, c_green";
			case "white to black": s += "c_black, c_white";
			default: s += 'c_$fc, c_$fc';
			}
			return s + ", 0, " + sb(bc != "none") + ", false)";
		});
		add("Score Caption", function(m) {
			return 'show_score = ${vb(m,0,"show")}'
				+'\ncaption_score = ${vstr(m,1)}'
				+'\nshow_lives = ${vb(m,2,"show")}'
				+'\ncaption_lives = ${vstr(m,3)}'
				+'\nshow_health = ${vb(m,4,"show")}'
				+'\ncaption_health = ${vstr(m,5)}';
		});
		//
		//}
		//{ 07_draw
		add("Draw Self", function(m) return 'draw_self()');
		add("Draw Sprite", function(m) {
			return 'draw_sprite(${vr(m,3)}, ${xs(m,2)}, ${xrn(m,"x",0)}, ${xrn(m,"y",1)})';
		});
		add("Draw Background", function(m) {
			return "draw_background" + (vs(m, 3) == "true" ? "_tiled" : "")
				+ '(${vr(m,2)}, ${xrn(m,"x",0)}, ${xrn(m,"y",1)})';
		});
		//
		add("Draw Text", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)})';
		});
		add("Draw Text Scaled", function(m) {
			return 'draw_text_transformed(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)},'
				+ ' ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)})';
		});
		//
		add("Draw Rectangle", function(m) {
			return 'draw_rectangle(${xrn(m,"x",0)}, ${xrn(m,"x",1)},'
				+ ' ${xrn(m,"x",2)}, ${xrn(m,"x",3)}, ${vb(m,4,"outline")})';
		});
		//
		add("Draw Line", function(m) {
			return 'draw_line(${xrn(m,"x",0)}, ${xrn(m,"x",1)}, ${xrn(m,"x",2)}, ${xrn(m,"x",3)})';
		});
		add("Draw Arrow", function(m) {
			return 'draw_arrow(${xrn(m,"x",0)}, ${xrn(m,"x",1)},'
				+ ' ${xrn(m,"x",2)}, ${xrn(m,"x",3)}, ${xs(m,4)})';
		});
		//
		add("Set Color", function(m) {
			return 'draw_set_color(${vcol(m,0)})';
		});
		add("Set Font", function(m) {
			return 'draw_set_font(${vr(m,0)})'
				+'\ndraw_set_halign(fa_${vs(m,1)})';
		});
		add("Set Full Screen", function(m) {
			return switch (vs(m, 0)) {
			case "window": "window_set_fullscreen(false)";
			case "fullscreen": "window_set_fullscreen(true)";
			default: "window_set_fullscreen(!window_get_fullscreen())";
			}
		});
		add("Take Snapshot", function(m) return 'screen_save(${vstr(m,0)})');
		add("Create Effect", function(m) {
			var s = "effect_create_" + (vs(m, 5) == "above objects" ? "above" : "below") + '(';
			var t = vs(m, 1);
			s += switch (t) {
			case "smoke up": "ef_smokeup";
			default: "ef_" + t;
			}
			s += ', ${xrn(m,"x",2)}, ${xrn(m,"x",3)}, ';
			s += switch (vs(m, 0)) {
			case "medium": "1";
			case "large": "2";
			default: "0";
			}
			return s + ', ${vcol(m,4)})';
		});
		//}
	}
}