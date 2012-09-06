package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filters.GlowFilter;
import flash.sampler.DeleteObjectSample;
import flash.sampler.NewObjectSample;
import flash.sampler.Sample;
import flash.sampler.clearSamples;
import flash.sampler.getSamples;
import flash.sampler.pauseSampling;
import flash.sampler.startSampling;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

import ice.game.wordox.views.letters.EJellyAnimation;
import ice.game.wordox.views.letters.JellyAnimation;
import ice.game.wordox.views.letters.JellyAnimationCooker;
import ice.game.wordox.views.progressbar.Progressbar;
	import ice.tools.display.prerenderer.IPrerenderedMovieClip;
	import ice.tools.display.prerenderer.PrerenderedMovieClipEvent;
import ice.tools.display.prerenderer.PrerenderedMovieClipWorker;
import ice.tools.display.tools.FPSDisplay;
import ice.wordox.gfx.JellyWinAnimation;

[SWF(frameRate="32", width="2500", height="2500")]
public class Main extends Sprite {


    public function Main() {
        startSampling();

        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        _jelliesContainer = new Sprite();
        this.addChild(_jelliesContainer);

        _infoContainer = new Sprite();
        _fpsDisplay = new FPSDisplay();
        _infoContainer.addChild(_fpsDisplay);
        _waitingAnimation = new JellyWinAnimation();
        _waitingAnimation.x = 50;
        _waitingAnimation.y = 50;
        addChild(_waitingAnimation);
        _progressbar = new Progressbar(450, 30, "Calcul des animations en cours:", true);
        _progressbar.x = 250;
        _progressbar.y = 15;
        _infoContainer.addChild(_progressbar);
        var infoTextfield:TextField = new TextField();
        infoTextfield.defaultTextFormat = new TextFormat(
                "Arial", 12, 0
        );
        infoTextfield.text = "Key mapping:\n"
                + "\tA: Switch to prerendering mode\n"
                + "\tZ: Switch to normal (vectorized) mode\n"
                + "\tW: Add a row\n"
                + "\tX: Remove a row\n"
                + "\tUP: Change jellies colors (prerendered mode only)\n"
                + "\tDOWN: Change jellies animations (prerendered mode only)\n"
                + "\tPAGE UP: Change jellies colors on every frame (prerendered mode only)\n"
                + "\tPAGE DOWN: Stop changing colors on every frame (prerendered mode only)\n"
				+ "\tSUPPR: Call garbage collector\n"
        ;
        infoTextfield.x = 300;
        infoTextfield.y = 300;
        infoTextfield.width = infoTextfield.textWidth + 10;
        infoTextfield.height = infoTextfield.textHeight + 10;
        _infoContainer.addChild(infoTextfield);
        _infoContainer.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 10)];

        this.addChild(_infoContainer);
        _infoContainer.mouseChildren = false;
        _infoContainer.mouseEnabled = false;

        initializeJellyCatalogue();
    }

    private function initializeJellyCatalogue():void {
        _prerenderingStartTime = getTimer();
        _prerenderedMovieClipWorker = new PrerenderedMovieClipWorker(this, 20);
        _jellyCatalogue = new JellyAnimationCooker(_prerenderedMovieClipWorker);
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
        changeMode(addPrerenderRows);

        this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboard);
    }

    private function onKeyboard(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.PAGE_UP && !_isAutoSwitching) {
            this.addEventListener(Event.ENTER_FRAME, autoSwitchPlayers);
            _isAutoSwitching = true;
            return;
        }

        if (event.keyCode == Keyboard.PAGE_DOWN) {
            this.removeEventListener(Event.ENTER_FRAME, autoSwitchPlayers);
            _isAutoSwitching = false;
            return;
        }

        if (event.keyCode == Keyboard.BACKSPACE) {
            displaySamplers();
            return;
        }
        //

			if (event.keyCode == Keyboard.A && _drawingFunction != addPrerenderRows) {
				changeMode(addPrerenderRows);
				return;
			}

			if(event.keyCode == Keyboard.Z && _drawingFunction != addNormalRows) {
				changeMode(addNormalRows);
				return;
			}

        if (event.keyCode == Keyboard.RIGHT) {
            addRows(1);
            return;
        }

        if (event.keyCode == Keyboard.LEFT) {
            removeRows(1);
            return;
        }

        for (var animIndex:uint = 0; animIndex < _jelliesAnimations.length; animIndex++) {

            var myJelly:JellyAnimation = _jelliesAnimations[animIndex];

            var animation:EJellyAnimation = myJelly.jellyAnimation;
            var player:int = myJelly.playerSeat;


            if (event.keyCode == Keyboard.UP) {
                var number:int = Math.random() * _jelliesClass.length;
                animation = _jelliesClass[number];
            }

            if (event.keyCode == Keyboard.DOWN) {
                player = Math.random() * 4;
            }

			if (event.keyCode == Keyboard.DELETE) {
				System.gc();
			}

            myJelly.updateAnimation(
                    animation
                    , player);
        }
    }

    private function autoSwitchPlayers(event:Event):void {
        for (var animIndex:uint = 0; animIndex < _jelliesAnimations.length; animIndex++) {

            var myJelly:JellyAnimation = _jelliesAnimations[animIndex];

            var animation:EJellyAnimation = myJelly.jellyAnimation;
            var player:int = Math.random() * 4;

            myJelly.updateAnimation(
                    animation
                    , player);
        }
    }

    private function changeMode(drawingModeFunction:Function):void {
        while (_jelliesAnimations.length > 0) {
            _jelliesAnimations.pop();
        }

        while (_jelliesContainer.numChildren > 0) {
            _jelliesContainer.removeChildAt(0);
        }

        _drawingFunction = drawingModeFunction;
        _currentRowsCount = 0;

        addRows(1);
    }

    private function addRows(rowsCount:int):void {
        _drawingFunction(rowsCount);
//        displaySamplers();
    }

    private function displaySamplers():void {
        pauseSampling();
        System.gc();
        var deleteCount:int = 0, createdCount:int = 0;
        var samplers:Object = getSamples();
        for each(var sample:Sample in samplers) {
            if (sample is NewObjectSample) {
                createdCount++;
                var qualifiedClassName:String = getQualifiedClassName(NewObjectSample(sample).object);
                if (_CREATED_DICO[qualifiedClassName] == null) {
                    _CREATED_DICO[qualifiedClassName] = 0;
               }
                _CREATED_DICO[qualifiedClassName] += 1;
                _KEY_ID[NewObjectSample(sample).id] = qualifiedClassName;
            }
        }

        var samplers:Object = getSamples();
        for each(var sample:Sample in samplers) {
            if (sample is DeleteObjectSample) {
                var deleteObjectSample:DeleteObjectSample = DeleteObjectSample(sample);
                var qualifiedClassName:String = _KEY_ID[deleteObjectSample.id];
                if (qualifiedClassName != null) {
                    if (_DELETED_DICO[qualifiedClassName] == null) {
                        _DELETED_DICO[qualifiedClassName] = 0;
                    }
                    _DELETED_DICO[qualifiedClassName] += 1;
                }
                deleteCount++;
            }
        }
        trace("Samples : created: " + createdCount + ",  deleted: " + deleteCount);
        trace("CREATED: ");
        for (var object:String in _CREATED_DICO) {
            try {
                if (_CREATED_DICO[object] == 0) {
                    continue;
                }
                trace(object + " --> " + _CREATED_DICO[object]);
                _CREATED_DICO[object] = 0;
            } catch (error:Error) {

            }
        }

        trace("DELETED: ");
        for (var object:String in _DELETED_DICO) {
            try {
                if (_DELETED_DICO[object] == 0) {
                    continue;
                }
                trace(object + " --> " + _DELETED_DICO[object]);
                _DELETED_DICO[object] = 0;
            } catch (error:Error) {

            }
        }

        trace("------------------------");
        clearSamples();
        startSampling();
    }

    private function addNormalRows(rowsCount:int):void {
        var animation:DisplayObjectContainer;
        for (var colIndex:uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex:uint = _currentRowsCount; rowIndex < _currentRowsCount + rowsCount; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                }

                var jellyAnimation:EJellyAnimation = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)];

                animation = new jellyAnimation.animationClass();
                animation.mouseEnabled = false;
                animation.mouseChildren = false;

                if (colIndex == 0 && rowIndex == 0) {
                }
                (animation).y = rowIndex * 50 + 50;
                (animation).x = colIndex * 50 + 50;
                _jelliesContainer.addChild((animation));
            }
        }
        _currentRowsCount += rowsCount;
    }

    private function addPrerenderRows(rowsCount:int):void {

        var animation:JellyAnimation;

        for (var colIndex:uint = 0; colIndex < SIZE; colIndex++) {
            for (var rowIndex:uint = _currentRowsCount; rowIndex < _currentRowsCount + rowsCount; rowIndex++) {
                if (colIndex == 0 && rowIndex == 0) {
                }

                var jellyAnimation:EJellyAnimation = _jelliesClass[Math.floor(Math.random() * _jelliesClass.length)];
                animation = _jellyCatalogue.getJellyAnimation(Math.random() * 29 + 1);
                animation.updateAnimation(jellyAnimation, Math.random() * 4);

                if (colIndex == 0 && rowIndex == 0) {
                }
                (animation).y = rowIndex * 50 + 50;
                (animation).x = colIndex * 50 + 50;
                _jelliesContainer.addChild((animation));
                _jelliesAnimations.push(animation);
            }
        }
        _currentRowsCount += rowsCount;
    }

    private function removeRows(rowsCount:int):void {
        var objectToRemoveCount:int = rowsCount * SIZE;

        for (var i:uint = 0; i < objectToRemoveCount; i++) {
            if (_jelliesContainer.numChildren == 0) {
                return;
            }

            var objectRemoved:DisplayObject = _jelliesContainer.removeChildAt(_jelliesContainer.numChildren - 1);
			if (objectRemoved is JellyAnimation) {
				JellyAnimation(objectRemoved).dispose();
			}
            if (_drawingFunction == addPrerenderRows && _jelliesAnimations.indexOf(objectRemoved) != -1) {
                _jelliesAnimations.splice(_jelliesAnimations.indexOf(objectRemoved), 1);
            }
        }

        _currentRowsCount--;
    }


    private function sortList(list:Vector.<int>):void {
        var tempList:Vector.<int> = new Vector.<int>(list.length);
        fusionAndDivide(list, 0, list.length - 1, tempList);
    }

    private function fusionAndDivide(list:Vector.<int>, start:int, end:int, tempList:Vector.<int>):void {
        var info:String = ""
        for (var i:int = start; i <= end; i++) {
            info += " " + list[i];
        }
        // Only one element: we pass this step
        if ((start) == end) {
            return;
        }

        // Only two elements: soft sorting
        if (end == (start + 1)) {
            if (list[start] > list[end]) {
                var tempObject:int = list[end];
                list[end] = list[start];
                list[start] = tempObject;
            }
            return;
        }

        // Here we are:
        var pivot:int = Math.floor(( end - start ) / 2) + start;
        fusionAndDivide(list, start, pivot, tempList);
        fusionAndDivide(list, pivot + 1, end, tempList);

        // Sorting large array:
        var leftIndex:int = start, copyIndex = start;
        var rightIndex:int = pivot + 1;

        while (leftIndex <= pivot) {
            var currentObject:int = list[leftIndex];
            while (currentObject > list[rightIndex]) {
                tempList[copyIndex] = list[rightIndex];
                if (rightIndex == end) {
                    break;
                }
                rightIndex++;
                copyIndex++;
            }
            tempList[copyIndex] = list[leftIndex];

            copyIndex++;
            leftIndex++;
        }

        for (var i:int = start; i < rightIndex; i++) {
            list[i] = tempList[i];
        }
    }

    private var _jelliesAnimations:Vector.<JellyAnimation>
            = new Vector.<JellyAnimation>();

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
    private static const SIZE:int = 20;
    private var _currentRowsCount:int = 0;


    private var _prerenderingStartTime:Number;
    private var _jellyCatalogue:JellyAnimationCooker;
    private var _prerenderedMovieClipWorker:PrerenderedMovieClipWorker;
    private var _waitingAnimation:DisplayObject;
    private var _progressbar:Progressbar;
    private var _isAutoSwitching:Boolean = false;

    private var _infoContainer:Sprite;
    private var _jelliesContainer:Sprite;
    private var _drawingFunction:Function;

    private static const _CREATED_DICO:Dictionary = new Dictionary();
    private static const _DELETED_DICO:Dictionary = new Dictionary();
    private static const _KEY_ID:Dictionary = new Dictionary();
}
}
