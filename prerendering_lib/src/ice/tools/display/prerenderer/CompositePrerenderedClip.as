/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 26/08/12
 * Time: 16:20
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.getTimer;

[Event(type="ice.tools.display.prerenderer.PrerenderedMovieClipEvent", name="animationEnd")]
public class CompositePrerenderedClip extends Sprite implements IPrerenderedMovieClip {

    public static const FRAME_REQUEST_TIME : Number = 1000 / 32;

    public function CompositePrerenderedClip() {
    }

    public function addPrerenderedChild(child:IPrerenderedMovieClip):void {
        this.addChild(child as DisplayObject);
        _totalFrames = Math.max(_totalFrames, child.totalFrames);
        _children.push(child);
    }

    public function play():void {
        if (_isRunning) {
            return;
        }
        _isRunning = true;
        this.addEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    public function stop():void {
        if (!_isRunning) {
            return;
        }
        _isRunning = false;
        this.removeEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    private function onEnterframe(event:Event):void {

        var frameToAdd:int = 1;
        var currentTime:Number = getTimer();

        if (_lastFrameTime != 0) {
            var currentTime:Number = getTimer();
            var timeElapsed:Number = currentTime - _lastFrameTime + _currentTimeDelta;
            if (timeElapsed < FRAME_REQUEST_TIME) {
                frameToAdd = 0;
            } else {
                frameToAdd = Math.floor(timeElapsed / FRAME_REQUEST_TIME) + 1;
            }
            _currentTimeDelta = timeElapsed - (frameToAdd * FRAME_REQUEST_TIME);
        }
        _lastFrameTime = currentTime;

        var frameIndex:int = (_currentFrame + frameToAdd) % _totalFrames;
        gotoFrame(frameIndex);
    }

    public function gotoFrame(frameIndex:int):void {
        _currentFrame = frameIndex;
        for each (var child:IPrerenderedMovieClip in _children) {
            child.gotoFrame(frameIndex);
        }
        if (_currentFrame == totalFrames && hasEventListener(PrerenderedMovieClipEvent.ANIMATION_END)) {
            dispatchEvent(new PrerenderedMovieClipEvent(PrerenderedMovieClipEvent.ANIMATION_END));
        }
    }

    public function get currentFrame():int {
        return _currentFrame;
    }

    public function clone():IPrerenderedMovieClip {
        return null;
    }

    public function dispose():void {
        while (_children.length > 0) {
            _children.pop().dispose();
        }
        while (numChildren > 0) {
            removeChildAt(0);
        }
        _totalFrames = 0;
        _currentFrame = 0;
        _lastFrameTime = 0;
    }

    public function get totalFrames():int {
        return _totalFrames;
    }

    public function get frames():Vector.<BitmapData> {
        return null;
    }

    private var _isRunning : Boolean = false;
    private var _lastFrameTime:Number;
    private var _currentTimeDelta:Number = 0;
    private var _currentFrame:int = 0;
    private var _totalFrames:int = 0;
    private const _children:Vector.<IPrerenderedMovieClip> = new Vector.<IPrerenderedMovieClip>();
}
}
