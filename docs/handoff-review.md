# Minigunner Horde Demo Handoff Review

Date: 2026-05-02  
Project: `godot-demo`  
Main implementation file: `godot-demo/scripts/Main.gd`

## Current Pitch

This is now a playable top-down horde-survival demo about an armored operator trying to hold a collapsing arena against an endless zombie swarm. The core fantasy is not precision shooting. It is pressure, volume, recoil, casings, blood, fire, and the feeling that the player is barely holding back an impossible crowd.

## Current Game Loop

The player starts in an open arena, aims with the mouse, moves with `WASD`, and survives escalating zombie waves. Zombies spawn outside the camera ring, push inward, and eventually crowd the player into an attack/eating state. The run now has an extraction objective: survive until extraction unlocks, fight to the beacon, and hold long enough to escape while the horde spikes.

Primary loop:

1. Move, aim, and manage distance from the horde.
2. Use the minigun to erase lanes through the crowd.
3. Switch to the shotgun as a close-range panic weapon.
4. Swap to the AK for controlled automatic fire when minigun ammo is too precious.
5. Use the katana as a risky close-range melee answer when surrounded.
6. Throw grenades to the clicked ground position to create damage and fire zones.
7. Unlock extraction at Wave 5 or 250 kills.
8. Reach the extraction beacon and hold the zone for 25 seconds.
9. Either extract for a score bonus or die, then enter initials for the local arcade leaderboard.
10. Restart with `R`.

Current controls:

- `WASD`: move
- Mouse: aim
- Left mouse: fire selected weapon
- Right mouse: throw grenade to clicked ground position
- `1`: minigun
- `2`: shotgun prototype
- `3`: AK
- `4`: katana melee
- Mouse wheel: camera zoom
- Space: pause
- On death: type initials, Enter to submit, `R` to restart after submitting

## Current Systems

### Player

- Uses the imported shooter pack character: `assets/models/shooter_pack/Ch35_nonPBR.fbx`.
- Locomotion clips are copied from the shooter pack and stripped of horizontal root motion so the model stays with the weapon rig.
- The player aims independently of movement, which is important for the omni-directional shooter feel.
- Current death state tilts/collapses the player while nearby zombies stay in attack animations to imply being eaten.

### Weapons

Minigun:

- Uses `assets/models/rotarycannonfbx.glb`.
- Has spin-up/spin-down, barrel rotation, muzzle flash, long tracers, casing ejection, belt feed, ammo backpack, recoil, camera shake, FOV punch, and layered audio.
- Audio includes spin-up, sustained fire loop, casing loop, zombie impact, zombie death, and `Turbo Black.mp3` as music.
- Now has finite backpack ammo. Current starting ammo: 1200 rounds.

Shotgun:

- Implemented as a secondary weapon on `2`.
- Currently uses a procedural visual shotgun because the uploaded shotgun archive contains `m3_benelli_final.max`, which Godot cannot import directly.
- Gameplay is active: short-range cone damage, cooldown, knockback, gore, tracers, casing ejection, and weapon HUD state.
- To use the actual shotgun asset, export the `.max` file to `.glb`, `.gltf`, or `.fbx`.
- Now has finite shell ammo. Current starting ammo: 36 shells.

AK:

- Implemented as weapon slot `3`.
- Uses `assets/models/rainier_ak_-_3d.glb`.
- Automatic hitscan rifle with muzzle flash, tracers, casing ejection, recoil, and finite ammo.
- Current starting ammo: 240 rounds.
- The model imports successfully but is large and mesh-heavy, so it may eventually want a lighter optimized version.

Katana:

- Implemented as weapon slot `4`.
- Uses `assets/models/katana.glb`.
- Close-range melee arc with cooldown, hit stop, knockback, and blood effects.
- No ammo, but the range is deliberately dangerous.

Grenades and fire:

- Right-click throws toward the clicked ground position using an arc.
- Grenades explode, spawn impacts, create fire patches, ignite zombies, and damage the player if the player stands in fire.
- Fire gives the demo an important risk/reward tool. It lets the player shape space but can punish panic throws.

### Zombies

- Uses the Scary Zombie Pack model: `assets/models/scary_zombie_pack/Warzombie F Pedroso.fbx`.
- Walk, run, attack, idle, and death clips are copied into each zombie instance.
- Current cap is `MAX_ZOMBIES = 120`.
- Zombie types:
  - Normal zombies: baseline horde pressure.
  - Runners: faster, lower-health pressure.
  - Heavy zombies: tougher, higher-damage bodies.
  - Big zombies: high health, high damage, do not get pushed back by weapon fire, grenade blast, fire ticks, or crowd separation.
- A lightweight separation pass keeps zombies from fully clipping into each other.

### UI and Meta

- Giant kill counter.
- HP bar.
- Wave, kills, camera, spin, and zombie count HUD.
- Weapon mode display for `[1] MINIGUN` and `[2] SHOTGUN`.
- Weapon slots now display `[1] MINIGUN`, `[2] SHOTGUN`, `[3] AK`, and `[4] KATANA` with ammo/cooldown status.
- Extraction HUD: locked state, beacon distance, hold timer, extracted score state.
- Absurd multi-kill titles, including higher-tier jokes like `APOCALYPSE MULCHER` and `EXTINCTION EVENT`.
- Pause overlay.
- Death and extracted overlays with initials entry.
- Persistent leaderboard saved to `user://leaderboard.json`.

### Extraction

- Extraction unlocks at Wave 5 or 250 kills.
- A green extraction beacon spawns toward the arena edge.
- The player must hold inside the beacon for 25 seconds.
- While extraction is open, spawn pressure increases and periodic big zombies are forced into the mix.
- Successful extraction adds a score bonus plus wave and remaining-health bonuses before saving to the leaderboard.

## Combat Feel Review

### What Feels Good

The minigun is the strongest part of the demo. The spin-up delay, barrel motion, audio layering, shell casings, and long bullet stream make the weapon feel like machinery rather than a normal gun. It has weight.

The horde pressure is also starting to work. Raising the zombie cap, increasing spawn rate, and adding separation makes the arena read as a living swarm instead of a few isolated enemies. The player can get surrounded, and the death screen supports that fantasy.

The shotgun prototype is surprisingly useful even without the real model. It gives the player a second rhythm: the minigun is sustained lane control, while the shotgun is a sharp panic burst. That contrast is good and should stay.

The AK and katana make the loadout feel more like a survival kit. The AK is the conservative ammo tool. The katana is the panic/ego tool: it saves ammo but asks the player to stand where they probably should not be.

Grenades are now more tactical because they go where the player clicks. Fire patches add area denial and make the arena feel more chaotic.

Blood, casings, fire, and the kill counter give the fight a nice accumulating history. The scene looks more and more wrecked as the run continues, which supports the arcade-survival loop.

Extraction gives the run a needed second act. It changes the objective from "survive forever" into "survive long enough, then cross the map and hold while everything gets worse." That is closer to the barely-got-out-alive feeling.

### What Still Feels Weak

The player and weapons are still visually hacked together. The minigun works better than before, but the character is not truly authored to hold such a heavy weapon. The shotgun visual is procedural and should be replaced with the actual model once exported.

The zombies have good assets, but their attack/eating behavior is still animation-lite. They crowd and attack, but there is not yet a custom finishing animation, grab state, or synced death sequence. The current death moment sells the idea with camera, crowding, and posture, not with authored choreography.

The arena is functional but still abstract. It has buildings, lights, debris, fire, and blood, but not yet strong level-design beats. The player mostly fights in open space. More lanes, chokepoints, barricades, and danger zones would make the game loop smarter.

The scoring loop is improving now that extraction gives a run endpoint, but it still needs more motivation. Leaderboards help, but there are no pickups, streak rewards, reload/heat choices, upgrades, or score multipliers yet.

Ammo is now present, but it is still only a starting pool. The next step is pickups, reload/overheat states, or extraction crates so running out creates decisions instead of just a dead end.

The audio stack is good for the minigun, but the shotgun needs its own punch, pump, and impact layers. Fire needs looping crackle. Zombies need ambient crowd pressure.

## Biggest Design Risk

The biggest risk is that the demo becomes visually busy but mechanically flat. The core fun is already there, but to become a real "hot damn" demo it needs more decisions under pressure:

- Do I hold the minigun lane or switch to shotgun?
- Do I throw fire at my feet and risk self-damage?
- Do I kite around the big zombie or burn grenades to remove it?
- Do I chase score streaks or survive?

The extraction layer helps, but the next layer should be controlled panic, not just more particles. The player should be making desperate tradeoffs in the last 30 seconds of a run.

## Recommended Next Tasks

1. Export the shotgun from `.max` to `.glb` or `.fbx`, then replace the procedural shotgun model.
2. Add shotgun audio: blast, pump, reload/chamber, close impact layer.
3. Add pickups: grenade refills, ammo/heat vents, health stims, temporary damage boosts.
4. Add upgrades between waves or after objectives: faster spin-up, wider shotgun cone, longer fire duration, bigger backpack ammo.
5. Add limited ammo or heat so the extraction hold becomes resource pressure instead of pure DPS.
6. Add score multipliers for risky play: close kills, burning chains, shotgun multikills, no-damage streaks.
7. Add Bite, Bleed, and Burn status effects once core pacing is stable.
8. Add zombie hit reactions by type: normal flinch, runner tumble, big zombie armor-like non-reaction.
9. Add a more authored death/eating sequence if we can get suitable animations.
10. Split `Main.gd` into smaller scripts once gameplay stabilizes: player, weapons, zombies, effects, HUD, leaderboard.
11. Add a simple title/start screen if this becomes a shareable demo build.
12. Add performance profiling around 120 zombies, 760 blood decals, 240 casings, fire patches, and extraction pressure.

## Dynamic Environment Plan

The arena should stop feeling like a flat test pad and start behaving like a collapsing combat zone.

Recommended sequence:

1. Add destructible props: cars, fences, barricades, gas tanks, streetlights, and crates.
2. Add explosive chain reactions: gas tanks ignite zombies, parked cars become temporary fire blockers, power boxes arc electricity.
3. Add extraction events: when extraction unlocks, floodlights snap on, sirens start, gates open, and zombie spawns redirect toward the beacon.
4. Add environmental cover that degrades under horde pressure.
5. Add moving hazards: fire spreading across oil slicks, collapsing debris, alarm zones that pull screamers.
6. Add loot objects: ammo crates, grenade boxes, medkits, heat vents, weapon pickups.
7. Add a few authored map landmarks so players learn routes and chokepoints.

## Future Mech Pilot Plan

The `combat_robot.glb` in the project root loads successfully and could become a Helldivers-style emergency call-in later. Best version:

1. Earn a mech beacon after an objective or rare drop.
2. Throw beacon, wait through a vulnerable delivery timer.
3. Enter robot for 30-60 seconds of high power.
4. Robot has limited ammo, stomps, heavy cannon, and overheat.
5. When destroyed or expired, eject the player back into the horde.

This should come after pickups/objectives are working, because the robot needs to feel earned.

## Future Screamer Bomber Plan

Monster variation concept: a fast screaming infected that explodes and applies Burn.

Gameplay spec:

- Spawns rarely after Wave 4, more during extraction.
- Emits a visible pulse and loud scream before sprinting.
- Low health, very fast, ignores mild stagger.
- On death or close contact, explodes into a small fire burst.
- Applies Burn to the player and nearby zombies.
- Counterplay: kill it early, dodge behind cover, or bait it into the horde for chain damage.

Needed assets:

- Screamer audio loop or one-shot.
- Distinct material tint or silhouette.
- Warning UI/screen-edge cue.
- Fire burst effect can reuse the grenade fire system.

## Questions For You

1. Should the fantasy stay "one doomed last stand" or become more arcade, with pickups, upgrades, and score-chasing?
2. Should the minigun have infinite ammo forever, or should it use heat, reload, or backpack ammo as a pressure mechanic?
3. Do you want the shotgun as a true secondary weapon, or should it be a pickup/panic cooldown?
4. How dangerous should fire be to the player: mild positioning tax or serious self-kill risk?
5. Should big zombies be rare mini-bosses, or should late waves contain several at once?
6. Do you want the gore to stay stylized and readable, or get more realistic and messy?
7. Should the camera stay top-down/isometric, or should death/replay moments use more cinematic close shots?
8. Do you want a real exported shotgun model, or should we keep using procedural placeholders until the core gameplay is locked?
9. Should the leaderboard be local-only, or do you eventually want an online score table?
10. What is the target demo length: 60-second spectacle, 5-minute arcade run, or an endless survival toy?

## Asset Status

Ready and used:

- Shooter character pack.
- Scary zombie pack.
- Rotary cannon GLB.
- AK GLB.
- Katana GLB.
- Minigun audio layers.
- Zombie impact/death audio.
- `Turbo Black.mp3` background music.

Available but not yet fully usable:

- `max_arnold.zip` shotgun archive. It contains `m3_benelli_final.max`, textures, and renders. It needs export to `.glb`, `.gltf`, or `.fbx`.

## Technical Notes

The project currently works as a single-scene Godot 4.6 demo. Most gameplay lives in `godot-demo/scripts/Main.gd`, which is now large. That was fine for rapid prototyping, but the next serious pass should split systems out before adding much more complexity.

Current validation command:

```powershell
& "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.2-stable_win64_console.exe" --path "C:\Users\User\Documents\Claude\Projects\RPG Demo\godot-demo" --quit-after 5
```

Current run command:

```powershell
& "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.2-stable_win64.exe" --path "C:\Users\User\Documents\Claude\Projects\RPG Demo\godot-demo"
```
