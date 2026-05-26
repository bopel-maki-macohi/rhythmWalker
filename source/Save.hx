import util.Flag;
import flixel.math.FlxMath;
import lime.app.Application;
import flixel.FlxG;

using StringTools;

typedef SaveData =
{
	?saveVer:Int
}

class Save
{
	public static final CURSAVEVER:Int = 2;
	public static var saveVer:Int = CURSAVEVER;

	public static var game(get, set):SaveData;

	static function get_game():SaveData
		return FlxG.save.data.game;

	static function set_game(value:SaveData):SaveData
		return FlxG.save.data.game = value;

	public static function init()
	{
		FlxG.save.bind('RhythmWalker', 'Maki');

		load();

		Application.current.onExit.add(function(l)
		{
			save();
		});
	}

	public static function load()
	{
		game ??= {};
		game.saveVer ??= CURSAVEVER;

		if (!Flag.SAVE_CLEAR)
		{
			saveVer = game.saveVer;
		}

		trace(game);
	}

	public static function save()
	{
		game.saveVer = saveVer;

		FlxG.save.flush();

		trace(game);
	}
}
