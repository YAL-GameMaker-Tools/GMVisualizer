package data;

/**
 * Defines mappings between object info texture sheet and GMC :GM#: smiley codes.
 * @author YellowAfterlife
 */
@:publicFields
class GMCIcons {
	static function action(id:Int):String {
		var i:Int = switch (id) {
		case 000: 002;
		case 001: 003;
		case 002: 004;
		case 100: 005;
		case 101: 006;
		case 102: 007;
		case 200: 008;
		case 201: 009;
		case 202: 010;
		case 300: 011;
		case 301: 012;
		case 302: 013;
		case 400: 014;
		case 401: 138;
		case 500: 015;
		case 501: 016;
		case 600: 017;
		case 601: 018;
		case 700: 019;
		case 701: 020;
		case 800: 021;
		case 801: 022;
		// main 1:
		case 003: 023;
		case 004: 024;
		case 005: 134;
		case 103: 025;
		case 104: 026;
		case 105: 027;
		case 203: 028;
		case 204: 029;
		case 205: 030;
		case 303: 031;
		case 304: 032;
		case 305: 033;
		case 403: 034;
		case 404: 035;
		case 405: 036;
		case 503: 037;
		case 504: 038;
		case 505: 039;
		// main 2:
		case 006: 040;
		case 007: 041;
		case 106: 042;
		case 107: 043;
		case 306: 044;
		case 307: 045;
		case 606: 047;
		case 607: 048;
		case 706: 049;
		case 707: 050;
		case 806: 135;
		case 807: 052;
		case 808: 053;
		// control:
		case 009: 054;
		case 010: 055;
		case 011: 056;
		case 109: 057;
		case 110: 058;
		case 111: 059;
		case 209: 060;
		case 210: 061;
		case 211: 062;
		case 309: 063;
		case 310: 064;
		case 311: 065;
		case 409: 066;
		case 410: 067;
		case 411: 068;
		case 509: 069;
		case 510: 070;
		case 511: 071;
		case 609: 072;
		case 610: 073;
		case 611: 074;
		// score:
		case 012: 075;
		case 013: 076;
		case 014: 077;
		case 112: 078;
		case 113: 079;
		case 212: 080;
		case 213: 081;
		case 214: 082;
		case 312: 083;
		case 412: 084;
		case 413: 085;
		case 414: 086;
		case 512: 087;
		// extras:
		// [screw this tab for time being]
		// draw:
		case 018: 108;
		case 019: 109;
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