package dialogue;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import haxe.Json;
import lime.utils.Assets;
import flixel.FlxG;
import song.Song;

using StringTools;

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

	var dialogueText:FlxTypeText;
	var currentLine:Int = 0;
	var dialogueFinished:Bool = false;

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

		dialogueText = new FlxTypeText(0, 0, 0, 'Lorem Ipsum Dolor Sit Amet', 32);
		add(dialogueText);

		dialogueText.sounds = [FlxG.sound.load(Paths.getAudio('sfx/game/cutscenes/dialogueText')),];
		dialogueText.finishSounds = true;

		dialogueText.screenCenter();
		dialogueText.y += dialogueText.height * 4;

		dialogueText.completeCallback = function()
		{
			dialogueFinished = true;
		};

		startDialogue();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		dialogueText.screenCenter(X);

		if (FlxG.keys.justPressed.ENTER && dialogueFinished)
		{
			currentLine++;

			if (currentLine > dialogue.lines.length - 1)
				leave();
			else
				startDialogue();
		}
	}

	function startDialogue()
	{
		dialogueFinished = false;

		var line = dialogue?.lines[currentLine];

		dialogueText.resetText(line?.text ?? '');
		dialogueText.start(0.04);

		if (line?.text.trim().length < 1)
			dialogueFinished = true;

		characterLeft.alpha = characterRight.alpha = 0.5;

		if (line?.speaker == 1)
			characterLeft.alpha = 1;
		if (line?.speaker == 2)
			characterRight.alpha = 1;
	}

	function leave()
	{
		FlxG.switchState(() -> new PlayState(song.id, song.variation));
	}
}
