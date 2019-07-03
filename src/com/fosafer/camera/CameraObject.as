package com.fosafer.camera
{
	import flash.media.Camera;

	public class CameraObject
	{
		private var width:int;
		private var height:int;
		private var fps:int;
		private var cameraWidth:int;
		private var cameraHeight:int;
		private var camera:Camera;

		
		public function CameraObject()
		{
		}
		
		public function getCamera(cameraWidth:int, cameraHeight:int, fps:int):Camera{
			this.camera = Camera.getCamera();
			if (this.camera != null) {
				this.camera.setMode(cameraWidth,cameraHeight,fps,true);
			} else {
				trace("You need a camera.");
			}
			return this.camera;
		}
		
		
		
		
		
		
		
		
		
		
		private function getCerm(){
			return this.camera;
		}
		private function getWidth(){
			return this.width;
		}
		private function getHeight(){
			return this.height;
		}
		private function getFps(){
			return this.fps;
		}
	}
}