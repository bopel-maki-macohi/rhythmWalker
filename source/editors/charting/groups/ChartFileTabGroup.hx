package editors.charting.groups;

import flixel.FlxG;
import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.Json;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.addons.ui.FlxUIButton;

class ChartFileTabGroup extends TabGroup
{
	public var saveMetadataButton:FlxUIButton;
	public var loadMetadataButton:FlxUIButton;

	override function create()
	{
		name = 'File';

		saveMetadataButton = new FlxUIButton(10, 20, 'Save Metadata', onSave);
		add(saveMetadataButton);

		loadMetadataButton = new FlxUIButton((saveMetadataButton.x * 2) + saveMetadataButton.width, saveMetadataButton.y, 'Load Metadata', onLoad);
		add(loadMetadataButton);
	}

	function onSave()
	{
		ChartingState.song.save();
	}

	function onLoad()
	{
		var fileRef = new FileReference();
		fileRef.addEventListener(Event.SELECT, onLoadSelect);
		fileRef.browse();
	}

	function onLoadSelect(e:Event)
	{
		var fileRef:FileReference = e.target;

		trace('Selected file');

		fileRef.addEventListener(Event.COMPLETE, onLoadComplete);
		fileRef.load();
	}

	function onLoadComplete(e:Event)
	{
		var fileRef:FileReference = e.target;

		var code:String = Base64.encode(Bytes.ofString(Date.now().toString()));

		var song:Song = new Song(code, defaultVariation, false);

		try
		{
			song.loadData(Json.parse(fileRef.data.toString()));
		}
		catch (e)
		{
			trace(e.message);

			song.loadData({
				id: code
			});
		}

		if (song.id != code)
		{
			trace('Loaded song: "${song.id}" (variation: ${song.variation})');

			ChartingState.song = song;
			FlxG.switchState(() -> new ChartingState());
		}
	}
}
