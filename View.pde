class View {
  void drawBase() {
    int margin = min(W, D);
    pushMatrix();
    rotateX(HALF_PI);
    translate(0, 0, -(D/2 + 0.5) * CUBEW - 1);
    noStroke();
    fill(255);
    rect(-(W/2 + 0.5 + margin) * CUBEW, -(D/2 + 0.5 + margin) * CUBEW, (2 * margin + W) * CUBEW, (2 * margin + D) * CUBEW);
    stroke(0);
    popMatrix();
  }

  void drawCube(int x, int y, int z) {
    x -= int(W/2);
    y -= int(H/2);
    z -= int(D/2);
    pushMatrix();
    translate(x * CUBEW, y * CUBEW, z * CUBEW);
    fill(255);
    box(CUBEW);
    popMatrix();
  }

  void drawHint(int x, int y, int z, int face, int h) {
    if (h == _) return;
    x -= int(W/2);
    y -= int(H/2);
    z -= int(D/2);
    pushMatrix();
    translate(x * CUBEW, y * CUBEW, z * CUBEW);
    if (face == SIDE) {
      rotateY(HALF_PI);
    } else if (face == TOP) {
      rotateX(HALF_PI);
    }
    fill(0);
    textSize(CUBEW * .7);
    textAlign(CENTER, CENTER);
    translate(0, 0, CUBEW/2 + 1);
    text(h & 255, 0, -.1 * CUBEW, 0);
    noFill();
    if ((h & S2) != 0) {
      float d = CUBEW * .8;
      ellipse(0, 0, d, d);
    }
    if ((h & S3) != 0) {
      float d = CUBEW * .72;
      rect(-d/2, -d/2, d, d);
    }
    popMatrix();
  }
}

