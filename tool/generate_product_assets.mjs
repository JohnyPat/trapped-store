/**
 * Generates the [trapped] catalogue mockups used for seeding Firebase Storage.
 * Requires Node.js and Google Chrome (headless). Run: node tool/generate_product_assets.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const root = path.resolve(import.meta.dirname, '..');
const outDir = path.join(root, 'assets', 'images', 'products');
fs.mkdirSync(outDir, { recursive: true });

const fontRegular = fs.readFileSync(path.join(root, 'assets', 'fonts', 'SpaceMono-Regular.ttf')).toString('base64');
const fontBold = fs.readFileSync(path.join(root, 'assets', 'fonts', 'SpaceMono-Bold.ttf')).toString('base64');

const chromeCandidates = [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
];
const chrome = chromeCandidates.find((candidate) => fs.existsSync(candidate));
if (!chrome) throw new Error('Chrome or Edge was not found.');

const baseDefs = `
  <defs>
    <style>
      @font-face { font-family: 'Space Mono'; src: url(data:font/ttf;base64,${fontRegular}) format('truetype'); font-weight: 400; }
      @font-face { font-family: 'Space Mono'; src: url(data:font/ttf;base64,${fontBold}) format('truetype'); font-weight: 700; }
      text { font-family: 'Space Mono', monospace; }
    </style>
    <linearGradient id="blackFabric" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#222222"/><stop offset=".35" stop-color="#111111"/>
      <stop offset=".65" stop-color="#0a0a0a"/><stop offset="1" stop-color="#1b1b1b"/>
    </linearGradient>
    <linearGradient id="creamFabric" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#f0ebdf"/><stop offset=".4" stop-color="#e3ddcf"/>
      <stop offset=".7" stop-color="#d7d0c0"/><stop offset="1" stop-color="#ece7db"/>
    </linearGradient>
    <linearGradient id="burgundyFabric" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#6d1f2c"/><stop offset=".5" stop-color="#4b111c"/>
      <stop offset="1" stop-color="#7a2634"/>
    </linearGradient>
    <linearGradient id="violetFabric" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#5d4a7a"/><stop offset=".5" stop-color="#3d2e56"/>
      <stop offset="1" stop-color="#6b5689"/>
    </linearGradient>
    <linearGradient id="denimFabric" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#8f9498"/><stop offset=".45" stop-color="#6f757a"/>
      <stop offset="1" stop-color="#a4a9ac"/>
    </linearGradient>
    <linearGradient id="brownFabric" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#6b5138"/><stop offset=".5" stop-color="#4a3524"/>
      <stop offset="1" stop-color="#7b5f43"/>
    </linearGradient>
    <filter id="softShadow" x="-30%" y="-30%" width="160%" height="160%">
      <feDropShadow dx="0" dy="24" stdDeviation="22" flood-color="#000000" flood-opacity="0.20"/>
    </filter>
    <filter id="rough">
      <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" result="noise"/>
      <feDisplacementMap in="SourceGraphic" in2="noise" scale="1.6" xChannelSelector="R" yChannelSelector="G"/>
    </filter>
    <filter id="grain">
      <feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="2" result="noise"/>
      <feColorMatrix in="noise" type="saturate" values="0"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.035"/></feComponentTransfer>
      <feComposite operator="over" in2="SourceGraphic"/>
    </filter>
    <pattern id="plaid" width="90" height="90" patternUnits="userSpaceOnUse">
      <rect width="90" height="90" fill="#5b4028"/>
      <rect width="90" height="18" fill="#2d2118" opacity=".75"/>
      <rect width="18" height="90" fill="#2d2118" opacity=".55"/>
      <rect y="44" width="90" height="4" fill="#c9a96f" opacity=".55"/>
      <rect x="44" width="4" height="90" fill="#c9a96f" opacity=".4"/>
      <rect x="70" width="2" height="90" fill="#9a3434" opacity=".55"/>
    </pattern>
    <pattern id="camo" width="150" height="150" patternUnits="userSpaceOnUse">
      <rect width="150" height="150" fill="#5a5c43"/>
      <path d="M0 20 C35 0 60 40 95 20 C120 8 145 30 150 50 L150 90 C110 75 90 110 55 95 C25 82 10 105 0 90Z" fill="#343827"/>
      <path d="M20 110 C50 90 70 120 100 110 C125 102 145 125 150 140 L0 150Z" fill="#7a7551"/>
      <path d="M80 0 C95 15 120 5 130 25 C138 42 120 58 100 50 C80 42 65 20 80 0Z" fill="#25281c"/>
      <path d="M0 60 C20 50 32 70 48 78 C60 84 62 100 48 105 C25 112 10 98 0 90Z" fill="#8b8660" opacity=".6"/>
    </pattern>
    <pattern id="mesh" width="16" height="16" patternUnits="userSpaceOnUse">
      <rect width="16" height="16" fill="#141414"/>
      <circle cx="4" cy="4" r="1.4" fill="#2d2d2d"/>
      <circle cx="12" cy="12" r="1.4" fill="#2d2d2d"/>
    </pattern>
    <pattern id="denimTexture" width="26" height="26" patternUnits="userSpaceOnUse">
      <rect width="26" height="26" fill="#7c8286"/>
      <path d="M0 4 L26 2 M0 14 L26 12 M0 24 L26 22" stroke="#5d6367" stroke-width="1" opacity=".45"/>
      <path d="M6 0 L4 26 M18 0 L16 26" stroke="#a9aeb1" stroke-width=".6" opacity=".25"/>
    </pattern>
  </defs>`;

const teeBody = (fill, collar = '#000') => `
  <ellipse cx="450" cy="872" rx="250" ry="34" fill="#000" opacity=".07"/>
  <g filter="url(#softShadow)">
    <path d="M318 210 C350 176 388 158 450 158 C512 158 550 176 582 210 L706 286 C728 300 731 330 713 352 L626 450 C616 463 597 463 586 450 L560 416 L572 818 C573 840 557 856 535 856 L365 856 C343 856 327 840 328 818 L340 416 L314 450 C303 463 284 463 274 450 L187 352 C169 330 172 300 194 286 Z" fill="${fill}"/>
    <path d="M340 416 L328 818 C327 840 343 856 365 856 L378 856 L370 416 Z" fill="#fff" opacity=".035"/>
    <path d="M560 416 L572 818 C573 840 557 856 535 856 L522 856 L530 416 Z" fill="#000" opacity=".16"/>
    <path d="M318 210 C350 176 388 158 450 158 C512 158 550 176 582 210 L560 224 C534 200 500 190 450 190 C400 190 366 200 340 224 Z" fill="#fff" opacity=".05"/>
    <path d="M194 286 L274 450 M706 286 L626 450" stroke="#fff" stroke-opacity=".10" stroke-width="3"/>
    <path d="M365 856 L535 856" stroke="#fff" stroke-opacity=".12" stroke-width="3"/>
    <path d="M450 190 C420 190 398 204 394 220 C390 238 410 252 450 252 C490 252 510 238 506 220 C502 204 480 190 450 190Z" fill="${collar}" stroke="#fff" stroke-opacity=".13" stroke-width="2"/>
    <path d="M398 220 C398 236 418 246 450 246 C482 246 502 236 502 220" fill="none" stroke="#fff" stroke-opacity=".18" stroke-width="2"/>
  </g>`;

const shortsBody = (fill, overlay = '') => `
  <ellipse cx="450" cy="856" rx="230" ry="30" fill="#000" opacity=".08"/>
  <g filter="url(#softShadow)">
    <path d="M292 246 L608 246 L648 838 L472 838 L450 490 L428 838 L252 838 Z" fill="${fill}"/>
    ${overlay}
    <rect x="292" y="246" width="316" height="54" fill="#000" opacity=".16"/>
    <path d="M292 300 L608 300" stroke="#fff" stroke-opacity=".12" stroke-width="2"/>
    <path d="M450 300 L450 490" stroke="#000" stroke-opacity=".35" stroke-width="3"/>
    <path d="M420 340 C412 470 418 650 432 810 M480 340 C488 470 482 650 468 810" stroke="#fff" stroke-opacity=".07" stroke-width="5" fill="none"/>
    <path d="M310 355 C330 400 330 470 312 520 M590 355 C570 400 570 470 588 520" stroke="#000" stroke-opacity=".28" stroke-width="4" fill="none"/>
    <path d="M330 370 L352 370 L360 520 L330 520 Z" fill="#000" opacity=".10"/>
    <path d="M570 370 L548 370 L540 520 L570 520 Z" fill="#000" opacity=".10"/>
    <path d="M252 838 L428 838 M472 838 L648 838" stroke="#fff" stroke-opacity=".16" stroke-width="3"/>
    <path d="M360 246 C360 282 540 282 540 246" stroke="#d9d2c6" stroke-width="8" fill="none"/>
    <path d="M360 250 L350 330 M540 250 L550 330" stroke="#d9d2c6" stroke-width="7" stroke-linecap="round"/>
    <circle cx="450" cy="275" r="13" fill="#d9d2c6"/>
    <path d="M450 275 L450 300" stroke="#d9d2c6" stroke-width="5"/>
  </g>`;

const capBody = (fill, logoColor) => `
  <ellipse cx="450" cy="670" rx="230" ry="28" fill="#000" opacity=".08"/>
  <g filter="url(#softShadow)">
    <path d="M292 500 C292 340 364 250 470 250 C576 250 650 340 650 500 L620 538 L320 538 Z" fill="${fill}"/>
    <path d="M450 250 L450 520 M292 500 L650 500" stroke="#fff" stroke-opacity=".09" stroke-width="3"/>
    <path d="M470 250 C470 250 470 330 470 370" stroke="#fff" stroke-opacity=".10" stroke-width="2"/>
    <path d="M320 538 C220 538 150 570 146 604 C142 642 220 660 330 656 L620 656 C730 660 758 626 748 598 C736 564 676 538 620 538 Z" fill="${fill}"/>
    <path d="M320 538 C240 548 190 570 180 598" stroke="#fff" stroke-opacity=".12" stroke-width="4" fill="none"/>
    <circle cx="470" cy="250" r="10" fill="${fill}" stroke="#fff" stroke-opacity=".16"/>
    <text x="470" y="430" font-size="92" font-weight="700" text-anchor="middle" fill="${logoColor}" letter-spacing="2">T</text>
    <text x="470" y="470" font-size="15" text-anchor="middle" fill="${logoColor}" letter-spacing="5">TRAPPED</text>
    <path d="M330 590 C400 600 540 600 610 590" stroke="#fff" stroke-opacity=".10" stroke-width="2"/>
  </g>`;

const bucketBody = () => `
  <ellipse cx="450" cy="660" rx="245" ry="30" fill="#000" opacity=".08"/>
  <g filter="url(#softShadow)">
    <path d="M320 520 L345 300 C352 258 392 232 450 232 C508 232 548 258 555 300 L580 520 Z" fill="url(#violetFabric)"/>
    <path d="M320 520 C250 528 160 560 158 604 C156 642 220 660 320 660 L580 660 C680 660 744 642 742 604 C740 560 650 528 580 520 Z" fill="url(#violetFabric)"/>
    <path d="M345 300 C392 322 508 322 555 300" stroke="#fff" stroke-opacity=".18" stroke-width="3" fill="none"/>
    <path d="M350 352 L550 352 M346 404 L554 404 M342 456 L558 456" stroke="#fff" stroke-opacity=".08" stroke-width="2"/>
    <path d="M320 520 C420 540 480 540 580 520" stroke="#fff" stroke-opacity=".12" stroke-width="2" fill="none"/>
    <text x="450" y="460" font-size="26" font-weight="700" text-anchor="middle" fill="#f0e8ff" letter-spacing="4">[trapped]</text>
  </g>`;

const print = (lines, color = '#f5f2ea', size = 44) => {
  const startY = 400 - (lines.length - 1) * 30;
  return `<g filter="url(#rough)">${lines
    .map((line, index) => `<text x="450" y="${startY + index * (size + 18)}" font-size="${size}" font-weight="700" fill="${color}" text-anchor="middle" letter-spacing="2">${line}</text>`)
    .join('')}</g>`;
};

const products = [
  {
    id: 'praise-the-lord-tee',
    art: `${teeBody('url(#blackFabric)')}${print(['PRAISE THE', 'LORD'], '#f5f2ea', 54)}
      <text x="450" y="600" font-size="15" fill="#bdb9ae" text-anchor="middle" letter-spacing="4">THESE ARE THE DAYS</text>`,
  },
  {
    id: 'psalm-23-tee',
    art: `${teeBody('url(#blackFabric)')}
      <g filter="url(#rough)" fill="#f5f2ea" text-anchor="middle">
        <text x="450" y="388" font-size="22" letter-spacing="6">PSALM</text>
        <text x="450" y="470" font-size="76" font-weight="700">23:4</text>
        <path d="M450 490 L450 550 M425 512 L475 512" stroke="#f5f2ea" stroke-width="4"/>
      </g>`,
  },
  {
    id: 'heaven-sent-tee',
    art: `${teeBody('url(#blackFabric)')}
      <g filter="url(#rough)" fill="#f5f2ea" text-anchor="middle">
        <text x="450" y="405" font-size="58" font-weight="700" letter-spacing="1">HEAVEN</text>
        <text x="450" y="468" font-size="58" font-weight="700" letter-spacing="1">SENT</text>
        <text x="450" y="520" font-size="14" letter-spacing="5">NOT OF THIS WORLD</text>
      </g>`,
  },
  {
    id: 'not-of-this-world-tee',
    art: `${teeBody('url(#blackFabric)')}
      <g filter="url(#rough)" fill="#f5f2ea" text-anchor="middle">
        <text x="450" y="390" font-size="18" letter-spacing="8">NOT OF THIS</text>
        <text x="450" y="470" font-size="68" font-weight="700">WORLD</text>
        <text x="450" y="516" font-size="14" letter-spacing="4">JOHN 17:16</text>
      </g>`,
  },
  {
    id: 'grace-alone-cream-tee',
    art: `${teeBody('url(#creamFabric)', '#bdb6a7')}
      <g filter="url(#rough)" fill="#161616" text-anchor="middle">
        <text x="450" y="405" font-size="56" font-weight="700">GRACE</text>
        <text x="450" y="468" font-size="56" font-weight="700">ALONE</text>
        <text x="450" y="520" font-size="14" letter-spacing="5">SOLA GRATIA</text>
      </g>`,
  },
  {
    id: 'dusk-cargo-shorts',
    art: `${shortsBody('url(#blackFabric)')}
      <g fill="#000" opacity=".22">
        <path d="M300 390 L390 390 L390 500 L300 500 Z"/><path d="M510 390 L600 390 L600 500 L510 500 Z"/>
      </g>
      <g stroke="#fff" stroke-opacity=".12" stroke-width="2" fill="none">
        <path d="M300 390 L390 390 L390 500 L300 500 Z"/><path d="M510 390 L600 390 L600 500 L510 500 Z"/>
        <path d="M300 440 L390 440"/><path d="M510 440 L600 440"/>
      </g>
      <text x="560" y="760" font-size="14" fill="#c8c4ba" letter-spacing="3" transform="rotate(-90 560 760)">[trapped]</text>`,
  },
  {
    id: 'midnight-mesh-shorts',
    art: `${shortsBody('url(#mesh)')}
      <path d="M300 700 C340 720 390 720 430 705 M470 705 C510 720 560 720 600 700" stroke="#fff" stroke-opacity=".14" stroke-width="2" fill="none"/>
      <text x="450" y="360" font-size="17" fill="#cfcac0" text-anchor="middle" letter-spacing="5">MIDNIGHT</text>`,
  },
  {
    id: 'earth-plaid-shorts',
    art: `${shortsBody('url(#plaid)')}
      <rect x="292" y="246" width="316" height="54" fill="#2b1f15" opacity=".45"/>`,
  },
  {
    id: 'camo-utility-shorts',
    art: `${shortsBody('url(#camo)')}
      <g fill="#2c2f22" opacity=".55">
        <path d="M300 380 L382 380 L382 480 L300 480 Z"/><path d="M518 380 L600 380 L600 480 L518 480 Z"/>
      </g>
      <g stroke="#d8d3c3" stroke-opacity=".18" stroke-width="2" fill="none">
        <path d="M300 380 L382 380 L382 480 L300 480 Z"/><path d="M518 380 L600 380 L600 480 L518 480 Z"/>
      </g>`,
  },
  {
    id: 'static-denim-shorts',
    art: `${shortsBody('url(#denimTexture)')}
      <g stroke="#e3e0d8" stroke-opacity=".35" stroke-width="2" fill="none" stroke-dasharray="4 5">
        <path d="M300 400 L390 400 L390 510 L300 510 Z"/><path d="M510 400 L600 400 L600 510 L510 510 Z"/>
      </g>
      <path d="M360 320 C420 336 480 336 540 320" stroke="#d9d6ce" stroke-opacity=".35" stroke-width="2" fill="none"/>`,
  },
  {
    id: 'crimson-script-cap',
    art: `${capBody('url(#burgundyFabric)', '#e3b34a')}`,
  },
  {
    id: 'violet-bucket-hat',
    art: bucketBody(),
  },
];

for (const product of products) {
  const html = `<!doctype html>
<html><head><meta charset="utf-8"><style>
html,body{margin:0;padding:0;width:1000px;height:1200px;overflow:hidden;background:#f4f2ed;}
.frame{width:1000px;height:1200px;background:radial-gradient(ellipse at 50% 42%, #fbfaf7 0%, #f4f2ed 58%, #eae7df 100%);display:flex;align-items:center;justify-content:center;}
svg{width:1000px;height:1200px;}
</style></head><body><div class="frame"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 1000">
${baseDefs}
<rect width="900" height="1000" fill="transparent"/>
${product.art}
</svg></div></body></html>`;
  const htmlPath = path.join(outDir, `${product.id}.html`);
  fs.writeFileSync(htmlPath, html);
  const pngPath = path.join(outDir, `${product.id}.png`);
  execFileSync(chrome, [
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    '--force-device-scale-factor=1',
    '--window-size=1000,1200',
    `--screenshot=${pngPath}`,
    `file:///${htmlPath.replaceAll('\\', '/')}`,
  ], { stdio: 'ignore' });
  fs.unlinkSync(htmlPath);
  console.log(`generated ${product.id}.png`);
}

console.log(`\nDone. ${products.length} images in ${outDir}`);
