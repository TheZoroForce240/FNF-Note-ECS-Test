package game;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import game.NoteGroup;

class Strumline extends FlxTypedGroup<Strum> {

    public var botplay:Bool = true;

    public var keyCount:Int = 4;
    public var skin:String = "notes/vanilla";
    public var notes:NoteGroup;

    public var scrollSpeed:Float = 3;
    public var downscroll:Bool = false;

    public var noteSpacing:Float = 1.0;
    public var noteScale:Float = 1.0;

    public var input:NoteInputManager;

    public static final DEFAULT_NOTE_SCALE = 0.7;
    public static final DEFAULT_NOTE_WIDTH = 160;

    public function setup(x, y) {
        for (i in 0...keyCount) {
            var strum = new Strum(x + (i * DEFAULT_NOTE_WIDTH * DEFAULT_NOTE_SCALE * noteSpacing * noteScale), y);
            strum.ID = i;

            //center strumline math
            strum.x -= ((DEFAULT_NOTE_WIDTH * DEFAULT_NOTE_SCALE * noteScale * ((keyCount/2)-0.5) * noteSpacing) + DEFAULT_NOTE_WIDTH * 0.5 * DEFAULT_NOTE_SCALE * noteScale);

            Paths.loadSpriteAnimations(strum, skin);
            strum.scale.x = strum.scale.y = DEFAULT_NOTE_SCALE * noteScale;
            strum.updateHitbox();
            strum.antialiasing = true;
            strum.animation.play("static"+i);
            strum.strumline = this;
            add(strum);
        }

        input = new NoteInputManager();
        notes = new NoteGroup(this);
    }

    public function onNoteHit(note:Note) {
        members[note.strumID].setState("confirm");
        note.wasHit = true;
    }
    public function onGhostTap(id:Int) {
        members[id].setState("press");
    }
    public function onNoteHold(note:Note) {
        members[note.strumID].setState("confirm");
        note.wasHit = true;
    }
    public function onInputRelease(id:Int) {
        members[id].setState("static");
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (!botplay) 
            input.noteUpdateCheck(this);
        notes.update(elapsed);
    }

    override public function draw() {
        super.draw();
        notes.draw();
    }

    override public function destroy() {
        super.destroy();
        notes.destroy();
    }
}