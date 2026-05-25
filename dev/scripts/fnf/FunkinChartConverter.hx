package dev.scripts.fnf;

import sys.FileSystem;
import haxe.Json;
import sys.io.File;

typedef SongData =
{
	id:String,
	variation:String,

	scrollSpeed:Null<Float>,

	bpmChanges:Array<Dynamic>,
	events:Array<SongEventData>,
}

typedef SongEventData =
{
	var time:Float;

	var id:String;

	@:optional
	var data:Dynamic;
}

/**
 * haxe -m dev.scripts.fnf.FunkinChartConverter --interp
 */
class FunkinChartConverter
{
	static final audio:String = 'D:/FNF/vslice/release/0.8.4/assets/songs/milf/Inst.ogg';
	static final chart:String = 'D:/FNF/vslice/release/0.8.4/assets/data/songs/milf/';

	static final song:String = 'milf';
	static final variation:String = 'default';

	static function main()
	{
		var meta:SongData = {
			id: song.toLowerCase(),
			variation: variation.toLowerCase(),
			scrollSpeed: 1,
			bpmChanges: [
				{
					t: 0,
					bpm: 0,
				}
			],
			events: []
		};

		var audioFile = File.getBytes(audio);

        var readchart:String = File.getContent(chart + '${song.toLowerCase()}-chart${(variation != 'default') ? '-$variation' : ''}.json');
        var readmeta:String = File.getContent(chart + '${song.toLowerCase()}-metadata${(variation != 'default') ? '-$variation' : ''}.json');

        FileSystem.createDirectory('assets/game/songs/$song');

		File.saveBytes('assets/game/songs/$song/${variation.toLowerCase()}.ogg', audioFile);
		File.saveContent('assets/game/songs/$song/${variation.toLowerCase()}.json', Json.stringify(meta, '\t'));
	}
}
