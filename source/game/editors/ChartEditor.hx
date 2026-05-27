package game.editors;

import flixel.addons.sound.FlxRhythmConductorUtil;
import util.SongUtil;
import game.song.Song;
import flixel.FlxG;
import flixel.addons.display.FlxTiledSprite;
import util.PathUtil;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import util.rhythm.ConductorState;

class ChartEditor extends ConductorState
{
	public static final GRID_SIZE:Int = 64;
	public static final gridBitmap:Null<BitmapData> = BitmapData.fromFile(PathUtil.png('ui/grid'));

	var gridTiled:FlxTiledSprite;

	var songLengthInPixels(get, never):Int;

	function get_songLengthInPixels():Int
		return Std.int(conductor.musicLength * GRID_SIZE);

	var song:Song;

	override public function new(?song:Song)
	{
		super();

		this.song = SongUtil.getSongField(song);
	}

	override function create()
	{
		this.song.onSongEnd.add(onSongEnd);

		initGrid();

		resetConductor();

		conductor.target = song.audio;
		FlxRhythmConductorUtil.loadMeta(conductor, FlxRhythmConductorUtil.parseTimeChanges(song.data.bpmChanges));

		super.create();
	}

	function initGrid()
	{
		gridTiled = new FlxTiledSprite(gridBitmap, GRID_SIZE * 4, GRID_SIZE, true, true);
		gridTiled.screenCenter(X);
		add(gridTiled);

		resizeGrid();
	}

	function resizeGrid()
	{
		gridTiled.height = songLengthInPixels;
	}

	function onSongEnd()
	{
		song.audio.time = song.audio.length;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		conductor.update(null);
		conductor.update(song.audio?.time);

		updateGrid();

		controlManagement();
	}

	function updateGrid()
	{
		if (gridTiled == null)
			return;

		gridTiled.y = (FlxG.height / 2) - conductor.frameMusicPosition;
	}

	function controlManagement()
	{
		if (FlxG.keys.justPressed.SPACE && song.audio != null)
		{
			if (song.audio.playing)
				song.audio.pause();
			else
				song.audio.play(song.audio.time == song.audio.length);
		}
	}
}
