module commands.help;
import botcommands;
import std.array : join;
import std.format : format;
import std.range : empty;

class HelpCommand
{
	mixin RegisterCommands;
static:
	@Command("help", "Show help",["?","commands"])
	void Help(CommandContext ctx)
	{
		string[] cmds = registeredCommands.keys;
		string str = "Available commands:";
		string fallback = str;
		foreach (cmdkey; cmds)
		{
			CommandInfo cmd = registeredCommands[cmdkey];

			string[] lines;
			if(!cmd.aliases.empty)
				lines ~= "Aliases: %s".format(cmd.aliases.join(","));
			if(cmd.description)
				lines ~= cmd.description;
			if(cmd.requireOwner)
				lines ~= "<font color=\"#ff0000\">Requires owner</font>";

			str ~= "<details>";
			str ~= "<summary>" ~ cmd.name ~ "</summary>";
			str ~= lines.join("<br>");
			str ~= "</details>";

			fallback ~= "\n⏵" ~ cmd.name;
			if(!cmd.aliases.empty)
				fallback ~= "\nAliases: %s".format(cmd.aliases.join(", "));
			if(cmd.description)
				fallback ~= "\n" ~ cmd.description;
			if(cmd.requireOwner)
				fallback ~= "\nRequires owner";
		}

		ctx.message.replyHtml(str, fallback);
	}

	/*
	@Command("help")
	void Help(CommandContext ctx, string cmdname)
	{
		if(!(cmdname in registeredCommands))
		{
			// Command not found
			return;
		}
		CommandInfo cmd = registeredCommands[cmdname];
*/
}
