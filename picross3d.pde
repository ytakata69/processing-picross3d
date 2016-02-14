/**
 * A program for illustrating
 * 3D Picross instances.
 *
 * <ul>
 * <li>Drag: change the camera position.</li>
 * <li>Drag up/down + shift: zoom in/out.</li>
 * <li>Press 'a': show the answer.</li>
 * </ul>
 */

// Define the hints.
final int S2 = (1 << 8); // circle
final int S3 = (2 << 8); // square
final int _ = -1;        // epsilon

// The following Picross instance
// is cited from [Kusano+2010].
final int[][] F = {
  { 3,    3,    3|S2 },
  { 2,    1,    2|S2 },
  { 3,    2|S2, 3 },
  { 2|S2, 2,    2 },
  { _,    3|S2, 3|S2 },
};
final int[][] S = {
  { _, _, _, 1 },
  { 1, _, 1, 1 },
  { 1, _, _, _ },
  { 1, 2, _, _ },
  { _, 1, _, _ },
};
final int[][] T = {
  { 3,    1,    _ },
  { 4|S2, 3|S3, _ },
  { _,    2|S2, 2 },
  { 2|S2, _,    _ },
};

final boolean _0 = false;
final boolean _1 = true;

final boolean[][][] P = {
  {
    { _1, _1, _1 },
    { _0, _1, _0 },
    { _0, _1, _0 },
    { _0, _1, _0 },
    { _1, _1, _1 },
  },
  {
    { _1, _1, _0 },
    { _1, _0, _1 },
    { _1, _0, _1 },
    { _1, _1, _0 },
    { _1, _0, _0 },
  },
  {
    { _1, _1, _1 },
    { _1, _0, _0 },
    { _1, _1, _1 },
    { _0, _0, _1 },
    { _1, _1, _1 },
  },
  {
    { _0, _0, _1 },
    { _0, _0, _1 },
    { _1, _0, _1 },
    { _1, _0, _1 },
    { _1, _1, _1 },
  },
};

final int W = F[0].length;
final int H = F.length;
final int D = T.length;
final int FRONT = 0;
final int SIDE  = 1;
final int TOP   = 2;

// the size of a cube in the xyz-space
final float CUBEW = 30;

View view;
Camera camera;

void setup(){
  size(400, 400, P3D);
  view = new View();
  camera = new Camera();
}

void draw(){
  background(204);

  // lightings
  lights();
  directionalLight(64, 64, 64, -1, 2, -2);
  pointLight(255, 255, 255, W * 1.5 * CUBEW, -H * 1.5 * CUBEW, D * 1.5 * CUBEW);

  // rotation and zoom in/out
  if (mousePressed) {
    if (keyPressed && key == CODED &&
        keyCode == SHIFT)
    {
      camera.zoom(mouseY - pmouseY);
    } else {
      view.rotate(mouseX - pmouseX, mouseY - pmouseY);
    }
  }
  camera.setCamera();

  // cubes
  setCursorCube();
  drawCubes();
}

boolean showAnswer = false;

void keyTyped() {
  if (key == 'a' || key == 'A') {
    showAnswer = ! showAnswer;
  }
}

boolean showCube(int x, int y, int z) {
  return !showAnswer || P[D-1-z][y][x];
}

void setCursorCube() {
  int minX = 0;
  int minY = 0;
  int minZ = 0;
  float minD = MAX_FLOAT;
  for (int x = 0; x < W; x++) {
    for (int y = 0; y < H; y++) {
      for (int z = 0; z < D; z++) {
        if (showCube(x, y, z) && view.isTouched(x, y, z)) {
          float d = view.cubeDist(x, y, z);
          if (minD > d) {
            minD = d;
            minX = x;
            minY = y;
            minZ = z;
          }
        }
      }
    }
  }
  if (minD < MAX_FLOAT) {
    view.setCursor(minX, minY, minZ);
  } else {
    view.resetCursor();
  }
}

void drawCubes() {
  for (int x = 0; x < W; x++) {
    for (int y = 0; y < H; y++) {
      for (int z = 0; z < D; z++) {
        if (showCube(x, y, z)) {
          view.drawCube(x, y, z);
          if (z == D-1 || ! showCube(x, y, z+1)) {
            view.drawHint(x, y, z, FRONT, F[y][x]);
          }
          if (x == W-1 || ! showCube(x+1, y, z)) {
            view.drawHint(x, y, z, SIDE, S[y][D-1-z]);
          }
          if (y == 0 || ! showCube(x, y-1, z)) {
            view.drawHint(x, y, z, TOP, T[z][x]);
          }
        }
      }
    }
  }
}

