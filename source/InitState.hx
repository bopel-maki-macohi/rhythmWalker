import freeplay.Freeplay;
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

		FlxG.stage.window.title = 'Rhythm Walker (v${FlxG.stage.application.meta.get('version')})';

		#if _32bit
		Main._32bit = true;
		trace('32bit');
		#end

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
		#if DIALOGUE
		FlxG.switchState(() -> new dialogue.DialogueScene(new song.Song('encapture')));
		return;
		#end

		#if RESULTS
		FlxG.switchState(() -> new ResultsState('train wreak-default'));
		return;
		#end

		FlxG.switchState(() -> new Freeplay());
	}

	function loadAssets()
	{
		var songList = Paths.json('game/songs/list');
		var tipsList = Paths.txt('game/tips');

		if (Assets.exists(songList))
		{
			Freeplay.songList = Json.parse(Assets.getText(songList));
		}
		else
		{
			FlxG.stage.window.alert('SONG LIST IS MISSING, GAME WILL DIE NOW.');
			FlxG.stage.window.close();
		}

		if (Assets.exists(tipsList))
		{
			Freeplay.tips = [
				for (line in Assets.getText(tipsList).split('\n'))
					if (line.trim().length > 0) line.trim()
			];
		}
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
