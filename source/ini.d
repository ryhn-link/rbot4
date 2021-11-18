module ini;

import inilike;

class IniFile
{
	IniLikeFile inilike;
	this(string filename)
	{
		inilike = new IniLikeFile(filename);
	}

	IniGroup opIndex(string index)
	{
		return new IniGroup(inilike.getNode(index).group);
	}
}

class IniGroup
{
	IniLikeGroup inilike;
	this(IniLikeGroup ilg)
	{
		inilike = ilg;
	}

	string opIndex(string index)
	{
		return inilike.escapedValue(index);
	}
}
