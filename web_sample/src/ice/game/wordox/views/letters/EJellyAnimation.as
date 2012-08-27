/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 27/08/12
 * Time: 11:01
 * To change this template use File | Settings | File Templates.
 */
package ice.game.wordox.views.letters {
import ice.wordox.gfx.JellyBirthAnimation;
import ice.wordox.gfx.JellyBreathingAnimation;
import ice.wordox.gfx.JellyDropAnimation;
import ice.wordox.gfx.JellyMovingAnimation;
import ice.wordox.gfx.JellyOutAnimation;
import ice.wordox.gfx.JellyOverAnimation;
import ice.wordox.gfx.JellyStealingAnimation;
import ice.wordox.gfx.JellyWinAnimation;

public class EJellyAnimation {

    public static const BIRTH_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyBirthAnimation);
    public static const DROP_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyDropAnimation);
    public static const MOVING_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyMovingAnimation);
    public static const OUT_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyOutAnimation);
    public static const OVER_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyOverAnimation);
    public static const BREATHING_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyBreathingAnimation);
    public static const STEALING_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyStealingAnimation);
    public static const WIN_ANIMATION : EJellyAnimation = new EJellyAnimation(JellyWinAnimation);

    public function EJellyAnimation(animationClass : Class) {
        _animationClass = animationClass;
    }

    public function get animationClass():Class {
        return _animationClass;
    }

    private var _animationClass : Class;
}
}
