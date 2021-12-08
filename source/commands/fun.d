module commands.fun;
import botcommands;
import std.conv;
import std.format;

class FunCommands
{
	mixin RegisterCommands;
static:

	@Command("pp")
	void PP(CommandContext ctx, string user)
	{
		float size = normalRandom(cast(int) user.length, 13, 1.75);
		ctx.message.reply(user ~ "'s pp size is %.1f cm".format(size));
	}

	//@Command("pp")
	void PP(CommandContext ctx)
	{
		PP(ctx, ctx.author.username);
	}

	double normalRandom(int seed, double mean, double stddev)
	{
		import std.mathspecial;
		import std.random;
		auto rand = Random(seed);
		double x = normalDistribution(uniform(0.0,1.0,rand));

		return x;
	}
}
