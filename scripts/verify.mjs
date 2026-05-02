import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const url = process.env.DEMO_URL ?? 'http://127.0.0.1:5173';
const outDir = new URL('../screenshots/', import.meta.url);

await mkdir(outDir, { recursive: true });

const browser = await launchBrowser();
const results = [];

try {
  for (const viewport of [
    { name: 'desktop', width: 1440, height: 900 },
    { name: 'mobile', width: 390, height: 844 }
  ]) {
    const page = await browser.newPage({ viewport });
    await page.goto(url, { waitUntil: 'networkidle' });
    await page.waitForFunction(() => window.__minigunnerDebug?.getFrameInfo().frameCount > 20);

    const before = await page.evaluate(() => window.__minigunnerDebug.getFrameInfo());
    await page.mouse.move(Math.floor(viewport.width * 0.5), Math.floor(viewport.height * 0.5));
    await page.mouse.wheel(0, 700);
    await page.waitForTimeout(220);
    const afterZoom = await page.evaluate(() => window.__minigunnerDebug.getFrameInfo());

    await page.keyboard.down('KeyW');
    await page.waitForTimeout(450);
    await page.keyboard.up('KeyW');
    const after = await page.evaluate(() => window.__minigunnerDebug.getFrameInfo());

    await page.mouse.move(Math.floor(viewport.width * 0.72), Math.floor(viewport.height * 0.44));
    await page.waitForTimeout(300);
    const placedZombies = await page.evaluate(() => window.__minigunnerDebug.forceZombiesInLane(5));
    const beforeFire = await page.evaluate(() => window.__minigunnerDebug.getFrameInfo());
    await page.mouse.down();
    await page.waitForTimeout(1000);
    const afterFire = await page.evaluate(() => window.__minigunnerDebug.getFrameInfo());
    await page.mouse.up();
    await page.waitForTimeout(250);
    const afterSpinDown = await page.evaluate(() => window.__minigunnerDebug.getFrameInfo());

    const pixels = await page.evaluate(() => window.__minigunnerDebug.samplePixels());
    await page.screenshot({
      path: fileURLToPath(new URL(`${viewport.name}.png`, outDir)),
      fullPage: true
    });

    const moved = Math.hypot(after.x - before.x, after.z - before.z);
    const nonBlankRatio = pixels.nonBlack / pixels.sampled;
    const barrelAligned = Math.min(before.barrelDot, after.barrelDot) > 0.98;
    const barrelLevel = Math.max(Math.abs(before.barrelY), Math.abs(after.barrelY), Math.abs(afterFire.barrelY)) < 0.015;
    const spunUp = afterFire.spin > 0.8;
    const spunDown = afterSpinDown.spin < afterFire.spin;
    const ejectedCasings = afterFire.activeCasings > 0 || afterSpinDown.activeCasings > 0;
    const impactsVisible = afterFire.activeImpacts > 0;
    const beltFed = afterFire.beltFeed > beforeFire.beltFeed + 0.2;
    const zoomedOut = afterZoom.cameraDistance > before.cameraDistance + 1;
    const zombiesPlaced = placedZombies >= 3;
    const zombiesDestroyed = afterFire.kills > beforeFire.kills;

    results.push({
      viewport: viewport.name,
      before,
      afterZoom,
      after,
      placedZombies,
      beforeFire,
      afterFire,
      afterSpinDown,
      moved: Number(moved.toFixed(3)),
      pixels,
      nonBlankRatio: Number(nonBlankRatio.toFixed(3)),
      barrelAligned,
      barrelLevel,
      spunUp,
      spunDown,
      ejectedCasings,
      impactsVisible,
      beltFed,
      zoomedOut,
      zombiesPlaced,
      zombiesDestroyed,
      pass: moved > 0.4 && nonBlankRatio > 0.12 && barrelAligned && barrelLevel && spunUp && spunDown && ejectedCasings && impactsVisible && beltFed && zoomedOut && zombiesPlaced && zombiesDestroyed
    });

    await page.close();
  }
} finally {
  await browser.close();
}

console.log(JSON.stringify(results, null, 2));

if (results.some((result) => !result.pass)) {
  process.exitCode = 1;
}

async function launchBrowser() {
  const edgePath = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';
  try {
    return await chromium.launch({ executablePath: edgePath });
  } catch {
    // Fall back to Playwright-managed browsers when the machine has them installed.
  }

  try {
    return await chromium.launch({ channel: 'msedge' });
  } catch {
    return chromium.launch();
  }
}
