# Reborn Wastland - Quick Reference Guide

## 8 Unique Mechanics At A Glance

### 1. 🧬 GENETIC MUTATIONS
**What**: Player-controlled evolution through zombie infection
- Start: 0% mutant (100% human)
- Progress: Each zombie death = +5% mutation
- Max: 100% (full mutation = zombie appearance)
- Impact: Different abilities per mutation level

**Mutations Available**:
```
Night Vision      → See in dark, but light-sensitive
Armored Skin      → -25% damage, +30% hunger
Regeneration      → 5 HP/sec heal, slower movement
Enhanced Limbs    → +20% speed, -10% accuracy
Enhanced Senses   → Detect enemies at 100m
Exoskeleton       → +50% carry capacity, -15% agility
```

**File**: `scripts/systems/MutationSystem.gd`

---

### 2. 👥 FACTION DYNAMICS
**What**: 4 rival factions with persistent reputation system
- Reputation: -100 (enemy) to +100 (ally)
- Actions affect standing (kill member = -20 rep)
- Changes NPC behavior, spawns, rewards
- Global consequences for all players

**The 4 Factions**:
```
Enclave Fortress  → Militaristic, weapon access
Frontier Nomads   → Traders, route maps
Green Eden        → Environmentalists, farming
Crimson Collective → Criminals, stolen goods
```

**Status Levels**:
```
-100 to -50: MORTAL ENEMY    → Will kill on sight
-49 to -20: ENEMY           → Hostile, no trading
-19 to 0:  HOSTILE          → Won't help, normal prices
1 to 19:   NEUTRAL          → No interactions
20 to 49:  FRIENDLY         → Discounts, help
50 to 100: ALLY             → 20% discount, secret quests
```

**File**: `scripts/systems/FactionSystem.gd`

---

### 3. 🌪️ PROCEDURAL CLIMATE
**What**: Dynamic weather with mechanical impact (not just visual)
- 6 weather types with unique hazards
- Season influences weather pool
- Affects zombie behavior, vehicle physics, player health
- Server-synchronized globally

**Weather Types & Effects**:
```
Toxic Storm      → Purple fog, 0.5 HP/sec damage outside shelter
Blizzard         → 5 HP/sec cold damage, frozen zombies
Electrical Storm → Lightning strikes, 10% damage chance
Extreme Heat     → 2 HP/sec dehydration, fast food decay
Dense Fog        → 15m visibility only, zombie spawn +2x
Clear Sky        → Normal conditions, no hazards
```

**Season Weather Pools**:
```
Spring:  Toxic Storm (60%), Fog (40%)
Summer:  Heat (70%), Lightning (20%), Clear (10%)
Autumn:  Fog (40%), Toxic (35%), Clear (25%)
Winter:  Blizzard (65%), Lightning (25%), Clear (10%)
```

**File**: `scripts/systems/WeatherSystem.gd`

---

### 4. 🚁 DRONE AUTOMATION
**What**: Buildable drones for resource farming, defense, reconnaissance
- 3 drone types: Scout, Farmer, Tower
- Battery-based operation
- Can be controlled remotely
- Limited by count (max 3, 2, 1 respectively)

**Drone Types**:
```
Scout Drone
├─ Cost: 50 metal, 10 circuits, 5 batteries
├─ Function: Reconnaissance (200m range)
├─ Speed: 15 m/s (fast)
├─ Battery: 15 min per charge
└─ Max: 3 simultaneous

Farmer Drone
├─ Cost: 80 metal, 15 circuits, 8 batteries
├─ Function: Auto-harvesting (20m² area)
├─ Speed: 3 m/s (slow)
├─ Battery: 20 min per charge
└─ Max: 2 simultaneous

Tower Drone
├─ Cost: 120 metal, 20 circuits, 15 batteries
├─ Function: Defense (40m range, 15 DPS)
├─ Speed: Static (0 m/s)
├─ Battery: 30 min per charge
└─ Max: 1 simultaneous
```

**File**: `scripts/systems/DroneSystem.gd`

---

### 5. 🧟 ZOMBIE ECOSYSTEMS
**What**: Biome-specific zombie evolution creating different threats
- 4+ zombie types per biome
- Adapt to environment (faster, stronger, etc.)
- Alpha zombies form when 10+ gather
- Evolution affects stats permanently

**Biome Zombie Types**:
```
URBAN
├─ Urban Runner    → +30% speed, normal health
└─ Scavenger Horde → -20% health, +coordination

FOREST
├─ Forest Mutant   → +60% health, +regeneration
└─ Camouflaged     → Invisible until 5m, high damage

DESERT
├─ Scorched Drifter → +80% speed in sand, -40% health
└─ Adapted Scavenger → Hot-resistant, less common

MOUNTAIN/SNOW
├─ Frozen Horror   → +240% health, slow, freezeout aura
└─ Alpine Mutant   → Avalanche immunity, cold-resistant
```

**Evolution Mechanics**:
- Survive combat: +5% health permanently
- Consume local resources: +regeneration per biome
- Group of 10+: Alpha spawns with +50% all stats
- Change biome: Reset evolution level (adaptation needed)

**File**: `scripts/ai/ZombieAI.gd`

---

### 6. 👻 SPECTRE MARKS
**What**: Death locations marked permanently with player ghosts
- When player dies: Location marked for 48 hours
- Show death cause and circumstances
- Leave behind 50% of inventory
- Other players can read epitaphs

**How It Works**:
```
1. Player dies at location X
   ↓
2. Aura spawns at death site (blue glow)
   ↓
3. Other players see: "A tragic death occurred here"
   ↓
4. Can inspect for details:
   - Name of dead player
   - Time of death
   - Cause (zombies, player, hunger, etc.)
   - Items left behind
   ↓
5. Can leave epitaph (50 char message)
   ↓
6. Multiple deaths = "Cursed Zone" marker
```

**Story Emergencies**:
```
Serial Victim Zone    → Same player dies 5x at spot
Battleground         → Different players die alternating
Legend's Grave       → One death with epic epitaph
Safe House           → Zone with zero deaths nearby
```

---

### 7. 🌍 SEASONAL CYCLES
**What**: 4 real seasons with game-changing mechanics
- 45 in-game days per season (180 day total cycle)
- Each season completely changes gameplay
- Global, synchronized for all players
- Affects everything: farming, vehicles, danger

**Spring (Days 1-45)**:
- ☀️ Daylight: 14h day / 10h night
- 🌱 Farming: +50% growth speed
- 🧟 Zombies: Normal behavior
- 🚗 Vehicles: Normal
- **Strategy**: Farm resources, low threat

**Summer (Days 46-90)**:
- ☀️ Daylight: 16h day / 8h night
- 🌡️ Climate: Extreme heat hazard
- 🧟 Zombies: +50% aggressive
- 🍴 Food: Decays 3x faster
- ⚙️ Vehicles: +30% fuel consumption
- **Strategy**: Manage heat, store food in freezers

**Autumn (Days 91-135)**:
- ☀️ Daylight: 12h day / 12h night (balanced)
- 🌤️ Climate: Unpredictable
- 🌾 Harvest: Final crops available
- **Strategy**: Prepare for winter, gather resources

**Winter (Days 136-180)**:
- ☀️ Daylight: 8h day / 16h night
- ❄️ Climate: Blizzards, frozen mechanics
- 🧟 Zombies: -40% speed, frozen often
- 🚗 Vehicles: -60% acceleration, can freeze
- 🏠 Danger: Avalanches, extreme cold
- **Strategy**: Survive indoors, zombies less threat

**File**: `scripts/managers/GameManager.gd`

---

### 8. 🌀 QUANTUM ANOMALIES
**What**: Rare random zones with impossible physics and unique loot
- Spawn randomly every 4-6 hours
- Max 2-3 active simultaneously
- Contain rare anomaly-specific loot
- Dangerous but rewarding

**Anomaly Types**:

**Teleport Vortex** (purple spin):
```
- Radius: 15m
- Effect: Random teleport 1-2km away
- Risk: May land in danger
- Loot: +50% rare mods
- Duration: 10-15 min
```

**Gravity Inversion** (sky flipped):
```
- Radius: 20m
- Effect: -9.8 gravity (float upward)
- Risk: Imprecise movement
- Reward: Access to secret caves
- Duration: 5-10 min
```

**Time Dilation** (bubble slow-motion):
```
- Radius: 10m
- Effect: Time 50% slower inside
- Benefit: Escape hordes safely
- Bonus: +30% XP & resources inside
- Duration: 8 min
```

**Clone Generator** (portal echoes):
```
- Radius: 15m
- Effect: Creates temporary player clone
- Clone Duration: 30 seconds
- Tactic: Distraction or team-up
- Bonus: Duplicate items if clone survives
```

**Temporal Storm** (lightning chaos):
```
- Radius: 30m
- Effect: Random 20 damage per 5 sec
- Electronics: -50% battery per sec
- Crystals: Drops rare temporal materials
- Duration: 15-25 min
```

**Spawn Rules**:
- Never near player spawn (safe zone)
- Sound warning 30 seconds before appearance
- Notification sent to all players
- Rare: 3% chance per 2-hour cycle

**File**: Referenced in `DESIGN_DOCUMENT.md` (implementation pending)

---

## Quick Stat Reference

### Player Stats
```
Health: 0-100 HP
Hunger: 0-100% (-1% per min base, -2% per min sprinting)
Thirst: 0-100% (-1% per min base, -2% per min sprinting, -3x in summer)
Fatigue: 0-100% (-0.5% per min standing, higher when sprinting)
Infection: 0-100% (from zombie exposure)
Temperature: °C (season-dependent, death at <0°C or >50°C)
```

### Mutation Impact on Stats
```
Night Vision     → +50% thirst (dry eyes)
Armored Skin     → +30% hunger (high metabolism)
Regeneration     → -50% fatigue (natural recovery)
Enhanced Limbs   → +20% speed, -10% accuracy
Enhanced Senses  → +50% fatigue (constant stimulation)
Exoskeleton      → +50% carry weight, -15% agility
```

### Zombie Stats by Type
```
Base:           Health=50, Damage=15, Speed=10
Urban Runner:   Health=50, Damage=15, Speed=13 (+30%)
Forest Mutant:  Health=80, Damage=18, Speed=10, Regen=+2/sec
Desert Drifter: Health=30, Damage=12, Speed=18 (+80%)
Frozen Horror:  Health=120, Damage=22, Speed=5 (-50%)
Alpha Zombie:   All stats +50%
```

---

## Game Files & Locations

```
Core Systems:
├─ GameManager              scripts/managers/GameManager.gd
├─ MutationSystem          scripts/systems/MutationSystem.gd
├─ FactionSystem           scripts/systems/FactionSystem.gd
├─ WeatherSystem           scripts/systems/WeatherSystem.gd
├─ DroneSystem             scripts/systems/DroneSystem.gd

Characters:
├─ PlayerCharacter         scripts/player/PlayerCharacter.gd
└─ ZombieAI               scripts/ai/ZombieAI.gd

Documentation:
├─ DESIGN_DOCUMENT.md      (Detailed 8 mechanics)
├─ README.md              (Setup & overview)
├─ CONVERSION_GUIDE.md    (Unity → Godot mapping)
└─ PROJECT_SUMMARY.md     (What was created)
```

---

## Common Commands

```gdscript
# Add mutation to player
mutation_system.add_mutation(player_id, "night_vision", 50.0)

# Change faction reputation
faction_system.add_reputation(player_id, "enclave", 25)

# Spawn drone
drone_system.spawn_drone(player_id, "scout", position)

# Get current weather
var weather_data = weather_system.get_weather_data()

# Take damage
player.take_damage(10.0)

# Apply evolution to zombie
zombie.evolve(5.0)
```

---

## Performance Tips

```
Very Low Setting (30 FPS):
✓ Max 30 zombies
✓ 720p resolution
✓ 100m render distance
✓ No particles
✓ Simple mutations (color swap only)

High Setting (60+ FPS):
✓ Max 150 zombies
✓ 1920x1080 resolution
✓ 500m render distance
✓ 200 particles
✓ Full shader mutations
```

---

## Next Steps

To continue development:

1. **Scenes** - Create .tscn files for levels and UI
2. **Models** - Import low-poly 3D models
3. **UI** - Build menus and HUD
4. **Audio** - Add sound effects and music
5. **Content** - Create item database, recipes, quests

See `PROJECT_SUMMARY.md` for full roadmap.

---

**Last Updated**: January 8, 2026
**Game**: Reborn Wastland
**Engine**: Godot 4.2+
**Mechanics**: 8 Unique Systems
