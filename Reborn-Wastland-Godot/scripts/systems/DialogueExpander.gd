extends Node
class_name DialogueExpander

## Dialogue Expander - Extended dialogue trees for Phase 3

static func get_expanded_merchant_dialogue() -> Dictionary:
	"""Get expanded merchant dialogue tree"""
	return {
		"greeting": {
			"text": "Welcome to my humble shop, traveler! What brings you here?",
			"options": [
				{"text": "Show me your goods", "next": "shop_menu"},
				{"text": "I'm looking for supplies", "next": "supplies_chat"},
				{"text": "What news from the outside?", "next": "news"},
				{"text": "Never mind, goodbye", "next": "end"}
			]
		},
		"shop_menu": {
			"text": "Here's what I have available today:",
			"options": [
				{"text": "Show me food", "next": "food_items"},
				{"text": "Show me medicine", "next": "medicine_items"},
				{"text": "Show me ammunition", "next": "ammo_items"},
				{"text": "Back to main menu", "next": "greeting"}
			]
		},
		"food_items": {
			"text": "I have fresh canned goods and bottled water. Prices are fair.",
			"options": [
				{"text": "Buy food can (3 circuits)", "next": "buy_food"},
				{"text": "Buy water bottle (2 circuits)", "next": "buy_water"},
				{"text": "Browse more items", "next": "shop_menu"},
			]
		},
		"medicine_items": {
			"text": "Medical kits are in high demand these days. I have limited stock.",
			"options": [
				{"text": "Buy medical kit (5 circuits)", "next": "buy_medicine"},
				{"text": "Ask about prices", "next": "prices"},
				{"text": "Browse more items", "next": "shop_menu"},
			]
		},
		"ammo_items": {
			"text": "Got 9mm and rifle ammunition. Both good for hunting.",
			"options": [
				{"text": "Buy 9mm ammo (1 circuit per 10)", "next": "buy_ammo9"},
				{"text": "Buy rifle ammo (2 circuits per 10)", "next": "buy_ammo_rifle"},
				{"text": "Browse more items", "next": "shop_menu"},
			]
		},
		"supplies_chat": {
			"text": "Most people come looking for supplies. You're not the first.",
			"options": [
				{"text": "Where can I find more resources?", "next": "resources_advice"},
				{"text": "Do you know of any safe places?", "next": "safe_places"},
				{"text": "Show me what you're selling", "next": "shop_menu"}
			]
		},
		"news": {
			"text": "News? Ha! If you survive long enough out there, you make your own news.",
			"options": [
				{"text": "The factions seem to be fighting", "next": "faction_talk"},
				{"text": "I've seen strange mutations", "next": "mutation_talk"},
				{"text": "What have you heard recently?", "next": "recent_events"}
			]
		},
		"resources_advice": {
			"text": "Scrap yards to the east have metal. Forest areas have wood and plants.",
			"options": [
				{"text": "Sounds dangerous", "next": "greeting"},
				{"text": "I'll check it out", "next": "greeting"}
			]
		},
		"faction_talk": {
			"text": "Yes, always fighting. The Enclave, Nomads, Eden... all want control.",
			"options": [
				{"text": "Which faction do you trade with?", "next": "my_faction"},
				{"text": "Interesting... got anything else?", "next": "greeting"}
			]
		},
		"my_faction": {
			"text": "I trade with whoever pays well. But the Nomads give best deals.",
			"options": [
				{"text": "I want to join the Nomads", "next": "join_nomads"},
				{"text": "What about the others?", "next": "other_factions"},
				{"text": "Back to shopping", "next": "shop_menu"}
			]
		},
		"buy_food": {
			"text": "Good choice. Food is life out here. That's 3 circuits, please.",
			"options": [
				{"text": "I don't have enough circuits", "next": "no_money"},
				{"text": "Done! Here's your payment", "next": "transaction_complete"},
				{"text": "Actually, nevermind", "next": "shop_menu"}
			]
		},
		"transaction_complete": {
			"text": "Pleasure doing business with you! Come back when you need more.",
			"options": [
				{"text": "Thanks! See you later", "next": "end"},
				{"text": "Show me more items", "next": "shop_menu"}
			]
		},
		"no_money": {
			"text": "No circuits? Tough luck. Come back when you can pay.",
			"options": [
				{"text": "I'll find more resources", "next": "greeting"},
				{"text": "Goodbye", "next": "end"}
			]
		},
		"prices": {
			"text": "Prices are competitive. No haggling. Food: 2-3 circuits. Medicine: 5. Ammo: 1 per 10.",
			"options": [
				{"text": "That's reasonable", "next": "shop_menu"},
				{"text": "That's expensive", "next": "expensive"}
			]
		},
		"expensive": {
			"text": "Look, you can risk your life finding these items yourself. I take that risk for you.",
			"options": [
				{"text": "Fair point", "next": "shop_menu"},
				{"text": "I'll look elsewhere", "next": "end"}
			]
		},
		"end": {
			"text": "Safe travels out there!",
			"options": []
		}
	}

static func get_expanded_guard_dialogue() -> Dictionary:
	"""Get expanded guard dialogue tree"""
	return {
		"greeting": {
			"text": "Halt! State your business immediately.",
			"options": [
				{"text": "I'm here to help protect the settlement", "next": "volunteer"},
				{"text": "Just passing through", "next": "passing_through"},
				{"text": "I'm looking for work", "next": "work_offered"},
				{"text": "Leave me alone!", "next": "hostile"}
			]
		},
		"volunteer": {
			"text": "We don't need civilians playing hero. But if you're serious, we have jobs.",
			"options": [
				{"text": "Tell me about the jobs", "next": "jobs_list"},
				{"text": "I'll think about it", "next": "end"}
			]
		},
		"jobs_list": {
			"text": "We need: Perimeter patrol (medium pay), Zombie elimination (high pay), Supply runs (medium pay)",
			"options": [
				{"text": "I'll do perimeter patrol", "next": "patrol_quest"},
				{"text": "Zombie elimination sounds good", "next": "elimination_quest"},
				{"text": "Nevermind", "next": "greeting"}
			]
		},
		"patrol_quest": {
			"text": "Good. Scout the western perimeter and report back. 80 XP and 15 circuits.",
			"options": [
				{"text": "I'll get it done", "next": "quest_accepted"},
				{"text": "Too risky", "next": "greeting"}
			]
		},
		"elimination_quest": {
			"text": "We've spotted a horde to the north. Kill 10 zombies. 150 XP and 30 circuits.",
			"options": [
				{"text": "They won't stand a chance", "next": "quest_accepted"},
				{"text": "That's too many", "next": "greeting"}
			]
		},
		"quest_accepted": {
			"text": "Good soldier. Report back when it's done.",
			"options": [
				{"text": "Will do", "next": "end"}
			]
		},
		"passing_through": {
			"text": "Then keep moving. We don't want trouble.",
			"options": [
				{"text": "No trouble from me", "next": "end"},
				{"text": "What's the threat level here?", "next": "threat_info"}
			]
		},
		"threat_info": {
			"text": "Zombies everywhere. Especially at night. Mutations are getting worse.",
			"options": [
				{"text": "Any safe routes?", "next": "safe_routes"},
				{"text": "I'll be careful", "next": "end"}
			]
		},
		"safe_routes": {
			"text": "Take the main road. Avoid the forest at night. Stick to lit areas.",
			"options": [
				{"text": "Thanks for the advice", "next": "end"}
			]
		},
		"work_offered": {
			"text": "Work? You qualified? Let me see...",
			"options": [
				{"text": "I'm a skilled fighter", "next": "fighter_path"},
				{"text": "I'm good with supplies", "next": "supply_path"},
				{"text": "I have other skills", "next": "other_skills"}
			]
		},
		"fighter_path": {
			"text": "We need combat personnel. Dangerous work, good pay.",
			"options": [
				{"text": "Show me the opportunities", "next": "jobs_list"},
				{"text": "Too dangerous", "next": "greeting"}
			]
		},
		"hostile": {
			"text": "BAD MOVE! GUARDS!",
			"options": [
				{"text": "[Combat Initiated]", "next": "end"}
			]
		},
		"end": {
			"text": "Move along then.",
			"options": []
		}
	}

static func get_expanded_survivor_dialogue() -> Dictionary:
	"""Get expanded survivor dialogue tree"""
	return {
		"greeting": {
			"text": "Hey there! Haven't seen you around before. Where are you from?",
			"options": [
				{"text": "I'm a new arrival", "next": "newcomer"},
				{"text": "I'm just passing through", "next": "traveler"},
				{"text": "I've been here for a while", "next": "experienced"},
				{"text": "What do you do here?", "next": "occupation"}
			]
		},
		"newcomer": {
			"text": "Welcome to hell, friend. Stick with me, and I'll help you survive.",
			"options": [
				{"text": "What should I know?", "next": "survival_tips"},
				{"text": "Thanks for the offer", "next": "end"}
			]
		},
		"survival_tips": {
			"text": "First: Always carry food and water. Second: Never go out at night alone. Third: Trust no one from the Collective.",
			"options": [
				{"text": "What's the Collective?", "next": "collective_info"},
				{"text": "Good advice", "next": "end"}
			]
		},
		"collective_info": {
			"text": "They're like a cult. They experiment on people. Stay far away.",
			"options": [
				{"text": "That sounds terrifying", "next": "end"},
				{"text": "I can handle myself", "next": "end"}
			]
		},
		"traveler": {
			"text": "Be careful out there. Zombies have been acting strange lately.",
			"options": [
				{"text": "Strange how?", "next": "zombie_behavior"},
				{"text": "I'll keep that in mind", "next": "end"}
			]
		},
		"zombie_behavior": {
			"text": "They're getting smarter. Coordinating attacks. And some have mutations we've never seen.",
			"options": [
				{"text": "Mutations?", "next": "mutation_info"},
				{"text": "That's concerning", "next": "end"}
			]
		},
		"mutation_info": {
			"text": "Yeah, some zombies are evolving. Fire resistance, extra speed, regeneration. It's getting bad.",
			"options": [
				{"text": "How do we fight them?", "next": "combat_tactics"},
				{"text": "We need more resources", "next": "end"}
			]
		},
		"combat_tactics": {
			"text": "Headshots always work. Use explosives if you have them. And aim for mutations first.",
			"options": [
				{"text": "Solid advice", "next": "end"},
				{"text": "Any other tips?", "next": "more_tips"}
			]
		},
		"more_tips": {
			"text": "Travel in groups when possible. Mark safe houses on your map. And never trust food from unknown sources.",
			"options": [
				{"text": "Thanks for the help", "next": "end"}
			]
		},
		"experienced": {
			"text": "Oh, you're one of the old-timers? Then you know how bad it's gotten.",
			"options": [
				{"text": "It's been rough", "next": "reminisce"},
				{"text": "We've managed so far", "next": "end"}
			]
		},
		"reminisce": {
			"text": "Yeah... remember when zombies were just shambling undead? Now they're something else entirely.",
			"options": [
				{"text": "The mutations started it all", "next": "mutation_origin"},
				{"text": "Those were simpler times", "next": "end"}
			]
		},
		"mutation_origin": {
			"text": "Some say it was a virus. Others say experiments. Nobody really knows. All we know is they're getting stronger.",
			"options": [
				{"text": "We need to find answers", "next": "end"},
				{"text": "Survival is all that matters now", "next": "end"}
			]
		},
		"occupation": {
			"text": "I'm trying to survive, just like everyone else. I gather supplies, take odd jobs, stay alive.",
			"options": [
				{"text": "Need any help?", "next": "help_offered"},
				{"text": "Good luck with that", "next": "end"}
			]
		},
		"help_offered": {
			"text": "Actually, I could use someone to help gather supplies in the old warehouse. Interested?",
			"options": [
				{"text": "I'll help", "next": "warehouse_quest"},
				{"text": "Too dangerous", "next": "end"}
			]
		},
		"warehouse_quest": {
			"text": "Great! Bring back 5 metal scraps and 3 cloth. 100 XP and some supplies for you.",
			"options": [
				{"text": "Consider it done", "next": "quest_start"},
				{"text": "Actually, nevermind", "next": "greeting"}
			]
		},
		"quest_start": {
			"text": "Good luck out there. Be careful in that warehouse.",
			"options": [
				{"text": "I will", "next": "end"}
			]
		},
		"end": {
			"text": "Take care, friend.",
			"options": []
		}
	}

static func get_expanded_scientist_dialogue() -> Dictionary:
	"""Get expanded scientist dialogue tree"""
	return {
		"greeting": {
			"text": "Ah, a visitor. Fascinating. You look relatively uninfected.",
			"options": [
				{"text": "I'm here to help your research", "next": "research_help"},
				{"text": "What are you studying?", "next": "research_topic"},
				{"text": "This place gives me the creeps", "next": "creepy"},
				{"text": "I'm just passing through", "next": "passing"}
			]
		},
		"research_help": {
			"text": "Excellent! I need samples. Zombie tissue, mutation markers, blood samples.",
			"options": [
				{"text": "I can get those", "next": "sample_quest"},
				{"text": "That sounds gross", "next": "greeting"}
			]
		},
		"sample_quest": {
			"text": "Bring me 3 tissue samples from mutated zombies. 200 XP and advanced research data.",
			"options": [
				{"text": "I'll gather them", "next": "quest_start"},
				{"text": "Too risky", "next": "greeting"}
			]
		},
		"research_topic": {
			"text": "The mutations, of course. They're evolving rapidly. If we understand them, maybe we can cure them.",
			"options": [
				{"text": "Can they be cured?", "next": "cure_possibility"},
				{"text": "How did this happen?", "next": "origin_story"}
			]
		},
		"cure_possibility": {
			"text": "Theoretically, yes. But it requires samples and experimentation. That's where you come in.",
			"options": [
				{"text": "I want to help", "next": "research_help"},
				{"text": "That's impossible", "next": "greeting"}
			]
		},
		"origin_story": {
			"text": "A virus. Engineered or natural, I don't know. But it rewrote zombie DNA. Made them smarter, stronger, adaptive.",
			"options": [
				{"text": "Who created it?", "next": "creator_theory"},
				{"text": "Can it jump to humans?", "next": "human_danger"}
			]
		},
		"creator_theory": {
			"text": "Rumor says the Collective was involved. Military experiments. But I can't prove it.",
			"options": [
				{"text": "That explains their interest in mutations", "next": "collective_interest"},
				{"text": "Interesting theory", "next": "greeting"}
			]
		},
		"collective_interest": {
			"text": "Yes! They're weaponizing the mutations. Creating super soldiers or something. Very dangerous.",
			"options": [
				{"text": "We need to stop them", "next": "stop_collective"},
				{"text": "That's not my problem", "next": "greeting"}
			]
		},
		"stop_collective": {
			"text": "Indeed. But first, I need data. Help me, and I'll share everything I discover.",
			"options": [
				{"text": "I'm in", "next": "research_help"},
				{"text": "I'll think about it", "next": "end"}
			]
		},
		"human_danger": {
			"text": "That's my greatest fear. If a human contracts the virus... we could see a new type of creature.",
			"options": [
				{"text": "Have humans been infected?", "next": "human_infection"},
				{"text": "We need to be careful", "next": "end"}
			]
		},
		"human_infection": {
			"text": "Possibly. Some disappearances could be attributed to infection rather than death. Concerning.",
			"options": [
				{"text": "We need a vaccine", "next": "vaccine_idea"},
				{"text": "How do we prevent infection?", "next": "prevention"}
			]
		},
		"vaccine_idea": {
			"text": "My thoughts exactly. But developing it would require massive resources and many test subjects.",
			"options": [
				{"text": "How can I help?", "next": "research_help"},
				{"text": "That's too ambitious", "next": "end"}
			]
		},
		"prevention": {
			"text": "Avoid bites, scratches, and blood contact. Basic precautions. And hope you're naturally resistant.",
			"options": [
				{"text": "I'll be careful", "next": "end"},
				{"text": "That's not enough", "next": "vaccine_idea"}
			]
		},
		"creepy": {
			"text": "Yes, well, science isn't always pleasant. But it's necessary.",
			"options": [
				{"text": "What are those containers?", "next": "containers"},
				{"text": "I'm leaving", "next": "end"}
			]
		},
		"containers": {
			"text": "Samples. Living and deceased specimens. Quite valuable for my research.",
			"options": [
				{"text": "That's disturbing", "next": "end"},
				{"text": "What are you studying about them?", "next": "research_topic"}
			]
		},
		"passing": {
			"text": "Shame. I could use another pair of hands.",
			"options": [
				{"text": "Maybe next time", "next": "end"},
				{"text": "Actually, I'll help", "next": "research_help"}
			]
		},
		"quest_start": {
			"text": "Good luck. Try not to get infected.",
			"options": [
				{"text": "I'll be careful", "next": "end"}
			]
		},
		"end": {
			"text": "Come back if you change your mind.",
			"options": []
		}
	}
