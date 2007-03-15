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
package onyx.layer {
	
	import onyx.constants.*;
	import onyx.controls.*;;
	/**
	 * 	Stores property names for layers
	 */
	dynamic public final class LayerProperties extends Controls {
		
		// display properties
		public static const ALPHA:String		= 'alpha';
		public static const BLENDMODE:String	= 'blendMode';
		public static const BRIGHTNESS:String	= 'brightness';
		public static const CONTRAST:String		= 'contrast';
		public static const SCALEX:String		= 'scaleX';
		public static const SCALEY:String		= 'scaleY';
		public static const ROTATION:String		= 'rotation';
		public static const SATURATION:String	= 'saturation';
		public static const THRESHOLD:String	= 'threshold';
		public static const COLOR:String		= 'color';
		public static const TINT:String			= 'tint';
		public static const X:String			= 'x';
		public static const Y:String			= 'y';
		public static const TIME:String			= 'time';
		public static const MUTE:String			= 'mute';
		
		// playhead properties
		public static const FRAMERATE:String	= 'framerate';
		public static const LOOPSTART:String	= 'loopStart';
		public static const LOOPEND:String		= 'loopEnd';

		// stores controls
		public var alpha:Control		=	new ControlNumber(
												LayerProperties.ALPHA,				'alpha',	0,	1,	1
											);
		public var blendMode:Control	=	new ControlRange(
												LayerProperties.BLENDMODE,			'blendmode',	BLEND_MODES,	0
											);
		public var brightness:Control	=	new ControlNumber(
												LayerProperties.BRIGHTNESS,			'bright',		-1,		1,		0
											);
		public var contrast:Control		= 	new ControlNumber(
												LayerProperties.CONTRAST,			'contrast',		-1,		2,		0
											);
		public var rotation:Control		= 	new ControlNumber(
												LayerProperties.ROTATION,			'rotation',		-360,	360,	0
											);
		public var saturation:Control	= 	new ControlNumber(
												LayerProperties.SATURATION,			'saturation',	0,		2,		1
											);
		public var threshold:Control	= 	new ControlInt(
												LayerProperties.THRESHOLD,			'threshold',	0,		100,	0
											);
		public var tint:Control			= 	new ControlNumber(
												LayerProperties.TINT,				'tint',			0,		1,		0
											);
		public var scaleX:Control		= 	new ControlNumber(
												LayerProperties.SCALEX,			'scaleX',		-5,		5,		1
											);
		public var scaleY:Control		= 	new ControlNumber(
												LayerProperties.SCALEY,			'scaleY',		-5,		5,		1
											);
		public var x:Control			= 	new ControlNumber(
												LayerProperties.X,	'x',	-5000,	5000,	0
											)
		public var y:Control			=	new ControlNumber(
												LayerProperties.Y,	'y',	-5000,	5000,	0
											);
		public var framerate:Control	=	new ControlNumber(
												LayerProperties.FRAMERATE,				'play rate', 	-20,	20, 1,
												{ display: 'frame', factor: 6, multiplier: 10 }
											);
		public var loopStart:Control	=	new ControlNumber(
												LayerProperties.LOOPSTART,				'loop',			0,		1,	0
											);
		public var loopEnd:Control		=	new ControlNumber(
												LayerProperties.LOOPEND,				'end',			0,		1,	1
											);
		public var time:Control			=	new ControlNumber(
												LayerProperties.TIME,					null,			0,		1,	0
											);
		public var color:Control		=	new ControlColor(
												LayerProperties.COLOR, 					'color'
											);
											
		public var position:Control		=	new ControlProxy(
												'position', 'x:y',
												x, y,
												{ invert: true }
											);

		public var scale:Control		=	new ControlProxy(
												'scale', 'scale',
												scaleX, scaleY,
												{ multiplier: 100, invert: true }
											);
											
		public var muted:ControlBoolean	=	new ControlBoolean('muted', 'muted');
													
		/**
		 * 	@constructor
		 */
		public function LayerProperties(layer:ILayer):void {
			
			super(layer);
			
			super.addControl(
				alpha,
				blendMode,
				brightness,
				contrast,
				rotation,
				saturation,
				threshold,
				scale,
				position,
				framerate,
				loopStart,
				loopEnd,
				time,
				tint,
				color,
				muted
			);
		}
		
		override public function dispose():void {
			super.dispose();
		}

	}
}