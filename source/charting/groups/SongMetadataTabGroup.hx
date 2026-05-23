package charting.groups;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUINumericStepper;
import editorstuff.TabGroup;

class SongMetadataTabGroup extends TabGroup
{
	public var bpmStepper:FlxUINumericStepper;

	override function create()
	{
		super.create();

        name = 'Metadata';

		bpmStepper = new FlxUINumericStepper(10, 20, .5, 150);
		bpmStepper.value = ChartingState.song.bpm;

		add(bpmStepper);
		add(makeTextLabel(bpmStepper, 'BPM'));
	}

	override function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>)
	{
		super.getEvent(name, sender, data, params);

		trace(name);
		trace(sender);
		trace(data);
		trace(params);
	}
}
