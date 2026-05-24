package;

import stage.TrainWreakShooter;
import flixel.FlxObject;
import flixel.FlxCamera;
import stage.TrainWreakPiece;
import stage.TrainGetawayShooter;
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

using StringTools;

class PlayState extends ConductorState
{
	var immortal:Bool = #if immortal true #else false #end;

	var player:FlxSprite;
	var playerSpeed:Float = 10;
	var playerStunned:Bool = false;
	var playerCollision:FlxSprite;

	var beatMonsters:FlxSpriteGroup;

	var scrollSpeed:Float = 1;

	var song:Song;
	var songEvents:Array<FlxTimer> = [];

	var scoreText:FlxText;
	var totalScore:Int = 0;
	var score:Int = 0;
	var hits:Int = 0;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var camGameFollow:FlxObject;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super();

		this.song = new Song(song, variation ?? defaultVariation);
	}

	override public function create()
	{
		super.create();

		camGameFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		add(camGameFollow);

		camGame = new FlxCamera();
		FlxG.cameras.add(camGame);

		camGame.follow(camGameFollow, LOCKON, 0.04);

		camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor.alpha = 0;

		scrollSpeed = song.scrollSpeed;

		resetConductor();

		FlxG.sound.playMusic(Paths.getSong(song.id, song.variation), 1, false);
		FlxG.sound.music.onComplete = onSongEnd;

		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(song.bpmChanges));

		trace('song len: ${FlxG.sound.music.length / 1000}s');
		trace('estimated song steps: ${FlxG.sound.music.length / conductor.stepLengthMs}');
		trace('estimated song beats: ${FlxG.sound.music.length / conductor.beatLengthMs}');

		stageBackLayer = new FlxSpriteGroup();
		add(stageBackLayer);
		stageBackLayer.camera = camGame;

		makePlayer();

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;
		player.camera = camGame;

		generateStage();

		add(player);

		// just realized this did not get scaled with the player and now im in a situation,
		// cause I already got used to how it was before.
		// shit.

		playerCollision = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);
		add(playerCollision);
		playerCollision.alpha = .25; // idk if i want it on i want it subtle
		playerCollision.visible = false;
		playerCollision.camera = camGame;

		beatMonsters = new FlxSpriteGroup();
		add(beatMonsters);
		beatMonsters.camera = camGame;

		scoreText = new FlxText(0, 0, 0, 'BOB', 16);
		add(scoreText);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		scoreText.camera = camHUD;

		for (event in song.events)
			addEvent(event);

		if (FlxG.sound.music.length < 1)
		{
			skipping = true;
			onSongEnd();
		}

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

		scoreText.text = 'Score: $score | Hits Taken: $hits';
		scoreText.screenCenter(X);

		playerCollision.x = player.getGraphicMidpoint().x - (playerCollision.width / 2);
		playerCollision.y = player.getGraphicMidpoint().y - (playerCollision.height / 2);

		if (!inCutscene)
			managePlayer();

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * scrollSpeed);

			if (!immortal && !inCutscene && monster.overlaps(playerCollision) && !playerStunned && FlxG.camera.visible && FlxG.camera.alpha > 0.1)
			{
				playerStunned = true;
				if (player.flipX)
					player.animation.play('hurtR');
				else
					player.animation.play('hurtL');
				player.velocity.x = 0;

				beatMonsters.remove(monster);
				monster.destroy();

				FlxG.sound.play(Paths.getAudio('sfx/game/hurt'));

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

			if (!playerStunned)
				player.animation.play('moveL');
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			player.flipX = true;
			player.velocity.x += playerSpeed * shiftThing;

			if (!playerStunned)
				player.animation.play('moveR');
		}
		else
			player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);

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
			skipping = true;
			onSongEnd();
		}
	}

	var skipping:Bool = false;

	function onSongEnd()
	{
		FlxG.sound.music.stop();

		inEndCutscene = true;

		if (endCutscene() && !skipping)
		{
			trace('Playin end cutscene');
			return;
		}

		final songCode = '${song.id}-${song.variation}';

		if (!immortal && !skipping)
			Save.saveSongScore(songCode, score, totalScore);

		trace('Yay we done');

		if (skipping)
			FlxG.switchState(() -> new Freeplay());
		else
			FlxG.switchState(() -> new ResultsState(songCode));
	}

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

		final canSpawnMonster = !inEndCutscene && data.beatMonsters.spawn;

		if (!inCutscene && (canSpawnMonster && data.beatMonsters.stepRate > 0))
		{
			var scoreInc:Int = 25;

			totalScore += scoreInc;
			if (!playerStunned)
				score += scoreInc;
		}

		if (canSpawnMonster && Math.floor(step % data.beatMonsters.stepRate) == 0)
			spawnBeatMonster();
	}

	override function onBeatHit(beat:Int, backward:Bool)
	{
		super.onBeatHit(beat, backward);

		stageBackLayer.forEach(sprite ->
		{
			if (Std.isOfType(sprite, StageSprite))
			{
				var stageSprite = cast(sprite, StageSprite);
				if (stageSprite == null)
					return;

				stageSprite.dance();
			}
		});

		if (trainGetaway_sky != null && subState == null)
		{
			trainGetaway_sky.velocity.x -= trainGetaway_i;
			trainGetaway_i += 0.25;
		}
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
			stepRate: 4,
			scale: 1.0
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
			case 'trainwreak-gun':
				if (song.id == 'train wreak')
					trainWreak_shooter.animation.play('shoot', true);

			case 'traingetaway-swappeople':
				if (song.id == 'train getaway')
					return;

			case 'traingetaway-reload':
				if (song.id == 'train getaway')
					trainGetaway_shooter.animation.play('reload', true);

			case 'traingetaway-gunjammed':
				if (song.id == 'train getaway')
					trainGetaway_shooter.animation.play('jammed', true);

			case 'traingetaway-gun':
				if (song.id == 'train getaway')
					trainGetaway_shooter.animation.play('shoot${FlxG.random.int(1, 2)}', true);

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

			// the old beat system
			case 'beatmonsters-setrate', 'beatmonsters-rate', 'beatmonsters-setbeatrate', 'beatmonsters-beatrate':
				if (event.data != null
					&& (Std.isOfType(event.data, Float) || Std.isOfType(event.data, Int) || Std.isOfType(event.data, String)))
					data.beatMonsters.stepRate = Math.floor((Std.parseFloat(Std.string(event.data)) ?? 1.0) * 4);

			case 'beatmonsters-setsteprate', 'beatmonsters-steprate':
				if (event.data != null
					&& (Std.isOfType(event.data, Float) || Std.isOfType(event.data, Int) || Std.isOfType(event.data, String)))
					data.beatMonsters.stepRate = Math.floor((Std.parseFloat(Std.string(event.data)) ?? 1));
		}
	}

	public var stageBackLayer:FlxSpriteGroup;

	public function generateStage()
	{
		switch ([song.id, song.variation])
		{
			case ['train wreak', defaultVariation]:
				makeStage('train-wreak');

			case ['train getaway', defaultVariation]:
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
				addIncrementSeg(22.5, 7, [3], true);

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

				makeStage('train-getaway');

			case ['scroll down chinatown', defaultVariation]:
				makeStage('chinatown-bridge');

			default:
				makeStage('stage');
		}
	}

	var trainGetaway_i:Float = 1;

	public var trainGetaway_sky:FlxBackdrop;
	public var trainGetaway_shooter:TrainGetawayShooter;

	public var trainWreak_shooter:TrainWreakShooter;

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
			case 'train-wreak':
				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('stages/train-wreak/sky'));
				sky.scale.set(2, 2);
				sky.velocity.x = 10;
				sky.screenCenter(X);
				sky.scrollFactor.set(.25, .25);
				stageBackLayer.add(sky);
				sky.camera = camGame;

				var pieceList:Array<Dynamic> = [
					['city', 0.5],
					['ground', 0.75],

					['crowds/randoms-left', 0.75],
					['crowds/randoms-right', 0.75],

					['crowds/dj', 0.8],
					['crowds/tiago-mobmod', 0.85],
					['crowds/marcella', 0.875],
					['crowds/ocs', 0.9],
					['crowds/super-eric', 0.95],

					['smoke', 1],
					['trainSegment', 1],
					['trainGround', 1],
				];

				var onlyCenter:Array<String> = ['smoke', 'trainSegment', 'trainGround',];

				for (piece in pieceList)
				{
					var isRandom:Bool = Std.string(piece[0]).startsWith('crowds/randoms-');
					var isCrowd:Bool = Std.string(piece[0]).startsWith('crowds/');

					function crowdSpriteShit(spr:TrainWreakPiece)
					{
						spr.setScale(1.75);
						spr.screenCenter();
						// spr.y -= spr.height * .1;
					}

					if (!onlyCenter.contains(piece[0]) && !isCrowd || piece[0] == 'crowds/randoms-left')
					{
						var pieceSprLEFT = new TrainWreakPiece(piece[0], camGame, piece[1]);
						stageBackLayer.add(pieceSprLEFT);

						if (isCrowd)
							crowdSpriteShit(pieceSprLEFT);
						pieceSprLEFT.x -= pieceSprLEFT.width;

						if (isRandom)
							pieceSprLEFT.x += pieceSprLEFT.width * 0.4;
					}

					if (!isRandom)
					{
						var pieceSprCENTER = new TrainWreakPiece(piece[0], camGame, piece[1]);
						stageBackLayer.add(pieceSprCENTER);

						if (isCrowd)
						{
							crowdSpriteShit(pieceSprCENTER);

							if (Std.string(piece[0]).contains('dj'))
								pieceSprCENTER.x -= pieceSprCENTER.width * .05;
							if (Std.string(piece[0]).contains('ocs'))
								pieceSprCENTER.x += pieceSprCENTER.width * .05;
							if (Std.string(piece[0]).contains('marcella'))
							{
								pieceSprCENTER.x += pieceSprCENTER.width * .05;
								pieceSprCENTER.y += pieceSprCENTER.height * .025;
							}
						}

						if (piece[0] == 'smoke')
						{
							pieceSprCENTER.blend = OVERLAY;
							pieceSprCENTER.alpha = 0.5;
						}
					}

					if (!onlyCenter.contains(piece[0]) && !isCrowd || piece[0] == 'crowds/randoms-right')
					{
						var pieceSprRIGHT = new TrainWreakPiece(piece[0], camGame, piece[1]);
						stageBackLayer.add(pieceSprRIGHT);

						if (isCrowd)
							crowdSpriteShit(pieceSprRIGHT);
						pieceSprRIGHT.x += pieceSprRIGHT.width;

						if (isRandom)
							pieceSprRIGHT.x -= pieceSprRIGHT.width * 0.4;
					}
				}

				var solidGround:StageSprite = new StageSprite(null);
				solidGround.setCamera(camGame);
				solidGround.makeGraphic(FlxG.width * 3, FlxG.height, FlxColor.fromString('#3b3e44'));
				solidGround.screenCenter();
				solidGround.y = FlxG.height;
				stageBackLayer.add(solidGround);

				trainWreak_shooter = new TrainWreakShooter(camGame);
				trainWreak_shooter.screenCenter();
				trainWreak_shooter.x -= trainWreak_shooter.width * 0.25;
				trainWreak_shooter.y -= trainWreak_shooter.width * 0.5;
				stageBackLayer.add(trainWreak_shooter);

				player.scale.set(2, 2);
				player.updateHitbox();

				player.screenCenter();
				player.y = FlxG.height - player.height * 1.15;

				// data.beatMonsters.scale = 0.5;

				persistentUpdate = true;

			case 'train-getaway':
				trainGetaway_sky = new FlxBackdrop(Paths.getImagePath('stages/train-getaway/sky'));
				trainGetaway_sky.scale.set(2, 2);
				trainGetaway_sky.velocity.x = 256 * -5;
				trainGetaway_sky.screenCenter(X);
				stageBackLayer.add(trainGetaway_sky);
				trainGetaway_sky.camera = camGame;

				var train:StageSprite = new StageSprite('train-getaway/train');
				train.setScale(2);
				train.screenCenter();
				train.y = FlxG.height - train.height;
				stageBackLayer.add(train);
				train.camera = camGame;

				player.scale.set(1, 1);
				player.updateHitbox();

				player.screenCenter();
				player.y = FlxG.height - player.height * 2.3;

				data.beatMonsters.scale = 0.5;

				persistentUpdate = true;

				trainGetaway_shooter = new TrainGetawayShooter();
				stageBackLayer.add(trainGetaway_shooter);
				trainGetaway_shooter.camera = camGame;

				trainGetaway_shooter.screenCenter();
				trainGetaway_shooter.x = trainGetaway_shooter.width * -5;

				FlxTween.tween(trainGetaway_shooter, {x: FlxG.width - trainGetaway_shooter.width}, 2.75, {
					ease: FlxEase.sineInOut
				});

			case 'chinatown-bridge':
				persistentUpdate = true;

				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('stages/chinatown-bridge/sky'));
				sky.scale.set(4, 4);
				sky.updateHitbox();
				sky.camera = camGame;

				sky.velocity.x = 2;
				sky.screenCenter();
				stageBackLayer.add(sky);

				var bridge:StageSprite = new StageSprite('chinatown-bridge/bridge');
				bridge.screenCenter();
				stageBackLayer.add(bridge);
				bridge.camera = camGame;

			case 'stage', 'understage':
				var stage:StageSprite = new StageSprite(stage);
				stage.screenCenter();
				stageBackLayer.add(stage);
				stage.camera = camGame;
		}
	}

	public function makePlayer()
	{
		var file:String = 'bro-regular';

		switch (song.id)
		{
			case 'train wreak':
				file = 'bro-chinatown-torn';

			case 'scroll down chinatown', 'train getaway':
				file = 'bro-chinatown';
		}

		var animFrames:Map<String, Dynamic> = [
			'idle' => {frames: [0]},
			'hurtL' => {frames: [1], fps: 2},
			'hurtR' => {frames: [1], fps: 2},
			'moveL' => {frames: [2, 3], fps: 6},
			'moveR' => {frames: [2, 3], fps: 6},
		];

		switch (file)
		{
			case 'bro-chinatown-torn':
				animFrames.get('hurtR').flipX = true;
				animFrames.get('moveR').frames = [4, 5];

			case 'bro-chinatown':
				animFrames.set('chinatown-bridge', {
					frames: [4],
				});
				animFrames.set('chinatown-bridge-lookup', {
					frames: [4, 5, 6, 7, 8],
					fps: 6
				});
				animFrames.set('chinatown-bridge-jump', {
					frames: [9],
				});
		}

		// player = new FlxSprite().makeGraphic(64, 128, FlxColor.WHITE);
		player = new FlxSprite().loadGraphic(Paths.getImagePath('player/$file'), true, 64, 64);

		for (thing => data in animFrames)
		{
			trace('Player Anim "$thing" : $data');
			player.animation.add(thing, data.frames, data?.fps ?? 24, false, data.flipX);
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
			case 'train wreak':
				camGameFollow.y -= FlxG.height * 2;
				camGame.zoom = 0.5;
				camGame.focusOn(camGameFollow.getPosition());

				FlxTween.tween(camGameFollow, {y: FlxG.height / 2}, 6, {
					ease: FlxEase.backInOut,
				});

				FlxTween.tween(camGame, {zoom: 1}, 6, {
					startDelay: 5,
					ease: FlxEase.backInOut,
					onComplete: t ->
					{
						stageBackLayer.forEach(sprite ->
						{
							if (Std.isOfType(sprite, StageSprite))
							{
								if (sprite != trainWreak_shooter
									&& (sprite.scale.x >= 2 && !cast(sprite, StageSprite).sprite.contains('randoms')))
									if (sprite.x != 0 || sprite.y != 0)
									{
										stageBackLayer.remove(sprite);
										sprite.destroy();
									}
							}
						});
					}
				});

				FlxTimer.wait(12, () ->
				{
					inIntroCutscene = false;
				});

				return true;

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
							spawnBeatMonster();

							FlxTween.tween(player, {x: player.x - 128}, .4, {
								ease: FlxEase.sineOut,
								startDelay: .2
							});

							FlxTween.tween(player, {y: player.y + player.height * 0.5}, .4, {
								ease: FlxEase.sineOut,
								startDelay: .2,
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
			case 'train wreak':
				player.animation.play('idle');

				new FlxTimer().start(1 / FlxG.updateFramerate, t ->
				{
					player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);
				}, FlxG.updateFramerate);

				FlxTween.tween(camGame, {zoom: 1.1}, 4, {ease: FlxEase.quintOut});

				FlxG.sound.play(Paths.getAudio('sfx/game/cutscenes/fuse'));

				FlxTimer.wait(1, () ->
				{
					camGame.flash(FlxColor.ORANGE, 10);
					FlxG.sound.play(Paths.getAudio('sfx/game/cutscenes/explosion'));

					forEach(basic ->
					{
						basic.visible = false;
					});
				});

				FlxTimer.wait(2, () ->
				{
					onSongEnd();
				});

				return true;

			case 'shift around':
				player.animation.play('idle');

				new FlxTimer().start(1 / FlxG.updateFramerate, t ->
				{
					player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);
				}, FlxG.updateFramerate);

				FlxTimer.wait(1, () ->
				{
					player.flipX = true;

					player.animation.play('moveR');
					player.animation.onFinish.add(anim ->
					{
						player.animation.play('moveR');
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
