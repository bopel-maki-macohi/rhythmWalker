import song.Song;
import util.WindowUtil;
import util.Flag;
import lime.app.Application;
import lime.utils.Assets;
import haxe.Json;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;

using StringTools;

class InitState extends FlxState
{
	override function create()
	{
		super.create();

		FlxTransitionableState.defaultTransIn = getDefaultTransition();
		FlxTransitionableState.defaultTransOut = getDefaultTransition();

		FlxG.sound.soundTray.volumeUpSound = Paths.getAudio('sfx/volume');
		FlxG.sound.soundTray.volumeDownSound = Paths.getAudio('sfx/volume');

		Save.init();

		loadAssets();

		WindowUtil.resetTitle(true);

		if (Flag.IS_DEBUG)
			WindowUtil.appendToTitle('(Debug)');

		for (id => flag in Flag.list)
			trace('Flag "${id}" : $flag');

		if (!Flag.PLATFORM_WEB)
		{
			proceed();
			return;
		}

		var clickForSync:FlxText = new FlxText(0, 0, 0, 'Click Here (Or anywhere!)', 16);
		add(clickForSync);
		clickForSync.screenCenter();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
			proceed();
	}

	function proceed()
	{
		FlxG.switchState(() -> new PlayState(new Song('hit')));
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
