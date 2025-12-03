float playerX = 100;
float playerY = 200;
float playerSize = 40;

class Obstacle {
  float x, y, w, h, speed;

  Obstacle() {
    w = random(20, 50);
    h = random(40, 120);
    x = width + w;
    y = random(0, height - h);
    speed = random(3, 7);
  }

  void update() {
    x -= speed;
  }

  void show() {
    fill(200, 50, 50);
    rect(x, y, w, h);
  }

  boolean offScreen() {
    return x + w < 0;
  }

  boolean hitPlayer() {
    return (playerX < x + w &&
            playerX + playerSize > x &&
            playerY < y + h &&
            playerY + playerSize > y);
  }
}

ArrayList<Obstacle> obs = new ArrayList<Obstacle>();
int spawnTimer = 0;

boolean upKey, downKey, leftKey, rightKey;

void setup() {
  size(800, 400);
}

void draw() {
  background(30);

  // 玩家移動
  if (upKey)    playerY -= 5;
  if (downKey)  playerY += 5;
  if (leftKey)  playerX -= 5;
  if (rightKey) playerX += 5;

  // 限制邊界
  playerX = constrain(playerX, 0, width - playerSize);
  playerY = constrain(playerY, 0, height - playerSize);

  // 玩家顯示
  fill(50, 200, 90);
  rect(playerX, playerY, playerSize, playerSize);

  // 生成障礙物
  spawnTimer++;
  if (spawnTimer > 60) {   // 每 1 秒生成一個障礙物
    obs.add(new Obstacle());
    spawnTimer = 0;
  }

  // 更新並顯示障礙物
  for (int i = obs.size()-1; i >= 0; i--) {
    Obstacle o = obs.get(i);
    o.update();
    o.show();

    // 撞到玩家
    if (o.hitPlayer()) {
      gameOver();
      noLoop();
    }

    // 移除離開螢幕的障礙物
    if (o.offScreen()) {
      obs.remove(i);
    }
  }

  // 顯示分數
  fill(255);
  textSize(20);
  text("Score: " + frameCount / 60, 10, 25);
}

// 遊戲結束畫面
void gameOver() {
  fill(255, 0, 0);
  textSize(40);
  text("GAME OVER", width/2 - 120, height/2);
}

// 鍵盤按下
void keyPressed() {
  if (keyCode == UP)    upKey = true;
  if (keyCode == DOWN)  downKey = true;
  if (keyCode == LEFT)  leftKey = true;
  if (keyCode == RIGHT) rightKey = true;
}

// 鍵盤放開
void keyReleased() {
  if (keyCode == UP)    upKey = false;
  if (keyCode == DOWN)  downKey = false;
  if (keyCode == LEFT)  leftKey = false;
  if (keyCode == RIGHT) rightKey = false;
}
