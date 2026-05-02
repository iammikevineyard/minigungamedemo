# Minigunner Horde Demo

Godot 4.6 demo scene for the armored minigunner horde prototype.

## Run

Open this folder in Godot and run the main scene:

```powershell
godot --path .\godot-demo
```

If `godot` is not on PATH yet, this install currently lives at:

```powershell
$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.2-stable_win64.exe
```

Direct run with the installed executable:

```powershell
& "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.2-stable_win64.exe" --path "C:\Users\User\Documents\Claude\Projects\RPG Demo\godot-demo"
```

## Controls

- `WASD`: move
- `Mouse`: aim
- `Left mouse`: spin up and fire
- `Mouse wheel`: pull camera in/out

## Current Features

- Imported FSB operator player model.
- Imported zombie GLB wave enemies with procedural lurching and fall-over deaths.
- Procedural six-barrel minigun with spin-up/spin-down, muzzle flash, long tracers, shell casings, impact puffs, blood drops, and floor decals.
- Belt-fed ammo backpack with animated brass feed belt.
- Infinite escalating zombie waves.
- Layered minigun, casing, zombie impact, and death audio.

## Notes

The Universal Animation Library is imported and available, but the uploaded operator/zombie skeletons do not directly share that rig. For this demo pass, the real models are used for visual fidelity and procedural motion handles the missing walk-cycle retargeting.
