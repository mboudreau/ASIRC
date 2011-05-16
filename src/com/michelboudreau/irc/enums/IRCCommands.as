package com.michelboudreau.irc.enums
{
	/** IRC commands - must be string since not all are numeric **/
	public class IRCCommands
	{
		// Server Commands
		static public const PING:String = 'PING';
		static public const FINGER:String = 'FINGER';
		static public const VERSION:String = 'FINGER';
		static public const TIME:String = 'FINGER';
		
		// Message Commands
		static public const MESSAGE:String = 'PRIVMSG';
		static public const USER_MODE:String = 'MODE';
		
		// Welcome Codes
		static public const WELCOME:String = '001';
		static public const HOST_SERVER:String = '002';
		static public const HOST_CREATION:String = '003';
		static public const HOST_INFO:String = '004';
		static public const HOST_MODES:String = '005';
		
		// Stats
		static public const CONNECTION_COUNT:String = '250';
		static public const USERS:String = '251';
		static public const OPS:String = '252';
		static public const CONNECTIONS:String = '253';
		static public const CHANNELS:String = '254';
		static public const LOCAL_USERS:String = '265';
		static public const GLOBAL_USERS:String = '266';
		static public const STATS_LINK_INFO:String = '211';
		static public const STATS_COMMANDS:String = '212';
		static public const STATS_CLINE:String = '213';
		static public const STATS_NLINE:String = '214';
		static public const STATS_ILINE:String = '215';
		static public const STATS_KLINE:String = '216';
		static public const STATS_YLINE:String = '218';
		static public const END_OF_STATS:String = '219';
		static public const STATS_LLINE:String = '241';
		static public const STATS_UPTIME:String = '242';
		static public const STATS_OLINE:String = '243';
		static public const STATS_HLINE:String = '244';
		
		// Message of the day
		static public const MOTD_TITLE:String = '375';
		static public const MOTD:String = '372';
		static public const MOTD_END:String = '376';
		
		// Channel
		static public const CHAN_TOPIC:String = '332';
		static public const CHAN_INFO:String = '333';
		static public const CHAN_USERS:String = '353';
		static public const CHAN_USERS_END:String = '366';
		static public const CHAN_USER_PART:String = 'PART';
		static public const CHAN_USER_JOIN:String = 'JOIN';
		static public const CHAN_USER_QUIT:String = 'QUIT';
		
		// Errors
		static public const NO_SUCH_NICK:String = '401';
		static public const NO_SUCH_SERVER:String = '402';
		static public const NO_SUCH_CHANNEL:String = '403';
		static public const CANNOT_SEND_TO_CHAN:String = '404';
		static public const TOO_MANY_CHANNELS:String = '405';
		static public const WAS_NO_SUCH_NICK:String = '406';
		static public const TOO_MANY_TARGETS:String = '407';
		static public const NO_ORIGIN:String = '409';
		static public const NO_RECIPIENT:String = '411';
		static public const NO_TEXT_TO_SEND:String = '412';
		static public const NO_TOP_LEVEL:String = '413';
		static public const WILD_TOP_LEVEL:String = '414';
		static public const UNKNOWN_COMMAND:String = '421';
		static public const NO_MOTD:String = '422';
		static public const NO_ADMIN_INFO:String = '423';
		static public const FILE_ERROR:String = '424';
		static public const NO_NICKNAME_GIVEN:String = '431';
		static public const ERROR_USER_NICKNAME:String = '432';
		static public const NICKNAME_IN_USE:String = '433';
		static public const NICK_COLLISION:String = '436';
		static public const USER_NOT_IN_CHANNEL:String = '441';
		static public const NOT_ON_CHANNEL:String = '442';
		static public const USER_ON_CHANNEL:String = '443';
		static public const NO_LOGIN:String = '444';
		static public const SUMMON_DISABLED:String = '445';
		static public const USERS_DISABLED:String = '446';
		static public const NOT_REGISTERED:String = '451';
		static public const NEED_MORE_PARAMS:String = '461';
		static public const ALREADY_REGISTRED:String = '462';
		static public const NO_PERM_FOR_HOST:String = '463';
		static public const PASSWORD_MISMATCH:String = '464';
		static public const YOURE_BANNED_CREEP:String = '465';
		static public const KEY_SET:String = '467';
		static public const CHANNEL_IS_FULL:String = '471';
		static public const UNKNOWN_MODE:String = '472';
		static public const INVITE_ONLY_CHAN:String = '473';
		static public const BANNED_FROM_CHAN:String = '474';
		static public const BAD_CHANNEL_KEY:String = '475';
		static public const NO_PRIVILEGES:String = '481';
		static public const CHAN_OP_PRIVS_NEEDED:String = '482';
		static public const CANT_KILL_SERVER:String = '483';
		static public const NO_OPER_HOST:String = '491';
		static public const UMODE_UNKNOWN_FLAG:String = '501';
		static public const USERS_DONT_MATCH:String = '502';
		static public const YOU_WILL_BE_BANNED:String = '466';
		static public const BAD_CHAN_MASK:String = '476';
		static public const NO_SERVICE_HOST:String = '492';
		
		// Traces
		static public const TRACE_LINK:String = '200';
		static public const TRACE_CONNECTING:String = '201';
		static public const TRACE_HANDSHAKE:String = '202';
		static public const TRACE_UNKNOWN:String = '203';
		static public const TRACE_OPERATOR:String = '204';
		static public const TRACE_USER:String = '205';
		static public const TRACE_SERVER:String = '206';
		static public const TRACE_NEWTYPE:String = '208';
		static public const TRACE_LOG:String = '261';
		
		
		static public const UMODEIS:String = '221';
		
		
		static public const LUSER_ME:String = '255';
		static public const ADMIN_ME:String = '256';
		static public const ADMIN_LOC1:String = '257';
		static public const ADMIN_LOC2:String = '258';
		static public const ADMIN_EMAIL:String = '259';
		
		static public const NONE:String = '300';
		static public const AWAY:String = '301';
		static public const USER_HOST:String = '302';
		static public const IS_ON:String = '303';
		static public const UNAWAY:String = '305';
		static public const NOW_AWAY:String = '306';
		static public const WHO_IS_USER:String = '311';
		static public const WHO_IS_SERVER:String = '312';
		static public const WHO_IS_OPERATOR:String = '313';
		static public const WHO_WAS_USER:String = '314';
		static public const END_OF_WHO:String = '315';
		static public const WHO_IS_IDLE:String = '317';
		static public const END_OF_WHOIS:String = '318';
		static public const WHO_IS_CHANNELS:String = '319';
		static public const LIST_START:String = '321';
		static public const LIST:String = '322';
		static public const LIST_END:String = '323';
		static public const CHANNEL_MODE_IS:String = '324';
		static public const NO_TOPIC:String = '331';
		static public const INVITING:String = '341';
		static public const SUMMONING:String = '342';
		static public const VERSION_REPLY:String = '351';
		static public const WHO_REPLY:String = '352';
		static public const LINKS:String = '364';
		static public const END_OF_LINKS:String = '365';
		static public const BANLIST:String = '367';
		static public const END_OF_BANLIST:String = '368';
		static public const END_OF_WHO_WAS:String = '369';
		static public const INFO:String = '371';
		static public const END_OF_INFO:String = '374';
		static public const YOURE_OPER:String = '381';
		static public const REHASHING:String = '382';
		static public const TIME_REPLY:String = '391';
		static public const USERS_START:String = '392';
		static public const USERS_REPLY:String = '393';
		static public const END_OF_USERS:String = '394';
		static public const NO_USERS:String = '395';
		
		// Reserved Numerics
		static public const TRACE_CLASS:String = '209';
		static public const STATS_QLINE:String = '217';
		static public const SERVICE_INFO:String = '231';
		static public const END_OF_SERVICES:String = '232';
		static public const SERVICE:String = '233';
		static public const SERV_LIST:String = '234';
		static public const SERV_LIST_END:String = '235';
		static public const WHO_IS_CHAN_OP:String = '316';
		static public const KILL_DONE:String = '361';
		static public const CLOSING:String = '362';
		static public const CLOSE_END:String = '363';
		static public const INFO_START:String = '373';
		static public const MY_PORT_IS:String = '384';
	}
}