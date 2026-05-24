import lime.app.Application;
import flixel.FlxG;
import song.SongRank;

class Save
{
	public static var songScores:Map<String, Int> = [];
	public static var songRanks:Map<String, SongRank> = [];

	public static var game(get, set):Dynamic;

	static function get_game():Dynamic
		return FlxG.save.data.game;

	static function set_game(value:Dynamic):Dynamic
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

		game.songScores ??= [];
		game.songRanks ??= [];

		songScores = game.songScores;
		songRanks = game.songRanks;

		trace(game);
	}

	public static function save()
	{
		game.songScores = songScores;
		game.songRanks = songRanks;

		FlxG.save.flush();

		trace(game);
	}
}
