class Paths
{
	public static inline function getPath(path:String)
		return 'assets/$path';

	public static inline function getAudio(path:String)
		return getPath('$path.ogg');

	public static inline function getSong(song:String, variation:String = 'default')
		return getAudio('songs/${song.toLowerCase()}/${variation.toLowerCase()}');

	public static inline function getImagePath(path:String)
		return getPath('$path.png');

	public static inline function json(path:String)
		return getPath('$path.json');
}
