package song;

import flixel.addons.sound.MusicTimeChangeEvent;

typedef SongData = {
    id:String,
    variation:String,

    scrollSpeed:Null<Float>,

    bpmChanges:Array<MusicTimeChangeData>,
}