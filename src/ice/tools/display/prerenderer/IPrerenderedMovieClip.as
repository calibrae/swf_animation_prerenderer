/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 26/08/12
 * Time: 16:21
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
public interface IPrerenderedMovieClip {
    function play():void;

    function stop():void;

    function gotoFrame(frameIndex:int):void;

    function clone():IPrerenderedMovieClip;

    function dispose():void;

    function get totalFrames():int;
}
}
