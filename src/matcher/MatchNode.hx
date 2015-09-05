package matcher;

/**
 * @author YellowAfterlife
 */

enum MatchNode {
	/// Plain text snippet
	MnText(text:String);
	/// "@[a|b|c]": Any of options in the set.
	MnSet(list:Array<String>);
	/// "@L": String lasting until the end of the line.
	MnEOL;
	/// "@{su}": "Cautious" string
	MnStringUntil;
	/// "@{mu}": "Cautious" multi-line string
	MnMultiline;
	/// "\n": Linebreak
	MnLN;
	/// "@e": An inline GML expression.
	MnExpr;
	/// "@{eu}": "Cautious" expression
	MnExprUntil;
	/// "@]": Soaks up extra spaces after expressions
	MnSpaces;
	/// "@s": " \t\r\n"
	MnWhitespace;
	/// "@{code}": Mutli-line GML code (spans until the invalid expression)
	MnCode;
	/// "@r": Optional "relative ".
	MnRelative;
	/// "@w": Optional "with"-prefix.
	MnWith;
	/// "@N": Optional "not ".
	MnNot;
	/// "@i": Resource index.
	MnResource;
	/// "@c": BGR color integer.
	MnColor;
}