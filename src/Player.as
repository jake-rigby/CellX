package  
{
	import flash.events.Event;
	import flash.media.Video;
	import flash.net.NetStream;
	import mx.core.UIComponent;
	
	/**
	 * ...
	 * @author Jake Rigby
	 */
	public class Player extends UIComponent 
	{
		
		private var _isPlaying:Boolean;
		private var _video:Video;
		private var _stream:NetStream;
		
		public function Player() 
		{
			super();
			_video = new Video();
			addChild(_video);
		}
		
		public function get video():Video
		{
			return _video;
		}
		
		[Bindable(event = "durationChanged")] public function get duration():Number
		{
			return 10;
		}
		
		public function set stream(value:NetStream):void
		{
			if (_stream) {
				_stream.dispose();
				_isPlaying = false;
				dispatchEvent(new Event("playingChanged"));
			}
			_stream = value;
			_video.attachNetStream(value);
			_stream.play();
		}
		
		public function get stream():NetStream
		{
			return _stream;
		}
		
		public function pause():void 
		{
			if (_stream) _stream.pause();
			_isPlaying = false;
			dispatchEvent(new Event("playingChanged"));
		}
		
		public function play():void
		{
			if (_stream) {
				stream.play();
				_isPlaying = true;
				dispatchEvent(new Event("playingChanged"));
			}
		}
		
		[Bindable(event="playingChanged")] public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function get currentTime():Number
		{
			if (_stream) return _stream.time;
			return -1;
		}
		
		public function seek(value:Number):void
		{
			if (_stream) stream.seek(value);
		}
		
		
	}

}