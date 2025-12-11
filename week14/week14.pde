float playerX = 100;
float playerY = 200;
float playerSize = 50;
int HP = 10;
boolean shield = false;
int shieldTimer = 0;

PImage playerImg;

// 道具圖片
PImage pwHeartImg, pwSlowImg, pwShieldImg;

// 障礙物圖片
PImage obsSquareImg, obsCircleImg, obsTriangleImg, obsRotateImg;

// 計時系統
int gameTime = 0;   // 單位：秒

// 道具類別
class PowerUp {
  float x, y, size;
  int type; // 0=回血、1=慢速、2=護盾
  float speed = 4;

  PowerUp() {
    size = 40;
    x = width + size;
    y = random(50, height - 50);
    type = int(random(0, 3));
  }

  void update() {
    x -= speed;
  }

  void show() {
    if (type == 0) image(pwHeartImg, x, y, size*3, size*3);
    else if (type == 1) image(pwSlowImg, x, y, size*3, size*3);
    else if (type == 2) image(pwShieldImg, x, y, size*3, size*3);
  }

  boolean hitPlayer() {
    return dist(playerX + playerSize/2, playerY + playerSize/2, x+size/2, y+size/2)
           < (playerSize/2 + size/2);
  }

  boolean offScreen() {
    return x < -size;
  }
}

// 障礙物類別
class Obstacle {
  float x, y, w, h, speed;
  int shapeType; // 0=方形、1=圓形、2=三角形、3=旋轉
  float angle = 0;

  Obstacle(float difficulty) {
    w = random(40, 80);
    h = random(40, 120);
    x = width + w;
    y = random(0, height - h);
    speed = random(3 + difficulty, 6 + difficulty);
    shapeType = int(random(0, 4));
  }

  void update() {
    x -= speed;
    angle += 0.05;
  }

  void show() {
    if (shapeType == 0) {
      image(obsSquareImg, x, y, w*3, h*3);
    } 
    else if (shapeType == 1) {
      image(obsCircleImg, x, y, w*3, h*3);
    } 
    else if (shapeType == 2) {
      image(obsTriangleImg, x, y, w*3, h*3);
    } 
    else if (shapeType == 3) {
      pushMatrix();
      translate(x + w*1.5, y + h*1.5);
      rotate(angle);
      imageMode(CENTER);
      image(obsRotateImg, 0, 0, w*3, h*3);
      imageMode(CORNER);
      popMatrix();
    }
  }

  boolean hitPlayer() {
    return (
      playerX < x + w &&
      playerX + playerSize > x &&
      playerY < y + h &&
      playerY + playerSize > y
    );
  }

  boolean offScreen() {
    return x + w < 0;
  }
}

// 全域變數
ArrayList<Obstacle> obs = new ArrayList<Obstacle>();
ArrayList<PowerUp> pws = new ArrayList<PowerUp>();

int spawnTimer = 0;
int powerTimer = 0;

boolean upKey, downKey, leftKey, rightKey;
boolean gameStart = false;
boolean gameOver = false;

// Setup
void setup() {
  size(800, 400);

  // 載入圖片
  playerImg = loadImage("player.png");

  pwHeartImg = loadImage("pw_heart.png");
  pwSlowImg = loadImage("pw_slow.png");
  pwShieldImg = loadImage("pw_shield.png");

  obsSquareImg = loadImage("obs_square.png");
  obsCircleImg = loadImage("obs_circle.png");
  obsTriangleImg = loadImage("obs_triangle.png");
  obsRotateImg = loadImage("obs_rotate.png");

  // --- 所有圖片統一放大 3 倍（提升畫質用，不影響顯示尺寸） ---
  playerImg.resize(playerImg.width * 3, playerImg.height * 3);

  pwHeartImg.resize(pwHeartImg.width * 3, pwHeartImg.height * 3);
  pwSlowImg.resize(pwSlowImg.width * 3, pwSlowImg.height * 3);
  pwShieldImg.resize(pwShieldImg.width * 3, pwShieldImg.height * 3);

  obsSquareImg.resize(obsSquareImg.width * 3, obsSquareImg.height * 3);
  obsCircleImg.resize(obsCircleImg.width * 3, obsCircleImg.height * 3);
  obsTriangleImg.resize(obsTriangleImg.width * 3, obsTriangleImg.height * 3);
  obsRotateImg.resize(obsRotateImg.width * 3, obsRotateImg.height * 3);
}

// Draw (主邏輯)
void draw() {
  background(30);

  if (!gameStart) { startScreen(); return; }
  if (gameOver) { gameOverScreen(); return; }

  float difficulty = frameCount / 600.0;

  // 玩家移動
  if (upKey)    playerY -= 5;
  if (downKey)  playerY += 5;
  if (leftKey)  playerX -= 5;
  if (rightKey) playerX += 5;

  playerX = constrain(playerX, 0, width - playerSize);
  playerY = constrain(playerY, 0, height - playerSize);

  // 計時（每 60 frame 加 1 秒）
  if (frameCount % 60 == 0) gameTime++;

  // 玩家圖片顯示 (放大3倍)
  image(playerImg, playerX, playerY, playerSize*3, playerSize*3);

  // 護盾
  if (shield) {
    stroke(255, 230, 0);
    noFill();
    ellipse(playerX + playerSize*1.5, playerY + playerSize*1.5, 70*3, 70*3);
    noStroke();
    shieldTimer--;
    if (shieldTimer <= 0) shield = false;
  }

  // 障礙物生成
  spawnTimer++;
  if (spawnTimer > 50 - min(30, frameCount/200)) {
    obs.add(new Obstacle(difficulty));
    spawnTimer = 0;
  }

  // 道具生成
  powerTimer++;
  if (powerTimer > 300) {
    pws.add(new PowerUp());
    powerTimer = 0;
  }

  // 更新障礙物
  for (int i = obs.size()-1; i >= 0; i--) {
    Obstacle o = obs.get(i);
    o.update();
    o.show();

    if (o.hitPlayer()) {
      if (!shield) HP--;
      else shield = false;

      if (HP <= 0) gameOver = true;

      obs.remove(i);
      continue;
    }

    if (o.offScreen()) obs.remove(i);
  }

  // 道具更新
  for (int i = pws.size()-1; i >= 0; i--) {
    PowerUp p = pws.get(i);
    p.update();
    p.show();

    if (p.hitPlayer()) {
      if (p.type == 0 && HP < 10) HP++;      
      if (p.type == 1) slowDown();           
      if (p.type == 2) activateShield();      

      pws.remove(i);
      continue;
    }

    if (p.offScreen()) pws.remove(i);
  }

  // UI
  fill(255);
  textSize(20);
  text("Score: " + frameCount/60, 10, 25);
  text("HP: " + HP, 10, 50);
  text("Time: " + gameTime + "s", 10, 75);  
}

// 功能函式
void slowDown() {
  for (Obstacle o : obs) {
    o.speed *= 0.5;
  }
}

void activateShield() {
  shield = true;
  shieldTimer = 300; // 5 秒
}

void restartGame() {
  playerX = 100;
  playerY = 200;
  HP = 10;
  shield = false;

  obs.clear();
  pws.clear();

  gameTime = 0;
  frameCount = 0;
  gameOver = false;
}

// UI 畫面
void startScreen() {
  fill(255);
  textSize(40);
  text("game start", width/2 - 120, height/2 - 50);

  textSize(20);
  text("Press enter to start", width/2 - 70, height/2 + 20);
}

void gameOverScreen() {
  fill(255, 0, 0);
  textSize(40);
  text("GAME OVER", width/2 - 120, height/2 - 20);

  fill(255);
  textSize(20);
  text("Time survived: " + gameTime + "s", width/2 - 70, height/2 + 10);
  text("Press R to replay", width/2 - 40, height/2 + 40);
}

// 控制
void keyPressed() {
  if (keyCode == ENTER) gameStart = true;
  if (key == 'r' || key == 'R') restartGame();

  if (keyCode == UP)    upKey = true;
  if (keyCode == DOWN)  downKey = true;
  if (keyCode == LEFT)  leftKey = true;
  if (keyCode == RIGHT) rightKey = true;
}

void keyReleased() {
  if (keyCode == UP)    upKey = false;
  if (keyCode == DOWN)  downKey = false;
  if (keyCode == LEFT)  leftKey = false;
  if (keyCode == RIGHT) rightKey = false;
}
