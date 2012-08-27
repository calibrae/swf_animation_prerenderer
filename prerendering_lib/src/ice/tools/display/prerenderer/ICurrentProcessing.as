/**
 * Created with IntelliJ IDEA.
 * User: fredericn
 * Date: 24/08/12
 * Time: 18:25
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.BitmapData;

public interface ICurrentProcessing {
		function get isCompleted () : Boolean;
		function set isCompleted (value : Boolean) : void;
		function get currentFrame () : int;
		function set currentFrame (value : int) : void;
		function get framesGenerated () : Vector.<BitmapData>;
		function get finalAnimation () : PrerenderedMovieClip;
		function set finalAnimation(value:PrerenderedMovieClip):void;
		function get animationDescription () : IAnimationDescription;
	}
}
