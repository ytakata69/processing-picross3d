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

  // Check the conformity to the hints.
  boolean isAnswer() {
    int[][] nF    = new int[H][W];
    int[][] nS    = new int[H][D];
    int[][] nT    = new int[D][W];
    int[][] nSegF = new int[H][W];
    int[][] nSegS = new int[H][D];
    int[][] nSegT = new int[D][W];
    for (int x = 0; x < W; x++) {
      for (int y = 0; y < H; y++) {
        for (int z = 0; z < D; z++) {
          if (cubeExists(x, y, z)) {
            nF[y][x]++;
            nS[y][z]++;
            nT[z][x]++;
            nSegF[y][x] += (z == 0 || ! cubeExists(x, y, z-1) ? 1 : 0);
            nSegS[y][z] += (x == 0 || ! cubeExists(x-1, y, z) ? 1 : 0);
            nSegT[z][x] += (y == 0 || ! cubeExists(x, y-1, z) ? 1 : 0);
          }
        }
      }
    }
    for (int x = 0; x < W; x++) {
      for (int y = 0; y < H; y++) {
        int h = F[y][x];
        if (! hintIsEpsilon(h) &&
            (nF[y][x] != hintN(h) || min(nSegF[y][x], 3) != hintSeg(h)))
        {
          return false;
        }
      }
      for (int z = 0; z < D; z++) {
        int h = T[z][x];
        if (! hintIsEpsilon(h) &&
            (nT[z][x] != hintN(h) || min(nSegT[z][x], 3) != hintSeg(h)))
        {
          return false;
        }
      }
    }
    for (int y = 0; y < H; y++) {
      for (int z = 0; z < D; z++) {
        int h = S[y][D-1-z];
        if (! hintIsEpsilon(h) &&
            (nS[y][z] != hintN(h) || min(nSegS[y][z], 3) != hintSeg(h)))
        {
          return false;
        }
      }
    }
    return true;
  }
}

