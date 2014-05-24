package
{
	import flash.events.Event;
	import org.osmf.events.TimeEvent;
	import spark.skins.spark.ButtonSkin;
	
	import spark.components.HSlider;
	import spark.components.VideoDisplay;
	import spark.events.TrackBaseEvent;
	
	[Event(name="positionChanged", type="flash.events.Event")]
	
	public class VideoScrub extends HSlider
	{
		private var _videoDisplay:VideoDisplay;
		
		public function VideoScrub()
		{
			super();
			addEventListener(TrackBaseEvent.THUMB_PRESS, onThumbPress);
			addEventListener(TrackBaseEvent.THUMB_RELEASE, onTumbRelease);
			addEventListener(TrackBaseEvent.THUMB_DRAG, onThumbDrag);
		}
		
		protected function onThumbDrag(event:TrackBaseEvent):void
		{
			if (_videoDisplay) {
				_videoDisplay.seek(value);
				dispatchEvent(new VideoScrubEvent(VideoScrubEvent.POSITION_CHANGED, value));
			}
		}
		
		protected function onTumbRelease(event:TrackBaseEvent):void
		{
			if (_videoDisplay) {
				_videoDisplay.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
				_videoDisplay.seek(value);
				dispatchEvent(new VideoScrubEvent(VideoScrubEvent.POSITION_CHANGED, value));
			}
		}
		
		protected function onThumbPress(event:TrackBaseEvent):void
		{
			if (_videoDisplay) {
				_videoDisplay.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			}
		}
		
		public function get videoDisplay():VideoDisplay
		{
			return _videoDisplay;
		}

		public function set videoDisplay(value:VideoDisplay):void
		{
			if (_videoDisplay) {
				_videoDisplay.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			}
			_videoDisplay = value;
			_videoDisplay.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
		}
		
		protected function onCurrentTimeChange(event:TimeEvent):void
		{
			this.value = event.time;
		}
		
	}
}