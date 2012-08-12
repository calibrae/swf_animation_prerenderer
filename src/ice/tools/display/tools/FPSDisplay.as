/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 12/08/12
 * Time: 12:53
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.tools {
import flash.display.Sprite;
import flash.events.Event;
import flash.system.System;
import flash.text.TextField;
import flash.utils.getTimer;

public class FPSDisplay extends Sprite {
    public function FPSDisplay() {
        _memText = new TextField();
        _fpstext = new TextField();
        this.addChild(_fpstext);
        _memText.y = 14;
        this.addChild(_memText);
        _memText.background = _fpstext.background = true;
        _fpstext.backgroundColor = _memText.backgroundColor = 0xFFFFFF;

        this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
    }

    private function onAdded(event:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);

        this.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        _fpsCount = 0;
        _intervalStartTime = getTimer();
    }

    private function onRemoved(event:Event):void {
        this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        this.addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
    }

    private function onEnterFrame(event:Event):void {
        var currentTime : Number = getTimer();
        _fpsCount++;
        if (currentTime - _intervalStartTime >= 1000) {
            _fpstext.text = "FPS : " +_fpsCount;
            _fpsCount = 0;
            _intervalStartTime = currentTime;
        }

        _memText.text = "Mem: " + int(System.totalMemory / 1024 / 1024);
    }

    private var _fpsCount : int;
    private var _intervalStartTime : Number;
    private var _memText : TextField;
    private var _fpstext:TextField;
}
}
