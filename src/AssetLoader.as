package
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class AssetLoader
	{
		private var bytes:ByteArray = new ByteArray();
		private var stream:FileStream = new FileStream();
		private var loader:Loader = new Loader();
		private var file:File;
		
		public function AssetLoader(path:String)
		{
			file = File.desktopDirectory.resolvePath(path);
			stream.addEventListener(Event.COMPLETE, compl);
			stream.openAsync(file, FileMode.READ);
		}
		
		private function compl(evt:Event):void
		{
			stream.readBytes(bytes);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, assetLoaded);
			loader.loadBytes(bytes);
		}
		
		private function assetLoaded(evt:Event):void
		{
			var content:DisplayObject = loader.content;
			stream.removeEventListener(Event.COMPLETE, compl);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, assetLoaded);
			stream.close();
		}
	}
}