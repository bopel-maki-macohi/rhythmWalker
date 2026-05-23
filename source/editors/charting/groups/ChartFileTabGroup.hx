package editors.charting.groups;

import flixel.addons.ui.FlxUIButton;

class ChartFileTabGroup extends TabGroup
{
	public var saveButton:FlxUIButton;

	override function create()
	{
		name = 'File';

		saveButton = new FlxUIButton(10, 20, 'Save', onSave);
        add(saveButton);
	}

	function onSave()
	{
		ChartingState.song.save();
	}
}
