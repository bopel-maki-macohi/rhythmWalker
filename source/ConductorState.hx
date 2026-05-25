import flixel.FlxG;
import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.ui.FlxUIState;

class ConductorState extends FlxUIState
{
	var conductor(get, never):FlxRhythmConductor;

	function get_conductor():FlxRhythmConductor
		return FlxRhythmConductor.instance;

	function resetConductor()
	{
		FlxRhythmConductor.reset();

		conductor.onBeatHit.add(onBeatHit);
		conductor.onBpmChange.add(onBpmChange);
		conductor.onMeasureHit.add(onMeasureHit);
		conductor.onStepHit.add(onStepHit);
	}

	function onBeatHit(beat:Int, backward:Bool) {}

	function onBpmChange(bpm:Float, backward:Bool) {}

	function onMeasureHit(measure:Float, backward:Bool) {}

	function onStepHit(step:Int, backward:Bool) {}

	var mouseEnabled:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.mouse.visible = mouseEnabled;
	}
}
