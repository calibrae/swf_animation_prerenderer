/**
 * Created with IntelliJ IDEA.
 * User: fredericn
 * Date: 06/09/12
 * Time: 12:16
 * To change this template use File | Settings | File Templates.
 */
package ice.tools.display.prerenderer {
	import flash.display.MovieClip;

	public interface IPrerenderedMovieClipWorker {
		function get totalAnimations():int;

		function get currentSize():int;

		function activate():void;

		function addAnimation(animationName:String, animationToProcess:MovieClip, animationBound:IAnimationBound):void;

		function getAnimation(animationName:String):PrerenderedMovieClip;
	}
}
