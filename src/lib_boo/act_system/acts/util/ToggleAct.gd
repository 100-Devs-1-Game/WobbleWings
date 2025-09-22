class_name ToggleAct extends NodeAct

enum Mode {
	ON,
	OFF,
	TOGGLE
}

@export var mode:Mode = Mode.TOGGLE ##NOTE: Will be overridden by params in Execute(params).
@export var affectsVisible:bool = true
@export var affectsButtonPressed:bool = false
@export var actors:Array[Node] = [null]

func Execute(params: Variant = null) -> Variant:
	for actor in actors:
		var target_mode = mode
		if params is bool:
			target_mode = Mode.ON if params else Mode.OFF
		
		match target_mode:
			Mode.ON:
				if affectsVisible: actor.show()
				if affectsButtonPressed and actor is Button: actor.button_pressed = true
			Mode.OFF:
				if affectsVisible: actor.hide()
				if affectsButtonPressed and actor is Button: actor.button_pressed = false
			Mode.TOGGLE:
				if affectsVisible: actor.visible = !actor.visible
				if affectsButtonPressed and actor is Button: actor.button_pressed = !actor.button_pressed
	return null
