package util;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.vis.dsp.SpectralAnalyzer;
import lime.media.AudioSource;

/**
 * Yoinked straight from the funkViz git repo as a base
 * https://github.com/FunkinCrew/funkVis/blob/main/example/source/Visualizer.hx
 */
class BarVisualizer extends FlxGroup
{
	var grpBars:FlxTypedGroup<FlxSprite>;
	var peakLines:FlxTypedGroup<FlxSprite>;
	var analyzer:SpectralAnalyzer;

	public function new(audioSource:AudioSource, barCount:Int = 16)
	{
		super();

		set(audioSource, barCount);
	}

	public function set(audioSource:AudioSource, barCount:Int = 16)
	{
		if (audioSource == null)
			return;

		analyzer = new SpectralAnalyzer(audioSource, barCount, 0.1, 10);

		grpBars = new FlxTypedGroup<FlxSprite>();
		add(grpBars);
		peakLines = new FlxTypedGroup<FlxSprite>();
		add(peakLines);

		for (i in 0...barCount)
		{
			var spr = new FlxSprite((i / barCount) * FlxG.width, 0).makeGraphic(Std.int((1 / barCount) * FlxG.width) - 4, FlxG.height, 0x55ff0000);
			spr.origin.set(0, FlxG.height);
			grpBars.add(spr);
			spr = new FlxSprite((i / barCount) * FlxG.width, 0).makeGraphic(Std.int((1 / barCount) * FlxG.width) - 4, 1, 0xaaff0000);
			peakLines.add(spr);
		}
	}

	@:generic
	static inline function min<T:Float>(x:T, y:T):T
	{
		return x > y ? y : x;
	}

	override function draw()
	{
		if (analyzer != null)
		{
			var levels = analyzer.getLevels();

			for (i in 0...min(grpBars.members.length, levels.length))
			{
				grpBars.members[i].scale.y = levels[i].value;
				peakLines.members[i].y = FlxG.height - (levels[i].peak * FlxG.height);
			}
		}

		super.draw();
	}
}
