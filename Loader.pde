// Class for loading an instance from a file
class Loader {
  // Load the hints F, S, T (and optionally the answer P) from a file.
  void loadInstance(String file) {
    String[] lines = loadStrings(file);
    ArrayList<String[]> sectSet = splitSections(lines);
    F = parseSection(sectSet.get(0));
    S = parseSection(sectSet.get(1));
    T = parseSection(sectSet.get(2));
    W = F[0].length;
    H = F.length;
    D = T.length;
    P = null;
    if (sectSet.size() > 3) {
      P = new boolean[D][H][W];
      for (int z = 0; z < D; z++) {
        int[][] buf = parseSection(sectSet.get(3 + z));
        for (int y = 0; y < H; y++) {
          for (int x = 0; x < W; x++) {
            P[z][y][x] = (buf[y][x] == 1);
          }
        }
      }
    }
  }

  // Split a list of strings into sections.
  // Sections are separated by one or more empty (or comment) lines.
  private ArrayList<String[]> splitSections(String[] lines) {
    ArrayList<String[]> sectSet = new ArrayList<String[]>();
    StringList buf = new StringList();
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].length() == 0 || lines[i].charAt(0) == '#') {
        if (buf.size() > 0) {
          sectSet.add(buf.array());
          buf = new StringList();
        }
      } else {
        buf.append(lines[i]);
      }
    }
    if (buf.size() > 0) {
      sectSet.add(buf.array());
    }
    return sectSet;
  }

  private int[][] parseSection(String[] sect) {
    int[][] hint = new int[sect.length][];
    for (int i = 0; i < sect.length; i++) {
      hint[i] = parseLine(sect[i]);
    }
    return hint;
  }

  private int[] parseLine(String ln) {
    String[] tokens = splitTokens(ln);
    int[] oneLine = new int[tokens.length];
    for (int i = 0; i < tokens.length; i++) {
      char c = tokens[i].charAt(0);
      if (c == '(' || c == '[') {
        tokens[i] = tokens[i].substring(1, tokens[i].length()-1);
      }
      if (c == '.') {
        oneLine[i] = _;
      } else {
        oneLine[i] = int(tokens[i]);
        if (c == '(' || c == '[') {
          oneLine[i] |= (c == '(' ? S2 : S3);
        }
      }
    }
    return oneLine;
  }
}
