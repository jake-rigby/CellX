package
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	public class CaptureVO extends EventDispatcher
	{
		private var _name:String;
		private var _bmd:BitmapData;
		private var _timecode:int;
		private var _points:Vector.<Point>;
		private var _nativeResolution:Point;
		
		public function CaptureVO(name:String, bmd:BitmapData, timecode:int, nativeResoltion:Point) 
		{
			_name = name;
			_bmd = bmd;
			_timecode = timecode;
			_points = new Vector.<Point>();
			_nativeResolution = nativeResoltion;
			
		}

		[Bindable(event="event")]public function get name():String
		{
			return _name;
		}

		[Bindable(event="event")]public function get bmd():BitmapData
		{
			return _bmd;
		}

		[Bindable(event="event")]public function get timecode():int
		{
			return _timecode;
		}

		[Bindable(event="event")]public function get points():Vector.<Point>
		{
			return _points;
		}

		public function get length():Number
		{
			var result:Number = 0;
			for (var i:int = 1; i < _points.length; i++) {
				result = _points[i].subtract(_points[i - 1]).length;
			}
			return result;
		}

		[Bindable(event="event")]public function get nativeResolution():Point
		{
			return _nativeResolution;
		}

	}
}