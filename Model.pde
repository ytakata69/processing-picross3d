// The set of cubes
class Model {
  boolean[] body = new boolean[W * H * D];
  int[]     mark = new int    [W * H * D];

  Model() {
    reset();
  }

  int coordToPos(int x, int y, int z) {
    return x + W * (y + H * z);
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
    return cubeExists(coordToPos(x, y, z));
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
    ConformityChecker checker = new ConformityChecker();
    checker.scan(this);
    return checker.success();
  }

  // Make the cubes with hint zero transparent.
  void clearZero() {
    new ZeroEraser(false).scan(this);
  }

  // Erase the cubes in the rows with the hint zero.
  void eraseZero() {
    int usize = undoBuffer.size();
    new ZeroEraser(true).scan(this);
    usize = undoBuffer.size() - usize;
    if (usize > 0) {
      undoBuffer.append(-usize);
    }
  }

  class ConformityChecker extends ModelScanner {
    int hint;
    boolean conform = true;
    int n, nSeg;
    boolean prevExist;
    void beginRow(int hint_, int depth) {
      hint = hint_;
      n = 0;
      nSeg = 0;
      prevExist = false;
    }
    void examCube(int i, int x, int y, int z, boolean exist) {
      if (exist) {
        n++;
        if (! prevExist) { nSeg++; }
      }
      prevExist = exist;
    }
    void endRow() {
      conform &=
        (n == hintN(hint) && (n == 0 || min(nSeg, 3) == hintSeg(hint)));
    }
    boolean success() {
      return conform;
    }
  }
  class ZeroEraser extends ModelScanner {
    boolean erase;
    boolean zero;
    ZeroEraser(boolean erase_) {
      erase = erase_;
    }
    void beginRow(int hint, int depth) {
      zero = (hintN(hint) == 0);
    }
    void examCube(int i, int x, int y, int z, boolean exist) {
      if (zero && exist) {
        int pos = coordToPos(x, y, z);
        if (erase) {
          eraseCube(pos);
        } else {
          mark[pos] = MK_CLEAR;
        }
      }
    }
  }
}

abstract class ModelScanner {
  abstract void examCube(int i, int x, int y, int z, boolean exist);
  void beginRow(int hint, int depth) {}
  void endRow() {}
  protected Model model;

  // Look through the cubes.
  void scan(Model model_) {
    model = model_;
    scanFace(F, FRONT);
    scanFace(S, SIDE);
    scanFace(T, TOP);
  }
  private void scanFace(int[][] hnt, int face) {
    for (int i = 0; i < hnt.length; i++) {
      for (int j = 0; j < hnt[i].length; j++) {
        int h = hnt[i][j];
        if (hintIsEpsilon(h)) continue;
        if (face == FRONT) {
          beginRow(h, D);
          scanRow(j, i, 0,     0, 0, 1, D);
        } else if (face == SIDE) {
          beginRow(h, W);
          scanRow(0, i, D-1-j, 1, 0, 0, W);
        } else {
          beginRow(h, H);
          scanRow(j, 0, i,     0, 1, 0, H);
        }
        endRow();
      }
    }
  }
  private void scanRow(int x, int y, int z, int vx, int vy, int vz, int depth) {
    for (int i = 0; i < depth; i++) {
      examCube(i, x, y, z, model.cubeExists(x, y, z));
      x += vx;
      y += vy;
      z += vz;
    }
  }
}

