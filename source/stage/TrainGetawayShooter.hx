package stage;

class TrainGetawayShooter extends StageSprite
{
	override public function new()
	{
		super('train-getaway/shooter', true, 128, 256);

		addAnim('idle', [0, 1, 2, 3], 8);
		addAnim('shoot', [4, 5, 6, 7], 8);
		addAnim('jammed', [8, 9, 10, 11], 8);
		addAnim('reload', [12, 13, 14, 14, 14, 14], 8);

		animation.onFinish.add(anim ->
		{
			// dance();
		});

		setScale(1);

		dance();
	}

	override function dance()
	{
		super.dance();

		if (animation.name != 'idle' && !animation.finished)
			return;

		animation.play('idle');
	}
}
