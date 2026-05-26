package util;

import flixel.FlxG;

using StringTools;

class WindowUtil
{
	public static inline function resetTitle(?includeVersion:Bool)
	{
		FlxG.stage.window.title = 'Rhythm Walker';

		if (includeVersion)
			appendVersion();
	}

	public static inline function appendToTitle(str:String)
	{
		if (str.trim().length < 1)
			return;

		FlxG.stage.window.title += ' $str';
	}

	public static inline function appendVersion()
	{
		appendToTitle('(v${FlxG.stage.application.meta.get('version')})');
	}

	public static inline function alert(message:String)
	{
		FlxG.stage.window.alert(message, FlxG.stage.window.title);
	}
}
