import flixel.addons.sound.MusicTimeChangeEvent.MusicTimeChangeData;
import flixel.FlxG;
import song.SongData;
import song.Variation;
import openfl.net.FileReference;
import haxe.Json;
import lime.utils.Assets;

class Song
{
	public var id(default, null):String;
	public var variation(default, null):Variation;

	public function new(nid:String, nvariation:Variation = defaultVariation, ?loadFile:Bool = true)
	{
		this.id = nid.toLowerCase();
		this.variation = nvariation.clone();

		if (loadFile)
			this.loadFile();
	}

	public var bpmChanges:Array<MusicTimeChangeData> = [];
	public var scrollSpeed:Float = 1;

	public function loadFile()
	{
		var path:String = Paths.json('songs/$id/$variation');

		if (!Assets.exists(path))
			return;

		try
		{
			var json:SongData = Json.parse(Assets.getText(path));

			loadData(json);
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
			this.id = json.id.toLowerCase();

		if (json.variation != null)
			this.variation = new Variation(json.variation);

		if (json.bpmChanges != null)
			this.bpmChanges = json.bpmChanges;

		if (json.scrollSpeed != null)
			this.scrollSpeed = json.scrollSpeed;
	}

	public function save()
	{
		var json:SongData = {
			id: id,
			variation: variation,
			scrollSpeed: scrollSpeed,
			bpmChanges: bpmChanges
		};

		var fileref:FileReference = new FileReference();
		fileref.save(Json.stringify(json, '\t'), '$variation.json');
	}
}
