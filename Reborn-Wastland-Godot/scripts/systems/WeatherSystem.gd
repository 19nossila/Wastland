extends Node
class_name WeatherSystem

## Weather System - Manages dynamic climate and environmental hazards

const WEATHER_TYPES = {
	"clear": {
		"name": "Clear",
		"damage_per_sec": 0.0,
		"fog_distance": 400,
		"color": Color.WHITE
	},
	"toxic_storm": {
		"name": "Toxic Storm",
		"damage_per_sec": 0.5,
		"fog_distance": 50,
		"color": Color(0.6, 0.2, 0.8)
	},
	"blizzard": {
		"name": "Blizzard",
		"damage_per_sec": 5.0,
		"fog_distance": 30,
		"color": Color(0.9, 0.95, 1.0)
	},
	"electrical_storm": {
		"name": "Electrical Storm",
		"damage_per_sec": 0.2,
		"fog_distance": 100,
		"color": Color(0.8, 0.8, 0.3),
		"lightning": true
	},
	"extreme_heat": {
		"name": "Extreme Heat",
		"damage_per_sec": 2.0,
		"fog_distance": 300,
		"color": Color(1.0, 0.7, 0.2)
	},
	"dense_fog": {
		"name": "Dense Fog",
		"damage_per_sec": 0.0,
		"fog_distance": 15,
		"color": Color(0.8, 0.8, 0.8)
	}
}

var current_weather: String = "clear"
var weather_timer: float = 0.0
var weather_duration: float = 0.0
var current_season: String = "spring"

func _ready():
	randomize()
	_spawn_random_weather()

func _process(delta):
	weather_timer += delta
	
	if weather_timer >= weather_duration:
		_spawn_random_weather()

func _spawn_random_weather():
	"""Spawn random weather based on season"""
	weather_duration = randf_range(300.0, 900.0)  # 5-15 minutes
	weather_timer = 0.0
	
	var weather_pool = _get_season_weather()
	current_weather = weather_pool[randi() % weather_pool.size()]
	
	print("Weather changed: %s" % current_weather)
	sync_weather.rpc_id(1)

func _get_season_weather() -> Array:
	"""Get weather pool for current season"""
	match current_season:
		"spring":
			return ["clear", "toxic_storm", "dense_fog"]
		"summer":
			return ["clear", "extreme_heat", "electrical_storm"]
		"autumn":
			return ["clear", "toxic_storm", "dense_fog"]
		"winter":
			return ["blizzard", "electrical_storm", "clear"]
		_:
			return ["clear"]

func get_weather_data() -> Dictionary:
	"""Get current weather data"""
	return WEATHER_TYPES.get(current_weather, WEATHER_TYPES["clear"])

func get_weather_damage() -> float:
	"""Get damage per second from current weather"""
	return get_weather_data()["damage_per_sec"]

func get_fog_distance() -> float:
	"""Get fog distance for current weather"""
	return get_weather_data()["fog_distance"]

func apply_weather_effects(body: Node, delta: float):
	"""Apply weather damage and effects to a body"""
	var damage = get_weather_damage() * delta
	
	if damage > 0 and body.has_method("take_damage"):
		body.take_damage(damage)

@rpc("authority")
func sync_weather():
	"""Sync weather across network"""
	rpc("receive_weather", current_weather, weather_timer, weather_duration)

@rpc
func receive_weather(weather: String, timer: float, duration: float):
	"""Receive weather update from server"""
	current_weather = weather
	weather_timer = timer
	weather_duration = duration
