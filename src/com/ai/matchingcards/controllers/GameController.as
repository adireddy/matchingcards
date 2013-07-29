package com.ai.matchingcards.controllers {
	
	import com.creativebottle.starlingmvc.views.ViewManager;
	import feathers.controls.Label;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	
	import com.ai.matchingcards.views.GameView;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class GameController extends Sprite {
		
		[Inject]
		public var viewManager:ViewManager;
		
		[PostConstruct]
		public function postConstruct():void {
			viewManager.setView(GameView);
		}
	}
}