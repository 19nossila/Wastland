extends Node
class_name SaveSystem

## Save System - Manages game saves and loading

const SAVE_DIR = "user://saves/"
const SAVE_FILE = "save_game.json"

signal game_saved
signal game_loaded

func _ready():
	"""Initialize save system"""
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_absolute(SAVE_DIR)
	print("Save system initialized")

func save_game(game_manager: GameManager) -> bool:
	"""Save current game state"""
	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_ticks_msec(),
		"game_state": game_manager.game_state,
		"current_season": game_manager.current_season,
		"current_day": game_manager.current_day,
		"game_time": game_manager.game_time,
		"quality_preset": game_manager.quality_preset,
		"player_data": _save_player(game_manager.player),
		"inventory_data": game_manager.inventory_system.get_inventory_data(),
		"quest_data": _save_quests(game_manager.quest_system),
		"faction_data": _save_factions(game_manager.faction_system),
		"mutation_data": _save_mutations(game_manager.player),
	}
	
	var json = JSON.stringify(save_data)
	var file = FileAccess.open(SAVE_DIR + SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(json)
		game_saved.emit()
		print("Game saved successfully")
		return true
	else:
		print("Failed to save game")
		return false

func load_game(game_manager: GameManager) -> bool:
	"""Load game state"""
	var file_path = SAVE_DIR + SAVE_FILE
	if not ResourceLoader.exists(file_path):
		print("Save file not found")
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error:
			print("Failed to parse save file")
			return false
		
		var save_data = json.get_data()
		
		# Restore game state
		game_manager.game_state = save_data.get("game_state", "playing")
		game_manager.current_season = save_data.get("current_season", "spring")
		game_manager.current_day = save_data.get("current_day", 0)
		game_manager.game_time = save_data.get("game_time", 0.0)
		
		# Restore player data
		if "player_data" in save_data and game_manager.player:
			_load_player(game_manager.player, save_data["player_data"])
		
		# Restore inventory
		if "inventory_data" in save_data:
			game_manager.inventory_system.load_inventory_data(save_data["inventory_data"])
		
		game_loaded.emit()
		print("Game loaded successfully")
		return true
	else:
		print("Failed to open save file")
		return false

func _save_player(player: PlayerCharacter) -> Dictionary:
	"""Save player data"""
	if not player:
		return {}
	
	return {
		"position": {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"z": player.global_position.z
		},
		"health": player.health,
		"hunger": player.hunger,
		"thirst": player.thirst,
		"fatigue": player.fatigue,
		"experience": player.experience if "experience" in player else 0,
	}

func _load_player(player: PlayerCharacter, data: Dictionary):
	"""Load player data"""
	if "position" in data:
		var pos = data["position"]
		player.global_position = Vector3(pos["x"], pos["y"], pos["z"])
	
	if "health" in data:
		player.health = data["health"]
	if "hunger" in data:
		player.hunger = data["hunger"]
	if "thirst" in data:
		player.thirst = data["thirst"]
	if "fatigue" in data:
		player.fatigue = data["fatigue"]

func _save_quests(quest_system: QuestSystem) -> Array:
	"""Save quest data"""
	var quest_data = []
	for quest_id in quest_system.active_quests:
		var quest = quest_system.active_quests[quest_id]
		quest_data.append({
			"id": quest.quest_id,
			"status": quest.status,
			"progress": quest.progress
		})
	return quest_data

func _save_factions(faction_system: FactionSystem) -> Dictionary:
	"""Save faction reputation data"""
	return {
		"enclave": faction_system.factions.get("enclave", {}).get("reputation", 0),
		"nomads": faction_system.factions.get("nomads", {}).get("reputation", 0),
		"eden": faction_system.factions.get("eden", {}).get("reputation", 0),
		"collective": faction_system.factions.get("collective", {}).get("reputation", 0),
	}

func _save_mutations(player: PlayerCharacter) -> Dictionary:
	"""Save player mutation data"""
	return {
		"mutation_level": player.mutation_level if "mutation_level" in player else 0.0,
		"active_mutations": player.active_mutations if "active_mutations" in player else []
	}

func delete_save() -> bool:
	"""Delete save file"""
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		var error = dir.remove(SAVE_FILE)
		if error == OK:
			print("Save file deleted")
			return true
	return false

func save_exists() -> bool:
	"""Check if save file exists"""
	return ResourceLoader.exists(SAVE_DIR + SAVE_FILE)
