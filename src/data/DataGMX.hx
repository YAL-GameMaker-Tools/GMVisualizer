package data;
import types.gmx.NodeGmxEvent;
import types.NodeAction;
import types.NodeEvent;
import types.gmx.*;

/**
 * ...
 * @author YellowAfterlife
 */
class DataGMX {
	public static function run(list:Array<NodeType>) {
		var lib:Int = 0;
		var events = NodeEvent.eventTypes;
		function add(id:Int, lid:Int, ?ord:String):Void {
			var action = NodeAction.iconMap.get(id);
			if (action == null) trace('No action for $id/$lid.');
			list.push(new NodeGmxAction("<action>"
				+ "\n@]<libid>1</libid>"
				+ "\n@]<id>" + lid + "</id>"
				+ "\n@]@{ml}</action>",
				action, ord));
		}
		function event(type:Int, numb:Int, name:String, icon:Int) {
			var match = '<event eventtype="$type" enumb="';
			if (numb >= 0) {
				match += numb;
			} else match += '@{su}';
			match += '">@{ml}</event>';
			events.push(new NodeGmxEvent(match, icon, name));
		}
		//{ Events
		event(0, 0, "Create Event", 0);
		for (i in 0 ... 16) event(7, 10 + i, "Other Event: User Defined " + i, 4);
		events.push(new NodeGmxEventAny(
			'<event eventtype="@{su}" enumb="@{su}">@{ml}</event>',
			4, ""));
		//}
		//{ move
		add(000, 101, "0e1e"); // Move Fixed
		add(001, 102, "1e0e"); // Move Free
		add(002, 105, "0e1e2e"); // Move Towards
		add(100, 103, "0e"); // Speed Horizontal
		add(101, 104, "0e"); // Speed Vertical
		add(102, 107, "1e0e"); // Set Gravity
		add(200, 113); // Reverse Horizontal
		add(201, 114); // Reverse Vertical
		add(202, 108, "0e"); // Set Friction
		add(300, 109, "0e1e"); // Jump to Position
		add(301, 110); // Jump to Start
		add(302, 111, "0e1e"); // Jump to Random
		add(400, 117, "0e1e"); // Align to Grid
		add(401, 112, "0[horizontal|vertical|in both directions]"); // Wrap Screen
		add(500, 116, "0e1e2[solid objects|all objects]"); // Move to Contact
		add(501, 115, "0[not precisely|precisely]1[solid objects|all objects]"); // Bounce
		add(600, 119, "3[relative|absolute]0*1e2[stop|continue from start|continue from here|reverse]"); // Set Path
		add(601, 124); // End Path
		add(700, 122, "0e"); // Path Position
		add(701, 123, "0e"); // Path Speed
		add(800, 120, "0e1e2e3[solid only|all instances]"); // Step Towards
		add(801, 121, "0e1e2e3[solid only|all instances]"); // Step Avoiding
		//}
		//{ main1
		add(003, 201, "0*1e2e"); // Create Instance
		add(004, 206, "0*1e2e3e4e"); // Create Moving
		add(005, 207, "0*1*2*3*4e5e"); // Create Random
		add(103, 202, "0*1[not|yes]"); // Change Instance
		add(104, 203); // Destroy Instance
		add(105, 204, "0e1e"); // Destroy at Position
		add(203, 541, "0*1e2e"); // Change Sprite
		add(204, 542, "0e1e2e3[no mirroring|mirror horizontally|flip vertically|mirror and flip]"); // Transform Sprite
		add(205, 543, "0*1e"); // Color Sprite
		add(303, 211, "0*1*"); // Play Sound
		add(304, 212, "0*"); // Stop Sound
		add(305, 213, "0*"); // Check Sound
		add(403, 221); // Previous Room
		add(404, 222); // Next Room
		add(405, 223); // Restart Room
		add(503, 224, "0*"); // Different Room
		add(504, 225); // Check Previous
		add(505, 226); // Check Next
		//}
		//{ main2
		add(006, 301, "1[Alarm 0|Alarm 1|Alarm 2|Alarm 3|Alarm 4|Alarm 5|Alarm 6|Alarm 7|Alarm 8|Alarm 9|Alarm 10|Alarm 11]0e"); // Set Alarm
		add(106, 305, "0*1e2[Start Immediately|Don't Start]3[Don't Loop|Loop]"); // Set Time Line
		add(107, 304, "0e"); // Time Line Position
		add(108, 309, "0e"); // Time Line Speed
		add(206, 306); // Start Time Line
		add(207, 307); // Pause Time Line
		add(208, 308); // Stop Time Line
		add(306, 321, "0*"); // Display Message
		add(308, 322, "0*"); // Open URL
		add(606, 331); // Restart Game
		add(607, 332); // End Game
		add(706, 333, "0*"); // Save Game
		add(707, 334, "0*"); // Load Game
		add(806, 803, "0*1*2e"); // Replace Sprite
		add(808, 805, "0*1*"); // Replace Background
		//}
		//{ control
		add(009, 401, "0e1e2[Only solid|All]"); // Check Empty
		add(010, 402, "0e1e2[Only solid|All]"); // Check Collision
		add(011, 403, "1e2e0*"); // Check Object
		add(109, 404, "0*2[equal to|smaller than|larger than]1e"); // Test Instance Count
		add(110, 405, "0e"); // Test Chance
		add(111, 407, "0*"); // Check Question
		add(209, 408, "0e"); // Test Expression
		add(210, 409, "0[no|left|right|middle]"); // Check Mouse
		add(211, 410, "0e1e"); // Check Grid
		add(309, 422); // Start Block
		add(310, 421); // Else
		add(311, 425); // Exit Event
		add(409, 424); // End Block
		add(410, 423, "0e"); // Repeat
		add(411, 604); // Call Parent Event
		add(509, 603, "0E"); // Execute Code
		add(510, 601, "0*1e2e3e4e5e"); // Execute Script
		add(511, 605, "0*"); // Comment
		add(609, 611, "0e1e"); // Set Variable
		add(610, 612, "0e2[equal to|less than|greater than|less than or equal to|greater than or equal to]1e"); // Test Variable
		add(611, 613, "1e2e0e"); // Draw Variable
		//}
		//{ score
		add(012, 701, "0e"); // Set Score
		add(013, 702, "1[equal to|smaller than|larger than]0e"); // Test Score
		add(014, 703, "0e1e2*"); // Draw Score
		add(113, 707); // Clear Highscore
		add(212, 711, "0e"); // Set Lives
		add(213, 712, "1[equal to|smaller than|larger than]0e"); // Test Lives
		add(214, 713, "0e1e2*"); // Draw Lives
		add(312, 714, "0e1e2*"); // Draw Life Images
		add(412, 721, "0e"); // Set Health
		add(413, 722, "1[equal to|smaller than|larger than]0e"); // Test Health
		add(414, 723, "0e1e2e3e4[none|black|gray|silver|white|maroon|green|olive|navy|purple|teal|red|lime|yellow|blue|fuchsia|aqua]5[green to red|white to black|black|gray|silver|white|maroon|green|olive|navy|purple|teal|red|lime|yellow|blue|fuchsia|aqua]"); // Draw Health
		//}
		//{ extra
		/*
		add(015, 820, "0e"); // Create Part System
		add(016, 821); // Destroy Part System
		add(017, 822); // Clear Part System
		add(115, 823, "0[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]1[pixel|disk|square|line|star|circle|ring|sphere|flare|spark|explosion|cloud|smoke|snow]2*3e4e5e"); // Create Particle
		add(116, 824, "0[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]1[mixed|changing]2*3*4e5e"); // Particle Color
		add(117, 826, "0[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]1e2e"); // Particle Life
		add(215, 827, "0[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]1e2e3e4e5e"); // Particle Speed
		add(216, 828, "0[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]1e2e"); // Particle Gravity
		add(217, 829, "0[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]2e1[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]4e3[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]"); // Particle Secondary
		add(315, 831, "0[emitter 0|emitter 1|emitter 2|emitter 3|emitter 4|emitter 5|emitter 6|emitter 7]1[rectangle|ellipse|diamond|line]2e3e4e5e"); // Create Emitter
		add(316, 832, "0[emitter 0|emitter 1|emitter 2|emitter 3|emitter 4|emitter 5|emitter 6|emitter 7]"); // Destroy Emitter
		add(317, 833, "2e1[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]0[emitter 0|emitter 1|emitter 2|emitter 3|emitter 4|emitter 5|emitter 6|emitter 7]"); // Burst from Emitter
		add(415, 834, "2e1[type 0|type 1|type 2|type 3|type 4|type 5|type 6|type 7|type 8|type 9|type 10|type 11|type 12|type 13|type 14|type 15]0[emitter 0|emitter 1|emitter 2|emitter 3|emitter 4|emitter 5|emitter 6|emitter 7]"); // Stream from Emitter
		add(515, 801, "0*1[don't show|show]"); // Set Cursor
		*/
		//}
		//{ draw
		add(020, 500); // Draw Self
		add(018, 501, "1e2e3e0*"); // Draw Sprite
		add(019, 502, "1e2e0*3*"); // Draw Background
		add(118, 514, "1e2e0*"); // Draw Text
		add(119, 519, "1e2e0*3e4e5e"); // Draw Scaled Text
		add(218, 511, "0e1e2e3e4[filled|outline]"); // Draw Rectangle
		add(219, 516, "0e1e2e3e4*5*"); // Horizontal Gradient
		add(220, 517, "0e1e2e3e4*5*"); // Vertical Gradient
		add(318, 512, "0e1e2e3e4[filled|outline]"); // Draw Ellipse
		add(319, 518, "0e1e2e3e4*5*"); // Gradient Ellipse
		add(418, 513, "0e1e2e3e"); // Draw Line
		add(419, 515, "0e1e2e3e4e"); // Draw Arrow
		add(518, 524, "0*"); // Set Color
		add(519, 526, "0*1[left|center|right]"); // Set Font
		add(520, 531, "0[switch|window|fullscreen]"); // Set Full Screen
		add(618, 802, "0*"); // Take Snapshot
		add(619, 532, "3[small|medium|large]0[explosion|ring|ellipse|firework|smoke|smoke up|star|spark|flare|cloud|rain|snow]1e2e4*5[below objects|above objects]"); // Create Effect
		//}
		list.push(new NodeGmxObject("<object>@{ml}<PhysicsObject>@{ml}</object>"));
	}
}