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

						if (hasUDA!(OV, RequireOwner))
							cmd.requireOwner = true;

						// Append any aliases
						cmd.aliases ~= cmda.aliases.select!(a => a.toLower, string);
						if (cmda.aliases)
							cmd.aliases = cmd.aliases.distinct;

						if (!cmd.description)
							cmd.description = cmda.description;

						// Register overload
						CommandOverload ovl = new CommandOverload();
						alias PARAMS = ParameterTypeTuple!OV;
						alias DEFAULTS = ParameterDefaultValueTuple!OV;
						ovl.paramNames = [ParameterIdentifierTuple!OV];
						static foreach (d; DEFAULTS)
						{
							static if (!is(d == void))
							{
								ovl.defaultValues ~= d.to!string;
							}
						}

						bool execute(CommandContext ctx)
						{
							PARAMS params = void;
							int paramc = PARAMS.length - 1;
							int defaultc = cast(int) ovl.defaultValues.length;
							int minparamsc = paramc - defaultc;
							if (ctx.args.length < minparamsc)
								throw new RBotCommandArgumentException(
									"Not enough command parameters");

							foreach (i, P; PARAMS)
							{
								// First arg MUST ALWAYS be a command context
								static if (i == 0)
								{
									params[i] = ctx;
								}
								else
								{
									if (i < ctx.args.length - 1)
									{
										static if (!is(DEFAULTS[i] == void))
											params[i] = (DEFAULTS[i]);
									}
									else
									{
										import std.conv;

										try
										{
											static if (P.stringof == "string")
												params[i] = ctx.args[i - 1];
											else
												params[i] = parseArgument!(P)(ctx, ctx.args[i - 1]);
										}
										catch(Exception e)
										{
											throw new RBotCommandArgumentException("Failed parsing argument '%s'".format(ovl.paramNames[i]));
										}
									}
								}
							}
							OV(params);
							return true;
						}

						import std.functional;

						ovl.execute = (&(execute)).toDelegate;
						cmd.overloads ~= ovl;
					}
				}
			}
		}
	}
}

CommandInfo[string] registeredCommands;

CommandInfo findCommand(string idOrAlias)
{
	import dlq;
	import std.string;

 	idOrAlias = idOrAlias.toLower;
	CommandInfo cmd = null;

	if(idOrAlias in registeredCommands)
		cmd = registeredCommands[idOrAlias];
	else cmd = registeredCommands.values.firstOrDefault!(
		v => v.aliases.contains(idOrAlias));

	return cmd;
}

/// Command UDA
struct Command
{
	string name, description;
	string[] aliases;
}

// Require owner UDA
struct RequireOwner
{
}

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
	string[] defaultValues;

	bool delegate(CommandContext) execute;
}

class CommandContext
{
	import matrix;
	RBotMessage message;
	RBotUser author;
	MatrixClient client;
	string[] args;
	string rawArgs;
}

T parseArgument(T)(CommandContext ctx, string s)
{
	static if (is(T == class) && "cmdParse" in __traits(allMembers, T))
	{
		T.cmdParse(ctx, s);
	}
	else
	{
		import std.conv;

		return s.to!T;
	}
}

class RBotCommandArgumentException : Exception
{
	public this(string s)
	{
		super(s);
	}
}