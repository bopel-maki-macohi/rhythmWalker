package util;

enum abstract Flag(Bool) from Bool to Bool
{
	public static var list:Map<String, Flag> = [];

	public static final IS_32BIT = new Flag('IS_32BIT', [#if _32bit true #else false #end,]);

	public static final PLATFORM_LINUX = new Flag('PLATFORM_LINUX', [#if linux true #else false #end,]);

	public static final FREEPLAY_MULTICACHE = new Flag('FREEPLAY_MULTICACHE', [!PLATFORM_LINUX, !IS_32BIT,]);
	public static final FREEPLAY_VISUALIZER = new Flag('FREEPLAY_VISUALIZER', [!PLATFORM_LINUX,]);

	public function new(id:String, conditionals:Array<Bool>)
	{
		this = conditionals.filter(b -> return b).length == conditionals.length;

		if (!list.exists(id))
			list.set(id, this);
	}
}
