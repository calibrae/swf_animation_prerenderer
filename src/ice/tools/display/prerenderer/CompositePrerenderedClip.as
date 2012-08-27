/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 26/08/12
 * Time: 16:20
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

[Event(type="ice.tools.display.prerenderer.PrerenderedMovieClipEvent", name="animationEnd")]
public class CompositePrerenderedClip extends Sprite implements IPrerenderedMovieClip{
    public function CompositePrerenderedClip() {
    }

    public function addPrerenderedChild(child : IPrerenderedMovieClip) : void {
        this.addChild(child as DisplayObject);
        _totalFrames = Math.max(_totalFrames, child.totalFrames);
        _children.push(child);
    }

    public function play():void {
        this.addEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    public function stop():void {
        this.removeEventListener(Event.ENTER_FRAME, onEnterframe);
    }

    private function onEnterframe(event:Event):void {
        var frameIndex:int = (_currentFrame + 1) % _totalFrames;
        gotoFrame(frameIndex);
    }

    public function gotoFrame(frameIndex:int):void {
        _currentFrame = frameIndex;
        for each (var child : IPrerenderedMovieClip in _children) {
            child.gotoFrame(frameIndex);
        }
        if (_currentFrame == totalFrames) {
            dispatchEvent(new PrerenderedMovieClipEvent(PrerenderedMovieClipEvent.ANIMATION_END));
        }
    }

    public function clone():IPrerenderedMovieClip {
        return null;
    }

    public function dispose():void {
        while(_children.length > 0) {
            _children.pop().dispose();
        }
        while (numChildren > 0) {
            removeChildAt(0);
        }
        _totalFrames = 0;
        _currentFrame = 0;
    }

    public function get totalFrames():int {
        return _totalFrames;
    }

    private var _currentFrame:int = 0;
    private var _totalFrames: int = 0;
    private const _children : Vector.<IPrerenderedMovieClip> = new Vector.<IPrerenderedMovieClip>();
}
}
