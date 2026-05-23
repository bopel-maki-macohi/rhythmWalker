import flixel.FlxSprite;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import song.SongFreeplayData;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;

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
		{
			song: 'Scroll Down Chinatown',
			variation: defaultVariation,
		},
	];

	var texts:FlxTypedSpriteGroup<FlxText>;

	var selected = 0;

	var camFollow:FlxObject;

	var tips:Array<String> = [
		for (line in Assets.getText(Paths.getPath('tips.txt')).split('\n'))
			if (line.trim().length > 0) line.trim()
	];

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

		var tipText:FlxText = new FlxText(0, 0, 0, 'Random Tip:\n' + tips[FlxG.random.int(0, tips.length - 1)].replace('\\n', '\n'), 16);
		tipText.alignment = CENTER;
		tipText.screenCenter(X);
		tipText.scrollFactor.set();

		var tipTextBG = new FlxSprite(0, 0).makeGraphic(Math.floor(tipText.width), Math.floor(tipText.height), FlxColor.BLACK);
		tipTextBG.scrollFactor.set();

		add(tipTextBG);
		add(tipText);

		changeSel(0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([W, UP]))
			changeSel(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]))
			changeSel(1);

		if (FlxG.keys.justPressed.ENTER)
		{
			var song:SongFreeplayData = songs[selected];
			FlxG.switchState(() -> new PlayState(song.song, song.variation));
		}
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
