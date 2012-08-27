/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 27/08/12
 * Time: 14:07
 * To change this template use File | Settings | File Templates.
 */
package {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.getTimer;

import ice.game.wordox.views.letters.EJellyAnimation;
import ice.game.wordox.views.letters.JellyAnimationCatalogue;
import ice.game.wordox.views.progressbar.Progressbar;
import ice.tools.display.prerenderer.MovieClipConversionUtils;
import ice.tools.display.prerenderer.PrerenderedMovieClip;
import ice.tools.display.prerenderer.PrerenderedMovieClipEvent;
import ice.tools.display.prerenderer.PrerenderedMovieClipWorker;
import ice.tools.display.tools.FPSDisplay;
import ice.wordox.gfx.JellyWinAnimation;

import mx.core.UIComponent;
import mx.graphics.codec.PNGEncoder;

public class Main extends UIComponent {

    [Bindable]
    public var currentAnimationAtlases:String = "";

    [Bindable]
    public var totalToSave:int = 0;

    [Bindable]
    public var currentSaved:int = 0;

    public function Main() {

        _fpsDisplay = new FPSDisplay();
        this.addChild(_fpsDisplay);
        _waitingAnimation = new JellyWinAnimation();
        _waitingAnimation.x = 50;
        _waitingAnimation.y = 50;
        addChild(_waitingAnimation);
        _progressbar = new Progressbar(450, 30, "Calcul des animations en cours:", true);
        _progressbar.x = 250;
        _progressbar.y = 15;
        this.addChild(_progressbar);

        initializeJellyCatalogue();
    }

    private function initializeJellyCatalogue():void {
        _prerenderingStartTime = getTimer();
        _prerenderedMovieClipWorker = new PrerenderedMovieClipWorker(this, 20);
        _jellyCatalogue = new JellyAnimationCatalogue(_prerenderedMovieClipWorker);
        _jellyCatalogue.addEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);
        this.addEventListener(Event.ENTER_FRAME, onEnterFrameRefreshAnimationCount);
        _jellyCatalogue.initializeAllMovieclip();
    }

    private function onEnterFrameRefreshAnimationCount(event:Event):void {
        _fpsDisplay.currentGenerationTime = getTimer() - _prerenderingStartTime;
        _progressbar.updateValue(_jellyCatalogue.catalogueCurrentSize, _jellyCatalogue.cataloguetotalSize);
    }

    private function onPrerenderEnd(event:PrerenderedMovieClipEvent):void {
        _jellyCatalogue.removeEventListener(PrerenderedMovieClipEvent.PRERENDER_END, onPrerenderEnd);

        _fpsDisplay.currentGenerationTime = getTimer() - _prerenderingStartTime;
        _progressbar.updateValue(_jellyCatalogue.catalogueCurrentSize, _jellyCatalogue.cataloguetotalSize);

        this.removeEventListener(Event.ENTER_FRAME, onEnterFrameRefreshAnimationCount);
        if (this.contains(_waitingAnimation)) {
            removeChild(_waitingAnimation);
        }
        generateAtlas();
    }

    private function generateAtlas():void {

        for (var animationName:String in _prerenderedMovieClipWorker.allAnimations) {
            _animationsQueue.push(animationName);
        }
        totalToSave = _animationsQueue.length;

        this.addEventListener(Event.ENTER_FRAME, processPng);
    }

    private function processPng(event:Event):void {
        var startTime:Number = getTimer();

        while (_animationsQueue.length > 0) {
            saveOneAnimation(_animationsQueue.pop());
            if (getTimer() - startTime > 20) {
                break;
            }
        }

        if (_animationsQueue.length == 0) {
            saveXmlFile();
            this.removeEventListener(Event.ENTER_FRAME, processPng);
        }
    }

    private function saveXmlFile():void {
        var path:String = "atlases-generation/atlases-info.xml";
        var currentFile:File = File.userDirectory.resolvePath(path);

        _atlasXmlInfo = XML_HEADER + _atlasXmlInfo + XML_FOOTER;
        var fileStream:FileStream = new FileStream();
        fileStream.open(currentFile, FileMode.WRITE);
        fileStream.writeUTFBytes(_atlasXmlInfo);
        fileStream.close();
    }

    private function saveOneAnimation(animationName:String):void {
        var animation:PrerenderedMovieClip = _prerenderedMovieClipWorker.getAnimation(animationName);

        var atlases:Vector.<BitmapData> = MovieClipConversionUtils.generateAtlas(animation, 1500);
        var pngs:Vector.<ByteArray> = new Vector.<ByteArray>();
        var encoder:PNGEncoder = new PNGEncoder();
        for (var i:uint = 0; i < atlases.length; i++) {
            pngs.push(encoder.encode(atlases[i]));
        }

        var workDir:File = File.userDirectory.resolvePath("atlases-generation");

        _atlasXmlInfo +=
                "\t<animation name=\"" + animationName + "\"" +
                        " path=\"" + animationName..split(":").join("-") + "\"" +
                        " width=\"" + animation.frames[0].width + "\"" +
                        " height=\"" + animation.frames[0].height + "\"" +
                        " files-count=\"" + pngs.length + "\"" +
                        " frames-count=\"" + animation.frames.length + "\"" +
                        "/>\n";
        currentSaved++;

        if (!workDir.exists) {
            workDir.createDirectory();
        }

        for (var i:uint = 0; i < pngs.length; i++) {

            var filePath:String = animationName..split(":").join("-") + "-" + i + ".png";
            var path:String = "atlases-generation/" + filePath;
            var currentFile:File = File.userDirectory.resolvePath(path);
            var fileStream:FileStream = new FileStream();
            fileStream.open(currentFile, FileMode.WRITE);
            fileStream.writeBytes(pngs[i]);
            fileStream.close();
        }

        _progressbar.updateValue(currentSaved, totalToSave);
    }


    [ArrayElementType("ice.game.wordox.views.letters.EJellyAnimation")]
    private const _jelliesClass:Array =
            [EJellyAnimation.BIRTH_ANIMATION
                , EJellyAnimation.DROP_ANIMATION
                , EJellyAnimation.MOVING_ANIMATION
                , EJellyAnimation.OUT_ANIMATION
                , EJellyAnimation.OVER_ANIMATION
                , EJellyAnimation.BREATHING_ANIMATION
                , EJellyAnimation.STEALING_ANIMATION
                , EJellyAnimation.WIN_ANIMATION];

    private var _fpsDisplay:FPSDisplay;

    private var _prerenderingStartTime:Number;
    private var _jellyCatalogue:JellyAnimationCatalogue;
    private var _prerenderedMovieClipWorker:PrerenderedMovieClipWorker;
    private var _waitingAnimation:DisplayObject;
    private var _progressbar:Progressbar;

    private var _atlasXmlInfo:String = "";
    private var _animationsQueue:Vector.<String> = new Vector.<String>();


    private static const XML_HEADER:String = '<?xml version="1.0" encoding="UTF-8"?>\n'
            + '<!--\n'
            + '~ Copyright (c) 2011.\n'
            + '~ WEKA Entertainement\n'
            + '-->\n' +
            '<animation>\n';
    private static const XML_FOOTER:String = '</animation>\n\n';

}
}
