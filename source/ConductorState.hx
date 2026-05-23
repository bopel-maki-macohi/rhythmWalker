import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import flixel.FlxState;

class ConductorState extends FlxUIState
{
	public var songTime:Float = 0;
	public var songTimeChange:Float = 0;

	public var bpm(default, set):Float = 0;

	function set_bpm(bpm:Float):Float
	{
		if (this.bpm == bpm)
			return this.bpm = bpm;

		songTimeChange = songTime;
		stepChange = step;

		return this.bpm = bpm;
	}

	public var crochet(get, never):Float;

	function get_crochet():Float
	{
		return (60 / bpm) * 1000;
	}

	public var stepCrochet(get, never):Float;

	function get_stepCrochet():Float
	{
		return crochet / 4;
	}

	public var beat:Int = 0;
	public var step:Int = 0;
	public var stepChange:Int = 0;

	public function updateConductor()
	{
		final lastStep:Int = step;
		final lastBeat:Int = beat;

		step = stepChange + Math.floor((songTime - songTimeChange) / stepCrochet);
		beat = Math.floor(step / 4);

		if (step != lastStep)
			stepHit();
		if (beat != lastBeat)
			beatHit();

		FlxG.watch.addQuick('bpm', bpm);
		FlxG.watch.addQuick('beat', beat);
		FlxG.watch.addQuick('step', step);
		FlxG.watch.addQuick('songTime', songTime);
	}

	public function beatHit() {}

	public function stepHit() {}
}
