package game.song;

import flixel.util.FlxSignal;
import flixel.sound.FlxSound;
import util.JsonUtil;
import util.WindowUtil;
import util.PathUtil;

class Song
{
	public var id(default, null):String;

	public var data(default, null):SongData;

	public var audio(default, null):FlxSound;

	public function new(id:String)
	{
		this.id = id.toLowerCase();

		loadSong();
		loadData();
	}

	function loadData()
	{
		data = null;

		var path:String = PathUtil.json('game/songs/$id/$id');

		if (!PathUtil.exists(path))
		{
			WindowUtil.alert('MISSING SONG METADATA PATH: $path');
			return;
		}

		final raw = JsonUtil.parseFile(path);
		if (raw == null)
			return;

		data = raw;
	}

	function loadSong()
	{
		audio = null;

		var path:String = PathUtil.getSong(id);

		if (!PathUtil.exists(path))
		{
			WindowUtil.alert('MISSING SONG AUDIO PATH: $path');
			return;
		}

		audio = new FlxSound().loadEmbedded(path);
		audio.onComplete = () ->
		{
			onSongEnd.dispatch();
		}

		audio.stop();
		audio.time = 0;
	}

	public var onSongEnd:FlxSignal = new FlxSignal();
}
