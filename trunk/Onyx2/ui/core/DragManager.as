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
package ui.core {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ui.events.DragEvent;
	import flash.geom.ColorTransform;
	
	public class DragManager {
		
		private static var _targets:Array = [];
		private static var _dragTarget:Bitmap;
		private static var _currentTarget:DisplayObject;
		private static var _offsetX:int;
		private static var _offsetY:int;
		private static var _origin:UIObject;
		private static var _dragOver:Function;
		private static var _dragOut:Function;
		private static var _dragDrop:Function;
			
		public static function startDrag(origin:UIObject, targets:Array, dragOver:Function, dragOut:Function, dragDrop:Function):void {
			
			// save variables
			_origin = origin;
			_targets = targets;
			
			_dragOver = dragOver;
			_dragOut = dragOut;
			_dragDrop = dragDrop;
			
			// mouse offset
			_offsetX = origin.mouseX;
			_offsetY = origin.mouseY;
			
			// we want the event to happen everywhere
			origin.stage.addEventListener(MouseEvent.MOUSE_MOVE, _onObjectFirstMove);
			origin.stage.addEventListener(MouseEvent.MOUSE_UP, _onObjectUp);
			
		}
		
		private static function _onObjectFirstMove(event:MouseEvent):void {

			var color:ColorTransform = new ColorTransform();
			color.alphaMultiplier = .5;

			// add a mirrored bitmap to the stage
			var bmp:BitmapData = new BitmapData(_origin.width, _origin.height, true, 0x00000000);
			bmp.draw(_origin, null, color);
			_dragTarget = new Bitmap(bmp);
			
			// place it
			_dragTarget.x = _origin.stage.mouseX - _offsetX;
			_dragTarget.y = _origin.stage.mouseY - _offsetY;
			
			// add to stage
			_origin.stage.addChild(_dragTarget);

			// set listeners for the dragged bitmap			
			_origin.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onObjectFirstMove);
			_origin.stage.addEventListener(MouseEvent.MOUSE_MOVE, _onObjectMove);
			
			// in each target, we're going to look for rollover, rollout events
			for each (var target:DisplayObject in _targets) {
				target.addEventListener(DragEvent.DRAG_OVER, _dragOver);
				target.addEventListener(DragEvent.DRAG_OUT, _dragOut);
				target.addEventListener(DragEvent.DRAG_DROP, _dragDrop);
				target.addEventListener(MouseEvent.ROLL_OVER, _onRollTarget);
				target.addEventListener(MouseEvent.ROLL_OUT, _onRollOutTarget);
			}
		}
		
		/**
		 * 	@private
		 */
		private static function _onObjectMove(event:MouseEvent):void {
			_dragTarget.x = event.stageX - _offsetX;
			_dragTarget.y = event.stageY - _offsetY;
			
			event.updateAfterEvent();
		}
		
		/**
		 * 	@private
		 */
		private static function _onObjectUp(event:MouseEvent):void {
			
			// remove the event listeners
			_origin.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onObjectFirstMove);
			_origin.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onObjectMove);
			_origin.stage.removeEventListener(MouseEvent.MOUSE_UP, _onObjectUp);

			if (_dragTarget != null) {
				_dragTarget.stage.removeChild(_dragTarget);
				_dragTarget.bitmapData.dispose();
			}
			
			if (_currentTarget) {
				
				var dragEvent:DragEvent = new DragEvent(DragEvent.DRAG_DROP);
				dragEvent.origin = _origin;
				
				_currentTarget.dispatchEvent(dragEvent);
			}

			// remove the target listeners			
			for each (var target:DisplayObject in _targets) {
				target.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutTarget);
				target.removeEventListener(MouseEvent.ROLL_OVER, _onRollTarget);
				target.removeEventListener(DragEvent.DRAG_OVER, _dragOver);
				target.removeEventListener(DragEvent.DRAG_OUT, _dragOut);
				target.removeEventListener(DragEvent.DRAG_DROP, _dragDrop);
			}
			
			// delete references;
			_targets = null;
			_origin = null;
			_currentTarget = null;
			_dragTarget = null;
			_dragDrop = null;
			_dragOut = null;
			_dragOver = null;
		}
		
		// rolled on a target
		private static function _onRollTarget(event:MouseEvent):void {
			if (event.currentTarget !== _currentTarget) {
				_currentTarget = event.currentTarget as DisplayObject;
				_currentTarget.dispatchEvent(new DragEvent(DragEvent.DRAG_OVER));
			}
		}

		// rolled out of a target
		private static function _onRollOutTarget(event:MouseEvent):void {
			_currentTarget.dispatchEvent(new DragEvent(DragEvent.DRAG_OUT));
			_currentTarget = null;
		}

	}
}