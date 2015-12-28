final int MAX_PARTICLE = 15;
Particle[] p = new Particle[MAX_PARTICLE];
 
final int LIGHT_FORCE_RATIO = 5; 
final int LIGHT_DISTANCE= 75 * 75;
final int BORDER = 75;
 
float baseRed, baseGreen, baseBlue;
float baseRedAdd, baseGreenAdd, baseBlueAdd;
final float RED_ADD = 1.2;
final float GREEN_ADD = 1.7;
final float BLUE_ADD = 2.3;
 
import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;

LeapMotionP5 leap;
void setup() {
  size(1000, 1000);
 
  for (int i = 0; i < MAX_PARTICLE; i++) {
    p[i] = new Particle();
  }
 
  baseRed = 0;
  baseRedAdd = RED_ADD;
 
  baseGreen = 0;
  baseGreenAdd = GREEN_ADD;
 
  baseBlue = 0;
  baseBlueAdd = BLUE_ADD;
}
 
void draw() {
  background(0);
 
  baseRed += baseRedAdd;
  baseGreen += baseGreenAdd;
  baseBlue += baseBlueAdd;
 
  colorOutCheck();
 
  for (int pid = 0; pid < MAX_PARTICLE; pid++) {
    p[pid].move(mouseX, mouseY);
  }
 
  //  各ピクセルの色の計算
  int tRed = (int)baseRed;
  int tGreen = (int)baseGreen;
  int tBlue = (int)baseBlue;
 
  //  綺麗に光を出すために二乗する
  tRed *= tRed;
  tGreen *= tGreen;
  tBlue *= tBlue;
 
  //  各パーティクルの周囲のピクセルの色について、加算を行う
  loadPixels();
  for (int pid = 0; pid < MAX_PARTICLE; pid++) {
 
    //  パーティクルの計算影響範囲
    int left = max(0, p[pid].x - BORDER);
    int right = min(width, p[pid].x + BORDER);
    int top = max(0, p[pid].y - BORDER);
    int bottom = min(height, p[pid].y + BORDER);
 
    //  パーティクルの影響範囲のピクセルについて、色の加算を行う
    for (int y = top; y < bottom; y++) {
      for (int x = left; x < right; x++) {
        int pixelIndex = x + y * width;
 
        //  ピクセルから、赤・緑・青の要素を取りだす
        int r = pixels[pixelIndex] >> 16 & 0xFF;
        int g = pixels[pixelIndex] >> 8 & 0xFF;
        int b = pixels[pixelIndex] & 0xFF;
 
        //  パーティクルとピクセルとの距離を計算する
        int dx = x - p[pid].x;
        int dy = y - p[pid].y;
        int distance = (dx * dx) + (dy * dy);  //  三平方の定理だが、高速化のため、sqrt()はしない。
 
        //  ピクセルとパーティクルの距離が一定以内であれば、色の加算を行う
        if (distance < LIGHT_DISTANCE) {
          int fixFistance = distance * LIGHT_FORCE_RATIO;
          //  0除算の回避
          if (fixFistance == 0) {
            fixFistance = 1;
          }   
          r = r + tRed / fixFistance;
          g = g + tGreen / fixFistance;
          b = b + tBlue / fixFistance;
        }
 
        //  ピクセルの色を変更する
        pixels[x + y * width] = color(r, g, b);
      }
    }
  }
  updatePixels();
}
 
//  マウスクリック時に、各パーティクルをランダムな方向に飛ばす
void mousePressed() {
  for (int pid = 0; pid < MAX_PARTICLE; pid++) {
    p[pid].explode();
  }
}
 
//  色の値が範囲外に変化した場合は符号を変える
void colorOutCheck() {
  if (baseRed < 10) {
    baseRed = 10;
    baseRedAdd *= -1;
  }
  else if (baseRed > 255) {
    baseRed = 255;
    baseRedAdd *= -1;
  }
 
  if (baseGreen < 10) {
    baseGreen = 10;
    baseGreenAdd *= -1;
  }
  else if (baseGreen > 255) {
    baseGreen = 255;
    baseGreenAdd *= -1;
  }
 
  if (baseBlue < 10) {
    baseBlue = 10;
    baseBlueAdd *= -1;
  }
  else if (baseBlue > 255) {
    baseBlue = 255;
    baseBlueAdd *= -1;
  }
}
 
//  パーティクルクラス
class Particle {
  int x, y;        //  位置
  float vx, vy;    //  速度
  float slowLevel; //  座標追従遅延レベル
  final float DECEL_RATIO = 0.95;  //  減速率
 
  Particle() {
    x = (int)random(width);
    y = (int)random(height);
    slowLevel = random(100) + 5;
  }
 
  //  移動
  void move(float targetX, float targetY) {
 
    //  ターゲットに向かって動こうとする
    vx = vx * DECEL_RATIO + (targetX - x) / slowLevel;
    vy = vy * DECEL_RATIO + (targetY - y) / slowLevel;
 
    //  座標を移動
    x = (int)(x + vx);
    y = (int)(y + vy);
  }
 
  //  適当な方向に飛び散る
  void explode() {
    vx = random(100) - 50;
    vy = random(100) - 50;
    slowLevel = random(100) + 5;
  }
}