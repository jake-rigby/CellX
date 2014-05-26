package  
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Jake Rigby
	 * http://www.purplesquirrels.com.au/2013/02/converting-video-with-ffmpeg-and-adobe-air/
	 */
	public class ConvertVideo extends EventDispatcher
	{
		private var _pFile:File;
		private var _vFile:File;
		private var _oFile:File;
		private var _process:NativeProcess;
		private var _pInfo:NativeProcessStartupInfo;
		private var _checkerTimer:Timer;
		
		public function ConvertVideo() 
		{
			_pFile = File.applicationDirectory.resolvePath("ffmpeg.exe");
			browseVideo();
		}
			
		public function browseVideo():void
		{
			if (! _vFile) {
				_vFile = new File();
			}
			_vFile.addEventListener(Event.SELECT, onSelectHandler);
			_vFile.addEventListener(Event.CANCEL, onCancelHandler);
			_vFile.browseForOpen("Select video source file");
		}
		
		public function get outputFile():File
		{
			return _oFile;
		}
		
		private function onSelectHandler(event : Event):void
		{           
			init();
		}
		
		private function onCancelHandler(event:Event):void
		{
			dispatchEvent(new ConversionProgressEvent(ConversionProgressEvent.CONVERSION_CANCELLED));
		}

		private function init():void
		{
			if (_process && _process.running) {
				_process.closeInput();
				_process.exit();
			}
			_pInfo = new NativeProcessStartupInfo();
			_pInfo.executable = _pFile;
			_process = new NativeProcess();
			_process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,progress);
			_process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR,progress);
			_process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,progress);
			_process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,progress);
			_process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			_process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);
			_process.addEventListener(NativeProcessExitEvent.EXIT, onProcessExit);
			startProcess();
		}
		
		private var _currentSeconds:Number = 0;
		private var _totalSeconds:Number = 0;
		
		private function progress(e:ProgressEvent):void 
		{
			// read the data from the error channel bytearray to string
			var s:String = _process.standardError.readUTFBytes(_process.standardError.bytesAvailable);
			
			dispatchEvent(new ConversionProgressEvent(ConversionProgressEvent.CONVERSION_PROGRESS, s));
			
			// stuff for finding timecodes
			var reg:RegExp;
			var matches:Array;
			var time:Array;
			
			// if the message includes frame=, this is a frame progress message
			// the message will be something like:
			//     frame= 1018 fps=226 q=31.0 size=    3634kB time=00:00:41.79 bitrate= 712.2kbits/s 
			// we need to extract the current time: time=00:00:41:79
			if (s.indexOf("frame=") != -1)
			{
				//is progress
				reg = /time=([^ ]+)/; // regexp to extract time portion
				matches = s.match(reg);
				
				if (matches.length > 0)
				{
					// split timestamp into sections
					time = matches[0].substring(5).split(":");
					// calculate the total seconds from the time stamp to get current seconds
					_currentSeconds = Math.round(((Number(time[0]) * 3600) + (Number(time[1]) * 60) + Number(time[2])));
					
				}
			}
			// Duration is sent at the beginning of the process which tells us how long the video is
			else if (s.indexOf("Duration:") != -1)
			{
				// find duration
				reg = /Duration:([^,]+)/; // regepx to extract duration portion
				matches = s.match(reg);
				
				if (matches.length > 0)
				{
					// split timestamp into sections
					time = matches[0].split(":");
					// calculate the total seconds from the time stamp to get total seconds
					_totalSeconds = Math.round(((Number(time[1]) * 3600) + (Number(time[2]) * 60) + Number(time[3])));
				}
			}
			// trace out the message if it contains Error, as there was probably something wrong with the encoding settings
			else if (s.indexOf("Error ") != -1)
			{
				trace("Error: " + s);
			}
			
			// trace percentage
			trace( Math.round(_currentSeconds / _totalSeconds * 100) + "%");
		}		
		private function onErrorS(evt:ProgressEvent):void
		{
			var n:Number = _process.standardError.bytesAvailable;
			var s:String = _process.standardError.readUTFBytes(n);
		}
		
		private function inputProgressListener(evt:ProgressEvent):void
		{
			trace('input progress '+evt.bytesLoaded);
		}
		
		private function onOutputData(evt:ProgressEvent):void
		{
			if (_process.running)
			{
				trace(evt.bytesTotal);
			}
		}
		
		private function onProcessExit(evt:NativeProcessExitEvent):void
		{
			trace(evt.exitCode);
		}
		
		private function startProcess():void
		{
			var p:Array = _vFile.name.split('.');
			if (p.length > 1) p.pop();
			p.push('flv');
			var outp:String = _vFile.parent.nativePath + '\\' + p.join('.');
			//var outp:String = "'" + p.join('.')+"'";
			_oFile = new File(outp);
			_pInfo.arguments = new Vector.<String>;
			_pInfo.arguments.push(
				'-i', _vFile.nativePath,
				'-ar', '44100',
				'-force_key_frames', "expr:gte(t,n_forced*0.04)",
				'-b:v', '2048k',
				'-y',
				'-qscale','0',
				outp);
			var evt:Event = new ConversionProgressEvent(ConversionProgressEvent.CONVERSION_STARTED);
			dispatchEvent(evt);
			if (_process.running) {
				_process.closeInput();
				_process.exit();
			}
			_process.start(_pInfo);
			if (_checkerTimer) {
				_checkerTimer.stop();
				_checkerTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			}
			_checkerTimer = new Timer(100);
			_checkerTimer.addEventListener(TimerEvent.TIMER, onTimer);
			_checkerTimer.start();
			
		}
		
		private function onTimer(evt:TimerEvent):void 
		{
			// see if the target file is created
			if (!_process.running){//_oFile.exists) {
				_checkerTimer.stop();
				_checkerTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				var e:Event = new ConversionProgressEvent(ConversionProgressEvent.CONVERSION_COMPLETE, 'Conversion successful', _oFile);
				dispatchEvent(e);
			} else {
				_checkerTimer.reset();
				_checkerTimer.start();
			}
		}
	}

}