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
package filters {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import onyx.controls.Control;
	import onyx.controls.ControlInt;
	import onyx.controls.ControlRange;
	import onyx.controls.Controls;
	import onyx.core.getBaseBitmap;
	import onyx.filter.Filter;
	import onyx.filter.IBitmapFilter;

	public final class Repeater extends Filter implements IBitmapFilter {
		
		public var amount:int			= 2;

		private var _step:Boolean		= false;
		private var _currentStep:int	= 0;
		private var _bmp:BitmapData		= getBaseBitmap();
		
		public function Repeater():void {
			
			super('Repeater');
			
			_controls.addControl(
				new ControlInt('amount', 'amount', 1, 42, 2),
				new ControlRange('step', 'step', [false, true], 0)
			)
		}
		
		/**
		 * 	Applys a filter to the bitmap
		 */
		public function applyFilter(bitmapData:BitmapData, bounds:Rectangle):BitmapData {
			
			var amount:int = amount;
			var square:int = amount * amount;
			
			var scaleX:Number = Math.ceil(bitmapData.width / amount);
			var scaleY:Number = Math.ceil(bitmapData.height / amount);
			
			var newbmp:BitmapData = new BitmapData(scaleX, scaleY, true, 0x00000000);
			var matrix:Matrix = new Matrix();
			matrix.scale(1 / amount, 1 / amount);
			
			newbmp.draw(bitmapData, matrix);
			
			if (_step) {
				
				_currentStep = (_currentStep+1) % (amount);

				_bmp.copyPixels(newbmp, newbmp.rect, new Point((_currentStep % amount) * scaleX, Math.floor(_currentStep / amount) * scaleY));
				
				return _bmp;

			} else {
				
				if (amount > 0) {
					for (var count:int = 0; count < square; count++) {
						bitmapData.copyPixels(
							newbmp, 
							newbmp.rect, 
							new Point((count % amount) * scaleX, 
							Math.floor(count / amount) * scaleY)
						);
					}
				}
			}

			return bitmapData;
		}
		
		/**
		 * 	clone
		 */
		override public function clone():Filter {
			var filter:Repeater = new Repeater();
			filter._step = _step;
			filter._currentStep = _currentStep;
			
			return filter;
		}
		
		/**
		 * 	Disposes the filter
		 */
		override public function dispose():void {
			if (_bmp) {
				_bmp.dispose();
			}
			super.dispose();
		}
	}
}