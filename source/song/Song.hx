package song;

import flixel.addons.sound.MusicTimeChangeEvent.MusicTimeChangeData;
import flixel.FlxG;
import song.SongData;
import song.SongVariation;
import openfl.net.FileReference;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

class Song
{
	public var id(default, null):String;
	public var variation(default, null):SongVariation;

	var data:SongData;

	public function new(nid:String, nvariation:SongVariation = defaultVariation, ?loadFile:Bool = true)
	{
		this.id = nid.toLowerCase();
		this.variation = new SongVariation(nvariation?.toString()?.toLowerCase() ?? defaultVariation);

		if (variation.toString()?.trim()?.length < 1 || variation == null)
			variation = defaultVariation;

		if (loadFile)
			this.loadFile();
	}

	public var bpmChanges(default, null):Array<MusicTimeChangeData> = [
		{
			t: 0,
			bpm: 0,
		}
	];
	public var events(default, null):Array<SongEventData> = [];
	public var scrollSpeed(default, null):Float = 1;

	public function loadFile()
	{
		var path:String = Paths.json('game/songs/$id/$variation');

		try
		{
			var json:SongData = Json.parse(Assets.getText(path));
			loadData(json);

			if (data == null)
				throw 'Null JSON Data';
		}
		catch (e)
		{
			FlxG.stage.window.alert('Song File Loading Error: ${e.message}');
		}
	}

	public function loadData(json:SongData)
	{
		if (json == null)
			return;

		if (json.id != null)
			json.id = json.id.toLowerCase();
		if (json.variation != null)
			json.variation = new SongVariation(json.variation);

		data = json;

		if (data.id != null)
			this.id = data.id.toLowerCase();

		if (data.variation != null)
			this.variation = data.variation;

		if (data.bpmChanges != null)
			this.bpmChanges = data.bpmChanges;

		if (data.events != null)
			this.events = data.events;

		if (data.scrollSpeed != null)
			this.scrollSpeed = data.scrollSpeed;
	}

	public function save()
	{
		var fileref:FileReference = new FileReference();
		fileref.save(Json.stringify(data, '\t'), '$variation.json');
	}

	public function toString():String
	{
		return 'Song($id-$variation)';
	}
}
