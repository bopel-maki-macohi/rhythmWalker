package game.song;

import util.JsonUtil;
import util.WindowUtil;
import util.PathUtil;

class Song
{
	public var id(default, null):String;

	var data(default, null):SongData;

	public function new(id:String)
	{
		this.id = id.toLowerCase();

		loadData();
	}

	function loadData() {
		this.data = null;

		var path:String = PathUtil.json('game/songs/$id/$id');

		if (!PathUtil.exists(path))
		{
			WindowUtil.alert('MISSING SONG METADATA PATH: $path');
			return;
		}

		final raw = JsonUtil.parseFile(path);
		if (raw == null) return;

		this.data = raw;
	}
}
