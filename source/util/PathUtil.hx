package util;

import sys.io.File;
import sys.FileSystem;

class PathUtil
{
	public static inline function getPath(path:String)
		return 'assets/$path';

	public static inline function getShadersPath(path:String)
		return getPath('shaders/$path');

	public static inline function getAudio(path:String)
		return getPath('$path.ogg');

	public static inline function getImagePath(path:String)
		return getPath('$path.png');

	public static inline function json(path:String)
		return getPath('$path.json');

	public static inline function txt(path:String)
		return getPath('$path.txt');

	public static inline function frag(path:String)
		return getShadersPath('$path.frag');

	public static inline function vert(path:String)
		return getShadersPath('$path.vert');

	public static inline function exists(path:String):Bool
		return FileSystem.exists(path);

	public static inline function getFileContent(file:String):String
		return File.getContent(file) ?? null;
}
