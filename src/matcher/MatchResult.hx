package matcher;

/**
 * Represents a result of Match.read - presence of values depends on type alone.
 * @author YellowAfterlife
 */
typedef MatchResult = {
	/// matched values, in order.
	?values:Array<Dynamic>,
	/// action context. null if not set.
	?with:String,
	/// whether `relative` flag is set (some actions)
	?relative:Bool,
	/// whether `not` flag is set (conditions only)
	?not:Bool,
}
