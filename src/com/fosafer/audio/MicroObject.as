package com.fosafer.audio
{
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	

	public class MicroObject
	{
		public function MicroObject()
		{
		}
		private var microphone:Microphone;
		private var isRecording:Boolean = false;
		private var soundByteArray:ByteArray;
		private var soundObj:Sound;
		private var soundChannel:SoundChannel;
		/**
		 * 开始录音
		 */
		public function startRecording():void
		{
			
			soundByteArray = new ByteArray();
			
			microphone.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			microphone.rate = 44; //麦克风捕获声音采样速率
			microphone.gain = 50; //麦克风在传输音频信号之前需要倍增音量
			
			//设置应该考虑为声音的最小输入音量水平，以及静默实际开始之前的静音时间量
			microphone.setSilenceLevel(0, 1000);
		}
		
		/**
		 * 停止录音
		 */
		public function stopRecording():void
		{
			
			microphone.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		}
		
		/**
		 * 录音中-录音数据持续接收响应
		 */
		public function onSampleData(micData:SampleDataEvent):void
		{
			//持续记录音频流
			soundByteArray.writeBytes(micData.data);
		}
		/**
		 * 开始播放录音
		 */
		public function playRecording():void
		{
			var trans:SoundTransform = new SoundTransform(1, 0);
			soundByteArray.position = 0;
			soundObj = new Sound();
			soundObj.addEventListener(SampleDataEvent.SAMPLE_DATA, playSound);
			soundChannel = soundObj.play(0, 1, trans);
		}
		/**
		 * 停止播放录音
		 */
		public function stopPlaySound():void
		{
			if(soundChannel!=null){
				soundChannel.stop();
				soundChannel = null;
			}
		}
		
		/**
		 * 录音播放中
		 */
		public function playSound(e:SampleDataEvent):void
		{
			if (!soundByteArray.bytesAvailable > 0)
			{
				return;
			}
			
			for (var i:int = 0; i < 8192; i++)
			{
				var audioSample:Number = 0;
				
				if (soundByteArray.bytesAvailable > 0)
				{
					audioSample = soundByteArray.readFloat();
				}
				
				//调用writeFloat()方法两次是为了音频数据采样能同时命中左声道和右声道
				e.data.writeFloat(audioSample);
				e.data.writeFloat(audioSample);
			}
		}
		
		public function getSound():ByteArray {
			return this.soundByteArray;
		}
		
		public function setMicrophone(micro:Microphone):void{
			this.microphone = micro;
		}
	}
}