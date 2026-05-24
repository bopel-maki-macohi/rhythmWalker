package dialogue;

import flixel.math.FlxMath;
import flixel.util.FlxTimer;
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
		trace(path);

		if (!Assets.exists(path))
			leave();

		try
		{
			dialogue = Json.parse(Assets.getText(path));
		}
		catch (e)
		{
			trace(e);
			dialogue = null;
		}
	}

	var characterLeft:DialogueCharacter;
	var characterRight:DialogueCharacter;

	var dialogueText:FlxTypeText;
	var currentLine:Int = 0;
	var dialogueFinished:Bool = false;

	var proceedText:FlxText;

	override function create()
	{
		super.create();

		if (dialogue == null)
		{
			leave();
			return;
		}

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

		proceedInTimer = new FlxTimer();

		proceedText = new FlxText(0, 0, 0, 'ENTER to proceed', 16);
		add(proceedText);
		proceedText.alpha = 0;
		proceedText.screenCenter();
		proceedText.y = FlxG.height - proceedText.height;

		startDialogue();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (dialogue == null)
			return;

		dialogueText.screenCenter(X);

		proceedText.alpha = FlxMath.lerp(proceedText.alpha, ((dialogueFinished) ? 1 : 0), .1);

		if (FlxG.keys.justPressed.ESCAPE)
			leave();
		
		if (FlxG.keys.justPressed.ENTER && dialogueFinished)
			proceed();
	}

	function proceed()
	{
		currentLine++;

		if (currentLine > dialogue.lines.length - 1)
			leave();
		else
			startDialogue();
	}

	function startDialogue()
	{
		var line = dialogue?.lines[currentLine];

		proceedInTimer.cancel();

		for (event in line?.events ?? [])
			parseEvent(event);

		dialogueFinished = false;

		dialogueText.resetText(line?.text ?? '');
		dialogueText.start(0.04);

		if (line?.text?.trim()?.length < 1 && !proceedInTimer.active)
			dialogueFinished = true;

		if (characterLeft != null)
			characterLeft.alpha = 0.5;
		if (characterRight != null)
			characterRight.alpha = 0.5;

		if (line?.speaker == 1 && characterLeft != null)
			characterLeft.alpha = 1;
		if (line?.speaker == 2 && characterRight != null)
			characterRight.alpha = 1;
	}

	var proceedInTimer:FlxTimer;

	function parseEvent(event:DialogueEventData)
	{
		switch (event.id.toLowerCase())
		{
			case 'playsound':
				if (event.data != null)
					FlxG.sound.play(Paths.getAudio('sfx/game/cutscenes/${event.data}'));
			case 'characterswitch':
				if (event.data != null)
				{
					if (event.data.left != null)
						characterLeft.switchPortrait(event.data.left);

					if (event.data.right != null)
						characterRight.switchPortrait(event.data.right);
				}
			case 'proceedin':
				if (event.data != null)
					proceedInTimer.start(Std.parseFloat(Std.string(event.data)), t ->
					{
						proceed();
					});
		}
	}

	function leave()
	{
		FlxG.switchState(() -> new PlayState(song.id, song.variation));
	}
}
