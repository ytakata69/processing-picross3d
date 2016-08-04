// 立体ピクロス問題をSAT問題に変換する.
class SATEncoder extends ModelScanner {
  final String outputFile = dataPath("sat/p3d.cnf");
  final String solverCmd  = dataPath("sat/solve.sh");

  // 節のリスト. 節は変数の内部番号の集合.
  ArrayList<int[]> clauses = new ArrayList<int[]>();

  // 命題変数集合
  VarSet varX; // ブロックの有無
  VarSet varC; // ブロックの個数
  VarSet varS; // セグメントの個数

  // 現在走査中の行のヒントと長さ
  int hint;
  int depth;
  int ppos;

  void beginRow(int hint_, int depth_) {
    hint = hint_;
    depth = depth_;
    if (varX == null) {
      varX = getVarSet(W * H * D, 1); // ブロックの有無
    }
    // (0..depth-1)x(0..hint+1) and (0..depth-1)x(0..3)
    varC = getVarSet(depth, hintN(hint) + 2);
    varS = getVarSet(depth, 3 + 1);
  }
  void examCube(int i, int x, int y, int z, boolean exist) {
    int pos = model.coordToPos(x, y, z);
    for (int j = 0; j <= hintN(hint) + 1; j++) {
      addClauses(constraintForBlock(i, j, pos));
    }
    for (int j = 0; j <= 3; j++) {
      addClauses(constraintForSegment(i, j, ppos, pos));
    }
    ppos = pos;
  }
  void endRow() {
    // ブロック数はhint以上hint+1未満
    addClauses(new int[][] {
      {  varC.get(depth-1, hintN(hint)) },
      { -varC.get(depth-1, hintN(hint)+1) }
    });
    if (hintN(hint) > 0) {
      int nSeg = hintSeg(hint);
      addClause(new int[] { varS.get(depth-1, nSeg) }); // nSeg以上
      if (nSeg < 3) {
        addClause(new int[] { -varS.get(depth-1, nSeg+1) }); // nSeg+1未満
      }
    }
  }
  // Solve the problem using a SAT solver.
  void endScan() {
    addAnotherSolutionConstraint();
    printClauses();
    IntList ls = runSolver();
    if (ls != null) {
      model.setAnswer(ls);
    }
  }

  private void addClause(int[] vs) {
    clauses.add(vs);
  }
  private void addClauses(int[][] vss) {
    for (int i = 0; i < vss.length; i++) {
      addClause(vss[i]);
    }
  }
  private int[][] constraintForBlock(int i, int j, int pos) {
    // c_{i,j} ⇔ x_0,...,x_i中, 1がj個以上.
    if (j == 0) {
      // c_{i,0} = 1
      return new int[][] { { varC.get(i, j) } };
    }
    else if (i == 0) {
      if (j == 1) {
        // c_{0,1} ⇔ x_0
        return new int[][] {
          {  varX.get(pos), -varC.get(i, j) },
          { -varX.get(pos),  varC.get(i, j) },
        };
      } else {
        // c_{0,j} = 0
        return new int[][] { { -varC.get(i, j) } };
      }
    }
    else {
      // c_{i,j} ⇔ (c_{i-1,j} ∨ (c_{i-1,j-1} ∧ x_i))
      return new int[][] {
        { -varC.get(i-1, j), varC.get(i, j) },
        { -varC.get(i-1, j-1), -varX.get(pos), varC.get(i, j) },
        {  varC.get(i-1, j), varC.get(i-1, j-1), -varC.get(i, j) },
        {  varC.get(i-1, j), varX.get(pos),      -varC.get(i, j) },
      };
    }
  }
  private int[][] constraintForSegment(int i, int j, int ppos, int pos) {
    // s_{i,j} ⇔ x_0,...,x_i中, セグメント数がj個以上.
    if (j == 0) {
      // s_{i,0} = 1
      return new int[][] { { varS.get(i, j) } };
    }
    else if (i == 0) {
      if (j == 1) {
        // s_{0,1} ⇔ x_0
        return new int[][] {
          {  varX.get(pos), -varS.get(i, j) },
          { -varX.get(pos),  varS.get(i, j) },
        };
      } else {
        // s_{0,j} = 0
        return new int[][] { { -varS.get(i, j) } };
      }
    }
    else {
      // s_{i,j} ⇔ (s_{i-1,j} ∨ (s_{i-1,j-1} ∧ ¬x_{i-1} ∧ x_i))
      return new int[][] {
        { -varS.get(i-1, j),   varS.get(i, j) },
        { -varS.get(i-1, j-1), varX.get(ppos), -varX.get(pos), varS.get(i, j) },
        {  varS.get(i-1, j),   varS.get(i-1, j-1), -varS.get(i, j) },
        {  varS.get(i-1, j),  -varX.get(ppos),     -varS.get(i, j) },
        {  varS.get(i-1, j),   varX.get(pos),      -varS.get(i, j) },
      };
    }
  }

  private void addAnotherSolutionConstraint() {
    int nPos = W * H * D;
    int[] vs = new int[nPos];
    for (int i = 0; i < nPos; i++) {
      vs[i] = (model.cubeExists(i) ? -1 : 1) * varX.get(i);
    }
    addClause(vs);
  }

  private void printClauses() {
    PrintWriter out = createWriter(outputFile);
    out.println("p cnf " + nVar + " " + clauses.size());
    for (int i = 0; i < clauses.size(); i++) {
      int[] cl = clauses.get(i);
      for (int j = 0; j < cl.length; j++) {
        out.print(cl[j] + " ");
      }
      out.println("0");
    }
    out.flush();
    out.close();
  }

  // m×n個の命題変数を新たに確保する.
  VarSet getVarSet(int m, int n) {
    VarSet vs = new VarSet(nVar + 1, m, n);
    nVar += m * n;
    return vs;
  }

  // 確保済みの命題変数の個数
  int nVar = 0;

  // 命題変数の集合.
  // 集合内の変数は2次元の添字(i,j)で特定される.
  // 各変数は他の集合の要素と重複しない正の内部番号を持つ.
  class VarSet {
    // 内部番号の開始番号と添字の範囲を指定して命題変数集合を生成する
    VarSet(int start_, int m, int n) {
      start = start_;
      dimL = m;
      dimR = n;
    }

    int start; // 先頭の命題変数の内部番号
    int dimL;  // 左の添字の範囲(0..dimL-1)
    int dimR;  // 右の添字の範囲(0..dimR-1)

    // 変数(i,j)の内部番号を返す.
    int get(int i, int j) {
      if (! (0 <= i && i < dimL && 0 <= j && j < dimR)) {
        println("ERROR!: VarSet.get(" + i + "," + j + ")");
      }
      return start + i * dimR + j;
    }
    int get(int i) {
      return get(i, 0);
    }
  }

  private IntList runSolver() {
    IntList ls = null;
    int n = W * H * D;
    String[] cmd = { "/bin/sh", solverCmd, "" + n, outputFile };
    try {
      Runtime rt = Runtime.getRuntime();
      Process proc = rt.exec(cmd);
      ls = readSolution(proc.getInputStream());
      proc.waitFor();
    } catch (Exception e) {
      println(e);
    }
    return ls;
  }
  private IntList readSolution(InputStream in) throws Exception {
    IntList ls = new IntList();
    BufferedReader reader = new BufferedReader(new java.io.InputStreamReader(in));
    boolean solved = false;
    String ln;
    while ((ln = reader.readLine()) != null) {
      if (ln.equals("SAT")) {
        solved = true;
        continue;
      }
      else if (ln.equals("UNSAT")) {
        println("No (other) solution");
        return null;
      }
      if (solved) {
        int pos = int(ln) - 1;
        ls.append(pos);
      }
    }
    return ls;
  }
}

