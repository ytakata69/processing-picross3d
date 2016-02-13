class Camera {
  // the center point of the scene
  final float ox = width  / 2;
  final float oy = height / 2;
  final float oz = 0;

  // the eye position in the polar coordinates
  float distance = height * .7;
  float latitude  = HALF_PI;
  float longitude = HALF_PI;

  // This function must be called before translate().
  void setCamera() {
    float y = distance * cos(longitude);
    float z = distance * sin(longitude);
    float x = z * cos(latitude);
          z = z * sin(latitude);
    camera(x + ox, y + oy, z + oz, ox, oy, oz, 0, 1, 0);
  }

  void move(float vx, float vy) {
    latitude  += map(vx, 0, width,  0, PI);
    longitude += map(vy, 0, height, 0, PI);
    longitude = constrain(longitude, radians(1), radians(179));
  }

  void zoom(float v) {
    distance += v;
    distance = constrain(distance, D/2 * CUBEW, 40 * CUBEW);
  }
}

