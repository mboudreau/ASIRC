package com.michelboudreau.irc
{
	import com.michelboudreau.irc.enums.Client;
	import com.michelboudreau.irc.enums.IRCCommands;
	import com.michelboudreau.irc.enums.IRCSocketStatus;
	import com.michelboudreau.irc.events.IRCServerEvent;
	import com.michelboudreau.irc.events.IRCSocketEvent;
	import com.michelboudreau.irc.models.IRCDataModel;
	import com.michelboudreau.utils.StringUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	// SOCKET EVENTS
	[Event(name='socketConnecting', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	[Event(name='socketHandshaking', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	[Event(name='socketConnected', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	[Event(name='socketClose', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	[Event(name='socketData', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	[Event(name='socketSecurityError', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	[Event(name='socketIOError', type='com.michelboudreau.irc.events.IRCSocketEvent')]
	
	// IRC EVENTS
	[Event(name='message', type='com.michelboudreau.irc.events.IRCEvent')]
	[Event(name='requestUsername', type='com.michelboudreau.irc.events.IRCEvent')]
	
	// SERVER EVENTS
	[Event(name='quitServer', type='com.michelboudreau.irc.events.IRCServerEvent')]
	[Event(name='serverMessage', type='com.michelboudreau.irc.events.IRCServerEvent')]
	
	// CHANNEL EVENTS
	[Event(name='joinChannel', type='com.michelboudreau.irc.events.IRCChannelEvent')]
	[Event(name='partChannel', type='com.michelboudreau.irc.events.IRCChannelEvent')]
	[Event(name='channelMessage', type='com.michelboudreau.irc.events.IRCChannelEvent')]
	
	// CHAT EVENTS
	[Event(name='chatMessage', type='com.michelboudreau.irc.events.IRCChatEvent')]
	
	// ERRORS
	[Event(name='error', type='com.michelboudreau.irc.events.IRCErrorEvent')]
	
	/**
	 * After weeks of trying to figure out how to break this class
	 * appart into easily manageable sections like server, channel and chat;
	 * I've come to the conclusion that the IRC protocol isn't made for OO
	 * languages and is better to just leave the whole protocol in one class
	 * and have lots of event dispatch throughout to notify the UI on what's
	 * going on and how to update the view model.
	 * 
	 * If you try to break this class in bits, you're on your own and have 
	 * been forwarned.
	 *  
	 * @author mboudreau
	 */	
	public class IRCSocket extends EventDispatcher
	{
		//private const _logger:ILogger = Log.getLogger('IRCSocket');
		
		protected var _password:String;
		protected var _sendBuffer:Vector.<String> = new Vector.<String>();
		
		// Read only properties
		protected var _hostname:String;
		protected var _host:String;
		protected var _port:uint;
		protected var _username:String;
		//protected var __info:InfoModel;
		protected var __status:IRCSocketStatus = IRCSocketStatus.CLOSED;
		
		// Making this private to stop anyone from sending directly to socket
		private var _socket:Socket = new Socket();
		private var _lineBuffer:String;
		
		// READ ONLY GETTERS
		public function get hostname():String
		{
			if(this._hostname && this._hostname.length > 0)
			{
				return this._hostname;
			}else{
				return this._host;
			}
		}
		
		public function get host():String
		{
			return this._host;
		}
		
		public function get port():uint
		{
			return this._port;
		}
		
		[Bindable(event="statusPropertyChanged")]
		public function get status():IRCSocketStatus
		{
			return this._status;
		}
		
		protected function get _status():IRCSocketStatus
		{
			return this.__status;
		}
		
		protected function set _status(value:IRCSocketStatus):void
		{
			this.__status = value;
			
			switch(this.__status)
			{
				case IRCSocketStatus.CLOSED:
					this.dispatchEvent(new IRCSocketEvent(IRCSocketEvent.CLOSE));
					break;
				case IRCSocketStatus.CONNECTING:
					this.dispatchEvent(new IRCSocketEvent(IRCSocketEvent.CONNECTING));
					break;
				case IRCSocketStatus.HANDSHAKING:
					this.dispatchEvent(new IRCSocketEvent(IRCSocketEvent.HANDSHAKING));
					break;
				case IRCSocketStatus.CONNECTED:
					this.dispatchEvent(new IRCSocketEvent(IRCSocketEvent.CONNECTED));
					break;
			}
 			dispatchEvent(new Event("statusPropertyChanged"));
		}
		/*
		protected function get _info():InfoModel
		{
			return this.__info;
		}
		
		protected function set _info(value:InfoModel):void
		{
			this.__info = value;
			dispatchEvent(new Event("userPropertyChanged"));
		}*/
		
		public function IRCSocket(host:String, port:uint, username:String, hostname:String = null, password:String = null)
		{
			// Save info
			//this._info = info;
			this._username = username;
			this._hostname = hostname;
			this._host = host;
			this._port = port;
			this._password = password;
			
			// Create server model
			//this._server = new IRCServer(this);
			
			// Add socket listeners
			this._socket.addEventListener(Event.CONNECT , onSocketConnect);				
			this._socket.addEventListener(Event.CLOSE , onSocketClose);
			this._socket.addEventListener(IOErrorEvent.IO_ERROR , onSocketIOError);
			this._socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR , onSocketSecurityError);
			this._socket.addEventListener(ProgressEvent.SOCKET_DATA , onSocketData);
		}
		
		/**
		 * Used to destroy socket altogether by whoever created
		 * the instance.  This function also force closes 
		 * the connection, leaving it up for GC.
		 */		
		public function destroy():void
		{
			this._socket.removeEventListener(Event.CONNECT , onSocketConnect);				
			this._socket.removeEventListener(Event.CLOSE , onSocketClose);
			this._socket.removeEventListener(IOErrorEvent.IO_ERROR , onSocketIOError);
			this._socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR , onSocketSecurityError);
			this._socket.removeEventListener(ProgressEvent.SOCKET_DATA , onSocketData);
			close();
		}
		
		/**
		 * Connect to the socket using the host and port specified
		 * in the constructor. 
		 * 
		 * @param username (Optional) set username before connecting.
		 */		
		public function connect(username:String = null):void
		{
			if(username)
				this._username = username;
			
			this._status = IRCSocketStatus.CONNECTING;
			this._socket.connect(this._host, this._port);
		}
		
		/**
		 * Sends quit message to irc server and closes connection.
		 * 
		 * @param reason (Optional) reason why you quit, defaults to nothing.
		 */		
		public function quit(reason:String = ""):void
		{
			if(this._status == IRCSocketStatus.CONNECTED)
			{
				send("QUIT :{0}", reason); // Send quit message
				close();
			}
		}
		
		/**
		 * Closes the connection.  ONLY TO BE USED TO FORCE CLOSE SOCKET.
		 * Should use 'quit' function whenever possible. 
		 */		
		public function close():void
		{
			// Close socket
			this._socket.close();
		}
		
		/**
		 * Send any message by specifying recipient.
		 * 
		 * @param target recipient of the message, can be user, server or channel.
		 * @param message message that you'd like to send.
		 */		
		public function sendMessage(target:String, message:String):void
		{
			// Send info to server
			send("PRIVMSG {0} :{1}", target, message);
		}
		
		/**
		 * Sends an action to the channel or to a user.
		 *
		 * @param target The name of the channel or user nick to send to.
		 * @param action The action to send.
		 */
		//TODO: not sure about this one
		public function sendAction(target:String, action:String):void 
		{
			sendCTCPCommand(target, "ACTION " + action);
		}
		
		/**
		 * Sends a notice to the channel or to a user.
		 *
		 * @param target The name of the channel or user nick to send to.
		 * @param notice The notice to send.
		 */
		public function sendNotice(target:String, notice:String):void 
		{
			send("NOTICE {0} :{1}", target, notice);
		}
		
		/**
		 * Sends a CTCP command to a channel or user.  (Client to client protocol).
		 * Examples of such commands are "PING <number>", "FINGER", "VERSION", etc.
		 * For example, if you wish to request the version of a user called "Dave",
		 * then you would call <code>sendCTCPCommand("Dave", "VERSION");</code>.
		 * The type of response to such commands is largely dependant on the target
		 * client software.
		 *
		 * @param target The name of the channel or user to send the CTCP message to.
		 * @param command The CTCP command to send.
		 */
		public function sendCTCPCommand(target:String,  command:String):void 
		{
			// Wrapping command in special characters for server
			command = "\u0001" + command + "\u0001";
			sendMessage(target, command); // send as normal message
		}
		
		/**
		 * Attempt to change the user's current nickname when
		 * connected to server.
		 *
		 * @param nick The new nick to use.
		 */
		public function setNick(nick:String):void 
		{
			// Only send if connected
			if(this._status == IRCSocketStatus.CONNECTED)
			{
				send("NICK {0}", nick);
			}
		}
		
		/**
		 * Set the mode of a channel.
		 * This method attempts to set the mode of a channel.  This
		 * may require the user to have operator status on the channel.
		 * For example, if the user has operator status, we can grant
		 * operator status to "Dave" on the #cs channel
		 * by calling setMode("#cs", "+o Dave");
		 * An alternative way of doing this would be to use the op method.
		 * 
		 * @param channel The channel on which to perform the mode change.
		 * @param mode    The new mode to apply to the channel.  This may include
		 *                zero or more arguments if necessary.
		 */
		//TODO: not sure if I should make this public or keep protected and have all mode functions public
		public function setMode(channel:String,  mode:String, extra:String = null):void 
		{
			send("MODE {0} {1} {2}", channel, mode, extra);
		}
		
		/**
		 * Sends an invitation to join a channel.  Some channels can be marked
		 * as "invite-only", so it may be useful to allow a user to invite people
		 * into it.
		 * 
		 * @param nick    The nick of the user to invite
		 * @param channel The channel you are inviting the user to join.
		 * 
		 */
		public function sendInvite(nick:String, channel:String):void 
		{
			send("INVITE {0} :{1}", nick, channel);
		}    
		
		/**
		 * Bans aanother user from a channel.  An example of a valid hostmask is
		 * "*!*compu@*.18hp.net".  This may be used in conjunction with the
		 * kick method to permanently remove a user from a channel.
		 * Successful use of this method may require the user to have operator
		 * status itself.
		 * 
		 * @param channel The channel to ban the user from.
		 * @param hostmask A hostmask representing the user we're banning.
		 */
		// TODO: ban by nick, check for hostmask if not already stored in user model
		public function ban(channel:String, hostmask:String):void 
		{
			this.setMode(channel, '+b', hostmask);
		}
		
		/**
		 * Unbans a user from a channel.  An example of a valid hostmask is
		 * "*!*compu@*.18hp.net".
		 * Successful use of this method may require the user to have operator
		 * status itself.
		 * 
		 * @param channel The channel to unban the user from.
		 * @param hostmask A hostmask representing the user we're unbanning.
		 */
		public function unBan(channel:String, hostmask:String):void 
		{
			this.setMode(channel, '-b', hostmask);
		}
		
		/**
		 * Grants operator privilidges to a user on a channel.
		 * Successful use of this method may require the user to have operator
		 * status itself.
		 * 
		 * @param channel The channel we're opping the user on.
		 * @param nick The nick of the user we are opping.
		 */
		public function op(channel:String, nick:String):void 
		{
			this.setMode(channel, "+o", nick);
		}
		
		/**
		 * Removes operator privilidges from a user on a channel.
		 * Successful use of this method may require the user to have operator
		 * status itself.
		 * 
		 * @param channel The channel we're deopping the user on.
		 * @param nick The nick of the user we are deopping.
		 */
		public function deOp(channel:String, nick:String):void 
		{
			this.setMode(channel, "-o", nick);
		}
		
		/**
		 * Grants voice privilidges to a user on a channel.
		 * Successful use of this method may require the user to have operator
		 * status itself.
		 * 
		 * @param channel The channel we're voicing the user on.
		 * @param nick The nick of the user we are voicing.
		 */
		public function voice(channel:String, nick:String):void 
		{
			this.setMode(channel, "+v", nick);
		}
		
		/**
		 * Removes voice privilidges from a user on a channel.
		 * Successful use of this method may require the user to have operator
		 * status itself.
		 * 
		 * @param channel The channel we're devoicing the user on.
		 * @param nick The nick of the user we are devoicing.
		 */
		public function deVoice(channel:String, nick:String):void 
		{
			this.setMode(channel, "-v", nick);
		}
		
		/**
		 * Set the key for a channel.
		 * This method attempts to set the key of a channel. 
		 * 
		 * @param channel The channel on which to perform the mode change.
		 * @param key   The key for the channel.
		 * 
		 */
		public function setChannelKey(channel:String, key:String):void 
		{
			this.setMode(channel, "+k", key);
		}
		
		/**
		 * Remove the key for a channel.
		 * This method attempts to remove the key of a channel. 
		 * 
		 * @param channel The channel on which to perform the mode change.
		 * @param key   The key for the channel.
		 */
		public function removeChannelKey(channel:String, key:String):void 
		{
			this.setMode(channel, "-k", key);
		}
		
		/**
		 * This method attempts to set the topic of a channel.  This
		 * may require the user to have operator status if the topic
		 * is protected.
		 * 
		 * @param channel The channel on which to perform the mode change.
		 * @param topic   The new topic for the channel.
		 */
		public function setTopic(channel:String, topic:String):void 
		{
			send("TOPIC {0} :{1}", channel, topic);
		}
		
		/**
		 * Kicks a user from a channel, giving a reason.
		 * This method attempts to kick a user from a channel and
		 * may require the user to have operator status in the channel.
		 * 
		 * @param channel The channel to kick the user from.
		 * @param nick    The nick of the user to kick.
		 * @param reason  A description of the reason for kicking a user.
		 */
		public function kick(channel:String, nick:String, reason:String = ''):void 
		{
			send("KICK {0} {1} :{2}", channel, nick, reason);
		}
		
		/**
		 * Issues a request for a list of all channels on the IRC server.
		 * 
		 * Some IRC servers support certain parameters for LIST requests.
		 * One example is a parameter of ">10" to list only those channels
		 * that have more than 10 users in them.  Whether these parameters
		 * are supported or not will depend on the IRC server software.
		 * 
		 * @param parameters The parameters to supply when requesting the list.
		 */
		public function listChannels(parameters:String = null):void
		{
			send("LIST {0}", parameters);
		}
		
		/**
		 * Joins a channel.
		 * 
		 * @param channel The channel name the user wants to join.
		 * @param password (Optional) password for the channel if private
		 */		
		public function joinChannel(channel:String, password:String = null ):void
		{
			if(channel.charAt(0) != '#')
				channel = '#' + channel;
			
			send("JOIN {0} {1}" , channel, password);
		}
		
		/**
		 * Parts a specified channel
		 * 
		 * @param channel The channel the user wants to part
		 * @param reason (Optional) The reason the user is parting
		 * 
		 */		
		public function partChannel(channel:String , reason:String = "" ):void
		{
			if(channel.charAt(0) != '#')
				channel = '#' + channel;
			
			send("PART {0} : {1}", channel, reason);
			//this.dispatchEvent(new IRCServerEvent(IRCServerEvent.PART_CHANNEL, false, false, this));
		}

		
		/**
		 * Sends a string to the irc server, can be anything but
		 * try to use readily available public functions.
		 *  
		 * @param string The string to be sent to the server, can use 
		 * 					injection vars like ({0},{1},...{n})
		 * @param params The vars to be injected in the string
		 * 
		 * Example: send("the {0} I want to {1} is {2}", "string", "send", "this");
		 */		
		protected function send(string:String, ...params:Array):void
		{
			// Check to see if there's parameters to replace
			string = StringUtil.substitute(string, params);
			
			// Check if connect or else buffer until connected
			if(this._socket.connected)
			{
				// trim string if there's extra spaces
				string = StringUtil.trim(string);
				
				//TODO: maximum 510 characters total (plus line end)
				// If longer than 510, split in several messages?
				
				//this._logger.debug('Sending: {0} - {1}', this._host, string);
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(string + Client.LINE_END);
				this._socket.writeBytes(ba);
				this._socket.flush();
			}else{
				//this._logger.warn("Server '{0}' currently not connected, storing for later", this._host);
				this._sendBuffer.push(string);
			}
		}
		
		//TODO: set proper status throughout service, have functions check that status
		/**
		 * Event handler for the socket connect event.
		 * Starts the handshaking process by sending nickname.
		 * 
		 * @param e scoket connection event
		 */		
		protected function onSocketConnect(e:Event):void
		{
			// Set status
			this._status = IRCSocketStatus.HANDSHAKING;
			
			// Need to send user info right away
			if(this._password)
			{
				send("PASS {0}", this._password);
			}
			
			// Send user information to the server
			if(this._username)
			{
				send("USER {0} 8 * :{1}", this._username, Client.CLIENT);
			}else{
				// TODO: ask for username, dispatch event
			}
			
			// iterate through send buffer
			while(this._sendBuffer.length > 0)
			{
				send(this._sendBuffer.shift());
			}
		}
		
		/**
		 * Socket close event handler.
		 *  
		 * @param e Event param
		 */		
		// TODO: try to reconnect
		protected function onSocketClose(e:Event):void
		{
			this._status = IRCSocketStatus.CLOSED;
			
			// Remove socket listeners
			/*this._socket.removeEventListener(IRCSocketEvent.CONNECTED, onSocketConnected);
			this._socket.removeEventListener(IRCSocketEvent.CLOSE, onSocketClose);
			this._socket.removeEventListener(IRCSocketEvent.DATA, onSocketData);
			this._socket.removeEventListener(IRCSocketEvent.IO_ERROR, onSocketIOError);
			this._socket.removeEventListener(IRCSocketEvent.SECURITY_ERROR, onSocketSecurityError);
			
			// Iterate through chats & channels to remove listeners
			var i:uint, len:uint;
			for(i = 0, len = this._channels.length; i<len; i++)
			{
				removeChannel(this._channels.getItemAt(i).name);
			}
			
			for(i = 0, len = this._chats.length; i<len; i++)
			{
				removeChat(this._chats.getItemAt(i).name);
			}
			
			// Remove all channels
			this._channels.removeAll();
			this._channelIds = new Dictionary();
			this._chats.removeAll();
			this._chatIds = new Dictionary();*/
			
			dispatchEvent(new IRCSocketEvent(IRCSocketEvent.CLOSE, {host:this._host, port:this._port}));
		}
		
		/**
		 * Input/Output error handler.  Haven't seen any errors yet 
		 * since IRC is a very basic socket. 
		 * 
		 * @param e IOErrorEvent param
		 */		
		protected function onSocketIOError(e:IOErrorEvent):void
		{
			//this._logger.error("IRC Socket IO Error: {0}", e.text);
			dispatchEvent(new IRCSocketEvent(IRCSocketEvent.IO_ERROR, e));
		}
		
		/**
		 * Socket security handler error.  Shouldn't happen either since
		 * IRC servers don't have socket based authentication.
		 *  
		 * @param e SecurityErrorEvent param
		 */		
		protected function onSocketSecurityError(e:SecurityErrorEvent):void
		{
			//this._logger.error("IRC Socket Security Error: {0}", e.text);
			dispatchEvent(new IRCSocketEvent(IRCSocketEvent.SECURITY_ERROR, e));
		}
		
		/**
		 * Socket data handler.  This is where we receive and 
		 * parase the irc protocol.
		 *  
		 * @param e ProgressEvent param
		 * 
		 */		
		protected function onSocketData(e:ProgressEvent):void
		{
			var lines:Vector.<String> = read(); // read data into vector
			if(lines && lines.length > 0)
			{
				//this._logger.debug('**** SOCKET DATA ****\n {0} \n**** END SOCKET DATA ****', lines.toArray().join('\n'));
				// Dispatch raw line event
				dispatchEvent(new IRCSocketEvent(IRCSocketEvent.DATA, lines));
				
				// Parse and handle lines
				for(var i:uint = 0, len:uint = lines.length; i<len; i++)
				{
					// first parse the data into model, then handle the model
					handleData(parseData(lines[i]));
				}
			}
		}
		
		/**
		 * Reads the byte data from the socket and casts them to
		 * strings, into different lines if there's a line end.
		 * 
		 * @return A vector full of strings (lines)
		 * 
		 */		
		protected function read():Vector.<String>
		{
			// Check to see if any data is available
			if(this._socket.bytesAvailable)
			{
				// Get line from socket
				var line:String = this._socket.readUTFBytes(this._socket.bytesAvailable);
				
				// If line buffer isn't empty, append line
				// because data coming in isn't always complete. 
				// need to wait for line end
				if(this._lineBuffer)
				{
					line = this._lineBuffer += line;
				}
				
				// Check to see if line is complete (should end with a newline)
				if(line.lastIndexOf(Client.LINE_END) == (line.length - 2))
				{
					this._lineBuffer = null; // clear buffer
					line = StringUtil.trim(line); // remove end whitespace
					return Vector.<String>.(line.split(LINE_END)); // Split strings into array on newline
				}else{
					this._lineBuffer = line;
				}
			}
			return null;
		}
		
		/**
		 * Take in raw string lines and parse them into a comprehensible
		 * model.
		 * 
		 * @param line string of data from the socket
		 * 
		 * @return An IRCDataModel that contains all the split up data 
		 */		
		protected function parseData(line:String):IRCDataModel
		{
			var data:IRCDataModel = new IRCDataModel();
			data.raw = line;
			
			// Split message from all other parts
			var parts:Vector.<String> = Vector.<String>(line.split(' :'));
			
			// Get message
			data.message = line.slice(parts[0].length + 2);
			
			// reduce line to just params
			parts = Vector.<String>(parts[0].split(' '));
			
			// Find prefix is available as the first param, remove from stack
			if(parts[0].charAt(0) == ':')
			{
				data.id = parts.shift().slice(1);
			}
			
			// Get command
			data.command = parts.shift();
			
			// save the rest of the params
			data.params = parts;
			
			return data;
		}
		
		/**
		 * Handle the newly parse data model into actions
		 *  
		 * @param data The irc model with all the line data
		 */		
		protected function handleData(data:IRCDataModel):void
		{
			//this._logger.debug(data.toString());
			var i:uint, len:uint, info:Array;
			// Find the proper command
			switch (data.command)
			{
				case IRCCommands.HOST_INFO:
					//addLog(data.raw);
					if (this._status == IRCSocketStatus.HANDSHAKING)
					{
						this._status = IRCSocketStatus.CONNECTED;
					}
					break;
				case IRCCommands.NICKNAME_IN_USE:
					//addLog("* Nickname is currently in use");
					//TODO: ask user for new nick
					break;

				case IRCCommands.CHAN_TOPIC:
					//this._server.getChannel(data.params[1]).setTopic(data.message);
					break;
				case IRCCommands.CHAN_INFO:
					//this._server.getChannel(data.params[1]).setTopicInfo(String(data.params[2]).split('!')[0], new Date(Number(data.params[3])*1000));
					//break;
				case IRCCommands.CHAN_USERS:
					/*channel = this._server.getChannel(data.params[2]);
					var users:Array = data.message.split(' ');
					for(i = 0, len = users.length; i<len; i++)
					{
						channel.addUser(new UserModel(users[i]));
					}*/
					break;
				case IRCCommands.CHAN_USERS_END: // Do nothing - no real data
					break;
				case IRCCommands.CHAN_USER_JOIN:
					/*if (data.id.split('!')[0] != this._info.nickname)
					{
						channel = this._server.getChannel(data.message);
						info = data.id.split('!');
						channel.addUser(new UserModel(info[0]));
						// Show message that user joined
						channel.addLog("{0} ({1}) has joined", info[0], info[1]);
					}*/
					break;
				case IRCCommands.CHAN_USER_PART:
					/*if (data.id.split('!')[0] != this._info.nickname)
					{
						channel = this._server.getChannel(data.params[0]);
						info = data.id.split('!');
						channel.removeUser(info[0]);
						// Show message that user parted
						channel.addLog("{0} ({1}) has left", info[0], info[1]);
					}*/
					break;
				case IRCCommands.USER_MODE:
					// Check to see if this is a server or channel mode
					/*if (String(data.params[0]).indexOf('#') == 0)
					{
						this._server.getChannel(data.params[0]).setMode(data.params[2], data.params[1], data.id.split('!')[0]); // chan mode
					}
					else
					{
						// server mode
						// TODO: set mode on user object
					}*/
					break;
				case IRCCommands.MESSAGE:
					// Check if it's a channel message or user pm
					// starts with '#' = channel
					/*if (String(data.params[0]).indexOf('#') == 0)
					{
						this._server.getChannel(data.params[0]).addLog("{0}: {1}", data.id.split('!')[0], data.message);
					}
					else
					{
						switch (data.message)
						{
							case "\u0001VERSION\u0001":
								break;
							case "\u0001PING\u0001":
								break;
							case "\u0001FINGER\u0001":
								break;
							case "\u0001TIME\u0001":
								break;
							default:
								this._server.getChat(data.id.split('!')[0]).addLog("{0}: {1}", data.id.split('!')[0], data.message);
								break;
						}
					}*/
					break;
				
				case IRCCommands.PING:
					//addLog(data.raw);
					send('PONG :{0}', data.id);
					break;
				case IRCCommands.FINGER:
					//addLog(data.raw);
					send("NOTICE {0} :\u0001FINGER {1}\u0001", data.id, Client.CLIENT);
					break;
				case IRCCommands.VERSION:
					//addLog(data.raw);
					send("NOTICE {0} :\u0001VERSION {1}\u0001", data.id, Client.CLIENT);
					break;
				case IRCCommands.TIME:
					//addLog(data.raw);
					send("NOTICE {0} :\u0001TIME {1}\u0001", data.id, new Date().toLocaleString());
					break;
				default:
					//super.handleLine(data);
			}
		}
	}
}