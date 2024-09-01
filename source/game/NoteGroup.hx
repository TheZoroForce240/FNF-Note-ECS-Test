package game;

import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.FlxBasic;

final class Note {
    public function new() {}
    
    public var strumTime:Float;
    public var strumID:Int;
    public var sustainLength:Float;
    public var noteType:Int;

    public var wasHit:Bool = false;
}

//dummy sprites that will be drawn multiple times
final class NoteRenderData {
    public var note:FlxSprite;
    public var sustain:FlxSprite;
    public var sustainEnd:FlxSprite;

    public function new() {
        note = new FlxSprite();
        sustain = new FlxSprite();
        sustainEnd = new FlxSprite();
    }
}

class NoteGroup extends FlxBasic {
    static final NOTE_SPEEDSCALE = 0.45;
    static final NOTE_DRAW_LIMIT = 1000;
    static final NOTE_APPEAR_CUTOFF = 720.0;

    public var notes:Array<Note> = [];
    var strumline:Strumline;
    
    var noteRenderData:Array<NoteRenderData> = [];

    public function new(strumline:Strumline) {
        this.strumline = strumline;
        super();

        //create sprites for each lane
        for (i in 0...strumline.keyCount) {
            var renderData:NoteRenderData = new NoteRenderData();
            Paths.loadSpriteAnimations(renderData.note, strumline.skin);
            Paths.loadSpriteAnimations(renderData.sustain, strumline.skin);
            Paths.loadSpriteAnimations(renderData.sustainEnd, strumline.skin);
            renderData.note.animation.play("note"+i);
            renderData.sustain.animation.play("noteHold"+i);
            renderData.sustainEnd.animation.play("noteHoldEnd"+i);
            //renderData.sustain.shader = renderData.sustainShader;
            //renderData.sustainEnd.shader = renderData.sustainEndShader;
            renderData.sustain.alpha = 0.6;
            renderData.sustainEnd.alpha = 0.6;
            noteRenderData.push(renderData);
        }

        /*
        addNote(0, 0, 500, 0);
        addNote(500, 3, 0, 0);
        addNote(1000, 2, 1000, 0);

        var time:Float = 2000;
        for (i in 0...100000) {
            
            time += 1000/(i+1);
            addNote(time, i%4, 0, 0);
        }*/
    }
    public function addNotes(arr:Array<Note>) {
        notes = notes.concat(arr);
        sort();
    }
    public inline function addNote(strumTime:Float, strumID:Int, sustainLength:Float, noteType:Int) {
        var note:Note = new Note();
        note.strumTime = strumTime;
        note.strumID = strumID;
        note.sustainLength = sustainLength;
        note.noteType = noteType;
        note.wasHit = false;
        notes.push(note);
    }
    public inline function sort() {
        notes.sort(function(a, b) {
            if(a.strumTime < b.strumTime) return -1;
            else if(a.strumTime > b.strumTime) return 1;
            else return 0;
         });
    }
    override public function update(elapsed) {
        super.update(elapsed);
        
        for (note in notes) {
            if (Conductor.songPosition >= note.strumTime && strumline.botplay) {
                if (!note.wasHit) {
                    strumline.onNoteHit(note);
                }
                if ((note.sustainLength != 0 && Conductor.songPosition < note.strumTime+note.sustainLength)) {
                    strumline.onNoteHold(note);
                }
            }
                
            if ((note.strumTime - Conductor.songPosition) * NOTE_SPEEDSCALE * strumline.scrollSpeed >= NOTE_APPEAR_CUTOFF) break;

            if (/*(note.wasHit && note.sustainLength == 0) ||*/ (note.strumTime+note.sustainLength - Conductor.songPosition) < -400) {
                notes.remove(note);
            }
        }
    }

    public var notesRendered = 0;
    override public function draw() {
        notesRendered = 0;
        for (i in 0...notes.length) {
            var note = notes[i];

            if ((note.strumTime - Conductor.songPosition) * NOTE_SPEEDSCALE * strumline.scrollSpeed >= NOTE_APPEAR_CUTOFF) break;
            var curPosition = (note.strumTime - Conductor.songPosition) * NOTE_SPEEDSCALE * strumline.scrollSpeed * (strumline.downscroll ? -1 : 1);

            var renderData = noteRenderData[note.strumID];
            //draw sustain first
            if (note.sustainLength > 0) {
                drawSustain(note, curPosition, renderData, strumline.members[note.strumID]);
                drawSustainEnd(note, curPosition, renderData, strumline.members[note.strumID]);
            }

            if (!note.wasHit) {
                //draw note
                drawNote(note, curPosition, renderData, strumline.members[note.strumID]);
            }

            if (notesRendered >= NOTE_DRAW_LIMIT) break;
        }
        super.draw();
    }

    private inline function drawNote(note:Note, curPosition:Float, renderData:NoteRenderData, strum:Strum) {
        renderData.note.x = strum.x;
        renderData.note.y = strum.y + curPosition;

        renderData.note.scale.x = strum.scale.x;
        renderData.note.scale.y = strum.scale.y;
        renderData.note.updateHitbox();

        renderData.note.cameras = cameras;
        renderData.note.draw();
        notesRendered++;
    }
    private inline function drawSustain(note:Note, curPosition:Float, renderData:NoteRenderData, strum:Strum) {
        //scale first
        renderData.sustain.scale.x = strum.scale.x;
        renderData.sustain.scale.y = ((note.sustainLength * NOTE_SPEEDSCALE * strumline.scrollSpeed) / renderData.sustain.frameHeight);
        renderData.sustain.updateHitbox();

        //center positions
        renderData.sustain.x = strum.x + strum.width*0.5 - renderData.sustain.width*0.5;
        renderData.sustain.y = strum.y + curPosition + strum.height*0.5;

        //downscroll offset
        if (strumline.downscroll)
            renderData.sustain.y -= renderData.sustain.height;

        //setup shader
        //renderData.sustainShader.clipY.value = [strum.y + strum.height*0.5];
        //renderData.sustainShader.yValue.value = [renderData.sustain.y, renderData.sustain.y, renderData.sustain.y+renderData.sustain.height, renderData.sustain.y+renderData.sustain.height];
        //renderData.sustainShader.downscroll.value = [strumline.downscroll ? 1 : 0];
        //renderData.sustain.shader = note.wasHit ? renderData.sustainShader : null;

        //clip
        //using the scale cuz doing with either cliprect or shaders acts kinda weird since it uses the same sprite
        if (note.wasHit) {
            renderData.sustain.y = strum.y + strum.height*0.5;

            var t = ((note.strumTime+note.sustainLength) - Conductor.songPosition) * NOTE_SPEEDSCALE * strumline.scrollSpeed;
            if (t < 0.0) t = 0.0;
            renderData.sustain.scale.y = (t / renderData.sustain.frameHeight);
            renderData.sustain.updateHitbox();

            if (strumline.downscroll)
                renderData.sustain.y -= renderData.sustain.height;
        }


        //now draw
        renderData.sustain.cameras = cameras;
        renderData.sustain.draw();
        notesRendered++;
    }
    private inline function drawSustainEnd(note:Note, curPosition:Float, renderData:NoteRenderData, strum:Strum) {
        //scale
        renderData.sustainEnd.scale.x = renderData.sustainEnd.scale.y = strum.scale.x;
        renderData.sustainEnd.updateHitbox();

        //offsets
        renderData.sustainEnd.x = strum.x + strum.width*0.5 - renderData.sustainEnd.width*0.5;
        if (!strumline.downscroll) {
            renderData.sustainEnd.flipY = false;
            renderData.sustainEnd.y = renderData.sustain.y + renderData.sustain.height;
        } else {
            renderData.sustainEnd.flipY = true;
            renderData.sustainEnd.y = renderData.sustain.y - renderData.sustainEnd.height;
        }

        //shader stuff
        //renderData.sustainEndShader.clipY.value = [strum.y + strum.height*0.5];
        //renderData.sustainEndShader.yValue.value = [renderData.sustainEnd.y, renderData.sustainEnd.y, renderData.sustainEnd.y+renderData.sustainEnd.height, renderData.sustainEnd.y+renderData.sustainEnd.height];
        //renderData.sustainEndShader.downscroll.value = [strumline.downscroll ? 1 : 0];
        //renderData.sustainEnd.shader = note.wasHit ? renderData.sustainEndShader : null;

        //clip
        if (note.wasHit && Conductor.songPosition >= note.strumTime + note.sustainLength) {
            renderData.sustainEnd.y = strum.y + strum.height*0.5;

            var height = renderData.sustainEnd.frameHeight / (NOTE_SPEEDSCALE * strumline.scrollSpeed); //sustain end time
            var t = ((note.strumTime+note.sustainLength+height) - Conductor.songPosition) * NOTE_SPEEDSCALE * strumline.scrollSpeed;
            if (t < 0.0) t = 0.0;
            renderData.sustainEnd.scale.y = (t / renderData.sustainEnd.frameHeight);
            renderData.sustainEnd.updateHitbox();
            if (strumline.downscroll)
                renderData.sustainEnd.y -= renderData.sustainEnd.height;
        }

        //now draw
        renderData.sustainEnd.cameras = cameras;
        renderData.sustainEnd.draw();
        notesRendered++;
    }
}