// The set of drawing functions
class View {
  float latitude  = 0;
  float longitude = 0;

  // Rotate the cubes.
  void rotate(float vx, float vy) {
    latitude  += map(vx, 0, width,  0, PI);
    longitude -= map(vy, 0, height, 0, PI);
//  longitude = constrain(longitude, radians(1), radians(179));
  }

  // Set the model view matrix for a cube at (x,y,z).
  private void setView(int x, int y, int z) {
    rotateX(longitude);
    rotateY(latitude);
    float cx = (x - (W - 1) * 0.5) * CUBEW;
    float cy = (y - (H - 1) * 0.5) * CUBEW;
    float cz = (z - (D - 1) * 0.5) * CUBEW;
    translate(cx, cy, cz);
  }

  // Draw a single cube.
  void drawCube(int x, int y, int z, int mark) {
    pushMatrix();
    setView(x, y, z);
    switch (mark) {
    case MK_NORMAL:
      fill(255);
      break;
    case MK_MARKED:
      fill(255, 100, 100);
      break;
    case MK_CLEAR:
      noFill();
      break;
    }
    box(CUBEW);
    popMatrix();
  }

  // Draw a hint.
  void drawHint(int x, int y, int z, int face, int h) {
    if (hintIsEpsilon(h)) return;
    pushMatrix();
    setView(x, y, z);
    if (face == SIDE) {
      rotateY(HALF_PI);
    } else if (face == TOP) {
      rotateX(HALF_PI);
    }
    fill(0);
    textSize(CUBEW * .7);
    textAlign(CENTER, CENTER);
    translate(0, 0, CUBEW/2 + 1);
    text(hintN(h), 0, -.1 * CUBEW, 0);
    noFill();
    if (hintSeg(h) == 2) {
      float d = CUBEW * .8;
      ellipse(0, 0, d, d);
    }
    else if (hintSeg(h) == 3) {
      float d = CUBEW * .72;
      rect(-d/2, -d/2, d, d);
    }
    popMatrix();
  }

  final PVector[][] cubePlanes = {
    { new PVector(0.5 * CUBEW, 0, 0), new PVector(-0.5 * CUBEW, 0, 0) },
    { new PVector(0, 0.5 * CUBEW, 0), new PVector(0, -0.5 * CUBEW, 0) },
    { new PVector(0, 0, 0.5 * CUBEW), new PVector(0, 0, -0.5 * CUBEW) },
  };
  final PVector[] unitVecs = { 
    new PVector(1, 0, 0),
    new PVector(0, 1, 0),
    new PVector(0, 0, 1)
  };
  final PVector centerPos = new PVector(0, 0, 0);

  // Distance between the camera and a given cube.
  float distToTouchedPoint(int x, int y, int z) {
    float distance = MAX_FLOAT;
    pushMatrix();
    setView(x, y, z);
    PVector eye = getEyePosition();
    for (int i = 0; i < unitVecs.length; i++) {
      for (int j = 0; j <= 1; j++) {
        PVector mousePos = getUnProjectedPointOnFloor(mouseX, mouseY, cubePlanes[i][j], unitVecs[i]);
        if (-CUBEW * .51 <= mousePos.x && mousePos.x <= CUBEW * .51 &&
            -CUBEW * .51 <= mousePos.y && mousePos.y <= CUBEW * .51 &&
            -CUBEW * .51 <= mousePos.z && mousePos.z <= CUBEW * .51)
        {
          distance = min(distance, eye.dist(mousePos));
        }
      }
    }
    popMatrix();
    return distance;
  }

  // Draw a caption label
  void drawLabel(String label) {
    PVector labelPos = getUnProjectedPointOnFloor(width/2, 15, centerPos, unitVecs[2]);
    textSize(24);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, labelPos.x, labelPos.y, labelPos.z);
  }
}

