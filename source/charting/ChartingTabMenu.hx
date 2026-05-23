package charting;

import charting.groups.ChartPreferencesTabGroup;
import charting.groups.ChartFileTabGroup;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import charting.groups.ChartMetadataTabGroup;
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

		metadata = new ChartMetadataTabGroup(this);
		addGroup(metadata);
	}

	public function sendEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>)
	{
		for (grp in [file, metadata, preferences])
			grp.getEvent(name, sender, data, params);
	}
}
