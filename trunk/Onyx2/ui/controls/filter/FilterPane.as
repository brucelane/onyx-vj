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
package ui.controls.filter {

	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import onyx.filter.Filter;
	import onyx.states.StateManager;
	
	import ui.controls.ScrollPane;
	import ui.layer.UILayer;
	import ui.states.FilterMoveState;

	/**
	 * 
	 */
	public final class FilterPane extends ScrollPane {
		
		/**
		 * 
		 */
		public var selectedFilter:LayerFilter;
		
		/**
		 * 
		 */
		private var _dict:Dictionary = new Dictionary();
		
		/**
		 * 	@constructor
		 */
		public function FilterPane():void {
			super(90, 120);
		}
		
		/**
		 * 	Registers a filter for display
		 */
		public function register(filter:Filter):void {
			
			// create the control
			var control:LayerFilter = new LayerFilter(filter);
			
			// add control
			_dict[filter] = control;
			
			// add it
			addChild(control);
		
			// reorder	
			reorder();
			
			// add the event handler
			control.addEventListener(MouseEvent.MOUSE_DOWN, _filterMouseHandler);
			
			if (!selectedFilter && filter.index === 0) {
				selectFilter(control);
			}
		}
		
		/**
		 * 	Unregisters a filter from display
		 */
		public function unregister(filter:Filter):void {
			
			var control:LayerFilter = _dict[filter];

			if (control) {

				// remove and delete reference
				removeChild(control);
				delete _dict[filter];

				// reorder
				reorder();

				// destroy
				control.dispose();

				// add the event handler
				control.removeEventListener(MouseEvent.MOUSE_DOWN, _filterMouseHandler);
				
				if (control === selectedFilter) {
					selectFilter(null);
				}
			}
		}
		
		/**
		 * 
		 */
		public function getFilter(filter:Filter):LayerFilter {
			return _dict[filter];
		}
		
		/**
		 * 	Reorders filters
		 */
		public function reorder():void {
			for each (var control:LayerFilter in _dict) {
				control.y = control.filter.index * 14;
			}
		}


		
		/**
		 * 	@private
		 */
		private function _filterMouseHandler(event:MouseEvent):void {

			selectFilter(event.currentTarget as LayerFilter);
			
			var state:FilterMoveState = new FilterMoveState();
			StateManager.loadState(state, event.currentTarget, _dict);

		}
		
		/**
		 * 	Selects a filter
		 */
		public function selectFilter(control:LayerFilter):void {

			var uilayer:UILayer = parent as UILayer;
			
			if (selectedFilter) {
				selectedFilter.highlight(0,0);
				
				// unselect if it's selected
				if (control === selectedFilter) {
					control = null;
				}
			}
			
			selectedFilter = control;
			
			if (control) {
				
				control.highlight(0xFFFFFF, .4);
				uilayer.selectPage(1, control.filter.controls);
			
			// select nothing
			} else {
				
				uilayer.selectPage(0);
				
			}
		}
		
	}
}