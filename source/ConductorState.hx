import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.ui.FlxUIState;

class ConductorState extends FlxUIState
{
	public var conductor(get, never):FlxRhythmConductor;

	function get_conductor():FlxRhythmConductor
		return FlxRhythmConductor.instance;

	public function resetConductor()
	{
		FlxRhythmConductor.reset();

		conductor.onBeatHit.add(onBeatHit);
		conductor.onBpmChange.add(onBpmChange);
		conductor.onMeasureHit.add(onMeasureHit);
		conductor.onStepHit.add(onStepHit);
	}

	public function onBeatHit(beat:Int, backward:Bool) {}

	public function onBpmChange(time:Float, backward:Bool) {}

	public function onMeasureHit(measure:Float, backward:Bool) {}

	public function onStepHit(step:Int, backward:Bool) {}
}
