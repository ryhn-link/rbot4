module commands.fun;
import botcommands;

class FunCommands
{
	mixin RegisterCommands;
	static:
	
	@Command("pp")
	void PP(CommandContext ctx)
	{
		import std.conv;
		float size = normalRandom(cast(int)ctx.author.username.length, 13, 1.75);
		ctx.message.reply(ctx.author.toString ~ "'s pp size is " ~ size.to!string ~ " cm");	
	}

	double normalRandom(int seed, double mean, double stddev)
	{
		return seed;
	}
}