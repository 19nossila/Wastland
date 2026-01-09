extends Node
class_name EventSystem

## Event System - Manages world events and anomalies

signal event_triggered(event_type: String, location: String)
signal event_resolved(event_type: String)
signal anomaly_detected(anomaly_type: String)

var active_events: Dictionary = {}
var event_history: Array = []
var anomaly_counter: int = 0

class GameEvent:
	var event_id: String
	var event_type: String
	var location: String
	var intensity: float
	var duration: float
	var rewards: Dictionary
	var time_elapsed: float = 0.0
	var active: bool = true
	
	func _init(id: String, type: String, loc: String, intensity: float):
		event_id = id
		event_type = type
		location = loc
		self.intensity = intensity

func _ready():
	"""Initialize event system"""
	print("Event system initialized")

func _process(delta):
	"""Update active events"""
	var completed_events = []
	
	for event_id in active_events:
		var event = active_events[event_id]
		event.time_elapsed += delta
		
		if event.time_elapsed >= event.duration:
			completed_events.append(event_id)
	
	for event_id in completed_events:
		resolve_event(event_id)

func trigger_event(event_type: String, location: String, intensity: float = 1.0) -> String:
	"""Trigger a new world event"""
	var event_id = "event_%s_%d" % [event_type, randi()]
	var duration = 120.0 + (intensity * 60.0)  # 2-5 minutes
	
	var event = GameEvent.new(event_id, event_type, location, intensity)
	event.duration = duration
	
	# Set rewards based on event type
	event.rewards = _get_event_rewards(event_type, intensity)
	
	active_events[event_id] = event
	event_history.append(event_id)
	
	event_triggered.emit(event_type, location)
	print("Event triggered: %s at %s (intensity: %.1f)" % [event_type, location, intensity])
	
	return event_id

func trigger_horde_event(location: String, horde_size: int = 10) -> String:
	"""Trigger zombie horde event"""
	var intensity = float(horde_size) / 20.0  # Normalize to 0-1
	return trigger_event("zombie_horde", location, intensity)

func trigger_resource_event(location: String, resource_type: String) -> String:
	"""Trigger resource discovery event"""
	return trigger_event("resource_discovery", location, 0.5)

func trigger_anomaly_event(anomaly_type: String, location: String) -> String:
	"""Trigger quantum anomaly event"""
	anomaly_counter += 1
	var event_id = trigger_event("anomaly", location, 0.75)
	anomaly_detected.emit(anomaly_type)
	print("Anomaly %d detected: %s" % [anomaly_counter, anomaly_type])
	return event_id

func trigger_faction_event(faction: String, location: String) -> String:
	"""Trigger faction-related event"""
	return trigger_event("faction_activity", location, 0.8)

func trigger_weather_event(weather_type: String, location: String) -> String:
	"""Trigger severe weather event"""
	return trigger_event("weather", location, 0.6)

func resolve_event(event_id: String):
	"""Resolve an event"""
	if event_id not in active_events:
		return
	
	var event = active_events[event_id]
	event.active = false
	
	event_resolved.emit(event.event_type)
	print("Event resolved: %s (lasted %.1f seconds)" % [event.event_type, event.time_elapsed])
	
	active_events.erase(event_id)

func get_active_events() -> Array:
	"""Get all active events"""
	var events = []
	
	for event_id in active_events:
		var event = active_events[event_id]
		events.append({
			"id": event_id,
			"type": event.event_type,
			"location": event.location,
			"intensity": event.intensity,
			"time_remaining": event.duration - event.time_elapsed,
			"progress": event.time_elapsed / event.duration
		})
	
	return events

func get_event_details(event_id: String) -> Dictionary:
	"""Get details about specific event"""
	if event_id not in active_events:
		return {}
	
	var event = active_events[event_id]
	return {
		"id": event_id,
		"type": event.event_type,
		"location": event.location,
		"intensity": event.intensity,
		"active": event.active,
		"rewards": event.rewards,
		"time_remaining": event.duration - event.time_elapsed
	}

func get_event_count() -> int:
	"""Get number of active events"""
	return active_events.size()

func get_event_history_count() -> int:
	"""Get total events triggered"""
	return event_history.size()

func _get_event_rewards(event_type: String, intensity: float) -> Dictionary:
	"""Calculate rewards for event"""
	match event_type:
		"zombie_horde":
			return {
				"xp": int(150 * intensity),
				"circuits": int(20 * intensity),
				"reputation": int(15 * intensity)
			}
		"resource_discovery":
			return {
				"xp": 50,
				"item_rarity": 0.5 + intensity
			}
		"anomaly":
			return {
				"xp": int(200 * intensity),
				"research_data": int(50 * intensity),
				"mutation_chance": 0.3 * intensity
			}
		"faction_activity":
			return {
				"xp": int(100 * intensity),
				"faction_reputation": int(25 * intensity)
			}
		"weather":
			return {
				"xp": 30,
				"survival_bonus": 1.0 + (0.5 * intensity)
			}
		_:
			return {"xp": 0}

func create_event_alert(event_id: String) -> String:
	"""Create human-readable alert message"""
	if event_id not in active_events:
		return ""
	
	var event = active_events[event_id]
	
	match event.event_type:
		"zombie_horde":
			return "⚠️ ZOMBIE HORDE DETECTED at %s! Intensity: %.0f%%" % [event.location, event.intensity * 100]
		"resource_discovery":
			return "💎 RESOURCE DISCOVERED at %s! Come collect it!" % event.location
		"anomaly":
			return "🌀 QUANTUM ANOMALY DETECTED at %s! Danger level: %.0f%%" % [event.location, event.intensity * 100]
		"faction_activity":
			return "⚔️ FACTION ACTIVITY at %s! Intensity: %.0f%%" % [event.location, event.intensity * 100]
		"weather":
			return "🌩️ SEVERE WEATHER at %s! Seek shelter!" % event.location
		_:
			return "Event: %s at %s" % [event.event_type, event.location]

func should_trigger_random_event() -> bool:
	"""Determine if random event should trigger"""
	# Higher chance with fewer active events
	var chance = 0.01 * (5 - active_events.size())
	return randf() < chance

func get_event_statistics() -> Dictionary:
	"""Get event statistics"""
	var horde_count = 0
	var resource_count = 0
	var anomaly_count = 0
	var other_count = 0
	
	for event_id in event_history:
		if "horde" in event_id:
			horde_count += 1
		elif "resource" in event_id:
			resource_count += 1
		elif "anomaly" in event_id:
			anomaly_count += 1
		else:
			other_count += 1
	
	return {
		"total_events": event_history.size(),
		"active_events": active_events.size(),
		"horde_events": horde_count,
		"resource_events": resource_count,
		"anomaly_events": anomaly_count,
		"other_events": other_count,
		"anomalies_detected": anomaly_counter
	}
