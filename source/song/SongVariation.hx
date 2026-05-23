package song;

enum abstract SongVariation(String) from String to String
{
	var defaultVariation:SongVariation = new SongVariation('default');

	public inline function new(variation:String)
		this = variation;

	public inline function clone()
		return new SongVariation(this);
}
