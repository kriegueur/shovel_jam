extends Resource
class_name ItemEffect

enum EffectType {
	ATTACK,
	MAXHP,
	MAXMANA,
	SPEED,
	DASHCOOLDOWN,
	DASHDURATION,
	SHIELD,
	PARRYCOOLDOWN,
}

@export var type : EffectType
@export var value : float
