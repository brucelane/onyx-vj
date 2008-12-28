/**
 * Copyright (c) 2003-2008 "Onyx-VJ Team" which is comprised of:
 *
 * Daniel Hai
 * Stefano Cottafavi
 *
 * All rights reserved.
 *
 * Licensed under the CREATIVE COMMONS Attribution-Noncommercial-Share Alike 3.0
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at: http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 *
 * Please visit http://www.onyx-vj.com for more information
 * 
 */
package ui.macros {

	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.tween.*;
	
	import ui.window.*;
	
	public final class ToggleTransition extends Macro {
		
		override public function keyDown():void {
				
			// create the position
			var property:TweenProperty = (Display.channelMix > 0) ? new TweenProperty('channelMix', Display.channelMix, 0) : new TweenProperty('channelMix', Display.channelMix, 1);
			
			new Tween(
				Display,
				1500,
				property
			);
		}

	}
}