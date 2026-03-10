extends Node2D
class_name VisionComponent

## Line-of-Sight Detection Component
## Author: Mykasia Simpkins

@export var detection_range: float = 250.0
@export var fov_angle: float = 90.0
@export var target_group: String = "player"

signal target_detected(body: Node2D)
signal target_lost()

var _current_target: Node2D = null
var _has_target: bool = false

func _physics_process(_delta: float) -> void:
	_scan_for_targets()

func _scan_for_targets() -> void:
	var space = get_world_2d().direct_space_state
	var bodies = get_tree().get_nodes_in_group(target_group)
	
	for body in bodies:
		var dist = global_position.distance_to(body.global_position)
		if dist > detection_range:
			continue
		
		# Check field of view angle
		var dir_to_body = (body.global_position - global_position).normalized()
		var forward = Vector2.RIGHT.rotated(get_parent().rotation)
		var angle = rad_to_deg(forward.angle_to(dir_to_body))
		
		if abs(angle) > fov_angle / 2.0:
			continue
		
		# Raycast for line of sight
		var query = PhysicsRayQueryParameters2D.create(
			global_position, body.global_position, 0b11, [get_parent()]
		)
		var result = space.intersect_ray(query)
		
		if result and result.collider == body:
			if not _has_target:
				_has_target = true
				_current_target = body
				target_detected.emit(body)
			return
	
	if _has_target:
		_has_target = false
		_current_target = null
		target_lost.emit()
