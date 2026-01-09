extends Node
## MaterialManager - Manages materials and textures from assets

class_name MaterialManager

var asset_base_path := "res://assets/Survival 3D/"
var materials_cache: Dictionary = {}

func _ready() -> void:
	print("🎨 MaterialManager initialized")

## Load texture
func load_texture(texture_path: String) -> Texture2D:
	var full_path = asset_base_path + texture_path
	
	if ResourceLoader.exists(full_path):
		var texture = load(full_path) as Texture2D
		if texture:
			return texture
	
	print("⚠️ Texture not found: %s" % full_path)
	return null

## Create standard material
func create_material(material_name: String, albedo_path: String, normal_path: String = "", roughness_path: String = "", metallic: float = 0.0) -> StandardMaterial3D:
	# Check cache
	if material_name in materials_cache:
		return materials_cache[material_name]
	
	var material = StandardMaterial3D.new()
	material.name = material_name
	
	# Load albedo
	if albedo_path:
		var albedo = load_texture(albedo_path)
		if albedo:
			material.albedo_texture = albedo
	
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
	
	# Set metallic
	material.metallic = metallic
	
	# Cache it
	materials_cache[material_name] = material
	return material

## Get zombie skin material
func get_zombie_skin(skin_name: String) -> StandardMaterial3D:
	var skin_materials = {
		"zombieA": create_material("zombie_a", "Animations/Zombie/Skins/zombieA.png"),
		"zombieC": create_material("zombie_c", "Animations/Zombie/Skins/zombieC.png"),
		"survivor_male": create_material("survivor_male", "Animations/Zombie/Skins/survivorMaleB.png"),
		"survivor_female": create_material("survivor_female", "Animations/Zombie/Skins/survivorFemaleA.png"),
	}
	
	if skin_name in skin_materials:
		return skin_materials[skin_name]
	
	# Return first available
	for skin in skin_materials.values():
		return skin
	
	return StandardMaterial3D.new()

## Get knife material
func get_knife_material() -> StandardMaterial3D:
	return create_material(
		"knife",
		"Items/Survival Kit Lite/Knife/Textures/Knife_diffuse.png",
		"Items/Survival Kit Lite/Knife/Textures/Knife_normal.png",
		"",
		0.5
	)

## Get rope material
func get_rope_material() -> StandardMaterial3D:
	return create_material(
		"rope",
		"Items/Survival Kit Lite/Rope/Textures/Rope_diffuse.png",
		"Items/Survival Kit Lite/Rope/Textures/Rope_normal.png",
		""
	)

## Get flashlight material
func get_flashlight_material() -> StandardMaterial3D:
	return create_material(
		"flashlight",
		"Items/Survival Kit Lite/Flashlight/Textures/Flashlight_diffuse.png",
		"Items/Survival Kit Lite/Flashlight/Textures/Flashlight_normal.png",
		""
	)

## Get weapon material
func get_weapon_material(weapon_type: String) -> StandardMaterial3D:
	match weapon_type.to_lower():
		"knife":
			return get_knife_material()
		"rope":
			return get_rope_material()
		"flashlight":
			return get_flashlight_material()
		_:
			return StandardMaterial3D.new()

## Get building material
func get_building_material(building_type: String) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GRAY
	material.metallic = 0.2
	return material

## Get vegetation material
func get_vegetation_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GREEN
	material.alpha_scissor = BaseMaterial3D.ALPHA_SCISSOR_1
	return material

## Get water material
func get_water_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 0.8, 0.6)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.metallic = 0.8
	material.roughness = 0.2
	return material

## Get sky material
func get_sky_material() -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.SKY_BLUE
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
