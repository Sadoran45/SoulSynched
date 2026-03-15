# Soul Synched - Current Game State

## What Is It?
A 2D puzzle-platformer with a unique dual-phase mechanic. You play as a soul that plans ahead as a ghost, then executes the plan in a physical body.

## How It Works

### Two Phases

**Spirit Phase (Planning)**
- You're a ghost — fly freely through the level with no collision or gravity
- All hazards are visible but grayed out and harmless
- You place exactly 3 skill trails anywhere on the map using keys 1/2/3
- Each trail can be rotated with the mouse before confirming with click
- Once all 3 trails are placed, the Body Phase begins

**Body Phase (Execution)**
- You respawn at the start as a normal platformer character
- All hazards activate — spikes hurt, enemies patrol, turrets shoot
- You must collect your placed skill trails to gain abilities
- Goal: reach the exit door alive

### Skills (Collected from Trails)
| Skill | Key | Color | What It Does |
|-------|-----|-------|--------------|
| Double Jump | 1 | Green | Extra mid-air jump in the direction the trail was rotated |
| Shield | 2 | Yellow | 3 seconds of damage immunity |
| Fireball | 3 | Red | Shoots a projectile in the trail's aimed direction |

### Player Stats
- 3 HP in Body phase
- 2s spawn protection at start of Body phase
- 1s invincibility frames after taking damage
- Dies at 0 HP → level restarts from Spirit phase

## Hazards

| Hazard | Behavior | Can Be Destroyed? |
|--------|----------|-------------------|
| **Spikes** | Static damage zone on the ground | No |
| **Melee Monster** | Patrols back and forth, turns at edges | Yes (1 fireball) |
| **Turret** | Tracks and shoots the player (3 shots, then 3s reload) | Yes (1 fireball) |
| **Flamethrower** | Fires flames in a fixed direction — 3s on, 2s off cycle, 300px range | No |

## Controls
- **Move:** WASD / Arrow Keys
- **Jump:** Space / Enter
- **Place Trail (Spirit):** 1 / 2 / 3
- **Rotate & Confirm Trail:** Mouse + Left Click

## Current Level Layout
- One wide horizontal level with a single floor platform
- Start on the left, exit doors on the right and upper-right
- Hazards spread across the level: spikes, a melee monster, a turret, and a flamethrower
- Two exit doors (no level progression yet — both show "You Win!")

## Visuals
- All art is placeholder (Godot icon with color tints)
- Color-coded elements: blue ghost, green/yellow/red trails, orange enemies, red spikes
- Particle effects on the flamethrower (orange-to-red flame)
- Flashing effects for invincibility and shield

## What's Working
- Full Spirit → Body phase loop
- All 3 skills (double jump, shield, fireball)
- Trail placement with rotation aiming
- All 4 hazard types active and dealing damage
- Fireball can destroy turrets and monsters
- Door exit and win condition
- Camera follow with smoothing

## What's Missing / Could Be Added
- Only 1 level — no progression or level select
- No real art — everything is placeholder
- No sound effects or music
- No main menu or pause menu
- No score or timer system
- Doors don't lead anywhere yet
- No tutorial or onboarding
- No save system

## The Core Question
The puzzle is: **where do you place your 3 skills to make the level beatable?** You scout the level as a ghost, plan your route, then execute. Wrong placement = restart.

---

*Share this with friends and ask: What would make this more interesting? What hazards/skills/mechanics would you add?*
