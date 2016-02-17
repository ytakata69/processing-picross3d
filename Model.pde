// The set of cubes
class Model {
  boolean[] body = new boolean[W * H * D];
  int[]     mark = new int    [W * H * D];

  Model() {
    reset();
  }

  void reset() {
    for (int i = 0; i < body.length; i++) {
      body[i] = true;
    }
    resetMark();
  }
  void resetMark() {
    for (int i = 0; i < mark.length; i++) {
      mark[i] = MK_NORMAL;
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

  IntList undoBuffer = new IntList();

  void eraseCube(int pos) {
    if (cubeExists(pos)) {
      body[pos] = false;
      undoBuffer.append(pos);
      println(undoBuffer.size() + ": " + pos);
    }
  }

  void undo() {
    if (undoBuffer.size() > 0) {
      int size = 1;
      while (--size >= 0) {
        int lastErased = undoBuffer.remove(undoBuffer.size() - 1);
        if (lastErased < 0) {
          size = -lastErased;
          continue;
        }
        body[lastErased] = true;
        println("undo: " + lastErased);
      }
    }
  }

  void eraseCubeAtCursor(View view) {
    eraseCube(cubeAtCursor(view));
  }

  void markCubeAtCursor(View view) {
    int pos = cubeAtCursor(view);
    if (cubeExists(pos)) {
      mark[pos] = (mark[pos] == MK_MARKED ? MK_NORMAL : MK_MARKED);
    }
  }

  int cubeAtCursor(View view) {
    float minD = MAX_FLOAT;
    int minPos = -1;
    for (int i = 0; i < body.length; i++) {
      int x = i % W;
      int y = int(i / W) % H;
      int z = int(i / W / H);
      if (cubeExists(i)) {
        float d = view.distToTouchedPoint(x, y, z);
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
          (face == FRONT ? rowConformsToHint(h, j, i, 0,     0, 0, 1, D)
          :face == SIDE  ? rowConformsToHint(h, 0, i, D-1-j, 1, 0, 0, W)
                         : rowConformsToHint(h, j, 0, i,     0, 1, 0, H));
        if (! conf) { return false; }
      }
    }
    return true;
  }
  private boolean rowConformsToHint(int h, int x, int y, int z, int vx, int vy, int vz, int depth) {
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
    return n == hintN(h) && (n == 0 || min(nSeg, 3) == hintSeg(h));
  }

  // Make the cubes with hint zero transparent.
  void clearZero() {
    eraseZeroRows(F, FRONT, false);
    eraseZeroRows(S, SIDE,  false);
    eraseZeroRows(T, TOP,   false);
  }

  // Erase the cubes in the rows with the hint zero.
  void eraseZero() {
    int usize = undoBuffer.size();
    eraseZeroRows(F, FRONT, true);
    eraseZeroRows(S, SIDE,  true);
    eraseZeroRows(T, TOP,   true);
    usize = undoBuffer.size() - usize;
    if (usize > 0) {
      undoBuffer.append(-usize);
    }
  }
  private void eraseZeroRows(int[][] hnt, int face, boolean erase) {
    for (int i = 0; i < hnt.length; i++) {
      for (int j = 0; j < hnt[i].length; j++) {
        int h = hnt[i][j];
        if (hintIsEpsilon(h) || hintN(h) != 0) continue;
        if (face == FRONT) {
          eraseZeroRow(j, i, 0,     0, 0, 1, D, erase);
        } else if (face == SIDE) {
          eraseZeroRow(0, i, D-1-j, 1, 0, 0, W, erase);
        } else {
          eraseZeroRow(j, 0, i,     0, 1, 0, H, erase);
        }
      }
    }
  }
  private void eraseZeroRow(int x, int y, int z, int vx, int vy, int vz, int depth, boolean erase) {
    for (int i = 0; i < depth; i++) {
      if (cubeExists(x, y, z)) {
        int pos = x + W * (y + H * z);
        if (erase) {
          eraseCube(pos);
        } else {
          mark[pos] = MK_CLEAR;
        }
      }
      x += vx;
      y += vy;
      z += vz;
    }
  }
}

