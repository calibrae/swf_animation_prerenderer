/**
 * Created with IntelliJ IDEA.
 * User: fredericn
 * Date: 24/08/12
 * Time: 17:43
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.display.MovieClip;

public interface IAnimationDescription {
		function get name () : String;
		function get movieClip () : MovieClip;
		function get bounds () : IAnimationBound;
        function get loopable () : Boolean;
	}
}
