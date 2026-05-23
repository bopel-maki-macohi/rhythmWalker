import flixel.text.FlxText;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;

class InitState extends FlxState
{
	override function create()
	{
		super.create();

		FlxTransitionableState.defaultTransIn = getDefaultTransition();
		FlxTransitionableState.defaultTransOut = getDefaultTransition();

		#if !web
		proceed();
		return;
		#end

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
		FlxG.switchState(() -> new PlayState());
	}

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
