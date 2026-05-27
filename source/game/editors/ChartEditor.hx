package game.editors;

import flixel.math.FlxMath;
import flixel.text.FlxText;
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
	var gridZoom:Float = 1.0;

	var strumline:FlxSprite;

	var textShit:FlxText;

	var songLengthInPixels(get, never):Int;

	function get_songLengthInPixels():Int
		return Std.int(song.audio?.length ?? 1000);

	var song:Song;

	var songPosition:Float = 0;

	override public function new(?song:Song)
	{
		super();

		this.song = SongUtil.getSongField(song);
	}

	override function create()
	{
		this.song.onSongEnd.add(onSongEnd);

		initGrid();

		initStrumline();

		initText();

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
		gridTiled.height = songLengthInPixels / gridZoom;
	}

	function onSongEnd()
	{
		song.audio.time = song.audio.length;
	}

	function initStrumline()
	{
		strumline = new FlxSprite().makeGraphic(Math.floor(gridTiled.width), 4);
		strumline.screenCenter();
		add(strumline);

		FlxG.camera.follow(strumline);
	}

	function initText()
	{
		textShit = new FlxText(10, 10, gridTiled.x - 16, 'urmom', 16);
		textShit.scrollFactor.set();
		add(textShit);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (song.audio?.playing)
			songPosition += elapsed * 1000;
		else
			songPosition = song.audio.time;

		conductor.update(songPosition);

		if (strumline != null)
			strumline.y = songPosition / gridZoom;

		controlManagement();

		textShit.text = 'Song: ${song.id}\n' + 'Song Position: ' + '${FlxMath.roundDecimal(songPosition / 1000, 2)}s / '
			+ '${FlxMath.roundDecimal(song.audio.length / 1000, 2)}s';
	}

	function controlManagement()
	{
		if (FlxG.keys.anyPressed([W, UP, S, DOWN]))
		{
			if (song.audio.playing)
				song.audio.pause();

			final amount = 10;

			if (FlxG.keys.anyPressed([W, UP]))
				songPosition -= amount;
			if (FlxG.keys.anyPressed([S, DOWN]))
				songPosition += amount;

			if (songPosition < 0)
				songPosition = 0;
			if (songPosition > song.audio.length)
				songPosition = song.audio.length;

			song.audio.time = songPosition;
		}

		if (FlxG.keys.justPressed.SPACE && song.audio != null)
		{
			if (song.audio.playing)
				song.audio.pause();
			else
				song.audio.play();
		}
	}

	var wasPlaying:Bool = false;

	override function onFocus()
	{
		super.onFocus();

		if (wasPlaying)
			song.audio.resume();
	}

	override function onFocusLost()
	{
		super.onFocusLost();

		wasPlaying = song.audio.playing;
		song.audio.pause();
	}
}
