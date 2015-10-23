package data;

/**
 * Defines mappings between object info texture sheet and GMC :GM#: smiley codes.
 * @author YellowAfterlife
 */
@:publicFields
class GMCIcons {
	static function action(id:Int):String {
		var i:Int = switch (id) {
		case   0:   2;
		case   1:   3;
		case   2:   4;
		case 100:   5;
		case 101:   6;
		case 102:   7;
		case 200:   8;
		case 201:   9;
		case 202:  10;
		case 300:  11;
		case 301:  12;
		case 302:  13;
		case 400:  14;
		case 401: 138;
		case 500:  15;
		case 501:  16;
		case 600:  17;
		case 601:  18;
		case 700:  19;
		case 701:  20;
		case 800:  21;
		case 801:  22;
		// main 1:
		case   3:  23;
		case   4:  24;
		case   5: 134;
		case 103:  25;
		case 104:  26;
		case 105:  27;
		case 203:  28;
		case 204:  29;
		case 205:  30;
		case 303:  31;
		case 304:  32;
		case 305:  33;
		case 403:  34;
		case 404:  35;
		case 405:  36;
		case 503:  37;
		case 504:  38;
		case 505:  39;
		// main 2:
		case   6:  40;
		case   7:  41;
		case 106:  42;
		case 107:  43;
		case 306:  44;
		case 307:  45;
		case 606:  47;
		case 607:  48;
		case 706:  49;
		case 707:  50;
		case 806: 135;
		case 807:  52;
		case 808:  53;
		// control:
		case   9:  54;
		case  10:  55;
		case  11:  56;
		case 109:  57;
		case 110:  58;
		case 111:  59;
		case 209:  60;
		case 210:  61;
		case 211:  62;
		case 309:  63;
		case 310:  64;
		case 311:  65;
		case 409:  66;
		case 410:  67;
		case 411:  68;
		case 509:  69;
		case 510:  70;
		case 511:  71;
		case 609:  72;
		case 610:  73;
		case 611:  74;
		// score:
		case  12:  75;
		case  13:  76;
		case  14:  77;
		case 112:  78;
		case 113:  79;
		case 212:  80;
		case 213:  81;
		case 214:  82;
		case 312:  83;
		case 412:  84;
		case 413:  85;
		case 414:  86;
		case 512:  87;
		// extras:
		// [screw this tab for time being]
		// draw:
		case  18: 108;
		case  19: 109;
		case 118: 110;
		case 119: 111;
		case 218: 112;
		case 219: 113;
		case 220: 114;
		case 318: 115;
		case 319: 116;
		case 418: 117;
		case 419: 118;
		case 518: 119;
		case 519: 120;
		case 520: 121;
		case 618: 122;
		case 619: 137;
		default: -1;
		}
		if (i == -1) return null;
		var s:String = Std.string(i);
		while (s.length < 3) s = "0" + s;
		return ":GM" + s + ":";
	}
	static function event(id:Int):String {
		var i:Int = switch (id) {
		case 0: 123;
		case 1: 124;
		case 2: 125;
		case 3: 126;
		case 4: 130;
		case 5: 131;
		case 6: 127;
		case 7: 129;
		case 8: 128;
		case 9: 132;
		case 10: 133;
		case 11: 130;
		case 12: 130;
		default: -1;
		}
		if (i == -1) return null;
		return ":GM" + i + ":";
	}
}
