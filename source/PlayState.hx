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

		player = new FlxSprite().makeGraphic(64, 128, FlxColor.WHITE);
		add(player);

		player.screenCenter();

		beatMonsters = new FlxSpriteGroup();
		add(beatMonsters);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		songTime += elapsed * 1000;
		updateConductor();

		var shiftThing:Float = 1;
		player.maxVelocity.x = 400;

		// if (FlxG.keys.pressed.SHIFT)
		// {
		// 	shiftThing *= 2;
		// 	player.maxVelocity.x = 600;
		// }

		if (FlxG.keys.anyPressed([A, LEFT]))
			player.velocity.x -= playerSpeed * shiftThing;
		else if (FlxG.keys.anyPressed([D, RIGHT]))
			player.velocity.x += playerSpeed * shiftThing;
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

		for (monster in beatMonsters)
		{
			monster.y += monster.height * (.2 * scrollSpeed);
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
