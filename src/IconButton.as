package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import spark.components.Button;
	import spark.components.Image;
	
	/**
	 * ...
	 * @author Jake Rigby
	 */
	public class IconButton extends Button 
	{
		[SkinPart(required="true")] public var image:Image;
		[SkinPart(required = "true")] public var ovr:Boolean = false;
		
		
		private var _img:Class;
		private var _url:String;
		private var _bmd:BitmapData;
		
		public function IconButton() 
		{
			super();	
			setStyle("skinClass", Class(IconButtonSkin));
		}
		
		[Bindable(event = "imgChanged")] public function get img():Class
		{
			return _img;
		}
		
		public function set img(value:Class):void
		{
			//_img = value;
			image.source = value;
			dispatchEvent(new Event("imgChanged"));
		}
		
		[Bindable(Event = "urlChanged")] public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url = value;
			var loader:Loader = new Loader();
			var req:URLRequest = new URLRequest(value);
			//var loaderContext:LoaderContext = new LoaderContext();
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fileLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);               
		}

		private function onIOError(event:IOErrorEvent):void{
			trace(event.text);
		}

		private function fileLoadComplete(event:Event):void
		{
			var loader:Loader = Loader(event.target.loader);
			var bitmap:Bitmap = Bitmap(loader.content);
			_bmd = bitmap.bitmapData;
			image.source = new Bitmap(_bmd);
		}		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			scale();
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		private function scale():void
		{
			if (!_bmd) return;
			var f:Number = width/_bmd.width;
			image.width = width;
			image.height = _bmd.height * f;
		}
		
	}

}