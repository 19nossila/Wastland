extends Node
class_name BalanceTestSystem

## Balance Test System - Tests and validates game balance

signal balance_test_started(test_name: String)
signal balance_issue_found(test_name: String, issue: String)
signal balance_test_complete(results: Dictionary)

class BalanceIssue:
	var test_name: String
	var issue_type: String  # warning, critical, info
	var message: String
	var data: Dictionary
	
	func _init(name: String, type: String, msg: String):
		test_name = name
		issue_type = type
		message = msg
		data = {}

var issues: Array = []
var warnings: int = 0
var critical_issues: int = 0

func _ready():
	"""Initialize balance test system"""
	add_to_group("balance_test_system")
	print("Balance test system initialized")

func run_balance_tests() -> Dictionary:
	"""Run complete balance test suite"""
	print("\n=== BALANCE TEST SUITE ===\n")
	
	issues.clear()
	warnings = 0
	critical_issues = 0
	
	# Item balance
	_test_item_balance()
	
	# Craft balance
	_test_crafting_balance()
	
	# Quest balance
	_test_quest_balance()
	
	# Mutation balance
	_test_mutation_balance()
	
	# Faction balance
	_test_faction_balance()
	
	# Difficulty balance
	_test_difficulty_balance()
	
	# Loot balance
	_test_loot_balance()
	
	# XP balance
	_test_xp_balance()
	
	var report = _generate_balance_report()
	balance_test_complete.emit(report)
	
	return report

func _test_item_balance():
	"""Test item balance"""
	balance_test_started.emit("Item Balance")
	
	var item_system = get_tree().get_first_node_in_group("item_system")
	
	if not item_system:
		_add_issue("Item Balance", "critical", "Item system not found")
		return
	
	# Test item rarity distribution
	var items = item_system.get_all_items()
	var rarity_counts = {"common": 0, "uncommon": 0, "rare": 0, "epic": 0, "legendary": 0}
	
	for item in items.values():
		var rarity = item.get("rarity", "common")
		if rarity in rarity_counts:
			rarity_counts[rarity] += 1
	
	# Warn if distribution is skewed
	var total = items.size()
	if rarity_counts["common"] < total * 0.4:
		_add_issue("Item Balance", "warning", "Too few common items: %d/%d (%.1f%%)" % [
			rarity_counts["common"], total, (float(rarity_counts["common"]) / total) * 100
		])
	
	if rarity_counts["legendary"] > total * 0.15:
		_add_issue("Item Balance", "warning", "Too many legendary items: %d/%d (%.1f%%)" % [
			rarity_counts["legendary"], total, (float(rarity_counts["legendary"]) / total) * 100
		])
	
	print("✓ Item Balance tested (%d items)" % items.size())

func _test_crafting_balance():
	"""Test crafting recipe balance"""
	balance_test_started.emit("Crafting Balance")
	
	var item_system = get_tree().get_first_node_in_group("item_system")
	
	if not item_system:
		_add_issue("Crafting Balance", "critical", "Item system not found")
		return
	
	var recipes = item_system.get_recipes()
	
	for recipe_id in recipes:
		var recipe = recipes[recipe_id]
		var materials_count = recipe.get("materials", {}).size()
		var craft_time = recipe.get("craft_time", 0)
		var output_value = recipe.get("output_value", 0)
		
		# Check if recipe is too efficient
		if materials_count < 2 and output_value > 50:
			_add_issue("Crafting Balance", "warning", 
				"Recipe '%s' may be too efficient: %d materials -> %d value" % [recipe_id, materials_count, output_value])
		
		# Check if recipe takes too long
		if craft_time > 300:
			_add_issue("Crafting Balance", "info", 
				"Recipe '%s' takes %d seconds (high but not necessarily bad)" % [recipe_id, craft_time])
	
	print("✓ Crafting Balance tested (%d recipes)" % recipes.size())

func _test_quest_balance():
	"""Test quest reward balance"""
	balance_test_started.emit("Quest Balance")
	
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	
	if not quest_system:
		_add_issue("Quest Balance", "critical", "Quest system not found")
		return
	
	var quests = quest_system.quests
	var total_xp = 0
	var avg_rewards = {}
	
	for quest_id in quests:
		var quest = quests[quest_id]
		var rewards = quest.get("rewards", {})
		
		if "xp" in rewards:
			total_xp += rewards["xp"]
		
		# Check individual quest XP
		if rewards.get("xp", 0) > 1000:
			_add_issue("Quest Balance", "warning", 
				"Quest '%s' gives %d XP (very high)" % [quest_id, rewards.get("xp", 0)])
	
	var avg_xp = total_xp / float(quests.size()) if quests.size() > 0 else 0
	print("✓ Quest Balance tested (%d quests, avg XP: %.0f)" % [quests.size(), avg_xp])

func _test_mutation_balance():
	"""Test mutation balance"""
	balance_test_started.emit("Mutation Balance")
	
	var mutation_system = get_tree().get_first_node_in_group("mutation_advanced")
	
	if not mutation_system:
		_add_issue("Mutation Balance", "info", "Advanced mutation system not found (optional)")
		return
	
	var stats = mutation_system.get_statistics()
	
	# Check if mutations are discoverable
	if stats.get("mutations_discovered", 0) == 0 and stats.get("total_mutations_available", 0) > 0:
		_add_issue("Mutation Balance", "warning", "No mutations discovered yet")
	
	print("✓ Mutation Balance tested")

func _test_faction_balance():
	"""Test faction balance"""
	balance_test_started.emit("Faction Balance")
	
	var faction_system = get_tree().get_first_node_in_group("faction_system")
	
	if not faction_system:
		_add_issue("Faction Balance", "critical", "Faction system not found")
		return
	
	var factions = faction_system.get_all_factions()
	
	if factions.size() != 4:
		_add_issue("Faction Balance", "warning", "Expected 4 factions, found %d" % factions.size())
	
	# Check faction balance in terms of influence
	for faction_name in factions:
		var faction_data = factions[faction_name]
		var reputation = faction_data.get("reputation", 0)
		
		# No faction should have extreme reputation differences
		if abs(reputation) > 80:
			_add_issue("Faction Balance", "info", 
				"Faction '%s' has extreme reputation: %d" % [faction_name, reputation])
	
	print("✓ Faction Balance tested (%d factions)" % factions.size())

func _test_difficulty_balance():
	"""Test difficulty multiplier balance"""
	balance_test_started.emit("Difficulty Balance")
	
	var config_manager = get_tree().get_first_node_in_group("config_manager")
	
	if not config_manager:
		_add_issue("Difficulty Balance", "info", "Config manager not found (optional)")
		return
	
	var difficulty = config_manager.game_config.get("difficulty", "normal")
	var multiplier = config_manager.get_difficulty_multiplier()
	
	if multiplier < 0.5 or multiplier > 3.0:
		_add_issue("Difficulty Balance", "warning", 
			"Difficulty multiplier out of range: %f (normal: 1.0)" % multiplier)
	
	print("✓ Difficulty Balance tested (difficulty: %s, multiplier: %.1f)" % [difficulty, multiplier])

func _test_loot_balance():
	"""Test loot balance"""
	balance_test_started.emit("Loot Balance")
	
	var loot_system = get_tree().get_first_node_in_group("loot_system")
	
	if not loot_system:
		_add_issue("Loot Balance", "info", "Loot system not found (optional)")
		return
	
	var loot_tables = loot_system.loot_tables
	var total_drop_chance = 0.0
	
	for zombie_type in loot_tables:
		var table = loot_tables[zombie_type]
		var drops = table.get("drops", [])
		
		var chance_sum = 0.0
		for drop in drops:
			chance_sum += drop.get("chance", 0.0)
		
		# Warn if drop chance is too high or too low
		if chance_sum > 1.0:
			_add_issue("Loot Balance", "warning", 
				"Zombie '%s' has drop chance > 100%% (%.0f%%)" % [zombie_type, chance_sum * 100])
		elif chance_sum < 0.2:
			_add_issue("Loot Balance", "warning", 
				"Zombie '%s' has very low drop chance (%.0f%%)" % [zombie_type, chance_sum * 100])
	
	print("✓ Loot Balance tested (%d zombie types)" % loot_tables.size())

func _test_xp_balance():
	"""Test XP progression balance"""
	balance_test_started.emit("XP Balance")
	
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	
	if not quest_system:
		_add_issue("XP Balance", "info", "Quest system not found")
		return
	
	var quests = quest_system.quests
	var xp_rewards = []
	
	for quest_id in quests:
		var quest = quests[quest_id]
		var xp = quest.get("rewards", {}).get("xp", 0)
		xp_rewards.append(xp)
	
	if xp_rewards.size() > 0:
		var avg_xp = xp_rewards.reduce(func(a, b): return a + b, 0) / float(xp_rewards.size())
		var max_xp = xp_rewards.max()
		var min_xp = xp_rewards.min()
		
		var variance = max_xp - min_xp
		if variance > avg_xp * 2:
			_add_issue("XP Balance", "warning", 
				"Large XP variance: min=%d, avg=%.0f, max=%d" % [min_xp, avg_xp, max_xp])
		
		print("✓ XP Balance tested (min: %d, avg: %.0f, max: %d)" % [min_xp, avg_xp, max_xp])
	else:
		print("✓ XP Balance tested (no quests)")

func _add_issue(test_name: String, issue_type: String, message: String):
	"""Add balance issue"""
	var issue = BalanceIssue.new(test_name, issue_type, message)
	issues.append(issue)
	
	if issue_type == "critical":
		critical_issues += 1
	elif issue_type == "warning":
		warnings += 1
	
	balance_issue_found.emit(test_name, message)

func _generate_balance_report() -> Dictionary:
	"""Generate balance test report"""
	var report = {
		"total_issues": issues.size(),
		"warnings": warnings,
		"critical_issues": critical_issues,
		"status": "balanced" if critical_issues == 0 else "needs_adjustment",
		"issues": []
	}
	
	for issue in issues:
		report["issues"].append({
			"test": issue.test_name,
			"type": issue.issue_type,
			"message": issue.message
		})
	
	print("\n=== BALANCE REPORT ===")
	print("Total Issues: %d" % report["total_issues"])
	print("Warnings: %d" % report["warnings"])
	print("Critical: %d" % report["critical_issues"])
	print("Status: %s" % report["status"])
	print("======================\n")
	
	if critical_issues > 0:
		print("CRITICAL ISSUES FOUND - Requires adjustment:")
		for issue in issues:
			if issue.issue_type == "critical":
				print("  - %s: %s" % [issue.test_name, issue.message])
	
	return report

func get_balance_issues() -> Array:
	"""Get all balance issues"""
	return issues.duplicate()

func get_balance_summary() -> Dictionary:
	"""Get balance summary"""
	return _generate_balance_report()
