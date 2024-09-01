package game;

import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.input.keyboard.FlxKey;
import flixel.FlxBasic;
import game.NoteGroup;

class NoteInputManager extends FlxBasic {
    var binds:Array<FlxKey> = [FlxKey.D, FlxKey.F, FlxKey.J, FlxKey.K];
    var actionsJP:Array<FlxActionDigital> = [];
    var actionsJR:Array<FlxActionDigital> = [];
    var actionsP:Array<FlxActionDigital> = [];

    static final HIT_WINDOW:Float = 150;

    public function new() {

        for (i in binds) {
            actionsJP.push(new FlxActionDigital("noteInput").addKey(i, JUST_PRESSED));
            actionsJR.push(new FlxActionDigital("noteInput").addKey(i, JUST_RELEASED));
            actionsP.push(new FlxActionDigital("noteInput").addKey(i, PRESSED));
        }
        super();
    }

    public inline function justPressed(id:Int) { return actionsJP[id].check(); }
    public inline function justReleased(id:Int) { return actionsJR[id].check(); }
    public inline function pressed(id:Int) { return actionsP[id].check(); }

    public function noteUpdateCheck(strumline:Strumline) {

        for (i in 0...binds.length) {
            var jp = justPressed(i);
            var p = pressed(i);
            var jr = justReleased(i);

            

            var notesThatCanBeHit:Array<Note> = [];
            var notesThatCanBeHeld:Array<Note> = [];

            for (note in strumline.notes.notes) {
                if (note.strumTime >= Conductor.songPosition - HIT_WINDOW && note.strumTime <= Conductor.songPosition + HIT_WINDOW) {
                    if (note.strumID == i && !note.wasHit) {
                        notesThatCanBeHit.push(note);
                    }
                }
                if (note.wasHit && note.strumID == i && note.sustainLength != 0 && Conductor.songPosition < note.strumTime+note.sustainLength) {
                    notesThatCanBeHeld.push(note);
                }

                if (Conductor.songPosition > note.strumTime + note.sustainLength + 1000) {
                    break;
                }
            }

            //trace(notesThatCanBeHit);

            if (jp) {
                if (notesThatCanBeHit.length > 0) {
                    if (notesThatCanBeHit.length > 1) { //sort just in case
                        notesThatCanBeHit.sort(function(a, b) {
                            if(a.strumTime < b.strumTime) return -1;
                            else if(a.strumTime > b.strumTime) return 1;
                            else return 0;
                         });
                    }
    
                    strumline.onNoteHit(notesThatCanBeHit[0]);
                } else {
                    strumline.onGhostTap(i);
                }
            }
            if (p) {
                if (notesThatCanBeHeld.length > 0) {
                    for (hold in notesThatCanBeHeld) {
                        strumline.onNoteHold(hold);
                    }
                }
            }

            if (jr) strumline.onInputRelease(i);
 
        }
    }
}