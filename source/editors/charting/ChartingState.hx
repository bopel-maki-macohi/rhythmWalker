package editors.charting;

import flixel.text.FlxText;

class ChartingState extends ConductorState
{
	public static var song:Song = null;

	var uiBox:ChartingTabMenu;

	var songText:FlxText;

	override function create()
	{
		super.create();

		if (song == null)
			song = new Song('First Steps');

		uiBox = new ChartingTabMenu();
		add(uiBox);

		songText = new FlxText(10, 10, 0, 'urmom', 16);
		add(songText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		songText.text = 'Song: ${song.id}\n' + '\tVariation: ${song.variation}\n' + '\tBPM: ${song.bpm}\n';
		bpm = song.bpm;
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
