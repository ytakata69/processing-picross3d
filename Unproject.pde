/**
 * Compute the world coordinates from the screen coordinates.
 * <p>
 * This code is quoted from:
 * http://d.hatena.ne.jp/kougaku-navi/20160102/p1
 * </p>
 * <p>
 * Note: PMatrix3D etc. are not included in the Processing API,
 * and thus they may not be supported in future versions of Processing.
 * </p>
 */

// 画面座標に対応する床面上の座標を計算する関数
PVector getUnProjectedPointOnFloor(float screen_x, float screen_y, PVector floorPosition, PVector floorDirection) {

  PVector f = floorPosition.get();  // 床の位置
  PVector n = floorDirection.get(); // 床の方向（法線ベクトル）
  PVector w = unProject(screen_x, screen_y, -1.0); // 画面上の点に対応する３次元座標
  PVector e = getEyePosition(); // 視点位置

  // 交点の計算  
  f.sub(e);
  w.sub(e);
  w.mult( n.dot(f)/n.dot(w) );
  w.add(e);

  return w;
}

// 現在の座標系における視点の位置を取得する関数
PVector getEyePosition() {
  PMatrix3D mat = (PMatrix3D)getMatrix(); // モデルビュー行列を取得
  mat.invert();
  return new PVector( mat.m03, mat.m13, mat.m23 );
}

// ウィンドウ座標系からローカル座標系への変換（逆投影）を行う関数
PVector unProject(float winX, float winY, float winZ) {
  PMatrix3D mat = getMatrixLocalToWindow();  
  mat.invert();
  
  float[] in = {winX, winY, winZ, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);  // Do not use PMatrix3D.mult(PVector, PVector)
  
  if (out[3] == 0 ) {
    return null;
  }
  
  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);  
  return result;
}

// ローカル座標系からウィンドウ座標系への変換行列を計算する関数
PMatrix3D getMatrixLocalToWindow() {
  PMatrix3D projection = ((PGraphics3D)g).projection; // プロジェクション行列
  PMatrix3D modelview = ((PGraphics3D)g).modelview;   // モデルビュー行列
  
  // ビューポート変換行列
  PMatrix3D viewport = new PMatrix3D();
  viewport.m00 = viewport.m03 = width/2;
  viewport.m11 = -height/2;
  viewport.m13 =  height/2;

  // ローカル座標系からウィンドウ座標系への変換行列を計算  
  viewport.apply(projection);
  viewport.apply(modelview);
  return viewport;
}

