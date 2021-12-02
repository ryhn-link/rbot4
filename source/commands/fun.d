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
		float size = normalRandom(cast(int) ctx.author.username.length, 13, 1.75);
		ctx.message.reply(ctx.author.toString ~ "'s pp size is %.1f cm".format(size));
	}

	//@Command("pp")
	void PP(CommandContext ctx)
	{
		PP(ctx, ctx.author.username);
	}

	double normalRandom(int seed, double mean, double stddev)
	{
		bool polarTransform(double a, double b, out double x, out double y)
		{
			auto v1 = (2.0 * a) - 1.0;
			auto v2 = (2.0 * b) - 1.0;
			auto r = (v1 * v1) + (v2 * v2);
			if (r >= 1.0 || r == 0.0)
			{
				x = 0;
				y = 0;
				return false;
			}

			import std.math;

			auto fac = sqrt(-2.0 * log(r) / r);
			x = v1 * fac;
			y = v2 * fac;
			return true;
		}

		import std.random;

		Random next(Random r)
		{
			r.popFront();
			return r;
		}

		double x, placeholder;
		auto rand = Random(seed);
		
		while (!polarTransform(uniform(0.0, 1.0, next(rand)), uniform(0.0, 1.0, next(rand)), x, placeholder))
		{
		}

		return mean + (stddev * x);
	}
}
