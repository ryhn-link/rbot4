module database;

import d2sqlite3;

Database db;

static this()
{
	db = Database("rbot.db");
}