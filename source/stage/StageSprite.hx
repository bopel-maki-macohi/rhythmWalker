package stage;

import util.RWSprite;

class StageSprite extends RWSprite
{
	override public function new(sprite:String, ?animated:Bool, ?fw:Int, ?fh:Int)
	{
		super((sprite == null) ? null : 'stages/$sprite', animated, fw, fh);
		this.sprite = sprite;
	}
}
