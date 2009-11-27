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
package onyx.asset.air {
	
	import flash.filesystem.File;
	import flash.utils.*;
	
	import onyx.asset.*;
	import onyx.display.*;
	import onyx.plugin.*;
	import onyx.utils.file.*;

	
	/**
	 * 
	 */
	public final class VPAdapter implements IAssetAdapter {
		
		/**
		 * 	Cache
		 */
		private static const cache:Object = {};
		
		/**
		 * 
		 */
		public static function getDirectoryCache(path:String):VPDirectoryQuery {
			return cache[path];
		}
		
		/**
		 * 
		 */
		public function VPAdapter(root:String):void {
			VP_ROOT = new File(root);
		}
	
		/**
		 * 	Queries a directory
		 */
		public function queryDirectory(path:String, callback:Function):void {

			cache[path] = new VPDirectoryQuery(path, callback);
			
		}
		
		/**
		 * 	Resolves a path to content
		 */
		public function queryContent(path:String, callback:Function, layer:Layer, settings:LayerSettings, transition:Transition):void {
			new VPContentQuery(path, callback, layer, settings, transition);
		}
		
		/**
		 * 
		 */
		public function save(path:String, callback:Function, bytes:ByteArray, extension:String):void {
			new VPSaveQuery(path, callback, bytes);
		}
		
		/**
		 * 
		 */
		public function queryFile(path:String, callback:Function):void {
			var query:VPReadQuery = new VPReadQuery(path, callback);
			query.query();
		}
		
		/**
		 * 
		 */
		public function browseForSave(callback:Function, title:String, bytes:ByteArray, extension:String):void {
			new VPSaveBrowseQuery(callback, title, bytes, extension);
		}
		
		/**
		 * 
		 */
		public function resolvePath(path:String):String {
			return VP_ROOT.resolvePath(path).nativePath;
		}
		
		/**
		 * 
		 */
		public function quit():void {
			
		}
	}
}
