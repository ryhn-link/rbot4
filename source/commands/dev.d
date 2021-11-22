module commands.dev;

import botcommands;
import database;
import d2sqlite3;

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

		if (results.empty)
		{
			ctx.message.reply("No result");
			return;
		}

		Row row = results.front();
		string[] columns;
		for (int i = 0; i < row.length; i++)
			columns ~= row.columnName(i);

		string html = "<table>";
		html ~= "<tr>";
		foreach (h; columns)
			html ~= "<th>" ~ h ~ "</th>";
		html ~= "</tr>";

		foreach (r; results)
		{
			html ~= "<tr>";
			for(int i=0; i<r.length; i++)
			{
				html ~= "<td>" ~ r[i].as!string ~ "</td>";
			}
			html ~= "</tr>";
		}

		ctx.message.replyHtml(html,null);
	}
}
