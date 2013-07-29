package com.ai.matchingcards.views {
	
	import com.ai.matchingcards.models.GameSettings;
	import com.creativebottle.starlingmvc.views.ViewManager;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	import flash.geom.Rectangle;
	import starling.events.EventDispatcher;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	[Event(name = "complete", type = "starling.events.Event")]
	[Event(name = "showRecipe", type = "starling.events.Event")]
	
	public class GameView extends Screen {
		
		[Inject]
		public var settings:GameSettings;
	
		[Inject]
		public var viewManager:ViewManager;
		
		[Dispatcher]
		public var dispatcher:EventDispatcher;
		
		private static const MENU:String = "menu";
		private static const CARDS:String = "cards";
		
		private var _navigator:ScreenNavigator;
		private var _transitionManager:ScreenSlidingStackTransitionManager;
		
		private var _guiSize:Rectangle;
		private var _appSize:Rectangle;
		private var _deviceSize:Rectangle;
		
		[PostConstruct]
		public function postConstruct():void {
			_guiSize = new Rectangle(0, 0, 1024, 768);
			_appSize = _guiSize.clone();
			_deviceSize = new Rectangle(0, 0, Math.max(stage.stageWidth, stage.stageHeight), Math.min(stage.stageWidth, stage.stageHeight));
			if ((_deviceSize.width / _deviceSize.height) > (_guiSize.width / _guiSize.height)) {
				// if device is wider than GUI's aspect ratio, height determines scale
				settings.scale = _deviceSize.height / _guiSize.height + 0.1;
				_appSize.width = _deviceSize.width / settings.scale;
			}
			else {
				// if device is taller than GUI's aspect ratio, width determines scale
				settings.scale = _deviceSize.width / _guiSize.width;
				_appSize.height = _deviceSize.height / settings.scale;
			}
			settings.width = stage.stageWidth;
			settings.height = stage.stageHeight;
			settings.res = stage.stageWidth + "x" + stage.stageHeight;
			trace(settings.scale);
			trace(settings.res);
			
			_navigator = new ScreenNavigator();
			addChild(_navigator);
			
			_navigator.addScreen(MENU, new ScreenNavigatorItem(MenuView, { showCards: CARDS }, { settings: settings } ));
			_navigator.addScreen(CARDS, new ScreenNavigatorItem(CardsView, { complete: MENU }, { settings: settings } ));			
			_navigator.showScreen(MENU);
			
			_transitionManager = new ScreenSlidingStackTransitionManager(_navigator);
			_transitionManager.duration = 0.4;
		}
		
		[PreDestroy]
		public function preDestroy():void {
			// clean up	
		}
	}
}