/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 26/08/12
 * Time: 14:37
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
import flash.events.Event;

public class PrerenderedMovieClipEvent extends Event {

    public static const PRERENDER_END : String = "prerenderEnd";

    public function PrerenderedMovieClipEvent(type : String) {
        super(type);
    }

    override public function clone () : Event {
        return new PrerenderedMovieClipEvent(type);
    }
}
}
