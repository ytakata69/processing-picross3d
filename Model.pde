// The set of cubes
class Model {
  boolean[] body = new boolean[W * H * D];

  Model() {
    reset();
  }

  void reset() {
    for (int i = 0; i < body.length; i++) {
      body[i] = true;
    }
  }

  void setAnswer(boolean[][][] P) {
    for (int i = 0; i < body.length; i++) {
      int x = i % W;
      int y = int(i / W) % H;
      int z = int(i / W / H);
      body[i] = P[D-1-z][y][x];
    }
  }

  int lastErased = -1;

  void eraseCube(int pos) {
    if (cubeExists(pos)) {
      body[pos] = false;
      lastErased = pos;
    }
  }

  void undo() {
    if (lastErased >= 0) {
      body[lastErased] = true;
      lastErased = -1;
    }
  }

  void eraseCubeAtCursor(View view) {
    float minD = MAX_FLOAT;
    int minPos = -1;
    for (int i = 0; i < body.length; i++) {
      int x = i % W;
      int y = int(i / W) % H;
      int z = int(i / W / H);
      if (cubeExists(i) && view.isTouched(x, y, z)) {
        float d = view.cubeDist(x, y, z);
        if (minD > d) {
          minD   = d;
          minPos = i;
        }
      }
    }
    if (minD < MAX_FLOAT) {
      eraseCube(minPos);
    }
  }

  boolean cubeExists(int pos) {
    return 0 <= pos && pos < body.length &&
           body[pos];
  }

  boolean cubeExists(int x, int y, int z) {
    return cubeExists(x + W * (y + H * z));
  }

  void draw(View view) {
    for (int i = 0; i < body.length; i++) {
      if (cubeExists(i)) {
        int x = i % W;
        int y = int(i / W) % H;
        int z = int(i / W / H);
        view.drawCube(x, y, z);
        if (z == D-1 || ! cubeExists(x, y, z+1)) {
          view.drawHint(x, y, z, FRONT, F[y][x]);
        }
        if (x == W-1 || ! cubeExists(x+1, y, z)) {
          view.drawHint(x, y, z, SIDE, S[y][D-1-z]);
        }
        if (y == 0 || ! cubeExists(x, y-1, z)) {
          view.drawHint(x, y, z, TOP, T[z][x]);
        }
      }
    }
  }
}

