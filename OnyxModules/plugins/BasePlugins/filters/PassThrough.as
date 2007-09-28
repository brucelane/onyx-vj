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
package filters {
	
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	
	import onyx.constants.*;
	import onyx.controls.*;
	import onyx.plugin.*;

	public final class PassThrough extends Filter implements IBitmapFilter {
		
		public var amount:int;
		public var mode:String;
		public var blur:BlurFilter;
		
		public function PassThrough():void {
			
			blur	= new BlurFilter(2, 2),
			amount		= 255,
			mode		= 'low pass';
			
			super(
				false,
				new ControlRange('mode', 'mode', ['low pass', 'high pass'], mode), 
				new ControlInt('amount', 'amount', 0, 255, 0),
				new ControlInt('postBlur', 'postBlur', 0, 10, 2)
			);
		}
		
		public function set postBlur(value:int):void {
			blur.blurX = blur.blurY = value;
		}
		
		public function get postBlur():int {
			return blur.blurX;
		}
		
		public function applyFilter(source:BitmapData):void {
			
			var thresh:uint = (amount << 16 | amount << 8 | amount);
			
			source.threshold(source, BITMAP_RECT, POINT, mode === 'high pass' ? '<=' : '>=', thresh, 0x00FFFFFF, 0x00FFFFFF);
			
			if (blur.blurX) {
				source.applyFilter(source, BITMAP_RECT, POINT, blur);
			}
		}
	}
}