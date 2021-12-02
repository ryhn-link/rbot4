module botcommands;
import rbot;

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
							cmd = registeredCommands[cmda.name.toLower];
						else
						{
							cmd = new CommandInfo();
							cmd.name = cmda.name;
							registeredCommands[cmd.name.toLower] = cmd;
						}

						if(hasUDA!(OV, RequireOwner))
							cmd.requireOwner = true;
						
						// Append any aliases
						cmd.aliases ~= cmda.aliases.select!(a => a.toLower, string);
						if(cmda.aliases)
							cmd.aliases = cmd.aliases.distinct;

						if(!cmd.description)
							cmd.description = cmda.description;

						// Register overload
						CommandOverload ovl = new CommandOverload();
						ovl.paramNames = [ParameterIdentifierTuple!OV];
						alias PARAMS = ParameterTypeTuple!OV;
						alias DEFAULTS = ParameterDefaultValueTuple!OV;

						mixin("bool execute"~M~"(CommandContext ctx)
						{
							PARAMS params;

							foreach (i, P; PARAMS)
							{
								// First arg MUST ALWAYS be a command context
								static if(i == 0)
								{
									params[i] = ctx;
								}
								else
								{
									import std.conv;
									static if(P.stringof  == \"string\")
										params[i] = ctx.args[i-1];
									else params[i] = ctx.args[i-1].to!(P);
								}
							}
							OV(params);
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

// Require owner UDA
struct RequireOwner
{ }

class CommandInfo
{
	string name, description;
	string[] aliases;
	CommandOverload[] overloads;
	bool requireOwner;
}

class CommandOverload
{
	string[] paramNames;
	string[] paramTypes;
	void[] defaultValues;

	
	bool delegate(CommandContext) execute;
}

class CommandContext
{
	MatrixMessage message;
	MatrixUser author;
	string[] args;
	string rawArgs;
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