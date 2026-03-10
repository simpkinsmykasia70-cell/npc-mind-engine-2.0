extends CharacterBody2D

## NPC Mind Engine - Main Controller
## Author: Mykasia Simpkins
## GitHub: https://github.com/simpkinsmykasia70-cell

@export var move_speed: float = 120.0
@export var detection_range: float = 250.0
@export var attack_range: float = 50.0
@export var patrol_points: Array[Vector2] = []

var state_machine: StateMachine
var utility_scorer: UtilityScorer
var vision: VisionComponent
var target: Node2D = null

signal npc_state_changed(new_state: String)
signal npc_detected_player(player: Node2D)
signal npc_lost_player()

func _ready() -> void:
	state_machine = $StateMachine
	utility_scorer = $UtilityScorer
	vision = $VisionComponent
	
	vision.target_detected.connect(_on_target_detected)
	vision.target_lost.connect(_on_target_lost)
	
	state_machine.change_state("Idle")

func _physics_process(delta: float) -> void:
	state_machine.update(delta)
	_evaluate_utility()
	move_and_slide()

func _evaluate_utility() -> void:
	## Utility AI: score each possible action and pick the best
	var scores = utility_scorer.evaluate({
		"health": get_health_percent(),
		"distance_to_target": _get_target_distance(),
		"has_target": target != null
	})
	
	var best_action = scores.keys()[0]
	for action in scores:
		if scores[action] > scores[best_action]:
			best_action = action
	
	if best_action != state_machine.current_state_name:
		state_machine.change_state(best_action)
		npc_state_changed.emit(best_action)

func _get_target_distance() -> float:
	if target == null:
		return INF
	return global_position.distance_to(target.global_position)

func get_health_percent() -> float:
	## Override in subclass or connect to health component
	return 1.0

func _on_target_detected(body: Node2D) -> void:
	target = body
	npc_detected_player.emit(body)

func _on_target_lost() -> void:
	target = null
	npc_lost_player.emit()
	state_machine.change_state("Patrol")
