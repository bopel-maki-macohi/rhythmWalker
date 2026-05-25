package freeplay;

import util.Flag;
import flixel.util.FlxSort;
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
	public static var songList:FreeplaySongListData;

	public static var songs(get, never):Array<FreeplaySongData>;

	static function get_songs():Array<FreeplaySongData>
		return songList.songs;

	public static var tips:Array<String> = ['No tips'];

	public static var filterList(get, never):Array<String>;

	static function get_filterList():Array<String>
	{
		var list:Array<String> = [];

		var filterCounts:Map<String, Int> = [];

		for (filter in songList?.filters)
		{
			if (!list.contains(filter.toLowerCase()))
			{
				list.push(filter.toLowerCase());
				filterCounts.set(filter.toLowerCase(), 1);
			}
			else
			{
				filterCounts.set(filter.toLowerCase(), filterCounts.get(filter.toLowerCase()) + 1);
			}
		}

		list.insert(0, 'all');

		return list;
	}

	public static var audioCache:Map<String, Sound> = [];
	public static var audioVizCache:Map<String, FlxWaveform> = [];

	public static var curWaveforms:Array<FlxWaveform> = [];
	public static var curWaveformsID:Array<String> = [];

	public static function runOnWaveforms(func:FlxWaveform->String->Void)
	{
		if (func != null)
			for (wf in curWaveforms)
				func(wf, curWaveformsID[wf.ID]);
	}

	var randomTip:String = '';

	var entries:Array<FreeplaySongData> = [];

	var texts:FlxTypedSpriteGroup<FlxText>;

	var selectedVolume = 0;
	var selectedEntry = 0;

	var camFollow:FlxObject;

	var topSegBG:FlxSprite;
	var topSegText:FlxText;

	var btmSegBG:FlxSprite;
	var btmSegText:FlxText;

	var bgAudio:FlxSound;
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

		trace('filters: ${filterList}');

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

		runOnWaveforms((wave, waveID) ->
		{
			wave.visible = true;
			wave.alpha = 0;
			add(wave);
		});

		changeVolume(filterList.length);
		changeSel(0);
		filter('all');

		if (Flag.FREEPLAY_BGAUDIO)
			changeBGAudio();
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

			var song:FreeplaySongData = entries[selectedEntry];

			if (bgAudio.playing)
				bgAudio.fadeOut(.25, 0, t ->
				{
					FlxG.sound.onVolumeChange.remove(onVolumeChange);

					bgAudio.stop();
					bgAudio.destroy();
					bgAudio = null;
				});

			DialogueScene.seenIntroCutscene = false;
			FlxG.switchState(() -> new DialogueScene(new Song(song.song, song.variation)));
		}

		if (bgAudio != null)
			if (bgAudio.volume > FlxG.sound.volume)
				bgAudio.volume = FlxG.sound.volume;

		FlxG.watch.addQuick('songCode', songCode);
		runOnWaveforms((wave, waveID) ->
		{
			if (wave == null)
				return;
			if (wave.waveformBuffer == null)
				return;

			FlxG.watch.addQuick('waveform-${wave.ID}', waveID);

			if (waveID != songCode)
			{
				wave.active = false;
				return;
			}

			wave.active = true;
			wave.waveformTime += elapsed * 1000;

			if (bgAudio != null)
				if (wave.waveformTime > bgAudio.length)
					wave.waveformTime = 0;
		});
	}

	override function finishTransIn()
	{
		super.finishTransIn();

		runOnWaveforms((wave, waveID) ->
		{
			remove(wave);
			wave.active = false;
			wave.visible = false;

			if (!Flag.FREEPLAY_VISUALIZER_MULTICACHE)
			{
				curWaveforms.remove(wave);
				curWaveformsID.remove(waveID);
				wave.destroy();
				wave = null;
			}
		});

		if (Flag.FREEPLAY_VISUALIZER_MULTICACHE && Flag.FREEPLAY_VISUALIZER)
		{
			for (id => waveform in audioVizCache)
			{
				audioVizCache.remove(id);
				waveform.destroy();
				waveform = null;
			}

			audioVizCache.clear();
		}
	}

	function onVolumeChange(vol:Float) @:privateAccess
	{
		if (bgAudio.fadeTween?.active)
			bgAudio.fadeTween.cancel();

		bgAudio.volume = FlxG.sound.volume;

		runOnWaveforms((wave, waveID) ->
		{
			wave.waveformGainMultiplier = FlxG.sound.volume;
		});
	}

	function fadeinVisualizer()
	{
		if (bgAudio?.volume < 0.1 || bgAudio == null || bgAudio.length < 1)
			return;

		runOnWaveforms((wave, waveID) ->
		{
			if (waveID == songCode)
			{
				wave.waveformTime = bgAudio.time;

				FlxTween.cancelTweensOf(wave);
				FlxTween.tween(wave, {alpha: 1}, .25, {ease: FlxEase.quartInOut});
			}
		});
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

			runOnWaveforms((wave, waveID) ->
			{
				if (wave != null)
					wave.waveformTime = bgAudio.time;
			});
		}
	}

	function loadSongAudio() @:privateAccess
	{
		bgAudio.stop();

		if (entries[selectedEntry] == null)
			return;

		if (!audioCache.exists(songCode))
		{
			bgAudio.loadEmbedded(Paths.getSong(entries[selectedEntry].song, entries[selectedEntry]?.variation ?? defaultVariation), true);
			audioCache.set(songCode, bgAudio._sound);
		}
		else
			bgAudio.loadEmbedded(audioCache.get(songCode), true);

		if (!Flag.FREEPLAY_VISUALIZER_MULTICACHE)
		{
			runOnWaveforms((wave, waveID) ->
			{
				curWaveforms.remove(wave);
				curWaveformsID.remove(waveID);
				remove(wave);
				wave.destroy();
			});

			makeWaveform(entries[selectedEntry]);
		}

		bgAudio.play();

		fadeinVisualizer();
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

		for (i => text in texts.members)
		{
			var textSongRank:SongRank = Save.songRanks.get('${entries[i].song.toLowerCase()}-${(entries[i].variation ?? defaultVariation).toString().toLowerCase()}') ?? NONE;

			text.color = (textSongRank == NONE) ? FlxColor.RED : FlxColor.WHITE;

			if (i == selectedEntry)
			{
				text.color = (textSongRank == NONE) ? FlxColor.ORANGE : FlxColor.YELLOW;
				camFollow.y = text.y;
			}
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

			if (Flag.FREEPLAY_BGAUDIO)
				changeBGAudio();
		}
	}

	function changeBGAudio()
	{
		if (!bgAudio.playing)
			loadSongAudio();
		else
		{
			runOnWaveforms((wave, waveID) ->
			{
				FlxTween.cancelTweensOf(wave);
				FlxTween.tween(wave, {alpha: 0}, .25, {ease: FlxEase.quartInOut});
			});

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
			selectedVolume = filterList.length - 1;
		if (selectedVolume > filterList.length - 1)
			selectedVolume = 0;

		btmSegText.text = 'Volume: ${filterList[selectedVolume]?.toUpperCase()}';
		btmSegText.screenCenter(X);
		btmSegText.y = FlxG.height - btmSegText.height;

		btmSegBG.scale.set(FlxG.width, btmSegText.height);
		btmSegBG.updateHitbox();

		btmSegBG.setPosition(0, btmSegText.y);

		if (selectedVolume != prevVol || amount == 0)
		{
			FlxG.sound.play(Paths.getAudio('sfx/menu/scroll'));

			filter(filterList[selectedVolume]);

			if (Flag.FREEPLAY_BGAUDIO)
				changeBGAudio();
		}
	}

	function filter(f:String)
	{
		entries = [];

		switch (f.toLowerCase())
		{
			case 'all':
				entries = songs;

			default:
				entries = songs.filter(s -> return s.filters.contains(f.toLowerCase()));
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

			var variationStr = song.variation.toString().toLowerCase();

			if (song.variation != defaultVariation)
				tXt.text += ' (${variationStr.substr(0, 1).toUpperCase()}${variationStr.substr(1)})';

			var curSongRank:SongRank = Save.songRanks.get('${song.song.toLowerCase()}-${variationStr}') ?? NONE;
			if (curSongRank == NONE)
				tXt.text += ' (Unplayed)';

			if (Flag.FREEPLAY_VISUALIZER)
			{
				tXt.alignment = RIGHT;
				tXt.x = FlxG.width - tXt.width;
			}
			else
			{
				tXt.screenCenter(X);
			}

			texts.add(tXt);

			if (curWaveforms[i] == null && Flag.FREEPLAY_VISUALIZER_MULTICACHE)
				makeWaveform(song, i);
		}

		changeSel(entries.length);
	}

	function makeWaveform(song:FreeplaySongData, ?i:Null<Int>) @:privateAccess
	{
		if (!Flag.FREEPLAY_VISUALIZER)
			return;

		if (i == null)
			i = curWaveforms.length;

		var viz:String = '${song.song.toLowerCase()}-${(song.variation ?? defaultVariation).toString().toLowerCase()}';

		if (curWaveformsID.contains(viz))
		{
			runOnWaveforms((wave, waveID) ->
			{
				if (waveID == viz)
				{
					wave.ID = i;
					curWaveformsID.remove(viz);
					curWaveformsID.insert(i, viz);
					add(wave);
				}
			});

			return;
		}

		var audio:FlxSound;
		if (audioCache.exists(viz))
			audio = new FlxSound().loadEmbedded(audioCache.get(viz));
		else
		{
			audio = new FlxSound().loadEmbedded(Paths.getSong(song.song, song.variation), true);

			audioCache.set(viz, audio._sound);
		}

		if (audio == null)
			return;

		var bgAudioViz:FlxWaveform;

		if (audioVizCache.exists(viz) && audioVizCache.get(viz) != null)
		{
			bgAudioViz = audioVizCache.get(viz);
		}
		else
		{
			bgAudioViz = new FlxWaveform(0, 0, Math.floor(FlxG.width / 4), Math.floor(FlxG.height - topSegBG.height - btmSegBG.height), FlxColor.WHITE,
				FlxColor.TRANSPARENT);
			bgAudioViz.scrollFactor.set();
			bgAudioViz.y = topSegBG.height;

			bgAudioViz.loadDataFromFlxSound(audio);

			bgAudioViz.waveformOrientation = VERTICAL;
			bgAudioViz.waveformDuration = 125;
			bgAudioViz.waveformTime = bgAudio.time;

			bgAudioViz.alpha = 0;

			bgAudioViz.waveformBuffer.autoDestroy = false;

			bgAudioViz.onDataLoad.add(function()
			{
				audioVizCache.set(viz, bgAudioViz);
			});
		}

		bgAudioViz.ID = i;
		add(bgAudioViz);

		curWaveforms.push(bgAudioViz);
		curWaveformsID.push(viz);
	}
}
