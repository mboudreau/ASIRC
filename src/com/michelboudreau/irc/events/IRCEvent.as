package com.michelboudreau.irc.events
{
	import flash.events.Event;
	
	/**
	 * the IrcEvent is the base class for the various IRC-related events in this package.
	 */
	public class IRCEvent extends Event
	{
		// TODO: trim down this list
		static public const MESSAGE:String = 'message';
		static public const REQUEST_USERNAME:String = 'requestUsername';
		
		public var data:Object;
		
		public function IRCEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}
		
	}
}