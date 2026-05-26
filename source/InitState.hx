import game.editors.ChartEditor;
import game.*;
import game.song.Song;
import util.*;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.*;
import flixel.*;

using StringTools;

class InitState extends FlxState
{
	override function create()
	{
		super.create();

		FlxTransitionableState.defaultTransIn = getDefaultTransition();
		FlxTransitionableState.defaultTransOut = getDefaultTransition();

		FlxG.sound.soundTray.volumeUpSound = PathUtil.audio('sfx/volume');
		FlxG.sound.soundTray.volumeDownSound = PathUtil.audio('sfx/volume');

		Save.init();

		loadAssets();

		WindowUtil.resetTitle(true);

		if (Flag.IS_DEBUG)
			WindowUtil.appendToTitle('(Debug)');

		for (id => flag in Flag.list)
			trace('Flag "${id}" : $flag');

		proceed();
	}

	function proceed()
	{
		if (Flag.STARTINGSTATE_CHARTEDITOR)
		{
			FlxG.switchState(() -> new ChartEditor());
		}
		else
		{
			FlxG.switchState(() -> new PlayState());
		}
	}

	function loadAssets() {}

	function getDefaultTransition():TransitionData
	{
		var transGraphic = FlxGraphic.fromClass(cast GraphicTransTileDiamond);
		transGraphic.persist = true;
		transGraphic.destroyOnNoUse = false;

		return new TransitionData(TILES, FlxColor.BLACK, 1, FlxPoint.get(0, -1), {
			asset: transGraphic,
			width: 32,
			height: 32
		},);
	}
}
