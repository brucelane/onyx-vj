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
package onyx.sound {
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import onyx.events.SpectrumEvent;

	public final class SpectrumAnalyzer extends EventDispatcher {
		
		// this stores our global spectrum analyzer
		private static var _analyzer:SpectrumAnalyzer	= new SpectrumAnalyzer();

		// gets the global analyzer - use this if you want to sync to the main
		public static function getGlobal():SpectrumAnalyzer {
			return _analyzer;
		}
		
		// sample at 11.025 khz
		private var _sampleRate:int						= 2;
		
		// resolution (number of bands to skip when analyzing) -- 1:1 is checking every band ... 8 skips bands
		private var _resolution:int						= 1;
		
		// stores our bytearray
		private var _bytes:ByteArray					= new ByteArray();
		
		// saves the ranges of which spectrums we're going to analyze
		private var _ranges:Array						= [];
		
		// stores our timer for analysis (10 frames per second)
		private var _timer:Timer						= new Timer(40);
		
		// stores the combined channels
		private var _analysis:Array;
		
		/**
		 * 	@constructor
		 **/
		public function SpectrumAnalyzer():void {
			
		}
		
		// adds a spectrum trigger
		public function addTrigger(trigger:SpectrumTrigger):void {
			_ranges.push(trigger);
			
			if (!_timer.running) {
				start();
			}
		}
		
		// removes a spectrum trigger
		public function removeTrigger(trigger:SpectrumTrigger):void {
			
			// if nothing is listening for the analyzing event, stop it
			if (!_ranges.length && !this.hasEventListener(SpectrumEvent.SPECTRUM_ANALYZED)) {
				stop();
			}
		}

		// starts the analyzing
		public function start():void {
//			_timer.addEventListener(TimerEvent.TIMER, _analyzeSpectrum);
//			_timer.start();
		}
		
		// stops the analyzing
		public function stop():void {
		}

		// analyze all our stuff!
		private function _analyzeSpectrum(event:TimerEvent):void {
			
			var start:int = getTimer(), i:int;
			
			// grab our bytes
			SoundMixer.computeSpectrum(_bytes, true, 2);

			_analysis = [];
			
			_bytes.position = 0;

			// loop through the left channel
			for (i = 0; i < 256; i++) {
			 	analysis[i] = _bytes.readFloat();
			}

			// loop through the right channel
//			for (i = 0; i < 256; i++) {
//			 	analysis[i] = Math.max(_bytes.readFloat(), analysis[i]);
//			}
	        
			for each (var trigger:SpectrumTrigger in _ranges) {
				trigger.analyze(analysis);
			}
	        
			// dispatch an event
			var spectrumEvent:SpectrumEvent = new SpectrumEvent(SpectrumEvent.SPECTRUM_ANALYZED);
			spectrumEvent.analysis = analysis;
			
			// dispatch that we've analyzed the bytes
			dispatchEvent(spectrumEvent);
			
		}
		
		// adds a listener
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);

			if (this.hasEventListener(SpectrumEvent.SPECTRUM_ANALYZED) && !_timer.running) {
				start();
			}
		}

		// returns our bytes
		public function get bytes():ByteArray {
			return _bytes;
		}
		
		// sets the rate
		public function set rate(r:int):void {
			_timer.delay = r;
		}
		
		// gets the rate of the timer (for analysis)
		public function get rate():int {
			return _timer.delay;
		}
		
		// returns the analysis array
		public function get analysis():Array {
			return _analysis;
		}
		
	}
}