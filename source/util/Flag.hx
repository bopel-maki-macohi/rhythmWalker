package util;

import util.macro.DefineMacro;

enum abstract Flag(Bool) from Bool to Bool
{
	public static var list:Map<String, Flag> = [];

	public static final IS_DEBUG = new Flag('IS_DEBUG', [DefineMacro.isDefined('debug'),]);

	public static final PLATFORM_WINDOWS = new Flag('PLATFORM_WINDOWS', [DefineMacro.isDefined('windows')]);
	public static final PLATFORM_MAC = new Flag('PLATFORM_MAC', [DefineMacro.isDefined('mac')]);
	public static final PLATFORM_LINUX = new Flag('PLATFORM_LINUX', [DefineMacro.isDefined('linux')]);
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
