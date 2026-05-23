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
	}
}
