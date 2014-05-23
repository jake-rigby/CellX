package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class VideoScrubEvent extends Event 
	{
		public static const POSITION_CHANGED:String = "positionChanged";
		
		private var _position:Number;
		
		public function VideoScrubEvent(type:String, position:Number) 
		{
			super(type, false, false);
			_position = position;
		}
		
		public function get position():Number
		{
			return _position;
		}
		
	}

}