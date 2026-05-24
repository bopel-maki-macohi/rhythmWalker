package dialogue;

import flixel.FlxG;
import song.Song;

class DialogueScene extends ConductorState
{
	public static var seenIntroCutscene:Bool = false;

	var song:Song;

	override public function new(song:Song)
	{
		super();

		this.song = song;

		seenIntroCutscene = true;

		switch ([song.id, song.variation])
		{
            case ['encapture', defaultVariation]:

			default:
				leave();
		}
	}

	function leave()
	{
		FlxG.switchState(() -> new PlayState(song.id, song.variation));
	}
}
