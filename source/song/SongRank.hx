package song;

enum abstract SongRank(String) from String to String
{
	var NONE = 'NONE'; // null
	var BAD = 'BAD'; // anything else
	var OK = 'OK'; // 50%
	var GOOD = 'GOOD'; // 60%
	var GREAT = 'GREAT'; // 70%
	var EXCELLENT = 'EXCELLENT'; // 80%
	var PERFECT = 'PERFECT'; // 100%

	public static function getRankFromPercent(percent:Float):SongRank
	{
		if (percent >= 1)
			return PERFECT;
		
        if (percent >= 0.8)
			return EXCELLENT;
		
        if (percent >= 0.7)
			return GREAT;
		
        if (percent >= 0.6)
			return GOOD;

		if (percent >= 0.5)
			return OK;

		return BAD;
	}
}
