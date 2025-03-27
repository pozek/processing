import processing.svg.*;

float t = 0;
float seedOffset = 0;

float centerX, centerY;
float targetX, targetY;

ArrayList<Slider> sliders;
ToggleButton colorToggle;
ToggleButton fillToggle;
ToggleButton invertToggle;
SaveButton saveBtn;

boolean staticMode = false;
boolean exportingSVG = false;
boolean renderingExport = false;

void setup() {
  size(600, 600);
  colorMode(HSB, 360, 100, 100);
  noStroke();

  centerX = width / 2;
  centerY = height / 2;
  targetX = centerX;
  targetY = centerY;

  textFont(createFont("Arial", 11));

  sliders = new ArrayList<Slider>();
  sliders.add(new Slider("Noise", 10, 1, 20, 0.1, 20, 20, 120, 6));
  sliders.add(new Slider("Layers", 45, 5, 90, 1, 20, 50, 120, 6));
  sliders.add(new Slider("Speed", 0.04, 0.001, 0.1, 0.001, 20, 80, 120, 6));
  sliders.add(new Slider("Alpha", 80, 10, 100, 1, 20, 110, 120, 6));

  colorToggle = new ToggleButton("Color Mode", false, 20, 150, 120, 20);
  fillToggle = new ToggleButton("Fill Mode", true, 20, 180, 120, 20);
  invertToggle = new ToggleButton("Invert Colors", false, 20, 210, 120, 20);

  saveBtn = new SaveButton("Save PNG & SVG", width - 150, height - 40, 130, 20);
}

void draw() {
  if (invertToggle.state) {
    background(0); // fundal negru
  } else {
    background(100); // fundal alb
  }

  float noiseFactor = sliders.get(0).value();
  int layerCount = int(sliders.get(1).value());
  float speed = sliders.get(2).value();
  float alpha = sliders.get(3).value();

  if (!staticMode) {
    t += speed;
  }

  centerX = lerp(centerX, targetX, 0.05);
  centerY = lerp(centerY, targetY, 0.05);

  drawShape(noiseFactor, layerCount, alpha);

  if (!renderingExport) {
    for (Slider s : sliders) s.draw();
    colorToggle.draw();
    fillToggle.draw();
    invertToggle.draw();

    if (staticMode) {
      saveBtn.draw();
      drawStaticLabel();
    }
  }

  if (exportingSVG) {
    exportingSVG = false;
    exportArtwork(noiseFactor, layerCount, alpha);
  }
}

void drawShape(float noiseFactor, int layerCount, float alpha) {
  int i = layerCount;

  while (i > 0) {
    float r = 0;
    float hue = map(i, 1, layerCount, 0, 360);

    if (fillToggle.state) {
      if (colorToggle.state) {
        fill(hue, 80, 100, alpha);
      } else {
        fill(invertToggle.state ? 0 : 100, 0, invertToggle.state ? 0 : 100, alpha);
      }
      noStroke();
    } else {
      noFill();
      stroke(invertToggle.state ? 100 : 0);
    }

    beginShape();
    while (r < TAU) {
      float d = i * noiseFactor * noise(r + seedOffset, i, t / 99);
      float x = (cos(r) + cos(t / 3 - i / 9.0)) * d + centerX;
      float y = (sin(r) + sin(t / 2 - i / 9.0)) * d + centerY;
      vertex(x, y);
      r += 0.2;
    }
    endShape(CLOSE);
    i--;
  }
}

void exportArtwork(float noiseFactor, int layerCount, float alpha) {
  renderingExport = true;

  beginRecord(SVG, "exported_art.svg");
  if (invertToggle.state) {
    background(0);
  } else {
    background(100);
  }
  drawShape(noiseFactor, layerCount, alpha);
  endRecord();

  saveFrame("exported_art-####.png");

  renderingExport = false;
  println("Export complete.");
}

void mousePressed() {
  targetX = mouseX;
  targetY = mouseY;

  for (Slider s : sliders) s.handleClick(mouseX, mouseY);
  colorToggle.handleClick(mouseX, mouseY);
  fillToggle.handleClick(mouseX, mouseY);
  invertToggle.handleClick(mouseX, mouseY);

  if (staticMode) {
    saveBtn.handleClick(mouseX, mouseY);
  }
}

void mouseDragged() {
  for (Slider s : sliders) s.handleDrag(mouseX);
}

void mouseReleased() {
  for (Slider s : sliders) s.dragging = false;
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    staticMode = !staticMode;
  }
}

void drawStaticLabel() {
  fill(invertToggle.state ? 100 : 0);
  textAlign(RIGHT, TOP);
  text("Static mode ON – press 'S' to resume", width - 10, 10);
}

// ====== SLIDER CLASS ======
class Slider {
  float val, minVal, maxVal, step;
  float x, y, w, h;
  boolean dragging = false;
  String label;

  Slider(String labelText, float initial, float minV, float maxV, float stepV, float px, float py, float pw, float ph) {
    label = labelText;
    val = initial;
    minVal = minV;
    maxVal = maxV;
    step = stepV;
    x = px;
    y = py;
    w = pw;
    h = ph;
  }

  void draw() {
    stroke(0);
    strokeWeight(1);
    line(x, y + h / 2, x + w, y + h / 2);

    float knobX = map(val, minVal, maxVal, x, x + w);
    noStroke();
    fill(0);
    rect(knobX - 4, y, 8, h);

    fill(0);
    textAlign(LEFT, BOTTOM);
    text(label + ": " + nf(val, 1, 2), x, y - 4);
  }

  void handleClick(float mx, float my) {
    if (mx > x && mx < x + w && my > y && my < y + h) {
      dragging = true;
      updateValue(mx);
    }
  }

  void handleDrag(float mx) {
    if (dragging) updateValue(mx);
  }

  void updateValue(float mx) {
    val = map(mx, x, x + w, minVal, maxVal);
    val = constrain(val, minVal, maxVal);
    val = round(val / step) * step;
  }

  float value() {
    return val;
  }
}

// ====== TOGGLE BUTTON CLASS ======
class ToggleButton {
  String label;
  boolean state;
  float x, y, w, h;

  ToggleButton(String labelText, boolean initialState, float px, float py, float pw, float ph) {
    label = labelText;
    state = initialState;
    x = px;
    y = py;
    w = pw;
    h = ph;
  }

  void draw() {
    stroke(0);
    fill(state ? 0 : 255);
    rect(x, y, w, h);
    fill(state ? 255 : 0);
    textAlign(CENTER, CENTER);
    text(label + ": " + (state ? "ON" : "OFF"), x + w / 2, y + h / 2);
  }

  void handleClick(float mx, float my) {
    if (mx > x && mx < x + w && my > y && my < y + h) {
      state = !state;
    }
  }
}

// ====== SAVE BUTTON CLASS ======
class SaveButton {
  String label;
  float x, y, w, h;

  SaveButton(String labelText, float px, float py, float pw, float ph) {
    label = labelText;
    x = px;
    y = py;
    w = pw;
    h = ph;
  }

  void draw() {
    stroke(0);
    fill(255);
    rect(x, y, w, h);
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }

  void handleClick(float mx, float my) {
    if (mx > x && mx < x + w && my > y && my < y + h) {
      exportingSVG = true;
    }
  }
}
