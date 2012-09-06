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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	public class MovieClipConversionUtils {

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
			var controlClip:MovieClip = basedOnParent == null ? animation : basedOnParent;
			var animationLength:int = controlClip.totalFrames;
			_boundControlBufferSprite.addChild(controlClip);

			controlClip.gotoAndStop(0);
			var bounds:Rectangle = animation.getBounds(basedOnParent == null ? _generationBufferSprite : basedOnParent);
			var maxWidth:int = bounds.width + 1
					, maxHeight:int = bounds.height + 1
					, xDelta:int = bounds.x
					, yDelta:int = bounds.y
					, xMax:int = bounds.x + bounds.width + 1
					, yMax:int = bounds.y + bounds.height + 1;

			for (var i:int = 0; i < animationLength; i++) {

				controlClip.gotoAndStop(i);
				updateAnimationChildsFrames(controlClip, i);
				bounds = animation.getBounds(basedOnParent == null ? _generationBufferSprite : basedOnParent);

				maxWidth = Math.max(maxWidth, bounds.width + 1);
				maxHeight = Math.max(maxHeight, bounds.height + 1);
				xDelta = Math.min(xDelta, bounds.x);
				yDelta = Math.min(yDelta, bounds.y);
				xMax = Math.max(xMax, bounds.x + bounds.width + 1);
				yMax = Math.max(yMax, bounds.y + bounds.height + 1);
			}

			_boundControlBufferSprite.removeChild(controlClip);

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

		public static function generatePrerenderedMovieClip(animationDescription:IAnimationDescription, maxExecutionTime:int = 10):ICurrentProcessing {
			var currentProcessing:ICurrentProcessing = new CurrentProcessingImpl(false
					, 0
					, new Vector.<BitmapData>()
					, null
					, animationDescription);

			continueProcessing(currentProcessing, maxExecutionTime);

			return currentProcessing;
		}

		public static function generateAtlas(prerenderedMovieclip:PrerenderedMovieClip, maxSize:int):Vector.<BitmapData> {
			var result:Vector.<BitmapData> = new Vector.<BitmapData>();
			var currentBitmap:BitmapData = new BitmapData(maxSize, maxSize, true, 0);

			var bound:Rectangle = new Rectangle(0, 0, prerenderedMovieclip.frames[0].width, prerenderedMovieclip.frames[0].height);
			var currentCol:int = 0;
			var currentRow:int = 0;
			var maxCols:int = Math.floor(maxSize / bound.width) - 1;
			var maxRows:int = Math.floor(maxSize / bound.height) - 1;

			for (var i:uint = 0; i < prerenderedMovieclip.frames.length; i++) {
				var bitmapData:BitmapData = prerenderedMovieclip.frames[i];
				currentBitmap.copyPixels(bitmapData, bound, new Point(currentCol * bound.width, currentRow * bound.height));

				if (currentCol == maxCols) {

					if (currentRow == maxRows) {
						currentCol = 0;
						currentRow = 0;
						result.push(currentBitmap);
						currentBitmap = new BitmapData(maxSize, maxSize, true, 0);
					}
					currentCol = 0;
					currentRow++;
				} else {
					currentCol++;
				}
			}

			var postProcessBitmap : BitmapData = new BitmapData((currentCol + 1) * bound.width, (currentRow + 1) * bound.height);
			postProcessBitmap.copyPixels(currentBitmap, new Rectangle(0, 0, postProcessBitmap.width, postProcessBitmap.height), new Point(0, 0));
			result.push(postProcessBitmap);

			return result;
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
					animationBound.xMax - animationBound.xMin
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
				currentProcessing.finalAnimation = PrerenderedMovieClip.checkOut(currentProcessing.framesGenerated, animationDescription.bounds);
			} else {
				currentProcessing.currentFrame = processingIteration + 1;
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
import ice.tools.display.prerenderer.IPrerenderedMovieClip;
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
	private var _xMax:Number;
	private var _yMax:Number;

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

	public function get finalAnimation():IPrerenderedMovieClip {
		return _finalAnimation;
	}

	public function set finalAnimation(value:IPrerenderedMovieClip):void {
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
	private var _finalAnimation:IPrerenderedMovieClip;
	private var _animationDescription:IAnimationDescription;

}