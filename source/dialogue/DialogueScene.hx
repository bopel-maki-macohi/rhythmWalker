package dialogue;

import flixel.text.FlxText;
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

	var dialogueText:FlxText;

	override function create()
	{
		super.create();

		if (dialogue?.characters?.left != null)
		{
			characterLeft = new DialogueCharacter(dialogue.characters.left);
			add(characterLeft);

			characterLeft.screenCenter(Y);
			characterLeft.x = characterLeft.width;
		}

		if (dialogue?.characters?.right != null)
		{
			characterRight = new DialogueCharacter(dialogue.characters.right);
			add(characterRight);

			characterRight.screenCenter(Y);
			characterRight.x = FlxG.width - (characterRight.width * 2);
		}

		dialogueText = new FlxText(0, 0, 0, 'Lorem Ipsum Dolor Sit Amet', 32);
		add(dialogueText);

		dialogueText.screenCenter();
		dialogueText.y += dialogueText.height * 4;
	}

	function leave()
	{
		FlxG.switchState(() -> new PlayState(song.id, song.variation));
	}
}
