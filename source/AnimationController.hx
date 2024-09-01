import haxe.Json;
import flixel.animation.FlxAnimationController;

typedef AnimationData = {
    var name:String;
    var prefix:String;
    var ?looped:Bool;
    var ?frameRate:Float;
    var ?flipX:Bool;
    var ?flipY:Bool;
    var ?offsetX:Float;
    var ?offsetY:Float;
    var ?indices:Array<Int>;
}

typedef AnimationJson = {
    var animations:Array<AnimationData>;
}

typedef Point = {
    var x:Float;
    var y:Float;
}

class AnimationController extends FlxAnimationController
{
    private var animOffsets:Map<String, Point> = [];

    override public function play(animName:String, force = false, reversed = false, frame = 0):Void 
    {
        if (_animations.get(animName) == null) //dont play an anim that doesnt exist
            return;

        super.play(animName, force, reversed, frame);

        if (animOffsets.exists(animName)) {
            var point = animOffsets.get(animName);
            _sprite.offset.x = point.x;
            _sprite.offset.y = point.y;
        }
    }

    public function loadAnimationJson(text:String) {
        var data:AnimationJson = cast Json.parse(text);

        for (animData in data.animations) {

            if (animData.indices == null) {
                addByPrefix(
                    animData.name, 
                    animData.prefix, 
                    animData.frameRate == null ? 24.0 : animData.frameRate,
                    animData.looped == null ? true : animData.looped,
                    animData.flipX == null ? false : animData.flipX,
                    animData.flipY == null ? false : animData.flipY
                );
            } else {
                addByIndices(
                    animData.name, 
                    animData.prefix,
                    animData.indices,
                    "",
                    animData.frameRate == null ? 24.0 : animData.frameRate,
                    animData.looped == null ? true : animData.looped,
                    animData.flipX == null ? false : animData.flipX,
                    animData.flipY == null ? false : animData.flipY
                );
            }

            if (animData.offsetX != null && animData.offsetY != null) {
                animOffsets.set(animData.name, {x: animData.offsetX, y: animData.offsetY});
            }
        }
    }
}