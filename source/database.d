module database;

import d2sqlite3;

__gshared Database db;

static this()
{
	db = Database("rbot.db");
}