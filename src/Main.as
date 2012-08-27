package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.utils.getTimer;

import ice.game.wordox.views.letters.EJellyAnimation;
import ice.game.wordox.views.letters.JellyAnimationCatalogue;
import ice.tools.display.prerenderer.IPrerenderedMovieClip;
import ice.tools.display.prerenderer.JellyAnimation;
import ice.tools.display.prerenderer.PrerenderedMovieClipEvent;
import ice.tools.display.prerenderer.PrerenderedMovieClipWorker;
import ice.tools.display.tools.FPSDisplay;
import ice.wordox.gfx.JellyWinAnimation;

[SWF(frameRate="32", width="1050", height="1050")]
public class Main extends Sprite {
    public function Main() {

        this.stage.scaleMode = StageScaleMode.NO_SCALE;


        _fpsDisplay = new FPSDisplay();
        this.addChild(_fpsDisplay);
        _waitingAnimation = new JellyWinAnimation();
        _waitingAnimation.x = 50;
        _waitingAnimation.y = 50;
        addChild(_waitingAnimation);

        initializeJellyCatalogue();

    }

    private function initializeJellyCatalogue():void {
        _prerenderedMovieClipWorker = new PrerenderedMovieClipWorker(this, 15);
        _jellyCatalogue = new JellyAnimationCatalogue(_prerenderedMovieClipWorker);
        _jellyCatalogue.addEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);
        this.addEventListener(Event.ENTER_FRAME, onEnterFrameRefreshAnimationCount);
        _jellyCatalogue.initializeAllMovieclip();
        _fpsDisplay.totalAnimationCount = _jellyCatalogue.cataloguetotalSize;
    }

    private function onEnterFrameRefreshAnimationCount(event:Event):void {
        _fpsDisplay.currentAnimationsCount = _jellyCatalogue.catalogueCurrentSize;
    }

    private function onPrerenderEnd(event:PrerenderedMovieClipEvent):void {
        _jellyCatalogue.removeEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);
        _fpsDisplay.currentAnimationsCount = _jellyCatalogue.catalogueCurrentSize;
        this.removeEventListener(Event.ENTER_FRAME, onEnterFrameRefreshAnimationCount);
        if (this.contains(_waitingAnimation)) {
            removeChild(_waitingAnimation);
        }
        displayPrerendered();
    }

    private function onClick(event:Event):void {
        switchDisplayMode();
        for (var animIndex:uint = 0; animIndex < _jelliesAnimations.length; animIndex++) {
            _jelliesAnimations[animIndex].playerSeatId = Math.random() * 4;
        }

        this.addChild(_fpsDisplay);
    }

    private function switchDisplayMode():void {
        while (numChildren > 0) {
            removeChildAt(0);
        }

        if (_currentDisplayMode == 0) {
            displayPrerendered();
            return;
        }
        displayNormal();
    }

    private function displayNormal():void {
        _currentDisplayMode = 0;

        var animation:DisplayObject;
        var playersColors:Vector.<int> = new Vector.<int>();
        playersColors.push(0xDD2222);
        playersColors.push(0x22DD22);
        playersColors.push(0x2222DD);
        playersColors.push(0x228888);

        var firstCreationEnd:int;


        for (var colIndex:uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex:uint = 0; rowIndex < SIZE; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                    var startCreation:int = getTimer();
                    trace("Start creation at " + startCreation);
                }

                var jellyClass:Class = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)].animationClass;
                animation = new jellyClass();

                if (colIndex == 0 && rowIndex == 0) {
                    firstCreationEnd = getTimer();
                    trace("First creation duration " + (firstCreationEnd - startCreation) + "ms");
                }
                animation.x = colIndex * 50;
                animation.y = rowIndex * 50;
                addChild(animation);
            }
        }

        trace("All adding to scene duration " + (getTimer() - firstCreationEnd) + "ms");

    }

    private function displayPrerendered():void {
        _currentDisplayMode = 1;

        var firstCreationEnd:int;
        var animation:IPrerenderedMovieClip;

        for (var colIndex:uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex:uint = 0; rowIndex < SIZE; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                    var startCreation:int = getTimer();
                    trace("Start creation at " + startCreation);
                }

                var jellyClass:Class = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)].animationClass;
                animation = _jellyCatalogue.getJellyAnimation(jellyClass, (Math.random() * 4), Math.random() * 29 + 1);

                if (colIndex == 0 && rowIndex == 0) {
                    firstCreationEnd = getTimer();
                    trace("First creation duration " + (firstCreationEnd - startCreation) + "ms");
                }
                DisplayObject(animation).y = rowIndex * 50 + 50;
                DisplayObject(animation).x = colIndex * 50 + 50;
//                    DisplayObject(animation).scaleX = DisplayObject(animation).scaleY = 0.5;
                addChild(DisplayObject(animation));
            }
        }

        return;
    }

    private var _jelliesAnimations:Vector.<JellyAnimation>
            = new Vector.<JellyAnimation>();

    [ArrayElementType("ice.game.wordox.views.letters.EJellyAnimation")]
    private const _jelliesClass:Array =
            [EJellyAnimation.BIRTH_ANIMATION
                , EJellyAnimation.DROP_ANIMATION
                , EJellyAnimation.MOVING_ANIMATION
                , EJellyAnimation.OUT_ANIMATION
                , EJellyAnimation.OVER_ANIMATION
                , EJellyAnimation.BREATHING_ANIMATION
                , EJellyAnimation.STEALING_ANIMATION
                , EJellyAnimation.WIN_ANIMATION];

    private var _currentDisplayMode:int = 0;
    private var _fpsDisplay:FPSDisplay;
    private static const SIZE:int = 40;

    private var _jellyCatalogue:JellyAnimationCatalogue;
    private var _prerenderedMovieClipWorker:PrerenderedMovieClipWorker;
    private var _waitingAnimation:DisplayObject;
}

}
