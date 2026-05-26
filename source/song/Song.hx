package song;

class Song
{
	public var id(default, null):String;

	public function new(id:String)
	{
		this.id = id.toLowerCase();
	}
}
