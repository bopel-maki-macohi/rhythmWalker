import flixel.math.FlxMath;
import lime.app.Application;
import flixel.FlxG;
import song.SongRank;

typedef SaveData =
{
	?songScores:Map<String, Int>,
	?songRanks:Map<String, SongRank>,
	?songRankPercents:Map<String, Float>,
};

class Save
{
	public static var songScores:Map<String, Int> = [];
	public static var songRanks:Map<String, SongRank> = [];
	public static var songRankPercents:Map<String, Float> = [];

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
		game.songRankPercents ??= [];

		#if !clear
		songScores = game.songScores;
		songRanks = game.songRanks;
		songRankPercents = game.songRankPercents;
		#end

		trace(game);
	}

	public static function save()
	{
		game.songScores = songScores;
		game.songRanks = songRanks;
		game.songRankPercents = songRankPercents;

		FlxG.save.flush();

		trace(game);
	}

	public static function saveSongScore(id:String, score:Int, totalScore:Int)
	{
		var songScore:Int = songScores.get(id) ?? 0;
		var songRank:SongRank = songRanks.get(id) ?? NONE;
		var songRankPercent:Float = songRankPercents.get(id) ?? 0;

		if (score > songScore)
		{
			trace('NEW HIGHSCORE FOR "$id": $score');
			trace(' | $score / $totalScore');

			songScore = score;

			songRankPercent = FlxMath.roundDecimal(score / totalScore, 2);
			songRank = SongRank.getRankFromPercent(songRankPercent);
		}

		songScores.set(id, songScore);
		songRanks.set(id, songRank);
		songRankPercents.set(id, FlxMath.roundDecimal(songRankPercent, 2));
	}
}
