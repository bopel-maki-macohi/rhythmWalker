package freeplay;

import song.SongVariation;

typedef SongFreeplayData =
{
	var song:String;

	@:optional
	var volume:String;

	@:optional
	var variation:SongVariation;
}
