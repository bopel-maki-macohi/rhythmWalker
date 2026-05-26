package util.graphics;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;

class RWSprite extends FlxSprite
{
	public var sprite:String;

	public function loadSprite(sprite:String, ?animated:Bool = false, ?frameWidth:Int, ?frameHeight:Int):RWSprite
	{
		this.sprite = sprite;

		if (this.sprite != null)
			loadGraphic(Paths.getImagePath(sprite), animated, frameWidth, frameHeight);
		else
			FlxG.log.warn('Null sprite, cannot load.');

		return this;
	}

	public function setScale(?x:Float, ?y:Float):RWSprite
	{
		scale.set(x ?? y ?? 1, y ?? x ?? 1);
		updateHitbox();

		return this;
	}

	public function addAnim(anim:String, frames:Array<Int>, fps:Int, ?looped:Bool = false):RWSprite
	{
		animation.add(anim, frames, fps, looped);

		return this;
	}

	public function playAnim(anim:String, ?force:Bool):RWSprite
	{
		if (animation.getNameList().contains(anim))
			animation.play(anim, force);

		return this;
	}

	public function setCamera(cam:FlxCamera):RWSprite
	{
		camera = cam;

		return this;
	}

	public function setScrollFactor(factor:Float):RWSprite
	{
		scrollFactor.set(factor, factor);

		return this;
	}

	public function dance() {}
}
