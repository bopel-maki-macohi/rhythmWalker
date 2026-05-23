package editors.charting;

import editors.charting.groups.*;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUITabMenu;

class ChartingTabMenu extends FlxUITabMenu
{
	public var file:ChartFileTabGroup;
	public var metadata:ChartMetadataTabGroup;
	public var preferences:ChartPreferencesTabGroup;

	override public function new()
	{
		super(null, null, [
			{name: 'File', label: 'File'},
			{name: 'Metadata', label: 'Metadata'},
			{name: 'Preferences', label: 'Preferences'},
		], null, true);

		resize(640, 380);

		setPosition(20, 20);
		screenCenter(Y);

		selected_tab = 0;

		file = new ChartFileTabGroup(this);
		addGroup(file);

		metadata = new ChartMetadataTabGroup(this);
		addGroup(metadata);

		preferences = new ChartPreferencesTabGroup(this);
		addGroup(preferences);
	}

	public function sendEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>)
	{
		for (grp in [file, metadata, preferences])
			if (grp != null)
				grp.getEvent(name, sender, data, params);
	}
}
