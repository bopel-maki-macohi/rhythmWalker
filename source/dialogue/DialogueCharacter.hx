package dialogue;

import util.RWSprite;

class DialogueCharacter extends RWSprite
{
	override public function new(portrait:String)
	{
		super(null);
		switchPortrait(portrait);

		setGraphicSize(256, 256);
		updateHitbox();
	}

	public function switchPortrait(portrait:String)
	{
		loadGraphic(Paths.getImagePath('dialogue/portraits/$portrait'));
	}
}
