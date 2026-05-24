package stage;

import flixel.FlxCamera;
import flixel.FlxSprite;

class StageSprite extends FlxSprite
{
	public var sprite:String;

	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super();

		if (sprite != null)
		{
			this.sprite = sprite;
			loadGraphic(Paths.getImagePath('stages/$sprite'), animated, fw, fh);

			setScale(4);
		}
	}

	public function setScale(?x:Float, ?y:Float)
	{
		scale.set(x ?? y ?? 1, y ?? x ?? 1);
		updateHitbox();
	}

	public function addAnim(anim:String, frames:Array<Int>, fps:Int, ?looped:Bool = false)
	{
		animation.add(anim, frames, fps, looped);
	}

	public function dance() {}

	public function setCamera(cam:FlxCamera)
	{
		camera = cam;
	}

	public function setScrollFactor(factor:Float)
	{
		scrollFactor.y = scrollFactor.x = factor;
	}
}
