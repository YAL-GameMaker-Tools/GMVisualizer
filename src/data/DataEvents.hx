package data;
import types.NodeEvent;

/**
 * ...
 * @author YellowAfterlife
 */
class DataEvents {
	public static function get():Array<NodeEvent> {
		var events = [];
		inline function add(id:String, icon:Int) {
			events.push(new NodeEvent(id, icon));
		}
		add("Create Event:", 0);
		add("Destroy Event:", 1);
		for (i in 0 ... 12) add('Alarm Event for alarm $i:', 2);
		add("Begin Step Event:", 3);
		add("Step Event:", 3);
		add("End Step Event:", 3);
		add("Draw Event:", 5);
		add("Collision Event with object @i:", 6);
		//
		for (b in ["Left", "Right", "Middle"]) {
			for (t in ["Button", "Pressed", "Released"]) {
				add('Mouse Event for $b $t:', 7);
				add('Mouse Event for Glob $b $t:', 7);
			}
		}
		for (m in ["", "No Button", "Mouse Enter", "Mouse Leave",
		"Mouse Wheel Up", "Mouse Wheel Down"]) {
			add('Mouse Event for $m:', 7);
		}
		//add(
		for (i in 0 ... 3) {
			var et = ["Keyboard", "Key Press", "Key Release"][i];
			var ei = 8 + i;
			add(et + " Event for @i Key:", ei);
			add(et + " Event for @i-key Key:", ei);
		}
		// other events:
		for (i in 0 ... 16) add('Other Event: User Defined $i:', 4);
		for (i in 0 ... 8) {
			add('Other Event: Outside View $i:', 4);
			add('Other Event: Boundary View $i:', 4);
		}
		for (s in ["Outside Room", "Intersect Boundary",
			"Game Start", "Game End", "Room Start", "Room End",
			"No More Lives", "No More Health",
			"Animation End", "End Of Path", "Close Button"]) {
			add('Other Event: $s:', 4);
		}
		add("Unknown Event (@{su}:@{su}):", 4);
		return events;
	}
}
