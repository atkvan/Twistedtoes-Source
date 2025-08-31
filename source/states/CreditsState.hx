package states;

import objects.AttachedSprite;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;

import flixel.addons.display.FlxRuntimeShader;
import sys.io.File;
import openfl.filters.ShaderFilter;
import haxe.Json;


class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;

	var background:FlxSprite;
	var grid:FlxBackdrop;
	var desc:FlxText;
	var info:FlxText;
	var name:FlxText;

	var iconGroup:FlxTypedGroup<IconStuff>;

	var dataName:Array<String>;
	var dataIcon:Array<String>;
	var dataDesc:Array<String>;
	var dataInfo:Array<String>;

	var allow:Bool = true;

	var iconPath:String = "credits/";
	var menuPath:String = "creditsmenu/";

	override function create() {

		var json:String = File.getContent('assets/shared/creds.json');
		var data:Array<CreditInfo> = haxe.Json.parse(json);

		dataName = [];
		dataIcon = [];
		dataDesc = [];
		dataInfo = [];

		iconGroup = new FlxTypedGroup<IconStuff>();

		for(i in data) {
			dataName.push(i.name);
			dataIcon.push(i.icon);
			dataDesc.push(i.desc);
			dataInfo.push(i.info);
		}

		for(i in 0...dataIcon.length) {
			var iconThing = new IconStuff();
			iconThing.loadGraphic(Paths.image(iconPath + dataIcon[i]));
			iconThing.screenCenter();
			iconThing.ID = i;
			iconGroup.add(iconThing);

			if (iconThing.width != 350 && iconThing.height != 350) {
				trace('RESIZING!');
				iconThing.scale.set(350 / iconThing.width, 350 / iconThing.height);
			}

		}

		background = new FlxSprite().loadGraphic(Paths.image(menuPath+'menuBGCredits'));
		background.screenCenter();
		background.scrollFactor.set();
		background.updateHitbox();
		add(background);
		
		grid = new FlxBackdrop(Paths.image(menuPath+'grid'));
		grid.velocity.set(70, 75);
		grid.color = 0xFF1f3329;
		grid.scrollFactor.set(0, 0);
	    add(grid);

		add(iconGroup);

		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image(menuPath+'menubars'));
		bars.scrollFactor.set();
		bars.updateHitbox();
		bars.screenCenter();
		add(bars);

		desc = new FlxText(50, -100, FlxG.width - 65, dataDesc[curSelected]);
        desc.setFormat("vcr.ttf", 25, 0xffffff, "center");
        desc.screenCenter();
        desc.y += 275;
		//desc.scale.x = Math.min(1, 1900 / desc.width);
		//desc.snapToPosition();
        desc.setFormat(Paths.font("vcr.ttf"), 32);
        add(desc);
		
		info = new FlxText(50, 50, FlxG.width - 100, dataInfo[curSelected]);
        info.screenCenter(X);
        info.setFormat(null, 40, 0xffffff, "center");
        info.setFormat(Paths.font("vcr.ttf"), 32);
        add(info);

		name = new FlxText(50, 50, FlxG.height - 15, dataName[curSelected]);
		name.screenCenter(X);
		name.setFormat(null, 35, 0xffffff, "center");
		name.setFormat(Paths.font('vcr.ttf'), 25);
		name.y += 45;
		add(name);

		persistentUpdate = true;

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {

		if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && allow) {
            changeSelection(controls.UI_LEFT_P ? -1 : 1);
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

		if(controls.BACK){
			allow = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}


	//yoink
	function changeSelection(i:Int = 0){
		curSelected += i;

		if(curSelected >= dataDesc.length)
			curSelected = 0;

		if(curSelected < 0)
			curSelected = dataDesc.length - 1;
		
		name.text = dataName[curSelected]; 
		desc.text = dataDesc[curSelected];
		info.text = dataInfo[curSelected]; 
	
		var change = 0;
		for (item in iconGroup) {
			item.posX = change++ - curSelected;
			item.alpha = (item.ID == curSelected) ? 1 : 0.65;
		}

	}

}

typedef CreditInfo = {
	name:String,
	icon:String,
	desc:String,
	info:String
}

//yoink
class IconStuff extends FlxSprite {
    public var balls:Float = 9;
    public var posX:Float = 0;
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, boundTo(elapsed * balls, 0, 1));
    }
}
//yoink
function boundTo(value:Float, min:Float, max:Float):Float {
    var newValue:Float = value;
    if(newValue < min) newValue = min;
    else if(newValue > max) newValue = max;
    return newValue;
}