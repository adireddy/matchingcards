package com.ai.matchingcards.mediators {
	
	import com.ai.matchingcards.views.GameView;	
	
	public class GameMediator {
		
		private var view:GameView;
		
		[ViewAdded]
		public function viewAdded(view:GameView):void {
			this.view = view;
			trace("[GameMediator] View Added");
		}
		
		[ViewRemoved]
		public function viewRemoved(view:GameView):void {
			this.view = null;
			trace("[GameMediator] View Removed");
		}
	}
}