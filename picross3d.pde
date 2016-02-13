final int S2 = (1 << 8); // circle
final int S3 = (2 << 8); // square
final int _ = -1;        // epsilon

int[][] F = {
  { 3,    3,    3|S2 },
  { 2,    1,    2|S2 },
  { 3,    2|S2, 3 },
  { 2|S2, 2,    2 },
  { _,    3|S2, 3|S2 },
};
int[][] S = {
  { _, _, _, 1 },
  { 1, _, 1, 1 },
  { 1, _, _, _ },
  { 1, 2, _, _ },
  { _, 1, _, _ },
};
int[][] T = {
  { 3,    1,    _ },
  { 4|S2, 3|S3, _ },
  { _,    2|S2, 2 },
  { 2|S2, _,    _ },
};

final boolean _0 = false;
final boolean _1 = true;

boolean[][][] P = {
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

  lights();
  directionalLight(128, 128, 128, -1, 2, -2);
  pointLight(128, 128, 128, W * 1.5 * CUBEW, -H * 1.5 * CUBEW, D * 1.5 * CUBEW);

  if (mousePressed) {
    if (keyPressed && key == CODED &&
        keyCode == SHIFT)
    {
      camera.zoom(mouseY - pmouseY);
    } else {
      camera.move(mouseX - pmouseX, mouseY - pmouseY);
    }
  }
  camera.setCamera();

  translate(width/2, height/2, 0);
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

