package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;

	public class Utils {
		/**
		 * Function to trim a string (removing white spaces).
		 * @param str - String value that needs to be trimmed.
		 * @return Trimmed text
		*/
		public static function trim(str:String):String {
			var j:Number      = 0;
			var strlen:Number = str.length;
			var k:Number;

			while (str.charAt(j) == " ") {
				j++;
			}
			if (j > 0) {
				str = str.substring(j, strlen);
				if (j == strlen) {
					return str;
				}
			}

			k = str.length - 1;
			while (str.charAt(k) == " ") {
				k--;
			}
			str = str.substring(0, k + 1);
			return str;
		}

		public static function caps(str:String):String {
			return str.charAt(0).toUpperCase() + str.slice(1);
		}

		/**
		 * Function to replace part of a string with any other string.
		 * @param str - Base string.
		 * @param src - Srting that has to be replaced in the base string
		 * @param target - String that will be replace with
		 * @return new string after replace
		*/
		public static function replace(str:String, src:String, target:String):String {
			var pos:Number = 0;
			while (true) {
				pos = str.indexOf(src, pos);
				if (pos == -1) {
					return str;
				}
				str = str.substring(0, pos) + target + str.substring(pos + src.length, str.length);
				pos += target.length;
			}
			return str;
		}

		/**
		 * Function to search an array for specific item
		 * @param arr - Array to search
		 * @param val - value to search
		 * @return true/false
		*/
		public static function hasItem(arr:Array, val:*):Boolean {
			for (var i:uint = 0; i < arr.length; i++) {
				if (arr[i] == val) {
					return true;
				}
			}
			return false;
		}

		/**
		 * Function to format any amount
		 * @param amount - Number to be formatted
		 * @return formatted amount
		*/
		public static function formatBalance(amount:Number, decimals:Boolean = true):String {
			if (amount == 0) {
				return "0";
			}

			amount = amount * 100;
			amount = Math.round(amount);

			var stramount:String = String(Math.floor(amount));
			if (stramount.length == 1) {
				return ("0.0" + amount);
			}
			else if (stramount.length == 2) {
				return ("0." + amount);
			}

			var deciValues:String = stramount.slice(-2);
			stramount = stramount.substring(0, stramount.length - 2);

			var wholeValues:Array = new Array();
			do {
				wholeValues.push(stramount.slice(-3));
				stramount = stramount.substring(0, stramount.length - 3);
			} while (stramount.length > 3);

			if (stramount.length) {
				wholeValues.push(stramount);
			}
			wholeValues.reverse();
			if (Number(deciValues) > 0 && decimals) {
				return (wholeValues.join() + "." + deciValues);
			}
			else {
				return (wholeValues.join());
			}
		}

		/**
		 * Function to check the text and chop it off if it doesn't fit the button
		 * @param txt - Text to be checked
		 * @param no - character limit to be checked
		 * @return text (modified or as it is)
		*/
		public static function checkText(txt:String, no:Number, obj:MovieClip):String {
			obj.originalTxt = txt;
			if (txt.length > no) {
				obj.tip = true;
				return txt.substring(0, no - 2) + "..";
			}
			else {
				obj.tip = false;
				return txt;
			}
		}

		/**
		 * Function to format the chip text on the table
		 * @param val - Number to be formatted
		 * @return formatted amount
		*/
		public static function formatChipText(val:Number):String {
			var formattedValue:String;
			if (val < 10) {
				formattedValue = floatCorrection(val) + "";
			}
			else if (val < 1000 && String(val / 100).length <= 4) {
				formattedValue = floatCorrection(Math.floor(val)) + "";
			}
			else if (val < 1000 && String(val / 100).length > 4) {
				formattedValue = floatCorrection(Math.floor(val)) + "+";
			}
			else if (val / 1000 < 1) {
				formattedValue = floatCorrection(Math.floor(val)) + "";
			}
			else if (val / 1000 > 1 && val % 1000 > 0) {
				formattedValue = floatCorrection(Math.floor(val) / 1000) + "k+";
			}
			else if ((val / 1000 >= 1) && val % 1000 == 0) {
				formattedValue = floatCorrection(Math.floor(val) / 1000) + "k";
			}
			return formattedValue;
		}

		/**
		 * Function to correct flash floating point issues ex: 0.300000000000000004
		 * @param val - Number to be corrected
		 * @return formatted amount
		*/
		public static function floatCorrection(val:Number):Number {
			var correction:Number = Math.pow(10, 5);
			return Math.round(correction * val) / correction;
		}

		/**
		 * Function to format the chip text in the bank
		 * @param val - Number to be formatted
		 * @return formatted amount
		*/
		public static function formatChipStackText(val:Number):String {
			var formattedValue:String = "";
			if (val / 1000 < 1) {
				formattedValue = "" + val;
			}
			else if (val / 1000 >= 1) {
				formattedValue = (val / 1000) + "k";
			}
			return formattedValue;
		}

		/**
		 * Function to delete the children of any movieclip
		 * @param mc - Movieclip to be cleared
		*/
		public static function removeChildren(mc:MovieClip):void {
			var children:Array = new Array();
			for (var i:int = 0; i < mc.numChildren; i++) {
				children.push(mc.getChildAt(i));
			}
			for (i = 0; i < children.length; i++) {
				children[i].parent.removeChild(children[i]);
			}
		}

		/**
		 * Function to launch javascript popup
		 * @param address - popup url
		 * @param wname - popup window name
		 * @param scrollbar - window scrollbar
		 * @param width - popup width
		 * @param height - popup height
		 * @param toolbar - popup toolbar
		 * @param resizeable - resizable window
		*/
		public static function openPopup(address:String, wname:String = "popup", scrollbar:String = "no", width:int = 800, height:int = 600, toolbar:String = "no", resizeable:String = "yes", location:String = "no"):void {
			wname = (wname == "") ? "window" : wname;
			if (ExternalInterface.available) {
				var features:String = "height=" + height + ",width=" + width + ",toolbar=" + toolbar + ",scrollbars=" + scrollbar + ",resizable=" + resizeable + ",location=" + location;
				ExternalInterface.call("function setWMWindow() { var " + wname + " = window.open('" + address + "', '" + wname + "', '" + features + "'); w.focus();}");
			}
			else {
				var jscommand:String = "window.open('" + address + "','" + wname + "','height=" + height + ",width=" + width + ",toolbar=" + toolbar + ",scrollbars=" + scrollbar + ",location=" + location + "');";
				var url:URLRequest   = new URLRequest("javascript:" + jscommand + " void(0);");
				navigateToURL(url, "_self");
			}
		}

		/**
		 * Function to return the chip color based on the denomination
		 * @param val - Denomination of the chip
		 * @return colour of the chip
		 * Please review the chipColors.fla
		 */
		public static function findChipMatrixColor(val:Number):Array {
			switch (val) {
				case -1:
					return [15, 40, -100, 0];
					break;
				case 0.5:
					return [30, 40, 40, -170];
					break;
				case 1:
					return [22, 50, 54, -140];
					break;
				case 2:
					return [40, 50, 40, -157];
					break;
				case 5:
					return [20, 50, 20, -14];
					break;
				case 10:
					return [20, 60, 0, -98];
					break;
				case 25:
					return [0, 40, 20, 50];
					break;
				case 50:
					return [0, 40, 30, 100];
					break;
				case 100:
					return [6, 40, 0, -180];
					break;
				case 500:
					return [20, 40, 10, -27];
					break;
				case 1000:
					return [0, 40, 40, 152];
					break;
				case 5000:
					return [10, 54, 0, 0];
					break;
				case 10000:
					return [18, 44, 33, -152];
					break;
				case 50000:
					return [16, 29, 29, 167];
					break;
				default:
					return findChipMatrixColor(getChipColor(val));
					break;
			}
		}

		public static function setTintClip(movie:MovieClip, col:uint,value:Number):void {
			var color:uint = col;
			var mul:Number = value/100;
			var ctMul:Number = (1-mul);
			var ctRedOff:Number = Math.round(mul*(( color >> 16 ) & 0xFF));
			var ctGreenOff:Number = Math.round(mul*((color >> 8) & 0xFF ));
			var ctBlueOff:Number = Math.round(mul*(color & 0xFF ));
			var ct:ColorTransform = new ColorTransform(ctMul,ctMul,ctMul,1,ctRedOff,ctGreenOff,ctBlueOff,0);
			movie.transform.colorTransform = ct;
		}
		
		public static function getChipColor(val:Number):Number {
			var color:Number = 0;
			if (val >= 0 && val < 0.9) {
				color = 0.5;
			}
			if (val >= 0.9 && val < 2) {
				color = 1;
			}
			if (val >= 2 && val < 5) {
				color = 2;
			}
			if (val >= 5 && val < 10) {
				color = 5;
			}
			if (val >= 10 && val < 25) {
				color = 10;
			}
			if (val >= 25 && val < 50) {
				color = 25;
			}
			if (val >= 50 && val < 100) {
				color = 50;
			}
			if (val >= 100 && val < 500) {
				color = 100;
			}
			if (val >= 500 && val < 1000) {
				color = 500;
			}
			if (val >= 1000 && val < 5000) {
				color = 1000;
			}
			if (val >= 5000 && val < 10000) {
				color = 5000;
			}
			if (val >= 10000 && val < 50000) {
				color = 10000;
			}
			if (val >= 50000) {
				color = 50000;
			}
			return color;
		}

		/**
		 * Function to return the chip color based on the denomination
		 * @param val - Denomination of the chip
		 * @return colour of the chip
		*/
		public static function findChipColor(val:Number):uint {
			switch (val) {
				case -1:
					return 0x929292; //GREYED OUT STATE
					break;
				case 0.1:
					return 0xFAAD65; //PEACH
					break;
				case 0.5:
					return 0xFAAD65; //PEACH
					break;
				case 1:
					return 0x666666; //WHITE GREY
					break;
				case 2:
					return 0xFF82D6; //PINK
					break;
				case 5:
					return 0xCE1D00; //RED
					break;
				case 10:
					return 0x00BEF3; //MID BLUE
					break;
				case 25:
					return 0x00A500; //GREEN
					break;
				case 50:
					return 0xAA7942; //BROWN
					break;
				case 100:
					return 0x000000; //BLACK
					break;
				case 500:
					return 0x8548B0; //PURPLE
					break;
				case 1000:
					return 0xDE9807; //YELLOW
					break;
				case 5000:
					return 0xDE7571; //BROWN RED
					break;
				case 10000:
					return 0x006699; //BLUE
					break;
				case 50000:
					return 0x929292; //GREY
					break;
				default:
					return 0x929292; //GREY
					break;
			}
		}

		/**
		 * Function to find the roulette net betspot colour based on the number passed
		 * @param val - Number to be checked
		 * @return colour of the number as String
		*/
		public static function findRouletteBetspotColor(val:Number):String {
			if (val == -1) {
				return "C";
			}

			var red:String   = "#1#3#5#7#9#12#14#16#18#19#21#23#25#27#30#32#34#36#";
			var black:String = "#2#4#6#8#10#11#13#15#17#20#22#24#26#28#29#31#33#35#";
			if (red.indexOf("#" + val + "#") != -1) {
				return "RED";
			}
			else if (black.indexOf("#" + val + "#") != -1) {
				return "BLACK";
			}
			else {
				return "GREEN";
			}
		}

		/**
		 * Function to find the card value based on the card number received from socket for baccarat
		 * @param val - Number to be checked
		 * @return value of the card
		*/
		public static function findCardBaccaratValue(val:Number):Number {
			var cardValue:Number = 0;
			if (val >= 0 && val <= 7) {
				cardValue = val + 2;
			}
			else if (val >= 13 && val <= 20) {
				cardValue = val - 11;
			}
			else if (val >= 26 && val <= 33) {
				cardValue = val - 24;
			}
			else if (val >= 39 && val <= 46) {
				cardValue = val - 37;
			}
			else if (val == 12 || val == 25 || val == 38 || val == 51) {
				cardValue = 1;
			}
			else if (val > 0) {
				cardValue = 0;
			}
			return cardValue;
		}

		/**
		 * Function to find the card value based on the card number received from socket for blackjack
		 * @param val - Number to be checked
		 * @return value of the card
		*/
		public static function findCardBlackjackValue(val:Number):Number {
			var cardValue:Number = 0;
			if (val >= 0 && val <= 7) {
				cardValue = val + 2;
			}
			else if (val >= 13 && val <= 20) {
				cardValue = val - 11;
			}
			else if (val >= 26 && val <= 33) {
				cardValue = val - 24;
			}
			else if (val >= 39 && val <= 46) {
				cardValue = val - 37;
			}
			else if (val == 12 || val == 25 || val == 38 || val == 51) {
				cardValue = 111;
			}
			else if (val > 0) {
				cardValue = 10;
			}
			return cardValue;
		}

		/**
		 * Function to generate random number between a range
		 * @param low - low number
		 * @param high - high number
		 * @return random number beteen the range
		*/
		public static function randomNumber(low:Number = 0, high:Number = 1):Number {
			return Math.floor(Math.random() * (1 + high - low)) + low;
		}

		public static function isEmail(val:String):Boolean {
			if (val.length < 5) {
				return false;
			}

			var iChars:String  = "*|,\":<>[]{}`';()&$#%";
			var eLength:Number = val.length;

			for (var i:int = 0; i < eLength; i++) {
				if (iChars.indexOf(val.charAt(i)) != -1) {
					return false;
				}
			}

			var atIndex:Number = val.lastIndexOf("@");
			if (atIndex < 1 || (atIndex == eLength - 1)) {
				return false;
			}

			var pIndex:Number = val.lastIndexOf(".");
			if (pIndex < 4 || (pIndex == eLength - 1)) {
				return false;
			}

			if (atIndex > pIndex) {
				return false;
			}
			return true;
		}

		public static function logOut(val:String):void {
			navigateToURL(new URLRequest("/player/logout.jsp?game=" + val), "_self");
		}

		public static function playForReal(evt:Event):void {
			openPopup("http://livecasino.smartlivegaming.com", "Smart Live Casino", "yes");
			//navigateToURL(new URLRequest("https://affiliates.smartlivecasino.com"), "_self");
		}
		
		public static function convertToHHMMSS(seconds:Number):String {
			var s:Number = seconds % 60;
			var m:Number = Math.floor((seconds % 3600 ) / 60);
			var h:Number = Math.floor(seconds / (60 * 60));
			 
			var hourStr:String = (h == 0) ? "" : doubleDigitFormat(h) + ":";
			var minuteStr:String = doubleDigitFormat(m) + ":";
			var secondsStr:String = doubleDigitFormat(s);
			 
			return hourStr + minuteStr + secondsStr;
		}
 
		public static function doubleDigitFormat(num:uint):String {
			if (num < 10) {
				return ("0" + num);
			}
			return String(num);
		}
	}
}