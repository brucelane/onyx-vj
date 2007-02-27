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
package onyx.display {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.*;
	
	import onyx.constants.*;
	import onyx.content.*;
	import onyx.controls.*;
	import onyx.core.*;
	import onyx.events.*;
	import onyx.filter.*;
	import onyx.jobs.*;
	import onyx.layer.*;
	import onyx.plugin.*;
	import onyx.transition.*;
	import onyx.utils.array.*;
	
	use namespace onyx_ns;
	
	/**
	 * 	Base Display class
	 */
	public class Display extends Bitmap implements IDisplay {

		/**
		 * 	@private
		 * 	Stores the saturation, tint, etc, as well as colortransform
		 */
		private var _filter:ColorFilter			= new ColorFilter();

		/**
		 * 	@private
		 * 	Stores the filters for this content
		 */
		private var _filters:FilterArray		= new FilterArray();
		
		/**
		 * 	@private
		 */
		private var _backgroundColor:uint		= 0x000000;
		
		/**
		 * 	@private
		 */
		private var __x:Control					= new ControlInt('displayX', 'x', 0, 2000, 640);
		
		/**
		 * 	@private
		 */
		private var __y:Control					= new ControlInt('displayY', 'y', 0, 2000, 480);
		
		/**
		 * 	@private
		 */
		private var __visible:Control			= new ControlBoolean('visible', 'visible');

		/**
		 * 	@private
		 */
		private var	_size:DisplaySize			= DISPLAY_SIZES[0];
		
		/**
		 * 	@private
		 */
		private var _controls:Controls;
		
		/**
		 * 	@private
		 */
		private var _layers:Array		= [];
		
		/**
		 * 
		 */
		private var _valid:Array		= [];
		
		/**
		 * 	@constructor
		 */
		public function Display():void {
			
			_controls = new Controls(this,
				new ControlProxy(
					'position', 'position',
					__x,
					__y,
					{ invert:true }
				),
				new ControlColor(
					'backgroundColor', 'backgroundColor'
				),
				new ControlRange(
					'size', 'size', DISPLAY_SIZES
				),
				__visible
			);
			
			// hide/show mouse when over the display
			addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			
			// render content
			addEventListener(Event.ENTER_FRAME, _renderContent);

			// set background color
			super(new BitmapData(320, 240, false, _backgroundColor));			
		}
		
		/**
		 * 	@private
		 * 	Make sure the mouse is gone when we roll over it
		 */
		private function _onMouseOver(event:MouseEvent):void {
			Mouse.hide();
		}
		
		/**
		 * 	@private
		 * 	Make sure the mouse comes back when we roll over it
		 */
		private function _onMouseOut(event:MouseEvent):void {
			Mouse.show();
		}
		
		/**
		 * 	Returns the number of layers
		 */
		public function get numLayers():int {
			return _layers.length;
		}
		
		/**
		 * 	Creates a specified number of layers
		 */
		public function createLayers(numLayers:uint, local:Boolean = true):void {
			
			while (numLayers-- ) {
				
				// create a new layer and set it's index
				var layer:Layer = new Layer();
				layer._display = this;
				
				// add to the index
				_layers.push(layer);
				
				// listen for load and unload (to push to the valid array);
				layer.addEventListener(LayerEvent.LAYER_LOADED,		_onLayerLoad);
				layer.addEventListener(LayerEvent.LAYER_UNLOADED,	_onLayerUnLoad);
				
				// dispatch
				dispatchEvent(
					new DisplayEvent(DisplayEvent.LAYER_CREATED, layer)
				);
			}
		}
		
		/**
		 * 	@private
		 * 	Called when a layer is loaded
		 */
		private function _onLayerLoad(event:LayerEvent):void {
			
			var currentLayer:ILayer	= event.currentTarget as ILayer;
			var currentIndex:int	= currentLayer.index;

			// only add it to the valid list if it's not already in the valid
			if (_valid.indexOf(currentLayer) < 0) {
					
				for (var index:int = 0; index < _valid.length; index++) {
					var layer:Layer = _valid[index];
					if (currentLayer.index < layer.index) {
						break;
					}
				}
				
				_valid.splice(index, 0, currentLayer);
			} else {
				throw new Error('rendering error, duplicate layers');
			}
		}
		
		/**
		 * 	@private
		 * 	Called when a layer is unloaded
		 */
		private function _onLayerUnLoad(event:LayerEvent):void {
			var layer:Layer = event.currentTarget as Layer;
			var index:int = _valid.indexOf(layer);
			
			_valid.splice(index, 1);
		}

		/**
		 * 	Returns the layers
		 */
		public function get layers():Array {
			return _layers.concat();
		}
		
		/**
		 * 	Moves a layer to a specified index
		 */
		public function moveLayer(... args:Array):void {
			
			var layer:Layer		= args[0];
			var index:int		= args[1];
			
			var fromIndex:int	= layer.index;
			var toLayer:Layer	= _layers[index];
			
			if (toLayer) {
				
				var numLayers:int = _layers.length;
				
				var fromChildIndex:int = _layers.indexOf(layer);
				
				swap(_layers, layer, index);

				// dispatch events to the layers				
				layer.dispatch(new LayerEvent(LayerEvent.LAYER_MOVE));
				toLayer.dispatch(new LayerEvent(LayerEvent.LAYER_MOVE));
				
				// now we need to check if they're both valid layers, and move them
				var toLayerValid:int = _valid.indexOf(toLayer);
				
				// swap
				if (toLayerValid >= 0) {
					swap(_valid, layer, toLayerValid);
				}
				
			}
		}
		
		/**
		 * 	Gets the display index
		 */
		public function get index():int {
			return Onyx._displays.indexOf(this);
		}
		
		/**
		 * 	Gets the controls related to the display
		 */
		public function get controls():Controls {
			return _controls;
		}
		
		/**
		 * 	Copies a layer
		 */
		public function copyLayer(layer:Layer, index:int):void {
			
			var layerindex:int	= layer.index;
			var copylayer:Layer	= _layers[index];
			
			if (copylayer) {
				
				var settings:LayerSettings = new LayerSettings();
				settings.load(layer);
				
				copylayer.load(layer.path, settings);
				
			}
		}
		
		/**
		 * 
		 */
		public function indexOf(layer:Layer):int {
			return _layers.indexOf(layer);
		}
		
		/**
		 * 	Returns the display as xml
		 */
		public function toXML():XML {
			var xml:XML = <display/>
			
			for each (var layer:Layer in _layers) {
				if (layer.path) {
					var settings:LayerSettings = new LayerSettings();
					settings.load(layer);
					xml.appendChild(settings.toXML());
				}
			}
			
			return xml;
		}
		
		/**
		 * 	Loads a mix file into the layers
		 * 	@param	request:URLRequest
		 * 	@param	origin:ILayer
		 * 	@param	transition:Transition
		 */
		public function load(path:String, origin:ILayer, transition:Transition):void {
			
			var job:LoadONXJob = new LoadONXJob(origin, transition);
			JobManager.register(this, job, path);
		}
		
		/**
		 * 
		 */
		public function set backgroundColor(value:uint):void {
			_backgroundColor = value;
		}
		
		/**
		 * 
		 */
		public function get backgroundColor():uint {
			return _backgroundColor;
		}
		
		/**
		 * 
		 */
		public function set size(value:DisplaySize):void {
			_size	= value;
			scaleX	= value.scale;
			scaleY	= value.scale;
		}
		
		/**
		 * 
		 */
		public function get size():DisplaySize {
			return _size;
		}
		
		/**
		 * 
		 */
		private function _renderContent(event:Event):void {
			
			// lock the bitmap
			super.bitmapData.lock();

			// fill the display
			super.bitmapData.fillRect(super.bitmapData.rect, _backgroundColor);
			
			// loop and render
			// TBD: raise the framerate of the root movie, and do calculation to render different content on different frames
			var length:int = _valid.length - 1;
			
			if (length >= 0) {
	
				// loop through layers and render			
				for (var count:int = length; count >= 0; count--) {
					
					var layer:ILayer = _valid[count];
	
					layer.render();
	
					if (layer.rendered) {
						super.bitmapData.draw(layer.rendered, null, null, layer.blendMode);
					}
				}
				
				// render filters
				_filters.render(super.bitmapData);
			}
			
			// unlock the bitmap
			super.bitmapData.unlock();
		}

		/**
		 * 	Adds a filter
		 */
		public function addFilter(filter:Filter):void {
			_filters.addFilter(filter, this);
		}

		/**
		 * 	Removes a filter
		 */		
		public function removeFilter(filter:Filter):void {
			_filters.removeFilter(filter, this);
		}
		
		/**
		 * 	Tint
		 */
		public function set tint(value:Number):void {	
			_filter.tint = value;
		}
		
		/**
		 * 	Sets color
		 */
		public function set color(value:uint):void {
			_filter.color = value;
		}

		
		/**
		 * 	Gets color
		 */
		public function get color():uint {
			return _filter._color;
		}

		/**
		 * 	Gets tint
		 */
		public function get tint():Number {
			return _filter._tint;
		}

		/**
		 * 	Gets saturation
		 */
		public function get saturation():Number {
			return _filter._saturation;
		}
		
		/**
		 * 	Sets saturation
		 */
		public function set saturation(value:Number):void {
			_filter.saturation = value;
		}

		/**
		 * 	Gets contrast
		 */
		public function get contrast():Number {
			return _filter._contrast;
		}

		/**
		 * 	Sets contrast
		 */
		public function set contrast(value:Number):void {
			_filter.contrast = value;
		}

		/**
		 * 	Gets brightness
		 */
		public function get brightness():Number {
			return _filter._brightness;
		}
		
		/**
		 * 	Sets brightness
		 */
		public function set brightness(value:Number):void {
			_filter.brightness = value;
		}

		/**
		 * 	Gets threshold
		 */
		public function get threshold():int {
			return _filter._threshold;
		}
		
		/**
		 * 	Sets threshold
		 */
		public function set threshold(value:int):void {
			_filter.threshold = value;
		}
		
		/**
		 * 	Gets a filter's index
		 */
		public function getFilterIndex(filter:Filter):int {
			return _filters.indexOf(filter);
		}
		
		/**
		 * 
		 */
		public function set framerate(value:Number):void {
			for each (var layer:Layer in _valid) {
				layer.framerate = value;
			}
		}
		
		/**
		 * 	Sets the default matrix for all layers
		 */
		public function set matrix(value:Matrix):void {
			for each (var layer:Layer in _valid) {
				layer.matrix = value;
			}
		}
		
		/**
		 * 
		 */
		public function get matrix():Matrix {
			return null;
		}

		/**
		 * 
		 */
		public function get loopStart():Number {
			return 0;
		}
		
		/**
		 * 
		 */
		public function set loopStart(value:Number):void {
			for each (var layer:Layer in _valid) {
				layer.loopStart = value;
			}
		}

		/**
		 * 
		 */
		public function pause(value:Boolean = true):void {
			for each (var layer:Layer in _valid) {
				layer.pause(value);
			}
		}
				
		/**
		 * 
		 */
		public function set time(value:Number):void {
			for each (var layer:Layer in _valid) {
				layer.time = value;
			}
		}
		
		/**
		 * 
		 */
		public function set loopEnd(value:Number):void {
			for each (var layer:Layer in _valid) {
				layer.loopEnd = value;
			}
		}
		
		/**
		 * 
		 */
		public function get loopEnd():Number {
			return 1;
		}
		
		/**
		 * 
		 */
		public function get framerate():Number {
			return 1;
		}
		
		/**
		 * 
		 */
		public function get source():BitmapData {
			return super.bitmapData;
		}

		/**
		 * 
		 */
		public function get rendered():BitmapData {
			return super.bitmapData;
		}
		
		/**
		 * 
		 */
		public function get totalTime():int {
			return 1;
		}
		
		/**
		 * 	Moves a filter to an index
		 */
		public function moveFilter(filter:Filter, index:int):void {
			
			if (swap(_filters, filter, index)) {
				super.dispatchEvent(new FilterEvent(FilterEvent.FILTER_MOVED, filter));
			}
		}
		
		/**
		 * 
		 */
		public function get path():String {
			return null;
		}
		
		/**
		 * 
		 */
		public function get time():Number {
			return 0;
		}
		
		/**
		 * 
		 */
		public function render():RenderTransform {
			return null;
		}

		/**
		 * 	Sets the display location
		 */
		public function set displayX(value:int):void {
			super.x = __x.setValue(value);
		}
		
		/**
		 * 	Sets the display location
		 */
		public function get displayX():int {
			return super.x;
		}
		
		/**
		 * 	Sets the display location
		 */
		public function set displayY(value:int):void {
			super.y = __y.setValue(value);
		}
		
		/**
		 * 	Sets the display location
		 */
		public function get displayY():int {
			return super.y;
		}


		/**
		 * 	@private
		 */
		override public function set x(value:Number):void {
			// do nothing
		}
		
		/**
		 * 	@private
		 */
		override public function set y(value:Number):void {
			// do nothing
		}
		
		/**
		 * 	@private
		 */
		override public function get x():Number {
			return 0;
		}
		
		/**
		 * 	@private
		 */
		override public function get y():Number {
			return 0;
		}
		
		/**
		 * 
		 */
		public function muteFilter(filter:Filter, toggle:Boolean = true):void {
			_filters.muteFilter(filter, this, toggle);
		}
		
		/**
		 * 
		 */
		override public function set visible(value:Boolean):void {
			super.visible = __visible.setValue(value);
		}
		
		/**
		 * 
		 */
		public function dispose():void {
		}

	}
}