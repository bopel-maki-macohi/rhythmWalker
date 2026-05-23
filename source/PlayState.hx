package;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends ConductorState
{
	var player:FlxSprite;
	var playerSpeed:Float = 20;

	var beatMonsters:FlxSpriteGroup;

	var scrollSpeed:Float = 1;

	override public function create()
	{
		super.create();

		#if BOPEEBO_ERECT
		FlxG.sound.playMusic('assets/Bopeebo-Erect.ogg');
		bpm = 123;
		scrollSpeed = 2;
		#else
		FlxG.sound.playMusic('assets/Bopeebo.ogg');
		bpm = 100;
		#end

		// player = new FlxSprite().makeGraphic(64, 128, FlxColor.WHITE);
		player = new FlxSprite().loadGraphic('assets/bro.png', true, 64, 64);
		player.animation.add('idle', [0], 24, false);
		player.animation.add('hurt', [1], 1, false);
		player.animation.add('move', [2, 3], 6, false);
		player.animation.play('idle');
		add(player);

		player.screenCenter();
		player.y = FlxG.height - player.height * 1.25;

		beatMonsters = new FlxSpriteGroup();
		add(beatMonsters);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		songTime += elapsed * 1000;
		updateConductor();

		var shiftThing:Float = 1;
		player.maxVelocity.x = 400 * scrollSpeed;

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

		if (FlxG.keys.anyPressed([A, LEFT, D, RIGHT]))
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
			player.animation.play('idle');

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * scrollSpeed);

			if (monster.overlaps(player))
			{
				player.animation.play('hurt');
				player.velocity.x = 0;

				beatMonsters.remove(monster);
				monster.destroy();
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		// trace('beat');

		var beatMonster:FlxSprite = new FlxSprite().makeGraphic(32, 32, FlxColor.RED);

		beatMonster.x = player.getGraphicMidpoint().x;
		beatMonster.y = beatMonster.height * -2;

		beatMonsters.add(beatMonster);
	}
}
