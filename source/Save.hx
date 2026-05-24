import lime.app.Application;
import flixel.FlxG;
import song.SongRank;

typedef SaveData =
{
	?songScores:Map<String, Int>,
	?songRanks:Map<String, SongRank>,
};

class Save
{
	public static var songScores:Map<String, Int> = [];
	public static var songRanks:Map<String, SongRank> = [];

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

		game.songScores ??= [];
		game.songRanks ??= [];

		#if !clear
		songScores = game.songScores;
		songRanks = game.songRanks;
		#end

		trace(game);
	}

	public static function save()
	{
		game.songScores = songScores;
		game.songRanks = songRanks;

		FlxG.save.flush();

		trace(game);
	}

	public static function saveSongScore(id:String, score:Int, totalScore:Int)
	{
		var songScore:Int = songScores.get(id) ?? 0;
		var songRank:SongRank = songRanks.get(id) ?? NONE;

		if (score > songScore)
		{
			trace('NEW HIGHSCORE: $score');
			trace(' | $score / $totalScore');

			songScore = score;
			songRank = SongRank.getRankFromPercent(score / totalScore);
		}

		songScores.set(id, songScore);
		songRanks.set(id, songRank);
	}
}
