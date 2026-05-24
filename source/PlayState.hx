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

		makePlayer();

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;

		generateStage();

		add(player);

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
			addEvent(event);

		if (FlxG.sound.music.length < 1)
			onSongEnd();

		if (introCutscene())
		{
			inIntroCutscene = true;
			return;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		scoreText.text = 'Score: $score | Hits: $hits';
		scoreText.screenCenter(X);

		playerCollision.x = player.getGraphicMidpoint().x - (playerCollision.width / 2);
		playerCollision.y = player.getGraphicMidpoint().y - (playerCollision.height / 2);

		if (!inCutscene)
			managePlayer();

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * scrollSpeed);

			if (!inCutscene && monster.overlaps(playerCollision) && !playerStunned && FlxG.camera.visible && FlxG.camera.alpha > 0.1)
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

		if (FlxG.keys.justPressed.ESCAPE)
		{
			seenEndCutscene = seenIntroCutscene = true;
			onSongEnd();
		}
	}

	function onSongEnd()
	{
		inEndCutscene = true;

		if (endCutscene())
		{
			trace('Playin end cutscene');
			return;
		}

		trace('Yay we done');
		FlxG.switchState(() -> new Freeplay());
	}

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

		if (!inCutscene && !playerStunned)
			score += 25;
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		// trace('beat');

		if (!inEndCutscene && data.beatMonsters.spawn && Math.floor(beat % data.beatMonsters.rate) < 1)
			spawnBeatMonster();
	}

	function spawnBeatMonster()
	{
		var beatMonster:FlxSprite = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);
		beatMonster.scale.y = beatMonster.scale.x = data.beatMonsters.scale;
		beatMonster.updateHitbox();

		beatMonster.x = player.getGraphicMidpoint().x - (beatMonster.width / 2);
		beatMonster.y = beatMonster.height * -2;

		beatMonsters.add(beatMonster);
	}

	var data = {
		beatMonsters: {
			spawn: true,
			rate: 1.0,
			scale: 1.0,
		}
	};

	public function addEvent(event:SongEventData)
	{
		var songEvent = new FlxTimer();
		songEvents.push(songEvent);

		songEvent.start(event.time / 1000, function(t)
		{
			parseEvent(event);
			songEvents.remove(songEvent);
		});
	}

	public function parseEvent(event:SongEventData)
	{
		trace(event);

		switch (event.id.toLowerCase())
		{
			case 'traingetaway-swapPeople':
				if (song.id == 'train getaway')
					return;

			case 'traingetaway-reload':
				if (song.id == 'train getaway')
					return;

			case 'traingetaway-gunJammeD':
				if (song.id == 'train getaway')
					return;

			case 'traingetaway-gun':
				if (song.id == 'train getaway')
					return;

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

	public var stageBackLayer:FlxSpriteGroup;

	public function generateStage()
	{
		switch ([song.id, song.variation])
		{
			case ['train getaway', defaultVariation]:
				makeStage('train-getaway');

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
			case 'train-getaway':
				var fireSegs:Array<Float> = [];
				var jammedSegs:Array<Float> = [];

				function addIncrementSeg(start:Float, inc:Int, skip:Array<Int>, ?jammed:Bool)
				{
					var incs = [0, 0.187, 0.375, 0.562, 0.750, 0.937, 1.125,];

					for (i in 0...inc)
					{
						if (!skip.contains(i))
							if (jammed)
								jammedSegs.push(start + incs[i]);
							else
								fireSegs.push(start + incs[i]);
					}
				}

				function addSeg(seg:Array<Float>)
				{
					for (thing in seg)
						fireSegs.push(thing);
				}

				addIncrementSeg(3, 7, []);
				addSeg([4.500, 4.781, 5.062, 5.343, 5.625]);
				addIncrementSeg(6, 7, [3]);
				addIncrementSeg(9, 7, [3]);
				addIncrementSeg(12, 7, [3]);
				addIncrementSeg(15, 7, [3]);
				addIncrementSeg(18, 7, [3]);
				addIncrementSeg(21, 7, [3]);
				addIncrementSeg(24, 7, [3], true);

				addIncrementSeg(27, 7, [3]);
				addIncrementSeg(30, 7, [3]);
				addIncrementSeg(33, 7, [3]);

				for (time in fireSegs)
					addEvent({
						time: time * 1000,
						id: 'traingetaway-gun'
					});

				for (time in jammedSegs)
					addEvent({
						time: time * 1000,
						id: 'traingetaway-gunJammed'
					});

				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('stages/train-getaway/sky'));
				sky.scale.set(2, 2);
				sky.velocity.x = 256 * -5;
				sky.screenCenter(X);
				stageBackLayer.add(sky);

				var train:StageSprite = new StageSprite('train-getaway/train');
				train.setScale(2);
				train.screenCenter();
				train.y = FlxG.height - train.height;
				stageBackLayer.add(train);

				player.scale.set(1, 1);
				player.updateHitbox();

				player.screenCenter();
				player.y = FlxG.height - player.height * 2.3;

				data.beatMonsters.scale = 0.5;

				persistentUpdate = true;

			case 'chinatown-bridge':
				persistentUpdate = true;

				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('stages/chinatown-bridge/sky'));
				sky.scale.set(4, 4);
				sky.updateHitbox();

				sky.velocity.x = 2;
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

	public function makePlayer()
	{
		var file:String = 'bro-regular';

		switch (song.id)
		{
			case 'scroll down chinatown':
				file = 'bro-chinatown';
		}

		// player = new FlxSprite().makeGraphic(64, 128, FlxColor.WHITE);
		player = new FlxSprite().loadGraphic(Paths.getImagePath('player/$file'), true, 64, 64);

		player.animation.add('idle', [0], 24, false);
		player.animation.add('hurt', [1], 2, false);
		player.animation.add('move', [2, 3], 6, false);

		if (file == 'bro-chinatown')
		{
			player.animation.add('chinatown-bridge', [4]);
			player.animation.add('chinatown-bridge-lookup', [4, 5, 6, 7, 8], 6, false);
			player.animation.add('chinatown-bridge-jump', [9], 6, false);
		}

		player.animation.play('idle');

		player.scale.set(2, 2);
		player.updateHitbox();

		player.animation.onFinish.add(animName ->
		{
			if (!inCutscene)
			{
				player.animation.play('idle');
				playerStunned = false;
			}
		});
	}

	var inIntroCutscene:Bool = false;
	var inEndCutscene:Bool = false;

	public var inCutscene(get, never):Bool;

	function get_inCutscene():Bool
		return inIntroCutscene || inEndCutscene;

	var seenEndCutscene:Bool = false;
	var seenIntroCutscene:Bool = false;

	public function introCutscene():Bool
	{
		if (seenIntroCutscene)
			return false;

		seenIntroCutscene = true;

		switch (song.id)
		{
			case 'scroll down chinatown':
				player.animation.play('chinatown-bridge');
				player.y -= player.height * 0.5;

				FlxTimer.wait(7.5, () ->
				{
					inEndCutscene = true;

					player.animation.play('chinatown-bridge-lookup');
					player.animation.onFinish.add(animName ->
					{
						if (animName == 'chinatown-bridge-lookup')
						{
							FlxTimer.wait(.2, () ->
							{
								spawnBeatMonster();
							});

							FlxTween.tween(player, {x: player.x - 128}, .4, {
								ease: FlxEase.sineOut,
							});

							FlxTween.tween(player, {y: player.y + player.height * 0.5}, .4, {
								ease: FlxEase.sineOut,
								onStart: t ->
								{
									player.animation.play('chinatown-bridge-jump');
								},
								onComplete: t ->
								{
									player.animation.play('idle');
									inEndCutscene = inIntroCutscene = false;
								}
							});
						}
					});
				});

				return true;
		}

		return false;
	}

	public function endCutscene():Bool
	{
		if (seenEndCutscene)
			return false;

		seenEndCutscene = true;

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
