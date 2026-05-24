package stage;

class TrainWreakPiece extends StageSprite
{
	override public function new(piece:String, scrollfact:Float = 1)
	{
		super('train-wreak/$piece', piece == 'smoke', 640, 360);

		if (piece == 'smoke')
		{
			addAnim('idle', [0, 1, 2], 2, true);
			animation.play('idle');
		}

        this.scrollFactor.set(scrollfact, scrollfact);

		setScale(2);
		screenCenter();
	}
}
