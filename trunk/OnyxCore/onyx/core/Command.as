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
package onyx.core {

	import onyx.constants.VERSION;
	import onyx.display.*;
	import onyx.jobs.StatJob;
	import onyx.plugin.*;
	
	use namespace onyx_ns;

	public final class Command {
		
		public static function help(... args:Array):void {
			
			var text:String;
			
			switch (args[0]) {
				case 'command':
				case 'commands':
				
					text =	_createHeader('commands') + 'PLUGINS: SHOWS # OF PLUGINS<br>' +
							'CLEAR: CLEARS THE TEXT<br>' +
							'STAT [TIME:INT]:	TESTS ALL LAYERS FOR AVERAGE RENDERING TIME';
				
					break;
				case 'contributors':
					text =	'CONTRIBUTORS<br>-------------<br>DANIEL HAI: HTTP://WWW.DANIELHAI.COM'
					break;
				case 'plugins':
					text =	Filter.filters.length + ' FILTERS, ' +
							Transition.transitions.length + ' TRANSITIONS, ' +
							Visualizer.visualizers.length + ' VISUALIZERS LOADED.';
					break;
				case 'stat':
					text =	_createHeader('stat') + 'TESTS FRAMERATE AND LAYER RENDERING TIMES.<br><br>USAGE: STAT [NUM_SECONDS:INT]<br>';
					break;
				default:
					text =	_createHeader('<b>ONYX ' + VERSION + '</b>', 21) + 
							'COPYRIGHT 2003-2006: WWW.ONYX-VJ.COM' +
							'<br>TYPE "HELP" OR "HELP COMMANDS" FOR MORE COMMANDS.';
					break;
			}
			// dispatch the start-up motd
			Console.output(text);
	
		}
		
		private static function _createHeader(command:String, size:int = 14):String {
			return '<font size="' + size + '" color="#DCC697">' + command + '</font><br><br>';
		}
		
		/**
		 * 	Finds out
		 */
		public static function stat(... args:Array):void {
			
			// does a stat job for a specified amount of time
			var time:int = args[0] || 2;
			
			var job:StatJob = new StatJob();
			job.initialize(time);
		}
		
		/**
		 * 
		 */
		public static function layer(... args:Array):void {
			
			try {
				
				var display:Display = Display.getDisplay(0);
				var layer:ILayer	= display.layers[args[0]];
				
				layer[args[1]] = args[2];
			} catch (e:Error) {
				Console.error(e.message);
			}
			
		}
	}
}