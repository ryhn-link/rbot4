import matrix;
import ini;
import std.stdio;
import std.functional : toDelegate;
import std.format : format;
import std.algorithm;
import std.string;
import std.range;
import botcommands;

MatrixClient mx;

void main()
{
	writeln(registeredCommands.keys);
	auto config = new IniFile("config.ini");

	string homeserver = config["login"]["server"];
	if (config["connection"]["usehttp"])
		homeserver = "http://" ~ homeserver;
	else
		homeserver = "https://" ~ homeserver;

	mx = new MatrixClient(homeserver);
	mx.login(config["login"]["name"], config["login"]["password"]);
	commandPrefix = config["commands"]["prefix"];

	writeln("Logged in as %s".format(mx.user_id));

	// Initial sync
	writeln("Preforming initial sync");
	mx.inviteDelegate = (&onInvite).toDelegate();
	mx.sync();
	writeln("Initial sync complete, processing events");

	mx.messageDelegate = (&onMessage).toDelegate();
	while (1)
	{
		mx.sync();
	}
}

void onInvite(string roomid, string userid)
{
	writeln("Invited to room %s by %s", roomid, userid);
	mx.joinRoom(roomid);

	mx.sendHTML(roomid, "Hello world! I was invited by <b>%s</b>".format(userid));
}

void onMessage(MatrixMessage m)
{
	writeln("Message from %s: %s".format(m.author, m.type));

	if(MatrixTextMessage txt = cast(MatrixTextMessage)m)
	{		
		handleCommand(txt);
	}
}

string commandPrefix;
void handleCommand(MatrixTextMessage msg)
{
	// Bots should respond with m.notice, ignore them
	if(msg.type != "m.text")
		return;

	string content = msg.conent;

	if(!content.startsWith(commandPrefix)) return;

	mx.markRead(msg.roomId, msg.eventId);

	content = content[commandPrefix.length..$];
	string[] args = strexp(content);
	string cmdname = args.front;
	args = args[1..$];

	mx.sendString(msg.roomId, "%s executing command '%s' with args %s".format(msg.author,cmdname,args));

	// Search for commands
	if(cmdname in registeredCommands)
	{
		CommandInfo cmd = registeredCommands[cmdname];
		cmd.overloads.front().execute(new CommandContext(), args);
		// Check overloads
	}
	else mx.sendString(msg.roomId, "Command '%s' not found".format(cmdname));
}

// I have no idea if it works properly, copilot wrote all of this, wow!
string[] strexp(string s)
{
	string[] result;
	int i = 0;
	while (i < s.length)
	{
		if (s[i] == ' ')
		{
			i++;
			continue;
		}
		if (s[i] == '"')
		{
			i++;
			string str = "";
			while (i < s.length && s[i] != '"')
			{
				str ~= s[i];
				i++;
			}
			result ~= (str);
			i++;
			continue;
		}
		string str = "";
		while (i < s.length && s[i] != ' ')
		{
			str ~= s[i];
			i++;
		}
		result ~= (str);
	}
	return result;
}