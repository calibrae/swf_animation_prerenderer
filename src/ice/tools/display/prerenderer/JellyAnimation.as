/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 20/07/12
 * Time: 19:44
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.Dictionary;

public class JellyAnimation extends Sprite {

    public function JellyAnimation (animationClass : Class, playersColor : Vector.<int>) {
        _animationClass = animationClass;
        if (_prerenderedForClass[animationClass] == null) {
            initializeTextures (animationClass, playersColor);
        }
        this.addChild(_prerenderedForClass[animationClass][0].clone());
    }

    public function set playerSeatId (playerSeatId : int) : void {
        while (this.numChildren > 0) {
            var removed : DisplayObject = this.removeChildAt(0);
            if (removed is PrenrederedMovieClip) {
                PrenrederedMovieClip(removed).dispose();
            }
        }
        this.addChild(_prerenderedForClass[_animationClass][playerSeatId].clone());
    }

    private static function initializeTextures (animationClass : Class, playersColor : Vector.<int>) : void {
        var prenderedMovieClip : Vector.<PrenrederedMovieClip> = new Vector.<PrenrederedMovieClip> ();
        _overlaySprite = new Sprite();

        var jellyAnimation : MovieClip = new animationClass ();
        try {
            jellyAnimation ["overlayClip"].addChild(_overlaySprite);
        } catch (error : Error) {
            return;
        }
        var animationBounds : IAnimationBound = MovieClipConversionUtils.getMaxSize (jellyAnimation);


        for (var i : uint = 0; i < playersColor.length; i++) {
            updateOverlayColor (playersColor[i]);
            prenderedMovieClip.push(MovieClipConversionUtils.generatePrerenderedMovieClip(jellyAnimation, animationBounds));
        }
        _prerenderedForClass[animationClass] = prenderedMovieClip;
        _overlaySprite = null;
    }

    private static function updateOverlayColor (color : uint) : Graphics {
        var graphics : Graphics = _overlaySprite.graphics;
        graphics.clear ();
        graphics.beginFill (color);
        graphics.moveTo (-1, -15);
        graphics.lineTo (-1, _LETTER_SIZE + 30);
        graphics.lineTo (_LETTER_SIZE + 2, _LETTER_SIZE + 30);
        graphics.lineTo (_LETTER_SIZE + 2, -15);
        graphics.endFill ();
        return graphics;
    }
    private var _animationClass : Class;

    private static var _overlaySprite : Sprite;

    private static const _prerenderedForClass : Dictionary = new Dictionary();
    private static const _LETTER_SIZE : int = 45;
}
}
