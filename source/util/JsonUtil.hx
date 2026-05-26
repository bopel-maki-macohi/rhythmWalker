package util;

import haxe.Json;

class JsonUtil
{
	public static function parseFile(file:String):Dynamic
	{
		if (!PathUtil.exists(file))
			return null;

		try
		{
			return Json.parse(PathUtil.getFileContent(file));
		}
		catch (e)
		{
			WindowUtil.alert('Error reading JSON file "$file" : $e');
		}

		return null;
	}
}
