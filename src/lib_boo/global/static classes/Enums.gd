class_name Enums extends RefCounted

enum ParentMode {
	SELF,
	SCENE_ROOT,
	MANUAL,
	GROUP_FIRST,
	##Both below require World to be in "world" group and to have references to appropriate child Node2Ds.
	WORLD_BACKGROUND,
	WORLD_MAIN, 
	WORLD_FOREGROUND
}
