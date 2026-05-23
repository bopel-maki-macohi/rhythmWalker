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
}
