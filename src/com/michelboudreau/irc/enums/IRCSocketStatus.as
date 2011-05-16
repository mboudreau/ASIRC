package com.michelboudreau.irc.enums
{
	public class IRCSocketStatus
	{
		// The possible enums for this class
		static public const CLOSED:IRCSocketStatus = new IRCSocketStatus('closed', 0);
		static public const CONNECTING:IRCSocketStatus = new IRCSocketStatus('connecting', 1);
		static public const HANDSHAKING:IRCSocketStatus = new IRCSocketStatus('handshaking', 2);
		static public const CONNECTED:IRCSocketStatus = new IRCSocketStatus('connected', 3);
		
		// A list of all the enums for easy referencing if needed
		static public const list:Array = [CLOSED, CONNECTING, HANDSHAKING, CONNECTED];
		
		// The static initializer needed to stop anyone else to an instance of this class
		static private var INIT:Boolean = init();
		
		// Class vars
		private var _name:String;
		private var _weight:uint;
		
		// Class constructor
		public function IRCSocketStatus(name:String, weight:uint)
		{
			if(INIT)
			{
				throw new Error('Status enums already created');
			}
			this._name = name;
			this._weight = weight;
		}
		
		// Returns the true weight of the class
		public function valueOf():uint
		{
			return this._weight;
		}
		
		// Returns a string when needed
		public function toString():String
		{
			return this._name;
		}
		
		// Static initializer function
		static private function init():Boolean
		{
			return true;
		}
	}
}