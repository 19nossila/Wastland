extends Node
## AssetImporter - Imports and converts Unity assets to Godot format

class_name AssetImporter

var asset_base_path := "res://assets/Survival 3D/"
var imported_models := {}
var imported_textures := {}

func _ready() -> void:
	print("🎮 AssetImporter initialized")

## Import a 3D model from FBX
func import_model(path: String) -> Node3D:
	var full_path = asset_base_path + path
	
	if ResourceLoader.exists(full_path):
		var scene = load(full_path)
		if scene:
			imported_models[path] = scene
			print("✅ Model imported: %s" % path)
			return scene.instantiate()
	
	print("❌ Failed to import model: %s" % full_path)
	return null

## Load a texture
func load_texture(path: String) -> Texture2D:
	var full_path = asset_base_path + path
	
	if ResourceLoader.exists(full_path):
		var texture = load(full_path)
		if texture:
			imported_textures[path] = texture
			return texture
	
	print("⚠️ Texture not found: %s" % full_path)
	return null

## Get available models by category
func get_models_by_category(category: String) -> Array:
	var models = []
	var dir = DirAccess.open(asset_base_path + category)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".fbx") or file_name.ends_with(".gltf"):
				models.append(category + "/" + file_name)
			file_name = dir.get_next()
	
	return models

## Get available textures
func get_textures_by_category(category: String) -> Array:
	var textures = []
	var dir = DirAccess.open(asset_base_path + category)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				textures.append(category + "/" + file_name)
			file_name = dir.get_next()
	
	return textures

## Get all available character models
func get_character_models() -> Array:
	return get_models_by_category("Animations/Zombie/Models")

## Get all available weapon models
func get_weapon_models() -> Array:
	return get_models_by_category("Items")

## Get all available building models
func get_building_models() -> Array:
	return get_models_by_category("Building")

## Get character skins
func get_character_skins() -> Array:
	return get_textures_by_category("Animations/Zombie/Skins")

## Create a material from textures
func create_material(diffuse_path: String, normal_path: String = "", roughness_path: String = "") -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	
	# Load diffuse
	if diffuse_path:
		var diffuse = load_texture(diffuse_path)
		if diffuse:
			material.albedo_texture = diffuse
	
	# Load normal
	if normal_path:
		var normal = load_texture(normal_path)
		if normal:
			material.normal_texture = normal
	
	# Load roughness
	if roughness_path:
		var roughness = load_texture(roughness_path)
		if roughness:
			material.roughness_texture = roughness
	
	return material
