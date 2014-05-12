package
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	public class CaptureVO extends EventDispatcher
	{
		private var _name:String;
		private var _bmd:BitmapData;
		private var _timecode:int;
		private var _points:Vector.<Point>;
		private var _nativeResolution:Point;
		private var _source:String;
		
		public function CaptureVO(name:String, bmd:BitmapData, timecode:int, nativeResoltion:Point, source:String) 
		{
			_name = name;
			_bmd = bmd;
			_timecode = timecode;
			_points = new Vector.<Point>();
			_nativeResolution = nativeResoltion;
			_source = source;	
		}

		[Bindable(event="nameChanged")]public function get name():String
		{
			return _name;
		}
		
		public function set name(value:String):void
		{
			_name = value;
			dispatchEvent(new Event("nameChanged"));
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
				result += _points[i].subtract(_points[i - 1]).length;
			}
			return result;
		}

		[Bindable(event="event")]public function get nativeResolution():Point
		{
			return _nativeResolution;
		}
		
		[Bindable(event="event")]public function get source():String
		{
			return _source;
		}

	}
}