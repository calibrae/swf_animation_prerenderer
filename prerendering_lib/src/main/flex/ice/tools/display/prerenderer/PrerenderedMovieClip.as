/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 12/08/12
 * Time: 12:09
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;

	[Event(type="ice.tools.display.prerenderer.PrerenderedMovieClipEvent", name="animationEnd")]
	public class PrerenderedMovieClip extends Sprite implements IPrerenderedMovieClip {

		public static function get ITEMS_CREATION_COUNT () : int {
			return _ITEMS_CREATION_COUNT;
		}

		public static function get ITEMS_AVAILABLE_COUNT () : int {
			return _pool.length;
		}

		public function PrerenderedMovieClip() {
			_ITEMS_CREATION_COUNT++;
			this.addChild(_currentDisplay);
		}

		public static function checkOut(bitmapDatas:Vector.<BitmapData>, animationBound:IAnimationBound) : IPrerenderedMovieClip {
			if (!_isPoolInitialize) {
				initializePool();
			}
			if (_pool.length == 0) {
				addNewElement ();
			}
			var element : PrerenderedMovieClip = _pool.pop() as PrerenderedMovieClip;
			element.bitmapDatas = bitmapDatas;
			element.animationBound = animationBound;
			element.currentDisplay.x = animationBound.xMin;
			element.currentDisplay.y = animationBound.yMin;
			return element;
		}

		public static function checkIn(element : IPrerenderedMovieClip) : void {
			_pool.push(element);
		}

		public function play():void {
			this.addEventListener(Event.ENTER_FRAME, onEnterframe);
		}

		public function stop():void {
			this.removeEventListener(Event.ENTER_FRAME, onEnterframe);
		}

		public function gotoFrame(frameIndex:int):void {
			_currentFrame = (frameIndex) % _bitmapDatas.length;
			var bitmapData:BitmapData = _bitmapDatas[_currentFrame];
			if (bitmapData != null) {
				_currentDisplay.bitmapData = bitmapData;
			}

			if (_currentFrame == totalFrames) {
				dispatchEvent(new PrerenderedMovieClipEvent(PrerenderedMovieClipEvent.ANIMATION_END));
			}
		}

		public function clone():IPrerenderedMovieClip {
			return checkOut(_bitmapDatas, _animationBound);
		}

		public function dispose():void {
			stop();
			_currentDisplay.bitmapData = null;
			_bitmapDatas = null;
			_animationBound = null;
		}

		public function get currentFrame():int {
			return _currentFrame;
		}

		public function get frames () :Vector.<BitmapData> {
			return _bitmapDatas;
		}

		public function get totalFrames():int {
			return _bitmapDatas.length;
		}


		internal function get currentDisplay():Bitmap {
			return _currentDisplay;
		}

		internal function set animationBound(value:IAnimationBound):void {
			_animationBound = value;
		}

		internal function set bitmapDatas(value:Vector.<BitmapData>):void {
			_bitmapDatas = value;
		}

		private function onEnterframe(event:Event):void {
			if (_bitmapDatas == null) {
				dispose();
				return;
			}
			var frameIndex:int = _currentFrame + 1;
			gotoFrame(frameIndex);
		}

		private static function initializePool () : void {
			for (var i : uint = 0; i < _POOL_START_SIZE; i++) {
				addNewElement();
			}
			_isPoolInitialize = true;
		}

		private static function addNewElement():void {
			_pool.push(new PrerenderedMovieClip());
		}


		private var _currentDisplay:Bitmap = new Bitmap();
		private var _bitmapDatas:Vector.<BitmapData>;
		private var _animationBound:IAnimationBound;
		private var _currentFrame:int = 0;

		private static const _POOL_START_SIZE : int = 500;
		private static var _isPoolInitialize : Boolean = false;
		private static var _ITEMS_CREATION_COUNT : int = 0;
		private static const _pool : Vector.<IPrerenderedMovieClip> = new Vector.<IPrerenderedMovieClip>();
	}
}
