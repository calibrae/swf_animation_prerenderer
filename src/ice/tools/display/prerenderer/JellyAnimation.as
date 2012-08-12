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

public class JellyAnimation extends Sprite {

    public function JellyAnimation (animationClass : Class, playersColor : Vector.<int>) {
        if (_prenderedMovieClip == null) {
            initializeTextures (animationClass, playersColor);
        }
        this.addChild(_prenderedMovieClip[0].clone());
    }

    public function set playerSeatId (playerSeatId : int) : void {
        while (this.numChildren > 0) {
            var removed : DisplayObject = this.removeChildAt(0);
            if (removed is PrenrederedMovieClip) {
                PrenrederedMovieClip(removed).dispose();
            }
        }
        this.addChild(_prenderedMovieClip[playerSeatId].clone());
    }

    private static function initializeTextures (animationClass : Class, playersColor : Vector.<int>) : void {
        _prenderedMovieClip = new Vector.<PrenrederedMovieClip> ();
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
            _prenderedMovieClip.push(MovieClipConversionUtils.generatePrerenderedMovieClip(jellyAnimation, animationBounds));
        }
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

    private static var _overlaySprite : Sprite;

    private static var _prenderedMovieClip : Vector.<PrenrederedMovieClip>;
    private static const _LETTER_SIZE : int = 45;
}
}
