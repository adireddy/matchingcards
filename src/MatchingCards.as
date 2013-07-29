package {
	
	import com.ai.matchingcards.views.GameConfig;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.display.StageOrientation;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	import starling.core.Starling;
	
	[SWF(width = "728", height = "1024", frameRate = "60", backgroundColor = "#003366")]
	public class MatchingCards extends Sprite {
		
		private var _starling:Starling;
		private var _initialized:Boolean;
		private var _bg:bg;
		private var _logo:logoBig;
		private var _timer:int;
		
		private var _launchImage:Loader;
		private var _savedAutoOrients:Boolean;		
		
		public function MatchingCards() {
			_initialized = false;
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				stage.quality = StageQuality.HIGH;
			}
			mouseEnabled = mouseChildren = false;
			loaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			showLaunchImage();
		}
		
		private function completeHandler(event:Event):void {
			Starling.handleLostContext = true;
			Starling.multitouchEnabled = true;
			_starling = new Starling(GameConfig, stage);
			_starling.enableErrorChecking = false;
			//_starling.showStats = true;
			//_starling.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
			_starling.start();
			if (_launchImage) {
				_starling.addEventListener("rootCreated", rootCreatedHandler);
			}			
			stage.addEventListener(Event.RESIZE, resizeHandler, false, int.MAX_VALUE, true);
			stage.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
		}
		
		private function showLaunchImage():void {
			var filePath:String;
			var isPortraitOnly:Boolean = false;
			if (Capabilities.manufacturer.indexOf("iOS") >= 0) {
				if (Capabilities.screenResolutionX == 1536 && Capabilities.screenResolutionY == 2048) {
					var isCurrentlyPortrait:Boolean = stage.orientation == StageOrientation.DEFAULT || stage.orientation == StageOrientation.UPSIDE_DOWN;
					filePath = isCurrentlyPortrait ? "Default-Portrait@2x.png" : "Default-Landscape@2x.png";
				} 
				else if (Capabilities.screenResolutionX == 768 && Capabilities.screenResolutionY == 1024) {
					isCurrentlyPortrait = stage.orientation == StageOrientation.DEFAULT || stage.orientation == StageOrientation.UPSIDE_DOWN;
					filePath = isCurrentlyPortrait ? "Default-Portrait.png" : "Default-Landscape.png";
				} 
				else if (Capabilities.screenResolutionX == 640) {
					isPortraitOnly = true;
					if (Capabilities.screenResolutionY == 1136) {
						filePath = "Default-568h@2x.png";
					} 
					else {
						filePath = "Default@2x.png";
					}
				} 
				else if (Capabilities.screenResolutionX == 320) {
					isPortraitOnly = true;
					filePath = "Default.png";
				}
			}
			
			if (filePath) {
				var file:File = File.applicationDirectory.resolvePath(filePath);
				if (file.exists) {
					var bytes:ByteArray = new ByteArray();
					var stream:FileStream = new FileStream();
					stream.open(file, FileMode.READ);
					stream.readBytes(bytes, 0, stream.bytesAvailable);
					stream.close();
					_launchImage = new Loader();
					_launchImage.loadBytes(bytes);
					addChild(_launchImage);
					_savedAutoOrients = stage.autoOrients;
					stage.autoOrients = false;
					if (isPortraitOnly) {
						stage.setOrientation(StageOrientation.DEFAULT);
					}
				}
			}
		}
		
		private function rootCreatedHandler(event:Object):void {
			if (_launchImage) {
				removeChild(_launchImage);
				_launchImage.unloadAndStop(true);
				_launchImage = null;
				stage.autoOrients = _savedAutoOrients;
			}
		}
		
		private function resizeHandler(event:Event):void {			
			_starling.stage.stageWidth = stage.stageWidth;
			_starling.stage.stageHeight = stage.stageHeight;
			
			const viewPort:Rectangle = _starling.viewPort;
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			try {
				_starling.viewPort = viewPort;
			} 
			catch (error:Error) {
			}
		}
		
		private function clearBG():void {
			removeChild(_bg);
			removeChild(_logo);
			clearTimeout(_timer);
		}
		
		private function deactivateHandler(event:Event):void {
			_starling.stop();
			stage.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
		}
		
		private function activateHandler(event:Event):void {
			stage.removeEventListener(Event.ACTIVATE, activateHandler);
			_starling.start();
		}
	}
}