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
package ui.window {
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import onyx.core.Plugin;
	import onyx.plugin.Filter;
	import onyx.utils.*;
	
	import ui.controls.ScrollPane;
	import ui.controls.filter.LibraryFilter;
	import ui.core.*;
	import ui.events.DragEvent;
	import ui.layer.*;
	import ui.policy.*;
	import ui.styles.*;
	
	/**
	 * 	Filters Window
	 */
	public final class Filters extends Window {
		
		/**
		 * 	@private
		 * 	An array of targets you can drag filters to
		 */
		private static const targets:Dictionary	= new Dictionary(true);

		/**
		 * 	
		 */
		public static function registerTarget(obj:UIObject, enable:Boolean):void {
			(enable) ? targets[obj] = obj : delete targets[obj];
			var test:GCTester = new GCTester(obj);
		}
		
		/**
		 * 	@private
		 */
		private var _normalPane:ScrollPane		= new ScrollPane(89, 225, 'EFFECT FILTERS');
		
		/**
		 * 	@private
		 */
		private var _bitmapPane:ScrollPane		= new ScrollPane(89, 225, 'BITMAP FILTERS');
		
		/**
		 * 	@constructor
		 */
		public function Filters(reg:WindowRegistration):void {
			
			// set title, etc
			super(reg, true, 192, 240);
			
			// add panes
			addChild(_normalPane);
			addChild(_bitmapPane);
			
			// add vertical ordering policy
			Policy.addPolicy(_normalPane, new VOrderPolicy());
			Policy.addPolicy(_bitmapPane, new VOrderPolicy());
			
			_normalPane.x = 99,
			_normalPane.y = 13,
			_bitmapPane.x = 4,
			_bitmapPane.y = 13;

			// create filter controls
			_createControls();

		}
		
		/**
		 * 	@private
		 */
		private function _createControls():void {
			
			var filters:Array = Filter.filters;
			var len:int = filters.length;
			
			for (var index:int = 0; index < len; index++) {
				
				var plugin:Plugin = filters[index];
				
				// create library ui item
				var lib:LibraryFilter = new LibraryFilter(plugin);
				
				if (plugin.getData('effect')) {
					_normalPane.addChild(lib);
				} else {
					_bitmapPane.addChild(lib);
				}
				
				// set it to listen for double clicks
				lib.doubleClickEnabled = true;
				
				// add listeners
				lib.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDown);
				lib.addEventListener(MouseEvent.DOUBLE_CLICK, _doubleClick);
			}
		}

		/**
		 * 	@private
		 * 	Clear all controls
		 */
		private function _clearControls():void {
			
			while (_bitmapPane.numChildren) {
				
				var lib:LibraryFilter = _bitmapPane.removeChildAt(0) as LibraryFilter;
				lib.removeEventListener(MouseEvent.MOUSE_DOWN, _mouseDown);
				lib.removeEventListener(MouseEvent.DOUBLE_CLICK, _doubleClick);
				
			}
		}
		
		/**
		 * 	@private
		 * 	Double Click
		 */
		private function _doubleClick(event:MouseEvent):void {
			
			var control:LibraryFilter	= event.target as LibraryFilter;
			var plugin:Plugin			= control.filter;
			var target:IFilterDrop		= UIObject.selection as IFilterDrop;
			
			if (target) {
				if (event.ctrlKey) {
					_applyToAll(plugin);
				} else {
					target.addFilter(plugin.getDefinition() as Filter);
				}
			}
				
		}
		
		/**
		 * 	@private
		 * 	Mouse Down
		 */
		private function _mouseDown(event:MouseEvent):void {
			
			var control:LibraryFilter = event.currentTarget as LibraryFilter;
			DragManager.startDrag(control, targets, _onDragOver, _onDragOut, _onDragDrop);
			
		}
		
		/**
		 * 	@private
		 * 	Drag Over
		 */
		private function _onDragOver(event:DragEvent):void {
			var obj:UIObject = event.currentTarget as UIObject;
			obj.transform.colorTransform = DRAG_HIGHLIGHT;
		}
		
		/**
		 * 	@private
		 */
		private function _onDragOut(event:DragEvent):void {
			var obj:UIObject = event.currentTarget as UIObject;
			obj.transform.colorTransform = DEFAULT;
		}
		
		/**
		 * 	@private
		 * 	Drag Handler
		 */
		private function _onDragDrop(event:DragEvent):void {
			var object:IFilterDrop		= event.currentTarget as IFilterDrop;
			var origin:LibraryFilter	= event.origin as LibraryFilter;
			var plugin:Plugin			= origin.filter;
			
			(object as DisplayObject).transform.colorTransform = DEFAULT;

			// if ctrl key is down, apply to all layers
			if (event.ctrlKey && !(object is UIDisplay)) {

				_applyToAll(plugin);

			} else {
				
				// just add the filter to the related object
				object.addFilter(plugin.getDefinition() as Filter);
				
			}
		}
		
		/**
		 * 	@private
		 * 	Apply to all layers
		 */
		private function _applyToAll(plugin:Plugin):void {
			
			var layers:Array = UILayer.layers;
			for each (var layer:UILayer in layers) {
				layer.addFilter(plugin.getDefinition() as Filter);
			}
		}
		
		/**
		 * 
		 */
		override public function dispose():void {

			// remove policites
			Policy.removePolicies(_normalPane);
			Policy.removePolicies(_bitmapPane);

			// remove controls
			_clearControls();

			super.dispose();

		}
	}
}