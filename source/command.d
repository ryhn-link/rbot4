module command;
import dlq;

mixin template RegisterCommands()
{
	static this()
	{
		import std.stdio;

		//writeln("Adding " ~ __traits(identifier, typeof(this)) ~ " to command list");

		static foreach (M; __traits(allMembers, typeof(this)))
		{
			static foreach (attr; __traits(getAttributes, M))
			{
				static if (typeof(attr) == CommandInfo)
				{

				}
			}
		}
	}
}

Command[string] commands;

struct Command
{
	string name;
	CommandOverload[] overloads;
}

struct CommandOverload
{

}

struct CommandInfo
{
	string name;
}

class CommandContext
{

}
