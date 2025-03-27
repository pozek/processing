
let t = 0;
let staticMode = false;
let seedOffset = 0;

let centerX, centerY;
let targetX, targetY;

function setup() {
  let canvas = createCanvas(windowWidth, windowHeight);
  canvas.parent('canvas-container');
  colorMode(HSB, 360, 100, 100, 100);
  windowResized(); // FIX: initialize center correctly
  pixelDensity(2);
}

function draw() {
  const noiseFactor = parseFloat(document.getElementById('noiseSlider').value);
  const layerCount = parseInt(document.getElementById('layersSlider').value);
  const speed = parseFloat(document.getElementById('speedSlider').value);
  const alpha = parseFloat(document.getElementById('alphaSlider').value);
  const useColor = document.getElementById('colorToggle').checked;
  const useFill = document.getElementById('fillToggle').checked;
  const invert = document.getElementById('invertToggle').checked;

  if (invert) {
    background(0);
  } else {
    background(255);
  }

  if (!staticMode) {
    t += speed;
  }

  centerX = lerp(centerX, targetX, 0.05);
  centerY = lerp(centerY, targetY, 0.05);

  for (let i = layerCount; i > 0; i--) {
    const hueVal = map(i, 1, layerCount, 0, 360);

    if (useFill) {
      if (useColor) {
        fill(hueVal, 80, 100, alpha);
      } else {
        fill(invert ? 0 : 255, alpha);
      }
      noStroke();
    } else {
      noFill();
      stroke(invert ? 255 : 0);
    }

    beginShape();
    for (let r = 0; r < TWO_PI; r += 0.2) {
      const d = i * noiseFactor * noise(r + seedOffset, i, t / 99);
      const x = (cos(r) + cos(t / 3 - i / 9.0)) * d + centerX;
      const y = (sin(r) + sin(t / 2 - i / 9.0)) * d + centerY;
      vertex(x, y);
    }
    endShape(CLOSE);
  }
}

function mousePressed() {
  targetX = mouseX;
  targetY = mouseY;
}

function keyPressed() {
  if (key === 's' || key === 'S') {
    staticMode = !staticMode;
    document.getElementById('saveButton').style.display = staticMode ? 'block' : 'none';
  }
}

document.getElementById('toggleStatic').addEventListener('click', () => {
  staticMode = !staticMode;
  document.getElementById('saveButton').style.display = staticMode ? 'block' : 'none';
});

document.getElementById('saveButton').addEventListener('click', () => {
  saveCanvas('exported_art', 'png');

  const svgCanvas = createGraphics(width, height, SVG);
  svgCanvas.colorMode(HSB, 360, 100, 100, 100);
  const useColor = document.getElementById('colorToggle').checked;
  const useFill = document.getElementById('fillToggle').checked;
  const invert = document.getElementById('invertToggle').checked;
  const noiseFactor = parseFloat(document.getElementById('noiseSlider').value);
  const layerCount = parseInt(document.getElementById('layersSlider').value);
  const alpha = parseFloat(document.getElementById('alphaSlider').value);

  svgCanvas.background(invert ? 0 : 100);

  for (let i = layerCount; i > 0; i--) {
    const hueVal = map(i, 1, layerCount, 0, 360);

    if (useFill) {
      if (useColor) {
        svgCanvas.fill(hueVal, 80, 100, alpha);
      } else {
        svgCanvas.fill(invert ? 0 : 100, 0, invert ? 0 : 100, alpha);
      }
      svgCanvas.noStroke();
    } else {
      svgCanvas.noFill();
      svgCanvas.stroke(invert ? 100 : 0);
    }

    svgCanvas.beginShape();
    for (let r = 0; r < TWO_PI; r += 0.2) {
      const d = i * noiseFactor * noise(r + seedOffset, i, t / 99);
      const x = (cos(r) + cos(t / 3 - i / 9.0)) * d + centerX;
      const y = (sin(r) + sin(t / 2 - i / 9.0)) * d + centerY;
      svgCanvas.vertex(x, y);
    }
    svgCanvas.endShape(CLOSE);
  }

  save(svgCanvas, 'exported_art.svg');
});

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  centerX = width / 2;
  centerY = height / 2;
  targetX = centerX;
  targetY = centerY;
}
