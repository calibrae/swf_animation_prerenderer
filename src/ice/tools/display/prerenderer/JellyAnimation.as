/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 20/07/12
 * Time: 19:44
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

public class JellyAnimation extends Sprite {

    public function JellyAnimation(animationClass:Class, letterCode:int, playersColor:Vector.<int>) {
        _animationClass = animationClass;
        _letterCode = letterCode;
        if (_prerenderedForClass[animationClass] == null) {
            initializeTextures(letterCode, animationClass, playersColor);
        }
        this.addChild(_prerenderedForClass[animationClass][0].clone());

        _letterContainer = new Sprite();
        this.addChild(_letterContainer);
        var letterClass:Class = ApplicationDomain.currentDomain.getDefinition(_letterClassPrefix + letterCode) as Class;
        var letterClip:Sprite = new letterClass();
        _letterContainer.addChild(letterClip);
        _letterContainer.cacheAsBitmap = true;
        letterClip.mouseChildren = letterClip.mouseEnabled = _letterContainer.mouseChildren = _letterContainer.mouseEnabled = false;
        this.mouseChildren = false;
    }

    public function set playerSeatId(playerSeatId:int):void {
        while (this.numChildren > 0) {
            var removed:DisplayObject = this.removeChildAt(0);
            if (removed is PrerenderedMovieClip) {
                PrerenderedMovieClip(removed).dispose();
            }
        }
        var newMovieClip: PrerenderedMovieClip = _prerenderedForClass[_animationClass][playerSeatId].clone();
        this.addChild(newMovieClip);
        newMovieClip.play();
        this.addChild(_letterContainer);
    }

    private static function initializeTextures(letterCode:int, animationClass:Class, playersColor:Vector.<int>):void {
        var prenderedMovieClip:Vector.<PrerenderedMovieClip> = new Vector.<PrerenderedMovieClip>();
        _overlaySprite = new Sprite();

        var jellyAnimation:MovieClip = new animationClass();
        try {
            jellyAnimation ["overlayClip"].addChild(_overlaySprite);
        } catch (error:Error) {
            return;
        }

        try {
            for (var i:uint = 0; i < jellyAnimation.letterContainer.numChildren; i++) {
                var clip:DisplayObject = DisplayObjectContainer(jellyAnimation.letterContainer).getChildAt(i);
                clip.visible = false;
                clip.alpha = 0;
            }
        } catch (error:Error) {
//            Logger.warning(this, "Error while setting the letter on the animation", Version.getInstance());
        }


        var animationBounds:IAnimationBound = MovieClipConversionUtils.getMaxSize(jellyAnimation);
        // Name of generate animation: [qualifiedClassName of animation]_[letter_index]

        for (var iPlayer:uint = 0; iPlayer < playersColor.length; iPlayer++) {
            updateOverlayColor(playersColor[iPlayer]);
            prenderedMovieClip.push(MovieClipConversionUtils.generatePrerenderedMovieClip(jellyAnimation, animationBounds));
            _prerenderedForClass[animationClass] = prenderedMovieClip;
        }
        _overlaySprite = null;
    }

    private static function updateOverlayColor(color:uint):Graphics {
        var graphics:Graphics = _overlaySprite.graphics;
        graphics.clear();
        graphics.beginFill(color);
        graphics.moveTo(-1, -15);
        graphics.lineTo(-1, _LETTER_SIZE + 30);
        graphics.lineTo(_LETTER_SIZE + 2, _LETTER_SIZE + 30);
        graphics.lineTo(_LETTER_SIZE + 2, -15);
        graphics.endFill();
        return graphics;
    }

    private var _animationClass:Class;
    private var _letterCode:int;
    private var _letterContainer:Sprite;

    private static var _overlaySprite:Sprite;

    private static const _prerenderedForClass:Dictionary = new Dictionary();

    private static const _LETTER_SIZE:int = 45;

    private static const _letterClassPrefix:String = "ice.wordox.gfx.LetterCode";
    private static const _LETTERS_CODES:Array = [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        , 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
        , 21, 22, 23, 24, 25, 26, 27, 28, 29, 30
        , 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009
    ]
}
}
