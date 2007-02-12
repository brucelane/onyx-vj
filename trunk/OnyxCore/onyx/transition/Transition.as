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
package onyx.transition {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import onyx.content.Content;
	import onyx.content.IContent;
	import onyx.controls.*;
	import onyx.core.IDisposable;
	import onyx.core.PluginBase;
	import onyx.core.RenderTransform;
	import onyx.core.getBaseBitmap;
	import onyx.core.onyx_ns;
	import onyx.events.TransitionEvent;
	import onyx.plugin.IRenderable;
	import onyx.plugin.Plugin;
	import onyx.tween.easing.Linear;
	
	use namespace onyx_ns;
	
	/**
	 * 	Transition
	 */
	public class Transition extends PluginBase implements IControlObject {

		/**
		 * 	@private
		 * 	Stores definitions
		 */
		private static var _definition:Object	= new Object();
		
		/**
		 * 	@private
		 */
		private static var _transitions:Array		= [];
		
		/**
		 * 	Registers a plugin
		 */
		onyx_ns static function registerPlugin(plugin:Plugin):void {
			_definition[plugin.name] = plugin;
			_transitions.push(plugin);
			
		}

		/**
		 * 	Returns a definition
		 */
		public static function getDefinition(name:String):Plugin {
			return _definition[name];
		}
		
		/**
		 * 
		 */
		public static function get transitions():Array {
			return _transitions.concat();
		}
		
		/**
		 * 	@private
		 * 	Stores duration of the transition
		 */
		onyx_ns var _duration:int;
		
		/** 
		 * 	@private
		 * 	The content that is currently loaded
		 */
		protected var currentContent:IContent;

		/** 
		 * 	@private
		 * 	The new content that is loading in
		 */
		protected var loadedContent:IContent;
		
		/**
		 * 	@private
		 * 	Stores transition controls
		 */
		private var _controls:Controls;
		
		/**
		 * 	@private
		 */
		private var _easing:Function;
		
		/**
		 * 	@constructor
		 */
		public function Transition(easing:Function = null):void {
			_easing	 	= easing || Linear.easeIn;
			
			_controls = new Controls(this);
		}
		
		/**
		 * 	Returns name of the transition
		 */
		final public function get name():String {
			return _name;
		}

		/**
		 * 	Called when the transition is first loaded
		 */
		public function initialize():void {
		}
		
		/**
		 * 	Renders content onto the source bitmap
		 * 	@returns	Return true if Onyx is to render the content
		 * 	@returns	Return false if the Transition will render the content itself
		 */
		public function apply(ratio:Number):void {
		}
		
		/**
		 * 	Sets duration
		 */		
		final public function set duration(value:int):void {
			_duration = value;
		}
		
		/**
		 * 	Gets duration
		 */
		final public function get duration():int {
			return _duration;
		}
		
		/**
		 * 	Internal function that sets the old and new content variables
		 */
		onyx_ns final function setContent(current:IContent, loaded:IContent):void {
			currentContent	= current;
			loadedContent	=  loaded;
		}
		
		/**
		 * 	Controls for the transition
		 */
		final public function get controls():Controls {
			return _controls;
		}

		/**
		 * 	Clones a transition
		 */
		final public function clone():Transition {
			
			var plugin:Plugin = Transition.getDefinition(_name);
			var transition:Transition = plugin.getDefinition() as Transition;
			
			// loops through controls
			for each (var control:Control in _controls) {
				var newControl:Control = transition.controls.getControl(control.name);
				newControl.value = control.value;
			}
			
			transition._duration = _duration;
			
			return transition;
		}
		
		/**
		 * 	Destroys
		 */
		public function dispose():void {
			
			currentContent	= null;
			loadedContent	= null;
		}
	}
}