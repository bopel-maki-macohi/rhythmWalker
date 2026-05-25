package freeplay;

import openfl.media.Sound;
import flixel.addons.display.waveform.FlxWaveformBuffer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.sound.FlxSound;
import song.Song;
import dialogue.DialogueScene;
import song.SongRank;
import haxe.Json;
import flixel.FlxSprite;
import lime.utils.Assets;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;

class Freeplay extends ConductorState
{
	public static var songs:Array<SongFreeplayData> = [];

	public static var tips:Array<String> = ['No tips'];

	public static var volumeList(get, never):Array<String>;

	static function get_volumeList():Array<String>
	{
		var list:Array<String> = ['all'];

		for (song in songs)
			if (song.volume?.trim()?.length > 0 && !list.contains(song.volume.toUpperCase()))
				list.push(song.volume.toUpperCase());

		return list;
	}

	public static var audioCache:Map<String, Sound> = [];
	public static var audioVizCache:Map<String, FlxWaveform> = [];

	var randomTip:String = '';

	var entries:Array<SongFreeplayData> = [];

	var texts:FlxTypedSpriteGroup<FlxText>;

	var selectedVolume = 0;
	var selectedEntry = 0;

	var camFollow:FlxObject;

	var topSegBG:FlxSprite;
	var topSegText:FlxText;

	var btmSegBG:FlxSprite;
	var btmSegText:FlxText;

	var bgAudio:FlxSound;
	var bgAudioViz:FlxWaveform;
	var bgAudioVizFade:FlxTween;

	public var songCode(get, never):String;

	function get_songCode():String
	{
		var sng = entries[selectedEntry];

		if (sng == null)
			return null;

		return '${sng.song.toLowerCase()}-${(sng.variation ?? defaultVariation).toString().toLowerCase()}';
	}

	override function create()
	{
		super.create();

		persistentUpdate = true;

		randomTip = tips[FlxG.random.int(0, tips.length - 1)].replace('\\n', '\n');

		bgAudio = new FlxSound();
		FlxG.sound.onVolumeChange.add(onVolumeChange);
		onVolumeChange(FlxG.sound.volume);

		texts = new FlxTypedSpriteGroup<FlxText>();
		add(texts);

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

		btmSegText = new FlxText(0, 0, 0, '', 32);
		btmSegText.alignment = CENTER;
		btmSegText.scrollFactor.set();

		btmSegBG = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
		btmSegBG.scrollFactor.set();

		add(btmSegBG);
		add(btmSegText);

		changeVolume(volumeList.length);
		changeSel(0);
		filter('all');

		changeAudio();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([W, UP]))
			changeSel(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]))
			changeSel(1);

		if (FlxG.keys.anyJustPressed([A, LEFT]))
			changeVolume(-1);
		if (FlxG.keys.anyJustPressed([D, RIGHT]))
			changeVolume(1);

		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/confirm'));

			var song:SongFreeplayData = entries[selectedEntry];

			if (bgAudio.playing)
				bgAudio.fadeOut(.25, 0, t ->
				{
					FlxG.sound.onVolumeChange.remove(onVolumeChange);

					bgAudio.stop();
					bgAudio.destroy();
					bgAudio = null;
				});

			bgAudioViz.destroy();
			bgAudioViz = null;

			DialogueScene.seenIntroCutscene = false;
			FlxG.switchState(() -> new DialogueScene(new Song(song.song, song.variation)));
		}

		if (bgAudio != null)
			if (bgAudio.volume > FlxG.sound.volume)
				bgAudio.volume = FlxG.sound.volume;

		if (bgAudioViz != null)
		{
			if (bgAudioViz.waveformBuffer != null)
			{
				bgAudioViz.waveformTime += elapsed * 1000;

				if (bgAudio != null)
					if (bgAudioViz.waveformTime > bgAudio.length)
						bgAudioViz.waveformTime = 0;
			}
		}
	}

	function onVolumeChange(vol:Float) @:privateAccess
	{
		if (bgAudio.fadeTween?.active)
			bgAudio.fadeTween.cancel();

		bgAudio.volume = FlxG.sound.volume;
	}

	function reloadVisualizer()
	{
		if (bgAudioViz != null)
			bgAudioViz.destroy();
		remove(bgAudioViz);

		if (bgAudio?.volume < 0.1 || bgAudio == null || bgAudio.length < 1)
			return;

		if (audioVizCache.exists(songCode) && audioVizCache.get(songCode) != null)
		{
			bgAudioViz = audioVizCache.get(songCode);
		}
		else
		{
			bgAudioViz = new FlxWaveform(0, 0, Math.floor(FlxG.width / 4), Math.floor(FlxG.height - topSegBG.height), FlxColor.WHITE, FlxColor.TRANSPARENT);
			bgAudioViz.scrollFactor.set();
			bgAudioViz.y = topSegBG.height;

			bgAudioViz.loadDataFromFlxSound(bgAudio);

			bgAudioViz.waveformOrientation = VERTICAL;
			bgAudioViz.waveformDuration = 125;
			bgAudioViz.waveformTime = 0;

			bgAudioViz.alpha = 0;

			bgAudioViz.waveformBuffer.autoDestroy = false;

			bgAudioViz.onDataLoad.add(function()
			{
				audioVizCache.set(songCode, bgAudioViz);
			});
		}

		add(bgAudioViz);

		if (bgAudioVizFade != null)
			bgAudioVizFade.cancel();

		bgAudioVizFade = FlxTween.tween(bgAudioViz, {alpha: 1}, .25, {ease: FlxEase.quartInOut});
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		if (bgAudio != null)
			bgAudio.pause();
	}

	override function onFocus()
	{
		super.onFocus();

		if (bgAudio != null)
		{
			bgAudio.resume();
			// trace(bgAudio.time);

			if (bgAudioViz != null)
				bgAudioViz.waveformTime = bgAudio.time;
		}
	}

	function loadSongAudio() @:privateAccess
	{
		bgAudio.stop();

		if (entries[selectedEntry] == null)
			return;

		if (!audioCache.exists(songCode))
			bgAudio.loadEmbedded(Paths.getSong(entries[selectedEntry].song, entries[selectedEntry]?.variation ?? defaultVariation), true);
		else
		{
			bgAudio.loadEmbedded(audioCache.get(entries[selectedEntry].song), true);
			audioCache.set(songCode, bgAudio._sound);
		}

		bgAudio.play();

		reloadVisualizer();

		bgAudio.fadeIn(.25, bgAudio.volume, FlxG.sound.volume);
	}

	function changeSel(amount:Int)
	{
		var prevSel = selectedEntry;

		selectedEntry += amount;

		if (selectedEntry < 0)
			selectedEntry = entries.length - 1;
		if (selectedEntry > entries.length - 1)
			selectedEntry = 0;

		for (i => text in texts.members)
		{
			text.color = FlxColor.WHITE;

			if (i == selectedEntry)
			{
				text.color = FlxColor.YELLOW;
				camFollow.y = text.y;
			}
		}

		var curSongScore:Int = Save.songScores.get(songCode) ?? 0;
		var curSongRank:SongRank = Save.songRanks.get(songCode) ?? NONE;
		var curSongRankPercent:Float = 0;
		try
		{
			if (Std.string(Save.songRankPercents.get(songCode)) == 'null')
				curSongRankPercent = 0;
			else
				curSongRankPercent = Save.songRankPercents.get(songCode) ?? 0;
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

		topSegText.text = 'Score: ${curSongScore} | Rank: ${curSongRank} (${Math.floor(curSongRankPercent * 100)}%)\n\n' + 'Random Tip:\n$randomTip';
		topSegText.updateHitbox();
		topSegText.screenCenter(X);

		topSegBG.scale.set(FlxG.width, topSegText.height);
		topSegBG.updateHitbox();

		topSegBG.setPosition(0, topSegText.y);

		if (selectedEntry != prevSel || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

			changeAudio();
		}
	}

	function changeAudio()
	{
		if (!bgAudio.playing)
			loadSongAudio();
		else
		{
			if (bgAudioVizFade != null)
				bgAudioVizFade.cancel();

			bgAudioVizFade = FlxTween.tween(bgAudioViz, {alpha: 0}, .25, {ease: FlxEase.quartInOut});

			bgAudio.fadeOut(.25, 0, t ->
			{
				loadSongAudio();
			});
		}
	}

	function changeVolume(amount:Int)
	{
		var prevVol = selectedVolume;

		selectedVolume += amount;

		if (selectedVolume < 0)
			selectedVolume = volumeList.length - 1;
		if (selectedVolume > volumeList.length - 1)
			selectedVolume = 0;

		btmSegText.text = 'Volume: ${volumeList[selectedVolume]?.toUpperCase()}';
		btmSegText.screenCenter(X);
		btmSegText.y = FlxG.height - btmSegText.height;

		btmSegBG.scale.set(FlxG.width, btmSegText.height);
		btmSegBG.updateHitbox();

		btmSegBG.setPosition(0, btmSegText.y);

		if (selectedVolume != prevVol || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

			filter(volumeList[selectedVolume]);
			changeAudio();
		}
	}

	function filter(f:String)
	{
		entries = [];

		switch (f)
		{
			case 'all':
				entries = songs;

			default:
				entries = songs.filter(s -> return s.volume.toLowerCase() == f.toLowerCase());
		}

		if (texts.members.length > 0)
		{
			for (text in texts)
			{
				texts.remove(text);
				text.destroy();
			}

			texts.clear();
		}

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

		changeSel(entries.length);
	}
}
