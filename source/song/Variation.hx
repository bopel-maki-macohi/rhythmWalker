package song;

enum abstract Variation(String) from String to String
{
	var defaultVariation:Variation = new Variation('default');

	public inline function new(variation:String)
		this = variation;

	public inline function clone()
		return new Variation(this);
}
