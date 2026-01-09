extends Node3D
class_name EffectManager

## Effect Manager - Manages visual effects and particles

var effect_pool: Dictionary = {}
var active_effects: Array = []

class EffectDefinition:
	var name: String
	var particle_count: int
	var duration: float
	var color: Color
	var speed: float
	var spread: float
	
	func _init(name: String, count: int, duration: float, color: Color, speed: float, spread: float):
		self.name = name
		self.particle_count = count
		self.duration = duration
		self.color = color
		self.speed = speed
		self.spread = spread

func _ready():
	"""Initialize effect manager"""
	_create_effect_definitions()
	_init_effect_pool()
	print("Effect manager initialized")

func _create_effect_definitions():
	"""Define all visual effects"""
	effect_pool["hit"] = EffectDefinition.new("hit", 10, 0.5, Color.WHITE, 5.0, 45.0)
	effect_pool["blood"] = EffectDefinition.new("blood", 15, 1.0, Color.RED, 3.0, 60.0)
	effect_pool["mutation"] = EffectDefinition.new("mutation", 30, 2.0, Color.DARK_MAGENTA, 4.0, 180.0)
	effect_pool["heal"] = EffectDefinition.new("heal", 20, 1.5, Color.GREEN, 3.0, 120.0)
	effect_pool["damage"] = EffectDefinition.new("damage", 15, 0.8, Color.ORANGE, 4.0, 90.0)
	effect_pool["fire"] = EffectDefinition.new("fire", 40, 2.0, Color.ORANGE, 5.0, 120.0)
	effect_pool["electric"] = EffectDefinition.new("electric", 25, 1.5, Color.YELLOW, 6.0, 90.0)
	effect_pool["frost"] = EffectDefinition.new("frost", 20, 1.5, Color.CYAN, 2.0, 60.0)
	effect_pool["poison"] = EffectDefinition.new("poison", 25, 2.0, Color.GREEN, 2.0, 90.0)
	effect_pool["explosion"] = EffectDefinition.new("explosion", 50, 1.0, Color.ORANGE_RED, 8.0, 180.0)
	effect_pool["smoke"] = EffectDefinition.new("smoke", 30, 3.0, Color.GRAY, 1.0, 120.0)
	effect_pool["dust"] = EffectDefinition.new("dust", 20, 2.0, Color(0.8, 0.7, 0.6), 2.0, 60.0)

func _init_effect_pool():
	"""Pre-allocate effect instances"""
	# In a full implementation, this would pre-create nodes
	pass

func play_effect(effect_name: String, position: Vector3, rotation: Vector3 = Vector3.ZERO) -> bool:
	"""Play a visual effect at position"""
	if effect_name not in effect_pool:
		print("Effect not found: " + effect_name)
		return false
	
	var effect_def = effect_pool[effect_name]
	var particles = MultiMeshInstance3D.new()
	particles.global_position = position
	particles.global_rotation = rotation
	
	add_child(particles)
	active_effects.append(particles)
	
	# Auto-cleanup after duration
	await get_tree().create_timer(effect_def.duration).timeout
	if is_instance_valid(particles):
		particles.queue_free()
		active_effects.erase(particles)
	
	return true

func play_damage_effect(position: Vector3, damage_type: String = "normal"):
	"""Play damage effect"""
	match damage_type:
		"fire":
			play_effect("fire", position)
		"electric":
			play_effect("electric", position)
		"frost":
			play_effect("frost", position)
		"poison":
			play_effect("poison", position)
		"mutation":
			play_effect("mutation", position)
		_:
			play_effect("damage", position)

func play_explosion(position: Vector3):
	"""Play explosion effect"""
	await play_effect("explosion", position)

func play_hit_effect(position: Vector3, direction: Vector3 = Vector3.ZERO):
	"""Play hit/impact effect"""
	await play_effect("hit", position, direction.normalized().to_euler())

func play_blood_splatter(position: Vector3):
	"""Play blood effect"""
	await play_effect("blood", position)

func play_healing_effect(position: Vector3):
	"""Play healing effect"""
	await play_effect("heal", position)

func play_mutation_effect(position: Vector3):
	"""Play mutation activation effect"""
	await play_effect("mutation", position)

func play_weather_effect(position: Vector3, weather_type: String):
	"""Play weather effect"""
	match weather_type:
		"rain":
			play_effect("smoke", position)  # Placeholder
		"toxic_storm":
			play_effect("poison", position)
		"lightning":
			play_effect("electric", position)
		"blizzard":
			play_effect("frost", position)
		"dust_storm":
			play_effect("dust", position)

func play_crafting_effect(position: Vector3):
	"""Play crafting effect"""
	await play_effect("heal", position)  # Reuse healing effect

func play_building_place_effect(position: Vector3):
	"""Play building placement effect"""
	var particles = MultiMeshInstance3D.new()
	particles.global_position = position
	add_child(particles)
	
	await get_tree().create_timer(0.5).timeout
	particles.queue_free()

func stop_all_effects():
	"""Stop and clear all active effects"""
	for effect in active_effects:
		if is_instance_valid(effect):
			effect.queue_free()
	active_effects.clear()

func get_active_effect_count() -> int:
	"""Get number of active effects"""
	return active_effects.size()

func set_effect_quality(quality: String):
	"""Adjust effect quality based on preset"""
	match quality:
		"very_low":
			# Disable most effects, use very few particles
			pass
		"low":
			# Reduce particle counts by 50%
			pass
		"medium":
			# Standard particle counts
			pass
		"high":
			# Increase particle counts by 50%
			pass

func get_effect_list() -> Array:
	"""Get list of all available effects"""
	return effect_pool.keys()

func create_environmental_effect(effect_type: String, position: Vector3, intensity: float = 1.0):
	"""Create environmental effects for weather/biome"""
	match effect_type:
		"rain":
			for i in range(int(5 * intensity)):
				play_effect("smoke", position + Vector3(randf_range(-5, 5), randf_range(0, 10), randf_range(-5, 5)))
		"dust_storm":
			for i in range(int(10 * intensity)):
				play_effect("dust", position + Vector3(randf_range(-10, 10), randf_range(0, 5), randf_range(-10, 10)))
		"volcanic":
			for i in range(int(8 * intensity)):
				play_effect("fire", position + Vector3(randf_range(-8, 8), randf_range(0, 8), randf_range(-8, 8)))
