package;

import openfl.media.Sound;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import game.*;

class PlayState extends FlxState
{

	var testSprite:FlxSprite;
	var strumline:Strumline;
	var strumline2:Strumline;
	var test:FlxText;

	var inst:FlxSound;
	var vocals:FlxSound;

	var song:String = "ruckus";
	var diff:String = "voiid";

	override public function create()
	{
		super.create();

		testSprite = new FlxSprite();
		testSprite.loadGraphic(Paths.image("glunger"));
		testSprite.screenCenter();
		testSprite.y += 100;
		add(testSprite);

		strumline = new Strumline();
		strumline.setup(FlxG.width * 0.25, strumline.downscroll ? 550 : 50);
		add(strumline);

		strumline2 = new Strumline();
		strumline2.setup(FlxG.width * 0.75, strumline2.downscroll ? 550 : 50);
		add(strumline2);

		strumline2.botplay = false;

		ChartParser.loadNotesFromJson(Paths.chartPath(song, diff), strumline, strumline2);

		inst = FlxG.sound.load(Sound.fromAudioBuffer(Paths.loadSound(Paths.instPath(song))));
		vocals = FlxG.sound.load(Sound.fromAudioBuffer(Paths.loadSound(Paths.voicesPath(song))));

		test = new FlxText(0, 100, 0, "yea", 32);
		add(test);

		Conductor.songPosition = -2000;
	}

	override public function update(elapsed:Float) {
		Conductor.songPosition += FlxG.elapsed * 1000;
		super.update(elapsed);

		if (inst.playing) {
			if (needsResync(inst) || needsResync(vocals)) {
				vocals.pause();
				inst.play();
				Conductor.songPosition = inst.time;
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
		if (Conductor.songPosition >= 0 && !inst.playing) {
			inst.play();
			vocals.play();
		}



		if (FlxG.keys.justPressed.SPACE) {
			strumline.downscroll = !strumline.downscroll;
			strumline2.downscroll = strumline.downscroll;

			for (strum in strumline.members) {
				strum.y = strumline.downscroll ? 550 : 50;
			}
			for (strum in strumline2.members) {
				strum.y = strumline2.downscroll ? 550 : 50;
			}
		}
			

		test.text = (strumline.notes.notesRendered + strumline2.notes.notesRendered) + " notes rendered";
	}

	private inline function needsResync(sound:FlxSound) {
		return Math.abs(sound.time - Conductor.songPosition) > 25;
	}
}
