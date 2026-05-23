import charting.ChartingTabMenu;
import flixel.addons.ui.FlxUITabMenu;

class ChartingState extends ConductorState
{
	public static var song:Song = null;

	var uiBox:ChartingTabMenu;

	override function create()
	{
		super.create();

		song = new Song('bopeebo');

		uiBox = new ChartingTabMenu();
		add(uiBox);
	}

	override function destroy()
	{
		super.destroy();

		song = null;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		super.getEvent(id, sender, data, params);

		uiBox?.sendEvent(id, sender, data, params);
	}
}
