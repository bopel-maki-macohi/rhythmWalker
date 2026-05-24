package stage;

import flixel.FlxCamera;

class TrainWreakPiece extends StageSprite
{
	override public function new(piece:String, cam:FlxCamera, scrollfactor:Float)
	{
		super('train-wreak/$piece', piece == 'smoke' || piece == 'shooter', ((piece == 'smoke') ? 640 : 128), ((piece == 'smoke') ? 360 : 192));

		if (piece == 'smoke')
		{
			addAnim('idle', [0, 1, 2], 2, true);
			animation.play('idle');
		}

		setScale(2);
		screenCenter();

		setCamera(cam);
		setScrollFactor(scrollfactor);
	}
}
