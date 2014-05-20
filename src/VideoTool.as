/*
https://suzhiyam.wordpress.com/2011/05/05/as3ffmpeg-play-multi-video-formats-in-air/
*/
package
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import spark.components.VideoDisplay;
	
	import mx.core.mx_internal;
	
	import  org.osmf.media.MediaPlayer;
	
	public class VideoTool extends EventDispatcher
	{
		private var pFile:File;
		private var vfile:File;
		private var process:NativeProcess;
		private var pInfo:NativeProcessStartupInfo;
		private var args:Vector.<String> ;
		
		private var stream:NetStream;
		private var connection:NetConnection;
		
		private var video:Video;
		
		public function VideoTool(video:Video)
		{
			this.video = video;
			if (!NativeProcess.isSupported) 
				throw new Error("Native Process not supported");			
			pFile = File.applicationDirectory.resolvePath("ffmpeg.exe"); //<-- ensure present locally
			
		}
		
		public function seek(offset:Number):void
		{
			stream.seek(offset);
		}

		private function init():void
		{
			if (process && process.running) {
				process.closeInput();
				process.exit();
			}
			pInfo = new NativeProcessStartupInfo();
			pInfo.executable = pFile;
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA,onErrorS);
			process.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR,onError);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR,onError);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR,onError);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			//process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);
			//debug_info.appendText("PROCESS_INIT_END\n")
			start_netConnection();
		}

		private function onError(evt:IOErrorEvent):void
		{
			trace(evt.text);
		}
		
		private function onErrorS(evt:ProgressEvent):void
		{
			var n:Number = process.standardError.bytesAvailable;
			var s:String = process.standardError.readUTFBytes(n);
		}
		
		private function inputProgressListener(evt:ProgressEvent):void
		{
			trace('input progress '+evt.bytesLoaded);
		}
		
		private function onOutputData(evt:ProgressEvent):void
		{
			if (process.running)
			{
				var videoStream : ByteArray = new ByteArray();
				process.standardOutput.readBytes(videoStream,0,process.standardOutput.bytesAvailable);
				stream.appendBytes(videoStream);
			}
		}
		
		private function start_netConnection():void
		{
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetstatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);			
		}
		
		private function onNetstatusHandler(event:NetStatusEvent):void
		{
			trace(event.toString());
			
			switch (event.info.code)
			{
				case "NetConnection.Connect.Success" :
					start_decode_process();
					dispatchEvent(event);
					break;
				
				case "NetStream.Play.StreamNotFound" :
					trace("Stream not found: ");
					break;
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace(event.toString());
		}
		
		private function start_decode_process():void
		{
			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, onNetstatusHandler);
			stream.client = { onMetaData:metaDataHandler };
			video.attachNetStream(stream);
			//video.mx_internal::videoPlayer.visible = true;
			//videoDisplay.mx_internal::videoPlayer.attachNetStream(incomingStream);
			//videoDisplay.mx_internal::videoPlayer.visible = true;			stream.play(null);
			args = new Vector.<String>();
			//args.push("-i",vfile.nativePath,"-sameq","-f","flv","-");
			args.push('-i',vfile.nativePath,'-ar','22050','-b:v','2048k','-f','flv','-','-g:1'); // <-- see comments in reference
			pInfo.arguments = args;
			if (process.running) {
				process.closeInput();
				process.exit();
			}
			process.start(pInfo);
		}
		
		public function browseVideo():void
		{
			if (! vfile) {
				vfile = new File();
			}
			vfile.addEventListener(Event.SELECT, onSelectHandler);
			vfile.browseForOpen("Select Video File");
		}
		
		private function onSelectHandler(event : Event):void
		{           
			init();
		}
		
		private function metaDataHandler(infoObject:Object):void
		{
			trace(infoObject);
			var w:Number = infoObject.width;
			var h:Number = infoObject.height;
			var whR:Number = h / w;
			var hwR:Number = w / h;
			var vw:Number;
			var vh:Number;
			if (w >= h)
			{
				vw = Math.min(480,w);
				vh = vw * whR;
			}
			else
			{
				vh = Math.min(360,h);
				vw = vh * hwR;
			}
			video.width = vw;
			video.height = vh;
			video.x=(480-vw)/2;
			video.y=(360-vh)/2;
		}
		
	}
	
}