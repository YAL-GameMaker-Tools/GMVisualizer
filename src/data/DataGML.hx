package data;
import matcher.MatchResult;
import types.NodeAction;
import Code;
import data.DataGML.DataGMLTools.*;
using data.DataGML.DataGMLTools;
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
			NodeAction.actions[section + ": " + name].gmlFunc = func;
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
		//{ 01_move
		section = "move";
		add("Move Fixed", function(m) {
			var c:CodeNode = m.values[0][0];
			var s:String;
			var op = octx(m, []);
			switch (c) {
			case CoNumber(d, _) if (d.length == 9): {
				inline function dc(i:Int):Bool {
					return (d.charCodeAt(i) == "1".code);
				}
				var n:Int = 0;
				var i:Int;
				i = -1; while (++i < 9) if (dc(i)) n++;
				if (n == 0) return "";
				var dcx = dc(4);
				if (dcx) {
					if (n == 1) return '${op}speed = 0;\n${op}direction = 0;';
					s = xrna(m, "speed", 1);
					if (s != "") s += ";\n\t";
					s = 'if (random($n) < 1) {\n\tspeed = 0;\n\tdirection = 0;\n} else {\n\t$s';
					n--;
				} else {
					s = xrna(m, '${op}speed', 1);
					if (s != "") s += ";\n";
				}
				if (n > 1) {
					s += '${op}direction = choose(';
					n = 0; i = -1;
					while (++i < 9) if (i != 4 && dc(i)) {
						if (++n > 1) s += ", ";
						s += moveFixedDirs[i];
					}
					s += ");";
				} else {
					i = -1; while (++i < 9) if (i != 4 && dc(i)) {
						s += '${op}direction = ' + moveFixedDirs[i];
					}
				}
				if (dcx) s += ";\n}";
				return s;
			};
			default:
			}
			// this fallback should not ever trigger under normal conditions.
			s = 'action_move("' + xs(m, 0) + '", ' + xs(m, 1) + ');';
			if (m.relative) {
				s = 'argument_relative = true;\n$s\nargument_relative = false;';
			}
			return s;
		});
		add("Move Free", function(m) {
			var s = m.relative ? "motion_add" : "motion_set";
			return s + "(" + xs(m, 1) + ", " + xs(m, 0) + ");";
		});
		add("Move Towards", function(m) {
			return 'move_towards_point(${xrn(m, "x", 0)}, ${xrn(m, "y", 1)}, ${xs(m, 2)});';
		});
		add("Speed Horizontal", function(m) return xrna(m, "hspeed", 0).sc());
		add("Speed Vertical", function(m) return xrna(m, "vspeed", 0).sc());
		add("Set Gravity", function(m) {
			return join(xrna(m, "gravity", 0), ";\n", xrna(m, "gravity_direction", 1)).sc();
		});
		add("Reverse Horizontal", function(_) return "hspeed *= -1;");
		add("Reverse Vertical", function(_) return "vspeed *= -1;");
		add("Set Friction", function(m) return xrna(m, "friction", 0).sc());
		//
		addx("Jump to Position", function(m) {
			var op = octx(m, [0, 1]);
			return join(xrna(m, op + "x", 0), ";\n", xrna(m, op + "y", 1)).sc();
		});
		add("Jump to Start", function(m) {
			var op = octx(m, []);
			return  '${op}x = ${op}xstart;'
				+ '\n${op}x = ${op}ystart;';
		});
		add("Jump to Random", function(m) {
			return "action_move_random(" + xs(m, 0) + ", " + xs(m, 1) + ");";
		});
		//
		add("Align to Grid", function(m) {
			//return "action_snap(" + xs(m, 0) + ", " + xs(m, 1) + ")";
			var op = octx(m, [0, 1]);
			var gx = xs(m, 0);
			var gy = xs(m, 1);
			return  '${op}x = floor(${op}x / $gx) * $gx;'
				+ '\n${op}y = floor(${op}y / $gy) * $gy;';
		});
		add("Wrap Screen", function(m) {
			var s = vs(m, 0);
			var i; switch (s) {
			case "horizontal": i = 0;
			case "vertical": i = 1;
			default: i = 2;
			}
			return 'action_wrap($i /* $s */);';
		});
		//
		add("Move to Contact", function(m) {
			return "move_contact_" + (vs(m, 2) == "all objects" ? "all" : "solid")
				+ "(" + xs(m, 0) + ", " + xs(m, 1) + ");";
		});
		add("Bounce", function(m) {
			return "move_bounce_" + (vs(m, 1) == "all objects" ? "all" : "solid")
				+ "(" + (vs(m, 0) == "precisely" ? "true" : "false") + ");";
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
			return 'path_start($pt, ${xs(m,2)}, $i /* $e */, ${vb(m,3,"absolute")});';
		});
		add("End Path", function(m) return "path_end();");
		add("Path Position", function(m) return xrna(m, "path_position", 0).sc());
		add("Path Speed", function(m) return xrna(m, "path_speed", 0).sc());
		//
		add("Step Towards", function(m) {
			return 'mp_linear_step(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xs(m,2)}, '
				+ vb(m, 3, "all instances") + ");";
		});
		add("Step Avoiding", function(m) {
			return 'mp_potential_step(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xs(m,2)}, '
				+ vb(m, 3, "all instances") + ");";
		});
		//}
		//{ 02_main1
		section = "main1";
		add("Create Instance", function(m) {
			var op = octx(m, [1, 2]);
			var ox = xrn(m, op + "x", 1);
			var oy = xrn(m, op + "y", 2);
			return 'instance_create($ox, $oy, ${vr(m,0)});';
		});
		add("Create Moving", function(m) {
			return 'var __newinst__;'
				+'\n__newinst__ = instance_create(${xrn(m,"x",1)}, ${xrn(m,"y",2)}, ${vr(m,0)});'
				+'\n__newinst__.speed = ${xs(m,3)};'
				+'\n__newinst__.direction = ${xs(m,4)};';
		});
		add("Create Random", function(m) {
			var found = 0;
			var choose = "";
			for (i in 0 ... 4) {
				var obj = vr(m, i);
				switch (obj) {
					case "-1", "-100": { };
					default: {
						if (found > 0) choose += ", ";
						choose += obj;
						found += 1;
					};
				}
			}
			if (found == 0) return ""; // not a valid action
			if (found > 1) choose = "choose(" + choose + ")";
			var op = octx(m, [4, 5]);
			var ox = xrn(m, op + "x", 4);
			var oy = xrn(m, op + "y", 5);
			return 'instance_create($ox, $oy, $choose);';
		});
		add("Change Instance", function(m) return 'instance_change(${vr(m,0)}, ${vb(m,1,"yes")});');
		add("Destroy Instance", function(_) return "instance_destroy();");
		add("Destroy at Position", function(m) {
			var op = octx(m, [4, 5]);
			var ox = xrn(m, op + "x", 0);
			var oy = xrn(m, op + "y", 1);
			return 'action_kill_position($ox, $oy)';
			//return 'if (position_meeting(${xrn(m,"x",0)},${xrn(m,"y",1)},id)) { instance_destroy(); }';
		});
		add("Change Sprite", function(m) {
			var op = octx(m, [0, 1, 2]);
			return  '${op}sprite_index = ${vr(m,0)};'
				+ '\n${xva(m,op+"image_index",1)};'
				+ '\n${xva(m,op+"image_speed",2)};';
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
			var op = octx(m, [0, 1, 2]);
			return '${op}image_xscale = $x;'
				+'\n${op}image_yscale = $y;'
				+'\n${op}image_angle = ${xs(m,2)};';
		});
		add("Color Sprite", function(m) {
			var op = octx(m, [1]);
			return '${op}image_blend = ${vcol(m,0)};'
				+'\n${op}image_alpha = ${xs(m,1)};';
		});
		//
		add("Play Sound", function(m) {
			var sound = vr(m, 0);
			var loop = (vb(m, 1, "loop") == "true");
			if (Conf.gmlNewAudio) {
				return 'audio_play_sound($sound, 0, $loop);';
			} else {
				return 'sound_${loop?"loop":"play"}($sound);';
			}
		});
		add("Stop Sound", function(m) {
			var sound = vr(m, 0);
			if (Conf.gmlNewAudio) {
				return 'audio_stop_sound($sound);';
			} else return 'sound_stop($sound);';
		});
		add("Check Sound", function(m) {
			var fn = (Conf.gmlNewAudio ? "audio_is_playing" : "sound_isplaying");
			return 'if (${xn(m)}$fn(${vr(m,0)}))';
		});
		// todo: pre-GMS transition actions
		add("Previous Room1", function(_) return 'room_goto_previous();');
		add("Next Room1", function(_) return 'room_goto_next();');
		add("Restart Room1", function(_) return 'room_restart();');
		add("Different Room1", function(m) return 'room_goto(${vr(m,0)});');
		//
		add("Check Previous", function(m) return 'if (${xn(m)}room_exists(room_previous(room)))');
		add("Check Next", function(m) return 'if (${xn(m)}room_exists(room_next(room)))');
		//}
		//{ 03_main2
		section = "main2";
		add("Set Alarm", function(m) {
			var ai:String = m.values[0];
			var op = octx(m, [1]);
			return xrna(m, op + "alarm[" + ai.substring(6) + "]", 1).sc();
		});
		add("Sleep", function(m) return 'sleep(${xs(m,0)});');
		
		//timelines
		add("Set Time Line", function(m) {
			var op = octx(m, [0, 1, 2, 3]);
			var tlRun = m.values[2] == "Start Immediately";
			var tlLoop = m.values[3] == "Loop";
			return '${op}timeline_index = ${vr(m,0)};'
				+'\n${op}timeline_position = ${xs(m,1)};'
				+'\n${op}timeline_running = $tlRun;'
				+'\n${op}timeline_loop = $tlLoop;';
		});
		add("Time Line Position", function(m) {
			var ai:String = m.values[0];
			return xrna(m, octx(m, [1]) + "timeline_position", m.values[1]).sc();
		});
		add("Time Line Speed", function(m) {
			var ai:String = m.values[0];
			return xrna(m, octx(m, [1]) + "timeline_speed", m.values[1]).sc();
		});
		add("Start Time Line", function(m) {
			return octx(m, []) + 'timeline_running = true;';
		});
		add("Pause Time Line", function(m) return 'timeline_running = false;');
		add("Stop Time Line", function(m) {
			var op = octx(m, []);
			return '${op}timeline_running = false;'
				+'\n${op}timeline_position = 0;';
		});
		//
		add("Display Message", function(m) return 'show_message(${ss(vs(m,0))});');
		add("Show Info", function(_) return 'show_info();');
		add("Open URL", function(m) return 'url_open(${vstr(m,0)});');
		//
		add("Restart Game", function(m) return "game_restart();");
		add("End Game", function(m) return "game_end();");
		add("Save Game", function(m) return 'game_save(${ss(vs(m,0))});');
		add("Load Game", function(m) return 'game_load(${ss(vs(m,0))});');
		add("Replace Sprite", function(m) return 'sprite_replace(${vr(m,0)}, ${ss(vs(m,1))}, ${xs(m,2)}, false, false, 0, 0);');
		add("Replace Background", function(m) return 'background_replace(${vr(m,0)}, ${ss(vs(m,1))}, false, false);');
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
			return 'if (random(${xs(m,0)}) ${m.not ? ">=" : "<"} 1)';
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
			var op = octx(m, [0, 1]);
			var gx = xs(m, 0);
			var gy = xs(m, 1);
			return 'if (${op}x == (floor(x/$gx) * $gx) && ${op}y == (floor(x/$gy) * $gy))';
		});
		//
		add("Start Block", function(_) return "{");
		add("Else", function(_) return "else");
		add("Exit Event", function(_) return "exit;");
		add("End Block", function(_) return "}");
		add("Repeat", function(m) return "repeat (" + xs(m, 0) + ")");
		add("Call Parent Event", function(m) return "event_inherited();");
		//
		add("Execute Code", function(m) return xs(m, 0));
		//{
		add("Execute Script", function(m) {
			var arg1 = xs(m, 1).length == 0;
			var arg2 = xs(m, 2).length == 0;
			var arg3 = xs(m, 3).length == 0;
			var arg4 = xs(m, 4).length == 0;
			var arg5 = xs(m, 5).length == 0;
			
			if ( arg1 && arg2 && arg3 && arg4 && arg5 ) {
				return '${vr(m,0)}();';
			} else if ( arg2 && arg3 && arg4 && arg5 ) {
				return '${vr(m,0)}(${xs(m,1)});';
			} else if ( arg3 && arg4 && arg5 ) {
				return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)});';
			} else if ( arg4 && arg5 ) {
				return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)});';
			} else if ( arg5 ) {
				return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)}, ${xs(m,4)});';
			} else {
				return '${vr(m,0)}(${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)});';
			}
		});
		//}
		add("Comment", function(m) return "// " + m.values[0]);
		//
		add("Set Variable", function(m) {
			var op = octx(m, [1]);
			return '$op${xs(m,0)} ${cs(m.relative, "+")}= ${xs(m,1)};';
		});
		add("Test Variable", function(m) {
			var op = octx(m, [2]); // not checking expr#0 because it's the variable to check
			return 'if ($op${xs(m, 0)} ${vcmp(m, 1)} ${xs(m, 2)})';
		});
		add("Draw Variable", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xs(m,2)});';
		});
		//}
		//{ 05_score
		add("Set Score", function(m) return xrna(m, "score", 0).sc());
		add("Test Score", function(m) return 'if (score ${vcmp(m,0)} ${xs(m,1)})');
		add("Draw Score", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)} + string(score));';
		});
		//
		add("Show Highscore", function(m) {
			var s = vs(m, 4);
			if ('\'"'.indexOf(s.charAt(0)) < 0) s = '"$s"';
			var fs = Std.parseInt(xs(m, 7)) + Std.parseInt(xs(m, 8)) * 2;
			return 'highscore_set_background(${vr(m,0)});'
				+'\nhighscore_set_border(${vb(m,1,"show")});'
				+'\nhighscore_set_colors(c_white, ${vcol(m,2)}, ${vcol(m,3)});'
				+'\nhighscore_set_font($s, ${xs(m,5)}, $fs);'
				+'\nhighscore_show(score);';
		});
		add("Clear Highscore", function(m) return "highscore_clear();");
		//
		add("Set Lives", function(m) return xrna(m, "lives", 0).sc());
		add("Test Lives", function(m) return 'if (lives ${vcmp(m,0)} ${xs(m,1)})');
		add("Draw Lives", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)} + string(lives));';
		});
		add("Draw Life Images", function(m) {
			return 'action_draw_life_images(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vr(m,2)});';
		});
		//
		add("Set Health", function(m) return xrna(m, "health", 0).sc());
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
			return s + ", 0, " + sb(bc != "none") + ", false);";
		});
		add("Score Caption", function(m) {
			return 'show_score = ${vb(m,0,"show")};'
				+'\ncaption_score = ${vstr(m,1)};'
				+'\nshow_lives = ${vb(m,2,"show")};'
				+'\ncaption_lives = ${vstr(m,3)};'
				+'\nshow_health = ${vb(m,4,"show")};'
				+'\ncaption_health = ${vstr(m,5)};';
		});
		//}
		//{ 06_extra
		inline function part_type(m:MatchResult, i:Int) {
			switch( vs(m, i) ) {
				case "type 0": return "0";
				case "type 1": return "1";
				case "type 2": return "2";
				case "type 3": return "3";
				case "type 4": return "4";
				case "type 5": return "5";
				case "type 6": return "6";
				case "type 7": return "7";
				case "type 8": return "8";
				case "type 9": return "9";
				case "type 10": return "10";
				case "type 11": return "11";
				case "type 12": return "12";
				case "type 13": return "13";
				case "type 14": return "14";
				case "type 15": return "15";
				default: return "0";
			}
		}
		
		//1[pixel|disk|square|line|star|circle|ring|sphere|flare|spark|explosion|cloud|smoke|snow]
		inline function part_shape(m:MatchResult, i:Int) {
			switch( vs(m, i) ) {
				case "pixel": return "0 /* pixel */";
				case "disk": return "1 /* disk */";
				case "square": return "2 /* square */";
				case "line": return "3 /* line */";
				case "star": return "4 /* star */";
				case "circle": return "5 /* circle */";
				case "ring": return "6 /* ring */";
				case "sphere": return "7 /* sphere */";
				case "flare": return "8 /* flare */";
				case "spark": return "9 /* spark */";
				case "explosion": return "10 /* explosion */";
				case "cloud": return "11 /* cloud */";
				case "smoke": return "12 /* smoke */";
				case "snow": return "13 /* snow */";
				default: return "0 /* pixel */";
			}
		}
		
		inline function emitter_type(m:MatchResult, i:Int) {
			switch( vs(m, i) ) {
				case "emitter 0": return "0";
				case "emitter 1": return "1";
				case "emitter 2": return "2";
				case "emitter 3": return "3";
				case "emitter 4": return "4";
				case "emitter 5": return "5";
				case "emitter 6": return "6";
				case "emitter 7": return "7";
				default: return "0";
			}
		}
		
		inline function emitter_shape(m:MatchResult, i:Int) {
			switch( vs(m, i) ) {
				case "rectangle": return "0 /* rectangle */";
				case "ellipse": return "1 /* ellipse */";
				case "diamond": return "2 /* diamond */";
				case "line": return "3 /* line */";
				default: return "0 /* rectangle */";
			}
		}
		
		add("Create Part System", function(m) return 'action_partsyst_create(${xs(m,0)});' );
		add("Part System Destroy", function(_) return 'action_partsyst_destroy();');
		add("Part System Clear", function(_) return 'action_partsyst_clear();');
		add("Part Type Create", function(m) return 'action_parttype_create(${part_type(m,0)}, ${part_shape(m,1)}, ${vr(m,2)}, ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)});');
		add("Part Type Color", function(m) return 'action_parttype_color(${part_type(m,0)}, ${vb(m,1,"changing")}, ${vcol(m,2)}, ${vcol(m,3)}, ${xs(m,4)}, ${xs(m,5)});');
		add("Part Type Life", function(m) return 'action_parttype_life(${part_type(m,0)}, ${xs(m,1)}, ${xs(m,2)});');
		add("Part Type Speed", function(m) return 'action_parttype_speed(${part_type(m,0)}, ${xs(m,1)}, ${xs(m,2)}, ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)});');
		add("Part Type Gravity", function(m) return 'action_parttype_gravity(${part_type(m,0)}, ${xs(m,1)}, ${xs(m,2)});');
		add("Part Type Secondary", function(m) return 'action_parttype_secondary(${part_type(m,0)}, ${part_type(m,1)}, ${xs(m,2)}, ${part_type(m,3)}, ${xs(m,4)});');
		add("Create Part Emitter", function(m) return 'action_partemit_create(${emitter_type(m,0)}, ${emitter_shape(m,1)}, ${xs(m,2)}, ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)});');
		add("Destroy Part Emitter", function(m) return 'action_partemit_destroy(${emitter_type(m,0)});');
		add("Emitter Burst", function(m) return 'action_partemit_burst(${emitter_type(m,0)}, ${part_type(m,1)}, ${xs(m,2)});');
		add("Emitter Stream", function(m) return 'action_partemit_stream(${emitter_type(m,0)}, ${part_type(m,1)}, ${xs(m,2)});');
		//
		add("Draw Cursor", function(m) {
			var s = 'cursor_sprite = ${vr(m,0)};';
			if ( vb(m,1,"show") == "true" ) {
				s += '\nwindow_set_cursor(cr_default);';
			} else {
				s += '\nwindow_set_cursor(cr_none);';
			}
			return s;
		});
		//}
		//{ 07_draw
		add("Draw Self", function(m) return 'draw_self();');
		add("Draw Sprite", function(m) {
			return 'draw_sprite(${vr(m,3)}, ${xs(m,2)}, ${xrn(m,"x",0)}, ${xrn(m,"y",1)});';
		});
		add("Draw Background", function(m) {
			return "draw_background" + (vs(m, 3) == "true" ? "_tiled" : "")
				+ '(${vr(m,2)}, ${xrn(m,"x",0)}, ${xrn(m,"y",1)});';
		});
		//
		add("Draw Text", function(m) {
			return 'draw_text(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)});';
		});
		add("Draw Text Scaled", function(m) {
			return 'draw_text_transformed(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${vstr(m,2)},'
				+ ' ${xs(m,3)}, ${xs(m,4)}, ${xs(m,5)});';
		});
		//
		add("Draw Rectangle", function(m) {
			return 'draw_rectangle(${xrn(m,"x",0)}, ${xrn(m,"y",1)},'
				+ ' ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ${vb(m,4,"outline")});';
		});
		add("Horizontal Gradient", function(m) {
			return 'action_draw_gradient_hor(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ${xs(m,4)}, ${xs(m,5)});';
		});
		add("Vertical Gradient", function(m) {
			return 'action_draw_gradient_vert(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ${xs(m,4)}, ${xs(m,5)});';
		});
		//
		add("Draw Ellipse", function(m) {
			return 'action_draw_ellipse(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ${vb(m,4,"outline")});';
		});
		add("Gradient Ellipse", function(m) {
			return 'action_draw_ellipse_gradient(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ${xs(m,4)}, ${xs(m,5)});';
		});
		//
		add("Draw Line", function(m) {
			return 'draw_line(${xrn(m,"x",0)}, ${xrn(m,"y",1)}, ${xrn(m,"x",2)}, ${xrn(m,"y",3)});';
		});
		add("Draw Arrow", function(m) {
			return 'draw_arrow(${xrn(m,"x",0)}, ${xrn(m,"y",1)},'
				+ ' ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ${xs(m,4)});';
		});
		//
		add("Set Color", function(m) {
			return 'draw_set_color(${vcol(m,0)});';
		});
		add("Set Font", function(m) {
			return 'draw_set_font(${vr(m,0)});'
				+'\ndraw_set_halign(fa_${vs(m,1)});';
		});
		add("Set Full Screen", function(m) {
			return switch (vs(m, 0)) {
			case "window": "window_set_fullscreen(false);";
			case "fullscreen": "window_set_fullscreen(true);";
			default: "window_set_fullscreen(!window_get_fullscreen());";
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
			s += ', ${xrn(m,"x",2)}, ${xrn(m,"y",3)}, ';
			s += switch (vs(m, 0)) {
			case "medium": "1";
			case "large": "2";
			default: "0";
			}
			return s + ', ${vcol(m,4)});';
		});
		//}
	}
}

class DataGMLTools {
	/// appends a semicolon to `s` if non-empty
	public static function sc(s:String) {
		return s != "" ? s + ";" : s;
	}
	/// separates `a` and `b` by `s` if both are non-empty
	public static function join(a:String, s:String, b:String) {
		return (a != "" && b != "") ? a + s + b : a + b;
	}
	/// conditional string
	public static inline function cs(c:Bool, s:String) return (c ? s : "");
	/// boolean->string
	public static inline function sb(c:Bool) return c ? "true" : "false";
	/// resource->string
	public static function sr(s:String) return s == "<undefined>" ? "-1" : s;
	/// string->string
	public static function ss(s:String) {
		switch (s.charCodeAt(0)) {
			case "'".code, '"'.code: return s;
		}
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
	public static inline function vs(m:MatchResult, i:Int):String return m.values[i];
	/// value boolean
	public static inline function vb(m:MatchResult, i:Int, s:String) return sb(m.values[i] == s);
	/// value resource
	public static inline function vr(m:MatchResult, i:Int) return sr(m.values[i]);
	/// value comparison
	public static function vcmp(m:MatchResult, i:Int) {
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
	public static inline function vcol(m:MatchResult, i:Int) {
		return "$" + StringTools.hex(m.values[i], 6);
	}
	public static inline function vstr(m:MatchResult, i:Int) return ss(vs(m, i));
	//}
	
	/** expression string */
	public static inline function xs(m:MatchResult, index:Int) {
		return Code.printNodes(m.values[index], OutputMode.OmGML);
	}
	
	/** expression-value-assign */
	public static function xva(m:MatchResult, s:String, index:Int) {
		var x:String = xs(m, index);
		return x != s ? '$s = $x' : '';
	}
	
	/**
	 * expression-relative-number
	 */
	public static function xrn(m:MatchResult, s:String, index:Int) {
		var x:String = xs(m, index);
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
	
	/**
	 * expression-relative-number-assign
	 */
	public static function xrna(m:MatchResult, s:String, index:Int) {
		var x:String = xs(m, index);
		if (m.relative) {
			if (x != "0") return '$s += $x';
		} else {
			if (x != s) return '$s = $x';
		}; return "";
	}
	
	/** Expression-not: returns "!" or "" based on not-flag */
	public static inline function xn(m:MatchResult) return m.not ? "!" : "";
	
	/** Returns an other-prefix for apply-to if needed. */
	public static function octx(m:MatchResult, valueIndexes:Array<Int>) {
		if (m.with != "other") return "";
		for (i in valueIndexes) {
			var cc:Array<CodeNode> = m.values[i];
			for (c in cc) switch (c) {
				case CoWord(s, t): {
					switch (t) {
						case CwStdSpec: {
							switch (s) {
								case "self", "other": return "";
								default:
							}
						};
						case CwStdVar: if (Code.isInst[s]) return "";
						case CwStdFunc: return ""; // can have side-effects
						case CwUserVar: return ""; // variables apply to `self` by default
						case CwUserFunc: return ""; // scripts may depend on context
						default:
					}
				};
				default: { };
			}
		}
		return "other/* apply to */.";
	}
}
