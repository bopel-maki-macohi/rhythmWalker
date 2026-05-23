package charting;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import charting.groups.SongMetadataTabGroup;
import flixel.addons.ui.FlxUITabMenu;

class ChartingTabMenu extends FlxUITabMenu
{
	public var metadata:SongMetadataTabGroup;

	override public function new()
	{
		super(null, null, [
			{name: 'Metadata', label: 'Metadata'},
			{name: 'Preferences', label: 'Preferences'},
		], null, true);

		resize(640, 380);

		setPosition(20, 20);
		screenCenter(Y);

		selected_tab = 0;

		metadata = new SongMetadataTabGroup(this);
		addGroup(metadata);
	}

	public function sendEvent(name:String, sender:IFlxUIWidget, data:Dynamic, ?params:Array<Dynamic>)
	{
		metadata.getEvent(name, sender, data, params);
	}
}
