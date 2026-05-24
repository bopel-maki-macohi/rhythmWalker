package dialogue;

import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import song.Song;

class DialogueScene extends ConductorState
{
	public static var seenIntroCutscene:Bool = false;

	var song:Song;
	var dialogue:DialogueData;

	override public function new(song:Song)
	{
		super();

		this.song = song;

		seenIntroCutscene = true;

		var path = Paths.json('dialogue/dialogue/${song.id}-${song.variation ?? defaultVariation}');

		if (!Assets.exists(path))
			leave();

		try
		{
			dialogue = Json.parse(Assets.getText(path));
		}
		catch (e)
		{
			trace(e);
			leave();
		}
	}

	var characterLeft:DialogueCharacter;
	var characterRight:DialogueCharacter;

	override function create()
	{
		super.create();

		if (dialogue?.characters?.left != null)
		{
			characterLeft = new DialogueCharacter(dialogue.characters.left);
			add(characterLeft);
			characterLeft.screenCenter();
			
			characterLeft.y = characterLeft.x = 32;
		}

		if (dialogue?.characters?.right != null)
		{
			characterRight = new DialogueCharacter(dialogue.characters.right);
			add(characterRight);
			characterRight.screenCenter();
			
			characterRight.y = 32;
			characterRight.x = FlxG.width - characterRight.width - characterRight.y;
		}
	}

	function leave()
	{
		FlxG.switchState(() -> new PlayState(song.id, song.variation));
	}
}
