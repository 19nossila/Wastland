extends Node3D
class_name WorldManager

## World Manager - Manages world state, POIs, and dynamic events

signal location_discovered(location_name: String)
signal location_cleared(location_name: String)
signal weather_changed(weather_type: String)

var points_of_interest: Dictionary = {}
var discovered_locations: Array = []
var cleared_locations: Array = []
var world_events: Array = []

class PointOfInterest:
	var name: String
	var location: Vector3
	var type: String  # settlement, dungeon, resource, safe_house
	var biome: String
	var threat_level: float  # 0.0 to 1.0
	var resources: Array
	var npcs: Array
	var discovered: bool = false
	
	func _init(name: String, pos: Vector3, type: String, biome: String):
		self.name = name
		self.location = pos
		self.type = type
		self.biome = biome

class WorldEvent:
	var event_id: String
	var event_type: String  # horde, migration, anomaly
	var location: Vector3
	var time_remaining: float
	var active: bool = true
	
	func _init(id: String, event_type: String, pos: Vector3):
		event_id = id
		self.event_type = event_type
		location = pos

func _ready():
	"""Initialize world manager"""
	_create_points_of_interest()
	_setup_world_events()
	print("World manager initialized")

func _create_points_of_interest():
	"""Create all points of interest"""
	
	# Urban Settlement
	var urban_settlement = PointOfInterest.new("Town Center", Vector3(0, 0, 0), "settlement", "urban")
	urban_settlement.threat_level = 0.3
	urban_settlement.resources = ["metal_scrap", "cloth"]
	urban_settlement.npcs = ["Marcus", "Captain Lee"]
	points_of_interest["town_center"] = urban_settlement
	
	# Forest Camp
	var forest_camp = PointOfInterest.new("Forest Outpost", Vector3(50, 0, 50), "safe_house", "forest")
	forest_camp.threat_level = 0.6
	forest_camp.resources = ["wood_plank", "leather"]
	forest_camp.npcs = ["Sarah"]
	points_of_interest["forest_camp"] = forest_camp
	
	# Desert Ruins
	var desert_ruins = PointOfInterest.new("Ancient Ruins", Vector3(-50, 0, -50), "dungeon", "desert")
	desert_ruins.threat_level = 0.8
	desert_ruins.resources = ["circuit", "metal_scrap", "rare_item"]
	points_of_interest["desert_ruins"] = desert_ruins
	
	# Mountain Base
	var mountain_base = PointOfInterest.new("Military Base", Vector3(100, 0, 100), "settlement", "mountain")
	mountain_base.threat_level = 0.5
	mountain_base.resources = ["ammo_rifle", "metal_scrap"]
	mountain_base.npcs = ["Dr. Evans"]
	points_of_interest["mountain_base"] = mountain_base
	
	# Wasteland Factory
	var wasteland_factory = PointOfInterest.new("Abandoned Factory", Vector3(-100, 0, 0), "resource", "wasteland")
	wasteland_factory.threat_level = 0.9
	wasteland_factory.resources = ["circuit", "battery", "metal_scrap"]
	points_of_interest["wasteland_factory"] = wasteland_factory
	
	# Safe Houses
	for i in range(3):
		var safe_house = PointOfInterest.new(
			"Safe House %d" % (i + 1),
			Vector3(randf_range(-200, 200), 0, randf_range(-200, 200)),
			"safe_house",
			["urban", "forest", "desert"][i]
		)
		safe_house.threat_level = 0.1
		points_of_interest["safe_house_%d" % i] = safe_house

func _setup_world_events():
	"""Setup world events"""
	pass  # Events triggered dynamically

func discover_location(poi_key: String) -> bool:
	"""Discover a point of interest"""
	if poi_key not in points_of_interest:
		return false
	
	var poi = points_of_interest[poi_key]
	
	if poi.discovered:
		return false
	
	poi.discovered = true
	discovered_locations.append(poi_key)
	location_discovered.emit(poi.name)
	print("Discovered: " + poi.name)
	
	return true

func clear_location(poi_key: String) -> bool:
	"""Clear a location of threats"""
	if poi_key not in points_of_interest:
		return false
	
	if poi_key in cleared_locations:
		return false
	
	cleared_locations.append(poi_key)
	location_cleared.emit(points_of_interest[poi_key].name)
	print("Cleared: " + points_of_interest[poi_key].name)
	
	return true

func get_nearby_locations(position: Vector3, radius: float = 100.0) -> Array:
	"""Get nearby points of interest"""
	var nearby = []
	
	for poi_key in points_of_interest:
		var poi = points_of_interest[poi_key]
		var distance = position.distance_to(poi.location)
		
		if distance <= radius:
			nearby.append({
				"name": poi.name,
				"distance": distance,
				"type": poi.type,
				"threat": poi.threat_level,
				"discovered": poi.discovered
			})
	
	nearby.sort_custom(func(a, b): return a.distance < b.distance)
	return nearby

func get_location_by_name(name: String) -> PointOfInterest:
	"""Get location by name"""
	for poi_key in points_of_interest:
		var poi = points_of_interest[poi_key]
		if poi.name == name:
			return poi
	
	return null

func get_locations_by_biome(biome: String) -> Array:
	"""Get all locations in biome"""
	var locations = []
	
	for poi_key in points_of_interest:
		var poi = points_of_interest[poi_key]
		if poi.biome == biome:
			locations.append({
				"key": poi_key,
				"name": poi.name,
				"type": poi.type,
				"threat": poi.threat_level
			})
	
	return locations

func get_locations_by_type(location_type: String) -> Array:
	"""Get all locations of specific type"""
	var locations = []
	
	for poi_key in points_of_interest:
		var poi = points_of_interest[poi_key]
		if poi.type == location_type:
			locations.append({
				"key": poi_key,
				"name": poi.name,
				"biome": poi.biome,
				"threat": poi.threat_level
			})
	
	return locations

func trigger_world_event(event_type: String, location_key: String) -> bool:
	"""Trigger a world event"""
	if location_key not in points_of_interest:
		return false
	
	var poi = points_of_interest[location_key]
	var event = WorldEvent.new("event_%s_%d" % [event_type, randi()], event_type, poi.location)
	
	world_events.append(event)
	print("Event triggered: %s at %s" % [event_type, poi.name])
	
	return true

func get_discovery_percentage() -> float:
	"""Get percentage of world discovered"""
	return float(discovered_locations.size()) / points_of_interest.size() * 100

func get_world_map_data() -> Dictionary:
	"""Get data for world map UI"""
	var map_data = {}
	
	for poi_key in points_of_interest:
		var poi = points_of_interest[poi_key]
		map_data[poi_key] = {
			"name": poi.name,
			"position": poi.location,
			"type": poi.type,
			"biome": poi.biome,
			"threat": poi.threat_level,
			"discovered": poi.discovered,
			"cleared": poi_key in cleared_locations
		}
	
	return map_data

func get_resource_locations(resource: String) -> Array:
	"""Get locations that have specific resource"""
	var locations = []
	
	for poi_key in points_of_interest:
		var poi = points_of_interest[poi_key]
		if resource in poi.resources:
			locations.append({
				"name": poi.name,
				"distance_rating": poi.threat_level,
				"location": poi.location
			})
	
	return locations
