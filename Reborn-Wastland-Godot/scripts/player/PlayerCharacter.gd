extends CharacterBody3D
class_name PlayerCharacter

## Player Character - Main player controller with survival mechanics

@export var mouse_sensitivity: float = 0.003
@export var move_speed: float = 7.0
@export var sprint_speed: float = 12.0

var camera: Camera3D
var head: Node3D
var is_sprinting: bool = false

# Survival stats
var health: float = 100.0
var hunger: float = 50.0
var thirst: float = 50.0
var fatigue: float = 0.0
var infection: float = 0.0
var temperature: float = 20.0

# Inventory
var inventory: Dictionary = {}
var max_inventory_weight: float = 50.0

# Mutations
var mutations: Array = []
var mutation_level: float = 0.0

# References
var game_manager: GameManager
var mutation_system: MutationSystem
var weather_system: WeatherSystem

# Network
var player_id: int = 0

func _ready():
	set_multiplayer_authority(multiplayer.get_unique_id())
	player_id = multiplayer.get_unique_id()
	
	# Setup camera
	camera = Camera3D.new()
	add_child(camera)
	camera.global_position = global_position + Vector3(0, 1.6, 0)
	
	# Setup head (for bobbing effect)
	head = Node3D.new()
	add_child(head)
	head.add_child(camera)
	
	# Get managers
	game_manager = get_tree().root.get_node_or_null("GameManager")
	if game_manager:
		mutation_system = game_manager.mutation_system
		weather_system = game_manager.weather_system
	
	# Lock mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if is_multiplayer_authority():
		print("Player initialized: %d" % player_id)

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	_handle_input()
	_update_survival_stats(delta)
	_apply_weather_effects(delta)
	_sync_position(delta)
	
	move_and_slide()

func _handle_input():
	"""Handle player input"""
	var input_vector = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_w"):
		input_vector.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_s"):
		input_vector.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_a"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_d"):
		input_vector.x += 1
	
	input_vector = input_vector.normalized()
	
	# Sprint
	is_sprinting = Input.is_action_pressed("ui_shift")
	var current_speed = sprint_speed if is_sprinting else move_speed
	
	# Apply mutations
	current_speed *= 1.0 + mutation_system.get_mutation_benefit(player_id, "movement_speed") if mutation_system else 1.0
	
	velocity = input_vector * current_speed
	
	# Mouse look
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_motion = Input.get_last_mouse_velocity()
		head.rotation.y -= mouse_motion.x * mouse_sensitivity
		camera.rotation.x -= mouse_motion.y * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _update_survival_stats(delta):
	"""Update player survival statistics"""
	if not game_manager:
		return
	
	var hunger_rate = 1.0 / 300.0 if not is_sprinting else 2.0 / 300.0
	hunger += hunger_rate * delta
	
	var thirst_rate = 1.0 / 200.0 if not is_sprinting else 2.0 / 200.0
	if game_manager.current_season == "summer":
		thirst_rate *= 2.0
	thirst += thirst_rate * delta
	
	fatigue += (0.5 if is_sprinting else 0.1) * delta
	
	# Check death
	if health <= 0:
		_die()
	
	# Apply stat effects
	if hunger >= 100.0 or thirst >= 100.0:
		take_damage(1.0 * delta)
	
	if fatigue >= 100.0:
		take_damage(0.5 * delta)

func _apply_weather_effects(delta):
	"""Apply environmental damage"""
	if not weather_system:
		return
	
	weather_system.apply_weather_effects(self, delta)

func take_damage(amount: float):
	"""Take damage"""
	health = max(0, health - amount)
	if is_multiplayer_authority():
		sync_stats.rpc()

func add_item(item_name: String, quantity: int = 1):
	"""Add item to inventory"""
	if item_name in inventory:
		inventory[item_name] += quantity
	else:
		inventory[item_name] = quantity
	
	if is_multiplayer_authority():
		sync_inventory.rpc()

func _die():
	"""Handle player death"""
	print("Player died!")
	if is_multiplayer_authority():
		mark_death_location.rpc()
		queue_free()

func mark_death_location():
	"""Mark death location for other players"""
	# Create spectre mark in game world
	pass

var sync_timer: float = 0.0
func _sync_position(delta):
	"""Sync position to other players"""
	sync_timer += delta
	if sync_timer >= 0.1:
		sync_timer = 0.0
		if is_multiplayer_authority():
			update_position.rpc_id(1, global_position, rotation)

@rpc("authority")
func update_position(pos: Vector3, rot: Vector3):
	"""Receive position update"""
	global_position = pos
	rotation = rot

@rpc("authority")
func sync_stats():
	"""Sync survival stats"""
	rpc("receive_stats", health, hunger, thirst, fatigue)

@rpc
func receive_stats(h: float, hu: float, t: float, f: float):
	"""Receive stat update"""
	health = h
	hunger = hu
	thirst = t
	fatigue = f

@rpc("authority")
func sync_inventory():
	"""Sync inventory"""
	rpc("receive_inventory", inventory)

@rpc
func receive_inventory(inv: Dictionary):
	"""Receive inventory update"""
	inventory = inv
