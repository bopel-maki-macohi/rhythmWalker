package freeplay;

import song.Song;
import dialogue.DialogueScene;
import song.SongRank;
import haxe.Json;
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
	public static var songs:Array<SongFreeplayData> = [];

	public static var tips:Array<String> = ['No tips'];

	var randomTip:String = '';

	var entries:Array<SongFreeplayData> = [];

	var texts:FlxTypedSpriteGroup<FlxText>;

	var selecteVolume = '';
	var selectedEntry = 0;

	var camFollow:FlxObject;

	var topSegBG:FlxSprite;
	var topSegText:FlxText;

	override function create()
	{
		super.create();

		randomTip = tips[FlxG.random.int(0, tips.length - 1)].replace('\\n', '\n');

		texts = new FlxTypedSpriteGroup<FlxText>();
		add(texts);

		filter(all);

		camFollow = new FlxObject();
		add(camFollow);

		camFollow.x = (FlxG.width / 2);

		FlxG.camera.follow(camFollow, LOCKON, .1);

		topSegText = new FlxText(0, 0, 0, 'Score & Rank go here', 16);
		topSegText.alignment = CENTER;
		topSegText.scrollFactor.set();

		topSegBG = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
		topSegBG.scrollFactor.set();

		add(topSegBG);
		add(topSegText);

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
			FlxG.sound.play(Paths.getAudio('sfx/menu/confirm'));

			var song:SongFreeplayData = songs[selectedEntry];

			DialogueScene.seenIntroCutscene = false;
			FlxG.switchState(() -> new DialogueScene(new Song(song.song, song.variation)));
		}
	}

	function changeSel(amount:Int)
	{
		var prevSel = selectedEntry;

		selectedEntry += amount;

		if (selectedEntry < 0)
			selectedEntry = songs.length - 1;
		if (selectedEntry > songs.length - 1)
			selectedEntry = 0;

		if (selectedEntry != prevSel)
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

		for (i => text in texts.members)
		{
			text.color = FlxColor.WHITE;

			if (i == selectedEntry)
			{
				text.color = FlxColor.YELLOW;
				camFollow.y = text.y;
			}
		}

		var songID = '${songs[selectedEntry].song.toLowerCase()}-${(songs[selectedEntry].variation ?? defaultVariation).toString().toLowerCase()}';

		var curSongScore:Int = Save.songScores.get(songID) ?? 0;
		var curSongRank:SongRank = Save.songRanks.get(songID) ?? NONE;
		var curSongRankPercent:Float = 0;
		try
		{
			if (Std.string(Save.songRankPercents.get(songID)) == 'null')
				curSongRankPercent = 0;
			else
				curSongRankPercent = Save.songRankPercents.get(songID) ?? 0;
		}
		catch (e)
		{
			#if hl
			if (e.toString().contains('assert'))
			{
				trace('ITS FUCKING ASSERT AGAIN.');
			}
			else
			#end
			trace(e);
		}

		topSegText.text = 'Score: ${curSongScore} | Rank: ${curSongRank} (${Math.floor(curSongRankPercent * 100)}%)\n' + 'Random Tip: $randomTip';
		topSegText.screenCenter(X);

		topSegBG.scale.set(FlxG.width, topSegText.height);
		topSegBG.updateHitbox();

		topSegBG.setPosition(0, topSegText.y);
	}

	function filter(f:FreeplayFilter)
	{
		entries = [];

		switch (f)
		{
			// case all:
				// entries = songs;

			default:
				entries = songs.filter(s -> return FlxG.random.bool());
		}

		for (text in texts)
		{
			texts.remove(text);
			text.destroy();
		}

		texts.clear();

		for (i => song in entries)
		{
			if (song.variation == null)
				song.variation = defaultVariation;

			var tXt:FlxText = new FlxText(0, i * 64, 0, '${song.song}', 32);

			if (song.variation != defaultVariation)
				tXt.text += ' (${song.variation.toString().substr(0, 1).toUpperCase()}${song.variation.toString().substr(1).toLowerCase()})';

			tXt.screenCenter(X);

			texts.add(tXt);
		}
	}
}
