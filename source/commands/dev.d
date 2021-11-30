module commands.dev;

import botcommands;
import d2sqlite3;
import database;
import std.conv;
import html;
import rbot : Color;

class DevCommands
{
	mixin RegisterCommands;
static:
@RequireOwner:

	@Command("SQL", "Execute a SQL query")
	void SQL(CommandContext ctx)
	{
		ctx.message.replyHtml(
			"Executing <code class=\"language-sql\">" ~ ctx.rawArgs ~ "</code>...",
			"Executing " ~ ctx.rawArgs ~ "...");

		Statement statement = db.prepare(ctx.rawArgs);
		ResultRange results = statement.execute();

		import std.stdio;
		if (results.empty)
		{
			ctx.message.reply("No result");
			return;
		}

		Row row = results.front();
		string[] columns;
		for (int i = 0; i < row.length; i++)
			columns ~= row.columnName(i);

		TableBuilder tb = new TableBuilder();
		tb.addHeader(columns);
		foreach (r; results)
		{
			string[] cells;
			for(int i=0; i<r.length; i++)
				cells ~= r[i].as!string;
			tb.addRow(cells);
		}

		ctx.message.replyHtml(tb.toString, null);
	}

	@Command("Tables", "List all SQL tables")
	void tables(CommandContext ctx)
	{
		ctx.rawArgs = "SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%'ORDER BY 1;";
		SQL(ctx);
	}

	@Command("RainbowTest", "Tests html.rainbow()")
	void rainbowTest(CommandContext ctx)
	{
		string msg = ctx.rawArgs;
		ctx.message.replyHtml(rainbow(msg, 1, 360f / msg.length), msg);
	}

	@Command("Exception", "Throw an exception", ["ex","throw"])
	void throwEx(CommandContext ctx)
	{
		throw new Exception("Exception test");
	}

	@Command("ArgTest", "Tests arguments")
	void argTest(CommandContext ctx, int number)
	{
		ctx.message.reply(number.to!string);
	}
}
