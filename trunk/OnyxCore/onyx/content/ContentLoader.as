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
package onyx.content {
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.getQualifiedClassName;
	
	import onyx.core.*;
	import onyx.display.Display;
	import onyx.events.LayerContentEvent;
	import onyx.layer.LayerSettings;
	import onyx.net.*;
	import onyx.plugin.IContentObject;
	import onyx.transition.Transition;
	import onyx.utils.string.*;

	[Event(name='complete',			type='flash.events.Event')]
	[Event(name='security_error',	type='flash.events.SecurityErrorEvent')]
	[Event(name='io_error',			type='flash.events.IOErrorEvent')]
	[Event(name='progress',			type='flash.events.ProgressEvent')]

	/**
	 * 	Loads different content based on the file url
	 */
	public final class ContentLoader extends EventDispatcher {
		
		/**
		 * 	@private
		 * 	Stores paths of loaded stuff
		 */
		private static const _dict:Object = {};
		
		/**
		 * 	@private
		 * 	Registers a loader
		 */
		private static function registration(path:String):Registration {
			return _dict[path];
		}
		
		/**
		 * 
		 */
		private static function register(path:String, loader:Loader = null):void {
			
			var reg:Registration = _dict[path];
			
			if (!reg) {
				reg			= new Registration();
				reg.loader	= loader;
				_dict[path] = reg;
			}
			
			reg.refCount++;
		}
		
		/**
		 * 	Unregisters from shared
		 */
		public static function unregister(path:String):void {
			var reg:Registration = _dict[path];
			reg.refCount--;
			
			if (reg.refCount === 0) {
				reg.dispose();
				delete _dict[path];
			}
		}
		
		/**
		 * 	@private
		 * 	Gets registration
		 */
		private static function getRegistration(path:String):void {
		}
		
		/**
		 * 	@private
		 * 	Handler for when registrations are completed loading
		 */
		
		/**
		 * 	@private
		 */
		private var _settings:LayerSettings;
		
		/**
		 * 	@private
		 * 	Transition to load with
		 */
		private var _transition:Transition;
		
		/**
		 * 	@private
		 */
		private var _loaded:Boolean;

		/**
		 * 	@private
		 */
		private var _path:String;
		
		/**
		 * 	Loads a file
		 */
		public function load(path:String, settings:LayerSettings, transition:Transition):void {
			
			_path		= path;
			_settings	= settings || new LayerSettings();
			_transition = transition;
			
			var extension:String	= getExtension(path);
		
			// do different stuff based on the extension
			switch (extension) {
				
				case 'flv':
					var stream:Stream = new Stream(path);
					stream.addEventListener(Event.COMPLETE, _onStreamComplete);
					
					break;
					
				// TBD: Multiple cameras should use the same content as well
				case 'cam':
				
					var names:Array = Camera.names;
					var name:String = path.substr(0, path.length - 4);
					
					_dispatchContent(ContentCamera, Camera.getCamera(String(names.indexOf(name))), new Event(Event.COMPLETE));
					
					break;
					
				case 'mp3':
				
					var sound:Sound		= new Sound();
					sound.addEventListener(Event.COMPLETE, _onSoundHandler);
					sound.addEventListener(IOErrorEvent.IO_ERROR, _onSoundHandler);
					sound.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
					sound.load(new URLRequest(path));
					break;

				// load a loader if we're any other type of file
				case 'swf':

					var reg:Registration = registration(path);
				
				case 'jpg':
				case 'jpeg':
				case 'png':
				
					// check to see if it's to be a shared content object
					if (reg) {
						
						register(path);
						_createLoaderContent(reg.loader.contentLoaderInfo);
						
					} else {
						
						var loader:Loader = new Loader();
						
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,				_onLoadHandler);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE,						_onLoadHandler);
						loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,				_onLoadProgress);
						loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,	_onLoadHandler);
						
						loader.load(new URLRequest(path));
						
					}
					break;
			}
		}
		
		/**
		 * 	@private
		 * 	Handles events when a sound object retrieves it's ID3 information
		 */
		private function _onSoundHandler(event:Event):void {
			var sound:Sound = event.currentTarget as Sound;
			sound.removeEventListener(Event.COMPLETE, _onSoundHandler);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, _onSoundHandler);
			sound.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			
			_dispatchContent(ContentMP3, sound, event);
		}
		
		/**
		 * 	@private
		 * 	Dispatched when a stream receives meta data
		 */
		private function _onStreamComplete(event:Event):void {
			
			var stream:Stream = event.currentTarget as Stream;
			stream.removeEventListener(Event.COMPLETE, _onStreamComplete);
			
			_dispatchContent(ContentFLV, stream, event);

		}
		
		/**
		 * 	@private
		 * 	Progress handler, forward the event
		 */
		private function _onLoadProgress(event:ProgressEvent):void {
			dispatchEvent(event);
		}
		
		/**
		 * 	@private
		 * 	Handler for loaded loaders
		 */
		private function _onLoadHandler(event:Event):void {
			
			var info:LoaderInfo = event.currentTarget as LoaderInfo;
			
			info.removeEventListener(IOErrorEvent.IO_ERROR,				_onLoadHandler);
			info.removeEventListener(Event.COMPLETE,					_onLoadHandler);
			info.removeEventListener(ProgressEvent.PROGRESS,			_onLoadProgress);
			info.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,	_onLoadHandler);
			
			if (!(event is ErrorEvent)) {
				
				if (getQualifiedClassName(info.content) === 'flash.display::MovieClip') {
					
					var reg:Registration = registration(_path);
					
					// if something loaded before us, use it's loader instead of our own
					if (reg) {
						info = reg.loader.contentLoaderInfo;
					}
					
					register(_path, info.loader);
				}

				// load it
				_createLoaderContent(info, event);
			}
			
		}
		
		/**
		 * 	@private
		 */
		private function _createLoaderContent(info:LoaderInfo, event:Event = null):void {
			var loader:Loader	= info.loader;
			var type:Class = (loader.content is MovieClip) ? ContentMC : (loader.content is IContentObject) ? ContentCustom : ContentSprite;

			_dispatchContent(type, loader, event || new Event(Event.COMPLETE));
		}
		
		/**
		 * 	@private
		 */
		private function _dispatchContent(contentType:Class, reference:Object, event:Event):void {
			
			if (event is ErrorEvent) {
				dispatchEvent(event);
			} else {
				var dispatch:LayerContentEvent = new LayerContentEvent(Event.COMPLETE);
				dispatch.contentType	= contentType;
				dispatch.reference		= reference;
				dispatch.settings		= _settings;
				dispatch.transition 	= _transition;
				dispatch.path			= _path;
				dispatchEvent(dispatch);
			}
		}
		
		/**
		 * 	Dispose
		 */
		public function dispose():void {

			// dispose
			_settings	= null;
			_transition = null;

		}
	}
}

import onyx.content.ContentLoader;

import flash.display.Loader;

/**
 * 	Content registration
 */
class Registration {
	
	// how many objects are looking at this loader?
	public var refCount:int;
	
	//
	public var loader:Loader;

	/**
	 * 	Dispose and kill the content
	 */
	public function dispose():void {
		loader.unload();
		loader	= null;
	}
	
}