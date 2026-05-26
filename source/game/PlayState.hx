package game;

import util.rhythm.ConductorState;
import game.song.Song;

class PlayState extends ConductorState
{
	var song:Song;

	override public function new(?song:Song)
	{
		super();

		if (song == null)
		{
			song = new Song('Stress-Pico');
		}

		this.song = song;
	}
}
