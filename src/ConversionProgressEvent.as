package  
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	/**
	 * ...
	 * @author Jake Rigby
	 */
	public class ConversionProgressEvent extends Event 
	{
		public static const CONVERSION_COMPLETE:String = "conversionComplete";
		public static const CONVERSION_STARTED:String = "conversionStarted";
		public static const CONVERSION_PROGRESS:String = "conversionProgress";
		public static const CONVERSION_CANCELLED:String = "conversionCancelled";
		
		
		private var _msg:String;
		private var _file:File;
		
		public function ConversionProgressEvent(type:String, msg:String = '', file:File = null) 
		{
			super(type, false, false);
			this._msg = msg;
			this._file = file;
		}
		
		public function get msg():String
		{
			return _msg;
		}
		
		public function get file():File
		{
			return _file;
		}
		
	}

}