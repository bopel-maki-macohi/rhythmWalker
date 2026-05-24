package stage;

import flixel.FlxSprite;

class StageSprite extends FlxSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super();

		loadGraphic(Paths.getImagePath('stages/$sprite'), animated, fw, fh);

		setScale(4);
	}

	public function setScale(?x:Float, ?y:Float)
	{
		scale.set(x ?? y ?? 1, y ?? x ?? 1);
		updateHitbox();
	}
}
