// The set of cubes
class Model {
  boolean[] body = new boolean[W * H * D];
  boolean[] mark = new boolean[W * H * D];

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
    eraseCube(cubeAtCursor(view));
  }

  void markCubeAtCursor(View view) {
    int pos = cubeAtCursor(view);
    if (cubeExists(pos)) {
      mark[pos] = ! mark[pos];
    }
  }

  int cubeAtCursor(View view) {
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
    return minD < MAX_FLOAT ? minPos : -1;
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
        view.drawCube(x, y, z, mark[i]);
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

  // Check the conformity to the hints.
  boolean isAnswer() {
    return conformsToHint(F, FRONT)
        && conformsToHint(S, SIDE)
        && conformsToHint(T, TOP);
  }

  private boolean conformsToHint(int[][] hnt, int face) {
    for (int i = 0; i < hnt.length; i++) {
      for (int j = 0; j < hnt[i].length; j++) {
        int h = hnt[i][j];
        if (hintIsEpsilon(h)) continue;
        boolean conf =
          (face == FRONT ? lineConformsToHint(h, j, i, 0,     0, 0, 1, D)
          :face == SIDE  ? lineConformsToHint(h, 0, i, D-1-j, 1, 0, 0, W)
                         : lineConformsToHint(h, j, 0, i,     0, 1, 0, H));
        if (! conf) { return false; }
      }
    }
    return true;
  }
  private boolean lineConformsToHint(int h, int x, int y, int z, int vx, int vy, int vz, int depth) {
    int n = 0;
    int nSeg = 0;
    boolean prev = false;
    for (int i = 0; i < depth; i++) {
      if (cubeExists(x, y, z)) {
        n++;
        if (! prev) { nSeg++; }
        prev = true;
      } else {
        prev = false;
      }
      x += vx;
      y += vy;
      z += vz;
    }
    return n == hintN(h) && min(nSeg, 3) == hintSeg(h);
  }
}

