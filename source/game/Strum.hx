package game;

import flixel.FlxSprite;

class Strum extends FlxSprite {
    public var strumline:Strumline;

    var curState:String = "static";
    public var holdTimer:Float = 0.0;
    override public function update(elapsed) {
        super.update(elapsed);
        if (curState == "confirm" && strumline.botplay) {
            holdTimer -= elapsed;
            if (holdTimer <= 0.0) {
                setState("static");
            }
        }
    }

    public function setState(state:String) {
        animation.play(state+ID, true);
        curState = state;
        centerOffsets();
		centerOrigin();
        holdTimer = 0.15;
    }
}