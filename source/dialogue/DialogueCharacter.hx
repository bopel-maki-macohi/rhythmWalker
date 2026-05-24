package dialogue;

import util.RWSprite;

class DialogueCharacter extends RWSprite
{
	override public function new(portrait:String)
	{
		super('dialogue/portraits/$portrait');

        setGraphicSize(256, 256);
        updateHitbox();
	}
}
