/**
 * Copyright (c) 2003-2010 "Onyx-VJ Team" which is comprised of:
 *
 * Daniel Hai
 * Stefano Cottafavi
 * Bruce Lane
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
package onyx.asset {
	
	import flash.display.*;
	import flash.media.*;
	import flash.text.*;
	
	[ExcludeSDK]
	
	/**
	 * 
	 */
	internal final class VideoPongAsset extends AssetFile {
		
		/**
		 * 	@private
		 */
		private var videopong:String;
		
		/**
		 * 	@constructor
		 */
		public function VideoPongAsset(name:String) {
			this.videopong						= name,
			this.thumbnail.bitmapData		= new VideoPongThumbnail();
			
			const source:BitmapData		= this.thumbnail.bitmapData;
			const label:TextField			= new TextField();
			const format:TextFormat			= new TextFormat('Verdana', 7, 0xFFFFFF);
			//const format:TextFormat			= new TextFormat(new AssetDefaultFont().fontName, 7, 0xFFFFFF);
			format.leading					= 3;
			label.autoSize					= TextFieldAutoSize.LEFT;
			label.wordWrap					= true;
			label.width						= 44;
			//label.embedFonts				= true;
			label.defaultTextFormat			= format;
			
			label.text						= name.toUpperCase();
			
			source.draw(label);
		}
		
		/**
		 * 
		 */
		override public function get name():String {
			return videopong;
		}
		
		/**
		 * 
		 */
		override public function get path():String {
			return 'videopong://' + name;
		}
		
		/**
		 * 
		 */
		override public function get extension():String {
			return '';
		}
		
		/**
		 * 
		 */
		override public function get isDirectory():Boolean {
			return false;
		}
	}
}