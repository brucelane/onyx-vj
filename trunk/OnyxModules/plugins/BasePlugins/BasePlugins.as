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
package {
	
	import effects.*;
	
	import filters.*;
	
	import flash.display.Sprite;
	
	import macros.*;
	
	import modules.*;
	import modules.VLC.*;
	import modules.render.*;
	import modules.stopmotion.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	import renderer.*;
	
	import transitions.*;
	
	import visualizer.*;
	
	public class BasePlugins extends Sprite implements IPluginLoader {

		/**
		 * 	Returns an array of plugins for onyx to load
		 */
		public function get plugins():Array {
			return [
			
				// bitmap filters
				// new Plugin('AutoCompose',		AutoCompose,	'AutoCompose'),
				new Plugin('Scroller',				ConstantScroll,	'Scroll'),
				new Plugin('Ray Of Light',			RayOfLight,		'Ray Of Light'),
				new Plugin('Mirror Filter',			MirrorFilter,	'Mirror Filter'),
				new Plugin('Echo Filter',			EchoFilter,		'Echo Filter'),
				// new Plugin('Scroller',				Scroller,		'Scroller'),
				new Plugin('Keying Filter',			KeyingFilter,	'Keys a color out'),
				new Plugin('Super Trigger',			SuperTrigger,	'Super Trigger'),
				// new Plugin('Generic Tempo',			GenericTempo,	'Generic Tempo'),
				new Plugin('Scroll Render',			ScrollRender,	'Scroll Render'),
				new Plugin('Tempo Blur',			TempoBlur,		'Tempo Blur'),
				new Plugin('Kaliedoscope', 			Kaliedoscope,	'Kaliedoscope'),
				new Plugin('Pixelate',				Pixelate,		'Pixelate'),
				new Plugin('Blur Filter', 			Blur,			'Blur Filter'),
				new Plugin('Halo Filter', 			Halo,			'Halo Filter'),
				new Plugin('Noise Filter',			NoiseFilter,	'Noise Filter'),
				new Plugin('Repeater Filter',		Repeater,		'Repeater Filter'),
				new Plugin('Alpha Effect', 			Alpha,			'Randomizes the alpha'),
				new Plugin('Blink Effect', 			Blink,			'Randomizes the visibility'),
				new Plugin('Frame Random', 			FrameRND,		'Randomizes Frame Rates'),
				new Plugin('MoveScale Effect', 		MoverScaler,	'Moves and Scales Object'),
				new Plugin('Threshold Gate', 		ThreshGate,		'Randomly Threshold'),
				new Plugin('Displace Filter',		DisplacementMap,'Displacement Map'),
				new Plugin('Slit Scan',				SlitScan,		'Slit Scan'),
				new Plugin('Invert',				InvertFilter,	'Invert'),
				new Plugin('Edge Bleed',			EdgeBlend,		'Frame Blend'),
				new Plugin('Pass Through',			PassThrough,	'Pass Through'),

				// transitions
				new Plugin('Repeater Transition',	RepeaterTransition, 'Repeater Transition'),
				new Plugin('Pixel Transition',		PixelTransition, 'Pixel Transition'),
				new Plugin('Blur Transition',		BlurTransition, 'Blurs the loaded layer'),
				new Plugin('Basic',					BasicVisualizer, 'Visualizer'),
				new Plugin('Circles',				CircleVisualizer, 'CircleVisualizer'),
				new Plugin('SpectrumVisualizer',	SpectrumVisualizer, 'SpectrumVisualizer'),
				
				// Modules
				// new Plugin('VLC',					VLCModule,		'VLC'),
				// new Plugin('Render',				RenderClient,		'RenderClient'),
				new Plugin('Debugger',				Debugger,			'Debugger'),

				// Macros
				new Plugin('Framerate Increase',	FrameRateIncrease),
				new Plugin('Framerate Decrease',	FrameRateDecrease),
				new Plugin('Echo Display',			EchoDisplay),
				new Plugin('Slow Down Layers',		SlowDown),
				new Plugin('Speed Up Layers',		SpeedUp),
				new Plugin('Buffer Display',		BufferDisplay),
				new Plugin('Random Blend',			RandomBlend),
				new Plugin('Display Contrast',		DisplayContrast)

			];
		}
	}
}
