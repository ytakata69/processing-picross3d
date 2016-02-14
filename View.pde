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
    x -= int(W/2);
    y -= int(H/2);
    z -= int(D/2);
    translate(x * CUBEW, y * CUBEW, z * CUBEW);
  }

  // Draw a single cube.
  void drawCube(int x, int y, int z) {
    pushMatrix();
    setView(x, y, z);
    fill(255);
    box(CUBEW);
    popMatrix();
  }

  // Draw a hint.
  void drawHint(int x, int y, int z, int face, int h) {
    if (h == _) return;
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

  // Distance between the camera and a given cube.
  float cubeDist(int x, int y, int z) {
    pushMatrix();
    setView(x, y, z);
    PVector eye = getEyePosition();
    popMatrix();
    return eye.dist(centerPos);
  }

  final PVector centerPos = new PVector(0, 0, 0);
  final PVector[] unitVecs = { 
    new PVector(1, 0, 0),
    new PVector(0, 1, 0),
    new PVector(0, 0, 1)
  };

  // Is a given cube is touched by the mouse?
  boolean isTouched(int x, int y, int z) {
    pushMatrix();
    setView(x, y, z);
    boolean touched = false;
    for (int i = 0; i < unitVecs.length; i++) {
      PVector mousePos = getUnProjectedPointOnFloor(mouseX, mouseY, centerPos, unitVecs[i]);
      touched |= (-CUBEW/2 < mousePos.x && mousePos.x < CUBEW/2 &&
                  -CUBEW/2 < mousePos.y && mousePos.y < CUBEW/2 &&
                  -CUBEW/2 < mousePos.z && mousePos.z < CUBEW/2);
    }
    popMatrix();
    return touched;
  }
}

