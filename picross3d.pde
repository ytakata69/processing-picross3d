/**
 * A program for illustrating
 * 3D Picross instances.
 *
 * <ul>
 * <li>Drag: Rotate the model.</li>
 * <li>Shift + Drag up/down: Zoom in/out.</li>
 * <li>Ctrl + Click: Erase a cube.</li>
 * <li>Alt  + Click: Mark a cube.</li>
 * <li>Press 'u': Undo.</li>
 * <li>Press 'r': Reset the model.</li>
 * <li>Press 'a': Show the answer.</li>
 * <li>Press '0': Make the cubes transparent in the rows with hint "0".</li>
 * <li>Press ')': Erase the cubes in the rows with hint "0".</li>
 * <li>Press 'F' or 'B': Move to another puzzle instance.</li>
 * </ul>
 */

// Files that define Picross instances
String[] files = {
  "ipsj.txt",
  "truth.txt",
  "clause.txt",
  "second-floor.txt",
  "second-floor-mod.txt",
  "interlock.txt",
  "interlock-twin.txt",
};
int selectedFile = 0;

// The hints in the front, side, and top faces
int[][] F, S, T;
// The dimensions
int W, H, D;
// An answer
boolean[][][] P;
// Caption label
String label;

// Define the hints.
final int S2 = (1 << 8); // circle
final int S3 = (2 << 8); // square
final int _ = -1;        // epsilon

// labels for each face
final int FRONT = 0;
final int SIDE  = 1;
final int TOP   = 2;

// labels for mark
final int MK_NORMAL = 0;
final int MK_MARKED = 1;
final int MK_CLEAR  = 2;

// the size of a cube in the xyz-space
final float CUBEW = 30;

Model model;
View view;
Camera camera;

void setup(){
  size(400, 400, P3D);
  new Loader().loadInstance(files[selectedFile]);
  model  = new Model();
  view   = new View();
  camera = new Camera();
}

void draw(){
  if (model.isAnswer()) {
    model.resetMark();
    background(255, 180, 128);
  } else {
    background(204);
  }

  // lightings
  lights();
  directionalLight(64, 64, 64, -1, 2, -2);
  pointLight(255, 255, 255, W * 1.5 * CUBEW, -H * 1.5 * CUBEW, D * 1.5 * CUBEW);

  // rotation and zoom in/out
  if (mousePressed) {
    if (keyPressed && key == CODED &&
        keyCode == SHIFT)
    {
      camera.zoom(mouseY - pmouseY);
    } else {
      view.rotate(mouseX - pmouseX, mouseY - pmouseY);
    }
  }
  camera.setCamera();

  // cubes
  model.draw(view);

  // caption label
  if (label != null) {
    view.drawLabel(label);
  }
}

void mousePressed() {
  if (keyPressed && key == CODED) {
    if (keyCode == CONTROL) {
      model.eraseCubeAtCursor(view);
    }
    else if (keyCode == ALT) {
      model.markCubeAtCursor(view);
    }
  }
}

void keyTyped() {
  if (key == 'a' || key == 'A') {
    model.setAnswer(P);
  }
  else if (key == 'u' || key == 'U') {
    model.undo();
  }
  else if (key == 'r' || key == 'R') {
    model.reset();
  }
  else if (key == '0') {
    model.clearZero();
  }
  else if (key == ')') {
    model.eraseZero();
  }
  else if (key == 'F' || key == 'B') {
    selectedFile += (key == 'F' ? 1 : -1);
    selectedFile = (selectedFile + files.length) % files.length;
    new Loader().loadInstance(files[selectedFile]);
    model = new Model();
  }
}

boolean hintIsEpsilon(int h) {
    return h == _;
}
int hintN(int h) {
  return h & 0xff;
}
int hintSeg(int h) {
  return (h & S2) != 0 ? 2 :
         (h & S3) != 0 ? 3 : 1;
}

