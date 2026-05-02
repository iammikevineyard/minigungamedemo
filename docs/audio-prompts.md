# Minigun Audio Targets

These values match the current prototype constants in `src/main.js`.

## Exact Timing

- Barrel cluster full spin: `76 rad/s` = `725.7 rotor RPM`
- Barrels: `6`
- Fire threshold: `spin > 0.68`
- Fire rate at threshold: `33.04 rounds/s` = `1,982 RPM`
- Fire rate at normal sustained spin, around `0.95`: `40.6 rounds/s` = `2,436 RPM`
- Maximum fire rate: `42 rounds/s` = `2,520 RPM`
- Belt feed at full spin: `42.12 rounds/s` = `2,527 RPM`
- Spin-up curve: reaches firing threshold in about `0.32s`, reaches about `95%` in about `0.83s`
- Spin-down curve: drops from `95%` to `50%` in about `0.28s`, nearly stopped around `1.28s`

## Prompts

### 1. Spin-Up

Create a dry, close-mic sound effect for a six-barrel sci-fi minigun spinning up from complete stop to full speed. Duration 0.85 seconds. The barrel cluster accelerates to 725 RPM with a heavy electric motor whine, metal bearings, a rising turbine-like mechanical pitch, and subtle belt-feed clicks. No gunshots, no explosions, no music, no voice. Dark military sci-fi tone, powerful but not cartoonish, suitable for seamless transition into sustained fire.

### 2. Sustained Fire Loop

Create a seamless 4-second loop of a heavy six-barrel sci-fi minigun firing at roughly 2,450 rounds per minute. Include a deep continuous rotary roar, rapid individual shot texture, aggressive low-mid mechanical chug, bright muzzle crack, and steady electric motor whine at 725 barrel-cluster RPM. It should feel like an armored soldier-mounted minigun, close perspective, dry mix, no reverb tail, no music, no voice, no explosions. Loop must be stable without obvious start/end transient.

### 3. Spin-Down

Create a 1.3-second spin-down sound for a six-barrel sci-fi minigun immediately after firing stops. Gunshots cease instantly, then the barrel motor winds down from 725 RPM to zero with falling metallic whine, bearing friction, soft receiver rattles, and a few delayed belt-feed clicks. Dry close perspective, dark military sci-fi, no music, no voice, no explosion.

### 4. Shell Casing Stream

Create a 4-second seamless loop of hot brass shell casings ejecting rapidly from a minigun at about 40 casings per second. Bright metallic ticks, dense brass rain, casings bouncing and skittering on cracked asphalt, slightly right-biased stereo image, close but not overpowering. No gunshots, no motor, no music, no voice. Designed to layer under a sustained minigun firing loop.

### 5. Zombie Impact Layer

Create a 4-second randomized impact texture layer for minigun rounds shredding undead targets. Rapid wet thuds, torn cloth snaps, bone-like cracks, armorless body impacts, and occasional heavier splats. Keep it stylized game-like, punchy and readable, not cinematic horror ambience. No screaming, no human voices, no music, no gunshots. Designed to be triggered in small chunks under a minigun loop.
