# Audio & Visual Effects System Documentation

## Overview

The Wastland Reborn game now features a comprehensive audio and visual effects system with **23 sound effects** and **13 particle effects** fully integrated into gameplay.

---

## Sound Effects System (SoundEffectsSystem.gd)

### Architecture

The `SoundEffectsSystem` manages all audio playback with:
- **6 Sound Categories** for organized effect management
- **Audio Bus Hierarchy** (Master → SFX/Music/Ambient)
- **Spatial 3D Audio** support with AudioStreamPlayer3D
- **Preloading** capability for faster playback
- **Volume Control** per category and individual sounds

### Sound Categories (23 Total Sounds)

#### 1. **UI Sounds** (6 effects)
Location: `Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/`

| Sound | File | Purpose |
|-------|------|---------|
| click_1 | click1.ogg | Button click |
| click_2 | click2.ogg | Alternative button click |
| rollover_1 | rollover1.ogg | Mouse hover start |
| rollover_2 | rollover2.ogg | Alternative hover |
| switch_2 | switch2.ogg | Toggle switch ON |
| switch_3 | switch3.ogg | Toggle switch OFF |

**Usage:**
```gdscript
sound_effects_system.play_ui_sound("click_1", -5.0)
sound_effects_system.play_ui_sound("rollover_1", -10.0)
```

#### 2. **Combat Sounds** (4 effects)
Location: `Sounds/`

| Sound | File | Enemy Type | Purpose |
|-------|------|-----------|---------|
| sword_hit | swordHitSound.wav | All | Player/weapon impact |
| zombie_attack | zombieAttackSound.mp3 | Zombie | Zombie melee attack |
| wolf_attack | wolfAttackSoundd.mp3 | Wolf | Wolf melee attack |
| bear_attack | bearAttackSound.mp3 | Bear | Bear melee attack |

**Usage:**
```gdscript
# Player attacking
sound_effects_system.play_combat_sound("sword_hit", player_position)

# Zombie attacking
sound_effects_system.play_combat_sound("zombie_attack", zombie_position)
```

#### 3. **Environmental Sounds** (4 effects)
Location: `Sounds/`

| Sound | File | Purpose | Loop |
|-------|------|---------|------|
| woodcutting | woodcutting.wav | Resource gathering | Yes |
| fireplace_loop | Fireplace Loop 4.wav | Ambient campfire | Yes |
| background_forest | backgroundforest.mp3 | Ambient nature | Yes |
| main_menu | SurrealForest_MainMenuSound.mp3 | Main menu theme | Yes |

**Usage:**
```gdscript
# Start ambient forest loop
sound_effects_system.play_environment_sound("background_forest", -15.0, true)

# Play one-time woodcutting sound
sound_effects_system.play_environment_sound("woodcutting", -5.0, false)
```

#### 4. **Enemy Death Sounds** (5 effects)
Location: `Sounds/`

| Sound | File | Enemy Type |
|-------|------|-----------|
| zombie_death | N/A (mapped) | Zombie |
| rabbit_death | RabbitDeath.mp3 | Rabbit |
| bear_death_1 | bearDeath.wav | Bear |
| bear_death_2 | bear_Death.mp3 | Bear (variant) |
| wolf_death | WolfDeathSound1.mp3 | Wolf |

**Usage:**
```gdscript
# Mapped through play_enemy_death_sound()
sound_effects_system.play_enemy_death_sound("zombie", position)
sound_effects_system.play_enemy_death_sound("wolf", position)
sound_effects_system.play_enemy_death_sound("bear", position)
```

#### 5. **Item Sounds** (2 effects)
Location: `Sounds/` (mapped)

| Sound | Purpose |
|-------|---------|
| iron_pickup | Iron ore collection |
| stone_pickup | Stone collection |

**Usage:**
```gdscript
sound_effects_system.play_item_sound("iron", position)
sound_effects_system.play_item_sound("stone", position)
```

#### 6. **Ambient Sounds** (2 effects)
Location: `Sounds/`

| Sound | Purpose |
|-------|---------|
| forest_ambient | Background nature loop |
| main_theme | Game background music |

**Usage:**
```gdscript
# Play background music
sound_effects_system.play_background_music("main_theme", -15.0)

# Control music volume
sound_effects_system.set_bus_volume("Music", -10.0)
```

### Audio Bus System

Three main audio buses manage all sound output:

```
Master (0 dB)
├── SFX (-5 dB default)
│   ├── UI sounds
│   ├── Combat sounds
│   └── Item sounds
├── Music (-15 dB default)
│   └── Background music
└── Ambient (-12 dB default)
    └── Environmental loops
```

**Volume Control:**
```gdscript
# Set individual bus volumes
sound_effects_system.set_bus_volume("SFX", -3.0)
sound_effects_system.set_bus_volume("Music", -20.0)
sound_effects_system.set_bus_volume("Ambient", -10.0)
```

### Public Methods

```gdscript
# Generic sound playback
play_sound(category: String, effect_name: String, volume_db: float, 
           pitch: float, spatial: bool, position: Vector3) -> void

# Category-specific methods
play_ui_sound(sound_name: String, volume_db: float = -5.0) -> void
play_combat_sound(sound_name: String, position: Vector3) -> void
play_environment_sound(sound_name: String, volume_db: float, looping: bool) -> void
play_enemy_death_sound(enemy_type: String, position: Vector3) -> void
play_item_sound(item_type: String, position: Vector3) -> void
play_background_music(music_name: String, volume_db: float = -15.0) -> void

# Control methods
stop_category(category: String) -> void
stop_all() -> void
pause_all() -> void
set_bus_volume(bus_name: String, volume_db: float) -> void
preload_sounds() -> void
```

---

## Visual Effects System (VisualEffectsSystem.gd)

### Architecture

The `VisualEffectsSystem` manages all particle effects using Godot's `CPUParticles3D`:
- **13 Effect Types** covering all gameplay scenarios
- **Automatic Lifecycle** management with cleanup
- **One-Shot & Continuous** modes
- **Optimized Parameters** for performance
- **Position-Based** spawning

### Particle Effects (13 Total)

#### Combat Effects

##### 1. **Impact Effect**
```
Particles: 20 | Lifetime: 0.5s | Velocity: 5-15 m/s
Color: Gray | Shape: Sphere | One-shot: Yes
```
**Purpose:** Weapon hits, melee impacts
**Usage:**
```gdscript
visual_effects_system.play_effect("impact", position, 0.5)
```

##### 2. **Blood Effect**
```
Particles: 30 | Lifetime: 2.0s | Gravity: Enabled
Color: Red | Shape: Sphere | One-shot: Yes
```
**Purpose:** Damage taken, enemy death
**Usage:**
```gdscript
visual_effects_system.play_effect("blood", position, 2.0)
visual_effects_system.play_blood_effect(position)
```

##### 3. **Fire Effect**
```
Particles: 40 | Lifetime: Continuous | Gravity: Upward
Color: Orange/Red | Shape: Sphere | Continuous: Yes
```
**Purpose:** Burning objects, fire damage
**Usage:**
```gdscript
visual_effects_system.play_effect("fire", position, duration)
visual_effects_system.play_fire_effect(position)
```

##### 4. **Smoke Effect**
```
Particles: 25 | Lifetime: 3.0s | Gravity: Minimal
Color: Gray/Transparent | Shape: Sphere | Continuous: Yes
```
**Purpose:** Weapon fire, explosions
**Usage:**
```gdscript
visual_effects_system.play_effect("smoke", position, 3.0)
visual_effects_system.play_smoke_effect(position)
```

##### 5. **Dust Effect**
```
Particles: 15 | Lifetime: 1.0s | Velocity: 3-8 m/s
Color: Tan/Beige | Shape: Sphere | One-shot: Yes
```
**Purpose:** Ground impacts, footsteps
**Usage:**
```gdscript
visual_effects_system.play_effect("dust", position, 1.0)
```

#### Environmental Effects

##### 6. **Wind Effect**
```
Particles: 50 | Lifetime: Continuous | Direction: Horizontal
Color: White/Semi-transparent | One-shot: No | Speed: Slow
```
**Purpose:** Weather, ambient atmosphere
**Usage:**
```gdscript
visual_effects_system.play_effect("wind", position, duration)
```

##### 7. **Rain Effect**
```
Particles: 100 | Lifetime: 3.0s | Gravity: Downward
Color: Cyan/Blue | Shape: Box | Continuous: Yes
```
**Purpose:** Rain weather
**Usage:**
```gdscript
visual_effects_system.play_effect("rain", position, duration)
```

##### 8. **Snow Effect**
```
Particles: 80 | Lifetime: 10.0s | Gravity: Gentle
Color: White | Shape: Box | Continuous: Yes
```
**Purpose:** Snow weather
**Usage:**
```gdscript
visual_effects_system.play_effect("snow", position, duration)
```

##### 9. **Leaves Effect**
```
Particles: 30 | Lifetime: 4.0s | Gravity: Gentle
Color: Yellow-Green | Shape: Sphere | Continuous: Yes
```
**Purpose:** Trees swaying, autumnal effect
**Usage:**
```gdscript
visual_effects_system.play_effect("leaves", position, 4.0)
```

#### Item/Buff Effects

##### 10. **Pickup Effect**
```
Particles: 20 | Lifetime: 1.0s | Direction: Upward burst
Color: Gold/Yellow | Shape: Sphere | One-shot: Yes
```
**Purpose:** Item collection, looting
**Usage:**
```gdscript
visual_effects_system.play_effect("pickup", position, 1.0)
visual_effects_system.play_pickup_effect(position)
```

##### 11. **Heal Effect**
```
Particles: 25 | Lifetime: 1.5s | Direction: Upward trajectory
Color: Green | Shape: Sphere | One-shot: Yes
```
**Purpose:** Health restoration
**Usage:**
```gdscript
visual_effects_system.play_effect("heal", position, 1.5)
visual_effects_system.play_heal_effect(position)
```

##### 12. **Buff Effect**
```
Particles: 15 | Lifetime: 2.0s | Direction: Upward spiral
Color: Blue/Purple | Shape: Sphere | One-shot: Yes
```
**Purpose:** Buff application
**Usage:**
```gdscript
visual_effects_system.play_effect("buff", position, 2.0)
visual_effects_system.play_buff_effect(position)
```

### Public Methods

```gdscript
# Generic effect playback
play_effect(effect_name: String, position: Vector3, duration: float) -> void

# Combat effects
play_combat_effect(position: Vector3) -> void
play_blood_effect(position: Vector3) -> void
play_fire_effect(position: Vector3) -> void
play_smoke_effect(position: Vector3) -> void

# Item effects
play_pickup_effect(position: Vector3) -> void
play_heal_effect(position: Vector3) -> void
play_buff_effect(position: Vector3) -> void

# Utility
get_available_effects() -> Array
clear_all() -> void
```

---

## Integration Examples

### Player Taking Damage
```gdscript
# In PlayerCharacter_v2.gd
func take_damage(amount: float, damage_type: String = "physical") -> void:
    health -= amount
    
    # Play damage sound and effect
    if game_manager and game_manager.sound_effects_system:
        game_manager.sound_effects_system.play_sound(
            "combat", "sword_hit", -5.0, 1.0, true, global_position
        )
    
    if game_manager and game_manager.visual_effects_system:
        game_manager.visual_effects_system.play_effect(
            "blood", global_position, 2.0
        )
```

### Enemy Attack
```gdscript
# In ZombieAI_v2.gd
func _attack_target() -> void:
    if target and "take_damage" in target:
        target.take_damage(10.0, "infection")
        
        # Play attack sound
        game_manager.sound_effects_system.play_sound(
            "combat", "zombie_attack", -5.0, 1.0, true, global_position
        )
        
        # Play impact effect
        game_manager.visual_effects_system.play_effect(
            "impact", target.global_position, 0.5
        )
```

### Player Healing
```gdscript
# In PlayerCharacter_v2.gd
func heal(amount: float) -> void:
    health = min(100, health + amount)
    
    # Play heal sound and effect
    if game_manager and game_manager.sound_effects_system:
        game_manager.sound_effects_system.play_sound(
            "items", "heal", -10.0, 1.0, true, global_position
        )
    
    if game_manager and game_manager.visual_effects_system:
        game_manager.visual_effects_system.play_effect(
            "heal", global_position, 1.5
        )
```

### Enemy Death
```gdscript
# In ZombieAI_v2.gd
func die() -> void:
    # Play death sound
    game_manager.sound_effects_system.play_enemy_death_sound(
        "zombie", global_position
    )
    
    # Play death effect
    game_manager.visual_effects_system.play_effect(
        "blood", global_position, 2.0
    )
    
    queue_free()
```

---

## Performance Optimization

### Quality Presets

The systems support hardware quality detection:

```gdscript
# Very Low
max_particles: 5
sound_preload: false
audio_quality: low

# Low
max_particles: 15
sound_preload: true
audio_quality: standard

# Medium
max_particles: 30
sound_preload: true
audio_quality: high

# High
max_particles: 50
sound_preload: true
audio_quality: very_high
```

### Memory Management

- **Automatic Cleanup:** Particles are removed after lifetime expires
- **Audio Pooling:** Audio players are reused across playback
- **Resource Preloading:** Optional preload for frequently used sounds

---

## Asset Files Location

```
res://assets/Survival 3D/
├── Sounds/
│   ├── Combat/
│   │   ├── swordHitSound.wav
│   │   ├── zombieAttackSound.mp3
│   │   ├── wolfAttackSoundd.mp3
│   │   └── bearAttackSound.mp3
│   ├── Environment/
│   │   ├── woodcutting.wav
│   │   ├── Fireplace Loop 4.wav
│   │   └── backgroundforest.mp3
│   ├── Death/
│   │   ├── RabbitDeath.mp3
│   │   ├── bearDeath.wav
│   │   ├── bear_Death.mp3
│   │   └── WolfDeathSound1.mp3
│   ├── UI/
│   │   ├── click1.ogg
│   │   ├── click2.ogg
│   │   ├── rollover1.ogg
│   │   ├── rollover2.ogg
│   │   ├── switch2.ogg
│   │   └── switch3.ogg
│   └── SurrealForest_MainMenuSound.mp3
├── Models/
│   └── [7,922 FBX files for particles & environments]
└── Textures/
    └── [2,021 PNG textures]
```

---

## Testing Checklist

- [ ] UI sounds play on button interactions
- [ ] Combat sounds play during attacks
- [ ] Enemy death sounds play correctly
- [ ] Background music loops properly
- [ ] Particle effects display without lag
- [ ] Spatial audio positions correctly in 3D
- [ ] Volume controls work for all buses
- [ ] Effects cleanup after completion
- [ ] Game performs well on low-end hardware
- [ ] All sound files load without errors

---

## Future Enhancements

1. **Dynamic Music System:** Change music based on gameplay state
2. **Audio Presets:** Different sound sets per biome
3. **Voiceover Support:** NPC dialogue and player voice acting
4. **Music Mixing:** Dynamic track layering based on intensity
5. **Custom Soundscapes:** Player-created sound presets

---

## Related Files

- [SoundEffectsSystem.gd](scripts/managers/SoundEffectsSystem.gd)
- [VisualEffectsSystem.gd](scripts/managers/VisualEffectsSystem.gd)
- [GameManager_v2.gd](scripts/managers/GameManager_v2.gd)
- [PlayerCharacter_v2.gd](scripts/player/PlayerCharacter_v2.gd)
- [ZombieAI_v2.gd](scripts/ai/ZombieAI_v2.gd)
