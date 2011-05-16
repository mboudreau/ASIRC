package com.michelboudreau.irc.events
{
	import flash.events.Event;

	/**
	 * The ChannelEvent is an IrcEvent that pertains to Channel related activity.
	 * You should inspect the type property to extract the exact type of event
	 * represented by a ChannelEvent object.
	 */
	public class IRCChannelEvent extends Event
	{
		static public const JOIN:String = 'joinChannel';
		static public const PART:String = 'partChannel';
		static public const MESSAGE:String = 'channelMessage';
		
		public var data:Object;
		
		public function IRCChannelEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}		
	}
}