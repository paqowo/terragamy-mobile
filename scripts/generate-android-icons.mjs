import fs from "node:fs/promises";
import path from "node:path";
import sharp from "sharp";

const rootDir = process.cwd();
const sourcePng = path.join(rootDir, "public", "app-logo.png");
const resRoot = path.join(
  rootDir,
  "src-tauri",
  "gen",
  "android",
  "app",
  "src",
  "main",
  "res"
);

const iconSizes = [
  { dir: "mipmap-mdpi", size: 48 },
  { dir: "mipmap-hdpi", size: 72 },
  { dir: "mipmap-xhdpi", size: 96 },
  { dir: "mipmap-xxhdpi", size: 144 },
  { dir: "mipmap-xxxhdpi", size: 192 }
];

try {
  await fs.access(sourcePng);
} catch {
  console.error(`Missing source icon: ${sourcePng}`);
  process.exit(1);
}

for (const { dir, size } of iconSizes) {
  const outDir = path.join(resRoot, dir);
  await fs.mkdir(outDir, { recursive: true });

  const base = sharp(sourcePng).resize(size, size, {
    fit: "contain",
    background: { r: 0, g: 0, b: 0, alpha: 0 }
  });
  await base.clone().png().toFile(path.join(outDir, "ic_launcher.png"));
  await base.clone().png().toFile(path.join(outDir, "ic_launcher_round.png"));
}

console.log("Android launcher icons generated from public/app-logo.png.");
