package data;

/**
 * ...
 * @author YellowAfterlife
 */
class DataInfo {
	public static function run(list:Array<NodeType>) {
		var r:NodeType;
		inline function add(code:String) {
			list.push(r = new NodeType(code));
		}
		add("Sprite: @i");
		add("Sprite: ");
		add("Solid: @e");
		add("Visible: @e");
		add("Depth: @e");
		add("Persistent: @e");
		add("Parent: @i");
		add("Parent: ");
		add("Mask: @i");
		add("Mask: ");
		add("Children:");
		// physics:
		add("No Physics Object");
		add("Start Awake: @e");
		add("Is Kinematic: @e");
		add("Is Sensor: @e");
		add("Density: @e");
		add("Restitution: @e");
		add("Group: @e");
		add("Linear Damping: @e");
		add("Angular Damping: @e");
		add("Friction: @e");
		add("Shape: @e");
		// header:
		types.NodeHeader.inst = new types.NodeHeader();
		types.NodeSeparator.inst = new types.NodeSeparator();
	}
}