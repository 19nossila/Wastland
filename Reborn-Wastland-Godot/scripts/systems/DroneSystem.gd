extends Node
class_name DroneSystem

## Drone System - Manages drone creation, control, and behavior

const DRONE_TYPES = {
	"scout": {
		"cost": {"metal": 50, "circuits": 10, "batteries": 5},
		"model_complexity": 200,
		"battery_drain": 0.067,
		"speed": 15.0,
		"max_count": 3,
		"abilities": ["detection"]
	},
	"farmer": {
		"cost": {"metal": 80, "circuits": 15, "batteries": 8},
		"model_complexity": 300,
		"battery_drain": 0.05,
		"speed": 3.0,
		"max_count": 2,
		"abilities": ["collection"]
	},
	"tower": {
		"cost": {"metal": 120, "circuits": 20, "batteries": 15},
		"model_complexity": 400,
		"battery_drain": 0.033,
		"speed": 0.0,
		"max_count": 1,
		"abilities": ["defense"]
	}
}

var active_drones: Array = []
var drone_pool: Array = []

class Drone:
	var drone_id: String
	var owner_id: int
	var drone_type: String
	var position: Vector3
	var battery: float = 100.0
	var active: bool = false
	var target: Vector3
	
	func _init(id: String, owner: int, type: String):
		drone_id = id
		owner_id = owner
		drone_type = type
		battery = 100.0
	
	func update(delta: float):
		if not active:
			return
		
		var drain_rate = DRONE_TYPES[drone_type]["battery_drain"]
		battery = max(0, battery - (drain_rate * 100.0 * delta))
		
		if battery <= 0:
			active = false

func _ready():
	pass

func spawn_drone(owner_id: int, drone_type: String, position: Vector3) -> String:
	"""Spawn a new drone"""
	if drone_type not in DRONE_TYPES:
		push_error("Unknown drone type: %s" % drone_type)
		return ""
	
	# Check max count
	var count = active_drones.filter(func(d): return d.drone_type == drone_type).size()
	if count >= DRONE_TYPES[drone_type]["max_count"]:
		return ""
	
	var drone_id = "%d_%s_%d" % [owner_id, drone_type, Time.get_ticks_msec()]
	var drone = Drone.new(drone_id, owner_id, drone_type)
	drone.position = position
	drone.active = true
	
	active_drones.append(drone)
	print("Drone spawned: %s (%s)" % [drone_id, drone_type])
	
	return drone_id

func deactivate_drone(drone_id: String):
	"""Deactivate a drone"""
	var drone = _find_drone(drone_id)
	if drone:
		drone.active = false
		active_drones.erase(drone)

func _find_drone(drone_id: String) -> Drone:
	"""Find drone by ID"""
	for drone in active_drones:
		if drone.drone_id == drone_id:
			return drone
	return null

func _process(delta):
	# Update all drones
	for drone in active_drones:
		drone.update(delta)
	
	# Remove dead drones
	active_drones = active_drones.filter(func(d): return d.active)

@rpc("authority")
func sync_drones():
	"""Sync all drone states across network"""
	var drone_states = []
	for drone in active_drones:
		drone_states.append({
			"id": drone.drone_id,
			"owner": drone.owner_id,
			"type": drone.drone_type,
			"position": drone.position,
			"battery": drone.battery,
			"active": drone.active
		})
	
	rpc("receive_drones", drone_states)

@rpc
func receive_drones(drone_states: Array):
	"""Receive drone states from server"""
	# Update client-side drone representations
	for state in drone_states:
		var drone = _find_drone(state["id"])
		if drone:
			drone.position = state["position"]
			drone.battery = state["battery"]
