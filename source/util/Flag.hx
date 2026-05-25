package util;

class Flag
{
	public static final FREEPLAY_MULTICACHE:Bool = #if linux false; #else !Main._32bit; #end
}
