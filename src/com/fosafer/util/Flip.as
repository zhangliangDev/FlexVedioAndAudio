package com.fosafer.util
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Video;

	public class Flip
	{
		public function Flip()
		{
			
		
		}
		// 水平翻转
		public static function flipH(target:DisplayObject):void
		{
			if(!target || !target.parent)
			{
				return;
			}
			
			var matrix:Matrix=target.transform.matrix;
			//如果设置了3D属性，则matrix会变成null，无法再执行2D水平翻转
			if(!matrix)
			{
				return;
			}
			
			var bound:Rectangle=target.getBounds(target.parent);
			var cX:Number=bound.x+bound.width/2;
			var m:Matrix=new Matrix(-1,0,0,1,cX*2,0);
			matrix.concat(m);
			target.transform.matrix=matrix;
		}
		
		//垂直翻转
		public static function flipV(target:DisplayObject):void
		{
			if(!target || !target.parent)
			{
				return;
			}
			
			var matrix:Matrix=target.transform.matrix;
			//如果设置了3D属性，则matrix会变成null，无法再执行2D垂直翻转
			if(!matrix)
			{
				return;
			}
			
			var bound:Rectangle=target.getBounds(target.parent);
			var cY:Number=bound.y+bound.height/2;
			var m:Matrix=new Matrix(1,0,0,-1,0,cY*2);
			matrix.concat(m);
			target.transform.matrix=matrix;
		}
	}
}