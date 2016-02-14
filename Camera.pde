class Camera {
  float distance = height * .7;

  void setCamera() {
    camera(0, 0, distance, 0, 0, 0, 0, 1, 0);
  }

  void zoom(float v) {
    distance += v;
    distance = constrain(distance, D/2 * CUBEW, 40 * CUBEW);
  }
}

