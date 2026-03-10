extends Node
class_name StateMachine

## Finite State Machine Base
## Author: Mykasia Simpkins

var current_state: Node = null
var current_state_name: String = ""
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is BaseState:
			states[child.name] = child
			child.state_machine = self

func change_state(state_name: String) -> void:
	if not states.has(state_name):
		push_error("State '%s' not found in StateMachine" % state_name)
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state_name = state_name
	current_state.enter()

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)
