package com.fosafer.audio 
{
	import flash.utils.*;
	
	public class WAVWriter extends Object
	{
		public function WAVWriter()
		{
			super();
			return;
		}
		
		internal function header(arg1:flash.utils.IDataOutput, arg2:Number):void
		{
			arg1.writeUTFBytes("RIFF");
			arg1.writeUnsignedInt(arg2);
			arg1.writeUTFBytes("WAVE");
			arg1.writeUTFBytes("fmt ");
			arg1.writeUnsignedInt(16);
			arg1.writeShort(this.compressionCode);
			arg1.writeShort(this.numOfChannels);
			arg1.writeUnsignedInt(this.samplingRate);
			arg1.writeUnsignedInt(this.samplingRate * this.numOfChannels * this.sampleBitRate / 8);
			arg1.writeShort(this.numOfChannels * this.sampleBitRate / 8);
			arg1.writeShort(this.sampleBitRate);
			return;
		}
		
		public function processSamples(arg1:flash.utils.IDataOutput, arg2:flash.utils.ByteArray, arg3:int, arg4:int=1):void
		{
			var loc6:*=0;
			var loc7:*=0;
			var loc8:*=0;
			var loc9:*=0;
			var loc10:*=0;
			var loc11:*=0;
			var loc12:*=0;
			var loc13:*=0;
			var loc14:*=NaN;
			var loc15:*=0;
			var loc16:*=0;
			if (!arg2 || arg2.bytesAvailable <= 0) 
			{
				throw new Error("No audio data");
			}
			var loc1:*=(Math.pow(2, this.sampleBitRate) / 2 - 1);
			var loc2:*=this.samplingRate / arg3;
			var loc3:*=arg2.length / 4 * loc2 * this.sampleBitRate / 8;
			var loc4:*=32 + 8 + loc3;
			arg1.endian = flash.utils.Endian.LITTLE_ENDIAN;
			this.header(arg1, loc4);
			arg1.writeUTFBytes("data");
			arg1.writeUnsignedInt(loc3);
			arg2.position = 0;
			var loc5:*;
			(loc5 = new flash.utils.ByteArray()).endian = flash.utils.Endian.LITTLE_ENDIAN;
			while (arg2.bytesAvailable > 0) 
			{
				loc5.clear();
				loc7 = loc6 = Math.min(arg2.bytesAvailable / 4, 8192);
				loc8 = 100;
				loc9 = (loc2 - Math.floor(loc2)) * loc8;
				loc10 = Math.ceil(loc2);
				loc11 = Math.floor(loc2);
				loc12 = 0;
				loc13 = this.numOfChannels - arg4;
				loc14 = 0;
				loc15 = 0;
				while (loc15 < loc7) 
				{
					if ((loc14 = arg2.readFloat()) > 1 || loc14 < -1) 
					{
						throw new Error("Audio samples not in float format");
					}
					if (this.sampleBitRate != 8) 
					{
						loc14 = loc1 * loc14;
					}
					else 
					{
						loc14 = loc1 * loc14 + loc1;
					}
					loc12 = loc9 > 0 && loc15 % loc8 < loc9 ? loc10 : loc11;
					loc16 = 0;
					while (loc16 < loc12) 
					{
						this.writeCorrectBits(loc5, loc14, loc13);
						++loc16;
					}
					loc15 = loc15 + 4;
				}
				arg1.writeBytes(loc5);
			}
			return;
		}
		
		internal function writeCorrectBits(arg1:flash.utils.ByteArray, arg2:Number, arg3:int):void
		{
			if (arg3 < 0) 
			{
				if (this.tempValueCount + arg3 != 1) 
				{
					this.tempValueSum = this.tempValueSum + arg2;
					var loc2:*;
					var loc3:*=((loc2 = this).tempValueCount + 1);
					loc2.tempValueCount = loc3;
					return;
				}
				else 
				{
					arg2 = int(this.tempValueSum / this.tempValueCount);
					this.tempValueSum = 0;
					this.tempValueCount = 0;
					arg3 = 1;
				}
			}
			else 
			{
				++arg3;
			}
			var loc1:*=0;
			while (loc1 < arg3) 
			{
				if (this.sampleBitRate != 8) 
				{
					if (this.sampleBitRate != 16) 
					{
						if (this.sampleBitRate != 24) 
						{
							if (this.sampleBitRate != 32) 
							{
								throw new Error("Sample bit rate not supported");
							}
							else 
							{
								arg1.writeInt(arg2);
							}
						}
						else 
						{
							arg1.writeByte(arg2 & 255);
							arg1.writeByte(arg2 >>> 8 & 255);
							arg1.writeByte(arg2 >>> 16 & 255);
						}
					}
					else 
					{
						arg1.writeShort(arg2);
					}
				}
				else 
				{
					arg1.writeByte(arg2);
				}
				++loc1;
			}
			return;
		}
		
		internal var tempValueSum:Number=0;
		
		internal var tempValueCount:int=0;
		
		public var samplingRate:Number=44100;
		
		public var sampleBitRate:int=16;
		
		public var numOfChannels:int=2;
		
		internal var compressionCode:int=1;
	}
}