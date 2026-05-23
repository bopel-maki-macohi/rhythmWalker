package charting.groups;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUINumericStepper;
import editorstuff.TabGroup;

class ChartMetadataTabGroup extends TabGroup
{
	public var bpmStepper:FlxUINumericStepper;

	override function create() @:privateAccess
	{
		super.create();

		name = 'Metadata';

		bpmStepper = new FlxUINumericStepper(10, 20, .5, 150, -999, 999, 1, FlxUINumericStepper.STACK_HORIZONTAL, makeUITextLabel(50));
		bpmStepper.value = ChartingState.song.bpm;
		bpmStepper.name = 'bpmStepper';

		add(bpmStepper);
		add(makeTextLabel(bpmStepper, 'BPM'));
	}

	override function getEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>)
	{
		super.getEvent(name, sender, data, params);

		switch (name)
		{
			case FlxUINumericStepper.CHANGE_EVENT:
				var stepperSender:FlxUINumericStepper = cast(sender, FlxUINumericStepper);

				if (stepperSender != null)
					switch (stepperSender.name)
					{
						case 'bpmStepper':
							ChartingState.song.bpm = stepperSender.value;
					}
		}
	}
}
