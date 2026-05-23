import flixel.FlxG;
import flixel.text.FlxText;

class DemoEndState extends ConductorState
{
	override function create()
	{
		super.create();

		var text = new FlxText(0, 0, 0,
			'Heya there, this is just version 0.1.0 of Rhythm Walker!'
			+ '\nJust a demo.'
			+ '\nThe game will continue getting updates thoooo. So yeah.'
			+ '\n\nBye bye.'
			+ '\n\nIf you want to hear my terrible music again, press ENTER.',
			16);
		text.alignment = CENTER;
		text.screenCenter();
		add(text);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
			FlxG.switchState(() -> new PlayState());
	}
}
