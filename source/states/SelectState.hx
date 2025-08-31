package states;

import flixel.FlxG;
import flixel.math.FlxMath;

class SelectState extends MusicBeatState {
	
	var dir:String = "selectmenu/"
	var selected:Bool = false;

	var background:FlxSprite;


	override function create() {


		background = new FlxSprite().loadGraphic(Paths.image(dir+'bg'));
		background.scrollFactor.set();
		background.screenCenter();
		add(background);


	}



}