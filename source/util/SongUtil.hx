package util;

import game.song.Song;

class SongUtil
{
	public static inline function getSongField(?song:Song):Song
	{
		return song ?? new Song('Dummy');
	}
}
