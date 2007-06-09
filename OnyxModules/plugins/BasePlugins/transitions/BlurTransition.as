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
package transitions {
	
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	
	import onyx.constants.POINT;
	import onyx.core.RenderTransform;
	import onyx.plugin.*;
	
	public final class BlurTransition extends Transition implements IBitmapTransition {
		
		private var _blur:BlurFilter	= new BlurFilter(0,0);
		
		public function BlurTransition():void {
			super();
		}
		
		public function render(source:BitmapData, ratio:Number):void {
			
			// 0 - .5: Blur Current 0-1
			// .5 - 1: Blur Loaded 1-0
			if (ratio < .5) {
				
				currentContent.render();

				var blur:int = (ratio / .5 * 26) << 0;
				var bitmap:BitmapData = currentContent.rendered;

			} else {
				
				loadedContent.render();
				blur = (((1 - ratio) / .5) * 26) << 0;
				
				bitmap = loadedContent.rendered;
			}

			_blur.blurX = _blur.blurY = blur;
			
			source.copyPixels(bitmap, bitmap.rect, POINT);
			source.applyFilter(source, source.rect, POINT, _blur);
		}
	}
}