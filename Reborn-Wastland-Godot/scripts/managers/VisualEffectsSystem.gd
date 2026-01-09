extends Node3D
## VisualEffectsSystem - Particle and visual effects

class_name VisualEffectsSystem

# Particle effect configurations
var particle_scenes: Dictionary = {}
var active_particles: Array = []

func _ready() -> void:
	print("✨ VisualEffectsSystem initializing...")
	_setup_particle_effects()

## Setup particle effect definitions
func _setup_particle_effects() -> void:
	# Combat effects
	particle_scenes["impact"] = _create_impact_effect()
	particle_scenes["blood"] = _create_blood_effect()
	particle_scenes["fire"] = _create_fire_effect()
	particle_scenes["smoke"] = _create_smoke_effect()
	particle_scenes["dust"] = _create_dust_effect()
	
	# Environmental effects
	particle_scenes["wind"] = _create_wind_effect()
	particle_scenes["rain"] = _create_rain_effect()
	particle_scenes["snow"] = _create_snow_effect()
	particle_scenes["leaves"] = _create_leaves_effect()
	
	# Item effects
	particle_scenes["pickup"] = _create_pickup_effect()
	particle_scenes["heal"] = _create_heal_effect()
	particle_scenes["buff"] = _create_buff_effect()
	
	print("✅ %d particle effects configured" % particle_scenes.size())

## Create impact particle effect
func _create_impact_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.emitting = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.2
	
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 15.0
	particles.angle_min = 0.0
	particles.angle_max = 360.0
	
	particles.modulate = Color.GRAY
	particles.scale_min = 0.2
	particles.scale_max = 0.5
	
	return particles

## Create blood particle effect
func _create_blood_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 2.0
	particles.one_shot = true
	particles.emitting = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.3
	
	particles.initial_velocity_min = 3.0
	particles.initial_velocity_max = 10.0
	particles.gravity = Vector3(0, -9.8, 0)
	
	particles.modulate = Color.RED
	particles.scale_min = 0.1
	particles.scale_max = 0.3
	
	return particles

## Create fire particle effect
func _create_fire_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 40
	particles.lifetime = 1.0
	particles.emitting = false
	particles.one_shot = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(1, 1, 1)
	
	particles.initial_velocity_min = 1.0
	particles.initial_velocity_max = 5.0
	particles.gravity = Vector3(0, 2, 0)
	
	particles.modulate = Color.ORANGE
	particles.scale_min = 0.5
	particles.scale_max = 1.5
	
	return particles

## Create smoke particle effect
func _create_smoke_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 25
	particles.lifetime = 3.0
	particles.emitting = false
	particles.one_shot = true
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.5
	
	particles.initial_velocity_min = 0.5
	particles.initial_velocity_max = 2.0
	particles.gravity = Vector3(0, 1, 0)
	
	particles.modulate = Color.GRAY
	particles.modulate.a = 0.5
	particles.scale_min = 0.5
	particles.scale_max = 2.0
	
	return particles

## Create dust particle effect
func _create_dust_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 15
	particles.lifetime = 1.5
	particles.emitting = false
	particles.one_shot = true
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(2, 0.5, 2)
	
	particles.initial_velocity_min = 1.0
	particles.initial_velocity_max = 5.0
	particles.gravity = Vector3(0, -2, 0)
	
	particles.modulate = Color(0.8, 0.8, 0.7, 0.6)
	particles.scale_min = 0.3
	particles.scale_max = 1.0
	
	return particles

## Create wind particle effect
func _create_wind_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 50
	particles.lifetime = 5.0
	particles.emitting = true
	particles.one_shot = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(50, 30, 50)
	
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 8.0
	particles.gravity = Vector3.ZERO
	
	particles.modulate = Color.WHITE
	particles.modulate.a = 0.2
	particles.scale_min = 0.1
	particles.scale_max = 0.3
	
	return particles

## Create rain particle effect
func _create_rain_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 100
	particles.lifetime = 3.0
	particles.emitting = false
	particles.one_shot = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(50, 30, 50)
	
	particles.initial_velocity_min = 0.0
	particles.initial_velocity_max = 0.0
	particles.gravity = Vector3(0, -30, 0)
	
	particles.modulate = Color.CYAN
	particles.modulate.a = 0.7
	particles.scale_min = 0.05
	particles.scale_max = 0.1
	
	return particles

## Create snow particle effect
func _create_snow_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 80
	particles.lifetime = 10.0
	particles.emitting = false
	particles.one_shot = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(50, 30, 50)
	
	particles.initial_velocity_min = 1.0
	particles.initial_velocity_max = 3.0
	particles.gravity = Vector3(0, -5, 0)
	
	particles.modulate = Color.WHITE
	particles.scale_min = 0.1
	particles.scale_max = 0.3
	
	return particles

## Create leaves particle effect
func _create_leaves_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 4.0
	particles.emitting = true
	particles.one_shot = false
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(30, 20, 30)
	
	particles.initial_velocity_min = 1.0
	particles.initial_velocity_max = 4.0
	particles.gravity = Vector3(0, -5, 0)
	
	particles.modulate = Color.YELLOW_GREEN
	particles.scale_min = 0.2
	particles.scale_max = 0.6
	
	return particles

## Create pickup particle effect
func _create_pickup_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 1.0
	particles.emitting = false
	particles.one_shot = true
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.5
	
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 8.0
	particles.gravity = Vector3(0, 5, 0)
	
	particles.modulate = Color.GOLD
	particles.scale_min = 0.2
	particles.scale_max = 0.6
	
	return particles

## Create heal particle effect
func _create_heal_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 25
	particles.lifetime = 1.5
	particles.emitting = false
	particles.one_shot = true
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.3
	
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 6.0
	particles.gravity = Vector3(0, 3, 0)
	
	particles.modulate = Color.GREEN
	particles.scale_min = 0.15
	particles.scale_max = 0.4
	
	return particles

## Create buff particle effect
func _create_buff_effect() -> CPUParticles3D:
	var particles = CPUParticles3D.new()
	particles.amount = 15
	particles.lifetime = 2.0
	particles.emitting = false
	particles.one_shot = true
	
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.2
	
	particles.initial_velocity_min = 1.0
	particles.initial_velocity_max = 5.0
	particles.gravity = Vector3(0, 1, 0)
	
	particles.modulate = Color.BLUE
	particles.scale_min = 0.1
	particles.scale_max = 0.3
	
	return particles

## Play particle effect at position
func play_effect(effect_name: String, position: Vector3 = Vector3.ZERO, duration: float = 0.0) -> CPUParticles3D:
	if effect_name not in particle_scenes:
		print("❌ Effect not found: %s" % effect_name)
		return null
	
	var template = particle_scenes[effect_name]
	var particles = template.duplicate()
	particles.position = position
	particles.emitting = true
	
	add_child(particles)
	active_particles.append(particles)
	
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		particles.emitting = false
		await get_tree().create_timer(particles.lifetime).timeout
		particles.queue_free()
	else:
		# Auto cleanup after effect ends
		await get_tree().create_timer(particles.lifetime + 0.5).timeout
		particles.queue_free()
		active_particles.erase(particles)
	
	print("✨ Playing effect: %s at %s" % [effect_name, position])
	return particles

## Play combat impact effect
func play_combat_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("impact", position, 0.5)

## Play blood effect
func play_blood_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("blood", position, 2.0)

## Play fire effect
func play_fire_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("fire", position)

## Play smoke effect
func play_smoke_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("smoke", position, 3.0)

## Play item pickup effect
func play_pickup_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("pickup", position, 1.0)

## Play heal effect
func play_heal_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("heal", position, 1.5)

## Play buff effect
func play_buff_effect(position: Vector3) -> CPUParticles3D:
	return play_effect("buff", position, 2.0)

## Get available effects
func get_available_effects() -> Array:
	return particle_scenes.keys()

## Clear all active particles
func clear_all() -> void:
	for particles in active_particles:
		particles.queue_free()
	active_particles.clear()
