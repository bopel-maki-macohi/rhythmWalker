class Paths
{
	public static inline function getPath(path:String)
		return 'assets/$path';

	public static inline function getAudio(path:String)
		return getPath('$path.ogg');

	public static inline function getSong(song:String, variation:String = 'default')
		return getAudio('game/songs/${song.toLowerCase()}/${variation.toLowerCase()}');

	public static inline function getImagePath(path:String)
		return getPath('$path.png');

	public static inline function json(path:String)
		return getPath('$path.json');

	public static inline function frag(path:String)
		return getPath('shaders/$path.frag');

	public static inline function vert(path:String)
		return getPath('shaders/$path.vert');
}
