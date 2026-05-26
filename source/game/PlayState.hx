package game;

import util.rhythm.ConductorState;
import game.song.Song;

class PlayState extends ConductorState
{
	var song:Song;

	override public function new(song:Song)
	{
		super();

		this.song = song;
	}
}
