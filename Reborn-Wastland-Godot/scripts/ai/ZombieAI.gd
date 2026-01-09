extends CharacterBody3D
class_name ZombieAI

## Zombie AI - Intelligent zombie behavior with biome adaptation

@export var base_health: float = 50.0
@export var base_damage: float = 15.0
@export var base_speed: float = 10.0
@export var detection_range: float = 50.0
@export var attack_range: float = 2.0

var health: float
var damage: float
var speed: float
var biome: String = "urban"
var zombie_type: String = "runner"
var evolution_level: float = 0.0

var target: Node3D = null
var patrol_points: Array = []
var current_patrol_index: int = 0

# Mutations/Evolution
var mutations: Dictionary = {}

func _ready():
	health = base_health
	damage = base_damage
	speed = base_speed
	
	_apply_biome_stats()

func _physics_process(delta):
	_update_ai(delta)
	_apply_behavior(delta)
	move_and_slide()

func _update_ai(delta):
	"""Update AI logic"""
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		
		if distance <= attack_range:
			_attack(target)
		elif distance <= detection_range:
			_chase_target(target, delta)
		else:
			target = null
	
	if target == null:
		_patrol(delta)

func _apply_biome_stats():
	"""Apply biome-specific stat modifications"""
	match biome:
		"urban":
			zombie_type = "runner"
			speed *= 1.3
			health *= 1.0
		"forest":
			zombie_type = "mutant"
			speed *= 1.0
			health *= 1.6
		"desert":
			zombie_type = "drifter"
			speed *= 1.8
			health *= 0.6
		"mountain":
			zombie_type = "frozen"
			speed *= 0.5
			health *= 2.4
			damage *= 1.47  # 22/15

func _chase_target(target_node: Node3D, delta: float):
	"""Chase target with simple pathfinding"""
	var direction = (target_node.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Simple obstacle avoidance
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position + direction * 5)
	var result = space_state.intersect_ray(query)
	
	if result:
		# Obstacle ahead, try to pathfind around
		var perpendicular = direction.rotated(Vector3.UP, PI/4)
		velocity = perpendicular * speed

func _attack(target_node: Node3D):
	"""Attack target"""
	if target_node.has_method("take_damage"):
		target_node.take_damage(damage)

func _patrol(delta: float):
	"""Patrol behavior"""
	if patrol_points.is_empty():
		return
	
	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - global_position).normalized()
	
	if global_position.distance_to(target_point) < 2.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	
	velocity = direction * (speed * 0.5)

func _apply_behavior(delta):
	"""Apply behavior-specific logic"""
	match zombie_type:
		"runner":
			pass
		"mutant":
			if is_instance_valid(target):
				# Regenerate in combat
				health = min(base_health, health + 2.0 * delta)
		"drifter":
			# Speed boost in sand/desert
			speed = base_speed * 1.8
		"frozen":
			# Freeze aura
			pass

func take_damage(amount: float):
	"""Take damage"""
	health -= amount
	
	if health <= 0:
		_die()

func _die():
	"""Die and disappear"""
	queue_free()

func set_biome(new_biome: String):
	"""Set biome and apply mutations"""
	biome = new_biome
	_apply_biome_stats()

func set_patrol_points(points: Array):
	"""Set patrol route"""
	patrol_points = points
	current_patrol_index = 0

func evolve(increase: float):
	"""Evolve zombie"""
	evolution_level += increase
	base_health *= 1.05
	base_damage *= 1.02
	base_speed *= 1.01
