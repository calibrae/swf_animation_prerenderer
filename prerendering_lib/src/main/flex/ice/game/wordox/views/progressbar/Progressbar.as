/**
 * Created with IntelliJ IDEA.
 * User: fred
 * Date: 27/08/12
 * Time: 11:45
 * To change this template use File | Settings | File Templates.
 */
package ice.game.wordox.views.progressbar {
import flash.display.Graphics;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;

public class Progressbar extends Sprite {

    public function Progressbar(width:int, height:int, prefixLabel:String = "", showPercent:Boolean = false) {
		_progressHeight = height;
		_progressWidth = width;
		_prefixLabel = prefixLabel;
		_showPercent = showPercent;
		_backgroundSprite = new Sprite();
		var textSprite:Sprite = new Sprite();

		this.addChild(_backgroundSprite);
		this.addChild(textSprite);

		_labelTextfield = new TextField();
		_labelTextfield.defaultTextFormat = new TextFormat("arial", 12, 0xFFFFFF, true, null, null, null, null,
				"center");
		_labelTextfield.width = width;
		_labelTextfield.height = height;
		_labelTextfield.filters = [new GlowFilter(0x1DA7E0, 1, 4, 4)];
		textSprite.addChild(_labelTextfield);

		this.mouseChildren = this.mouseEnabled = false;

		refreshBar();
	}

    public function updateValue(currentValue:int, maxValue:int):void {
        _currentValue = currentValue;
        _maxValue = maxValue;
        refreshBar();
    }

    private function refreshBar():void {
        var graphics:Graphics = _backgroundSprite.graphics;
        graphics.clear();

        graphics.beginFill(0xCCCCDD);
        graphics.drawRoundRect(0, 0, _progressWidth, _progressHeight, _ELLIPSE, _ELLIPSE);
        graphics.endFill();

        graphics.beginFill(0xFFFFFF, 0.8);
        var maxSize:int = _progressWidth - _INTERNAL_DELTA * 2;
        var currentWidth:int = maxSize * _currentValue / _maxValue;
        graphics.drawRoundRect(_INTERNAL_DELTA, _INTERNAL_DELTA, _progressWidth - _INTERNAL_DELTA * 2, _progressHeight - _INTERNAL_DELTA * 2, _ELLIPSE - 4, _ELLIPSE - 4);
        graphics.endFill();

        graphics.beginFill(0x1DA7E0);
        graphics.drawRoundRect(_INTERNAL_DELTA, _INTERNAL_DELTA, currentWidth, _progressHeight - _INTERNAL_DELTA * 2, _ELLIPSE - 4, _ELLIPSE - 4);
        graphics.endFill();

        _labelTextfield.text = _prefixLabel + " " +
                (_showPercent ?
                int(_currentValue / _maxValue * 100) + " %  "
                : "")
                + "(" + _currentValue + "/" + _maxValue + ")";
        _labelTextfield.y = (_progressHeight - _labelTextfield.textHeight) / 2;
    }

    private var _backgroundSprite: Sprite;

    private var _progressWidth:int;
    private var _progressHeight:int;
    private var _maxValue:int;
    private var _currentValue:int;
    private var _labelTextfield:TextField;
    private var _prefixLabel:String;
    private var _showPercent:Boolean;

    private static const _ELLIPSE:int = 16;
    private static const _INTERNAL_DELTA:int = 4;

}
}
