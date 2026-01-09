extends Node
## FBXConverter - Converts Unity FBX models to Godot format

class_name FBXConverter

var asset_base_path := "res://assets/Survival 3D/"
var godot_models_path := "res://models/"

func _ready() -> void:
	print("🔧 FBXConverter initialized")
	
	# Create models directory if not exists
	if not DirAccess.dir_exists_absolute(godot_models_path):
		DirAccess.make_abs_absolute(godot_models_path)

## Get all FBX files from a directory
func get_fbx_files(directory: String) -> Array:
	var fbx_files = []
	var dir = DirAccess.open(asset_base_path + directory)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".fbx"):
				fbx_files.append(directory + "/" + file_name)
			file_name = dir.get_next()
	
	return fbx_files

## Convert FBX to Godot scene
func convert_fbx_to_scene(fbx_path: String) -> Node3D:
	# Godot 4.2+ can load FBX directly
	var full_path = asset_base_path + fbx_path
	
	if ResourceLoader.exists(full_path):
		var scene = load(full_path)
		if scene and scene is PackedScene:
			return scene.instantiate() as Node3D
	
	print("⚠️ Could not load FBX: %s" % full_path)
	return null

## Create weapon model from item
func create_weapon_model(weapon_type: String) -> Node3D:
	var weapon_models = get_fbx_files("Items/Survival Kit Lite")
	
	for model_path in weapon_models:
		if weapon_type.to_lower() in model_path.to_lower():
			return convert_fbx_to_scene(model_path)
	
	# Fallback - load any weapon
	if weapon_models.size() > 0:
		return convert_fbx_to_scene(weapon_models[0])
	
	return null

## Create building model
func create_building_model(building_type: String) -> Node3D:
	var building_models = get_fbx_files("Building")
	
	for model_path in building_models:
		if building_type.to_lower() in model_path.to_lower():
			return convert_fbx_to_scene(model_path)
	
	# Fallback
	if building_models.size() > 0:
		return convert_fbx_to_scene(building_models[0])
	
	return null

## Create character model (zombie/survivor)
func create_character_model(character_type: String) -> Node3D:
	var character_models = get_fbx_files("Animations/Zombie/Models")
	
	# Try to find specific model
	for model_path in character_models:
		if character_type.to_lower() in model_path.to_lower():
			return convert_fbx_to_scene(model_path)
	
	# Fallback
	if character_models.size() > 0:
		return convert_fbx_to_scene(character_models[0])
	
	return null

## Create animal model
func create_animal_model(animal_type: String) -> Node3D:
	var animal_models = get_fbx_files("Animations/Animals")
	
	for model_path in animal_models:
		if animal_type.to_lower() in model_path.to_lower():
			return convert_fbx_to_scene(model_path)
	
	# Fallback
	if animal_models.size() > 0:
		return convert_fbx_to_scene(animal_models[0])
	
	return null

## Create prop model
func create_prop_model(prop_type: String) -> Node3D:
	var prop_models = get_fbx_files("Models")
	
	for model_path in prop_models:
		if prop_type.to_lower() in model_path.to_lower():
			return convert_fbx_to_scene(model_path)
	
	# Fallback
	if prop_models.size() > 0:
		return convert_fbx_to_scene(prop_models[0])
	
	return null

## Get all animation clips from a model
func get_animation_clips(fbx_path: String) -> Array:
	var model = convert_fbx_to_scene(fbx_path)
	var clips = []
	
	if model and model.has_node("AnimationPlayer"):
		var anim_player = model.get_node("AnimationPlayer") as AnimationPlayer
		clips = anim_player.get_animation_list()
	
	return clips
