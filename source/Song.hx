import song.Variation;
import openfl.net.FileReference;
import haxe.Json;
import lime.utils.Assets;

class Song
{
	public var id(default, null):String;
	public var variation(default, null):Variation;

	public function new(nid:String, nvariation:Variation = defaultVariation)
	{
		this.id = nid.toLowerCase();
		this.variation = nvariation.clone();

		load();
	}

	public var bpm:Float = 0;
	public var scrollSpeed:Float = 1;

	public function load()
	{
		var path:String = Paths.json('songs/$id/$variation');

		if (!Assets.exists(path))
			return;

		var json:Dynamic = Json.parse(Assets.getText(path));

		if (json.bpm != null && (Std.isOfType(json.bpm, Float) || Std.isOfType(json.bpm, Int)))
			this.bpm = json.bpm;

		if (json.scrollSpeed != null && (Std.isOfType(json.scrollSpeed, Float) || Std.isOfType(json.scrollSpeed, Int)))
			this.scrollSpeed = json.scrollSpeed;
	}

	public function save()
	{
		var json:Dynamic = {
			bpm: this.bpm,
			scrollSpeed: this.scrollSpeed,
		};

		var fileref:FileReference = new FileReference();
		fileref.save(Json.stringify(json, '\t'), '$variation');
	}
}
