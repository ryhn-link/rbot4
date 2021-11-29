module html;
import std.string;
import std.format;
import std.typecons;
import rbot : Color;

string escapeHtml(string s)
{
	return s.translate([
		'&': "&amp;",
		'<': "&lt;",
		'>': "&gt;",
		'"': "&quot;",
		'\'': "&#39;"
	]);
}

string bold(string str)
{
	return "<b>" ~ str ~ "</b>";
}

string italics(string str)
{
	return "<i>" ~ str ~ "</i>";
}

string underline(string str)
{
	return "<u>" ~ str ~ "</u>";
}

string strikethrough(string str)
{
	return "<strike>" ~ str ~ "</strike>";
}

string link(string str, string url)
{
	return "<a href=\"%s\">%s</a>".format(url, str);
}

string image(string mxc, int w = -1, int h = -1)
{
	return "<img src=\"%s\" width=\"%d\" height=\"%d\"/>".format(mxc, w, h);
}

string font(string str, Color color, Nullable!Color bgcolor = Nullable!Color())
{
	string html = "<font color=\"%s\"".format(color.toHex);
	if (!bgcolor.isNull)
		html ~= " bgcolor=\"%s\"".format(bgcolor.get.toHex);
	html ~= ">";

	return html ~ str ~ "</font>";
}

string spoiler(string str)
{
	return "<span data-mx-spoiler" ~ str ~ "</span>";
}

string ul(string[] items)
{
	string html = "<ul>";
	foreach (i; items)
		html ~= "<li>" ~ i ~ "</li>";
	html ~= "</ul>";

	return html;
}

string ol(string[] items, int start = 1)
{
	string html = "<ol start=\"%d\">".format(start);
	foreach (i; items)
		html ~= "<li>" ~ i ~ "</li>";
	html ~= "</ol>";

	return html;
}

string code(string code, string lang = null)
{
	string html = "<code";
	if (!(lang is null))
		html ~= " lang=\"language-%s\"".format(lang);
	html ~= ">";

	return html ~ code ~ "</code>";
}

string sup(string str)
{
	return "<sup>" ~ str ~ "</sup>";
}

string sub(string str)
{
	return "<sub>" ~ str ~ "</sub>";
}

string h(string str, int level = 1)
{
	return "<h%d>%s</h%d>".format(level, str, level);
}

string hr()
{
	return "<hr/>";
}

string br()
{
	return "<br/>";
}

string details(string details, string summary)
{
	return "<details><summary>%s</summary>%s</details>".format(summary, details);
}

string rainbow(string str, int step = 2, float hueOffset = 1)
{
	string html = "";
	float hue = 0;

	for (int i = 0; i < str.length; i += step)
	{
		import std.algorithm;
		string substr = str[i .. min(i + step, str.length-1)];
		html ~= font(substr, Color.fromHue(hue));
		import std.stdio;
		writeln(hue);
		hue = (hue + (hueOffset * step)) % 360;
	}

	return html;
}

class TableBuilder
{
	string html = "<table>";

	TableBuilder addHeader(string[] cells)
	{
		html ~= "<tr>";
		foreach (c; cells)
			html ~= "<th>" ~ c ~ "</th>";
		html ~= "</tr>";
		return this;
	}

	TableBuilder addRow(string[] cells)
	{
		html ~= "<tr>";
		foreach (c; cells)
			html ~= "<td>" ~ c ~ "</td>";
		html ~= "</tr>";
		return this;
	}

	override string toString()
	{
		return html ~ "</table>";
	}
}
