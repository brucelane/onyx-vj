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
package onyx.layer {

	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import onyx.content.*;
	import onyx.controls.*;
	import onyx.core.*;
	import onyx.events.*;
	import onyx.filter.*;
	import onyx.net.Stream;
	import onyx.transition.Transition;
	
	use namespace onyx_internal;
	
	[Event(name="filter_applied",	type="onyx.events.FilterEvent")]
	[Event(name="filter_removed",	type="onyx.events.FilterEvent")]
	[Event(name="filter_moved",		type="onyx.events.FilterEvent")]
	[Event(name="layer_loaded",		type="onyx.events.LayerEvent")]
	[Event(name="layer_moved",		type="onyx.events.LayerEvent")]
	[Event(name="progress",			type="flash.events.Event")]

	/**
	 * 	Layer is the base media for all video objects
	 */
	public class Layer extends Sprite implements ILayer {
		
		/**
		 * 	@private
		 * 	Stores the transition for layer
		 */
		private var _transition:Transition;

		/**
		 * 	@private
		 * 	Stores the content
		 */
		private var _content:IContent			= new ContentNull();

		/**
		 * 	@private
		 */
		private var _settings:LayerSettings;
		
		/**
		 * 	@private
		 * 	The url request for the layer path
		 */
		private var _request:URLRequest;
		
		/**
		 * 	Creates the base bitmap
		 */
		private var _source:BitmapData			= getBaseBitmap();

		/**
		 * 	@private
		 * 	Controls
		 */
		private const _controls:Controls = new Controls(this,
		
			new ControlNumber(	LayerProperties.DISPLAY_ALPHA,				null,	0,		1,		1),
			new ControlRange(	LayerProperties.DISPLAY_BLENDMODE,			null,	BLEND_MODES,	0),
			new ControlNumber(	LayerProperties.DISPLAY_BRIGHTNESS,			null,	-1,		1,		0),
			new ControlNumber(	LayerProperties.DISPLAY_CONTRAST,			null,	-1,		2,		0),
			new ControlNumber(	LayerProperties.DISPLAY_SCALEX,				null,	-5,		5,		1),
			new ControlNumber(	LayerProperties.DISPLAY_SCALEY,				null,	-5,		5,		1),
			new ControlNumber(	LayerProperties.DISPLAY_ROTATION,			null,	-360,	360,	0),
			new ControlNumber(	LayerProperties.DISPLAY_SATURATION,			null,	0,		2,		1),
			new ControlInt(		LayerProperties.DISPLAY_THRESHOLD,			null,	0,		100,	0),
			new ControlNumber(	LayerProperties.DISPLAY_TINT,				null,	0,		1,		0),
			new ControlNumber(	LayerProperties.DISPLAY_X,					null,	-5000,	5000,	0),
			new ControlNumber(	LayerProperties.DISPLAY_Y,					null,	-5000,	5000,	0),
			new ControlUInt  (	LayerProperties.DISPLAY_COLOR, 				null),
			new ControlNumber(	LayerProperties.DISPLAY_TIME,				null,	0,		1,	0),
			new ControlNumber(	LayerProperties.PLAYHEAD_RATE,				null,	-20,	20,	1),

			new ControlNumber(	LayerProperties.PLAYHEAD_START,				null,	0,	1,	0),
			new ControlNumber(	LayerProperties.PLAYHEAD_END,				null,	0,	1,	1)

		);
		

		/**
		 * 	@private
		 * 	Stores the index of the layer within the display
		 */
		onyx_internal var _index:int				= -1;


		/**
		 *	Constructor
		 */
		public function Layer():void {
		}

		/**
		 * 	Returns the index of the layer within the display
		 **/
		public function get index():int {
			return _index;
		}
		
		/**
		 * 	Loads a file type into a layer
		 * 	The path of the file to load into the layer
		 **/
		public function load(request:URLRequest, settings:LayerSettings = null, transition:Transition = null):void {
			
			// do we have settings?
			_settings = settings;
			
			// do we have a transition?
			this.transition = transition;
			
			trace(transition);
			
			// store the request
			_request = request;
			
			var loader:ContentLoader = new ContentLoader(request);
			loader.addEventListener(ContentEvent.CONTENT_STATUS, _onContentStatus);
			loader.addEventListener(ProgressEvent.PROGRESS, _forwardEvents);
		}
		
		/**
		 * 	@private
		 * 	Content Status Handler
		 */
		private function _onContentStatus(event:ContentEvent):void {
			
			// if we have content, we have a successful load
			if (event.content) {
				
				var loaderObj:Object = event.content;
				
				_createContent(loaderObj);
				
			// there was an error, dispatch it
			} else {
				
			}
		}
		
		/**
		 * 	@private
		 * 	Initializes Content
		 */
		private function _createContent(metadata:Object):void {

			_destroyContent();

			// create the content based on the passed in object
			if (metadata is Loader) {
				var content:IContent = new ContentSWFMovieClip(metadata as Loader);
				
				if (_transition && !(_content is ContentNull)) {
					_transition.initializeTransition(_content, content, this);	
				}

				_content = content;
			}
			
			// if it's a displayobject, add it
			if (_content is DisplayObject) {
				addChild(_content as DisplayObject);
			}
			
			// listen for events to forward			
			_content.addEventListener(FilterEvent.FILTER_APPLIED, _forwardEvents);
			_content.addEventListener(FilterEvent.FILTER_MOVED, _forwardEvents);
			_content.addEventListener(FilterEvent.FILTER_REMOVED, _forwardEvents);
			
			// dispatch a load event
			var dispatch:LayerEvent = new LayerEvent(LayerEvent.LAYER_LOADED, this);
			dispatch.layer = this;
			dispatchEvent(dispatch);
			
			// if there are settings, apply them
			if (_settings) {
				_settings.apply(this);
				_settings = null;
			}

			// dispatch the controls to update
			_controls.update();
		}
		
		/**
		 * 	@private
		 * 	Destroys the current content state
		 */
		private function _destroyContent():void {
			
			_content.removeEventListener(FilterEvent.FILTER_APPLIED, _forwardEvents);
			_content.removeEventListener(FilterEvent.FILTER_MOVED, _forwardEvents);
			_content.removeEventListener(FilterEvent.FILTER_REMOVED, _forwardEvents);
			
			// destroys the earlier content
			_content.dispose();
			
		}
		
		/**
		 * 	@private
		 * 	Listens for events and forwards them
		 */
		private function _forwardEvents(event:Event):void {
			dispatchEvent(event.clone());
		}
		
		/**
		 * 	@private
		 * 	This is called when content has finished loading from a contentLoader;
		 *	The loader which is loading content (swf, jpg, png, etc)
		 **/
		private function _addContent(content:IContent):void {

			// content is null
			if (_content is ContentNull) {

				// create new bitmap
//				bitmapData = getBaseBitmap();

			}
			
			// now test to see if we have a transition
			/*
			if (transitionClass && !(_content is ContentNull)) {

				_transition = new transitionClass(transitionDuration);
				_transition.initializeTransition(_content, content, this);

				_content = content;

				removeEventListener(Event.ENTER_FRAME, _render);
				addEventListener(Event.ENTER_FRAME, _renderTransition);
				
				_renderTransition();

			} else {

				// kill old content
				_content.dispose();

				_content = content;

				// render frames
				removeEventListener(Event.ENTER_FRAME, _renderTransition);
				addEventListener(Event.ENTER_FRAME, _render);
				
				// render
				_render();

			}
			*/
		}

		/**
		 * 	Sets time
		 */
		public function set time(value:Number):void {
			_content.time = value;
		}
		
		/**
		 * 	Gets time
		 */
		public function get time():Number {
			return _content.time;
		}
		
		/**
		 * 	Gets totalTime
		 */
		public function get totalTime():Number {
			return _content.totalTime;
		}

		/**
		 * 	Sets the playhead time
		 */
		public function set timePercent(value:Number):void {
			_content.time = value;
		}
		
		/**
		 * 	Returns the path of the file loaded
		 */
		public function get path():String {
			return (_request) ? _request.url : null;
		}
		
		/**
		 * 	Returns the control array of the layer
		 */
		public function get controls():Controls {
			return _controls;
		}

		/**
		 * 	Gets the framerate of the movie adjusted to it's own time rate
		 */
		public function get framerate():Number {
			return _content.framerate;
		}

		/**
		 * 	Sets the framerate
		 */
		public function set framerate(value:Number):void {
			_content.framerate = value;
		}

		/**
		 * 	Gets the start loop point
		 */
		public function get loopStart():Number {
			return _content.loopStart;
		}

		/**
		 * 	Sets the start loop point
		 */
		public function set loopStart(value:Number):void {
			_content.loopStart = value;
		}

		/**
		 * 	Gets the start marker
		 */
		public function get loopEnd():Number {
			return _content.loopEnd;
		}

		/**
		 * 	Sets the right loop point for the video
		 */
		public function set loopEnd(value:Number):void {
			_content.loopEnd = value;
		}

		/**
		 * 	Pauses the layer
		 *	@param			True to pause, false to unpause
		 */
		public function pause(b:Boolean = true):void {
			_content.pause(b);
		}
		
		/**
		 * 	Returns a bitmapdata of the source file
		 **/
		public function get source():BitmapData {
			return _source;
		}
		
		/**
		 * 	Moves the layer up in the display list
		 */
		public function moveUp():void {
			dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVE_UP, this));
		}

		/**
		 * 	Moves the layer down the display list
		 */
		public function moveDown():void {
			dispatchEvent(new LayerEvent(LayerEvent.LAYER_MOVE_DOWN, this));
		}

		/**
		 * 	Copys the layer down
		 */
		public function copyLayer():void {
			dispatchEvent(new LayerEvent(LayerEvent.LAYER_COPY_LAYER, this));
		}

		/**
		 * 	Returns the threshold
		 */
		public function get threshold():int {
			return _content.threshold;
		}

		/**
		 * 	Sets the threshold
		 */
		public function set threshold(value:int):void {
			_content.threshold = value;
		}
	
		/**
		 * 	Returns contrast
		 */
		public function get contrast():Number {
			return _content.contrast;
		}
		
		/**
		 * 	Sets contrast
		 */
		public function set contrast(value:Number):void {
			_content.contrast = value;
		}

		/**
		 * 	Gets brightness
		 */
		public function get brightness():Number {
			return _content.brightness;
		}
		
		/**
		 * 	Sets brightness
		 */
		public function set brightness(value:Number):void {
			_content.brightness = value;
		}

		/**
		 * 	Sets saturation
		 */
		public function get saturation():Number {
			return _content.saturation;
		}

		/**
		 * 	Gets saturation
		 */
		public function set saturation(value:Number):void {
			_content.saturation = value;
		}

		/**
		 * 	Returns tint
		 */
		public function get tint():Number {
			return _content.tint;
		}
		
		/**
		 * 	Sets tint
		 */
		public function set tint(value:Number):void {
			_content.tint = value;
		}

		/**
		 * 	Sets color
		 */
		public function set color(value:uint):void {
			_content.color = value;
		}

		/**
		 * 	Gets color of current content
		 */
		public function get color():uint {
			return _content.color;
		}
		
		/**
		 * 	Sets alpha of current content
		 */
		override public function set alpha(value:Number):void {
			_content.alpha = value;
		}

		/**
		 * 	Gets alpha of current content
		 */
		override public function get alpha():Number {
			return _content.alpha;
		}

		/**
		 * 	Sets the x of current content
		 */
		override public function set x(value:Number):void {
			_content.x = value;
		}

		/**
		 * 	Sets the y of current content
		 */
		override public function set y(value:Number):void {
			_content.y = value;
		}

		/**
		 * 	Sets scaleX for current content
		 */
		override public function set scaleX(value:Number):void {
			_content.scaleX = value;
		}

		/**
		 * 	Sets scaleY for current content
		 */
		override public function set scaleY(value:Number):void {
			_content.scaleY = value;
		}
		
		/**
		 * 	Gets scaleX for current content
		 */
		override public function get scaleX():Number {
			return _content.scaleX;
		}

		/**
		 * 	Gets scaleY for current content
		 */
		override public function get scaleY():Number {
			return _content.scaleY;
		}

		/**
		 * 	Gets x for current content
		 */
		override public function get x():Number {
			return _content.x;
		}

		/**
		 * 	Gets y for current content
		 */
		override public function get y():Number {
			return _content.y;
		}
		
		/**
		 * 	Gets content rotation
		 */
		override public function get rotation():Number {
			return _content.rotation / RADIANS;
		}

		/**
		 * 	Sets content rotation
		 */
		override public function set rotation(value:Number):void {
			_content.rotation = value * RADIANS;
		}

		/**
		 * 	Sets the transition for the layer
		 */
		public function set transition(value:Transition):void {
			
			if (_transition) {
				_transition.dispose();
			}
			
			_transition = value;
			
			// if we're not setting it to null
			if (value) {
				_transition.addEventListener(TransitionEvent.TRANSITION_END, _endTransition);
			}
		}
		
		/**
		 * 	Adds an onyx-based filter
		 * 	The onyx filter to add to the Layer
		 */
		public function addFilter(filter:Filter):void {
			_content.addFilter(filter);
		}
		
		/**
		 * 	Removes an onyx filter from the layer
		 * 	@param		The filter to remove
		 **/
		public function removeFilter(filter:Filter):void {
			_content.removeFilter(filter);
		}

		/**
		 * 	Overrides filters
		 */		
		override public function set filters(value:Array):void {
			throw new Error('Use addFilter() or removeFilter() instead');
		}
		
		/**
		 * 
		 */
		override public function get filters():Array {
			return _content.filters;
		}

		/**
		 * 	The enterframe event for rendering filters
		 */
		private function _render(event:Event = null):void {

/*			var start:int = getTimer();

			bitmapData.lock();		
			bitmapData.fillRect(bitmapData.rect, 0x00000000);

			var contentBitmapData:BitmapData = _content.draw();
			bitmapData.copyPixels(contentBitmapData, contentBitmapData.rect, new Point(0, 0));
			_content.applyFilters(bitmapData);
			
			bitmapData.unlock();
						
			renderTime = getTimer() - start;
*/
		}

		
		/**
		 * 	@private
		 * 	The enterframe event for rendering a transition
		 */
		private function _renderTransition(event:Event = null):void {
/*
			// fill in nothing
			bitmapData.fillRect(bitmapData.rect, 0x00000000);

			// draw the transition
			_transition.calculateTransition(bitmapData);
*/
		}
		
		/**
		 * 	Unloads the layer
		 **/
		public function unload():void {

			// disposes content
			if (_content) {
				
				// if content is a displayobject, remove it
				if (_content is DisplayObject) {
					removeChild(_content as DisplayObject);
				}

				_content.dispose();
				
			}

			// dispatch an unload event
			dispatchEvent(new LayerEvent(LayerEvent.LAYER_UNLOADED, this));
			
			// remove listener
			removeEventListener(Event.ENTER_FRAME, _render);
			removeEventListener(Event.ENTER_FRAME, _renderTransition);
			
			// remove content
			_content = new ContentNull();
			_settings = null;
			
		}
		
		/**
		 * 	@private
		 * 	Ends a transition
		 */
		private function _endTransition(event:TransitionEvent):void {
			
			var transition:Transition = event.transition;
			
			// remove listener
			transition.removeEventListener(TransitionEvent.TRANSITION_END, _endTransition);

			// get the old content
			var oldcontent:IContent = transition.oldContent;

			// kill old content
			oldcontent.dispose();
			
			// remove listener
			removeEventListener(Event.ENTER_FRAME, _renderTransition);

			// remove listener
			addEventListener(Event.ENTER_FRAME, _render);
 
		}
		
		public function draw(bmp:BitmapData):void {
			
			var scaleX:Number = bmp.width / _content.source.width;
			var scaleY:Number = bmp.height / _content.source.height;
			
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleX, scaleY);

			bmp.draw(_content.source, matrix);
			
		}
		
		/**
		 * 	Merges a layer into the current layer (no load)
		 */
		public function merge(layer:Layer):void {
		}
		
		public function dispose():void {
		}

	}
}