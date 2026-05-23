package;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var player:FlxSprite;
	var playerSpeed:Float = 20;

	override public function create()
	{
		super.create();

		FlxG.sound.playMusic('assets/Bopeebo.ogg');

		player = new FlxSprite().makeGraphic(32, 32, FlxColor.WHITE);
		add(player);

		player.maxVelocity.x = 100;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyPressed([A, LEFT]))
			player.velocity.x -= playerSpeed;
		else if (FlxG.keys.anyPressed([D, RIGHT]))
			player.velocity.x += playerSpeed;

		player.velocity.x = FlxMath.lerp(player.velocity.x, 0, 0.1);
	}
}
