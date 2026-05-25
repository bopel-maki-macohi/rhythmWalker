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

	public static final PLAY_SHADERS = new Flag('PLAY_SHADERS', [!DefineMacro.isDefined('DISABLE_PLAY_SHADERS')]);
	public static final PLAY_IMMORTAL = new Flag('PLAY_IMMORTAL', [DefineMacro.isDefined('immortal') || DefineMacro.isDefined('IMMORTAL')]);

	public static final FREEPLAY_BGAUDIO = new Flag('FREEPLAY_BGAUDIO', [!PLATFORM_LINUX, !DefineMacro.isDefined('DISABLE_FREEPLAY_BGAUDIO')]);

	public static final FREEPLAY_DISPLAY_TIP = new Flag('FREEPLAY_DISPLAY_TIP', []);
	public static final FREEPLAY_DISPLAY_SONG_SCORE = new Flag('FREEPLAY_DISPLAY_SONG_SCORE', [!PLATFORM_WEB]);
	public static final FREEPLAY_DISPLAY_SONG_RANK = new Flag('FREEPLAY_DISPLAY_SONG_RANK', [!PLATFORM_WEB]);
	public static final FREEPLAY_DISPLAY_SONG_PLAYED = new Flag('FREEPLAY_DISPLAY_TIP', [!PLATFORM_WEB, FREEPLAY_DISPLAY_SONG_RANK]);

	public static final FREEPLAY_VISUALIZER = new Flag('FREEPLAY_VISUALIZER', [
		!PLATFORM_LINUX,
		!DefineMacro.isDefined('DISABLE_FREEPLAY_VISUALIZER')
	]);
	public static final FREEPLAY_VISUALIZER_MULTICACHE = new Flag('FREEPLAY_VISUALIZER_MULTICACHE', [FREEPLAY_VISUALIZER, !PLATFORM_LINUX, !IS_32BIT,]);

	public static final STARTINGSTATE_DIALOGUE = new Flag('STARTINGSTATE_DIALOGUE', [DefineMacro.isDefined('DIALOGUE')]);
	public static final STARTINGSTATE_RESULTS = new Flag('STARTINGSTATE_RESULTS', [DefineMacro.isDefined('RESULTS')]);

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
