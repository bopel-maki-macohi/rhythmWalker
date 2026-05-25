package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var _32bit:Bool = false;

	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, InitState));
	}
}
