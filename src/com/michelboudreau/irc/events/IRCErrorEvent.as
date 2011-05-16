package com.michelboudreau.irc.events
{
	/**
	 * This Error is thrown when an unspecified Irc Error occurs.
	 */
	public class IRCErrorEvent extends Error
	{
		static public const ERROR:String = 'error';
		
	    public function IRCErrorEvent(message:String/*, errorID:int=0*/)
	    {
	        super(message, errorID);
	    }
	}

}