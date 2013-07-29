package com.ai.matchingcards {
	
	import com.ai.matchingcards.controllers.*;
	import com.ai.matchingcards.mediators.*;
	import com.ai.matchingcards.models.*;
	import com.creativebottle.starlingmvc.beans.BeanProvider;
	
	public class GameProvider extends BeanProvider {
		
		public function GameProvider() {
			beans = [new GameMediator(),
					new GameSettings(),
					new Categories(),
					new IconsLibrary(),
					new GameController()];
		}
	}
}