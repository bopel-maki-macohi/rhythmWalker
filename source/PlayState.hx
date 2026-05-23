package;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends ConductorState
{
	var player:FlxSprite;
	var playerSpeed:Float = 20;

	override public function create()
	{
		super.create();

		FlxG.sound.playMusic('assets/Bopeebo.ogg');
		bpm = 100;

		player = new FlxSprite().makeGraphic(64, 128, FlxColor.WHITE);
		add(player);

		player.screenCenter();

		player.maxVelocity.x = 400;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		songTime += elapsed * 1000;
		updateConductor();

		if (FlxG.keys.anyPressed([A, LEFT]))
			player.velocity.x -= playerSpeed;
		else if (FlxG.keys.anyPressed([D, RIGHT]))
			player.velocity.x += playerSpeed;
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
	}

	override function beatHit()
	{
		super.beatHit();

		trace('beat');
	}
}
