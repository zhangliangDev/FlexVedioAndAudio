//class MultipartURLLoader
package com.fosafer.audio
{
	import flash.errors.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class MultipartURLLoader extends flash.events.EventDispatcher
	{
		public function MultipartURLLoader()
		{
			super();
			this._fileNames = new Array();
			this._files = new flash.utils.Dictionary();
			this._variableNames = new Array();
			this._variables = new flash.utils.Dictionary();
			this._loader = new flash.net.URLLoader();
			this.requestHeaders = new Array();
			return;
		}
		
		internal function getFilePartData(arg1:flash.utils.ByteArray, arg2:FilePart):flash.utils.ByteArray
		{
			arg1.writeBytes(arg2.fileContent, 0, arg2.fileContent.length);
			return arg1;
		}
		
		internal function onProgress(arg1:flash.events.ProgressEvent):void
		{
			dispatchEvent(arg1);
			return;
		}
		
		internal function onComplete(arg1:flash.events.Event):void
		{
			this.removeListener();
			dispatchEvent(arg1);
			return;
		}
		
		internal function onIOError(arg1:flash.events.IOErrorEvent):void
		{
			this.removeListener();
			dispatchEvent(arg1);
			return;
		}
		
		internal function onSecurityError(arg1:flash.events.SecurityErrorEvent):void
		{
			this.removeListener();
			dispatchEvent(arg1);
			return;
		}
		
		public function get PREPARED():Boolean
		{
			return this._prepared;
		}
		
		internal function onHTTPStatus(arg1:flash.events.HTTPStatusEvent):void
		{
			dispatchEvent(arg1);
			return;
		}
		
		internal function addListener():void
		{
			this._loader.addEventListener(flash.events.Event.COMPLETE, this.onComplete, false, 0, false);
			this._loader.addEventListener(flash.events.ProgressEvent.PROGRESS, this.onProgress, false, 0, false);
			this._loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, this.onIOError, false, 0, false);
			this._loader.addEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, this.onHTTPStatus, false, 0, false);
			this._loader.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError, false, 0, false);
			return;
		}
		
		internal function removeListener():void
		{
			this._loader.removeEventListener(flash.events.Event.COMPLETE, this.onComplete);
			this._loader.removeEventListener(flash.events.ProgressEvent.PROGRESS, this.onProgress);
			this._loader.removeEventListener(flash.events.IOErrorEvent.IO_ERROR, this.onIOError);
			this._loader.removeEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS, this.onHTTPStatus);
			this._loader.removeEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, this.onSecurityError);
			return;
		}
		
		internal function BOUNDARY(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			var loc1:*=this.getBoundary().length;
			arg1 = this.DOUBLEDASH(arg1);
			var loc2:*=0;
			while (loc2 < loc1) 
			{
				arg1.writeByte(this._boundary.charCodeAt(loc2));
				++loc2;
			}
			return arg1;
		}
		
		internal function QUOTATIONMARK(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			arg1.writeByte(34);
			return arg1;
		}
		
		internal function DOUBLEDASH(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			arg1.writeShort(11565);
			return arg1;
		}
		
		internal function nextAsyncLoop():void
		{
			var loc1:*=null;
			if (this.asyncFilePointer < this._fileNames.length) 
			{
				loc1 = this._files[this._fileNames[this.asyncFilePointer]] as FilePart;
				this._data = this.getFilePartHeader(this._data, loc1);
				this.asyncWriteTimeoutId = flash.utils.setTimeout(this.writeChunkLoop, 10, this._data, loc1.fileContent, 0);
				var loc2:*;
				var loc3:*=((loc2 = this).asyncFilePointer + 1);
				loc2.asyncFilePointer = loc3;
			}
			else 
			{
//				this._data = this.closeFilePartsData(this._data);
				this._data = this.closeDataObject(this._data);
				this._prepared = true;
			}
			return;
		}
		
		internal function writeChunkLoop(arg1:flash.utils.ByteArray, arg2:flash.utils.ByteArray, arg3:uint=0):void
		{
			var loc1:*=Math.min(BLOCK_SIZE, arg2.length - arg3);
			arg1.writeBytes(arg2, arg3, loc1);
			if (loc1 < BLOCK_SIZE || arg3 + loc1 >= arg2.length) 
			{
				arg1 = this.LINEBREAK(arg1);
				this.nextAsyncLoop();
				return;
			}
			arg3 = arg3 + loc1;
			this.writtenBytes = this.writtenBytes + loc1;
			if (this.writtenBytes % BLOCK_SIZE * 2 == 0) 
			{
			}
			this.asyncWriteTimeoutId = flash.utils.setTimeout(this.writeChunkLoop, 10, arg1, arg2, arg3);
			return;
		}
		
		
		{
			BLOCK_SIZE = 64 * 1024;
		}
		
		public function load(arg1:String, arg2:Boolean=false):void
		{
			if (arg1 == null || arg1 == "") 
			{
				throw new flash.errors.IllegalOperationError("You cant load without specifing PATH");
			}
			this._path = arg1;
			this._async = arg2;
			if (this._async) 
			{
				if (this._prepared) 
				{
					this.doSend();
				}
				else 
				{
					this.constructPostDataAsync();
				}
			}
			else 
			{
				this._data = this.constructPostData();
				this.doSend();
			}
			return;
		}
		
		public function startLoad():void
		{
			if (this._path == null || this._path == "" || this._async == false) 
			{
				throw new flash.errors.IllegalOperationError("You can use this method only if loading asynchronous.");
			}
			if (!this._prepared && this._async) 
			{
				throw new flash.errors.IllegalOperationError("You should prepare data before sending when using asynchronous.");
			}
			this.doSend();
			return;
		}
		
		public function prepareData():void
		{
			this.constructPostDataAsync();
			return;
		}
		
		public function close():void
		{
			try 
			{
				this._loader.close();
			}
			catch (e:Error)
			{
			};
			return;
		}
		
		public function addVariable(arg1:String, arg2:Object=""):void
		{
			if (this._variableNames.indexOf(arg1) == -1) 
			{
				this._variableNames.push(arg1);
			}
			this._variables[arg1] = arg2;
			this._prepared = false;
			return;
		}
		
		public function addFile(arg1:flash.utils.ByteArray, arg2:String, arg3:String="Filedata", arg4:String="application/octet-stream"):void
		{
			var loc1:*=null;
			if (this._fileNames.indexOf(arg2) != -1) 
			{
				loc1 = this._files[arg2] as FilePart;
				this.totalFilesSize = this.totalFilesSize - loc1.fileContent.length;
				loc1.fileContent = arg1;
				loc1.fileName = arg2;
				loc1.dataField = arg3;
				loc1.contentType = arg4;
				this.totalFilesSize = this.totalFilesSize + arg1.length;
			}
			else 
			{
				this._fileNames.push(arg2);
				this._files[arg2] = new FilePart(arg1, arg2, arg3, arg4);
				this.totalFilesSize = this.totalFilesSize + arg1.length;
			}
			this._prepared = false;
			return;
		}
		
		public function clearVariables():void
		{
			this._variableNames = new Array();
			this._variables = new flash.utils.Dictionary();
			this._prepared = false;
			return;
		}
		
		public function clearFiles():void
		{
			var loc1:*=null;
			var loc2:*=0;
			var loc3:*=this._fileNames;
			for each (loc1 in loc3) 
			{
				(this._files[loc1] as FilePart).dispose();
			}
			this._fileNames = new Array();
			this._files = new flash.utils.Dictionary();
			this.totalFilesSize = 0;
			this._prepared = false;
			return;
		}
		
		public function dispose():void
		{
			flash.utils.clearInterval(this.asyncWriteTimeoutId);
			this.removeListener();
			this.close();
			this._loader = null;
			this._boundary = null;
			this._variableNames = null;
			this._variables = null;
			this._fileNames = null;
			this._files = null;
			this.requestHeaders = null;
			this._data = null;
			return;
		}
		
		public function getBoundary():String
		{
			var loc1:*=0;
			if (this._boundary == null) 
			{
				this._boundary = "";
				loc1 = 0;
				while (loc1 < 32) 
				{
					this._boundary = this._boundary + String.fromCharCode(int(97 + Math.random() * 25));
					++loc1;
				}
			}
			return this._boundary;
		}
		
		public function get ASYNC():Boolean
		{
			return this._async;
		}
		
		internal function LINEBREAK(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			arg1.writeShort(3338);
			return arg1;
		}
		
		public function get dataFormat():String
		{
			return this._loader.dataFormat;
		}
		
		public function set dataFormat(arg1:String):void
		{
			if (!(arg1 == flash.net.URLLoaderDataFormat.BINARY) && !(arg1 == flash.net.URLLoaderDataFormat.TEXT) && !(arg1 == flash.net.URLLoaderDataFormat.VARIABLES)) 
			{
				throw new flash.errors.IllegalOperationError("Illegal URLLoader Data Format");
			}
			this._loader.dataFormat = arg1;
			return;
		}
		
		public function get loader():flash.net.URLLoader
		{
			return this._loader;
		}
		public function getFileData():ByteArray{
			return this._data;
		}
		internal function doSend():void
		{
			var loc1:*=new flash.net.URLRequest();
			loc1.url = this._path;
			loc1.method = flash.net.URLRequestMethod.POST;
			loc1.data = this._data;
			loc1.requestHeaders.push(new flash.net.URLRequestHeader("Content-type", "multipart/form-data; boundary=" + this.getBoundary()));
			if (this.requestHeaders.length) 
			{
				loc1.requestHeaders = loc1.requestHeaders.concat(this.requestHeaders);
			}
			this.addListener();
			this._loader.load(loc1);
			return;
		}
		
		internal function constructPostDataAsync():void
		{
			flash.utils.clearInterval(this.asyncWriteTimeoutId);
			this._data = new flash.utils.ByteArray();
			this._data.endian = flash.utils.Endian.BIG_ENDIAN;
			this._data = this.constructVariablesPart(this._data);
			this.asyncFilePointer = 0;
			this.writtenBytes = 0;
			this._prepared = false;
			if (this._fileNames.length) 
			{
				this.nextAsyncLoop();
			}
			else 
			{
				this._data = this.closeDataObject(this._data);
				this._prepared = true;
			}
			return;
		}
		
		internal function constructPostData():flash.utils.ByteArray
		{
			var loc1:*=new flash.utils.ByteArray();
			loc1.endian = flash.utils.Endian.BIG_ENDIAN;
			loc1 = this.constructVariablesPart(loc1);
			loc1 = this.constructFilesPart(loc1);
			loc1 = this.closeDataObject(loc1);
			return loc1;
		}
		
		internal function closeDataObject(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			arg1 = this.BOUNDARY(arg1);
			arg1 = this.DOUBLEDASH(arg1);
			return arg1;
		}
		
		internal function constructVariablesPart(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			var loc1:*=0;
			var loc2:*=null;
			var loc3:*=null;
			var loc4:*=0;
			var loc5:*=this._variableNames;
			for each (loc3 in loc5) 
			{
				arg1 = this.BOUNDARY(arg1);
				arg1 = this.LINEBREAK(arg1);
				loc2 = "Content-Disposition: form-data; name=\"" + loc3 + "\"";
				loc1 = 0;
				while (loc1 < loc2.length) 
				{
					arg1.writeByte(loc2.charCodeAt(loc1));
					++loc1;
				}
				arg1 = this.LINEBREAK(arg1);
				arg1 = this.LINEBREAK(arg1);
				arg1.writeUTFBytes(this._variables[loc3]);
				arg1 = this.LINEBREAK(arg1);
			}
			return arg1;
		}
		
		internal function constructFilesPart(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			var loc1:*=0;
			var loc2:*=null;
			var loc3:*=null;
			if (this._fileNames.length) 
			{
				var loc4:*=0;
				var loc5:*=this._fileNames;
				for each (loc3 in loc5) 
				{
					arg1 = this.getFilePartHeader(arg1, this._files[loc3] as FilePart);
					arg1 = this.getFilePartData(arg1, this._files[loc3] as FilePart);
					arg1 = this.LINEBREAK(arg1);
				}
//				arg1 = this.closeFilePartsData(arg1);
			}
			return arg1;
		}
		
		internal function closeFilePartsData(arg1:flash.utils.ByteArray):flash.utils.ByteArray
		{
			var loc1:*=0;
			var loc2:*=null;
			arg1 = this.LINEBREAK(arg1);
			arg1 = this.BOUNDARY(arg1);
			arg1 = this.LINEBREAK(arg1);
			loc2 = "Content-Disposition: form-data; name=\"Upload\"";
			loc1 = 0;
			while (loc1 < loc2.length) 
			{
				arg1.writeByte(loc2.charCodeAt(loc1));
				++loc1;
			}
			arg1 = this.LINEBREAK(arg1);
			arg1 = this.LINEBREAK(arg1);
			loc2 = "Submit Query";
			loc1 = 0;
//			while (loc1 < loc2.length) 
//			{
//				arg1.writeByte(loc2.charCodeAt(loc1));
//				++loc1;
//			}
			arg1 = this.LINEBREAK(arg1);
			return arg1;
		}
		
		internal function getFilePartHeader(arg1:flash.utils.ByteArray, arg2:FilePart):flash.utils.ByteArray
		{
			var loc1:*=0;
			var loc2:*=null;
			arg1 = this.BOUNDARY(arg1);
			arg1 = this.LINEBREAK(arg1);
			loc2 = "Content-Disposition: form-data; name=\"Filename\"";
			loc1 = 0;
//			while (loc1 < loc2.length) 
//			{
//				arg1.writeByte(loc2.charCodeAt(loc1));
//				++loc1;
//			}
//			arg1 = this.LINEBREAK(arg1);
//			arg1 = this.LINEBREAK(arg1);
//			arg1.writeUTFBytes(arg2.fileName);
//			arg1 = this.LINEBREAK(arg1);
//			arg1 = this.BOUNDARY(arg1);
//			arg1 = this.LINEBREAK(arg1);
			loc2 = "Content-Disposition: form-data; name=\"" + arg2.dataField + "\"; filename=\"";
			loc1 = 0;
			while (loc1 < loc2.length) 
			{
				arg1.writeByte(loc2.charCodeAt(loc1));
				++loc1;
			}
			arg1.writeUTFBytes(arg2.fileName);
			arg1 = this.QUOTATIONMARK(arg1);
			arg1 = this.LINEBREAK(arg1);
			loc2 = "Content-Type: " + arg2.contentType;
			loc1 = 0;
			while (loc1 < loc2.length) 
			{
				arg1.writeByte(loc2.charCodeAt(loc1));
				++loc1;
			}
			arg1 = this.LINEBREAK(arg1);
			arg1 = this.LINEBREAK(arg1);
			return arg1;
		}
		
		internal var _loader:flash.net.URLLoader;
		
		internal var _boundary:String;
		
		internal var _variableNames:Array;
		
		internal var _fileNames:Array;
		
		internal var _variables:flash.utils.Dictionary;
		
		internal var _async:Boolean=false;
		
		internal var _path:String;
		
		internal var _data:flash.utils.ByteArray;
		
		internal var _prepared:Boolean=false;
		
		internal var asyncWriteTimeoutId:Number;
		
		internal var asyncFilePointer:uint=0;
		
		internal var totalFilesSize:uint=0;
		
		internal var writtenBytes:uint=0;
		
		public var requestHeaders:Array;
		
		public static var BLOCK_SIZE:uint=65536;
		
		internal var _files:flash.utils.Dictionary;
	}
}

import flash.utils.*;


class FilePart extends Object
{
	public function FilePart(arg1:flash.utils.ByteArray, arg2:String, arg3:String="Filedata", arg4:String="application/octet-stream")
	{
		super();
		this.fileContent = arg1;
		this.fileName = arg2;
		this.dataField = arg3;
		this.contentType = arg4;
		return;
	}
	
	public function dispose():void
	{
		this.fileContent = null;
		this.fileName = null;
		this.dataField = null;
		this.contentType = null;
		return;
	}
	
	public var fileContent:flash.utils.ByteArray;
	
	public var fileName:String;
	
	public var dataField:String;
	
	public var contentType:String;
}

