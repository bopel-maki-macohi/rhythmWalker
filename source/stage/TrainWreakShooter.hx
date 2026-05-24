package stage;

import flixel.FlxCamera;

class TrainWreakShooter extends TrainWreakPiece
{
	override public function new(cam:FlxCamera)
	{
		super('shooter', cam, 1);

		addAnim('idle', [0, 1], 2);
		addAnim('shoot', [2, 3, 3, 3, 3], 12);

		setScale(1);
		dance();
	}

	override function dance()
	{
		super.dance();

		animation.play('idle');
	}
}
