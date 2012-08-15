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

public class PrerenderedMovieClip extends Sprite {

    public function PrerenderedMovieClip(bitmapDatas:Vector.<BitmapData>, animationBound:IAnimationBound) {
        _bitmapDatas = bitmapDatas;
        _animationBound = animationBound;
        _currentDisplay.x = animationBound.xDelta;
        _currentDisplay.y = animationBound.yDelta;
        this.addChild(_currentDisplay);
        this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
    }

    public function play () : void {
        this.addEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    public function stop () : void {
        this.removeEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    public function gotoFrame(frameIndex:int):void {
        _currentFrame = (frameIndex) % _bitmapDatas.length;
        var bitmapData:BitmapData = _bitmapDatas[_currentFrame];
        if (bitmapData != null) {
            _currentDisplay.bitmapData = bitmapData;
        }
    }

    public function clone():PrerenderedMovieClip {
        return new PrerenderedMovieClip(_bitmapDatas, _animationBound);
    }

    public function dispose():void {
        stop();
        this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);

        this.removeChild(_currentDisplay);
        _currentDisplay.bitmapData = null;
        _currentDisplay = null;
        _bitmapDatas = null;
        _animationBound = null;
    }

    private function onAdded(event:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
    }

    private function onRemoved(event:Event):void {
        this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
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
