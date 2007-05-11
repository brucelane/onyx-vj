/** 
 * Copyright (c) 2003-2006, www.onyx-vj.com
 * All rights reserved.	
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 * -  Redistributions of source code must retain the above copyright notice, this 
 *    list of conditions and the following disclaimer.
 * 
 * -  Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * 
 * -  Neither the name of the www.onyx-vj.com nor the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 * 
 */
package ui.window {

	import flash.display.Shape;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.System;
	import flash.utils.*;
	
	import onyx.constants.*;
	import onyx.controls.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.events.*;
	import onyx.file.*;
	import onyx.jobs.*;
	import onyx.net.*;
	import onyx.states.StateManager;
	
	import ui.controls.*;
	import ui.core.UIObject;
	import ui.states.MidiLearnState;
	import ui.styles.*;

	public final class TempoWindow extends Window {

		/**
		 * 	@private
		 */
		private var _controlTempo:SliderV;
		
		/**
		 * 	@private
		 */
		private var _controlActive:DropDown
		
		/**
		 * 	@private
		 */
		private var _tapTempo:TempoShape	= new TempoShape();
		
		/**
		 * 	@private
		 */
		private var _releaseTimer:Timer		= new Timer(50);
		
		/**
		 * 	@private
		 */
		private var _samples:Array			= [0];
		
		/**
		 * 	@constructor
		 */
		public function TempoWindow():void {
			
			// super!
			super('TEMPO', 202, 34);
			
			var display:IDisplay	= Display.getDisplay(0);
			var control:Control;

			// create new ui options
			var options:UIOptions	= new UIOptions();
			options.width			= 60;
			
			// tempo controls
			_controlTempo			= new SliderV(options, TEMPO.controls.getControl('tempo'));
			_controlActive			= new DropDown(options, TEMPO.controls.getControl('snapTempo'));
			
			// add controls
			addChildren(	
				_controlActive,	2,		20,
				_controlTempo,	70,		20,
				_tapTempo,		138,	20
			);

			// start the timer
			TEMPO.addEventListener(TempoEvent.CLICK, _onTempo);
			
			// tap tempo click
			_tapTempo.addEventListener(MouseEvent.MOUSE_DOWN, _onTempoDown);
			
		}

		/**
		 * 	@private
		 */
		private function _onTempoDown(event:Event):void {
			
			var time:int = getTimer();
			
			if (time - _samples[_samples.length - 1] > 1000) {
				_samples = [time];
			} else {
				_samples.push(time);
			}
			
			var len:int = _samples.length;
			
			if (len > 2) {

				var total:int	= 0;
	
				for (var count:int = 1; count < len; count++) {
					total += _samples[count] - _samples[count - 1];
				}

				total /= (count - 1);
				TEMPO.tempo = (total / 4);
			} else {
				TEMPO.start();
			}
			
			if (len > 8) {
				_samples.shift();
			}

		}
		
		/**
		 * 	@private
		 */
		private function _onTempo(event:TempoEvent):void {
			if (event.beat % 4 === 0) {
				_tapTempo.transform.colorTransform = (event.beat % 16 == 0) ? TEMPO_BEAT : TEMPO_CLICK;
				_releaseTimer.addEventListener(TimerEvent.TIMER, _onTempoOff);
				_releaseTimer.start();
			}
		}
		
		/**
		 * 	@private
		 */
		private function _onTempoOff(event:TimerEvent):void {
			_tapTempo.transform.colorTransform = DEFAULT;
			_releaseTimer.removeEventListener(TimerEvent.TIMER, _onTempoOff);
			_releaseTimer.stop();
		}

	}
}

import flash.display.Sprite;

/**
 * 	Tempo shape
 */
class TempoShape extends Sprite {
	
	/**
	 * 	@constructor
	 */
	public function TempoShape():void {
		
		graphics.beginFill(0xAAAAAA);
		graphics.drawRect(0,0,20,10);
		graphics.endFill();
		
	}
}