package com.ai.matchingcards.views {
	
	import com.ai.matchingcards.assets.Applause;
	import com.ai.matchingcards.assets.Nice;
	import com.ai.matchingcards.assets.Touch;
	import com.ai.matchingcards.assets.Uhoh;
	import com.ai.matchingcards.assets.Wow;
	import com.ai.matchingcards.models.Categories;
	import com.ai.matchingcards.models.GameSettings;
	import com.ai.matchingcards.models.IconsLibrary;
	
	import org.casalib.util.*;
	
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Scroller;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import starling.display.MovieClip;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.text.TextField;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.animation.Transitions;
	
	import starling.extensions.PDParticleSystem;
    import starling.extensions.ParticleSystem;
	
	import com.emibap.textureAtlas.DynamicAtlas;
	
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	[Event(name = "complete", type = "starling.events.Event")]
	[Event(name = "showSettings", type = "starling.events.Event")]
	
	public class CardsView extends Screen {
		
		[Inject]
		public var categories:Categories;
		
		[Inject]
		public var icons:IconsLibrary;
		
		[Embed(source="/../assets/media/drugs.pex", mimeType="application/octet-stream")]
        private static const DrugsConfig:Class;
		
		[Embed(source = "/../assets/media/drugs_particle.png")]
        private static const DrugsParticle:Class;
		
		public var group1:Group1;
		public var group2:Group2;
		public var group3:Group3;
		public var group4:Group4;
		public var group5:Group5;
		public var group6:Group6;
		
		public var settings:GameSettings;
		
		private var _card:MovieClip;
		private var _bg:MovieClip;
		private var _loading:Image;
		private var _back:Image;
		private var _congrats:Image;
		
		private var _container:ScrollContainer;
		private var _layout:TiledRowsLayout;
		
		private var _iconClips:Array;
		private var _icons:Array;
		private var _allIcons:Array;
		private var _matched:Array;
		private var _matchCount:int;
		
		private var _cardClip:MovieClip;
		private var _cardCount:int;
		private var _firstOpenCard:MovieClip;
		private var _secondOpenCard:MovieClip;
		
		private var _iconsAtlas:TextureAtlas;		
		private var _commonAtlas:TextureAtlas;
		
		private var _mParticleSystems:Vector.<ParticleSystem>;
		private var _mParticleSystem:ParticleSystem;
		
		private var _touch:Touch;
		private var _applause:Applause;
		private var _wow:Wow;
		private var _uhoh:Uhoh;
		private var _nice:Nice;
		
		private var _groupID:int;
		
		private var _timer:int;
		private var _particleTimer:int;
		
		private var _gameTimer:Timer;
		private var _timerText:TextField;
		private var _moves:TextField;
		private var _movesCounter:int;
		
		public function CardsView() {
			super();
			_touch = new Touch();
			_applause = new Applause();
			_wow = new Wow();
			_uhoh = new Uhoh();
			_nice = new Nice();
		}
		
		override protected function initialize():void {
			_layout = new TiledRowsLayout();
			_layout.gap = 15;			
			_layout.paddingTop = 5;
			_layout.paddingRight = 5;
			_layout.paddingBottom = 5;
			_layout.paddingLeft = 5;
			_layout.useSquareTiles = true;
			_layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			_layout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			
			_container = new ScrollContainer();
			_container.layout = _layout;
			_container.scrollerProperties.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_container.scrollerProperties.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
			_container.scrollerProperties.snapScrollPositionsToPixels = true;
			
			var drugsConfig:XML = XML(new DrugsConfig());
            var drugsTexture:Texture = Texture.fromBitmap(new DrugsParticle());
			_mParticleSystems = new <ParticleSystem>[new PDParticleSystem(drugsConfig, drugsTexture)];
			_mParticleSystem = _mParticleSystems[0];
            Starling.juggler.add(_mParticleSystem);
			_timer = setTimeout(addAssets, 300);
		}
		
		private function addAssets():void {
			clearTimeout(_timer);
			try {
				_commonAtlas = DynamicAtlas.fromMovieClipContainer(new Common(), 1, 0, true, true);
				_back = new Image(_commonAtlas.getTextures("back")[0]);
				_loading = new Image(_commonAtlas.getTextures("hourglass")[0]);
				assetsReady();
			} 
			catch (e:Error) {
				trace("Error creatiing texture atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}
		}
		
		private function assetsReady():void {
			_groupID = NumberUtil.randomIntegerWithinRange(1, 6);
			trace("GROUP: " + _groupID);
			var GroupClass:Object = getDefinitionByName("Group" + _groupID);
			
			try {
				_iconsAtlas = DynamicAtlas.fromMovieClipContainer(new GroupClass(), 1, 0, true, true);
			} 
			catch (e:Error) {
				trace("Error creating texture atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
			}
			
			_allIcons = icons["ICONS" + _groupID].slice();
			
			_cardCount = 0;
			_iconClips = [];
			_icons = [];
			_matched = [];
			_matchCount = 0;
			_movesCounter = 0;
			
			addChild(_loading);
			draw();
			
			Starling.juggler.delayCall(addCard, 0.1, _cardCount);
		}
		
		private function addCard(i:int):void {
			_matched[i] = false;
			_cardClip = new MovieClip(_commonAtlas.getTextures("card"), 1);
			_cardClip.name = "" + i;
			_cardClip.addEventListener(TouchEvent.TOUCH, showIcon);
			_iconClips[i] = _cardClip;
			switch(settings.cards) {
				case 6:
					if(settings.scale > 1.2) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 480;
						_cardClip.scaleX = _cardClip.scaleY = 2.4;
					}
					else if(settings.scale > 1 && settings.scale <= 1.2) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 320;
						_cardClip.scaleX = _cardClip.scaleY = 1.8;
					}
					else if(settings.scale > 0.93 && settings.scale <= 1) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 286;
						_cardClip.scaleX = _cardClip.scaleY = 1.7;
					}
					else if(settings.scale >= 0.9 && settings.scale <= 0.93) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 256;
						_cardClip.scaleX = _cardClip.scaleY = 1.6;
					}
					else if (settings.scale >= 0.8 && settings.scale < 0.9) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 220;
						_cardClip.scaleX = _cardClip.scaleY = 1.5;
					}
					else if(settings.scale >= 0.7 && settings.scale < 0.8) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 188;
						_cardClip.scaleX = _cardClip.scaleY = 1.4;
					}
					else {
						_cardClip.scaleX = _cardClip.scaleY = 1.6 - settings.scale - 0.2;
					}
					_layout.paddingBottom = 50;
					break;
				case 12:
					if(settings.scale > 1.2) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 300;
						_cardClip.scaleX = _cardClip.scaleY = 1.7;
					}
					else if(settings.scale > 1 && settings.scale <= 1.2) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 210;
						_cardClip.scaleX = _cardClip.scaleY = 1.6;
					}
					else if(settings.scale > 0.93 && settings.scale <= 1) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 170;
						_cardClip.scaleX = _cardClip.scaleY = 1.3;
					}
					else if(settings.scale >= 0.9 && settings.scale <= 0.93) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 180;
						_cardClip.scaleX = _cardClip.scaleY = 1.15;
					}
					else if (settings.scale >= 0.8 && settings.scale < 0.9) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 160;
						_cardClip.scaleX = _cardClip.scaleY = 1.1;
					}
					else if (settings.scale >= 0.7 && settings.scale < 0.8) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 110;
						_cardClip.scaleX = _cardClip.scaleY = 0.8;
					}					
					else {
						_cardClip.scaleX = _cardClip.scaleY = 1.3 - settings.scale - 0.13;
					}					
					_layout.paddingBottom = 50;
					break;
				case 24:
					if(settings.scale > 1.2) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 220;
						_cardClip.scaleX = _cardClip.scaleY = 1.4;
					}
					else if(settings.scale > 1 && settings.scale <= 1.2) {
						_cardClip.scaleX = _cardClip.scaleY = 1.11;
					}
					else if (settings.scale > 0.93 && settings.scale < 1) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 85;
						_cardClip.scaleX = _cardClip.scaleY = 0.95;
					}
					else if (settings.scale >= 0.9 && settings.scale <= 0.93) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 130;
						_cardClip.scaleX = _cardClip.scaleY = 0.9;
					}
					else if (settings.scale >= 0.8 && settings.scale < 0.9) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 115;
						_cardClip.scaleX = _cardClip.scaleY = 0.9;
					}
					else if (settings.scale >= 0.7 && settings.scale < 0.8) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 90;
						_cardClip.scaleX = _cardClip.scaleY = 0.74;
						_layout.paddingLeft = _layout.paddingRight = 22;
					}
					else {
						_cardClip.scaleX = _cardClip.scaleY = 1.1 - settings.scale - 0.15;
					}
					_layout.paddingBottom = 40;
					break;
				case 48:
					_layout.gap = 12;
					_layout.paddingBottom = 60;
					_cardClip.scaleX = _cardClip.scaleY = 0.8;
					if(settings.scale > 1.2) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 140;
						_cardClip.scaleX = _cardClip.scaleY = 1;
					}
					else if (settings.scale >= 1 && settings.scale <= 1.2) {
						_layout.gap = 15;
					}
					else if (settings.scale >= 0.8 && settings.scale < 1) {
						_layout.typicalItemWidth = _layout.typicalItemHeight = 80;
						_cardClip.scaleX = _cardClip.scaleY = 0.65;
					}
					break;
			}
			_cardClip.visible = false;
			_container.addChild(_cardClip);
			
			if (i == settings.cards - 1) {
				addHiddenCards();
			}
			else {
				i++;
				addCard(i);
			}
		}
		
		private function addHiddenCards():void {
			var cardClip:MovieClip;
			var rand:int;
			var rand2:int;
			for (var i:int = 0; i < settings.cards; i++) {
				if(_icons[i] == null) {
					cardClip = MovieClip(_container.getChildByName("" + i));
					cardClip.loop = false;
					cardClip.stop();
					Starling.juggler.add(cardClip);
					cardClip.setFrameDuration(0, 0.01);
					rand = NumberUtil.randomIntegerWithinRange(0, _allIcons.length - 1);
					cardClip.addFrame(_iconsAtlas.getTextures(_allIcons[rand])[0], null, 999);
					
					_icons[i] = _allIcons[rand];
					
					rand2 = NumberUtil.randomIntegerWithinRange(i, settings.cards - 1);
					while (_icons[rand2] != null) {
						rand2 = NumberUtil.randomIntegerWithinRange(i, settings.cards - 1);
					}
					cardClip = MovieClip(_container.getChildByName("" + rand2));
					cardClip.loop = false;
					cardClip.stop();
					Starling.juggler.add(cardClip);
					cardClip.setFrameDuration(0, 0.01);
					cardClip.addFrame(_iconsAtlas.getTextures(_allIcons[rand])[0], null, 999);
					_icons[rand2] = _allIcons[rand];
					
					_allIcons.splice(rand, 1);
				}
			}
			
			_timerText = new TextField(120, 32, "Time: 00:00", "Verdana", 16, 0xFFFFFF, true);
			_timerText.hAlign = "left";
			addChild(_timerText);
			
			_moves = new TextField(120, 32, "Moves: 0", "Verdana", 16, 0xFFFFFF, true);
			_moves.hAlign = "right";
			addChild(_moves);
			
			if (settings.scale >= 1) {
				_moves.scaleX = _moves.scaleY = settings.scale + 0.2;
				_timerText.scaleX = _timerText.scaleY = settings.scale + 0.2;
			}			
			_back.scaleX = _back.scaleY = settings.scale;
			addChild(_mParticleSystem);
			addChild(_container);
			addChild(_back);
			draw();
			
			removeChild(_loading);
			showAll();
		}
		
		override protected function draw():void {
			if(_back != null) {
				_back.x = (actualWidth - _back.width) / 2;
				_back.y = actualHeight - _back.height + 2;
			}
			
			if(_loading != null) {
				_loading.x = (actualWidth - _loading.width) / 2;
				_loading.y = (actualHeight - _loading.height) / 2;
			}
			
			if (_timerText != null) {
				_timerText.y = actualHeight - _timerText.height - 10;
				_moves.x = actualWidth - _moves.width;
				_moves.y = actualHeight - _moves.height - 10;
			}
			
			_container.width = actualWidth;
			_container.height = actualHeight - _container.y;
		}
		
		private function showIcon(event:TouchEvent):void {
			var cardClip:MovieClip = MovieClip(event.target);
			cardClip.removeEventListener(TouchEvent.TOUCH, showIcon);
			_touch.play();
			cardClip.play();			
			/*Starling.juggler.tween(cardClip, 0.5, {
			   transition: Transitions.EASE_IN,
			   delay: 0,
			   repeatCount: 1,
			   onComplete: function():void { checkCards(cardClip); },
			   alpha: 0
			});*/
			
			if (_firstOpenCard == null) {
				_firstOpenCard = cardClip;
			}
			else {
				_secondOpenCard = cardClip;
				disableIcons();
			}
			checkCards(cardClip);
		}
		
		private function checkCards(cardClip:MovieClip):void {		
			//cardClip.alpha = 1; 			
			if (_secondOpenCard != null) {
				_movesCounter++;
				_moves.text = "Moves: " + _movesCounter;
				if(_icons[_firstOpenCard.name] == _icons[_secondOpenCard.name]) {
					trace("CARDS MATCHED");
					_matched[_firstOpenCard.name] = _matched[_secondOpenCard.name] = true;
					_firstOpenCard = null;
					_secondOpenCard = null;
					enableIcons();
					_matchCount += 2;
					if (_matchCount == settings.cards) {
						showCompleteAnimation();
					}					
					_nice.play();
				}
				else {
					_uhoh.play();
					trace("CARDS NOT MATCHED");
					Starling.juggler.delayCall(stopClips, 1);
				}
				clearTimeout(_timer);
			}
			else {
				_timer = setTimeout(resetClip, 2000);
			}
		}
		
		private function stopClips():void {
			if (_firstOpenCard != null) {
				_firstOpenCard.stop();
			}
			if (_secondOpenCard != null) {
				_secondOpenCard.stop();
			}
			_firstOpenCard = null;
			_secondOpenCard = null;
			enableIcons();
		}
		
		private function resetClip():void {
			clearTimeout(_timer);
			if (_secondOpenCard == null && _firstOpenCard != null) {
				_firstOpenCard.stop();
				_firstOpenCard = null;
			}
			enableIcons();
		}
		
		private function showCompleteAnimation():void {
			_gameTimer.stop();
			_timerText.color = 0x7FFF00;
			_moves.color = 0x7FFF00;
			_congrats = new Image(_commonAtlas.getTextures("welldone")[0]);
			addChild(_congrats);
			
			_congrats.x = (actualWidth - _congrats.width) / 2;
			_congrats.y = -200;
			Starling.juggler.tween(_congrats, 1, {
			   transition: Transitions.EASE_IN_OUT_BOUNCE,
			   y: (actualHeight - _congrats.height) / 2
			});
			
			_wow.play();
			Starling.juggler.delayCall(function():void { _applause.play(); }, 0.5);
			
			draw();
			_mParticleSystem.start();
			_mParticleSystem.emitterX = actualWidth / 2;
            _mParticleSystem.emitterY = actualHeight / 2;
			_mParticleSystem.start();
			_particleTimer = setTimeout(removeParticle, 100);
		}
		
		private function removeParticle():void {
            _mParticleSystem.stop();            
			_mParticleSystem.emitterX = NumberUtil.randomIntegerWithinRange(0, actualWidth);
            _mParticleSystem.emitterY = NumberUtil.randomIntegerWithinRange(0, actualHeight);
			_mParticleSystem.start();
			clearTimeout(_particleTimer);
			_particleTimer = setTimeout(removeParticle, 100);
		}
		
		private function goBack(event:TouchEvent):void {
			if (_gameTimer != null) {
				_gameTimer.stop();
			}
			_mParticleSystem.stop();
			_mParticleSystem.dispose();
			_container.dispose();
			removeChild(_congrats);
			removeChild(_back);
			removeChild(_mParticleSystem);
			_commonAtlas.dispose();
			_iconsAtlas.dispose();
			dispatchEventWith(Event.COMPLETE);
		}
		
		private function showAll():void {
			var cardClip:MovieClip;
			for (var i:int = 0; i < settings.cards; i++) {
				cardClip = MovieClip(_container.getChildByName("" + i));
				cardClip.visible = true;
				cardClip.removeEventListener(TouchEvent.TOUCH, showIcon);
				cardClip.play();
			}
			_timer = setTimeout(hideAll, 2000);
		}
		
		private function hideAll():void {
			clearTimeout(_timer);
			var cardClip:MovieClip;
			for (var i:int = 0; i < settings.cards; i++) {
				cardClip = MovieClip(_container.getChildByName("" + i));
				cardClip.addEventListener(TouchEvent.TOUCH, showIcon);
				cardClip.stop();
			}
			_back.addEventListener(TouchEvent.TOUCH, goBack);
			startTimer();
		}
		
		private function startTimer():void {
			_gameTimer = new Timer(1000, 9999999999);
			_gameTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			_gameTimer.start();
		}
		
		private function timerHandler(event:TimerEvent):void {
			_timerText.text = "Time: " + Utils.convertToHHMMSS(_gameTimer.currentCount);
		}
		
		private function disableIcons():void {
			var cardClip:MovieClip;
			for (var i:int = 0; i < settings.cards; i++) {
				cardClip = MovieClip(_container.getChildByName("" + i));
				cardClip.removeEventListener(TouchEvent.TOUCH, showIcon);
			}
		}
		
		private function enableIcons():void {
			var cardClip:MovieClip;
			for (var i:int = 0; i < settings.cards; i++) {
				if(!_matched[i]) {
					cardClip = MovieClip(_container.getChildByName("" + i));
					cardClip.addEventListener(TouchEvent.TOUCH, showIcon);
				}
			}
		}
	}
}