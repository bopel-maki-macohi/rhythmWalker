class ChartingState extends ConductorState
{
    var song:Song;

	override function create()
	{
		super.create();

        song = new Song('bopeebo');

        song.save();
	}
}
