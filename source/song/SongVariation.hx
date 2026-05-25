package song;

enum abstract SongVariation(String) from String to String
{
	var defaultVariation:SongVariation = new SongVariation('default');
	var resolved:SongVariation = new SongVariation('resolved');

	public inline function new(variation:String)
		this = variation;

	public inline function clone()
		return new SongVariation(this.toLowerCase());

	@:to
	public inline function toString():String
		return this;
}
