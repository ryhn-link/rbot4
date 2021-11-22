module rbot;

import ini;
import dlq;
import matrix;
import matrixwrapper : WMatrixMessage = MatrixMessage;

import std.array;
import std.stdio;
import std.format : format;
import std.string;
import std.algorithm;
import std.functional;

public import botcommands;
public import matrixwrapper;

class RBot
{
	static RBot current;

	MatrixClient matrix;
	IniFile config;

	string commandPrefix, owner;

	public this()
	{
		current = this;

		writeln("Starting RBot");

		config = new IniFile("config.ini");

		string homeserver = config["login"]["server"];
		if (config["connection"]["usehttp"])
			homeserver = "http://" ~ homeserver;
		else
			homeserver = "https://" ~ homeserver;

		owner = config["bot"]["owner"];

		matrix = new MatrixClient(homeserver);
		matrix.passwordLogin(config["login"]["name"], config["login"]["password"]);
		commandPrefix = config["commands"]["prefix"];

		writeln("Logged in as %s".format(matrix.userId));

		// Initial sync
		writeln("Preforming initial sync");
		matrix.inviteDelegate = (&onInvite).toDelegate();
		matrix.sync();
		writeln("Initial sync complete, processing events");
	}

	void runLoop()
	{
		matrix.eventDelegate = (&onEvent).toDelegate();
		while (1)
		{
			matrix.sync();
		}
	}

	void onInvite(string roomid, string userid)
	{
		writeln("Invited to room %s by %s".format(roomid, userid));
		//matrix.joinRoom(roomid);

		//matrix.sendHTML(roomid, "Hello world! I was invited by <b>%s</b>".format(userid));
	}

	void onEvent(MatrixEvent e)
	{
		if (MatrixTextMessage txt = cast(MatrixTextMessage) e)
		{
			handleCommand(txt);
		}
	}

	void handleCommand(MatrixTextMessage msg)
	{
		// Bots should respond with m.notice, ignore them
		if (msg.msgtype != "m.text")
			return;

		string content = msg.content;

		if (!content.startsWith(commandPrefix))
			return;

		matrix.markRead(msg.roomId, msg.eventId);

		content = content[commandPrefix.length .. $];
		string[] args = strexp(content);
		string cmdname = args.front;
		args = args[1 .. $];

		writeln("%s executing command '%s' with args %s".format(msg.sender, cmdname, args));

		// Search for commands
		CommandInfo cmd;
		if (cmdname.toLower in registeredCommands)
			cmd = registeredCommands[cmdname.toLower];
		else
		{
			// Search using alias
			cmd = registeredCommands.values.firstOrDefault!(v=>v.aliases.contains(cmdname.toLower));
		}

		if (!cmd)
		{
			matrix.sendString(msg.roomId, "Command '%s' not found.".format(cmdname));
			return;
		}

		CommandContext ctx = new CommandContext();
		ctx.message = new WMatrixMessage(matrix, msg);
		ctx.author = new MatrixUser(matrix, msg.sender);

		if (cmd.requireOwner && !ctx.author.isOwner)
		{
			ctx.message.reply("You must be the bot owner to use this command.");
			return;
		}

		ctx.args = args;
		ctx.rawArgs = content[cmdname.length .. $].strip();

		cmd.overloads.front().execute(ctx);
		// Check overloads
	}
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
