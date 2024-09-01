package game;

import game.NoteGroup.Note;
import haxe.Json;


typedef LegacyFNFFormatSection = {
    var sectionNotes:Array<Dynamic>;
    var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
}

typedef LegacyFNFFormatSong = {
    var song:String;
    var notes:Array<LegacyFNFFormatSection>;
    var bpm:Float;
	var speed:Float;
}
typedef LegacyFNFFormat = {
    var song:LegacyFNFFormatSong;
}


class ChartParser
{
    public static function loadNotesFromJson(path:String, ?strumline0:Strumline, ?strumline1:Strumline) {
        var jsonFile = Paths.loadText(path);
        if (jsonFile == null) return;

        var song:LegacyFNFFormat = cast Json.parse(jsonFile);

        var leftSide:Array<Note> = [];
        var rightSide:Array<Note> = [];

        for (section in song.song.notes) {
            for (note in section.sectionNotes) {
                var n:Note = new Note();
                n.strumTime = note[0];
                n.strumID = Std.int(note[1]) % 4;
                n.sustainLength = note[2];
                n.noteType = 0;

                if (note[1] < 4) {
                    if (section.mustHitSection) rightSide.push(n); else leftSide.push(n);
                } else {
                    if (section.mustHitSection) leftSide.push(n); else rightSide.push(n);
                }
            }
        }
        if (strumline0 != null)
            strumline0.notes.addNotes(leftSide);
        if (strumline1 != null)
            strumline1.notes.addNotes(rightSide);
    }
}