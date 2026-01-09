extends CharacterBody3D
class_name PlayerCharacter

## Player Character - Main player controller with survival mechanics and asset integration

@export var mouse_sensitivity: float = 0.003
@export var move_speed: float = 7.0
@export var sprint_speed: float = 12.0

var camera: Camera3D
var head: Node3D
var is_sprinting: bool = false

# Asset system
var asset_importer: AssetImporter
var player_model: Node3D

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
	
	# Initialize asset importer
	asset_importer = AssetImporter.new()
	add_child(asset_importer)
	
	# Setup camera
	camera = $Head/Camera3D if has_node("Head/Camera3D") else Camera3D.new()
	if not has_node("Head"):
		head = Node3D.new()
		add_child(head)
		head.name = "Head"
		head.add_child(camera)
	else:
		head = $Head
	
	camera.global_position = global_position + Vector3(0, 1.6, 0)
	
	# Load player model from assets
	_load_player_model()
	
	# Initialize survival stats
	_initialize_stats()
	
	# Get game systems
	game_manager = get_tree().root.get_child(0).get_node_or_null("GameManager")
	mutation_system = get_tree().root.get_child(0).get_node_or_null("MutationSystem")
	weather_system = get_tree().root.get_child(0).get_node_or_null("WeatherSystem")

## Load player model from assets
func _load_player_model() -> void:
	var models = asset_importer.get_character_models()
	if models.size() > 0:
		var model_path = models[0]
		player_model = asset_importer.import_model(model_path)
		if player_model:
			add_child(player_model)
			player_model.position = Vector3(0, 0, 0)
			print("✅ Player model loaded: %s" % model_path)
		else:
			print("⚠️ Failed to load player model")

## Initialize survival stats
func _initialize_stats() -> void:
	health = 100.0
	hunger = 75.0
	thirst = 75.0
	fatigue = 0.0
	infection = 0.0
	temperature = 20.0

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	# Handle input
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.z = Input.get_axis("ui_up", "ui_down")
	input_dir = input_dir.normalized()
	
	# Handle sprint
	is_sprinting = Input.is_action_pressed("sprint")
	var speed = sprint_speed if is_sprinting else move_speed
	
	# Apply movement
	velocity = input_dir * speed
	move_and_slide()
	
	# Update survival stats
	_update_survival_stats(delta)

## Update survival stats over time
func _update_survival_stats(delta: float) -> void:
	# Hunger decreases over time
	hunger -= 0.5 * delta
	if hunger <= 0:
		health -= 1.0 * delta
	
	# Thirst decreases faster
	thirst -= 1.0 * delta
	if thirst <= 0:
		health -= 2.0 * delta
	
	# Fatigue from running
	if is_sprinting and velocity.length() > 0:
		fatigue += 2.0 * delta
		hunger -= 0.5 * delta
	else:
		fatigue = max(0, fatigue - 1.0 * delta)
	
	# Health regeneration at rest
	if fatigue < 20 and hunger > 50 and thirst > 50:
		health = min(100, health + 0.5 * delta)
	
	# Clamp values
	health = clamp(health, 0, 100)
	hunger = clamp(hunger, 0, 100)
	thirst = clamp(thirst, 0, 100)
	fatigue = clamp(fatigue, 0, 100)
	infection = clamp(infection, 0, 100)

func _input(event):
	if not is_multiplayer_authority():
		return
	
	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

## Add item to inventory
func add_item(item_name: String, quantity: int = 1) -> bool:
	if item_name in inventory:
		inventory[item_name] += quantity
	else:
		inventory[item_name] = quantity
	
	if is_multiplayer_authority():
		_update_inventory.rpc(item_name, inventory[item_name])
	
	return true

## Remove item from inventory
func remove_item(item_name: String, quantity: int = 1) -> bool:
	if item_name in inventory:
		inventory[item_name] -= quantity
		if inventory[item_name] <= 0:
			inventory.erase(item_name)
		return true
	return false

## Apply damage
func take_damage(amount: float, damage_type: String = "physical") -> void:
	health -= amount
	
	# Different damage types
	match damage_type:
		"infection":
			infection += amount * 0.5
		"hunger":
			hunger -= amount
		"thirst":
			thirst -= amount
	
	if health <= 0:
		die()

## Heal player
func heal(amount: float) -> void:
	health = min(100, health + amount)

## Consume food
func consume_food(food_name: String, hunger_restore: float = 30.0, thirst_restore: float = 5.0) -> void:
	if remove_item(food_name):
		hunger = min(100, hunger + hunger_restore)
		thirst = min(100, thirst + thirst_restore)

## Consume water
func consume_water(water_name: String, thirst_restore: float = 50.0) -> void:
	if remove_item(water_name):
		thirst = min(100, thirst + thirst_restore)

## Apply mutation
func apply_mutation(mutation_name: String, level: int = 1) -> void:
	mutations.append({
		"name": mutation_name,
		"level": level,
		"applied_at": Time.get_ticks_msec()
	})
	mutation_level += level

## Die
func die() -> void:
	print("☠️ Player died!")
	queue_free()

## Get player info
func get_player_info() -> Dictionary:
	return {
		"id": player_id,
		"health": health,
		"hunger": hunger,
		"thirst": thirst,
		"fatigue": fatigue,
		"infection": infection,
		"mutations": mutations,
		"inventory": inventory,
		"position": global_position
	}

@rpc("authority", "call_local")
func _update_inventory(item_name: String, quantity: int) -> void:
	inventory[item_name] = quantity
