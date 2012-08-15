/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 20/07/12
 * Time: 00:38
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.getTimer;

public class MovieClipConversionUtils {
    public static const MOVIECLIP_FPS:int = 32;

    public function MovieClipConversionUtils() {
        // should not be called
    }

    /**
     * Returns size information about a flash movieclip
     * @param animation Animation to inspect
     * @return Animation size information
     * @see IAnimationBound
     */
    public static function getMaxSize(animation:MovieClip):IAnimationBound {
        var startTime:Number = getTimer();
        var animationLength:int = animation.totalFrames;

        var maxWidth:Number = 0
                , maxHeight:Number = 0
                , xDelta:Number = 0
                , yDelta:Number = 0;

        _bufferSprite.addChild(animation);

        for (var i:int = 0; i < animationLength; i++) {

            animation.gotoAndStop(i);
            updateAnimationChildsFrames(animation, i);
            var bounds:Rectangle = animation.getBounds(_bufferSprite);

            maxWidth = Math.max(maxWidth, bounds.width);
            maxHeight = Math.max(maxHeight, bounds.height);
            xDelta = Math.min(xDelta, bounds.x);
            yDelta = Math.min(yDelta, bounds.y);
        }

        _bufferSprite.removeChild(animation);

        var duration:Number = getTimer() - startTime;
        var animationBoundImpl:AnimationBoundImpl = new AnimationBoundImpl(
                maxWidth
                , maxHeight
                , xDelta
                , yDelta
        );
        trace("MovieClipConversionUtils::getMaxSize() duration : " + (duration) + "ms {" + animationBoundImpl + "}");
        return animationBoundImpl;
    }

    public static function generatePrerenderedMovieClip(movieClipInstance : MovieClip, animationBounds:IAnimationBound):DisplayObject {
        return new PrerenderedMovieClip(MovieClipConversionUtils.generateBitmapDataFromMovieClip(movieClipInstance, animationBounds), animationBounds);
    }



    /**
     * Generate a bitmap data for a movieclip frame
     * @param animation Source Movieclip
     * @param frameIndex frame index (from 0 to animation.totalFrames)
     * @param animationBound Animation bound information
     * @return Bitmap data
     */
    private static function generateBitmapForFrame(animation:MovieClip, animationBound:IAnimationBound, frameIndex:uint):BitmapData {
        var bitmapData:BitmapData = new BitmapData(animationBound.maxWidth
                , animationBound.maxHeight, true, 0);
        var translationMatrix:Matrix = new Matrix();
        translationMatrix.translate(animation.x - animationBound.xDelta
                , animation.y - animationBound.yDelta);

        animation.gotoAndStop(frameIndex);
        _bufferSprite.addChild(animation);
        animation.x = - animationBound.xDelta;
        animation.y = - animationBound.yDelta;

        updateAnimationChildsFrames(animation, frameIndex);
        bitmapData.draw(_bufferSprite);
        _bufferSprite.removeChildAt(0);
        return bitmapData;
    }

    private static function updateAnimationChildsFrames(container:DisplayObjectContainer, frameIndex:uint):void {
        for (var childIndex:uint = 0; childIndex < container.numChildren; childIndex++) {
            var child:DisplayObject = container.getChildAt(childIndex);
            if (child is MovieClip) {
                MovieClip(child).gotoAndStop(frameIndex % MovieClip(child).totalFrames);
            }

            if (child is DisplayObjectContainer) {
                updateAnimationChildsFrames(child as DisplayObjectContainer, frameIndex);
            }
        }
    }

    /**
     * Generate a bitmapdata vector for all the movieclip frames
     * @param animation Source movieclip
     * @param animationBound Animation bound information
     * @return
     */
    private static function generateBitmapDataFromMovieClip(animation:MovieClip, animationBound:IAnimationBound):Vector.<BitmapData> {
        var startTime:Number = getTimer();

        var bitmapdatas:Vector.<BitmapData> = new Vector.<BitmapData>();
        var bitmapData:BitmapData;
        for (var i:uint = 0; i < animation.totalFrames; i++) {
            bitmapData = generateBitmapForFrame(
                    animation
                    , animationBound
                    , i
            );
            bitmapdatas.push(bitmapData);
//				bitmapData.dispose();
        }

        var duration:Number = getTimer() - startTime;
        trace("MovieClipConversionUtils::generateBitmapFromMovieClip() duration : " + (duration) + "ms");
        return bitmapdatas;
    }

    private static const _bufferSprite:Sprite = new Sprite();
}
}

import ice.tools.display.prerenderer.IAnimationBound;

class AnimationBoundImpl implements IAnimationBound {

    public function AnimationBoundImpl(maxWidth:Number, maxHeight:Number, xDelta:Number, yDelta:Number) {
        _maxWidth = maxWidth;
        _maxHeight = maxHeight;
        _xDelta = xDelta;
        _yDelta = yDelta;
    }

    public function get maxWidth():int {
        return _maxWidth;
    }

    public function get maxHeight():int {
        return _maxHeight;
    }

    public function get xDelta():int {
        return _xDelta;
    }

    public function get yDelta():int {
        return _yDelta;
    }

    public function toString():String {
        return "AnimationBoundImpl{_maxWidth=" + String(_maxWidth) + ",_maxHeight=" + String(_maxHeight) + ",_xDelta=" + String(_xDelta) + ",_yDelta=" + String(_yDelta) + "}";
    }

    private var _maxWidth:Number;
    private var _maxHeight:Number;
    private var _xDelta:Number;
    private var _yDelta:Number;

}