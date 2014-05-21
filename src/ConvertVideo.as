package  
{
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.desktop.NativeProcess;
	import flash.filesystem.File;
	/**
	 * ...
	 * @author Jake Rigby
	 */
	public class ConvertVideo 
	{
		private var _pFile:File;
		private var _vFile:File;
		private var _process:NativeProcess;
		
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
			_vFile.browseForOpen("Select Video File");
		}
		
		private function onSelectHandler(event : Event):void
		{           
			init();
		}

		private function init():void
		{
			if (_process && _process.running) {
				_process.closeInput();
				_process.exit();
			}
			var pInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			pInfo.executable = _pFile;
			_process = new NativeProcess();
			_process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onErrorS);
			_process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR,onError);
			_process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,onError);
			_process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,onError);
			_process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			_process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);
			//debug_info.appendText("PROCESS_INIT_END\n")
			//start_netConnection();
		}

		private function onError(evt:IOErrorEvent):void
		{
			trace(evt.text);
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
		
		private function startProcess():void
		{
			var args:Vector.<String> = new Vector.<String>;
			args.push('-i', _vFile.nativePath, 'force_key_frames', 'expr:gte(t,n_forced*0.04)', _vFile.name.split('.')[0] + '_upscaled');
		}
		
		
	}

}