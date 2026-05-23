import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import song.SongFreeplayData;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Freeplay extends ConductorState
{
	public var songs:Array<SongFreeplayData> = [
		{
			song: 'First Steps',
			variation: defaultVariation,
		},
		{
			song: 'Shift Around',
			variation: defaultVariation,
		},
	];

	var texts:FlxTypedSpriteGroup<FlxText>;

	var selected = 0;

	var camFollow:FlxObject;

	override function create()
	{
		super.create();

		texts = new FlxTypedSpriteGroup<FlxText>();
		add(texts);

		for (i => song in songs)
		{
			var tXt:FlxText = new FlxText(0, i * 64, 0, '${song.song}', 32);

			if (song.variation != defaultVariation)
				tXt.text += ' (${song.variation})';

			tXt.screenCenter(X);

			texts.add(tXt);
		}

		camFollow = new FlxObject();
		add(camFollow);

		camFollow.x = (FlxG.width / 2);

		FlxG.camera.follow(camFollow, LOCKON, .1);

		changeSel(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([W, UP]))
			changeSel(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]))
			changeSel(1);
	}

	function changeSel(amount:Int)
	{
		selected += amount;

		if (selected < 0)
			selected = songs.length - 1;
		if (selected > songs.length - 1)
			selected = 0;

		for (i => text in texts.members)
		{
			text.color = FlxColor.WHITE;

			if (i == selected)
			{
				text.color = FlxColor.YELLOW;
				camFollow.y = text.y;
			}
		}
	}
}
