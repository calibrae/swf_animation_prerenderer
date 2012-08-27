package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getTimer;

import ice.game.wordox.views.letters.EJellyAnimation;
import ice.game.wordox.views.letters.JellyAnimation;
import ice.game.wordox.views.letters.JellyAnimationCatalogue;
import ice.game.wordox.views.progressbar.Progressbar;
import ice.tools.display.prerenderer.PrerenderedMovieClipEvent;
import ice.tools.display.prerenderer.PrerenderedMovieClipWorker;
import ice.tools.display.tools.FPSDisplay;
import ice.wordox.gfx.JellyWinAnimation;

[SWF(frameRate="32", width="2500", height="2500")]
public class Main extends Sprite {
    public function Main() {

        this.stage.scaleMode = StageScaleMode.NO_SCALE;

        _fpsDisplay = new FPSDisplay();
        this.addChild(_fpsDisplay);
        _waitingAnimation = new JellyWinAnimation();
        _waitingAnimation.x = 50;
        _waitingAnimation.y = 50;
        addChild(_waitingAnimation);
        _progressbar = new Progressbar(450, 30, "Calcul des animations en cours:", true);
        _progressbar.x = 250;
        _progressbar.y = 15;
        this.addChild(_progressbar);

        initializeJellyCatalogue();
    }

    private function initializeJellyCatalogue():void {
        _prerenderingStartTime = getTimer();
        _prerenderedMovieClipWorker = new PrerenderedMovieClipWorker(this, 20);
        _jellyCatalogue = new JellyAnimationCatalogue(_prerenderedMovieClipWorker);
        _jellyCatalogue.addEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);
        this.addEventListener(Event.ENTER_FRAME, onEnterFrameRefreshAnimationCount);
        _jellyCatalogue.initializeAllMovieclip();
    }

    private function onEnterFrameRefreshAnimationCount(event:Event):void {
        _fpsDisplay.currentGenerationTime = getTimer() - _prerenderingStartTime;
        _progressbar.updateValue(_jellyCatalogue.catalogueCurrentSize, _jellyCatalogue.cataloguetotalSize);
    }

    private function onPrerenderEnd(event:PrerenderedMovieClipEvent):void {
        _jellyCatalogue.removeEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);

        _fpsDisplay.currentGenerationTime = getTimer() - _prerenderingStartTime;
        _progressbar.updateValue(_jellyCatalogue.catalogueCurrentSize, _jellyCatalogue.cataloguetotalSize);

        this.removeEventListener(Event.ENTER_FRAME, onEnterFrameRefreshAnimationCount);
        if (this.contains(_waitingAnimation)) {
            removeChild(_waitingAnimation);
        }
        displayPrerendered();
        this.addEventListener(MouseEvent.CLICK, onClick);
    }

    private function onClick(event:Event):void {
        addRows(1);
        return;
        for (var animIndex:uint = 0; animIndex < _jelliesAnimations.length; animIndex++) {
            _jelliesAnimations[animIndex].updateAnimation(
                    _jelliesAnimations[animIndex].jellyAnimation
            //        _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)]
                    , Math.random() * 4);
        }

    }

    private function displayPrerendered () : void {
        addRows(1);
    }

    private function addRows(rowsCount : int):void {

        var firstCreationEnd:int;
        var animation:JellyAnimation;

        for (var colIndex:uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex:uint = _currentRowsCount; rowIndex < _currentRowsCount + rowsCount; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                    var startCreation:int = getTimer();
                    trace("Start creation at " + startCreation);
                }

                var jellyAnimation:EJellyAnimation = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)];
                animation = _jellyCatalogue.getJellyAnimation(Math.random() * 29 + 1);
                animation.updateAnimation(jellyAnimation, Math.random() * 4);

                if (colIndex == 0 && rowIndex == 0) {
                    firstCreationEnd = getTimer();
                    trace("First creation duration " + (firstCreationEnd - startCreation) + "ms");
                }
                (animation).y = rowIndex * 50 + 50;
                (animation).x = colIndex * 50 + 50;
                addChild((animation));
                _jelliesAnimations.push(animation);
            }
        }
        _currentRowsCount += rowsCount;
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

    private var _fpsDisplay:FPSDisplay;
    private static const SIZE:int = 20;
    private var _currentRowsCount : int = 0;


    private var _prerenderingStartTime : Number;
    private var _jellyCatalogue:JellyAnimationCatalogue;
    private var _prerenderedMovieClipWorker:PrerenderedMovieClipWorker;
    private var _waitingAnimation:DisplayObject;
    private var _progressbar:Progressbar;
}

}
