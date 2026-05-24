import flixel.util.FlxTimer;
import flixel.FlxSprite;
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
				FlxTimer.wait(.5, () ->
				{
					FlxG.camera.flash(FlxColor.WHITE, 1);
					onWindupDone();
				});
			}
		}, v ->
		{
			final prev = Math.floor(windupScore);

			windupScore = v;

			if (Math.floor(windupScore) != prev)
				FlxG.sound.play(Paths.getAudio('results/resultsTick'), 0.2);

			windupText.text = 'Score:\n${Math.floor(windupScore)}';
			windupText.screenCenter();
		});
	}

	function onWindupDone()
	{
		FlxG.sound.play(Paths.getAudio('results/resultsTickDone'));

		windupText.size *= 2;
		windupText.screenCenter();
		windupText.x -= windupText.width / 2;

		var were:Bool = (songRank != BAD);

		var didWere = new FlxSprite(0, 0, Paths.getImagePath('results/${(were) ? 'were' : 'did'}'));
		add(didWere);
		didWere.scale.set(2, 2);
		didWere.updateHitbox();
		didWere.screenCenter();

		var rank = new FlxSprite(0, 0, Paths.getImagePath('results/ranks/$songRank'));
		add(rank);
		rank.scale.set(2, 2);
		rank.updateHitbox();
		rank.screenCenter();

		windupDone = true;

		leaveTimer = new FlxTimer().start(5, t ->
		{
			leave();
		});
	}

	var windupDone = false;

	var leaveTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (windupDone && !leaveTimer.finished && FlxG.keys.anyJustPressed([ENTER, ESCAPE]))
		{
			leaveTimer.cancel();
			leave();
		}
	}

	function leave()
	{
		FlxG.switchState(() -> new Freeplay());
	}
}
