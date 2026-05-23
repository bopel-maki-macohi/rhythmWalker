package stage;

import flixel.FlxSprite;

class StageSprite extends FlxSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super();

		loadGraphic(Paths.getImagePath('stages/$sprite'), animated, fw, fh);

		scale.set(4, 4);
		updateHitbox();
	}
}
