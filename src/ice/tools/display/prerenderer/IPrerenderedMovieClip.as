/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 26/08/12
 * Time: 16:21
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.events.IEventDispatcher;

[Event(type="ice.tools.display.prerenderer.PrerenderedMovieClipEvent", name="animationEnd")]
public interface IPrerenderedMovieClip extends IEventDispatcher{
    function play():void;

    function stop():void;

    function gotoFrame(frameIndex:int):void;

    function clone():IPrerenderedMovieClip;

    function dispose():void;

    function get currentFrame():int;
    function get totalFrames():int;
}
}
