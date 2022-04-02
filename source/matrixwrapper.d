module matrixwrapper;

import matrix;
import std.string;

class RBotMessage
{
private:
	MatrixClient c;

public:
	MatrixTextMessage msg;
	this(MatrixClient c, MatrixTextMessage msg)
	{
		this.c = c;
		this.msg = msg;
	}

	void reply(string text)
	{
		c.sendString(msg.roomId, text);
	}

	void replyHtml(string html, string fallback)
	{
		c.sendHTML(msg.roomId, html, fallback);
	}
}

class RBotUser
{
private:
	MatrixClient c;
	string userId;
public:
	this(MatrixClient c, string userId)
	{
		this.c = c;
		this.userId = userId;
	}

	@property string username()
	{
		return userId.split(":")[0][1 .. $];
	}

	@property string homeServer()
	{
		return userId.split(":")[1];
	}

	@property string fullUsername()
	{
		return userId;
	}

	bool isOwner()
	{
		import rbot;
		return userId == RBot.current.owner;
	}

	override string toString()
	{
		return userId;
	}

	import botcommands;
	RBotUser cmdParse(CommandContext ctx, string str)
	{
		import std.regex;
		auto r = ctRegex!(r"\@.*:.*\..*");
		if(matchFirst(str, r).empty)
			throw new Exception("User does not match the @user:domain.example format");
		return new RBotUser(ctx.client, str);
	}
}