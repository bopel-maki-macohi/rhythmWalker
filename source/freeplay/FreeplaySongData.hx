package freeplay;

import song.SongVariation;

typedef FreeplaySongData =
{
	var song:String;

	@:optional
	var filters:Array<String>;

	@:optional
	var variation:SongVariation;
}
