package com.ai.matchingcards.views {	
	
	import com.ai.matchingcards.GameProvider;
	import com.creativebottle.starlingmvc.StarlingMVC;
	import com.creativebottle.starlingmvc.config.StarlingMVCConfig;
	import com.creativebottle.starlingmvc.views.ViewManager;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class GameConfig extends Sprite {

		private var config:StarlingMVCConfig;
		private var beans:Array;
		private var starlingMVC:StarlingMVC;
		
		public function GameConfig() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			config = new StarlingMVCConfig();
			config.eventPackages = ["com.bwinparty.casino.slots.events"];
			config.viewPackages = ["com.bwinparty.casino.slots.views"];			
			
			beans = [new GameProvider(), new ViewManager(this)];
			starlingMVC = new StarlingMVC(this, config, beans);
			
			trace("[Engine] MVC Started...");
		}
	}
}
