/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 15/08/12
 * Time: 13:59
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.utils.getTimer;

public class PrerenderedMovieClipManager {
    public function PrerenderedMovieClipManager(eventDispatcher:IEventDispatcher) {
        _eventDispatcher = eventDispatcher;
    }

    public function startWork():void {
//        _eventDispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrameStart, false, int.MAX_VALUE);
//        _eventDispatcher.addEventListener(Event.COMPLETE, onRender, true, int.MAX_VALUE);
//        _eventDispatcher.addEventListener(Event.FRAME_CONSTRUCTED, onFrameConstructed, false, int.MAX_VALUE);
        _eventDispatcher.addEventListener(Event.EXIT_FRAME, onEnterFrameEnable, false, int.MIN_VALUE);
    }

    private function onFrameConstructed(event:Event):void {
        _constructedFrameTime = getTimer();
        if (_constructedFrameTime - _enterframeTime > 1) {
            trace("onFrameConstructed: : " + (_constructedFrameTime - _enterframeTime));
        }
    }

    private function onRender(event:Event):void {
        trace("COMPLETE");
    }

    private function onEnterFrameStart(event:Event):void {
        trace("ENTER_FRAME");
        _enterframeTime = getTimer();
    }

    private function onEnterFrameEnable(event:Event):void {
        _startExecutionTime = getTimer();

        var t : int = 0;
        while ((getTimer() - _startExecutionTime) < 10) {
            t++;
        }
        trace("iterations : " +t);
    }

    private var _constructedFrameTime:Number;
    private var _enterframeTime:Number;
    private var _exitframeTime:Number;

    private var _startExecutionTime:Number;

    private var _eventDispatcher:IEventDispatcher;
}
}
