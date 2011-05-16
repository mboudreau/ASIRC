package com.michelboudreau.irc.events
{
	import flash.events.Event;

	/**
	 * The ChannelEvent is an IrcEvent that pertains to Channel related activity.
	 * You should inspect the type property to extract the exact type of event
	 * represented by a ChannelEvent object.
	 */
	public class IRCChatEvent extends Event
	{
		static public const MESSAGE:String = 'chatMessage';
		
		public var data:Object;
		
		public function IRCChatEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}		
	}
}