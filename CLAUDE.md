# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Soul Synched** is a 2D puzzle-platformer built in Godot 4.6 (GDScript). The core mechanic is a dual-phase gameplay loop:

1. **Spirit Phase** — Player is a ghost (no collision/gravity) and places 3 skill trails on the level
2. **Body Phase** — Player respawns at StartMarker with physics enabled and must collect the placed skills to reach the exit door

## Running the Project

Open in Godot 4.6+ and run. Main scene: `res://scenes/level.tscn`. No external build tools, plugins, or package managers. Jolt Physics is the physics engine (built-in).

## Architecture

### Core Game Loop (GameManager → Player)

`GameManager` (`scripts/game_manager.gd`) orchestrates phase transitions. It tracks trail placements (max 3), switches the player between SPIRIT/BODY states, and uses group-based calls (`get_tree().call_group()`) to activate/deactivate all hazards on phase change.

`Player` (`scripts/player.gd`) implements a state machine with SPIRIT and BODY states that control movement speed, collision, gravity, and visual appearance. Skills (double jump, shield, fireball) are granted by collecting `SpiritTrail` pickups during Body phase only.

### Hazard System

All hazards (`trap.gd`, `turret.gd`, `melee_monster.gd`, `flamethrower.gd`) implement a `set_active(active: bool)` method. They are inactive (grayed out) during Spirit phase and activated during Body phase via the "traps" and "enemies" groups.

### Signal Flow

- `player.player_died` → GameManager restarts the level
- `SpiritTrail` collision → `player.activate_skill(skill_name)` (Body phase only)
- Hazards deal damage via Area2D overlap detection

### Input Map

- Movement: WASD / Arrow Keys
- Accept/Place: Space / Enter

## GDScript Conventions

- Scenes in `scenes/`, scripts in `scripts/`
- Hazard scenes use colored rectangles as placeholder visuals
- Player uses invincibility frames (1.0s post-damage) and spawn protection (2.0s)
