package stage;

import flixel.FlxG;

class TrainGetawayShooter extends StageSprite
{
	override public function new()
	{
		super('train-getaway/shooter', true, 128, 256);

		addAnim('idle', [0, 1, 2, 3], 8);
		addAnim('shoot1', [4, 5, 6, 7], 8);
		addAnim('shoot2', [8, 9, 10, 11], 8);
		addAnim('jammed', [12, 13, 14, 15], 8);
		addAnim('reload', [16, 17, 18, 18, 18, 18], 8);

		setScale(1);

		dance();
	}

	var time:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		time += elapsed;

		y = ((FlxG.height - height) / 2) + (Math.cos(time * 2) * 10);
	}

	override function dance()
	{
		super.dance();

		if (animation.name != 'idle' && !animation.finished)
			return;

		animation.play('idle');
	}
}
