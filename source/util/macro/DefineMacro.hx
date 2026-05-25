package util.macro;

import haxe.macro.Expr.ExprOf;

class DefineMacro
{
	public static macro function isDefined(str:String):ExprOf<Bool>
	{
		return macro $v{haxe.macro.Context.defined(str)};
	}
}
