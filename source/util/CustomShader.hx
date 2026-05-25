package util;

import flixel.FlxG;
import flixel.addons.display.FlxRuntimeShader;
import lime.utils.Assets;

class CustomShader extends FlxRuntimeShader
{
	public function new(name:String)
	{
		var fragPath:String = Paths.frag(name);
		var vertPath:String = Paths.vert(name);

		var fragCode:String = null;
		var vertCode:String = null;

		if (Assets.exists(fragPath))
			fragCode = Assets.getText(fragPath);

		if (Assets.exists(vertPath))
			vertCode = Assets.getText(vertPath);

		if (fragCode == null && vertCode == null)
			FlxG.stage.window.alert('Shader "$name" couldn\'t be found.');

		super(fragCode, vertCode);
	}
}
