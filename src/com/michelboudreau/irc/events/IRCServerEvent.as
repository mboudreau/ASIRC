package com.michelboudreau.irc.events
{
	import flash.events.Event;

	/**
	 * The ServerEvent is an IrcEvent that pertains to global server related activity.
	 * You should inspect the type property to extract the exact type of event
	 * represented by a ServerEvent object.
	 */
	public class IRCServerEvent extends Event
	{
		static public const QUIT:String = 'quitServer';
		static public const MESSAGE:String = 'serverMessage';
		
		public var data:Object;
		
		public function IRCServerEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}
	}
}