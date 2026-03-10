extends Node
class_name UtilityScorer

## Utility-Based AI Scoring System
## Author: Mykasia Simpkins
## Evaluates context and scores each possible NPC action

func evaluate(context: Dictionary) -> Dictionary:
	return {
		"Idle":   _score_idle(context),
		"Patrol": _score_patrol(context),
		"Chase":  _score_chase(context),
		"Attack": _score_attack(context),
		"Flee":   _score_flee(context)
	}

func _score_idle(ctx: Dictionary) -> float:
	if ctx.has_target:
		return 0.0
	return 0.3

func _score_patrol(ctx: Dictionary) -> float:
	if ctx.has_target:
		return 0.1
	return 0.7

func _score_chase(ctx: Dictionary) -> float:
	if not ctx.has_target:
		return 0.0
	var dist = ctx.get("distance_to_target", INF)
	if dist > 50.0:
		return clamp(1.0 - (dist / 500.0), 0.0, 1.0)
	return 0.0

func _score_attack(ctx: Dictionary) -> float:
	if not ctx.has_target:
		return 0.0
	var dist = ctx.get("distance_to_target", INF)
	return 1.0 if dist <= 50.0 else 0.0

func _score_flee(ctx: Dictionary) -> float:
	var health = ctx.get("health", 1.0)
	if health < 0.25:
		return 0.95
	return 0.0
