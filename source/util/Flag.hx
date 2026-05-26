package util;

import util.macro.DefineMacro;

enum abstract Flag(Bool) from Bool to Bool
{
	public static var list:Map<String, Flag> = [];

	public static final IS_32BIT = new Flag('IS_32BIT', [DefineMacro.isDefined('_32bit'),]);
	public static final IS_DEBUG = new Flag('IS_DEBUG', [DefineMacro.isDefined('debug'),]);

	public static final PLATFORM_LINUX = new Flag('PLATFORM_LINUX', [DefineMacro.isDefined('linux')]);
	public static final PLATFORM_WEB = new Flag('PLATFORM_WEB', [DefineMacro.isDefined('web')]);
	public static final PLATFORM_HASHLINK = new Flag('PLATFORM_HASHLINK', [DefineMacro.isDefined('hl')]);

	public static final SAVE_CLEAR = new Flag('SAVE_CLEAR', [DefineMacro.isDefined('clear') || DefineMacro.isDefined('SAVE_CLEAR')]);

	public function new(id:String, conditionals:Array<Bool>)
	{
		set(conditionals);

		if (!list.exists(id))
			list.set(id, this);
	}

	public inline function set(conditionals:Array<Bool>)
		this = (conditionals == [] || conditionals.filter(b -> return b).length == conditionals.length);
}
