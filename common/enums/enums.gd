extends Resource
class_name Enums

class Terrain:
	# NOTE: Terrains that can only be specified via the Foreground or above must always
	# have a larger integer value than the largest terrain type specified via
	# the Background.
	enum Type
	{
		Null      = -1,
		Plains    =  0,
		Water     =  1,
		Road      =  2,
		Mountain  =  3,
		Forest    =  4,
		Building  =  5,
	}

class Unit:
	enum Type
	{
		Null              = -1,
		Mech              =  0,
		Infantry          =  1,
		Submarine         =  2,
		Cruiser           =  3,
		Lander            =  4,
		TransportCopter   =  5,
		BattleCopter      =  6,
		Bomber            =  7,
		AntiAir           =  8,
		Tank              =  9,
		APC               = 10,
		CargoTruckFull    = 11,
		CargoTruckEmpty   = 12
	}

class Flag:
	enum Colour
	{
		Null   = -1,
		Gray   =  0,
		Green  =  1,
		Blue   =  2,
		Red    =  3,
		Orange =  4
	}
