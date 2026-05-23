import haxe.Json;
import lime.utils.Assets;

class Song
{
	public var id(default, null):String;
	public var variation(default, null):String;

	public function new(nid:String, nvariation:String = 'default')
	{
		this.id = nid.toLowerCase();
		this.variation = nvariation.toLowerCase();

		load();
	}

	public var bpm:Float = 0;

	public function load()
	{
		var path:String = Paths.json('songs/$id/chart-$variation');

		if (!Assets.exists(path))
			return;

		var json:Dynamic = Json.parse(Assets.getText(path));

		if (json.bpm != null && (Std.isOfType(json.bpm, Float) || Std.isOfType(json.bpm, Int)))
			this.bpm = json.bpm;
	}
}
