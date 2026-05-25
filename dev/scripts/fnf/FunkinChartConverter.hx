package dev.scripts.fnf;

import sys.FileSystem;
import haxe.Json;
import sys.io.File;

#if FLOATED_TIME_SIGNATURE
typedef FlxTimeSignature = Float;

/*
	abstract FlxTimeSignature(Float) from Float from Int to Float
	{
	public inline function new(Value:Float = 0)
	{
		this = Value;
	}

	@:to
	public inline function toInt():Int
	{
		return Math.floor(this);
	}
	}
 */
#else
abstract FlxTimeSignature(Int) from Int to Int to Float
{
	public inline function new(Value:Int = 0)
	{
		this = Value;
	}

	@:from
	public inline static function fromFloat(i:Float):FlxTimeSignature
	{
		return new FlxTimeSignature(Math.floor(i));
	}
}
#end

typedef MusicTimeChangeData =
{
	var t:Float; // TODO: Beat, Step, Section time variations

	@:optional
	var bpm:Null<Float>;

	@:optional
	var tsn:Null<FlxTimeSignature>;
	@:optional
	var tsd:Null<FlxTimeSignature>;

	@:optional
	var d:Null<Float>;
	@:optional
	var ease:Null<String>;
}

typedef SongData =
{
	id:String,
	variation:String,

	scrollSpeed:Null<Float>,

	bpmChanges:Array<MusicTimeChangeData>,
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
	static final song:String = 'milf';
    
	static final audio:String = 'D:/FNF/vslice/release/0.8.4/assets/songs/$song/Inst.ogg';
	static final chart:String = 'D:/FNF/vslice/release/0.8.4/assets/data/songs/$song/';

	static final variation:String = 'default';

	static function main()
	{
		var meta:SongData = {
			id: song.toLowerCase(),
			variation: variation.toLowerCase(),
			scrollSpeed: 1,
			bpmChanges: [],
			events: [
				{
					time: 0,
					id: "beatmonsters-stop"
				}
			]
		};

		var audioFile = File.getBytes(audio);

		var readchart:Dynamic = Json.parse(File.getContent(chart + '${song.toLowerCase()}-chart${(variation != 'default') ? '-$variation' : ''}.json'));
		var readmeta:Dynamic = Json.parse(File.getContent(chart + '${song.toLowerCase()}-metadata${(variation != 'default') ? '-$variation' : ''}.json'));

		var bpmChanges:Array<Dynamic> = readmeta.timeChanges;

		for (thing in bpmChanges)
		{
			meta.bpmChanges.push({
				t: thing.t,
				bpm: thing.bpm,
			});
		}

		var chart:Array<Dynamic> = [];

		if (variation == 'default')
		{
			meta.scrollSpeed = readchart.scrollSpeed.hard;
			chart = readchart.notes.hard;
		}
		if (variation == 'erect')
		{
			meta.scrollSpeed = readchart.scrollSpeed.nightmare;
			chart = readchart.notes.nightmare;
		}

		for (thing in chart)
		{
			var len:Null<Float> = thing?.l ?? 0.0;
            len += 1;

			var tO = 0.0;

			var holdIncS = .05;

			while (len > 0)
			{
				meta.events.push({
					time: thing.t + tO,
					id: "beatmonsters-spawnmonster"
				});

				len -= holdIncS * 1000;
				tO += holdIncS * 1000;
			}
		}

		FileSystem.createDirectory('assets/game/songs/$song');

		File.saveBytes('assets/game/songs/$song/${variation.toLowerCase()}.ogg', audioFile);
		File.saveContent('assets/game/songs/$song/${variation.toLowerCase()}.json', Json.stringify(meta, '\t'));
	}
}
