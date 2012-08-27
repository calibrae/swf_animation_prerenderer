/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 27/08/12
 * Time: 11:13
 * To change this template use File | Settings | File Templates.
 */
package ice.game.wordox.views.letters {
import flash.display.Sprite;
import flash.utils.getQualifiedClassName;

import ice.tools.display.prerenderer.CompositePrerenderedClip;
import ice.tools.display.prerenderer.PrerenderedMovieClipWorker;

public class JellyAnimation extends Sprite {

    public function JellyAnimation(animationCatalogue : PrerenderedMovieClipWorker, letterIndex : int) {
        _animationCatalogue = animationCatalogue;
        _letterIndex = letterIndex;
        this.addChild(_internalMovieClip);
        _internalMovieClip.mouseEnabled = false;
        _internalMovieClip.mouseChildren = false;
    }


    public function get jellyAnimation():EJellyAnimation {
        return _jellyAnimation;
    }

    public function updateAnimation (jellyAnimation : EJellyAnimation, playerSeat : int) : void {
        // If only the player has changed, we will continue playing animation from the actual frame:
        var startFrameIndex : int = 0;

        if (jellyAnimation == _jellyAnimation) {
            startFrameIndex = _internalMovieClip.currentFrame;
        } else {
            _jellyAnimation = jellyAnimation;
        }

        _internalMovieClip.dispose();
        _playerSeat = playerSeat;

         var woxAnimationName:String = getQualifiedClassName(jellyAnimation.animationClass)+ "_"  + playerSeat; //  + "_ice.wordox.gfx::LetterCode15";//
         var letterAnimationName:String = getQualifiedClassName(jellyAnimation.animationClass)+ "_LETTER" + _letterIndex; //  + "_ice.wordox.gfx::LetterCode15";//

        _internalMovieClip.addPrerenderedChild(_animationCatalogue.getAnimation(woxAnimationName).clone());
        _internalMovieClip.addPrerenderedChild(_animationCatalogue.getAnimation(letterAnimationName).clone());
        _internalMovieClip.gotoFrame(startFrameIndex);
        _internalMovieClip.play();
    }

    private var _internalMovieClip : CompositePrerenderedClip = new CompositePrerenderedClip();
    private var _playerSeat : int;
    private var _jellyAnimation : EJellyAnimation;
    private var _letterIndex : int = -1;
    private var _animationCatalogue : PrerenderedMovieClipWorker;
}
}
