# Reborn Wastland - Godot Edition

A complete conversion of the Unturned survival game mechanics to **Godot 4.2+** with a focus on low-end hardware optimization.

## Project Status

✅ **Design Document Complete** - 8 unique mechanics
✅ **Core Systems Framework** - GameManager, Mutation, Faction, Weather, Drone systems
✅ **Player & AI Scripts** - Basic character controller and zombie AI
⏳ **In Development** - Scene setup, UI, networking, optimization

## Conversion from Unity/C# to Godot/GDScript

### Why Godot?

- **Lightweight**: Smaller engine footprint (better for low-end)
- **GDScript**: Easier to optimize for performance
- **Open Source**: Full control over rendering pipeline
- **Vulkan/OpenGL**: Better compatibility with old GPUs
- **Built-in Networking**: Simpler multiplayer integration

### Key Differences from Original Unturned

| Feature | Unturned (Unity) | Reborn Wastland (Godot) |
|---------|-----------------|----------------------|
| Engine | Unity 2020+ | Godot 4.2+ |
| Language | C# | GDScript |
| Rendering | URP | Built-in (Forward) |
| Networking | Netcode for GameObjects | Godot MultiplayerAPI |
| Physics | PhysX | Godot Physics 3D |
| Min GPU | DirectX 9 | DirectX 10 / OpenGL 2.1 |
| Target RAM | 2 GB | 4 GB |

## Setup & Build Instructions

### Requirements

- **Godot 4.2+** (Download: https://godotengine.org/download)
- **Git** (for version control)
- **Python 3.8+** (for build scripts - optional)

### Installation

```bash
# Clone repository
git clone <repository-url>
cd Reborn-Wastland-Godot

# Open in Godot Editor
# 1. Launch Godot
# 2. Click "Open Project"
# 3. Select this directory
# 4. Click "Open & Edit"
```

### Building

#### Development (Editor)
```bash
# Simply open in Godot editor and press F5 to run
```

#### Export for Windows

```bash
# Via Editor:
# 1. Project > Export
# 2. Select "Windows Desktop"
# 3. Configure export settings
# 4. Click "Export Project"

# Via Command Line:
godot --headless --export-release "Windows Desktop" ./build/RebornWastland.exe
```

#### Export for Linux

```bash
godot --headless --export-release "Linux/X11" ./build/RebornWastland
```

## Project Structure

```
Reborn-Wastland-Godot/
├── scenes/                    # Scene files (.tscn)
│   ├── main/                 # Main game scenes
│   ├── player/              # Player-related scenes
│   ├── enemies/             # Enemy/zombie scenes
│   └── ui/                  # UI scenes
├── scripts/                  # GDScript files
│   ├── managers/            # GameManager, NetworkManager
│   ├── systems/             # Core game systems
│   │   ├── MutationSystem.gd
│   │   ├── FactionSystem.gd
│   │   ├── WeatherSystem.gd
│   │   └── DroneSystem.gd
│   ├── player/              # Player scripts
│   ├── ai/                  # Enemy AI scripts
│   └── ui/                  # UI scripts
├── assets/                   # Game assets
│   ├── models/              # 3D models (low-poly)
│   ├── textures/            # Textures (optimized)
│   ├── shaders/             # GLSL shaders
│   └── audio/               # Sound files
├── project.godot            # Godot project config
├── DESIGN_DOCUMENT.md       # Complete game design
└── README.md               # This file
```

## Core Systems Overview

### 1. **Mutation System** (`MutationSystem.gd`)
- 6 unique player mutations
- Genetic progression
- Multiplayer synchronization
- Impact on gameplay and NPC interactions

### 2. **Faction System** (`FactionSystem.gd`)
- 4 dynamic factions
- Reputation system (-100 to +100)
- Affects NPC behavior, spawns, and rewards

### 3. **Weather System** (`WeatherSystem.gd`)
- 6 weather types (toxic storms, blizzards, etc.)
- Season-based weather pools
- Environmental damage
- Affects zombie behavior and vehicle physics

### 4. **Drone System** (`DroneSystem.gd`)
- 3 drone types: Scout, Farmer, Tower
- Autonomous resource collection
- Defensive support
- Battery management

### 5. **Player Character** (`PlayerCharacter.gd`)
- First-person controller
- Survival stats (hunger, thirst, fatigue, health)
- Mutation integration
- Network synchronization

### 6. **Zombie AI** (`ZombieAI.gd`)
- Biome-based evolution
- 4 zombie types per biome
- Detection and chase behavior
- Adaptive combat

## Optimization Features

### Hardware Detection
```gdscript
# Automatic quality settings based on system
- Very Low: 4GB RAM, Dual-core CPU
- Low: 4GB RAM, Quad-core CPU
- Medium: 8GB RAM, Quad-core CPU
- High: 8GB+, i5+ CPU
```

### Rendering Optimization
- Forward rendering only
- Maximum 1024x768 resolution (Very Low)
- Fog-based draw distance culling
- Low-poly models (200-500 polygons)
- Aggressive LOD system
- No post-processing (Very Low)

### Memory Pooling
```gdscript
# Drone pooling
var drone_pool: Array[Drone] = []

# Zombie pooling
var max_active_zombies: int = 30  # Very Low
var max_active_zombies: int = 150 # High
```

### Network Optimization
- Unreliable RPCs for position updates
- Compressed delta updates
- Priority-based synchronization
- Server-side validation

## Unique Mechanics (8 Total)

1. **Genetic Mutations** - Player evolution with gameplay impacts
2. **Faction Dynamics** - Persistent reputation system
3. **Procedural Climate** - Weather that changes strategy
4. **Drone Automation** - Resource farming and defense
5. **Zombie Ecosystems** - Biome-specific evolution
6. **Spectre Marks** - Death location persistence
7. **Seasonal Cycles** - 4 dynamic seasons with mechanics
8. **Quantum Anomalies** - Rare teleport/gravity zones

## Configuration Files

### `project.godot`
Main project configuration:
- Resolution settings
- Rendering pipeline
- Physics settings
- Input mapping
- Auto-loaded singletons

## Development Roadmap

### Phase 1 (Core) - Current
- [x] Project structure
- [x] Core system frameworks
- [x] Player controller
- [x] Zombie AI
- [ ] Networking setup
- [ ] Scene creation

### Phase 2 (Content)
- [ ] World generation
- [ ] Item system
- [ ] Crafting system
- [ ] NPC interactions
- [ ] Quest system

### Phase 3 (Polish)
- [ ] UI/HUD
- [ ] Audio system
- [ ] Particle effects
- [ ] Animation blending
- [ ] Optimization pass

### Phase 4 (Multiplayer)
- [ ] Server architecture
- [ ] Player persistence
- [ ] Base building
- [ ] PvP mechanics

## Performance Targets

| Setting | Target FPS | Resolution | Max Draw Distance |
|---------|-----------|-----------|-----------------|
| Very Low | 30 FPS | 720p | 100m |
| Low | 45 FPS | 1024x768 | 150m |
| Medium | 60 FPS | 1280x720 | 250m |
| High | 60+ FPS | 1920x1080 | 500m |

## Contributing

To add new features:

1. Create feature branch: `git checkout -b feature/new-mechanic`
2. Implement in appropriate system script
3. Update DESIGN_DOCUMENT.md if mechanics change
4. Test on low-end hardware (Very Low preset)
5. Submit pull request

## Debugging

### Enable Debug Output
```gdscript
# In project.godot
[debug]
gdscript/warnings/unused_variable = 1
```

### Profiling
```bash
# Run with profiler
godot --profiling
```

### Network Debugging
```gdscript
# In GameManager.gd
if OS.is_debug_build():
    print("Multiplayer state: ", multiplayer.get_connection_status())
```

## Known Limitations

- Godot 4.2 doesn't support DX10 directly (uses OpenGL/Vulkan)
- Some advanced physics behaviors may need custom implementation
- UI system requires more manual setup than Unity UGUI

## References

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Manual](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot 4 Migration Guide](https://docs.godotengine.org/en/stable/about/about_versions.html)
- [Original Unturned Game](https://store.steampowered.com/app/304930/Unturned/)

## License

[Add your license here]

## Support

For issues and questions:
- Open GitHub Issue
- Check DESIGN_DOCUMENT.md
- Review Godot documentation

---

**Last Updated**: January 2026
**Engine**: Godot 4.2+
**Status**: Active Development
