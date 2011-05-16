package com.michelboudreau.irc.models
{
	import com.michelboudreau.irc.enums.IRCCommands;
	
	import mx.utils.StringUtil;

	public class IRCDataModel
	{
		public var id:String;
		public var command:String;
		public var params:Vector.<String>;
		public var message:String;
		public var raw:String;
		
		public function toString():String
		{
			return StringUtil.substitute('id: {0}, command: {1}, params: {2}, message: {3}', id, command, params, message);
		}
	}
}