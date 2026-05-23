package song;

enum abstract Variation(String) from String to String
{
	var defaultVariation:Variation = new Variation('default');

	inline function new(variation:String)
		this = variation;

	public function clone()
		return new Variation(this);
}
