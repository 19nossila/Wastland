extends Node3D
class_name ZombieSpawner

## Zombie Spawner - Manages zombie spawning and waves

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal zombies_defeated(count: int)

var current_wave: int = 0
var zombies_alive: int = 0
var max_zombies: int = 20
var spawned_zombies: Array = []

# Wave configuration
var wave_data: Array = [
	{"delay": 30.0, "count": 3, "types": ["drifter", "runner"]},
	{"delay": 60.0, "count": 5, "types": ["drifter", "runner", "mutant"]},
	{"delay": 90.0, "count": 8, "types": ["drifter", "runner", "mutant", "camouflaged"]},
	{"delay": 120.0, "count": 10, "types": ["all"]},
	{"delay": 150.0, "count": 15, "types": ["all"]},
]

func _ready():
	"""Initialize zombie spawner"""
	print("Zombie spawner initialized")

func _process(delta):
	"""Update zombie spawner"""
	# Check for defeated zombies
	spawned_zombies = spawned_zombies.filter(func(z): return is_instance_valid(z))
	zombies_alive = spawned_zombies.size()

func start_wave(wave_number: int = -1):
	"""Start a new zombie wave"""
	if wave_number == -1:
		wave_number = current_wave + 1
	
	if wave_number >= wave_data.size():
		print("All waves completed!")
		return
	
	current_wave = wave_number
	var wave_config = wave_data[wave_number]
	
	wave_started.emit(wave_number)
	print("Wave %d started with %d zombies" % [wave_number, wave_config["count"]])
	
	# Spawn zombies for this wave
	for i in range(wave_config["count"]):
		await get_tree().create_timer(0.5).timeout
		_spawn_zombie(wave_config["types"])

func _spawn_zombie(types: Array):
	"""Spawn a single zombie"""
	if zombies_alive >= max_zombies:
		return
	
	var random_type = types[randi() % types.size()]
	if random_type == "all":
		var all_types = ["drifter", "runner", "mutant", "camouflaged"]
		random_type = all_types[randi() % all_types.size()]
	
	var zombie = ZombieAI.new()
	zombie.zombie_type = random_type
	zombie.global_position = global_position + Vector3(randf_range(-20, 20), 0, randf_range(-20, 20))
	add_child(zombie)
	spawned_zombies.append(zombie)
	zombies_alive += 1

func get_zombie_count() -> int:
	"""Get current zombie count"""
	return zombies_alive

func stop_spawning():
	"""Stop spawning new zombies"""
	# Kill all remaining zombies
	for zombie in spawned_zombies:
		if is_instance_valid(zombie):
			zombie.queue_free()
	spawned_zombies.clear()

func despawn_all():
	"""Remove all spawned zombies"""
	for zombie in spawned_zombies:
		if is_instance_valid(zombie):
			zombie.queue_free()
	spawned_zombies.clear()
	zombies_alive = 0
