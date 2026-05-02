import * as THREE from 'three';

import './styles.css';

const canvas = document.querySelector('#game');

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x060708);
scene.fog = new THREE.FogExp2(0x050607, 0.035);

const renderer = new THREE.WebGLRenderer({
  canvas,
  antialias: true,
  powerPreference: 'high-performance'
});
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.outputColorSpace = THREE.SRGBColorSpace;

const camera = new THREE.PerspectiveCamera(48, window.innerWidth / window.innerHeight, 0.1, 160);
camera.position.set(0, 9, 13);

const clock = new THREE.Clock();
let frameCount = 0;
const pointer = new THREE.Vector2(0, 0);
const pointerWorld = new THREE.Vector3();
const raycaster = new THREE.Raycaster();
const groundPlane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0);
const keys = new Set();
const audio = {
  unlocked: false,
  spinUp: new Audio('/audio/minigun-spin-up.wav'),
  sustained: new Audio('/audio/minigun-sustained-loop.wav'),
  casings: new Audio('/audio/minigun-casing-loop.wav'),
  zombieImpactPool: createAudioPool('/audio/zombie-impact-layer.wav', 6, 0.34),
  zombieDeathPool: createAudioPool('/audio/zombie-death.wav', 5, 0.68),
  lastImpactSoundAt: 0
};
audio.spinUp.preload = 'auto';
audio.spinUp.volume = 0.82;
audio.sustained.preload = 'auto';
audio.sustained.loop = true;
audio.sustained.volume = 0.72;
audio.casings.preload = 'auto';
audio.casings.loop = true;
audio.casings.volume = 0.45;

const materials = {
  armor: new THREE.MeshStandardMaterial({
    color: 0x111417,
    roughness: 0.72,
    metalness: 0.58
  }),
  armorEdge: new THREE.MeshStandardMaterial({
    color: 0x3f4242,
    roughness: 0.5,
    metalness: 0.8
  }),
  rubber: new THREE.MeshStandardMaterial({
    color: 0x050607,
    roughness: 0.9,
    metalness: 0.15
  }),
  visor: new THREE.MeshStandardMaterial({
    color: 0xff1010,
    emissive: 0xff0505,
    emissiveIntensity: 2.8,
    roughness: 0.18,
    metalness: 0.35
  }),
  weapon: new THREE.MeshStandardMaterial({
    color: 0x1c1e1f,
    roughness: 0.46,
    metalness: 0.85
  }),
  hotMetal: new THREE.MeshStandardMaterial({
    color: 0xff6a13,
    emissive: 0xff5a00,
    emissiveIntensity: 1.6,
    roughness: 0.3,
    metalness: 0.55
  }),
  brass: new THREE.MeshStandardMaterial({
    color: 0xd6a241,
    emissive: 0x3a2406,
    emissiveIntensity: 0.18,
    roughness: 0.34,
    metalness: 0.82
  }),
  shell: new THREE.MeshStandardMaterial({
    color: 0xd9a33a,
    emissive: 0x5a2f05,
    emissiveIntensity: 0.35,
    roughness: 0.3,
    metalness: 0.9
  }),
  backpack: new THREE.MeshStandardMaterial({
    color: 0x161a1a,
    roughness: 0.68,
    metalness: 0.62
  }),
  line: new THREE.LineBasicMaterial({
    color: 0xff8c28,
    transparent: true,
    opacity: 0.78
  }),
  tracer: new THREE.MeshBasicMaterial({
    color: 0xff9f32,
    transparent: true,
    opacity: 0
  }),
  impactFlash: new THREE.MeshBasicMaterial({
    color: 0xffb13b,
    transparent: true,
    opacity: 0,
    depthWrite: false
  }),
  impactDust: new THREE.MeshBasicMaterial({
    color: 0x8c7765,
    transparent: true,
    opacity: 0,
    depthWrite: false
  }),
  zombieSkin: new THREE.MeshStandardMaterial({
    color: 0x6f7865,
    roughness: 0.92,
    metalness: 0.02
  }),
  zombieSkinDark: new THREE.MeshStandardMaterial({
    color: 0x3f493c,
    roughness: 0.96,
    metalness: 0.01
  }),
  zombieCloth: new THREE.MeshStandardMaterial({
    color: 0x2b302c,
    roughness: 0.88,
    metalness: 0.04
  }),
  zombieEye: new THREE.MeshStandardMaterial({
    color: 0x9fd8cb,
    emissive: 0x78fff0,
    emissiveIntensity: 1.7,
    roughness: 0.2
  }),
  blood: new THREE.MeshBasicMaterial({
    color: 0x8e0505,
    transparent: true,
    opacity: 0.78,
    depthWrite: false
  }),
  bloodDark: new THREE.MeshBasicMaterial({
    color: 0x420303,
    transparent: true,
    opacity: 0.58,
    depthWrite: false
  })
};

const world = new THREE.Group();
scene.add(world);

const soldierLightRefs = {};

addLights();
addGround();
const soldier = createMinigunner();
world.add(soldier.root);

const movement = {
  velocity: new THREE.Vector3(),
  speed: 7,
  targetYaw: 0,
  firing: false,
  spin: 0,
  fireAccumulator: 0,
  beltTravel: 0,
  beltFeedDistance: 0,
  stepTime: 0
};

const cameraRig = {
  targetDistance: 13,
  distance: 13
};

const game = {
  elapsed: 0,
  kills: 0,
  wave: 1,
  spawnTimer: 0.2,
  burstTimer: 8,
  maxZombies: 80
};

const tracers = createTracerPool(32);
tracers.forEach((tracer) => world.add(tracer));
const casings = createCasingPool(120);
casings.forEach((casing) => world.add(casing));
const zombies = createZombiePool(game.maxZombies);
zombies.forEach((zombie) => world.add(zombie.root));
const bloodDecals = createBloodDecalPool(130);
bloodDecals.forEach((decal) => world.add(decal));
const bloodDrops = createBloodDropPool(180);
bloodDrops.forEach((drop) => world.add(drop));
const impacts = createImpactPool(120);
impacts.forEach((impact) => world.add(impact.root));

window.__minigunnerDebug = {
  getFrameInfo() {
    const forward = getSoldierForward();
    const barrelForward = getBarrelForward();
    return {
      frameCount,
      x: Number(soldier.root.position.x.toFixed(3)),
      z: Number(soldier.root.position.z.toFixed(3)),
      spin: Number(movement.spin.toFixed(3)),
      activeCasings: casings.filter((casing) => casing.visible).length,
      activeImpacts: impacts.filter((impact) => impact.root.visible).length,
      activeZombies: zombies.filter((zombie) => zombie.root.visible).length,
      kills: game.kills,
      wave: game.wave,
      beltFeed: Number(movement.beltFeedDistance.toFixed(3)),
      cameraDistance: Number(cameraRig.targetDistance.toFixed(3)),
      forwardX: Number(forward.x.toFixed(3)),
      forwardZ: Number(forward.z.toFixed(3)),
      barrelDot: Number(forward.dot(barrelForward).toFixed(3)),
      barrelY: Number(barrelForward.y.toFixed(3))
    };
  },
  forceZombiesInLane(count = 4) {
    const forward = getSoldierForward();
    const side = getSoldierRight();
    let placed = 0;
    for (let i = 0; i < count; i += 1) {
      const zombie = spawnZombie(1);
      if (!zombie) continue;
      zombie.root.position.copy(soldier.root.position)
        .addScaledVector(forward, 7 + i * 1.7)
        .addScaledVector(side, random(-0.28, 0.28));
      zombie.root.userData.health = 1.7;
      zombie.root.userData.maxHealth = 1.7;
      zombie.root.userData.speed = 0.25;
      placed += 1;
    }
    return placed;
  },
  samplePixels() {
    renderer.render(scene, camera);
    const gl = renderer.getContext();
    const width = gl.drawingBufferWidth;
    const height = gl.drawingBufferHeight;
    const pixels = new Uint8Array(width * height * 4);
    gl.readPixels(0, 0, width, height, gl.RGBA, gl.UNSIGNED_BYTE, pixels);

    let sampled = 0;
    let nonBlack = 0;
    let orange = 0;
    let red = 0;
    const stride = 28 * 4;

    for (let i = 0; i < pixels.length; i += stride) {
      const r = pixels[i];
      const g = pixels[i + 1];
      const b = pixels[i + 2];
      sampled += 1;
      if (r + g + b > 34) nonBlack += 1;
      if (r > 130 && g > 45 && g < 170 && b < 70) orange += 1;
      if (r > 120 && g < 55 && b < 55) red += 1;
    }

    return { width, height, sampled, nonBlack, orange, red };
  }
};

window.addEventListener('keydown', (event) => keys.add(event.code));
window.addEventListener('keyup', (event) => keys.delete(event.code));
window.addEventListener('pointermove', onPointerMove);
window.addEventListener('pointerdown', () => {
  startFiring();
});
window.addEventListener('pointerup', () => {
  stopFiring();
});
window.addEventListener('blur', stopFiring);
window.addEventListener('wheel', onWheel, { passive: false });
window.addEventListener('resize', resize);

animate();

function addLights() {
  const hemi = new THREE.HemisphereLight(0x9eb8c8, 0x16100d, 1.2);
  scene.add(hemi);

  const key = new THREE.DirectionalLight(0xb9d6ff, 2.4);
  key.position.set(-7, 12, 8);
  key.castShadow = true;
  key.shadow.mapSize.set(2048, 2048);
  key.shadow.camera.left = -24;
  key.shadow.camera.right = 24;
  key.shadow.camera.top = 24;
  key.shadow.camera.bottom = -24;
  scene.add(key);

  const orange = new THREE.PointLight(0xff6418, 18, 12, 2);
  orange.position.set(4, 3.2, 0.5);
  soldierLightRefs.muzzle = orange;
  scene.add(orange);
}

function addGround() {
  const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(160, 160, 80, 80),
    new THREE.MeshStandardMaterial({
      color: 0x151719,
      roughness: 0.92,
      metalness: 0.05
    })
  );
  ground.rotation.x = -Math.PI / 2;
  ground.receiveShadow = true;
  world.add(ground);

  const grid = new THREE.GridHelper(160, 80, 0x262a2d, 0x1a1d20);
  grid.position.y = 0.012;
  world.add(grid);

  for (let i = 0; i < 90; i += 1) {
    const shard = new THREE.Mesh(
      new THREE.BoxGeometry(random(0.3, 1.2), 0.04, random(0.05, 0.18)),
      new THREE.MeshStandardMaterial({
        color: new THREE.Color().setHSL(0.08, 0.11, random(0.13, 0.23)),
        roughness: 0.9
      })
    );
    shard.position.set(random(-65, 65), 0.035, random(-65, 65));
    shard.rotation.y = random(0, Math.PI);
    shard.receiveShadow = true;
    shard.castShadow = true;
    world.add(shard);
  }
}

function createMinigunner() {
  const root = new THREE.Group();
  const body = new THREE.Group();
  root.add(body);

  const hips = part(new THREE.BoxGeometry(1.25, 0.65, 0.62), materials.armor, [0, 1.12, 0], [0, 0, 0]);
  body.add(hips);

  const torso = part(new THREE.BoxGeometry(1.55, 1.5, 0.82), materials.armor, [0, 2.05, 0], [0.12, 0, 0]);
  body.add(torso);

  const chestPlate = part(new THREE.BoxGeometry(1.1, 0.7, 0.14), materials.armorEdge, [0, 2.22, 0.44], [0.16, 0, 0]);
  body.add(chestPlate);

  const helmet = part(new THREE.SphereGeometry(0.58, 32, 20), materials.armor, [0, 3.06, 0.03], [0, 0, 0], [1.03, 0.82, 0.98]);
  body.add(helmet);

  const visor = part(new THREE.BoxGeometry(0.62, 0.12, 0.08), materials.visor, [0, 3.07, 0.53], [0, 0, 0]);
  const leftEye = part(new THREE.BoxGeometry(0.22, 0.1, 0.1), materials.visor, [-0.2, 3.08, 0.57], [0, 0, -0.08]);
  const rightEye = part(new THREE.BoxGeometry(0.22, 0.1, 0.1), materials.visor, [0.2, 3.08, 0.57], [0, 0, 0.08]);
  body.add(visor, leftEye, rightEye);

  const respirator = part(new THREE.BoxGeometry(0.36, 0.2, 0.18), materials.rubber, [0, 2.84, 0.53], [0, 0, 0]);
  body.add(respirator);

  const shoulders = [
    addShoulder(body, -0.98),
    addShoulder(body, 0.98)
  ];
  const arms = [
    addArm(body, -1, -0.18),
    addArm(body, 1, 0.18)
  ];
  const legs = [
    addLeg(body, -0.43),
    addLeg(body, 0.43)
  ];

  const pack = new THREE.Group();
  pack.position.set(0, 2.02, -0.78);
  body.add(pack);
  pack.add(part(new THREE.BoxGeometry(1.44, 1.92, 0.66), materials.backpack, [0, 0, 0], [0, 0, 0]));
  pack.add(part(new THREE.BoxGeometry(0.54, 1.52, 0.3), materials.weapon, [-0.47, 0.02, -0.27], [0, 0, 0]));
  pack.add(part(new THREE.BoxGeometry(0.54, 1.52, 0.3), materials.weapon, [0.47, 0.02, -0.27], [0, 0, 0]));
  pack.add(part(new THREE.BoxGeometry(0.72, 0.32, 0.2), materials.armorEdge, [0.36, 0.52, 0.38], [0, 0, 0]));
  pack.add(part(new THREE.CylinderGeometry(0.15, 0.15, 0.92, 18), materials.armorEdge, [0, 0.9, -0.38], [Math.PI / 2, 0, Math.PI / 2]));
  pack.add(part(new THREE.CylinderGeometry(0.15, 0.15, 0.92, 18), materials.hotMetal, [0, -0.9, -0.39], [Math.PI / 2, 0, Math.PI / 2]));
  pack.add(part(new THREE.CylinderGeometry(0.035, 0.035, 0.92, 10), materials.armorEdge, [-0.52, 1.34, -0.08], [0.16, 0, -0.1]));
  pack.add(part(new THREE.SphereGeometry(0.07, 12, 8), materials.armorEdge, [-0.58, 1.78, -0.17], [0, 0, 0]));

  const gun = new THREE.Group();
  gun.position.set(0.14, 2.04, 0.74);
  gun.rotation.set(0, -Math.PI / 2, 0);
  body.add(gun);

  gun.add(part(new THREE.BoxGeometry(1.15, 0.48, 0.45), materials.weapon, [0, 0, 0], [0, 0, 0]));
  gun.add(part(new THREE.CylinderGeometry(0.27, 0.27, 1.12, 24), materials.weapon, [0.74, 0, 0], [0, 0, Math.PI / 2]));
  gun.add(part(new THREE.BoxGeometry(0.34, 0.84, 0.16), materials.armorEdge, [0.47, 0.18, 0], [0, 0, -0.1]));
  gun.add(part(new THREE.BoxGeometry(0.16, 0.55, 0.16), materials.armorEdge, [-0.24, 0.33, 0], [0, 0, 0]));

  const barrelRoot = new THREE.Group();
  barrelRoot.position.set(1.35, 0, 0);
  gun.add(barrelRoot);

  const barrelCount = 6;
  for (let i = 0; i < barrelCount; i += 1) {
    const angle = (i / barrelCount) * Math.PI * 2;
    const barrel = part(
      new THREE.CylinderGeometry(0.055, 0.055, 1.72, 14),
      i % 2 === 0 ? materials.weapon : materials.hotMetal,
      [0.86, Math.cos(angle) * 0.18, Math.sin(angle) * 0.18],
      [0, 0, Math.PI / 2]
    );
    barrelRoot.add(barrel);
  }
  barrelRoot.add(part(new THREE.TorusGeometry(0.23, 0.035, 12, 32), materials.armorEdge, [0.15, 0, 0], [0, Math.PI / 2, 0]));
  barrelRoot.add(part(new THREE.TorusGeometry(0.24, 0.04, 12, 32), materials.armorEdge, [1.64, 0, 0], [0, Math.PI / 2, 0]));

  const muzzle = part(new THREE.ConeGeometry(0.36, 1.0, 24, 1, true), materials.tracer, [2.72, 0, 0], [0, 0, -Math.PI / 2]);
  muzzle.scale.set(1, 0.65, 0.65);
  gun.add(muzzle);

  const belt = createAmmoBelt();
  body.add(belt);

  return {
    root,
    body,
    gun,
    barrelRoot,
    muzzle,
    belt,
    limbs: {
      arms,
      legs,
      shoulders
    }
  };
}

function addShoulder(parent, side) {
  const shoulder = part(new THREE.SphereGeometry(0.36, 20, 14), materials.armorEdge, [side, 2.48, 0.02], [0, 0, 0], [1.25, 0.82, 1.08]);
  parent.add(shoulder);
  rememberPose(shoulder);
  return { mesh: shoulder, side: Math.sign(side) };
}

function addArm(parent, side, zOffset) {
  const upper = part(new THREE.BoxGeometry(0.36, 0.82, 0.38), materials.armor, [side * 0.92, 1.96, 0.34 + zOffset], [0.18, 0, side * 0.36]);
  const fore = part(new THREE.BoxGeometry(0.36, 0.76, 0.34), materials.armorEdge, [side * 0.77, 1.53, 0.67 + zOffset], [0.28, 0, side * -0.16]);
  const hand = part(new THREE.BoxGeometry(0.32, 0.22, 0.3), materials.rubber, [side * 0.64, 1.98, 0.82 + zOffset], [0, 0, 0]);
  parent.add(upper, fore, hand);
  [upper, fore, hand].forEach(rememberPose);
  return {
    side,
    upper,
    fore,
    hand
  };
}

function addLeg(parent, side) {
  const thigh = part(new THREE.BoxGeometry(0.42, 0.9, 0.42), materials.armor, [side, 0.63, 0.02], [0.04, 0, side * 0.04]);
  const shin = part(new THREE.BoxGeometry(0.42, 0.85, 0.42), materials.armorEdge, [side, -0.04, 0.06], [-0.02, 0, side * -0.02]);
  const boot = part(new THREE.BoxGeometry(0.5, 0.24, 0.76), materials.rubber, [side, -0.55, 0.18], [0, 0, 0]);
  parent.add(thigh, shin, boot);
  [thigh, shin, boot].forEach(rememberPose);
  return {
    side: Math.sign(side),
    thigh,
    shin,
    boot
  };
}

function createAmmoBelt() {
  const belt = new THREE.Group();
  const curve = new THREE.CatmullRomCurve3([
    new THREE.Vector3(0.5, 2.78, -1.08),
    new THREE.Vector3(1.42, 3.0, -0.34),
    new THREE.Vector3(1.58, 2.74, 0.58),
    new THREE.Vector3(1.02, 2.28, 0.98),
    new THREE.Vector3(0.26, 2.0, 0.84)
  ]);

  const feedTube = new THREE.Mesh(
    new THREE.TubeGeometry(curve, 64, 0.06, 12, false),
    materials.armorEdge
  );
  feedTube.castShadow = true;
  belt.add(feedTube);

  const glowLine = new THREE.Line(
    new THREE.BufferGeometry().setFromPoints(curve.getPoints(48)),
    materials.line
  );
  belt.add(glowLine);

  const roundGeometry = new THREE.CylinderGeometry(0.095, 0.095, 0.36, 14);
  const casingGeometry = new THREE.BoxGeometry(0.19, 0.2, 0.07);
  const segments = [];

  for (let i = 0; i < 26; i += 1) {
    const t = i / 26;
    const round = part(roundGeometry, materials.brass, [0, 0, 0], [0, 0, 0]);
    const link = part(casingGeometry, materials.weapon, [0, 0, 0], [0, 0, 0]);
    const segment = { round, link, baseT: t };
    placeBeltSegment(curve, segment, t);
    belt.add(round, link);
    segments.push(segment);
  }

  belt.userData.curve = curve;
  belt.userData.segments = segments;
  return belt;
}

function createTracerPool(count) {
  const pool = [];
  for (let i = 0; i < count; i += 1) {
    const tracer = new THREE.Mesh(new THREE.BoxGeometry(8.4, 0.045, 0.045), materials.tracer.clone());
    tracer.visible = false;
    tracer.userData.life = 0;
    pool.push(tracer);
  }
  return pool;
}

function createImpactPool(count) {
  const pool = [];
  const flashGeometry = new THREE.SphereGeometry(0.18, 10, 8);
  const dustGeometry = new THREE.SphereGeometry(0.26, 10, 8);
  for (let i = 0; i < count; i += 1) {
    const root = new THREE.Group();
    const flash = new THREE.Mesh(flashGeometry, materials.impactFlash.clone());
    const dust = new THREE.Mesh(dustGeometry, materials.impactDust.clone());
    flash.scale.set(0.7, 0.7, 1);
    dust.scale.set(0.9, 0.9, 1);
    root.add(dust, flash);
    root.visible = false;
    root.userData.life = 0;
    root.userData.maxLife = 0.1;
    root.userData.velocity = new THREE.Vector3();
    pool.push({ root, flash, dust });
  }
  return pool;
}

function createCasingPool(count) {
  const pool = [];
  const geometry = new THREE.CylinderGeometry(0.055, 0.055, 0.24, 12);

  for (let i = 0; i < count; i += 1) {
    const casing = new THREE.Mesh(geometry, materials.shell);
    casing.visible = false;
    casing.castShadow = true;
    casing.receiveShadow = true;
    casing.userData.velocity = new THREE.Vector3();
    casing.userData.angularVelocity = new THREE.Vector3();
    casing.userData.life = 0;
    casing.userData.settled = false;
    pool.push(casing);
  }

  return pool;
}

function createZombiePool(count) {
  const pool = [];
  for (let i = 0; i < count; i += 1) {
    const root = new THREE.Group();
    root.visible = false;

    const torso = part(new THREE.BoxGeometry(0.62, 1.04, 0.36), materials.zombieCloth, [0, 1.16, 0], [0.12, 0, 0], [1, 1, 1]);
    const head = part(new THREE.SphereGeometry(0.25, 14, 10), materials.zombieSkin, [0.02, 1.84, 0.05], [0, 0, 0], [0.92, 1.08, 0.9]);
    const jaw = part(new THREE.BoxGeometry(0.23, 0.12, 0.08), materials.zombieSkinDark, [0.02, 1.72, 0.25], [0, 0, 0]);
    const leftEye = part(new THREE.BoxGeometry(0.075, 0.045, 0.035), materials.zombieEye, [-0.075, 1.88, 0.25], [0, 0, 0]);
    const rightEye = part(new THREE.BoxGeometry(0.075, 0.045, 0.035), materials.zombieEye, [0.115, 1.88, 0.25], [0, 0, 0]);
    const leftArm = part(new THREE.BoxGeometry(0.22, 0.9, 0.2), materials.zombieSkinDark, [-0.46, 1.15, 0.2], [0.68, 0, -0.18]);
    const rightArm = part(new THREE.BoxGeometry(0.22, 0.9, 0.2), materials.zombieSkinDark, [0.48, 1.15, 0.18], [0.62, 0, 0.16]);
    const leftLeg = part(new THREE.BoxGeometry(0.24, 0.86, 0.24), materials.zombieSkinDark, [-0.2, 0.4, 0], [0.08, 0, -0.04]);
    const rightLeg = part(new THREE.BoxGeometry(0.24, 0.86, 0.24), materials.zombieSkinDark, [0.21, 0.4, 0.02], [-0.08, 0, 0.04]);
    const wound = part(new THREE.BoxGeometry(0.24, 0.18, 0.035), materials.bloodDark, [-0.12, 1.34, 0.205], [0, 0, -0.16]);

    root.add(torso, head, jaw, leftEye, rightEye, leftArm, rightArm, leftLeg, rightLeg, wound);
    root.traverse((child) => {
      if (child.isMesh) rememberPose(child);
    });

    root.userData = {
      active: false,
      health: 3,
      maxHealth: 3,
      speed: 1.8,
      radius: 0.58,
      stagger: new THREE.Vector3(),
      age: 0,
      hitFlash: 0,
      parts: {
        torso,
        head,
        leftArm,
        rightArm,
        leftLeg,
        rightLeg,
        wound
      }
    };

    pool.push({ root });
  }
  return pool;
}

function createBloodDecalPool(count) {
  const pool = [];
  const geometry = new THREE.CircleGeometry(1, 18);

  for (let i = 0; i < count; i += 1) {
    const decal = new THREE.Mesh(geometry, materials.blood.clone());
    decal.rotation.x = -Math.PI / 2;
    decal.position.y = 0.018 + i * 0.00002;
    decal.visible = false;
    decal.renderOrder = 2;
    decal.userData.life = 0;
    pool.push(decal);
  }

  return pool;
}

function createBloodDropPool(count) {
  const pool = [];
  const geometry = new THREE.SphereGeometry(0.055, 8, 6);

  for (let i = 0; i < count; i += 1) {
    const drop = new THREE.Mesh(geometry, materials.bloodDark.clone());
    drop.visible = false;
    drop.userData.velocity = new THREE.Vector3();
    drop.userData.life = 0;
    pool.push(drop);
  }

  return pool;
}

function part(geometry, material, position, rotation, scale = [1, 1, 1]) {
  const mesh = new THREE.Mesh(geometry, material);
  mesh.position.set(...position);
  mesh.rotation.set(...rotation);
  mesh.scale.set(...scale);
  mesh.castShadow = true;
  mesh.receiveShadow = true;
  return mesh;
}

function rememberPose(mesh) {
  mesh.userData.basePosition = mesh.position.clone();
  mesh.userData.baseRotation = mesh.rotation.clone();
  return mesh;
}

function setFromBase(mesh) {
  mesh.position.copy(mesh.userData.basePosition);
  mesh.rotation.copy(mesh.userData.baseRotation);
}

function placeBeltSegment(curve, segment, t) {
  const position = curve.getPointAt(t);
  const tangent = curve.getTangentAt(t).normalize();
  const cross = new THREE.Vector3().crossVectors(new THREE.Vector3(0, 1, 0), tangent);
  if (cross.lengthSq() < 0.001) {
    cross.set(1, 0, 0);
  } else {
    cross.normalize();
  }

  segment.round.position.copy(position);
  segment.round.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), cross);

  segment.link.position.copy(position)
    .addScaledVector(cross, -0.015)
    .add(new THREE.Vector3(0, -0.11, 0));
  segment.link.quaternion.setFromUnitVectors(new THREE.Vector3(1, 0, 0), tangent);
}

function onPointerMove(event) {
  pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
  pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;
}

function startFiring() {
  if (!movement.firing) {
    playSpinUp();
  }
  movement.firing = true;
}

function createAudioPool(src, count, volume) {
  return Array.from({ length: count }, () => {
    const item = new Audio(src);
    item.preload = 'auto';
    item.volume = volume;
    return item;
  });
}

function playOneShot(pool, options = {}) {
  const sound = pool.find((item) => item.paused || item.ended) ?? pool[0];
  sound.pause();
  sound.currentTime = options.offset ?? 0;
  sound.volume = options.volume ?? sound.volume;
  const playPromise = sound.play();
  if (playPromise) {
    playPromise.catch(() => {
      // Audio can be blocked before the first user gesture.
    });
  }
}

function stopFiring() {
  movement.firing = false;
}

function playSpinUp() {
  audio.unlocked = true;
  audio.spinUp.pause();
  audio.spinUp.currentTime = 0;
  const playPromise = audio.spinUp.play();
  if (playPromise) {
    playPromise.catch(() => {
      // Browser autoplay policies can still block audio in unusual focus states.
    });
  }
}

function onWheel(event) {
  event.preventDefault();
  cameraRig.targetDistance = THREE.MathUtils.clamp(cameraRig.targetDistance + event.deltaY * 0.018, 9, 30);
}

function animate() {
  const delta = Math.min(clock.getDelta(), 0.033);
  frameCount += 1;
  updatePointerWorld();
  updateMovement(delta);
  updateZombieWaves(delta);
  updateZombies(delta);
  updateWeapon(delta);
  updateCamera(delta);
  updateTracers(delta);
  updateImpacts(delta);
  updateShellCasings(delta);
  updateBlood(delta);
  updateHud();
  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}

function updatePointerWorld() {
  raycaster.setFromCamera(pointer, camera);
  raycaster.ray.intersectPlane(groundPlane, pointerWorld);
}

function updateMovement(delta) {
  const input = new THREE.Vector3(
    (keys.has('KeyD') ? 1 : 0) - (keys.has('KeyA') ? 1 : 0),
    0,
    (keys.has('KeyS') ? 1 : 0) - (keys.has('KeyW') ? 1 : 0)
  );

  if (input.lengthSq() > 0) {
    input.normalize();
  }

  const firingDrag = movement.firing ? 0.72 : 1;
  movement.velocity.lerp(input.multiplyScalar(movement.speed * firingDrag), 1 - Math.pow(0.001, delta));
  soldier.root.position.addScaledVector(movement.velocity, delta);
  soldier.root.position.x = THREE.MathUtils.clamp(soldier.root.position.x, -64, 64);
  soldier.root.position.z = THREE.MathUtils.clamp(soldier.root.position.z, -64, 64);

  const aim = pointerWorld.clone().sub(soldier.root.position);
  if (aim.lengthSq() > 0.01) {
    movement.targetYaw = Math.atan2(aim.x, aim.z);
  } else if (movement.velocity.lengthSq() > 0.1) {
    movement.targetYaw = Math.atan2(movement.velocity.x, movement.velocity.z);
  }

  soldier.root.rotation.y = dampAngle(soldier.root.rotation.y, movement.targetYaw, 12, delta);

  const speed01 = THREE.MathUtils.clamp(movement.velocity.length() / movement.speed, 0, 1);
  movement.stepTime += delta * speed01 * 9.5;
  updateWalkAnimation(speed01);
}

function updateZombieWaves(delta) {
  game.elapsed += delta;
  game.wave = 1 + Math.floor(game.elapsed / 18);

  const activeCount = zombies.filter((zombie) => zombie.root.visible).length;
  if (activeCount >= game.maxZombies) return;

  const difficulty = 1 + game.wave * 0.22;
  game.spawnTimer -= delta;
  game.burstTimer -= delta;

  if (game.spawnTimer <= 0) {
    spawnZombie(difficulty);
    game.spawnTimer = THREE.MathUtils.clamp(0.92 - game.wave * 0.055, 0.18, 0.92);
  }

  if (game.burstTimer <= 0) {
    const burstCount = Math.min(5 + game.wave * 2, game.maxZombies - activeCount);
    for (let i = 0; i < burstCount; i += 1) {
      spawnZombie(difficulty + 0.5);
    }
    game.burstTimer = THREE.MathUtils.clamp(10 - game.wave * 0.28, 4.5, 10);
  }
}

function spawnZombie(difficulty) {
  const zombie = zombies.find((item) => !item.root.visible);
  if (!zombie) return null;

  const root = zombie.root;
  const data = root.userData;
  const angle = random(0, Math.PI * 2);
  const distance = cameraRig.distance + random(13, 24);
  const isHeavy = Math.random() < Math.min(0.1 + game.wave * 0.015, 0.32);
  const isRunner = !isHeavy && Math.random() < Math.min(0.12 + game.wave * 0.012, 0.28);
  const scale = isHeavy ? random(1.18, 1.38) : isRunner ? random(0.82, 0.95) : random(0.92, 1.12);

  root.visible = true;
  root.position.set(
    soldier.root.position.x + Math.sin(angle) * distance,
    0,
    soldier.root.position.z + Math.cos(angle) * distance
  );
  root.rotation.set(0, angle + Math.PI, 0);
  root.scale.setScalar(scale);

  data.active = true;
  data.maxHealth = isHeavy ? 6 + game.wave * 0.45 : isRunner ? 2.2 : 3.2 + game.wave * 0.18;
  data.health = data.maxHealth;
  data.speed = isHeavy ? random(1.0, 1.35) + difficulty * 0.05 : isRunner ? random(2.8, 3.35) + difficulty * 0.08 : random(1.55, 2.05) + difficulty * 0.06;
  data.radius = 0.46 * scale;
  data.stagger.set(0, 0, 0);
  data.age = random(0, Math.PI * 2);
  data.hitFlash = 0;

  root.traverse((child) => {
    if (child.isMesh && child.userData.basePosition) {
      setFromBase(child);
    }
  });

  return zombie;
}

function updateZombies(delta) {
  for (const zombie of zombies) {
    const root = zombie.root;
    if (!root.visible) continue;

    const data = root.userData;
    data.age += delta;
    data.hitFlash = Math.max(0, data.hitFlash - delta * 5);

    const toPlayer = soldier.root.position.clone().sub(root.position);
    toPlayer.y = 0;
    const distance = Math.max(toPlayer.length(), 0.001);
    const direction = toPlayer.divideScalar(distance);

    root.position.addScaledVector(direction, data.speed * delta);
    root.position.addScaledVector(data.stagger, delta);
    data.stagger.lerp(new THREE.Vector3(0, 0, 0), 1 - Math.pow(0.002, delta));
    root.rotation.y = dampAngle(root.rotation.y, Math.atan2(direction.x, direction.z), 8, delta);

    animateZombie(zombie, delta);

    if (distance < 0.85) {
      root.position.addScaledVector(direction, -delta * 1.4);
    }

    if (root.position.distanceToSquared(soldier.root.position) > 120 * 120) {
      root.visible = false;
    }
  }
}

function animateZombie(zombie) {
  const root = zombie.root;
  const data = root.userData;
  const { leftArm, rightArm, leftLeg, rightLeg, head, torso, wound } = data.parts;
  const phase = data.age * (4.5 + data.speed * 0.9);
  const limp = Math.sin(phase);
  const stagger = Math.sin(phase * 0.5 + 1.7);

  [leftArm, rightArm, leftLeg, rightLeg, head, torso, wound].forEach((mesh) => {
    if (mesh.userData.basePosition) setFromBase(mesh);
  });

  torso.rotation.z += stagger * 0.08;
  torso.rotation.x += 0.12 + data.hitFlash * 0.18;
  head.rotation.z += -stagger * 0.12;
  head.position.y += Math.abs(limp) * 0.035;

  leftArm.rotation.x += 0.48 + limp * 0.2;
  rightArm.rotation.x += 0.54 - limp * 0.22;
  leftArm.rotation.z -= 0.16;
  rightArm.rotation.z += 0.16;

  leftLeg.rotation.x += limp * 0.22;
  rightLeg.rotation.x -= limp * 0.22;
  leftLeg.position.z += limp * 0.08;
  rightLeg.position.z -= limp * 0.08;

  wound.scale.setScalar(1 + data.hitFlash * 1.8);
}

function updateWeapon(delta) {
  const targetSpin = movement.firing ? 1 : 0;
  movement.spin = THREE.MathUtils.damp(movement.spin, targetSpin, movement.firing ? 3.6 : 2.3, delta);
  soldier.barrelRoot.rotation.x += delta * movement.spin * 76;
  const firingReady = movement.firing && movement.spin > 0.68;
  updateAmmoBelt(delta, firingReady);
  soldier.muzzle.material.opacity = firingReady ? 0.18 + Math.random() * 0.24 : 0;
  soldier.muzzle.scale.x = firingReady ? random(0.75, 1.12) : 0.2;

  const muzzleWorld = new THREE.Vector3();
  soldier.gun.localToWorld(muzzleWorld.set(3.05, 0, 0));
  if (soldierLightRefs.muzzle) {
    soldierLightRefs.muzzle.position.lerp(muzzleWorld, 0.45);
    soldierLightRefs.muzzle.intensity = firingReady ? random(18, 36) : 0;
  }

  if (firingReady) {
    movement.fireAccumulator += delta * THREE.MathUtils.lerp(14, 42, movement.spin);
    while (movement.fireAccumulator >= 1) {
      fireTracer(muzzleWorld);
      ejectCasing();
      movement.fireAccumulator -= 1;
    }
  } else {
    movement.fireAccumulator = 0;
  }
}

function updateAmmoBelt(delta, feeding) {
  const feedRate = feeding ? THREE.MathUtils.lerp(0.82, 1.62, movement.spin) : 0;
  movement.beltTravel = (movement.beltTravel + delta * feedRate) % 1;
  movement.beltFeedDistance += delta * feedRate;

  const curve = soldier.belt.userData.curve;
  const segments = soldier.belt.userData.segments;
  for (const segment of segments) {
    const t = (segment.baseT + movement.beltTravel) % 1;
    placeBeltSegment(curve, segment, t);
  }
}

function updateWalkAnimation(speed01) {
  const stride = THREE.MathUtils.smoothstep(speed01, 0, 1);
  const phase = movement.stepTime;

  soldier.body.position.y = Math.abs(Math.sin(phase)) * 0.055 * stride;
  soldier.body.rotation.x = 0;
  soldier.body.rotation.z = Math.sin(phase * 0.5) * 0.028 * stride;

  for (const leg of soldier.limbs.legs) {
    const legPhase = phase + (leg.side < 0 ? 0 : Math.PI);
    const swing = Math.sin(legPhase);
    const footLift = Math.max(0, Math.cos(legPhase));

    setFromBase(leg.thigh);
    setFromBase(leg.shin);
    setFromBase(leg.boot);

    leg.thigh.rotation.x += swing * 0.22 * stride;
    leg.thigh.position.z += swing * 0.07 * stride;

    leg.shin.rotation.x += swing * 0.12 * stride - footLift * 0.1 * stride;
    leg.shin.position.z += swing * 0.1 * stride;

    leg.boot.rotation.x -= swing * 0.16 * stride;
    leg.boot.position.z += swing * 0.17 * stride;
    leg.boot.position.y += footLift * 0.12 * stride;
  }

  for (const arm of soldier.limbs.arms) {
    const armPhase = phase + (arm.side < 0 ? Math.PI : 0);
    const brace = movement.spin * 0.04;

    setFromBase(arm.upper);
    setFromBase(arm.fore);
    setFromBase(arm.hand);

    arm.upper.rotation.x += Math.sin(armPhase) * 0.045 * stride - brace;
    arm.upper.rotation.z += arm.side * 0.02 * stride;
    arm.fore.rotation.x += Math.sin(armPhase + 0.35) * 0.035 * stride - brace;
    arm.hand.position.z += Math.sin(armPhase) * 0.03 * stride;
    arm.hand.position.y -= movement.spin * 0.018;
  }

  for (const shoulder of soldier.limbs.shoulders) {
    setFromBase(shoulder.mesh);
    shoulder.mesh.rotation.z += shoulder.side * Math.sin(phase) * 0.025 * stride;
  }
}

function fireTracer(origin) {
  const tracer = tracers.find((item) => !item.visible);
  if (!tracer) return;

  const direction = getSoldierForward().applyAxisAngle(new THREE.Vector3(0, 1, 0), random(-0.045, 0.045));
  const hit = applyBulletDamage(origin, direction);
  const side = new THREE.Vector3().crossVectors(direction, new THREE.Vector3(0, 1, 0)).normalize();
  tracer.position.copy(origin)
    .addScaledVector(direction, random(3.2, 7.2))
    .addScaledVector(side, random(-0.18, 0.18));
  tracer.quaternion.setFromUnitVectors(new THREE.Vector3(1, 0, 0), direction);
  tracer.material.opacity = 0.86;
  tracer.visible = true;
  tracer.userData.direction = direction;
  tracer.userData.life = random(0.085, 0.14);

  if (!hit) {
    const missPoint = new THREE.Vector3(origin.x, 0.08, origin.z).addScaledVector(direction, random(22, 45));
    spawnImpact(missPoint, direction, 'dust');
  }
}

function applyBulletDamage(origin, direction) {
  const candidates = [];
  const flatOrigin = new THREE.Vector3(origin.x, 0, origin.z);
  const flatDirection = new THREE.Vector3(direction.x, 0, direction.z).normalize();
  const maxRange = 55;

  for (const zombie of zombies) {
    const root = zombie.root;
    if (!root.visible) continue;

    const toZombie = new THREE.Vector3(root.position.x - flatOrigin.x, 0, root.position.z - flatOrigin.z);
    const projected = toZombie.dot(flatDirection);
    if (projected < 0 || projected > maxRange) continue;

    const lateralSq = Math.max(0, toZombie.lengthSq() - projected * projected);
    const hitRadius = root.userData.radius + 0.24;
    if (lateralSq <= hitRadius * hitRadius) {
      candidates.push({ zombie, projected });
    }
  }

  candidates.sort((a, b) => a.projected - b.projected);
  let hitSomething = false;
  for (let i = 0; i < Math.min(candidates.length, 3); i += 1) {
    const { zombie, projected } = candidates[i];
    const hitPoint = flatOrigin.clone().addScaledVector(flatDirection, projected);
    hitPoint.y = random(0.75, 1.45);
    damageZombie(zombie, 1.15 * (1 - i * 0.18), flatDirection, hitPoint);
    hitSomething = true;
  }

  return hitSomething;
}

function damageZombie(zombie, damage, direction, hitPoint) {
  const data = zombie.root.userData;
  data.health -= damage;
  data.hitFlash = 0.18;
  data.stagger.addScaledVector(direction, 4.2);
  playZombieImpactSound();
  spawnImpact(hitPoint, direction, 'flesh');
  spawnBloodImpact(hitPoint, direction, false);

  if (data.health <= 0) {
    killZombie(zombie, direction);
  }
}

function playZombieImpactSound() {
  if (!audio.unlocked) return;

  const now = performance.now();
  if (now - audio.lastImpactSoundAt < 85) return;
  audio.lastImpactSoundAt = now;
  playOneShot(audio.zombieImpactPool, {
    offset: random(0, 1.6),
    volume: random(0.2, 0.38)
  });
}

function killZombie(zombie, direction) {
  const root = zombie.root;
  const deathPosition = root.position.clone();
  root.visible = false;
  game.kills += 1;
  playOneShot(audio.zombieDeathPool, { volume: random(0.52, 0.78) });

  spawnBloodDecal(deathPosition, random(1.0, 1.9), random(20, 34));
  for (let i = 0; i < 3; i += 1) {
    const offset = new THREE.Vector3(random(-0.55, 0.55), 0, random(-0.55, 0.55));
    spawnBloodDecal(deathPosition.clone().add(offset), random(0.35, 0.85), random(14, 24));
  }
  for (let i = 0; i < 14; i += 1) {
    spawnBloodDrop(deathPosition.clone().add(new THREE.Vector3(0, random(0.4, 1.4), 0)), direction, true);
  }
}

function ejectCasing() {
  const casing = casings.find((item) => !item.visible);
  if (!casing) return;

  const ejectionWorld = new THREE.Vector3();
  soldier.gun.localToWorld(ejectionWorld.set(0.18, -0.16, -0.36));

  const forward = getSoldierForward();
  const right = getSoldierRight();
  casing.position.copy(ejectionWorld)
    .addScaledVector(right, random(0.02, 0.12))
    .addScaledVector(forward, random(-0.06, 0.08));
  casing.rotation.set(random(0, Math.PI), random(0, Math.PI), random(0, Math.PI));
  casing.visible = true;
  casing.userData.life = random(3.6, 5.2);
  casing.userData.settled = false;
  casing.userData.velocity.copy(right).multiplyScalar(random(2.3, 4.4))
    .addScaledVector(forward, random(-0.7, 0.3))
    .add(new THREE.Vector3(0, random(2.2, 3.8), 0));
  casing.userData.angularVelocity.set(
    random(-18, 18),
    random(-24, 24),
    random(-18, 18)
  );
}

function updateTracers(delta) {
  for (const tracer of tracers) {
    if (!tracer.visible) continue;
    tracer.userData.life -= delta;
    tracer.position.add(tracer.userData.direction.clone().multiplyScalar(delta * 78));
    tracer.material.opacity = Math.min(0.92, Math.max(0, tracer.userData.life * 8.5));
    if (tracer.userData.life <= 0) {
      tracer.visible = false;
    }
  }
}

function spawnImpact(position, direction, type) {
  const impact = impacts.find((item) => !item.root.visible);
  if (!impact) return;

  const isFlesh = type === 'flesh';
  impact.root.visible = true;
  impact.root.position.copy(position);
  impact.root.userData.life = isFlesh ? 0.16 : 0.12;
  impact.root.userData.maxLife = impact.root.userData.life;
  impact.root.userData.velocity.copy(direction).multiplyScalar(isFlesh ? 0.5 : -0.25)
    .add(new THREE.Vector3(0, isFlesh ? 1.0 : 0.25, 0));

  impact.flash.material.color.setHex(isFlesh ? 0xffd070 : 0xffa53a);
  impact.dust.material.color.setHex(isFlesh ? 0x7c0505 : 0x837060);
  impact.flash.material.opacity = isFlesh ? 0.95 : 0.78;
  impact.dust.material.opacity = isFlesh ? 0.55 : 0.48;
  impact.flash.scale.setScalar(isFlesh ? random(0.55, 0.95) : random(0.32, 0.62));
  impact.dust.scale.setScalar(isFlesh ? random(0.85, 1.4) : random(0.6, 1.15));
}

function updateImpacts(delta) {
  for (const impact of impacts) {
    if (!impact.root.visible) continue;

    impact.root.userData.life -= delta;
    impact.root.position.addScaledVector(impact.root.userData.velocity, delta);
    const t = THREE.MathUtils.clamp(impact.root.userData.life / impact.root.userData.maxLife, 0, 1);
    impact.flash.material.opacity = t * 0.95;
    impact.dust.material.opacity = t * 0.55;
    impact.flash.scale.multiplyScalar(1 + delta * 3.8);
    impact.dust.scale.multiplyScalar(1 + delta * 2.2);

    if (impact.root.userData.life <= 0) {
      impact.root.visible = false;
    }
  }
}

function updateShellCasings(delta) {
  for (const casing of casings) {
    if (!casing.visible) continue;

    casing.userData.life -= delta;
    if (!casing.userData.settled) {
      casing.userData.velocity.y -= 12.5 * delta;
      casing.position.addScaledVector(casing.userData.velocity, delta);
      casing.rotation.x += casing.userData.angularVelocity.x * delta;
      casing.rotation.y += casing.userData.angularVelocity.y * delta;
      casing.rotation.z += casing.userData.angularVelocity.z * delta;

      if (casing.position.y <= 0.08) {
        casing.position.y = 0.08;
        if (Math.abs(casing.userData.velocity.y) > 0.9) {
          casing.userData.velocity.y *= -0.22;
          casing.userData.velocity.x *= 0.68;
          casing.userData.velocity.z *= 0.68;
          casing.userData.angularVelocity.multiplyScalar(0.55);
        } else {
          casing.userData.velocity.set(0, 0, 0);
          casing.userData.angularVelocity.set(0, 0, 0);
          casing.userData.settled = true;
        }
      }
    }

    if (casing.userData.life <= 0) {
      casing.visible = false;
    }
  }
}

function spawnBloodImpact(position, direction, lethal) {
  spawnBloodDecal(position, lethal ? random(0.7, 1.4) : random(0.22, 0.48), lethal ? 18 : 10);
  const count = lethal ? 12 : 5;
  for (let i = 0; i < count; i += 1) {
    spawnBloodDrop(position.clone().add(new THREE.Vector3(0, random(0.55, 1.25), 0)), direction, lethal);
  }
}

function spawnBloodDecal(position, size, life) {
  const decal = bloodDecals.find((item) => !item.visible) ?? bloodDecals[0];
  decal.visible = true;
  decal.position.set(position.x + random(-0.18, 0.18), 0.02 + random(0, 0.01), position.z + random(-0.18, 0.18));
  decal.rotation.set(-Math.PI / 2, 0, random(0, Math.PI * 2));
  decal.scale.set(size * random(0.7, 1.55), size * random(0.45, 1.1), 1);
  decal.material.opacity = random(0.5, 0.82);
  decal.userData.life = life;
}

function spawnBloodDrop(position, direction, lethal) {
  const drop = bloodDrops.find((item) => !item.visible);
  if (!drop) return;

  const side = new THREE.Vector3(-direction.z, 0, direction.x);
  drop.visible = true;
  drop.position.copy(position);
  drop.scale.setScalar(lethal ? random(1.0, 1.8) : random(0.65, 1.15));
  drop.userData.life = lethal ? random(0.38, 0.72) : random(0.22, 0.5);
  drop.userData.velocity.copy(direction).multiplyScalar(lethal ? random(2.1, 4.5) : random(1.0, 2.5))
    .addScaledVector(side, random(-1.8, 1.8))
    .add(new THREE.Vector3(0, lethal ? random(1.5, 3.4) : random(0.8, 2.0), 0));
}

function updateBlood(delta) {
  for (const drop of bloodDrops) {
    if (!drop.visible) continue;
    drop.userData.life -= delta;
    drop.userData.velocity.y -= 10 * delta;
    drop.position.addScaledVector(drop.userData.velocity, delta);

    if (drop.position.y <= 0.05) {
      spawnBloodDecal(drop.position, random(0.08, 0.18) * drop.scale.x, random(6, 12));
      drop.visible = false;
    } else if (drop.userData.life <= 0) {
      drop.visible = false;
    }
  }

  for (const decal of bloodDecals) {
    if (!decal.visible) continue;
    decal.userData.life -= delta;
    if (decal.userData.life < 4) {
      decal.material.opacity = Math.max(0, decal.userData.life / 4) * 0.58;
    }
    if (decal.userData.life <= 0) {
      decal.visible = false;
    }
  }
}

function updateCamera(delta) {
  cameraRig.distance = THREE.MathUtils.damp(cameraRig.distance, cameraRig.targetDistance, 7, delta);
  const cameraTarget = soldier.root.position.clone().add(new THREE.Vector3(0, cameraRig.distance * 0.68, cameraRig.distance));
  camera.position.lerp(cameraTarget, 1 - Math.pow(0.0007, delta));
  const lookAt = soldier.root.position.clone().add(new THREE.Vector3(0, 1.4, 0));
  camera.lookAt(lookAt);
}

function updateHud() {
  const kills = document.querySelector('#kills');
  const wave = document.querySelector('#wave');
  const zoom = document.querySelector('#zoom');
  if (kills) kills.textContent = String(game.kills);
  if (wave) wave.textContent = String(game.wave);
  if (zoom) zoom.textContent = `${Math.round(cameraRig.targetDistance)}m`;
}

function getSoldierForward() {
  return new THREE.Vector3(0, 0, 1).applyQuaternion(soldier.root.quaternion).normalize();
}

function getSoldierRight() {
  return new THREE.Vector3(1, 0, 0).applyQuaternion(soldier.root.quaternion).normalize();
}

function getBarrelForward() {
  return new THREE.Vector3(1, 0, 0).applyQuaternion(soldier.barrelRoot.getWorldQuaternion(new THREE.Quaternion())).normalize();
}

function dampAngle(current, target, smoothing, delta) {
  const wrapped = current + THREE.MathUtils.euclideanModulo(target - current + Math.PI, Math.PI * 2) - Math.PI;
  return THREE.MathUtils.damp(current, wrapped, smoothing, delta);
}

function resize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(window.innerWidth, window.innerHeight);
}

function random(min, max) {
  return min + Math.random() * (max - min);
}
