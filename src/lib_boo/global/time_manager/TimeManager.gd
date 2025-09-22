class_name TimeManager extends Node

const NORMAL_TIME_SCALE:float = 1.0
const BASELINE_SLOW_TIME_SCALE:float = 0.4


func ResetTimeScale():
	Engine.time_scale = NORMAL_TIME_SCALE
	print("NORMAL Time Scale on " + str(Engine.time_scale))

func ChangeTimeScale(new_scale:float):
	Engine.time_scale = new_scale
	
	if new_scale < 1.0:
		print("SLOWED Time Scale " + str(new_scale))
	elif new_scale > 1.0:
		print("HASTENED Time Scale to " + str(new_scale))
	else:
		print("NORMAL Time Scale on " + str(Engine.time_scale))
