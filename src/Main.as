package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getTimer;

import ice.tools.display.prerenderer.JellyAnimation;
import ice.tools.display.tools.FPSDisplay;
import ice.wordox.gfx.JellyBirthAnimation;
import ice.wordox.gfx.JellyBreathingAnimation;
import ice.wordox.gfx.JellyDropAnimation;
import ice.wordox.gfx.JellyMovingAnimation;
import ice.wordox.gfx.JellyOutAnimation;
import ice.wordox.gfx.JellyOverAnimation;
import ice.wordox.gfx.JellyStealingAnimation;
import ice.wordox.gfx.JellyWinAnimation;

[SWF(frameRate="32", width="1024", height="1024")]
public class Main extends Sprite {
    public function Main () {

        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.stage.addEventListener (MouseEvent.CLICK, onClick);

        displayPrerendered();
        _fpsDisplay = new FPSDisplay();
        this.addChild(_fpsDisplay);

    }

    private function onClick (event : Event) : void {
        switchDisplayMode ();
        for (var animIndex : uint = 0; animIndex < _jelliesAnimations.length; animIndex++) {
            _jelliesAnimations[animIndex].playerSeatId = Math.random () * 4;
        }

        this.addChild(_fpsDisplay);
    }

    private function switchDisplayMode():void {
        while(numChildren > 0) {
            removeChildAt(0);
        }

        if (_currentDisplayMode == 0) {
            displayPrerendered ();
            return;
        }
        displayNormal ();
    }

    private function displayNormal():void {
        _currentDisplayMode = 0;

        var animation : DisplayObject;
        var playersColors : Vector.<int> = new Vector.<int> ();
        playersColors.push (0xDD2222);
        playersColors.push (0x22DD22);
        playersColors.push (0x2222DD);
        playersColors.push (0x228888);

        var firstCreationEnd : int;


        for (var colIndex : uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex : uint = 0; rowIndex < SIZE; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                    var startCreation : int = getTimer ();
                    trace ("Start creation at " + startCreation);
                }

                var jellyClass : Class = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)];
                animation = new jellyClass();

                if (colIndex == 0 && rowIndex == 0) {
                    firstCreationEnd = getTimer ();
                    trace ("First creation duration " + (firstCreationEnd - startCreation) + "ms");
                }
                animation.x = colIndex * 50;
                animation.y = rowIndex * 50;
                addChild (animation);
            }
        }

        trace ("All adding to scene duration " + (getTimer () - firstCreationEnd) + "ms");

    }

    private function displayPrerendered():void {
        _currentDisplayMode = 1;

        _jelliesAnimations =  new Vector.<JellyAnimation> ();

        var animation : JellyAnimation;
        var playersColors : Vector.<int> = new Vector.<int> ();
        playersColors.push (0xDD2222);
        playersColors.push (0x22DD22);
        playersColors.push (0x2222DD);
        playersColors.push (0x228888);

        var firstCreationEnd : int;

        for (var colIndex : uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex : uint = 0; rowIndex < SIZE; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                    var startCreation : int = getTimer ();
                    trace ("Start creation at " + startCreation);
                }

                var jellyClass : Class = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)];
                animation = new JellyAnimation (jellyClass, Math.random () * 29 + 1, playersColors);

                if (colIndex == 0 && rowIndex == 0) {
                    firstCreationEnd = getTimer ();
                    trace ("First creation duration " + (firstCreationEnd - startCreation) + "ms");
                }
                animation.playerSeatId = Math.random () * 4;
                animation.x = colIndex * 50;
                animation.y = rowIndex * 50;
                addChild (animation);
                _jelliesAnimations.push (animation);
            }
        }

        trace ("All adding to scene duration " + (getTimer () - firstCreationEnd) + "ms");

    }

    private var _jelliesAnimations : Vector.<JellyAnimation>
            = new Vector.<JellyAnimation> ();

    private const _jelliesClass : Array = [JellyBirthAnimation, JellyDropAnimation, JellyMovingAnimation, JellyOutAnimation, JellyOverAnimation
    , JellyBreathingAnimation, JellyStealingAnimation, JellyWinAnimation];

    private var _currentDisplayMode : int = 0;
    private var _fpsDisplay:FPSDisplay;
    private static const SIZE:int = 20;
}

}
