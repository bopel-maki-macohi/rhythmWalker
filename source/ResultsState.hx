import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import song.SongRank;

class ResultsState extends ConductorState
{
	var songScore:Int;
	var songRank:SongRank;
	var songRankPercent:Float;

	override public function new(songCode:String)
	{
		super();

		songScore = Save.songScores.get(songCode);
		songRank = Save.songRanks.get(songCode);
		songRankPercent = Save.songRankPercents.get(songCode);
	}

	var windupScore:Float = 0;
	var windupText:FlxText;

	override function create()
	{
		super.create();

		windupText = new FlxText(0, 0, 0, '', 32);
		add(windupText);

		windupText.alignment = CENTER;
		windupText.screenCenter();


        FlxG.sound.play(Paths.getAudio('results/results'));

		FlxTween.num(0, songScore, 4, {
			ease: FlxEase.quintInOut,
			onComplete: t ->
			{
				FlxG.camera.flash(FlxColor.WHITE, 1, onWindupDone);
			}
		}, v ->
		{
			windupScore = v;

			windupText.text = 'Score:\n${Math.floor(windupScore)}';
			windupText.screenCenter();
		});
	}

	function onWindupDone() {}
}
