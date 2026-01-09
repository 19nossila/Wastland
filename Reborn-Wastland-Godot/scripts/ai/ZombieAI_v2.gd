extends CharacterBody3D
class_name ZombieAI_v2

## Zombie AI with asset integration

@export var max_health: float = 30.0
@export var move_speed: float = 4.0
@export var chase_speed: float = 6.0
@export var detection_range: float = 20.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.5

var health: float
var target: Node3D
var is_chasing: bool = false
var velocity: Vector3 = Vector3.ZERO
var gravity: float = 9.8
var last_attack_time: float = 0.0

# Asset system
var asset_importer: AssetImporter
var zombie_model: Node3D
var animation_player: AnimationPlayer

# AI variables
var patrol_timer: float = 0.0
var patrol_points: Array = []
var current_patrol_index: int = 0

func _ready():
	health = max_health
	asset_importer = AssetImporter.new()
	add_child(asset_importer)
	
	# Load zombie model
	_load_zombie_model()
	
	# Get animation player
	animation_player = $AnimationPlayer if has_node("AnimationPlayer") else null
	
	# Setup patrol points around spawn
	_setup_patrol_points()
	
	# Setup detection
	_setup_detection()

## Load zombie model from assets
func _load_zombie_model() -> void:
	var models = asset_importer.get_character_models()
	if models.size() > 0:
		# Get the characterMedium model which works for zombies
		for model_path in models:
			if "characterMedium" in model_path or "zombie" in model_path.to_lower():
				zombie_model = asset_importer.import_model(model_path)
				if zombie_model:
					add_child(zombie_model)
					zombie_model.position = Vector3(0, 0, 0)
					print("✅ Zombie model loaded")
					return
		
		# Fallback to first model
		zombie_model = asset_importer.import_model(models[0])
		if zombie_model:
			add_child(zombie_model)

## Setup detection area
func _setup_detection() -> void:
	if not has_node("DetectionArea"):
		var detection_area = Area3D.new()
		detection_area.name = "DetectionArea"
		add_child(detection_area)
		
		var shape = SphereShape3D.new()
		shape.radius = detection_range
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = shape
		detection_area.add_child(collision_shape)
		
		detection_area.area_entered.connect(_on_detection_area_entered)

## Setup patrol points
func _setup_patrol_points() -> void:
	var base_pos = global_position
	patrol_points = [
		base_pos,
		base_pos + Vector3(5, 0, 0),
		base_pos + Vector3(5, 0, 5),
		base_pos + Vector3(0, 0, 5),
	]

func _physics_process(delta):
	# Apply gravity
	velocity.y -= gravity * delta
	
	if target and is_instance_valid(target):
		var distance = global_position.distance_to(target.global_position)
		
		# Check if can attack
		if distance < attack_range:
			if Time.get_ticks_msec() - last_attack_time > attack_cooldown * 1000:
				_attack_target()
				last_attack_time = Time.get_ticks_msec()
		
		# Chase target
		if distance > attack_range:
			_chase_target(delta)
			is_chasing = true
			_play_animation("run")
	else:
		# Patrol
		is_chasing = false
		_patrol(delta)
		_play_animation("idle")
	
	# Move
	velocity = move_and_slide(velocity)

## Chase target
func _chase_target(delta: float) -> void:
	var direction = (target.global_position - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * chase_speed
	velocity.z = direction.z * chase_speed
	
	# Look at target
	look_at(target.global_position, Vector3.UP)

## Attack target
func _attack_target() -> void:
	if target and is_instance_valid(target) and "take_damage" in target:
		target.take_damage(10.0, "infection")
		_play_animation("attack")
		print("💀 Zombie attacking player!")

## Patrol around spawn point
func _patrol(delta: float) -> void:
	patrol_timer += delta
	
	if patrol_timer > 2.0:  # Move every 2 seconds
		patrol_timer = 0.0
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	
	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	# Slowly rotate towards patrol point
	var target_angle = atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, 0.05)

## Play animation
func _play_animation(anim_name: String) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)

## Detection area entered
func _on_detection_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		target = area.get_parent()
		print("🎯 Zombie detected player!")

## Take damage
func take_damage(amount: float) -> void:
	health -= amount
	print("💢 Zombie hit! Health: %.1f" % health)
	
	if health <= 0:
		die()

## Die
func die() -> void:
	print("☠️ Zombie died!")
	queue_free()

## Infect player
func infect_player() -> void:
	if target and "infection" in target:
		target.infection += 10.0
