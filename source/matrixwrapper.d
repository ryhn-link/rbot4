module matrixwrapper;

import matrix;
import std.string;

class MatrixMessage
{
private:
	MatrixClient c;
	MatrixTextMessage msg;

public:
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

class MatrixUser
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
}