/**
 * Created with IntelliJ IDEA.
 * User: fredericn
 * Date: 24/08/12
 * Time: 17:28
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
	import avmplus.getQualifiedClassName;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;

	import ice.wordox.gfx.JellyBirthAnimation;
	import ice.wordox.gfx.JellyBreathingAnimation;
	import ice.wordox.gfx.JellyDropAnimation;
	import ice.wordox.gfx.JellyMovingAnimation;
	import ice.wordox.gfx.JellyOutAnimation;
	import ice.wordox.gfx.JellyOverAnimation;
	import ice.wordox.gfx.JellyStealingAnimation;
	import ice.wordox.gfx.JellyWinAnimation;

	public class JellyAnimationCatalogue {

		public function JellyAnimationCatalogue(eventdispatcher : IEventDispatcher) {
			_worker = new PrerenderedMovieClipWorker(eventdispatcher);
		}

		public function initializeAllMovieclip () : void {
			while (_jelliesClass.length > 0) {
				initializeMovieclip(_jelliesClass.pop());
			}
		}

		private function initializeMovieclip(animationClass : Class):void {
			var prenderedMovieClip:Vector.<PrerenderedMovieClip> = new Vector.<PrerenderedMovieClip>();
			var _overlaySprite:Sprite = new Sprite();

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

			for (var iPlayer:uint = 0; iPlayer < _playersColor.length; iPlayer++) {
				updateOverlayColor(_playersColor[iPlayer], _overlaySprite);
				_worker.addAnimation(getQualifiedClassName(jellyAnimation) + "_" + iPlayer, jellyAnimation, animationBounds);
//				prenderedMovieClip.push(MovieClipConversionUtils.generatePrerenderedMovieClip(jellyAnimation,
//						animationBounds));
//				_prerenderedForClass[animationClass] = prenderedMovieClip;
			}
			_overlaySprite = null;
		}

		private static function updateOverlayColor(playerColor:int, overlayClip : Sprite):void {
			var graphics:Graphics = overlayClip.graphics;
		   graphics.clear();
		   graphics.beginFill(playerColor);
		   graphics.moveTo(-1, -15);
		   graphics.lineTo(-1, _LETTER_SIZE + 30);
		   graphics.lineTo(_LETTER_SIZE + 2, _LETTER_SIZE + 30);
		   graphics.lineTo(_LETTER_SIZE + 2, -15);
		   graphics.endFill();
		}

		private const _playersColor:Array = [0xDD2222, 0x22DD22, 0x2222DD, 0x228888];
		private const _jelliesClass:Array = [JellyBirthAnimation, JellyDropAnimation, JellyMovingAnimation, JellyOutAnimation, JellyOverAnimation
			, JellyBreathingAnimation, JellyStealingAnimation, JellyWinAnimation];
		private static const _LETTER_SIZE:int = 45;

		private static var _worker : PrerenderedMovieClipWorker;
	}
}
