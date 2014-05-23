package
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class CaptureVO extends EventDispatcher
	{
		[Bindable] public var name:String;
		private var _bmd:BitmapData;
		private var _imageBytes:ByteArray;
		[Bindable] public var imageWidth:int;
		[Bindable] public var imageHeight:int;
		[Bindable] public var timecode:int;
		[Bindable] public var calibration:String;
		[Bindable] public var points:Vector.<Point>;
		[Bindable] public var nativeResolution:Point;
		[Bindable] public var source:String;
		
		public function CaptureVO(name:String = "", bmd:BitmapData = null, timecode:int = -1, nativeResoltion:Point = null, source:String = "") 
		{
			this.name = name;
			_bmd = bmd;
			if (_bmd) {
				imageWidth = _bmd.width;
				imageHeight = _bmd.height;
			}
			this.timecode = timecode;
			this.points = new Vector.<Point>();
			this.nativeResolution = nativeResoltion;
			this.source = source;	
		}
		
		[Bindable(event="_")]public function get bmd():BitmapData
		{
			if (!_bmd && _imageBytes && imageWidth && imageHeight) {
				_bmd = new BitmapData(imageWidth, imageHeight);
				_bmd.setPixels(new Rectangle(0,0,imageWidth,imageHeight),_imageBytes);
				//imageBytes.readBytes(_bmd,0,imageWidth * imageHeight);
			}
			return _bmd;
		}
		
		public function get imageBytes():ByteArray
		{
			return _bmd.getPixels(new Rectangle(0,0,imageWidth,imageHeight));
		}
		
		public function set imageBytes(value:ByteArray):void
		{
			_imageBytes = value;
			_bmd = null;
		}


		public function get length():Number
		{
			var result:Number = 0;
			for (var i:int = 1; i < points.length; i++) {
				result += points[i].subtract(points[i - 1]).length;
			}
			return result;
		}

	}
}