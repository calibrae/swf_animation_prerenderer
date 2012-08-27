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

    public function PrerenderedMovieClip(bitmapDatas:Vector.<BitmapData>, animationBound:IAnimationBound) {
        _bitmapDatas = bitmapDatas;
        _animationBound = animationBound;
        _currentDisplay.x = animationBound.xMin;
        _currentDisplay.y = animationBound.yMin;
        this.addChild(_currentDisplay);
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
            _currentDisplay.bitmapData = bitmapData
        };

        if (_currentFrame == totalFrames) {
            dispatchEvent(new PrerenderedMovieClipEvent(PrerenderedMovieClipEvent.ANIMATION_END));
        }
    }

    public function clone():IPrerenderedMovieClip {
        return new PrerenderedMovieClip(_bitmapDatas, _animationBound);
    }

    public function dispose():void {
        stop();
        this.removeChild(_currentDisplay);
        _currentDisplay.bitmapData = null;
        _currentDisplay = null;
        _bitmapDatas = null;
        _animationBound = null;
    }

    public function get currentFrame():int {
        return _currentFrame;
    }

    public function get totalFrames():int {
        return _bitmapDatas.length;
    }

    private function onEnterframe(event:Event):void {
        if (_bitmapDatas == null) {
            dispose();
            return;
        }
        var frameIndex:int = _currentFrame + 1;
        gotoFrame(frameIndex);
    }

    private var _currentDisplay:Bitmap = new Bitmap();
    private var _bitmapDatas:Vector.<BitmapData>;
    private var _animationBound:IAnimationBound;
    private var _currentFrame:int = 0;
}
}
