package dialogue;

typedef DialogueLineData = {
    speaker:Int,
    ?text:String,
    
    ?events:Array<DialogueEventData>,
}