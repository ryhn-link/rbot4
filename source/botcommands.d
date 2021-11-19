module botcommands;

mixin template RegisterCommands()
{
	static this()
	{
		import std.traits;
		import std.stdio;
		import std.string;
		import dlq;

		alias T = typeof(this);
		alias members = __traits(allMembers, T);
		// Check all the methods 
		foreach (M; members)
		{
			static foreach (OV; __traits(getOverloads, T, M, true))
			{
				{
					// Check if the method is a command
					static if (hasUDA!(OV, Command))
					{
						// Get the Command UDA
						Command cmda;
						foreach (uda; __traits(getAttributes, OV))
						{
							static if (is(typeof(uda) == Command))
							{
								cmda = uda;
								break;
							}
						}

						// Default to method's name for command name if no command specified in UDA
						if (!cmda.name)
							cmda.name = M.toLower;

						// Register the command if not found
						CommandInfo cmd;
						if (cmda.name in registeredCommands)
							cmd = registeredCommands[cmda.name];
						else
						{
							cmd = new CommandInfo();
							cmd.name = cmda.name;
							registeredCommands[cmd.name] = cmd;
						}
						
						// Append any aliases
						cmd.aliases ~= cmda.aliases;
						if(cmda.aliases)
							cmd.aliases = cmd.aliases.distinct;

						// Register overload
						CommandOverload ovl = new CommandOverload();
						ovl.paramNames = [ParameterIdentifierTuple!OV];
						alias params = ParameterTypeTuple!OV;
						alias defaults = ParameterDefaultValueTuple!OV;

						pragma(msg, M);
						mixin("bool execute"~M~"(CommandContext ctx, string[] args)
						{
							try
							{
								OV(ctx);
							}
							catch (Exception e) {}

							return true;
						}");
						

						import std.functional;
						ovl.execute = (&(mixin("execute"~M))).toDelegate;
						cmd.overloads ~= ovl;
					}
				}
			}
		}
	}
}

CommandInfo[string] registeredCommands;

/// Command UDA
struct Command
{
	string name, description;
	string[] aliases;
}

class CommandInfo
{
	string name;
	string[] aliases;
	CommandOverload[] overloads;
}

class CommandOverload
{
	string[] paramNames;
	string[] paramTypes;
	void[] defaultValues;

	
	bool delegate(CommandContext, string[]) execute;
}

class CommandContext
{

}

T parseArgument(T)(CommandContext ctx, string s)
{
	static if("cmdParse" in __traits(allMembers, T))
	{
		T.cmdParse(ctx, s);
	}
	else
	{
		import std.conv;
		return s.to!T;
	}
}