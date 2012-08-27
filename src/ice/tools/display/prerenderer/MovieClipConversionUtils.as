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
import flash.geom.Rectangle;
import flash.utils.getTimer;

public class MovieClipConversionUtils {
    public static const MOVIECLIP_FPS:int = 32;
    public static const MAX_EXECUTION_TIME:int = 10;

    public function MovieClipConversionUtils() {
        // should not be called
    }

    /**
     * Returns size information about a flash movieclip
     * @param animation Animation to inspect
     * @return Animation size information
     * @see IAnimationBound
     */
    public static function getMaxSize(animation:MovieClip, basedOnParent:MovieClip = null):IAnimationBound {
        var startTime:Number = getTimer();




        var controlClip : MovieClip = basedOnParent == null ? animation : basedOnParent;
        var animationLength:int = controlClip.totalFrames;
        _boundControlBufferSprite.addChild(controlClip);

        controlClip.gotoAndStop(0);
        var bounds:Rectangle = animation.getBounds(basedOnParent == null ? _generationBufferSprite : basedOnParent);
        var maxWidth:Number = bounds.width
                , maxHeight:Number = bounds.height
                , xDelta:Number = bounds.x
                , yDelta:Number = bounds.y
                , xMax : Number = bounds.x + bounds.width
                , yMax : Number = bounds.y + bounds.height;

        for (var i:int = 0; i < animationLength; i++) {

            controlClip.gotoAndStop(i);
            updateAnimationChildsFrames(controlClip, i);
            var bounds:Rectangle = animation.getBounds(basedOnParent == null ? _generationBufferSprite : basedOnParent);

            maxWidth = Math.max(maxWidth, bounds.width);
            maxHeight = Math.max(maxHeight, bounds.height);
            xDelta = Math.min(xDelta, bounds.x);
            yDelta = Math.min(yDelta, bounds.y);
            xMax = Math.max(xMax, bounds.x + bounds.width);
            yMax = Math.max(yMax, bounds.y + bounds.height);
        }

        _boundControlBufferSprite.removeChild(controlClip);

        var duration:Number = getTimer() - startTime;
        var animationBoundImpl:AnimationBoundImpl = new AnimationBoundImpl(
                maxWidth
                , maxHeight
                , xDelta
                , yDelta
                , xMax
                , yMax
        );
        return animationBoundImpl;
    }

    public static function generatePrerenderedMovieClip(movieClipInstance:MovieClip, animationBounds:IAnimationBound, animationDescription:IAnimationDescription, maxExecutionTime:int = 10):ICurrentProcessing {
        var currentProcessing:ICurrentProcessing = new CurrentProcessingImpl(false
                , 0
                , new Vector.<BitmapData>()
                , null
                , animationDescription);

        continueProcessing(currentProcessing, maxExecutionTime);

        return currentProcessing;
    }


    /**
     * Generate a bitmap data for a movieclip frame
     * @param animation Source Movieclip
     * @param frameIndex frame index (from 0 to animation.totalFrames)
     * @param animationBound Animation bound information
     * @return Bitmap data
     */
    private static function generateBitmapForFrame(animation:MovieClip, animationBound:IAnimationBound, frameIndex:uint):BitmapData {
        var bitmapData:BitmapData = new BitmapData(
                animationBound.xMax -animationBound.xMin
                , animationBound.yMax - animationBound.yMin, true, 0);

        animation.gotoAndStop(frameIndex);
        _generationBufferSprite.addChild(animation);
        animation.x = -animationBound.xMin;
        animation.y = -animationBound.yMin;

        updateAnimationChildsFrames(animation, frameIndex);
        bitmapData.draw(_generationBufferSprite, null, null, null);
        _generationBufferSprite.removeChildAt(0);
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

    public static function continueProcessing(currentProcessing:ICurrentProcessing, maxExecutionTime:int = 10):ICurrentProcessing {
        var startTime:Number = getTimer();
        var bitmapData:BitmapData;
        var duration:Number;
        var processingIteration:uint;
        var animationDescription:IAnimationDescription = currentProcessing.animationDescription;

        for (processingIteration = currentProcessing.currentFrame; processingIteration < animationDescription.movieClip.totalFrames; processingIteration++) {
            bitmapData = generateBitmapForFrame(
                    animationDescription.movieClip
                    , animationDescription.bounds
                    , processingIteration
            );
            currentProcessing.framesGenerated.push(bitmapData);
            duration = getTimer() - startTime;
            if (duration >= maxExecutionTime) {
                break;
            }
        }

        currentProcessing.currentFrame = processingIteration;
        if (currentProcessing.currentFrame == animationDescription.movieClip.totalFrames) {
            currentProcessing.isCompleted = true;
            currentProcessing.finalAnimation = new PrerenderedMovieClip(currentProcessing.framesGenerated, animationDescription.bounds);
        }

        return currentProcessing;
    }


    private static const _generationBufferSprite:Sprite = new Sprite();
    private static const _boundControlBufferSprite:Sprite = new Sprite();
}
}

import flash.display.BitmapData;

import ice.tools.display.prerenderer.IAnimationBound;
import ice.tools.display.prerenderer.IAnimationDescription;
import ice.tools.display.prerenderer.ICurrentProcessing;
import ice.tools.display.prerenderer.PrerenderedMovieClip;

class AnimationBoundImpl implements IAnimationBound {

    public function AnimationBoundImpl(maxWidth:Number, maxHeight:Number, xDelta:Number, yDelta:Number, xMax:Number, yMax:Number) {
        _maxWidth = maxWidth;
        _maxHeight = maxHeight;
        _xDelta = xDelta;
        _yDelta = yDelta;
        _xMax = xMax;
        _yMax = yMax;
    }

    public function get maxWidth():int {
        return _maxWidth;
    }

    public function get maxHeight():int {
        return _maxHeight;
    }

    public function get xMin():int {
        return _xDelta;
    }

    public function get yMin():int {
        return _yDelta;
    }

    public function get xDelta():int {
        return _xDelta;
    }

    public function get yDelta():int {
        return _yDelta;
    }

    public function get xMax():int {
        return _xMax;
    }

    public function get yMax():int {
        return _yMax;
    }

    public function toString():String {
        return "AnimationBoundImpl{_maxWidth=" + String(_maxWidth) + ",_maxHeight=" + String(_maxHeight) + ",_xDelta=" + String(_xDelta) + ",_yDelta=" + String(_yDelta) + "}";
    }

    private var _maxWidth:Number;
    private var _maxHeight:Number;
    private var _xDelta:Number;
    private var _yDelta:Number;
    private var _xMax : Number;
    private var _yMax : Number;

}

class CurrentProcessingImpl implements ICurrentProcessing {

    public function CurrentProcessingImpl(isCompleted:Boolean, currentFrame:int, framesGenerated:Vector.<BitmapData>, finalAnimation:PrerenderedMovieClip, animationDescription:IAnimationDescription) {
        _isCompleted = isCompleted;
        _currentFrame = currentFrame;
        _framesGenerated = framesGenerated;
        _finalAnimation = finalAnimation;
        _animationDescription = animationDescription;
    }

    public function get isCompleted():Boolean {
        return _isCompleted;
    }

    public function get currentFrame():int {
        return _currentFrame;
    }

    public function get framesGenerated():Vector.<BitmapData> {
        return _framesGenerated;
    }

    public function get finalAnimation():PrerenderedMovieClip {
        return _finalAnimation;
    }

    public function set finalAnimation(value:PrerenderedMovieClip):void {
        _finalAnimation = value;
    }

    public function get animationDescription():IAnimationDescription {
        return _animationDescription;
    }

    public function set isCompleted(value:Boolean):void {
        _isCompleted = value;
    }

    public function set currentFrame(value:int):void {
        _currentFrame = value;
    }

    private var _isCompleted:Boolean;
    private var _currentFrame:int;
    private var _framesGenerated:Vector.<BitmapData>;
    private var _finalAnimation:PrerenderedMovieClip;
    private var _animationDescription:IAnimationDescription;

}