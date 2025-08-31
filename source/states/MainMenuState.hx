package states;

import backend.Song;
import backend.Highscore;
import backend.WeekData;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;


class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var buttons:Array<FlxSprite> = [];

	var camFollow:FlxObject;

	var menuButtons:FlxSprite;

	var play:FlxSprite;
	var freeplay:FlxSprite;
	var option:FlxSprite;
	var credits:FlxSprite;
	var discord:FlxSprite;

	var corner:Int = 750;

	//var shader:FlxShader;
	var pathShader = "assets/shaders/";

	override function create()
	{
		//FlxG.mouse.visible = true;

		trace(Std.int(FlxG.camera.zoom));
		Paths.clearUnusedMemory();
		Paths.clearStoredMemory();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("TWISTEDTOES | Menu", null);
		#end

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		ClientPrefs.loadPrefs();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-180).loadGraphic(Paths.image('menu/bg1'));
		bg.screenCenter();
		add(bg);

		//insert(members.indexOf(bg)+1, rain);
		
		var panel:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menu/panel'));
		add(panel);

		for(a in [bg, panel]) {
			a.antialiasing = ClientPrefs.data.antialiasing;
			a.updateHitbox();
			a.scrollFactor.set();
		}

		play = new FlxSprite(875, 75).loadGraphic(Paths.image('menu/play'));
		play.scale.set(0.91, 0.91);

		freeplay = new FlxSprite(845, play.y + play.height + 30).loadGraphic(Paths.image('menu/freeplay'));
		freeplay.scale.set(0.91, 0.91);

		option = new FlxSprite(835, freeplay.y + freeplay.height + 30).loadGraphic(Paths.image('menu/options'));
		option.scale.set(0.91, 0.91);

		credits = new FlxSprite(875, option.y + option.height + 10).loadGraphic(Paths.image('menu/credits'));
		credits.scale.set(0.4, 0.4);

		discord = new FlxSprite(1025, option.y + option.height + 10).loadGraphic(Paths.image('menu/discord'));
		discord.scale.set(0.4, 0.4);

		for (num => button in [play, freeplay, option, credits, discord]) {
			button.scrollFactor.set();
			button.updateHitbox();
			button.antialiasing = ClientPrefs.data.antialiasing;
			buttons.push(button);
			add(button);
		}


		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		super.create();

		FlxG.camera.follow(camFollow, null, 9);
		
		if(FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.3);

		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
	}

	var selectedSomethin:Bool = false;

	var hover:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
			
		
				if(FlxG.mouse.justPressed)
					for(hello in buttons) {
						if(FlxG.mouse.overlaps(hello))
						switch(buttons.indexOf(hello)) {
							case 0: goToSong('twistedtoes');
							case 1: MusicBeatState.switchState(new FreeplayState());
							case 2: MusicBeatState.switchState(new OptionsState());
							case 3: MusicBeatState.switchState(new CreditsState());
							case 4: trace('went to discord??'); CoolUtil.browserLoad("https://discord.gg/SkQa6skFuV");
						}
					}
				for (i => boo in buttons) {
					if (FlxG.mouse.overlaps(boo) && i < 3) {
						boo.scale.set(0.85, 0.85);
					}
					else if (FlxG.mouse.overlaps(boo) && i > 2) {
						boo.scale.set(0.36, 0.36);
					}
					if (!FlxG.mouse.overlaps(boo) && i < 3) {
						boo.scale.set(0.91, 0.91);
					}
					else if (!FlxG.mouse.overlaps(boo) && i > 2) {
						boo.scale.set(0.4, 0.4);
					}
				}


			super.update(elapsed);

	
	}

    function playMusic() {
		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0); //so it plays once lol
	}

	function goToSong(?name:String = null)
		{
			if(name == null || name.length < 1)
				name = PlayState.SONG.song;
	
			var poop = Highscore.formatSong(name, 2);
			PlayState.SONG = Song.loadFromJson(poop, name);
	
			LoadingState.loadAndSwitchState(new PlayState());
		}
}