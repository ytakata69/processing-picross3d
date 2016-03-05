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
    ConformityChecker checker = new ConformityChecker();
    scanCubes(checker);
    return checker.success();
  }

  // Make the cubes with hint zero transparent.
  void clearZero() {
    scanCubes(new ZeroEraser(false));
  }

  // Erase the cubes in the rows with the hint zero.
  void eraseZero() {
    int usize = undoBuffer.size();
    scanCubes(new ZeroEraser(true));
    usize = undoBuffer.size() - usize;
    if (usize > 0) {
      undoBuffer.append(-usize);
    }
  }

  // Make a scanner look through the cubes.
  void scanCubes(Scanner scanner) {
    scanCubesFromFace(F, FRONT, scanner);
    scanCubesFromFace(S, SIDE,  scanner);
    scanCubesFromFace(T, TOP,   scanner);
  }
  private void scanCubesFromFace(int[][] hnt, int face, Scanner scanner) {
    for (int i = 0; i < hnt.length; i++) {
      for (int j = 0; j < hnt[i].length; j++) {
        int h = hnt[i][j];
        if (hintIsEpsilon(h)) continue;
        scanner.beginRow(h);
        if (face == FRONT) {
          scanRow(j, i, 0,     0, 0, 1, D, scanner);
        } else if (face == SIDE) {
          scanRow(0, i, D-1-j, 1, 0, 0, W, scanner);
        } else {
          scanRow(j, 0, i,     0, 1, 0, H, scanner);
        }
        scanner.endRow();
      }
    }
  }
  private void scanRow(int x, int y, int z, int vx, int vy, int vz, int depth, Scanner scanner) {
    for (int i = 0; i < depth; i++) {
      scanner.examCube(x, y, z, cubeExists(x, y, z));
      x += vx;
      y += vy;
      z += vz;
    }
  }
  abstract class Scanner {
    abstract void examCube(int x, int y, int z, boolean exist);
    void beginRow(int hint) {}
    void endRow() {}
  }
  class ConformityChecker extends Scanner {
    int hint;
    boolean conform = true;
    int n, nSeg;
    boolean prevExist;
    void beginRow(int hint_) {
      hint = hint_;
      n = 0;
      nSeg = 0;
      prevExist = false;
    }
    void examCube(int x, int y, int z, boolean exist) {
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
  class ZeroEraser extends Scanner {
    boolean erase;
    boolean zero;
    ZeroEraser(boolean erase_) {
      erase = erase_;
    }
    void beginRow(int hint) {
      zero = (hintN(hint) == 0);
    }
    void examCube(int x, int y, int z, boolean exist) {
      if (zero && exist) {
        int pos = x + W * (y + H * z);
        if (erase) {
          eraseCube(pos);
        } else {
          mark[pos] = MK_CLEAR;
        }
      }
    }
  }
}

