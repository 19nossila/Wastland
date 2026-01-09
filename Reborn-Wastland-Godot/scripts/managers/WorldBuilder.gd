extends Node3D
## WorldBuilder - Builds game world with biomes and assets

class_name WorldBuilder

@export var world_size: Vector2 = Vector2(500, 500)
@export var num_biomes: int = 4

var fbx_converter: FBXConverter
var material_manager: MaterialManager
var biomes: Array = []

func _ready() -> void:
	print("🌍 WorldBuilder initializing...")
	
	fbx_converter = FBXConverter.new()
	add_child(fbx_converter)
	
	material_manager = MaterialManager.new()
	add_child(material_manager)
	
	# Build the world
	_build_world()

## Build complete world
func _build_world() -> void:
	print("🏗️ Building world...")
	
	# Create biomes
	_create_biomes()
	
	# Add NPCs to biomes
	_spawn_npcs()
	
	# Add buildings
	_spawn_buildings()
	
	# Add vegetation
	_spawn_vegetation()
	
	# Add loot
	_spawn_loot()

## Create biome sections
func _create_biomes() -> void:
	var biome_types = ["Urban", "Forest", "Desert", "Mountain"]
	var biome_size = world_size / 2
	var positions = [
		Vector3(biome_size.x / 2, 0, biome_size.y / 2),
		Vector3(-biome_size.x / 2, 0, biome_size.y / 2),
		Vector3(biome_size.x / 2, 0, -biome_size.y / 2),
		Vector3(-biome_size.x / 2, 0, -biome_size.y / 2),
	]
	
	for i in range(min(biome_types.size(), num_biomes)):
		var biome = _create_biome(biome_types[i], positions[i], biome_size)
		biomes.append(biome)
		add_child(biome)

## Create single biome
func _create_biome(biome_type: String, position: Vector3, size: Vector2) -> Node3D:
	var biome = Node3D.new()
	biome.name = biome_type + "_Biome"
	biome.position = position
	
	# Create ground
	var ground = CSGBox3D.new()
	ground.size = Vector3(size.x, 1, size.y)
	ground.position = Vector3(0, -0.5, 0)
	
	# Apply biome-specific material
	match biome_type:
		"Urban":
			ground.material = material_manager.create_material("urban", "", "")
		"Forest":
			ground.material = material_manager.get_vegetation_material()
		"Desert":
			ground.material = material_manager.create_material("desert", "", "")
		"Mountain":
			ground.material = material_manager.create_material("mountain", "", "")
	
	biome.add_child(ground)
	
	print("✅ Created %s biome at %s" % [biome_type, position])
	return biome

## Spawn NPCs
func _spawn_npcs() -> void:
	print("👥 Spawning NPCs...")
	
	var npc_types = ["merchant", "guard", "survivor", "scientist"]
	var spawn_positions = [
		Vector3(50, 2, 50),
		Vector3(-50, 2, 50),
		Vector3(50, 2, -50),
		Vector3(-50, 2, -50),
	]
	
	for i in range(min(npc_types.size(), spawn_positions.size())):
		var npc = _create_npc(npc_types[i], spawn_positions[i])
		add_child(npc)

## Create NPC
func _create_npc(npc_type: String, position: Vector3) -> Node3D:
	var npc = Node3D.new()
	npc.name = npc_type.capitalize() + "_NPC"
	npc.position = position
	
	# Load character model
	var character = fbx_converter.create_character_model(npc_type)
	if character:
		npc.add_child(character)
	
	print("✅ Spawned %s at %s" % [npc_type, position])
	return npc

## Spawn buildings
func _spawn_buildings() -> void:
	print("🏢 Spawning buildings...")
	
	var building_types = ["shelter", "watchtower", "storage", "barracks"]
	var spawn_positions = [
		Vector3(30, 0, 30),
		Vector3(-30, 0, 30),
		Vector3(30, 0, -30),
		Vector3(-30, 0, -30),
	]
	
	for i in range(min(building_types.size(), spawn_positions.size())):
		var building = _create_building(building_types[i], spawn_positions[i])
		add_child(building)

## Create building
func _create_building(building_type: String, position: Vector3) -> Node3D:
	var building = Node3D.new()
	building.name = building_type.capitalize() + "_Building"
	building.position = position
	
	# Try to load building model
	var model = fbx_converter.create_building_model(building_type)
	if model:
		building.add_child(model)
	else:
		# Fallback: create simple box
		var box = CSGBox3D.new()
		box.size = Vector3(5, 5, 5)
		box.material = material_manager.get_building_material(building_type)
		building.add_child(box)
	
	print("✅ Created %s building at %s" % [building_type, position])
	return building

## Spawn vegetation
func _spawn_vegetation() -> void:
	print("🌳 Spawning vegetation...")
	
	# Spawn trees randomly
	randomize()
	for i in range(20):
		var pos = Vector3(
			randf_range(-world_size.x/2, world_size.x/2),
			0,
			randf_range(-world_size.y/2, world_size.y/2)
		)
		
		var tree = _create_vegetation("tree", pos)
		add_child(tree)

## Create vegetation
func _create_vegetation(veg_type: String, position: Vector3) -> Node3D:
	var veg = Node3D.new()
	veg.name = veg_type
	veg.position = position
	
	# Try to load model
	var model = fbx_converter.create_prop_model(veg_type)
	if model:
		veg.add_child(model)
	else:
		# Fallback: create simple cylinder (tree)
		var mesh = CylinderMesh.new()
		mesh.height = 5.0
		mesh.radius = 0.5
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material_manager.get_vegetation_material()
		veg.add_child(mesh_instance)
	
	return veg

## Spawn loot
func _spawn_loot() -> void:
	print("💰 Spawning loot...")
	
	var loot_items = ["iron", "stone", "banana", "building_kit"]
	randomize()
	
	for i in range(15):
		var item = loot_items[randi() % loot_items.size()]
		var pos = Vector3(
			randf_range(-world_size.x/2, world_size.x/2),
			1,
			randf_range(-world_size.y/2, world_size.y/2)
		)
		
		var loot = _create_loot_item(item, pos)
		add_child(loot)

## Create loot item
func _create_loot_item(item_type: String, position: Vector3) -> Node3D:
	var loot = Node3D.new()
	loot.name = item_type
	loot.position = position
	
	# Try to load item model
	var model = fbx_converter.create_prop_model(item_type)
	if model:
		loot.add_child(model)
	else:
		# Fallback: create simple sphere
		var mesh = SphereMesh.new()
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.scale = Vector3(0.5, 0.5, 0.5)
		loot.add_child(mesh_instance)
	
	return loot

## Get random biome
func get_random_biome() -> Node3D:
	if biomes.size() > 0:
		return biomes[randi() % biomes.size()]
	return null

## Get biome by name
func get_biome(biome_name: String) -> Node3D:
	for biome in biomes:
		if biome_name in biome.name:
			return biome
	return null
