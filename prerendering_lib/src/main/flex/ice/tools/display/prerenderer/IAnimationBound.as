/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 20/07/12
 * Time: 00:39
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
public interface IAnimationBound {

    /**
     * Max size of an animation
     */
    function get maxWidth () : int;

    /**
     * Max height of an animation
     */
    function get maxHeight () : int;

    /**
     * xDelta for the animation (used if any frame has X position lower than 0)
     */
    function get xMin () : int;

    /**
     * yDelta for the animation (used if any frame has Y position lower than 0)
     */
    function get yMin () : int;

    function get xMax () : int;
    function get yMax () : int;
}
}
