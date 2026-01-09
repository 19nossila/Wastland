# Unity to Godot Conversion Guide

## Overview

This document maps concepts from the original Unity/Unturned codebase to the new Godot implementation.

## Language & Syntax Changes

### Class Definitions

**Unity C#:**
```csharp
public class PlayerCharacter : MonoBehaviour
{
    public float health = 100f;
    
    public void TakeDamage(float amount)
    {
        health -= amount;
    }
}
```

**Godot GDScript:**
```gdscript
extends CharacterBody3D
class_name PlayerCharacter

var health: float = 100.0

func take_damage(amount: float):
    health -= amount
```

### Inheritance

| Unity | Godot | Purpose |
|-------|-------|---------|
| `MonoBehaviour` | `extends Node` | Base game object |
| `Transform` | `position`, `rotation`, `scale` | Position/rotation |
| `Collider` | `CollisionShape3D` | Physics collision |
| `RigidBody` | `RigidBody3D` | Physics object |
| `CharacterController` | `CharacterBody3D` | Player movement |

### Lifecycle Methods

| Unity | Godot | When Called |
|-------|-------|-----------|
| `Start()` | `_ready()` | First frame initialization |
| `Update()` | `_process(delta)` | Every frame |
| `LateUpdate()` | N/A | Use `_process()` in order |
| `FixedUpdate()` | `_physics_process(delta)` | Physics updates |
| `OnDestroy()` | `queue_free()` / `_exit_tree()` | When destroyed |

### Properties & Attributes

**Unity:**
```csharp
[SerializeField] private float speed = 10f;
[Export] public float Damage = 15f;
```

**Godot:**
```gdscript
@export var speed: float = 10.0
@export var damage: float = 15.0
```

## System Architecture

### GameManager (Godot MultiplayerAPI)

**Unity (Netcode for GameObjects):**
```csharp
public class GameManager : NetworkBehaviour
{
    public void SyncGameState()
    {
        if (IsServer)
        {
            BroadcastGameState();
        }
    }
}
```

**Godot:**
```gdscript
extends Node
class_name GameManager

func sync_game_state():
    if is_multiplayer_authority():
        rpc("receive_game_state", state)
```

### RPC Communication

**Unity:**
```csharp
[ServerRpc]
public void TakeDamageServerRpc(float amount) { }

[ClientRpc]
public void OnDamageTakenClientRpc(float amount) { }
```

**Godot:**
```gdscript
@rpc("authority")
func take_damage(amount: float):
    pass

@rpc
func on_damage_taken(amount: float):
    pass
```

## Core Systems Mapping

### Mutation System

**Original Unturned Approach:**
- Mutations stored in player serializable data
- Applied via prefabs and shader swaps
- Networked via `NetworkVariable`

**Godot Implementation:**
```gdscript
class_name MutationSystem

var player_mutations: Dictionary = {}  # player_id -> mutations

func add_mutation(player_id: int, mutation_type: String, intensity: float):
    # Store in dictionary, sync via RPC
    sync_mutations.rpc_id(1, player_id)
```

### Faction System

**Original:**
- XML-based configuration
- SQL database for persistence
- Event-driven reputation changes

**Godot:**
```gdscript
class_name FactionSystem

var faction_reputation: Dictionary = {}

func add_reputation(player_id: int, faction: String, amount: int):
    faction_reputation[player_id][faction] += amount
    sync_faction_reputation.rpc_id(1, player_id)
```

### Weather System

**Original:**
- Singleton weather manager
- ParticleSystems for visual effects
- LOD system for low-end

**Godot:**
```gdscript
class_name WeatherSystem

const WEATHER_TYPES = { ... }
var current_weather: String = "clear"

func _process(delta):
    weather_timer += delta
    if weather_timer >= weather_duration:
        spawn_random_weather()
```

### Drone System

**Original:**
- Pathfinding with A* (many points)
- Complex AI behavior trees
- Expensive particle effects

**Godot (Optimized):**
```gdscript
class_name DroneSystem

class Drone:
    var position: Vector3
    var battery: float
    var active: bool
    
    func update(delta: float):
        battery = max(0, battery - drain_rate * delta)

var active_drones: Array = []
```

## Physics & Movement

### Character Movement

**Unity:**
```csharp
if (Input.GetKey(KeyCode.W))
{
    controller.Move(transform.forward * speed * Time.deltaTime);
}
```

**Godot:**
```gdscript
if Input.is_action_pressed("ui_w"):
    velocity = Vector3.FORWARD * speed

move_and_slide()
```

### Raycasting

**Unity:**
```csharp
if (Physics.Raycast(origin, direction, out RaycastHit hit, distance))
{
    Debug.Log("Hit: " + hit.collider.name);
}
```

**Godot:**
```gdscript
var space_state = get_world_3d().direct_space_state
var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * distance)
var result = space_state.intersect_ray(query)

if result:
    print("Hit: ", result.collider.name)
```

## Asset Pipeline

### 3D Models

**Unity Workflow:**
1. Create in Blender/Maya
2. Export as FBX
3. Import to Unity (automatic optimization)
4. Adjust LOD groups

**Godot Workflow:**
1. Create in Blender/Maya
2. Export as GLTF 2.0 (.glb)
3. Import to Godot (preserves hierarchy)
4. Configure in GeometryInstance3D

### Textures & Materials

**Unity:**
```csharp
material.color = new Color(r, g, b, a);
material.SetFloat("_Intensity", 0.5f);
```

**Godot:**
```gdscript
material.albedo_color = Color(r, g, b, a)
material.set_shader_parameter("intensity", 0.5)
```

### Shaders

**Unity (HLSL/Cg):**
```shader
Shader "Custom/Mutation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
}
```

**Godot (GLSL):**
```glsl
shader_type spatial;

uniform sampler2D main_tex: source_color;

void fragment() {
    ALBEDO = texture(main_tex, UV).rgb;
}
```

## UI System

**Unity (uGUI):**
```csharp
public class HUDManager : MonoBehaviour
{
    public Text healthText;
    
    void Update()
    {
        healthText.text = "Health: " + health;
    }
}
```

**Godot:**
```gdscript
extends CanvasLayer

@onready var health_label = $VBoxContainer/HealthLabel

func _process(delta):
    health_label.text = "Health: %f" % health
```

## Audio

**Unity:**
```csharp
AudioSource audioSource = GetComponent<AudioSource>();
audioSource.PlayOneShot(clip);
```

**Godot:**
```gdscript
var audio_player = AudioStreamPlayer3D.new()
add_child(audio_player)
audio_player.stream = preload("res://assets/audio/sound.ogg")
audio_player.play()
```

## Input System

**Unity:**
```csharp
if (Input.GetKeyDown(KeyCode.Space))
{
    Jump();
}
```

**Godot:**
```gdscript
if Input.is_action_just_pressed("ui_select"):
    jump()
```

## Performance Optimization

### Object Pooling

**Unity:**
```csharp
public class ObjectPool : MonoBehaviour
{
    private Queue<GameObject> availableObjects;
    
    public GameObject Get()
    {
        return availableObjects.Count > 0 ? availableObjects.Dequeue() : 
            Instantiate(prefab);
    }
}
```

**Godot:**
```gdscript
var drone_pool: Array[Drone] = []

func get_drone() -> Drone:
    if drone_pool.is_empty():
        return Drone.new()
    return drone_pool.pop_back()
```

### LOD System

**Unity:**
```csharp
LODGroup lodGroup = GetComponent<LODGroup>();
```

**Godot:**
```gdscript
@onready var lod_near = $LOD_Far
@onready var lod_far = $LOD_VeryFar

func _process(delta):
    var distance = camera.global_position.distance_to(global_position)
    lod_near.visible = distance < 100
    lod_far.visible = distance >= 100
```

### Memory Management

**Unity (Automatic GC):**
```csharp
Destroy(gameObject);  // Scheduled destruction
```

**Godot (Deferred):**
```gdscript
queue_free()  # Deferred destruction at end of frame
```

## Networking Differences

### Player Synchronization

**Unity (Netcode):**
```csharp
[DefaultExecutionOrder(-1)]
public partial class PlayerNetworkTransform : NetworkBehaviour
{
    [NetworkVariable] private NetworkVariable<Vector3> NetworkPosition;
}
```

**Godot:**
```gdscript
var network_position: Vector3 = Vector3.ZERO

@rpc("authority")
func update_position(pos: Vector3):
    network_position = pos
    global_position = pos
```

## File Structure Comparison

### Unity Project
```
Assets/
├── Scripts/
│   ├── Player/
│   ├── Zombies/
│   └── Managers/
├── Scenes/
├── Prefabs/
├── Resources/
├── Textures/
└── Models/
```

### Godot Project
```
res://
├── scripts/
│   ├── player/
│   ├── ai/
│   ├── systems/
│   └── managers/
├── scenes/
├── assets/
│   ├── models/
│   ├── textures/
│   └── shaders/
└── project.godot
```

## Common Pitfalls & Solutions

### Issue: Performance drops on low-end
**Solution:** Use quality presets with LOD system

### Issue: Network synchronization lag
**Solution:** Use unreliable RPCs for frequent updates, reliable for critical

### Issue: Memory leaks
**Solution:** Always use `queue_free()`, not `free()`

### Issue: Physics behaving differently
**Solution:** Adjust physics settings in `project.godot`, use `move_and_collide()` for more control

## Migration Checklist

- [ ] Port all C# classes to GDScript
- [ ] Replace Unity API calls with Godot equivalents
- [ ] Set up NetworkManager for MultiplayerAPI
- [ ] Convert shaders to GLSL
- [ ] Import 3D models and textures
- [ ] Create UI scenes (.tscn)
- [ ] Test on low-end hardware configuration
- [ ] Optimize draw calls and LOD
- [ ] Implement server validation
- [ ] Test multiplayer functionality

## Additional Resources

- [Godot C# to GDScript Migration](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/migrating_to_gdscript.html)
- [Godot Networking Tutorial](https://docs.godotengine.org/en/stable/tutorials/networking/index.html)
- [Godot 3D Performance Tips](https://docs.godotengine.org/en/stable/tutorials/3d/using_3d_characters/index.html)
- [GDScript Performance](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)

---

**Last Updated**: January 2026
**Godot Version**: 4.2+
**Conversion Status**: In Progress
