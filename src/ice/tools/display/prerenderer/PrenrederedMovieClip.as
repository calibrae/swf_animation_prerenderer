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

public class PrenrederedMovieClip extends Sprite {

    public function PrenrederedMovieClip(bitmapDatas:Vector.<BitmapData>, animationBound:IAnimationBound) {
        _bitmapDatas = bitmapDatas;
        _animationBound = animationBound;
        _currentDisplay.x = animationBound.xDelta;
        _currentDisplay.y = animationBound.yDelta;
        this.addChild(_currentDisplay);
        this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
    }

    public function clone():PrenrederedMovieClip {
        return new PrenrederedMovieClip(_bitmapDatas, _animationBound);
    }

    public function dispose():void {
        this.removeEventListener(Event.ENTER_FRAME, onEnterframe);
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
        this.addEventListener(Event.ENTER_FRAME, onEnterframe);
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
        _currentFrame = (_currentFrame + 1) % _bitmapDatas.length;
        var bitmapData:BitmapData = _bitmapDatas[_currentFrame];
        if (bitmapData == null) {
            return;
        }
        _currentDisplay.bitmapData = bitmapData;
    }

    private var _currentDisplay:Bitmap = new Bitmap();
    private var _bitmapDatas:Vector.<BitmapData>;
    private var _animationBound:IAnimationBound;
    private var _currentFrame:int = 0;
}
}
