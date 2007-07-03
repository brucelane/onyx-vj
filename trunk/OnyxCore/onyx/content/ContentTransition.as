/** 
 * Copyright (c) 2003-2007, www.onyx-vj.com
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
package onyx.content {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.getTimer;
	
	import onyx.constants.*;
	import onyx.controls.*;
	import onyx.core.*;
	import onyx.display.*;
	import onyx.events.*;
	import onyx.plugin.*;
	
	use namespace onyx_ns;
	
	[ExcludeClass]
	public final class ContentTransition extends Content {
		
		/**
		 * 	@private
		 * 	Stores old content
		 */
		onyx_ns var oldContent:Content;

		/**
		 * 	@private
		 * 	Stores new content
		 */
		onyx_ns var newContent:Content;

		/**
		 * 	@private
		 * 	Stores transition
		 */
		private var _transition:Transition;
		
		/**
		 * 	@private
		 * 	Stores the start of the transition
		 */
		private var _startTime:uint;
		
		/**
		 * 	@constructor
		 */
		public function ContentTransition(layer:Layer, transition:Transition, current:IContent, loaded:IContent):void {

			// super!
			super(layer, null, null);

			// initialize transition			
			_transition = transition;
			
			// store content
			oldContent	= current as Content,
			newContent = loaded as Content;
			
			// add listeners for filter events
			newContent.addEventListener(FilterEvent.FILTER_APPLIED,		_forwardEvents);
			newContent.addEventListener(FilterEvent.FILTER_MOVED,		_forwardEvents);
			newContent.addEventListener(FilterEvent.FILTER_REMOVED,		_forwardEvents);
			oldContent.addEventListener(FilterEvent.FILTER_APPLIED,		_forwardEvents);
			oldContent.addEventListener(FilterEvent.FILTER_MOVED,		_forwardEvents);
			oldContent.addEventListener(FilterEvent.FILTER_REMOVED,		_forwardEvents);
			
			// change the target properties to the new content
			layer.properties.target = newContent;

			// initialize the transition
			_transition.setContent(current, loaded);

			// initialize the transition
			_transition.initialize();

			// set time			
			_startTime = getTimer();

		}
		
		/**
		 * 	@private
		 * 	Forward events from the new content
		 */
		private function _forwardEvents(event:Event):void {
			super.dispatchEvent(event);
		}
		
		/**
		 * 	Renders the bitmap
		 */
		override public function render():RenderTransform {
			
			// get the time of the transition
			var ratio:Number = (getTimer() - _startTime) / _transition.onyx_ns::_duration;
			
			// get out!
			if (ratio > 1) {

				endTransition();
								
				return null;
				
			}

			// check bitmap transition			
			if (_transition is IBitmapTransition) {
				
				_transition.apply(ratio);
				(_transition as IBitmapTransition).render(_source, ratio);
				
			// otherwise just normal render
			} else {
				
				oldContent.render();
				newContent.render();
				
				_transition.apply(ratio);

				_source.copyPixels(oldContent.rendered, BITMAP_RECT, POINT);
				_source.draw(newContent.rendered);

			}
			
			return null;
		}
		
		/**
		 * 	Gets alpha
		 */
		override public function get alpha():Number {
			return newContent.alpha;
		}

		/**
		 * 	Sets alpha
		 */
		override public function set alpha(value:Number):void {
			newContent.alpha = value;
		}
		
		/**
		 * 	Tint
		 */
		override public function set tint(value:Number):void {
			newContent.tint = value;
		}
		
		/**
		 * 	Sets color
		 */
		override public function set color(value:uint):void {
			newContent.color = value;
		}

		/**
		 * 	Gets color
		 */
		override public function get color():uint {
			return newContent.color;
		}

		/**
		 * 	Gets tint
		 */
		override public function get tint():Number {
			return newContent.tint;
		}
		
		/**
		 * 	Sets x
		 */
		override public function set x(value:Number):void {
			newContent.x = value;
		}

		/**
		 * 	Sets y
		 */
		override public function set y(value:Number):void {
			newContent.y = value;
		}

		override public function set scaleX(value:Number):void {
			newContent.scaleX = value;
		}

		override public function set scaleY(value:Number):void {
			newContent.scaleY = value;
		}
		
		override public function get scaleX():Number {
			return newContent.scaleX;
		}

		override public function get scaleY():Number {
			return newContent.scaleY;
		}

		override public function get x():Number {
			return newContent.x;
		}

		override public function get y():Number {
			return newContent.y;
		}
		
		/**
		 * 	Gets saturation
		 */
		override public function get saturation():Number {
			return newContent.saturation;
		}
		
		/**
		 * 	Sets saturation
		 */
		override public function set saturation(value:Number):void {
			newContent.saturation = value;
		}

		/**
		 * 	Gets contrast
		 */
		override public function get contrast():Number {
			return newContent.contrast;
		}

		/**
		 * 	Sets contrast
		 */
		override public function set contrast(value:Number):void {
			newContent.contrast = value
		}

		/**
		 * 	Gets brightness
		 */
		override public function get brightness():Number {
			return newContent.brightness;
		}
		
		/**
		 * 	Sets brightness
		 */
		override public function set brightness(value:Number):void {
			newContent.brightness = value;
		}

		/**
		 * 	Gets threshold
		 */
		override public function get threshold():int {
			return newContent.threshold;
		}
		
		/**
		 * 	Sets threshold
		 */
		override public function set threshold(value:int):void {
			newContent.threshold = value;
		}
		
		/**
		 *	Returns rotation
		 */
		override public function get rotation():Number {
			return newContent.rotation;
		}

		/**
		 *	@private
		 * 	Sets rotation
		 */
		override public function set rotation(value:Number):void {
			newContent.rotation = value;
		}

		/**
		 * 	Adds a filter
		 */
		override public function addFilter(filter:Filter):void {
			newContent.addFilter(filter);
		}

		/**
		 * 	Removes a filter
		 */		
		override public function removeFilter(filter:Filter):void {
			newContent.removeFilter(filter);
		}
		
		/**
		 * 	Returns filters
		 */
		override public function get filters():Array {
			return newContent.filters;
		}
		
		/**
		 * 	Gets a filter's index
		 */
		override public function getFilterIndex(filter:Filter):int {
			return newContent.getFilterIndex(filter);
		}
		
		/**
		 * 	Moves a filter to an index
		 */
		override public function moveFilter(filter:Filter, index:int):void {
			newContent.moveFilter(filter, index);
		}
				
		/**
		 * 	Sets the time
		 */
		override public function set time(value:Number):void {
			newContent.time = value;
		}
		
		/**
		 * 	Gets the time
		 */
		override public function get time():Number {
			return newContent.time;
		}
		
		/**
		 * 	Gets the total time
		 */
		override public function get totalTime():int {
			return newContent.totalTime;
		}
		
		/**
		 * 	Pauses content
		 */
		override public function pause(value:Boolean = true):void {
			newContent.pause(value);
		}
				
		/**
		 * 	Gets the framerate
		 */
		override public function get framerate():Number {
			return newContent.framerate;
		}

		/**
		 * 	Sets framerate
		 */
		override public function set framerate(value:Number):void {
			newContent.framerate = value;
		}
		
		/**
		 * 	Gets the beginning loop point
		 */
		override public function get loopStart():Number {
			return newContent.loopStart;
		}
		
		/**
		 * 	Sets the beginning loop point (percentage)
		 */		
		override public function set loopStart(value:Number):void {
			newContent.loopStart = value;
		}
		
		/**
		 * 	Gets the beginning loop point
		 */
		override public function get loopEnd():Number {
			return newContent.loopEnd;
		}

		/**
		 * 	Sets the end loop point
		 */
		override public function set loopEnd(value:Number):void {
			newContent.loopEnd = value;
		}

		/**
		 * 	Returns the bitmap source
		 */
		override public function get source():BitmapData {
			return newContent.source;
		}
		
		/**
		 * 	Sets blendmode
		 */
		override public function set blendMode(value:String):void {
			newContent.blendMode = value;
		}
		
		/**
		 * 	Returns content controls
		 */
		override public function get controls():Controls {
			return newContent.controls;
		}
		
		/**
		 * 
		 */
		override public function set matrix(value:Matrix):void {
			newContent.matrix = value;
		}
		
		/**
		 * 	Dispose
		 */
		override public function dispose():void {
			
			super.dispose();
			
			// clean transition
			_transition.clean();
		
			// remove listeners
			newContent.removeEventListener(FilterEvent.FILTER_APPLIED,		_forwardEvents);
			newContent.removeEventListener(FilterEvent.FILTER_MOVED,		_forwardEvents);
			newContent.removeEventListener(FilterEvent.FILTER_REMOVED,		_forwardEvents);
			oldContent.removeEventListener(FilterEvent.FILTER_APPLIED,		_forwardEvents);
			oldContent.removeEventListener(FilterEvent.FILTER_MOVED,		_forwardEvents);
			oldContent.removeEventListener(FilterEvent.FILTER_REMOVED,		_forwardEvents);

			// destroy the old content
			oldContent.dispose();
			
			// clear out
			_transition	= null,
			oldContent	= null,
			newContent	= null;
		}
		
		/**
		 * 	Get the rendered
		 */
		override public function get rendered():BitmapData {
			return _source;
		}
		
		/**
		 * 	Dispatches an event over to the new content
		 */
		override public function dispatchEvent(event:Event):Boolean {
			return newContent.dispatchEvent(event);
		}
		
		/**
		 * 
		 */
		override public function get path():String {
			return newContent.path;
		}
		
		/**
		 * 
		 */
		public function endTransition():void {
			super.dispatchEvent(new TransitionEvent(TransitionEvent.TRANSITION_END, newContent));
		}

 	}
}