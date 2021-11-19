module commands.help;
import botcommands;

class HelpCommand
{
	mixin RegisterCommands;
static:
	@Command("help", "Show help")
	void Help(CommandContext ctx)
	{
		import std.stdio;
		writeln("Showing help...");
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
