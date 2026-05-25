package;

import util.Flag;
import freeplay.Freeplay;
import util.CustomShader;
import flixel.util.FlxGradient;
import util.RWSprite;
import flixel.addons.transition.FlxTransitionableState;
import dialogue.DialogueScene;
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

	var beatMonsterSpawner:FlxSprite;

	var data = {
		player: {
			skin: 'bro-regular',
			maxVelocityBase: 200,
			speed: 20,
		},
		beatMonsters: {
			spawn: true,
			stepRate: 4,
			scale: 1.0
		}
	};

	var stageBackLayer:FlxSpriteGroup;
	var stageFrontLayer:FlxSpriteGroup;

	override public function new(song:String, ?variation:SongVariation = defaultVariation)
	{
		super(null, null);

		this.song = new Song(song, variation ?? defaultVariation);

		FlxG.log.add(song);
	}

	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;

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

		stageBackLayer = new FlxSpriteGroup();
		add(stageBackLayer);
		stageBackLayer.camera = camGame;

		makePlayer();

		beatMonsters = new FlxSpriteGroup();
		add(beatMonsters);
		beatMonsters.camera = camGame;

		beatMonsterSpawner = FlxGradient.createGradientFlxSprite(Math.floor(FlxG.width * 1.1), Math.floor(FlxG.height * 0.2),
			[FlxColor.RED, FlxColor.TRANSPARENT]);
		add(beatMonsterSpawner);
		beatMonsterSpawner.camera = camGame;
		beatMonsterSpawner.alpha = 0;

		stageFrontLayer = new FlxSpriteGroup();
		add(stageFrontLayer);
		stageFrontLayer.camera = camGame;

		scoreText = new FlxText(0, 0, 0, 'BOB', 16);
		add(scoreText);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		scoreText.camera = camHUD;

		generateStage();

		beatMonsterSpawner.shader = beatMonsters.shader;

		for (event in song.events)
			addEvent(event);

		if (FlxG.sound.music.length < 1)
		{
			skipping = true;
			onSongEnd();
		}

		transitionIn();

		if (introCutscene())
			inIntroCutscene = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);

		if (scoreText != null)
		{
			scoreText.text = 'Score: $score | Hits Taken: $hits';
			scoreText.screenCenter(X);
		}

		if (playerCollision != null)
		{
			playerCollision.x = player.getGraphicMidpoint().x - (playerCollision.width / 2);
			playerCollision.y = player.getGraphicMidpoint().y - (playerCollision.height / 2);
		}

		if (!inCutscene)
			managePlayer();
		else
		{
			if (song.id == 'encapture')
				playerVelocityDamping();
		}

		if (beatMonsters != null)
		{
			beatMonsters.y = camGame.viewY;

			for (monster in beatMonsters)
			{
				monster.y += monster.height * (.2 * scrollSpeed);

				if (!immortal && !inCutscene && monster.overlaps(playerCollision) && !playerStunned && camGame.visible && camGame.alpha >= 0.1)
				{
					playerStunned = true;
					if (player.flipX)
						player.animation.play('hurtR');
					else
						player.animation.play('hurtL');
					player.velocity.x = 0;

					beatMonsters.remove(monster);
					monster.destroy();

					FlxG.sound.play(Paths.getAudio('game/hurt'));

					hits++;
				}

				if (monster.y > FlxG.height + monster.height)
				{
					beatMonsters.remove(monster);
					monster.destroy();
				}
			}
		}

		if (beatMonsterSpawner != null)
		{
			beatMonsterSpawner.y = camGame.viewY;

			beatMonsterSpawner.alpha = FlxMath.lerp(beatMonsterSpawner.alpha, (canSpawnMonster) ? 0.2 : 0, .1);
		}
	}

	function managePlayer()
	{
		var shiftThing:Float = 1;
		player.maxVelocity.x = data.player.maxVelocityBase * scrollSpeed;

		if (FlxG.keys.pressed.SHIFT)
			shiftThing *= 2;

		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			player.flipX = false;
			player.velocity.x -= data.player.speed * shiftThing;

			if (!playerStunned)
				player.animation.play('moveL');
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			player.flipX = true;
			player.velocity.x += data.player.speed * shiftThing;

			if (!playerStunned)
				player.animation.play('moveR');
		}
		else
			playerVelocityDamping();

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

	function playerVelocityDamping()
	{
		player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);
	}

	var skipping:Bool = false;

	function onSongEnd()
	{
		if (skipping)
			seenIntroCutscene = seenEndCutscene = true;

		FlxG.sound.music.stop();

		inEndCutscene = true;

		if (endCutscene())
		{
			trace('Playin end cutscene');
			return;
		}

		final songCode = '${song.id}-${song.variation}';

		trace('Yay we done');

		if (!immortal && !skipping)
			if (Save.saveSongScore(songCode, score, totalScore))
			{
				FlxG.switchState(() -> new ResultsState(songCode));
				return;
			}

		FlxG.switchState(() -> new Freeplay());
	}

	public var canSpawnMonster(get, never):Bool;

	function get_canSpawnMonster():Bool
	{
		return !inEndCutscene && data.beatMonsters.spawn;
	}

	override function onStepHit(step:Int, backward:Bool)
	{
		super.onStepHit(step, backward);

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

		stageFrontLayer.forEach(sprite ->
		{
			if (Std.isOfType(sprite, StageSprite))
			{
				var stageSprite = cast(sprite, StageSprite);
				if (stageSprite == null)
					return;

				stageSprite.dance();
			}
		});

		if (trainGetaway_sky != null && FlxG.sound.music.playing)
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

		beatMonster.shader = beatMonsters.shader;

		beatMonsters.add(beatMonster);

		beatMonsterSpawner.alpha += .1;
	}

	function addEvent(event:SongEventData)
	{
		var songEvent = new FlxTimer();
		songEvents.push(songEvent);

		songEvent.start(event.time / 1000, function(t)
		{
			parseEvent(event);
			songEvents.remove(songEvent);
		});
	}

	function parseEvent(event:SongEventData)
	{
		trace(event);

		switch (event.id.toLowerCase())
		{
			case 'player-idle':
				playPlayerIdle();

			case 'encapture-subjectbang':
				if (song.id == 'encapture' && containment04_tubeSubject != null)
				{
					if (!inEndCutscene)
					{
						camGame.followLerp *= 0.1;
						camGameFollow.setPosition(containment04_tubeSubject.getGraphicMidpoint().x, containment04_tubeSubject.getGraphicMidpoint().y);

						FlxTween.tween(camGame, {zoom: 1.5}, (FlxG.sound.music.length - FlxG.sound.music.time) / 1000, {
							ease: FlxEase.quartOut,
						});

						inEndCutscene = true;
					}
					containment04_tubeSubject.animation.play('bang');
				}

			case 'song-end':
				onSongEnd();

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
				camGame.visible = false;

			case 'camera-on', 'cam-on':
				camGame.visible = true;

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

	function generateStage()
	{
		switch ([song.id, song.variation])
		{
			case ['scroll down chinatown', resolved]:
				makeStage('chinatown');

			case ['lost media', defaultVariation]:
				makeStage('crash landing');

			case ['first steps', resolved], ['shift around', resolved]:
				makeStage('stage-withered');

			case ['encapture', defaultVariation]:
				makeStage('containment-04');

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

	var containment04_tubeSubject:StageSprite;

	var trainGetaway_i:Float = 1;

	var trainGetaway_sky:FlxBackdrop;
	var trainGetaway_shooter:TrainGetawayShooter;

	var trainWreak_shooter:TrainWreakShooter;

	function makeStage(?stage:String)
	{
		if (stageBackLayer == null || stageFrontLayer == null)
			return;

		for (sprite in stageBackLayer.members)
		{
			stageBackLayer.members.remove(sprite);
			sprite.destroy();
		}

		stageBackLayer.clear();

		for (sprite in stageFrontLayer.members)
		{
			stageFrontLayer.members.remove(sprite);
			sprite.destroy();
		}

		stageFrontLayer.clear();

		switch (stage.toLowerCase())
		{
			case 'chinatown':
				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/town/sky'));
				sky.scale.set(2, 2);
				sky.updateHitbox();
				sky.camera = camGame;

				sky.velocity.x = 2;
				sky.screenCenter();
				stageBackLayer.add(sky);

				var buildings = new StageSprite('chinatown/town/buildings');
				buildings.setScale(2);
				buildings.screenCenter();
				stageBackLayer.add(buildings);

				var backRedThings = new StageSprite('chinatown/town/backRedThings');
				backRedThings.setScale(2);
				backRedThings.screenCenter();
				stageBackLayer.add(backRedThings);

				var ground = new StageSprite('chinatown/town/ground');
				ground.setScale(2);
				ground.screenCenter();
				stageBackLayer.add(ground);

				var frontRedThings = new StageSprite('chinatown/town/frontRedThings');
				frontRedThings.setScale(2);
				frontRedThings.screenCenter();
				stageBackLayer.add(frontRedThings);

			case 'crash landing':
				if (Flag.PLAY_SHADERS)
				{
					var charShader = new CustomShader('dropshadow');

					charShader.setFloat('hue', -9.0);
					charShader.setFloat('saturation', -15.0);
					charShader.setFloat('brightness', -22.0);
					charShader.setFloat('contrast', 0.0);

					player.shader = charShader;
					beatMonsters.shader = charShader;
				}

				var sky = new FlxSprite().makeGraphic(1, 1, 0x0d0712);
				sky.scale.set(FlxG.width, FlxG.height);
				sky.updateHitbox();
				sky.screenCenter();
				sky.scrollFactor.set(0, 0);
				stageBackLayer.add(sky);

				var ship = new StageSprite('$stage/ship');
				var mountains = new StageSprite('$stage/mountains');
				var hills = new StageSprite('$stage/hills');
				var ground = new StageSprite('$stage/ground');
				var frontHills = new StageSprite('$stage/frontHills');

				ship.setScrollFactor(0.05);
				mountains.setScrollFactor(0.1);
				hills.setScrollFactor(0.25);
				ground.setScrollFactor(0.75);
				frontHills.setScrollFactor(0.9);

				for (spr in [ship, mountains, hills, ground, frontHills])
				{
					spr.setCamera(camGame);
					spr.setScale(2);

					if (spr != frontHills)
						stageBackLayer.add(spr);
				}
				stageFrontLayer.add(frontHills);

				ship.setScale(1);
				ship.alpha = .5;

				ship.x += FlxG.width * 2;
				ship.y += -FlxG.height * 2;

				FlxTween.tween(ship, {x: -FlxG.width * 2, y: FlxG.height * 2}, 6, {
					onComplete: t ->
					{
						stageBackLayer.remove(ship);
						ship.destroy();
					}
				});

				player.scale.set(1.5, 1.5);
				player.updateHitbox();
				player.screenCenter();
				player.y = FlxG.height - player.height * 1.3;

				data.beatMonsters.scale = 0.75;

			case 'stage-withered':
				var backdrop:StageSprite = new StageSprite(stage);
				backdrop.screenCenter();
				stageBackLayer.add(backdrop);
				backdrop.setCamera(camGame);

				if (Flag.PLAY_SHADERS)
				{
					var bgShader = new CustomShader('dropshadow');
					var charShader = new CustomShader('dropshadow');
					var monsterShader = new CustomShader('dropshadow');

					bgShader.setFloat('hue', -24.0);
					bgShader.setFloat('saturation', -24.0);
					bgShader.setFloat('brightness', -36.0);
					bgShader.setFloat('contrast', 0.0);

					charShader.setFloat('hue', -3.0);
					charShader.setFloat('saturation', 7.0);
					charShader.setFloat('brightness', -75.0);
					charShader.setFloat('contrast', 0.0);

					monsterShader.setFloat('hue', -43.0);
					monsterShader.setFloat('saturation', -51.0);
					monsterShader.setFloat('brightness', -73.0);
					monsterShader.setFloat('contrast', 0.0);

					backdrop.shader = bgShader;
					player.shader = charShader;
					beatMonsters.shader = monsterShader;
				}

			case 'containment-04':
				var backdrop:StageSprite = new StageSprite('$stage/backdrop');
				backdrop.setScale(2);
				backdrop.screenCenter();
				stageBackLayer.add(backdrop);
				backdrop.setCamera(camGame);

				var tubes = 2;

				for (i in 0...tubes)
				{
					var tube = new StageSprite('$stage/tube');
					tube.setScale(2);

					tube.y = FlxG.height - tube.height * 1.4 - 4;
					tube.x = ((tube.width * 2.75) * (i)) + 32;

					stageBackLayer.add(tube);

					if (i == tubes - 1)
					{
						containment04_tubeSubject = tube;
						containment04_tubeSubject.loadGraphic(Paths.getImagePath('game/stages/$stage/subject'), true, 128, 128);
						containment04_tubeSubject.addAnim('idle', [0, 1], 2, true);
						containment04_tubeSubject.addAnim('bang', [2, 3], 6, false);
						containment04_tubeSubject.animation.play('idle');
					}
				}

			case 'train-wreak':
				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/sky'));
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

				var solidGround:RWSprite = new RWSprite(null);
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
				trainGetaway_sky = new FlxBackdrop(Paths.getImagePath('game/stages/$stage/sky'));
				trainGetaway_sky.scale.set(2, 2);
				trainGetaway_sky.velocity.x = 256 * -5;
				trainGetaway_sky.screenCenter(X);
				stageBackLayer.add(trainGetaway_sky);
				trainGetaway_sky.camera = camGame;

				var train:StageSprite = new StageSprite('$stage/train');
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

				var sky:FlxBackdrop = new FlxBackdrop(Paths.getImagePath('game/stages/chinatown/bridge/sky'));
				sky.scale.set(4, 4);
				sky.updateHitbox();
				sky.camera = camGame;

				sky.velocity.x = 2;
				sky.screenCenter();
				stageBackLayer.add(sky);

				var bridge:StageSprite = new StageSprite('chinatown/bridge/bridge');
				bridge.screenCenter();
				stageBackLayer.add(bridge);
				bridge.camera = camGame;

			case 'stage', 'understage':
				var backdrop:StageSprite = new StageSprite(stage);
				backdrop.screenCenter();
				stageBackLayer.add(backdrop);
				backdrop.setCamera(camGame);
		}
	}

	function playPlayerIdle()
	{
		player.animation.play('idle' + ((player.flipX) ? 'R' : 'L'));
	}

	function makePlayer()
	{
		data.player.skin = 'bro-regular';

		var dimensionsSprite:Array<Int> = [64, 64];
		var dimensionsHitbox:Array<Int> = [32, 32];

		switch ([song.id, song.variation])
		{
			case ['scroll down chinatown', resolved]:
				data.player.skin = 'bro-chinatown-wanted';

			case ['lost media', defaultVariation]:
				data.player.skin = 'jez-regular';

			case ['encapture', defaultVariation]:
				data.player.skin = 'bro-captured';

			case ['train wreak', defaultVariation]:
				data.player.skin = 'bro-chinatown-torn';

			case ['scroll down chinatown', defaultVariation], ['train getaway', defaultVariation]:
				data.player.skin = 'bro-chinatown';

			default:
		}

		var animFrames:Map<String, Dynamic> = [
			'idleL' => {frames: [0]},
			'idleR' => {frames: [0]},
			'hurtL' => {frames: [1], fps: 2},
			'hurtR' => {frames: [1], fps: 2},
			'moveL' => {frames: [2, 3], fps: 6},
			'moveR' => {frames: [2, 3], fps: 6},
		];

		switch (data.player.skin)
		{
			case 'bro-chinatown-wanted':
				animFrames.get('idleL').frames = animFrames.get('idleR').frames = [0, 1];
				animFrames.get('hurtL').frames = animFrames.get('hurtR').frames = [2, 3];
				animFrames.get('moveL').frames = animFrames.get('moveR').frames = [4, 5];

				animFrames.get('idleL').fps = animFrames.get('idleR').fps = 4;
				animFrames.get('hurtL').fps = animFrames.get('hurtR').fps = 4;

			case 'jez-regular':
				dimensionsSprite = [96, 112];
				data.player.maxVelocityBase = 250;
				data.player.speed = 30;

			case 'bro-captured':
				animFrames.get('idleR').flipX = true;
				animFrames.get('hurtR').flipX = true;
				animFrames.get('moveR').frames = [4, 5];

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
		player = new FlxSprite().loadGraphic(Paths.getImagePath('game/players/${data.player.skin}'), true, dimensionsSprite[0], dimensionsSprite[1]);

		for (thing => data in animFrames)
		{
			trace('Player Anim "$thing" : $data');
			player.animation.add(thing, data.frames, data?.fps ?? 24, false, data.flipX);
		}

		playPlayerIdle();

		player.scale.set(2, 2);
		player.updateHitbox();

		player.animation.onFinish.add(animName ->
		{
			if (!inCutscene)
			{
				playPlayerIdle();
				playerStunned = false;
			}
		});

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;
		player.camera = camGame;

		// just realized this did not get scaled with the player and now im in a situation,
		// cause I already got used to how it was before.
		// shit.

		playerCollision = new FlxSprite().makeGraphic(dimensionsHitbox[0], dimensionsHitbox[1], FlxColor.RED);
		playerCollision.alpha = .25; // idk if i want it on i want it subtle
		playerCollision.visible = false;
		playerCollision.camera = camGame;

		add(player);
		add(playerCollision);
	}

	var inIntroCutscene:Bool = false;
	var inEndCutscene:Bool = false;

	var inCutscene(get, never):Bool;

	function get_inCutscene():Bool
		return inIntroCutscene || inEndCutscene;

	var seenEndCutscene:Bool = false;
	var seenIntroCutscene:Bool = false;

	function introCutscene():Bool
	{
		if (seenIntroCutscene)
			return false;

		seenIntroCutscene = true;

		switch ([song.id, song.variation])
		{
			case ['lost media', defaultVariation]:
				camGameFollow.y -= FlxG.height * 2;
				camGame.focusOn(camGameFollow.getPosition());

				FlxTween.tween(camGameFollow, {y: FlxG.height / 2}, 1.5, {
					ease: FlxEase.backInOut,
				});

				FlxTimer.wait(1.75, () ->
				{
					inIntroCutscene = false;
				});

				return true;

			case ['train wreak', defaultVariation]:
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
								if (sprite == null)
									return;

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

			case ['scroll down chinatown', defaultVariation]:
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
							beatMonsterSpawner.alpha += .5;

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
									playPlayerIdle();
									inEndCutscene = inIntroCutscene = false;
								}
							});
						}
					});
				});

				return true;

			default:
		}
		return false;
	}

	function endCutscene():Bool
	{
		if (seenEndCutscene)
			return false;

		seenEndCutscene = true;

		switch ([song.id, song.variation])
		{
			case ['train wreak', defaultVariation]:
				playPlayerIdle();

				new FlxTimer().start(1 / FlxG.updateFramerate, t ->
				{
					playerVelocityDamping();
				}, FlxG.updateFramerate);

				FlxTween.tween(camGame, {zoom: 1.1}, 4, {ease: FlxEase.quintOut});

				FlxG.sound.play(Paths.getAudio('game/cutscenes/fuse'));

				FlxTimer.wait(1, () ->
				{
					camGame.flash(FlxColor.ORANGE, 10);
					FlxG.sound.play(Paths.getAudio('game/cutscenes/explosion'));

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

			case ['shift around', defaultVariation]:
				playPlayerIdle();

				new FlxTimer().start(1 / FlxG.updateFramerate, t ->
				{
					playerVelocityDamping();
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

			default:
		}

		return false;
	}
}
