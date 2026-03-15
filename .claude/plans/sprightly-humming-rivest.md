# Plan: Build Level 02 and Level 03

## Context
Level 01 (`scenes/level.tscn`) exists and works. We need two new levels that reuse the exact same node structure, instanced scenes, and game flow. The game_manager, player, hazard scenes, door, and spirit_trail are all already built and working.

## Key Architecture Notes (from codebase exploration)
- **Level structure**: Node2D root → GameManager, CanvasLayer/Label, StartMarker, Player instance, Environment (StaticBody2D platforms), Traps (hazard instances), Door instances
- **Floor pattern**: StaticBody2D with Sprite2D (icon.svg, dark modulate) + CollisionShape2D (RectangleShape2D 128x128), scaled on X axis
- **Hazard groups**: "traps" (spikes, turret, flamethrower) and "enemies" (melee_monster) — all receive `set_active(bool)` via group calls
- **Door**: Area2D with exported `next_level_path: String`, calls `game_manager.complete_level(path)`
- **Camera2D**: Child of Player in `player.tscn`. Can override `limit_*` properties per-level
- **Melee monster**: Patrols using RayCast2D edge detection + wall detection — no explicit patrol bounds. Need invisible StaticBody2D walls to constrain patrol range
- **Flamethrower timing**: `is_firing` starts `false`. `set_active(true)` starts Timer. First timeout → `start_firing()`. Timer `wait_time` controls initial delay before first fire. Override Timer's `wait_time` in .tscn to control offset

## Files to Create

### 1. `scenes/level_02.tscn` — "The Turret Problem"
**Bounds**: 2400×600. Same ext_resources as level.tscn (player, game_manager, spirit_trail, spikes, melee_monster, turret, door, icon.svg).

Node tree:
```
Level (Node2D)
├── GameManager (Node) — script, player_node, spirit_trail_scene
├── CanvasLayer → Label (HUD text)
├── StartMarker (Marker2D, group "start_marker") — pos (80, 460)
├── Player (instance player.tscn) — pos (80, 460)
│   └── Camera2D override: limit_left=0, limit_top=0, limit_right=2400, limit_bottom=600
├── Environment (Node2D)
│   ├── Floor (StaticBody2D) — pos (1200, 564), scale (19, 1)
│   │   ├── Sprite2D (dark modulate, icon.svg)
│   │   └── CollisionShape2D (RectangleShape2D 128×128)
│   └── RaisedPlatform (StaticBody2D) — pos (1100, 350)
│       ├── Sprite2D (dark modulate, icon.svg)
│       └── CollisionShape2D (RectangleShape2D 400×32) ← sub_resource
├── Traps (Node2D)
│   ├── Spikes (spikes.tscn) — pos (450, 475) — covers x≈400–500 on floor
│   ├── Spikes2 (spikes.tscn) — pos (1550, 475) — covers x≈1500–1600
│   ├── Turret (turret.tscn) — pos (1100, 310) — on raised platform
│   └── MeleeMonster (melee_monster.tscn) — pos (1900, 460)
├── MonsterWallLeft (StaticBody2D) — pos (1700, 470), thin collision (16×80) — invisible patrol bound
├── MonsterWallRight (StaticBody2D) — pos (2100, 470), thin collision (16×80) — invisible patrol bound
└── Door (door.tscn) — pos (2300, 460), next_level_path = "res://scenes/level_03.tscn"
```

### 2. `scenes/level_03.tscn` — "The Flamethrower Sync"
**Bounds**: 2800×700. Uses all hazard types including flamethrower.

Node tree:
```
Level (Node2D)
├── GameManager, CanvasLayer/Label (same pattern)
├── StartMarker — pos (80, 560)
├── Player (instance player.tscn) — pos (80, 560)
│   └── Camera2D override: limit_left=0, limit_top=0, limit_right=2800, limit_bottom=700
├── Environment (Node2D)
│   ├── MainFloor (StaticBody2D) — pos (1400, 664), scale (22, 1) — y=600 top
│   ├── PlatformA (StaticBody2D) — pos (1200, 450) — 200×32, x=1100–1300, y=450
│   ├── PlatformB (StaticBody2D) — pos (1200, 300) — 200×32, x=1100–1300, y=300
│   ├── PlatformC (StaticBody2D) — pos (1200, 150) — 200×32, x=1100–1300, y=150
│   └── UpperCorridor (StaticBody2D) — pos (2000, 150) — 1400×32, x=1300–2700, y=150
├── Traps (Node2D)
│   ├── Spikes (spikes.tscn) — pos (475, 575) — x=400–550 on main floor
│   ├── MeleeMonster (melee_monster.tscn) — pos (750, 560) — patrol x=600–900
│   ├── FlamethrowerA (flamethrower.tscn) — pos (1250, 425), rotation=0 (fires right)
│   │   └── Timer override: wait_time=0.01 (starts firing immediately = "starts ON")
│   ├── FlamethrowerB (flamethrower.tscn) — pos (1700, 125), rotation=0 (fires right)
│   │   └── Timer override: wait_time=2.5 (2.5s delay = "starts OFF, offset")
│   └── Turret (turret.tscn) — pos (2200, 110) — on upper corridor
├── MonsterWallLeft (StaticBody2D) — pos (600, 570), thin collision (16×80)
├── MonsterWallRight (StaticBody2D) — pos (900, 570), thin collision (16×80)
└── Door (door.tscn) — pos (2650, 110), next_level_path = "res://scenes/main_menu.tscn"
```

**Flamethrower offset timing verification**:
- Both: cycle_time=5.0, active_time=3.0 (3s on, 2s off)
- A fires at t=0.01→3, off 3→5, on 5→8...
- B fires at t=2.5→5.5, off 5.5→7.5, on 7.5→10.5...
- Both-off windows: NONE. They always stagger. Design intent met.

### 3. Update `scenes/level.tscn` — Wire level_01 door to level_02
Set `next_level_path = "res://scenes/level_02.tscn"` on the existing Door node.

### 4. Update `scripts/main_menu.gd` — Play button targets level_01
Currently points to `"res://scenes/level.tscn"` (level_01). No change needed — this is correct.

## Flamethrower "starts ON" Implementation
The flamethrower script flow: `_ready()` → `set_active(is_active)`. `is_active` defaults false. GameManager calls `set_active(true)` when body phase starts, which calls `timer.start()`. First timeout (after `wait_time`): `start_firing()`.

To make Flamethrower A fire immediately when body phase starts: set Timer `wait_time = 0.01`.
To offset Flamethrower B by 2.5s: set Timer `wait_time = 2.5`.

Override Timer wait_time in .tscn via child node property override:
```
[node name="Timer" parent="Traps/FlamethrowerA" index="1"]
wait_time = 0.01
```

## Monster Patrol Bounds
The melee_monster uses RayCast2D for edge detection and `is_on_wall()` for wall detection. Since floors are full-width, invisible StaticBody2D walls at patrol boundaries will cause the monster to turn around. These walls are small (16×80px) and have no Sprite2D so they're invisible.

Player can jump over these walls (they're only 80px tall, player jump_velocity=-400).

## Verification
1. Open Godot → run. Main menu → Play → loads level_01
2. Complete level_01 → door transitions to level_02
3. Level 02: spikes block direct path, turret on raised platform covers corridor, melee monster patrols near exit. Must use skills to pass.
4. Complete level_02 → door transitions to level_03
5. Level 03: vertical climb with offset flamethrowers (never both off), turret on upper corridor. Must use skills to force through.
6. Complete level_03 → returns to main menu
7. Camera limits prevent scrolling beyond level bounds in all levels
