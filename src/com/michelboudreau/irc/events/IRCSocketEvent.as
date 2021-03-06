package com.michelboudreau.irc.events
{
	import flash.events.Event;
	
	/**
	 * the IrcEvent is the base class for the various IRC-related events in this package.
	 */
	public class IRCSocketEvent extends Event
	{
		static public const CONNECTING:String = 'socketConnecting';
		static public const HANDSHAKING:String = 'socketHandshaking';
		static public const CONNECTED:String = 'socketConnected';
		static public const CLOSE:String = 'socketClose';
		static public const DATA:String = 'socketData';
		static public const SECURITY_ERROR:String = 'socketSecurityError';
		static public const IO_ERROR:String = 'socketIOError';
		
		public var data:Object;
		
		public function IRCSocketEvent(type:String, data:Object = null)
		{
			super(type, false, false);
			this.data = data;
		}
		
	}
}