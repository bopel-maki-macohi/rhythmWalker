package;

import flixel.addons.display.FlxBackdrop;
import stage.StageSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import song.SongVariation;
import song.SongEventData;
import flixel.util.FlxTimer;
import song.Song;
import flixel.addons.sound.FlxRhythmConductorUtil;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class PlayState extends ConductorState
{
	var player:FlxSprite;
	var playerSpeed:Float = 10;
	var playerStunned:Bool = false;
	var playerCollision:FlxSprite;

	var beatMonsters:FlxSpriteGroup;

	var scrollSpeed:Float = 1;

	var song:Song;
	var songEvents:Array<FlxTimer> = [];

	var scoreText:FlxText;
	var score:Int = 0;
	var hits:Int = 0;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super();

		this.song = new Song(song, variation ?? defaultVariation);
	}

	override public function create()
	{
		super.create();

		scrollSpeed = song.scrollSpeed;

		resetConductor();

		FlxG.sound.playMusic(Paths.getSong(song.id, song.variation), 1, false);
		FlxG.sound.music.onComplete = onSongEnd;

		trace(FlxG.sound.music.length);

		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(song.bpmChanges));

		stageBackLayer = new FlxSpriteGroup();
		add(stageBackLayer);

		generateStage();

		makePlayer();

		add(player);

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;

		playerCollision = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);
		add(playerCollision);
		playerCollision.alpha = .25; // idk if i want it on i want it subtle
		playerCollision.visible = false;

		beatMonsters = new FlxSpriteGroup();
		add(beatMonsters);

		scoreText = new FlxText(0, 0, 0, 'BOB', 16);
		add(scoreText);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);

		for (event in song.events)
		{
			var songEvent = new FlxTimer();
			songEvents.push(songEvent);

			songEvent.start(event.time / 1000, function(t)
			{
				parseEvent(event);
				songEvents.remove(songEvent);
			});
		}

		if (FlxG.sound.music.length < 1)
			onSongEnd();

		persistentUpdate = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		scoreText.screenCenter(X);
		scoreText.text = 'Score: $score | Hits: $hits';

		playerCollision.x = player.getGraphicMidpoint().x - (playerCollision.width / 2);
		playerCollision.y = player.getGraphicMidpoint().y - (playerCollision.height / 2);

		if (!inCutscene)
			managePlayer();

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * scrollSpeed);

			if (!inCutscene)
				if (monster.overlaps(playerCollision) && !playerStunned && FlxG.camera.visible && FlxG.camera.alpha > 0.1)
				{
					playerStunned = true;
					player.animation.play('hurt');
					player.velocity.x = 0;

					beatMonsters.remove(monster);
					monster.destroy();

					hits++;
				}

			if (monster.y > FlxG.height + monster.height)
			{
				beatMonsters.remove(monster);
				monster.destroy();
			}
		}
	}

	function managePlayer()
	{
		var shiftThing:Float = 1;
		player.maxVelocity.x = 200 * scrollSpeed;

		if (FlxG.keys.pressed.SHIFT)
			shiftThing *= 2;

		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			player.flipX = false;
			player.velocity.x -= playerSpeed * shiftThing;
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			player.flipX = true;
			player.velocity.x += playerSpeed * shiftThing;
		}
		else
			player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);

		if (FlxG.keys.anyPressed([A, LEFT, D, RIGHT]) && !playerStunned)
			player.animation.play('move');

		if (player.x < player.width)
		{
			player.x = player.width;
			player.velocity.x = 0;
		}

		if (player.x > FlxG.width - (player.width * 2))
		{
			player.x = FlxG.width - (player.width * 2);
			player.velocity.x = 0;
		}

		if (player.animation.finished)
		{
			player.animation.play('idle');
			playerStunned = false;
		}
	}

	function onSongEnd()
	{
		inCutscene = true;

		if (endCutscene())
		{
			trace('Playin cutscene');
			return;
		}

		trace('Yay we done');
		FlxG.switchState(() -> new Freeplay());
	}

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

		if (!inCutscene)
			if (!playerStunned)
				score += 25;
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		// trace('beat');

		if (!inCutscene)
			if (data.beatMonsters.spawn && Math.floor(beat % data.beatMonsters.rate) < 1)
			{
				var beatMonster:FlxSprite = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);

				beatMonster.x = player.getGraphicMidpoint().x - (beatMonster.width / 2);
				beatMonster.y = beatMonster.height * -2;

				beatMonsters.add(beatMonster);
			}
	}

	var data = {
		beatMonsters: {
			spawn: true,
			rate: 1.0,
		}
	};

	public function parseEvent(event:SongEventData)
	{
		trace(event);

		switch (event.id.toLowerCase())
		{
			case 'camera-off', 'cam-off':
				FlxG.camera.visible = false;

			case 'camera-on', 'cam-on':
				FlxG.camera.visible = true;

			case 'stage-switch', 'stage-change':
				if (event.data != null)
					makeStage(Std.string(event.data));

			case 'beatmonsters-stop':
				data.beatMonsters.spawn = false;

			case 'beatmonsters-resume':
				data.beatMonsters.spawn = true;

			case 'beatmonsters-setrate', 'beatmonsters-rate':
				if (event.data != null
					&& (Std.isOfType(event.data, Float) || Std.isOfType(event.data, Int) || Std.isOfType(event.data, String)))
					data.beatMonsters.rate = Std.parseFloat(Std.string(event.data)) ?? 1.0;
		}
	}

	public function makePlayer()
	{
		var file:String = 'bro';

		// player = new FlxSprite().makeGraphic(64, 128, FlxColor.WHITE);
		player = new FlxSprite().loadGraphic(Paths.getImagePath('player/$file'), true, 64, 64);

		player.animation.add('idle', [0], 24, false);
		player.animation.add('hurt', [1], 2, false);
		player.animation.add('move', [2, 3], 6, false);
		player.animation.add('chinatown-bridge', [4], 6, false);

		player.animation.play('idle');

		player.scale.set(2, 2);
		player.updateHitbox();
	}

	public var stageBackLayer:FlxSpriteGroup;

	public function generateStage()
	{
		switch ([song.id, song.variation])
		{
			case ['scroll down chinatown', defaultVariation]:
				makeStage('chinatown-bridge');

			default:
				makeStage('stage');
		}
	}

	public function makeStage(?stage:String)
	{
		if (stageBackLayer == null)
			return;

		for (sprite in stageBackLayer.members)
		{
			stageBackLayer.members.remove(sprite);
			sprite.destroy();
		}

		stageBackLayer.clear();

		switch (stage.toLowerCase())
		{
			case 'chinatown-bridge':
				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('stages/chinatown-bridge/sky'));
				sky.scale.set(4,4);
				sky.updateHitbox();

				sky.velocity.x = 32;
				sky.screenCenter();
				stageBackLayer.add(sky);
				
				var bridge:StageSprite = new StageSprite('chinatown-bridge/bridge');
				bridge.screenCenter();
				stageBackLayer.add(bridge);

			case 'stage', 'understage':
				var stage:StageSprite = new StageSprite(stage);
				stage.screenCenter();
				stageBackLayer.add(stage);
		}
	}

	var inCutscene:Bool = false;
	var seenCutscene:Bool = false;

	public function endCutscene():Bool
	{
		if (seenCutscene)
			return false;

		seenCutscene = true;

		switch (song.id)
		{
			case 'shift around':
				var walkTmr:FlxTimer;

				player.animation.play('idle');

				new FlxTimer().start(1 / FlxG.updateFramerate, t ->
				{
					player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);
				}, FlxG.updateFramerate);

				FlxTimer.wait(1, () ->
				{
					player.flipX = true;

					player.animation.play('move');
					player.animation.onFinish.add(anim ->
					{
						player.animation.play('move');
					});

					FlxTween.tween(player, {x: FlxG.width + (player.width * 2)}, 3, {
						ease: FlxEase.sineIn,
					});
				});

				FlxTimer.wait(4, onSongEnd);

				return true;
		}

		return false;
	}
}
