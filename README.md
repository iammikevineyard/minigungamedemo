# Minigunner Prototype

A small Three.js prototype for testing the armored minigunner fantasy before building the zombie horde around it.

## Run

```bash
npm install
npm run dev
```

Open `http://127.0.0.1:5173`.

## Controls

- `WASD`: move
- Mouse: aim
- Hold left mouse button: spin/fire the minigun
- Mouse wheel: pull the camera in/out

## Current Features

- Infinite zombie pressure waves
- Destroyable low-poly zombie targets
- Blood impact particles and ground splatter decals
- Minigun spin-up/spin-down
- Animated belt feed from backpack to receiver
- Shell casing ejection
- Camera zoom HUD, wave counter, and kill counter

## Audio

Sound-design targets and generation prompts are in `docs/audio-prompts.md`.

Current wired asset:

- `audio/minigun-spin-up.wav`: minigun spin-up, plays once when firing begins.
- `audio/minigun-sustained-loop.wav`: sustained minigun loop, loaded and ready to wire into the firing state.
- `audio/minigun-casing-loop.wav`: shell casing loop, loaded and ready to layer under sustained fire.
- `audio/zombie-impact-layer.wav`: pooled zombie bullet-impact layer, triggered during hits.
- `audio/zombie-death.wav`: pooled zombie death hit, triggered when a zombie is destroyed.

## Verify

```bash
npm run build
npm run verify
```

The verifier opens the scene in headless Edge, presses `W`, fires the weapon, saves desktop/mobile screenshots, and samples the WebGL canvas pixels.
