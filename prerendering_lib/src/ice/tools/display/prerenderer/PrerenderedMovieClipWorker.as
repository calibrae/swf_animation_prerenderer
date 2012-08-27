/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 15/08/12
 * Time: 13:59
 * To change this template use File | Settings | File Templates.
 */


package ice.tools.display.prerenderer {
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;
import flash.utils.getTimer;

[Event(type="ice.tools.display.prerenderer.PrerenderedMovieClipEvent", name="prerenderEnd")]
public class PrerenderedMovieClipWorker extends EventDispatcher {
    public function PrerenderedMovieClipWorker(eventDispatcher:IEventDispatcher, maxExecutionTime : int) {
        _eventDispatcher = eventDispatcher;
		_maxExecutionTime  = maxExecutionTime;
    }

    public function get totalAnimations():int {
        return _totalSize;
    }

    public function get currentSize() : int {
        return _currentSize;
    }

    private function start():void {
		if (_running) {
			return;
		}
		_running = true;
        _eventDispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrameEnable, false, int.MIN_VALUE);
    }

	private function stop() : void {
		if (!_running) {
			return;
		}
		_eventDispatcher.removeEventListener(Event.ENTER_FRAME, onEnterFrameEnable);
		_running = false;

		trace("PrerenderedMovieClipWorker halted. \n\tAnimations List:");
		for (var keyName : String in _prerenderedAnimations) {
			trace("\t\t* " + keyName + " -> " + PrerenderedMovieClip(_prerenderedAnimations[keyName]).totalFrames + " frames");
		}
	}

	public function addAnimation (animationName : String, animationToProcess : MovieClip, animationBound : IAnimationBound) : void {
		_animationsQueues.push(new AnimationDescriptionImpl(animationName, animationToProcess, animationBound));
        _totalSize ++;
		if (!_running) {
			start();
		}
	}

    public function getAnimation(animationName:String):PrerenderedMovieClip {
        return _prerenderedAnimations[animationName];
    }

    [ArrayElementType("ice.tools.display.prerenderer.PrerenderedMovieClip")]
    public function get allAnimations () : Dictionary {
        return _prerenderedAnimations
    }

    private function onEnterFrameEnable(event:Event):void {
		var _startExecutionTime:Number = getTimer();

		var t:int = 0;
		while ((getTimer() - _startExecutionTime) < 10) {
			if (_animationsQueues.length == 0 && _currentProcessing == null) {
				trace("PrerenderedMovieClipWorker : queue is empty");
				stop();
                dispatchEvent(new PrerenderedMovieClipEvent(PrerenderedMovieClipEvent.PRERENDER_END));
				break;
			}
			execute();
		}
	}

	private function execute():void {
		if (_currentProcessing == null) {
			var animationDescription : IAnimationDescription = _animationsQueues.shift();
			_currentProcessing = MovieClipConversionUtils.generatePrerenderedMovieClip(animationDescription.movieClip, animationDescription.bounds, animationDescription, _maxExecutionTime);
		} else {
			MovieClipConversionUtils.continueProcessing(_currentProcessing, _maxExecutionTime);
		}

		if (_currentProcessing.isCompleted) {
			_prerenderedAnimations[_currentProcessing.animationDescription.name] = _currentProcessing.finalAnimation;
            _currentSize++;
			_currentProcessing = null;
		}

	}

	private var _currentProcessing : ICurrentProcessing;
	private const _animationsQueues : Vector.<IAnimationDescription> = new Vector.<IAnimationDescription>();
    [ArrayElementType("ice.tools.display.prerenderer.PrerenderedMovieClip")]
	private const _prerenderedAnimations : Dictionary = new Dictionary();
    private var _eventDispatcher:IEventDispatcher;
	private var _running : Boolean = false;
	private var _maxExecutionTime : int;
    private var _currentSize : int;
    private var _totalSize : int;

}
}

import flash.display.MovieClip;

import ice.tools.display.prerenderer.IAnimationBound;
import ice.tools.display.prerenderer.IAnimationDescription;

class AnimationDescriptionImpl implements IAnimationDescription {

	public function AnimationDescriptionImpl(name:String, movieClip:MovieClip, bounds:IAnimationBound, loopable : Boolean = true) {
		_name = name;
		_movieClip = movieClip;
		_bounds = bounds;
        _loopable = loopable;
	}

	public function get name():String {
		return _name;
	}

	public function get movieClip():MovieClip {
		return _movieClip;
	}

	public function get bounds():IAnimationBound {
		return _bounds;
	}

    public function get loopable():Boolean {
        return _loopable;
    }

    private var _loopable : Boolean = true;
	private var _name : String;
	private var _movieClip : MovieClip;
	private var _bounds : IAnimationBound;
}