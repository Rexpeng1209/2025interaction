float playerX = 100;
float playerY = 200;
float playerSize = 50;
int HP = 8;

boolean shield = false;
int shieldTimer = 0;

// Dash 系統
boolean isDashing = false;
int dashTimer = 0;
int dashCooldown = 0;
float dashMultiplier = 6.0; // 衝刺更快
int dashDuration = 12;       // 衝刺持續時間
int dashCDTime = 180;
float dashVX = 0;
float dashVY = 0;

// 畫面震動
int shakeTime = 0;
float shakeStrength = 0;

// 圖片
PImage playerImg;
PImage pwHeartImg, pwSlowImg, pwShieldImg;
PImage obsSquareImg, obsCircleImg, obsTriangleImg, obsRotateImg;

// 計時
int gameTime = 0;

// 控制
boolean wKey, aKey, sKey, dKey;
boolean gameStart = false;
boolean gameOver = false;

// 清單
ArrayList<Obstacle> obs = new ArrayList<Obstacle>();
ArrayList<PowerUp> pws = new ArrayList<PowerUp>();
ArrayList<AfterImage> afterImages = new ArrayList<AfterImage>();

int spawnTimer = 0;
int powerTimer = 0;

// 玩家速度
float speed = 6;

// 殘影
class AfterImage {
  float x, y;
  int life = 20;
  float alpha = 150;

  AfterImage(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void update() {
    life--;
    alpha -= 7;
  }

  void show() {
    tint(255, alpha);
    image(playerImg, x, y, playerSize * 2.5, playerSize * 2.5);
    noTint();
  }

  boolean dead() {
    return life <= 0 || alpha <= 0;
  }
}

// 道具
class PowerUp {
  float x, y, size = 40;
  int type; // 0回血 1慢速 2護盾
  float speed = 4;

  PowerUp() {
    x = width + size;
    y = random(50, height - 50);
    type = int(random(0, 3));
  }

  void update() { x -= speed; }

  void show() {
    if (type == 0) image(pwHeartImg, x, y, size * 2, size * 2);
    if (type == 1) image(pwSlowImg, x, y, size * 2, size * 2);
    if (type == 2) image(pwShieldImg, x, y, size * 2, size * 2);
  }

  boolean hitPlayer() {
    return dist(playerX + playerSize/2, playerY + playerSize/2, x + size/2, y + size/2) < playerSize;
  }

  boolean offScreen() { return x < -size; }
}

// 障礙物
class Obstacle {
  float x, y, w, h, speed;
  int shapeType;
  float angle = 0;

  Obstacle(float diff) {
    w = random(40, 80);
    h = random(40, 120);
    x = width + w;
    y = random(0, height - h);
    speed = random(3 + diff, 6 + diff);
    shapeType = int(random(0, 4));
  }

  void update() {
    x -= speed;
    angle += 0.05;
  }

  void show() {
    if (shapeType == 0) image(obsSquareImg, x, y, w, h);
    if (shapeType == 1) image(obsCircleImg, x, y, w, h);
    if (shapeType == 2) image(obsTriangleImg, x, y, w, h);
    if (shapeType == 3) {
      pushMatrix();
      translate(x + w/2, y + h/2);
      rotate(angle);
      imageMode(CENTER);
      image(obsRotateImg, 0, 0, w, h);
      imageMode(CORNER);
      popMatrix();
    }
  }

  boolean hitPlayer() {
    return playerX < x + w &&
           playerX + playerSize > x &&
           playerY < y + h &&
           playerY + playerSize > y;
  }

  boolean offScreen() { return x + w < 0; }
}

void setup() {
  size(800, 400);

  playerImg = loadImage("1.jpg");
  pwHeartImg = loadImage("2.jpg");
  pwSlowImg = loadImage("3.jpg");
  pwShieldImg = loadImage("4.jpg");

  obsSquareImg = loadImage("5.jpg");
  obsCircleImg = loadImage("6.jpg");
  obsTriangleImg = loadImage("7.jpg");
  obsRotateImg = loadImage("8.jpg");
}

void draw() {

  if (shakeTime > 0) {
    translate(random(-shakeStrength, shakeStrength),
              random(-shakeStrength, shakeStrength));
    shakeTime--;
  }

  background(0); // 黑色背景

  if (!gameStart) { startScreen(); return; }
  if (gameOver) { gameOverScreen(); return; }

  float diff = frameCount / 600.0;

  // 玩家移動
  float vx = 0, vy = 0;
  if (wKey) vy = -speed;
  if (sKey) vy = speed;
  if (aKey) vx = -speed;
  if (dKey) vx = speed;

  // Dash
  if (isDashing) {
    playerX += dashVX;
    playerY += dashVY;
    afterImages.add(new AfterImage(playerX, playerY));
    dashTimer--;
    if (dashTimer <= 0) isDashing = false;
  } else {
    playerX += vx;
    playerY += vy;
  }

  if (dashCooldown > 0) dashCooldown--;

  playerX = constrain(playerX, 0, width - playerSize);
  playerY = constrain(playerY, 0, height - playerSize);

  if (frameCount % 60 == 0) gameTime++;

  // 殘影
  for (int i = afterImages.size() - 1; i >= 0; i--) {
    AfterImage a = afterImages.get(i);
    a.update();
    a.show();
    if (a.dead()) afterImages.remove(i);
  }

  image(playerImg, playerX, playerY, playerSize * 1.5, playerSize * 1.5);

  // 護盾
  if (shield) {
    noFill();
    stroke(255, 230, 0);
    ellipse(playerX + playerSize * 0.75,
            playerY + playerSize * 0.75,
            70 * 1.5,
            70 * 1.5);
    noStroke();
    shieldTimer--;
    if (shieldTimer <= 0) shield = false;
  }

  // 生成障礙
  spawnTimer++;
  if (spawnTimer > 50 - min(30, frameCount / 200)) {
    obs.add(new Obstacle(diff));
    spawnTimer = 0;
  }

  // 生成道具
  powerTimer++;
  if (powerTimer > 300) {
    pws.add(new PowerUp());
    powerTimer = 0;
  }

  // 更新道具
  for (int i = pws.size() - 1; i >= 0; i--) {
    PowerUp p = pws.get(i);
    p.update();
    p.show();

    if (p.hitPlayer()) {
      if (p.type == 0) HP = min(HP + 2, 10);
      if (p.type == 1) for (Obstacle o : obs) o.speed *= 0.5;
      if (p.type == 2) { shield = true; shieldTimer = 300; }
      pws.remove(i);
    } else if (p.offScreen()) {
      pws.remove(i);
    }
  }

  // 更新障礙
  for (int i = obs.size() - 1; i >= 0; i--) {
    Obstacle o = obs.get(i);
    o.update();
    o.show();

    if (o.hitPlayer()) {
      if (!shield && !isDashing) {
        HP--;
        shakeTime = 10;
        shakeStrength = 6;
      } else shield = false;

      if (HP <= 0) gameOver = true;
      obs.remove(i);
    }

    if (o.offScreen()) obs.remove(i);
  }

  // UI
  fill(255);
  textSize(20);
  text("HP: " + HP, 10, 25);
  text("Time: " + gameTime + "s", 10, 50);

  // Dash 冷卻條
  fill(50); // 背景條
  rect(10, 80, 100, 10);
  fill(0, 200, 255); // 冷卻進度
  float dashProgress = map(dashCooldown, 0, dashCDTime, 100, 0); // 倒數
  rect(10, 80, dashProgress, 10);
  stroke(255);
  noFill();
  rect(10, 80, 100, 10); // 外框
  noStroke();
  textSize(12);
  fill(255);
  text("Dash CD", 115, 90);
}

void startScreen() {
  fill(255);
  textSize(40);
  text("GAME START", width / 2 - 130, height / 2 - 20);
  textSize(20);
  text("Press ENTER", width / 2 - 60, height / 2 + 20);
}

void gameOverScreen() {
  fill(255, 0, 0);
  textSize(40);
  text("GAME OVER", width / 2 - 120, height / 2);
  fill(255);
  textSize(20);
  text("Press R to Restart", width / 2 - 80, height / 2 + 40);
}

void keyPressed() {
  if (keyCode == ENTER) gameStart = true;
  if (key == 'r' || key == 'R') restartGame();

  // 普通移動 WASD
  if (key == 'w' || key == 'W') wKey = true;
  if (key == 's' || key == 'S') sKey = true;
  if (key == 'a' || key == 'A') aKey = true;
  if (key == 'd' || key == 'D') dKey = true;

  // Dash Ctrl
  if ((keyCode == CONTROL) && !isDashing && dashCooldown == 0) {
    isDashing = true;
    dashTimer = dashDuration;
    dashCooldown = dashCDTime;
    shakeTime = 5;
    shakeStrength = 4;

    dashVX = 0; dashVY = 0;
    if (wKey) dashVY = -speed;
    if (sKey) dashVY = speed;
    if (aKey) dashVX = -speed;
    if (dKey) dashVX = speed;
    if (dashVX == 0 && dashVY == 0) dashVX = speed; // 沒按方向，向右
    dashVX *= dashMultiplier;
    dashVY *= dashMultiplier;
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') wKey = false;
  if (key == 's' || key == 'S') sKey = false;
  if (key == 'a' || key == 'A') aKey = false;
  if (key == 'd' || key == 'D') dKey = false;
}

void restartGame() {
  playerX = 100;
  playerY = 200;
  HP = 10;
  shield = false;
  obs.clear();
  pws.clear();
  afterImages.clear();
  gameTime = 0;
  frameCount = 0;
  gameOver = false;
}
