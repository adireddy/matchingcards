package com.ai.matchingcards.views {
	
	import com.ai.matchingcards.models.GameSettings;
	
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.layout.VerticalLayout;
	import starling.display.Image;
	import starling.textures.TextureAtlas;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	import org.casalib.util.NavigateUtil;
	
	import com.emibap.textureAtlas.DynamicAtlas;
	
	[Event(name = "complete", type = "starling.events.Event")]
	[Event(name = "showSettings", type = "starling.events.Event")]
	[Event(name = "showRecipesList", type = "starling.events.Event")]
	[Event(name = "showFavourites", type = "starling.events.Event")]
	
	public class MenuView extends Screen {
		
		[Inject]
		public var settings:GameSettings;
		
		public static const SHOW_SETTINGS:String = "showSettings";		
		public static const SHOW_CARDS:String = "showCards";
		public static const SHOW_FAVOURITES:String = "showFavourites";
		
		private var _assets:TextureAtlas;
		private var _logo:Image;
		private var _courtesy:Image;
		private var _cards6:Image;
		private var _cards12:Image;
		private var _cards24:Image;
		private var _cards48:Image;		
		
		private var _container:ScrollContainer;
		private var _layout:VerticalLayout;
		
		public function MenuView() {
		
		}
		
		override protected function initialize():void {			
			_layout = new VerticalLayout();
			_layout.gap = 25;
			_layout.paddingTop = 50;
			_layout.paddingRight = 5;
			_layout.paddingBottom = 5;
			_layout.paddingLeft = 5;
			_layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			_layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			
			_container = new ScrollContainer();
			_container.layout = _layout;
			_container.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_container.scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_container.scrollerProperties.snapScrollPositionsToPixels = true;			
			
			Starling.juggler.delayCall(addAssets, 0.5);
		}
		
		private function addAssets():void {
			try {
				_assets = DynamicAtlas.fromMovieClipContainer(new LogoMenu(), 1, 0, true, true);
				assetsReady();				
			} 
			catch (e:Error) {
				trace("Eerror creating texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}
		}
		
		private function assetsReady():void {
			_logo = new Image(_assets.getTextures("logo")[0]);
			_logo.touchable = false;
			_logo.scaleX = _logo.scaleY = settings.scale;
			addChild(_logo);
			addChild(_container);
			
			_courtesy = new Image(_assets.getTextures("courtesy")[0]);
			_courtesy.scaleX = _courtesy.scaleY = settings.scale;
			_courtesy.addEventListener(TouchEvent.TOUCH, launchURL);
			addChild(_courtesy);
			
			_cards6 = new Image(_assets.getTextures("cards6")[0]);
			_cards12 = new Image(_assets.getTextures("cards12")[0]);
			_cards24 = new Image(_assets.getTextures("cards24")[0]);
			
			_cards6.scaleX = _cards6.scaleY = settings.scale;
			_cards12.scaleX = _cards12.scaleY = settings.scale;
			_cards24.scaleX = _cards24.scaleY = settings.scale;
			
			_container.addChild(_cards6);
			_container.addChild(_cards12);
			_container.addChild(_cards24);
			
			_cards6.addEventListener(TouchEvent.TOUCH, showCards6);
			_cards12.addEventListener(TouchEvent.TOUCH, showCards12);
			_cards24.addEventListener(TouchEvent.TOUCH, showCards24);			
			
			if (settings.scale >= 1 || settings.res == "600x976") {
				_cards48 = new Image(_assets.getTextures("cards48")[0]);
				_cards48.scaleX = _cards48.scaleY = settings.scale;
				_cards48.addEventListener(TouchEvent.TOUCH, showCards48);
				_container.addChild(_cards48);
			}			
			draw();
		}
		
		override protected function draw():void {
			if (_logo != null) {
				_logo.y = 10;
				_logo.x = 35 + (actualWidth - 320) / 2;
				
				_container.width = actualWidth;
				_container.height = actualHeight - _container.y;
				
				_courtesy.x = (actualWidth - _courtesy.width) / 2;
				_courtesy.y = actualHeight - 20;
			}
		}
		
		private function settingsHandler(event:Event):void {
			dispatchEventWith(SHOW_SETTINGS);
		}
		
		private function showCards6(event:TouchEvent):void {
			settings.cards = 6;
			showCards();
		}
		
		private function showCards12(event:TouchEvent):void {
			settings.cards = 12;
			showCards();
		}
		
		private function showCards24(event:TouchEvent):void {
			settings.cards = 24;
			showCards();
		}
		
		private function showCards48(event:TouchEvent):void {
			settings.cards = 48;
			showCards();
		}
		
		private function showCards():void {
			_container.dispose();
			dispatchEventWith(SHOW_CARDS);
		}
		
		private function launchURL(event:TouchEvent):void {
			NavigateUtil.openUrl("http://www.fasticon.com", "_blank");
		}
	}
}