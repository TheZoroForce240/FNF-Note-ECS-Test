import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Bytes;
import openfl.display.BitmapData;
import sys.FileSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.FlxGraphic;
import lime.media.AudioBuffer;
import flixel.util.FlxDestroyUtil;

class Paths
{
    public static var libraryPaths = ["assets/"];

    private static var _graphics:Map<String, FlxGraphic> = [];
   // private static var _frames:Map<String, FlxFramesCollection> = [];
    private static var _sounds:Map<String, AudioBuffer> = [];
    private static var _fonts:Map<String, Dynamic> = [];
    private static var _texts:Map<String, String> = [];

    private static inline function clearGraphics() {
        for (name => obj in _graphics) {
            if (obj != null) {
                obj.destroy();
                _graphics[name] = null;
            }
            _graphics.remove(name);
        }
    }
    private static inline function clearAudio() {
        for (name => obj in _sounds) {
            if (obj != null) {
                obj.dispose();
                _sounds[name] = null;
            }
            _sounds.remove(name);
        }
    }
    private static inline function clearFonts() {
        for (name => obj in _fonts) {
            if (obj != null) {
                _fonts[name] = null;
            }
            _fonts.remove(name);
        }
    }
    private static inline function clearTexts() {
        for (name => obj in _texts) {
            if (obj != null) {
                _texts[name] = null;
            }
            _texts.remove(name);
        }
    }
    public static function clearCache() {
        clearTexts();
        clearFonts();
        clearAudio();
        clearGraphics();
        FlxG.bitmap.reset();
        #if cpp
		cpp.vm.Gc.enable(true);
		#end
		#if sys
		openfl.system.System.gc();	
		#end
    }

    public static function exists(path:String) {
        for (lib in libraryPaths) {
            if (FileSystem.exists(lib+path))
                return true;
        }
        return false;
    }
    private static function getPath(path:String) {
        for (lib in libraryPaths) {
            if (FileSystem.exists(lib+path))
                return lib+path;
        }
        return path;
    }

    public static function loadGraphic(path:String) : FlxGraphic {
        if (_graphics.exists(path)) return _graphics.get(path);

        if (!exists(path)) {
            trace("Graphic could not be found at '" + path + "'");
            return null;
        }

        var fullPath = getPath(path);
        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(fullPath), false, null, false);
        _graphics.set(path, graphic);
        return graphic;
    }
    public static function loadSound(path:String) {
        if (_sounds.exists(path)) return _sounds.get(path);
        
        if (!exists(path)) {
            trace("Sound could not be found at '" + path + "'");
            return null;
        }

        var fullPath = getPath(path);
        var audioBuffer:AudioBuffer = AudioBuffer.fromFile(fullPath);
        _sounds.set(path, audioBuffer);
        return audioBuffer;
    }
    public static function loadText(path:String) {
        if (_texts.exists(path)) return _texts.get(path);
        
        if (!exists(path)) {
            trace("Text could not be found at '" + path + "'");
            return null;
        }

        var fullPath = getPath(path);
        var bytes:Bytes = Bytes.fromFile(fullPath);
        var text:String = bytes.getString(0, bytes.length);
        _texts.set(path, text);
        return text;
    }

    public inline static function imagePath(path:String) { return "images/"+path+".png"; }
    public inline static function animationPath(path:String) { return "images/"+path+"_meta.json"; }
    public inline static function sparrowXMLPath(path:String) { return "images/"+path+".xml"; }
    public inline static function soundPath(path:String) { return "sounds/"+path+".ogg"; }
    public inline static function textPath(path:String) { return "data/"+path+".txt"; }

    public inline static function chartPath(song:String, diff:String) { return 'data/charts/$song/$song-$diff.json'; }
    public inline static function instPath(song:String) { return "songs/"+song+"/Inst.ogg"; }
    public inline static function voicesPath(song:String) { return "songs/"+song+"/Voices.ogg"; }

    public inline static function image(path:String) { return loadGraphic(imagePath(path)); }
    public inline static function sound(path:String) { return loadSound(soundPath(path)); }
    public inline static function text(path:String) { return loadText(textPath(path)); }

    public static function loadSpriteAnimations(sprite:FlxSprite, path:String) {
        var graphicPath = imagePath(path);
        var animationsPath = animationPath(path);
        var xmlPath = sparrowXMLPath(path);

        if (!exists(graphicPath) || !exists(xmlPath)) {
            trace("Animated Sprite could not be found at '" + path + "'");
            return;
        }

        sprite.frames = FlxAtlasFrames.fromSparrow(loadGraphic(graphicPath), loadText(xmlPath));
        sprite.animation = FlxDestroyUtil.destroy(sprite.animation);
        var controller = new AnimationController(sprite);
        sprite.animation = controller;
        if (exists(animationsPath)) {
            controller.loadAnimationJson(loadText(animationsPath));
        }
    }
}