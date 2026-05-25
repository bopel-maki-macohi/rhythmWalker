package freeplay;

enum abstract FreeplayFilter(String) from String to String
{
	public static var list:Array<FreeplayFilter> = [all, volume1, volume2, volume3,];

	var all = 'all';

	var volume1 = 'volume1';
	var volume2 = 'volume2';
	var volume3 = 'volume3';

	public inline function newVolume(volume:Int)
		this = 'volume$volume';
}
