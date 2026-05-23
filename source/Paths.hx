class Paths
{
	public static inline function getPath(path:String)
		return 'assets/$path';

	public static inline function getAudio(path:String)
		return getPath('$path.ogg');

	public static inline function getImage(path:String)
		return getPath('$path.png');
}
