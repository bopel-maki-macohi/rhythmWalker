package util;

import util.macro.DefineMacro;

enum abstract Flag(Bool) from Bool to Bool
{
	public static var list:Map<String, Flag> = [];

	public static final IS_32BIT = new Flag('IS_32BIT', [DefineMacro.isDefined('_32bit'),]);

	public static final PLATFORM_LINUX = new Flag('PLATFORM_LINUX', [DefineMacro.isDefined('linux')]);

	public static final FREEPLAY_BGAUDIO = new Flag('FREEPLAY_BGAUDIO', [!PLATFORM_LINUX, !DefineMacro.isDefined('DISABLE_FREEPLAY_BGAUDIO')]);
	public static final FREEPLAY_VISUALIZER = new Flag('FREEPLAY_VISUALIZER', [!PLATFORM_LINUX, !DefineMacro.isDefined('DISABLE_FREEPLAY_VISUALIZER')]);
	public static final FREEPLAY_VISUALIZER_MULTICACHE = new Flag('FREEPLAY_VISUALIZER_MULTICACHE', [FREEPLAY_VISUALIZER, !PLATFORM_LINUX, !IS_32BIT,]);

	public function new(id:String, conditionals:Array<Bool>)
	{
		this = conditionals.filter(b -> return b).length == conditionals.length;

		if (!list.exists(id))
			list.set(id, this);
	}
}
