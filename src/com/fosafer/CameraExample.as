package com.fosafer {
	import com.fosafer.audio.MicroObject;
	import com.fosafer.audio.MultipartURLLoader;
	import com.fosafer.audio.WAVWriter;
	import com.fosafer.util.Base64;
	import com.fosafer.util.Flip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.system.*;
	import flash.text.TextField;
	import flash.utils.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	
	
	public class CameraExample extends Sprite {
		private var output:TextField;
		private var video:Video;
		private var microphone:Microphone;
		private var cameraWidth:int = 0;
		private var cameraHeight:int = 0;
		
		protected static var sampleRate:*=44.1;
		protected var microphoneWasMuted:Boolean;
		protected var buffer:flash.utils.ByteArray;
		protected var recordingStartTime:*=0;
		protected var isRecording:Boolean=false;
		
		protected var channel:flash.media.SoundChannel;
		protected var playingProgressTimer:flash.utils.Timer;
		protected var isPlaying:Boolean=false;
		protected var microObject:MicroObject;
		
		public function CameraExample() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			if (ExternalInterface.available) {
				try {
					//output.appendText("Adding callback...\n");
					ExternalInterface.addCallback("initCamera", initCamera);
					ExternalInterface.addCallback("initMicro", initMicro);
					ExternalInterface.addCallback("init", init);
					ExternalInterface.addCallback("test", test);
					ExternalInterface.addCallback("takePhoto", takePhoto);
					ExternalInterface.addCallback("startRecorder", startRecorder);
					ExternalInterface.addCallback("stopRecorder", stopRecorder);
					ExternalInterface.addCallback("audioData", audioData);
					ExternalInterface.addCallback("playVoice", playVoice);
					ExternalInterface.addCallback("stopVoice", stopVoice);
				} catch (error:SecurityError) {
					output.appendText("A SecurityError occurred: " + error.message + "\n");
				} catch (error:Error) {
					output.appendText("An Error occurred: " + error.message + "\n");
				}
			} else {
				output.appendText("External interface is not available for this container.");
			}
			
		}
		
		public function stopVoice():void{
			microObject.stopPlaySound();
		}
		public function playVoice(): void{
			microObject.playRecording();
		}
		
		public function initCamera(cameraWidth:int, cameraHeight:int, fps:int):void{
			// 检测是否有麦克风
//			var mic:Microphone = getMicrophone();
			
			//			//检测是否有摄像头
			var camera:Camera = getCamera(cameraWidth, cameraHeight, fps);
			video = new Video(cameraWidth, cameraHeight);
			video.attachCamera(camera);
			video.smoothing = true;
			addChild(video);
			Flip.flipH(video);
		}
		public function init(cameraWidth:int, cameraHeight:int, fps:int):void{
			// 检测是否有麦克风
						var mic:Microphone = getMicrophone();
			
			//			//检测是否有摄像头
			var camera:Camera = getCamera(cameraWidth, cameraHeight, fps);
			video = new Video(cameraWidth, cameraHeight);
			video.attachCamera(camera);
			addChild(video);
			Flip.flipH(video);
		}
		public function initMicro(): void{
			var mic:Microphone = getMicrophone();
		}
		protected function audioData(method:String, url:String, fileName:String, type:String, params:*):String
		{
			var loc2:*=undefined;
			var loc3:*=undefined;
			var loc4:*=null;
			var loc1:*=";";
			var ml:com.fosafer.audio.MultipartURLLoader;
			var wav:flash.utils.ByteArray;
			var k:*;
			var i:*;

			
			var onReady:Function;
			onReady = function (arg1:flash.events.Event):void
			{
				ExternalInterface.call(method, externalInterfaceEncode(arg1.target.loader.data));
				return;
			}
			ml = new MultipartURLLoader();
			ml.addEventListener(flash.events.Event.COMPLETE, onReady);
				i = 0;
				while (i < params.length) 
				{
					ml.addVariable(params[i][0], params[i][1]);
					++i;
				}
			ml.addFile(this.prepareWav(), "audio.wav", type);
			ml.load(url,false);
			return loc4;
		}
		internal function externalInterfaceEncode(arg1:String):*
		{
			return arg1.split("%").join("%25").split("\\").join("%5c").split("\"").join("%22").split("&").join("%26");
		}
		protected function upload(arg1:String, arg2:String, arg3:*):void
		{
			var uri:String;
			var audioParam:String;
			var parameters:*;
			var wav:flash.utils.ByteArray;
			var ml:MultipartURLLoader;
			var onReady:Function;
			var i:*;
			var k:*;
			
			var loc1:*;
			onReady = null;
			i = undefined;
			k = undefined;
			uri = arg1;
			audioParam = arg2;
			parameters = arg3;
			this.buffer.position = 0;
			wav = this.prepareWav();
			ml = new MultipartURLLoader();;
			ml.addEventListener(flash.events.Event.COMPLETE, onReady);
			if (flash.utils.getQualifiedClassName(parameters.constructor) != "Array") 
			{
				var loc2:*=0;
				var loc3:*=parameters;
				for (k in loc3) 
				{
					ml.addVariable(k, parameters[k]);
				}
			}
			else 
			{
				i = 0;
				while (i < parameters.length) 
				{
					ml.addVariable(parameters[i][0], parameters[i][1]);
					++i;
				}
			}
			ml.addFile(wav, "audio.wav", audioParam);
			ml.load(uri, false);
			return;
		}
		protected function stopRecorder():void{
			microObject.stopRecording();
		}
		// 开启麦克风
		protected function startRecorder():void{
			microObject.startRecording();
		}
		
		
		
		public function takePhoto(method:String):void{
				var bitmapdata:BitmapData = new BitmapData(cameraWidth,cameraHeight);
//				//把vid中的内容画到bitmapdata中。
				bitmapdata.draw(this.video);
//				
				var bs:ByteArray = new ByteArray();
				bitmapdata.encode(new Rectangle(0,0,cameraWidth,cameraHeight),new flash.display.JPEGEncoderOptions(), bs);
				var base64Code:String = Base64.encode(bs);
				
			
				if (ExternalInterface.available) {
					ExternalInterface.call(method,base64Code);
				}
		}
		
		
		//测试接口
		public function test(value:String):void{
			if (ExternalInterface.available) {
				ExternalInterface.call("testR", "flash="+value);
			}
		}
		
		public function triggerEvent(arg1:String, arg2:*, arg3:*=null):void
		{
			ExternalInterface.call("Recorder.triggerEvent", arg1, arg2, arg3);
			return;
		}
		
		public function activityHandler(event:ActivityEvent):void {
			trace("activityHandler: " + event);
		}
		
		public function statusHandler(event:StatusEvent):void {
			trace("statusHandler: " + event);
		}
		
		public function getMicrophone():Microphone{
			var mic:Microphone = Microphone.getMicrophone();
//			mic.setLoopBack(true);
			mic.noiseSuppressionLevel = -30 ;
			microObject = new MicroObject();
			microObject.setMicrophone(mic);
			return mic;
		}
		
		public function getCamera(cameraWidth:int, cameraHeight:int, fps:int):Camera{
			var camera:Camera = Camera.getCamera();
			if (camera != null) {
				this.cameraWidth = cameraWidth;
				this.cameraHeight = cameraHeight;
				camera.setMode(cameraWidth,cameraHeight,fps,true);
				camera.setQuality(0, 100);
			} else {
				trace("You need a camera.");
			}
			return camera;
		}
		
		protected function prepareWav():flash.utils.ByteArray
		{
			var loc1:*=new flash.utils.ByteArray();
			var loc2:*=new WAVWriter();
			this.buffer = this.microObject.getSound();
			this.buffer.position = 0;
			loc2.numOfChannels = 1;
			loc2.sampleBitRate = 16;
			loc2.samplingRate = sampleRate * 1000;
			loc2.processSamples(loc1, this.buffer, sampleRate * 1000, 1);
			return loc1;
		}
		
		

		
	}
}