package
{
	import com.michelboudreau.irc.IRCSocket;
	
	import flash.display.Sprite;
	
	public class ASIRC extends Sprite
	{
		public function ASIRC()
		{
			var socket:IRCSocket = new IRCSocket('irc.freenode.org', 6664, 'J_A_X');
		}
	}
}