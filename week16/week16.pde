import processing.sound.*; 

// --- 基礎變數 ---
float playerX = 100, playerY = 200, playerSize = 40; 
int HP = 10; 
int maxHP = 10; 
boolean shield = false;
int shieldTimer = 0;
int slowTimer = 0; 

SoundFile bgm;
SoundFile ultimateHit;
boolean bgmPaused = false; 

int bgChangeTimer = 0;
int bgIndex = 0;
color currentBG = color(0, 0, 0); 
color[] bgColors = {
  color(60, 20, 100),   
  color(20, 60, 120),   
  color(100, 20, 20),   
  color(20, 80, 60)     
};

ArrayList<PLine> bgLines = new ArrayList<PLine>();
int bgLineSpawnRate = 5; 

boolean isDashing = false;
int dashTimer = 0, dashCooldown = 0;
int dashDuration = 12; 
int dashCDTime = 180;  
float dashMultiplier = 6.0;
float dashVX = 0, dashVY = 0;

int bulletLevel = 1; 
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<BossBullet> bossBullets = new ArrayList<BossBullet>();
Boss currentBoss = null;
boolean gameStart = false, gameOver = false, gameWin = false; 
int gameTime = 0;
boolean isBossPhase = false;
boolean boss1Done = false, boss2Done = false;

int shakeTime = 0; 
float shakeStrength = 0;
PImage playerImg, pwHeartImg, pwSlowImg, pwShieldImg;
PImage obsSquareImg, obsCircleImg, obsTriangleImg, obsRotateImg;
PImage boss1Img, boss2Img; 

ArrayList<Obstacle> obs = new ArrayList<Obstacle>();
ArrayList<PowerUp> pws = new ArrayList<PowerUp>();
ArrayList<AfterImage> afterImages = new ArrayList<AfterImage>();

int spawnTimer = 0, powerTimer = 0;
float baseSpeed = 6; 
float currentSpeed = 6; 
boolean wKey, aKey, sKey, dKey;

class PLine {
  float x, y, len, speed;
  color c;
  PLine() {
    x = width + random(50, 200);
    y = random(height);
    len = random(40, 120);
    speed = random(8, 20);
    c = random(1) > 0.5 ? color(0, 255, 255, 200) : color(255, 0, 255, 200);
  }
  void update() {
    float moveSpeed = speed;
    if (isDashing) moveSpeed *= 3;
    else if (slowTimer > 0) moveSpeed *= 0.3;
    x -= moveSpeed;
  }
  void show() { stroke(c); strokeWeight(2); line(x, y, x + len, y); }
}

class Bullet {
  float x, y, w, h, bSpeed, vy;
  int level;
  Bullet(float x, float y, int lvl, float vy) {
    this.x = x; this.y = y; this.level = lvl; this.vy = vy;
    this.bSpeed = 12;
    if (lvl == 4) { this.w = 60; this.h = 60; } 
    else { this.w = 15; this.h = 6; }
  }
  void update() { x += bSpeed; y += vy; }
  void show() {
    if (level == 4) { fill(255, 200, 0); stroke(255); strokeWeight(3); ellipse(x, y, w, h); } 
    else { fill(255, 255, 0); noStroke(); rect(x, y, w, h, 2); }
  }
  boolean offScreen() { return x > width || y < 0 || y > height; }
}

class BossBullet {
  float x, y, size = 18, bSpeed, vy;
  BossBullet(float x, float y, float bSpeed, float vy) { this.x = x; this.y = y; this.bSpeed = bSpeed; this.vy = vy; }
  void update() { x -= bSpeed; y += vy; }
  void show() { fill(255, 50, 0); stroke(255); strokeWeight(2); ellipse(x, y, size, size); noStroke(); }
  boolean hitPlayer() { return dist(x, y, playerX + playerSize/2, playerY + playerSize/2) < playerSize/2 + size/2; }
  boolean offScreen() { return x < -50 || y < -50 || y > height + 50; }
}

class Boss {
  float x, y, w, h;
  int hp, maxHp, type, shootTimer = 0;
  float moveAngle = 0;
  Boss(int type) {
    this.type = type; this.x = width - 250; this.y = height / 2;
    // 修改：Boss 體積再縮小一點點點
    if (type == 1) { hp = 30; w = 150; h = 150; } 
    else { hp = 60; w = 210; h = 210; }
    maxHp = hp;
  }
  void update() {
    moveAngle += 0.05; y = (height/2 - h/2) + sin(moveAngle) * 80;
    shootTimer++;
    int rate = (type == 1) ? 50 : 35; 
    if (shootTimer > rate) {
      if (type == 1) {
        bossBullets.add(new BossBullet(x, y + h/2, 8, -1.0));
        bossBullets.add(new BossBullet(x, y + h/2, 8, 1.0));
      } else {
        for (int i = -1; i <= 1; i++) { bossBullets.add(new BossBullet(x, y + h/2, 9, i * 2.0)); }
      }
      shootTimer = 0;
    }
  }
  void show() {
    imageMode(CORNER);
    if (type == 1) image(boss1Img, x, y, w, h);
    else image(boss2Img, x, y, w, h);
    noStroke(); fill(50); rect(x, y - 25, w, 15);
    fill(255, 0, 0); rect(x, y - 25, map(hp, 0, maxHp, 0, w), 15);
  }
}

class Obstacle {
  float x, y, w, h, speed, angle = 0;
  int shapeType;
  Obstacle(float diff) {
    w = random(60, 110) * 0.7; h = random(60, 110) * 0.7;
    x = width + w; y = random(0, height - h);
    speed = random(4 + diff, 7 + diff); shapeType = (int)random(0, 4);
  }
  void update() { x -= (slowTimer > 0) ? speed * 0.4 : speed; angle += 0.05; }
  void show() {
    if (shapeType == 0) image(obsSquareImg, x, y, w, h);
    else if (shapeType == 1) image(obsCircleImg, x, y, w, h);
    else if (shapeType == 2) image(obsTriangleImg, x, y, w, h);
    else { pushMatrix(); translate(x + w/2, y + h/2); rotate(angle); imageMode(CENTER); image(obsRotateImg, 0, 0, w, h); imageMode(CORNER); popMatrix(); }
  }
  boolean hitPlayer() { return playerX < x + w - 6 && playerX + playerSize > x + 6 && playerY < y + h - 6 && playerY + playerSize > y + 6; }
}

class PowerUp {
  float x, y, size = 80;
  int type; 
  PowerUp() {
    x = width + size; y = random(50, height - 50);
    type = isBossPhase ? 3 : (int)random(0, 3);
  }
  void update() { x -= 4; }
  void show() {
    if (type == 0) image(pwHeartImg, x, y, size, size);
    else if (type == 1) image(pwSlowImg, x, y, size, size);
    else if (type == 2) image(pwShieldImg, x, y, size, size);
    else { fill(0, 255, 255); stroke(255); strokeWeight(2); rect(x, y, size, size, 10); fill(0); textAlign(CENTER, CENTER); textSize(18); text("LV UP", x+size/2, y+size/2); }
  }
  boolean hitPlayer() { return dist(playerX+playerSize/2, playerY+playerSize/2, x+size/2, y+size/2) < playerSize/2 + size/2; }
}

class AfterImage {
  float x, y; int life = 20; float alpha = 150;
  AfterImage(float x, float y) { this.x = x; this.y = y; }
  void update() { life--; alpha -= 7; }
  void show() { tint(255, alpha); image(playerImg, x, y, playerSize * 1.5, playerSize * 1.5); noTint(); }
  boolean dead() { return life <= 0 || alpha <= 0; }
}

void setup() {
  size(800, 400);
  playerImg = loadImage("1.png"); pwHeartImg = loadImage("2.png");
  pwSlowImg = loadImage("3.png"); pwShieldImg = loadImage("4.png");
  obsSquareImg = loadImage("5.png"); obsCircleImg = loadImage("6.png");
  obsTriangleImg = loadImage("7.png"); obsRotateImg = loadImage("8.png");
  boss1Img = loadImage("9.png"); boss2Img = loadImage("10.png");
  bgm = new SoundFile(this, "11.mp3");
  ultimateHit = new SoundFile(this, "12.mp3");
  bgm.loop(); 
}

void draw() {
  if (shakeTime > 0) { translate(random(-shakeStrength, shakeStrength), random(-shakeStrength, shakeStrength)); shakeTime--; }
  
  if (ultimateHit.isPlaying()) {
    if (bgm.isPlaying()) bgm.pause();
    bgmPaused = true;
  } else if (bgmPaused) {
    bgm.loop();
    bgmPaused = false;
  }

  currentBG = lerpColor(currentBG, bgColors[bgIndex], 0.08); 
  background(currentBG); 
  bgChangeTimer++;
  if (bgChangeTimer > 180) { bgIndex = (bgIndex + 1) % bgColors.length; bgChangeTimer = 0; }
  
  if (frameCount % bgLineSpawnRate == 0) bgLines.add(new PLine());
  for (int i = bgLines.size()-1; i >= 0; i--) {
    PLine pl = bgLines.get(i); pl.update(); pl.show();
    if (pl.x + pl.len < 0) bgLines.remove(i);
  }
  
  if (!gameStart) { startScreen(); return; }
  if (gameOver) { gameOverScreen(); return; }
  if (gameWin) { gameWinScreen(); return; }
  
  currentSpeed = (slowTimer > 0) ? baseSpeed * 0.6 : baseSpeed;
  if (slowTimer > 0) slowTimer--;
  
  if (gameTime == 50 && !boss1Done && currentBoss == null && !isBossPhase) { currentBoss = new Boss(1); isBossPhase = true; obs.clear(); }
  if (gameTime == 100 && !boss2Done && currentBoss == null && !isBossPhase) { currentBoss = new Boss(2); isBossPhase = true; obs.clear(); }
  
  if ((gameTime >= 46 && gameTime < 50 && !boss1Done) || (gameTime >= 96 && gameTime < 100 && !boss2Done)) {
    float a = map(sin(frameCount * 0.3), -1, 1, 0, 255);
    textAlign(CENTER); textSize(45); fill(255, 0, 0, a); text("WARNING: BOSS APPROACHING", width/2, height/2);
  }
  if (frameCount % 60 == 0 && !isBossPhase) gameTime++;
  
  for (int i = afterImages.size()-1; i >= 0; i--) {
    AfterImage ai = afterImages.get(i); ai.update(); ai.show();
    if (ai.dead()) afterImages.remove(i);
  }
  updatePlayer();
  imageMode(CORNER);
  image(playerImg, playerX, playerY, playerSize * 1.5, playerSize * 1.5);
  
  if (shield) {
    noFill(); stroke(0, 255, 255); strokeWeight(3);
    ellipse(playerX+playerSize*0.75, playerY+playerSize*0.75, 120, 120);
    shieldTimer--; if (shieldTimer <= 0) shield = false;
  }
  
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i); b.update(); b.show();
    if (currentBoss != null && b.x > currentBoss.x && b.x < currentBoss.x + currentBoss.w && b.y > currentBoss.y && b.y < currentBoss.y + currentBoss.h) {
      if (b.level == 4) { 
        currentBoss.hp = 0; 
        if (!ultimateHit.isPlaying()) ultimateHit.play(); 
      } else { currentBoss.hp--; }
      bullets.remove(i);
      if (currentBoss.hp <= 0) {
        if (currentBoss.type == 1) boss1Done = true; else { boss2Done = true; gameWin = true; }
        currentBoss = null; isBossPhase = false; bulletLevel = 1; bossBullets.clear();
      }
      continue;
    }
    if (b.offScreen()) bullets.remove(i);
  }
  
  for (int i = bossBullets.size() - 1; i >= 0; i--) {
    BossBullet bb = bossBullets.get(i); 
    if (slowTimer > 0) { bb.x -= bb.bSpeed * 0.4; bb.y += bb.vy * 0.4; } else { bb.update(); }
    bb.show();
    if (bb.hitPlayer()) {
      if (!isDashing && !shield) { HP--; shakeTime = 10; shakeStrength = 6; } else shield = false;
      bossBullets.remove(i); if (HP <= 0) gameOver = true;
    } else if (bb.offScreen()) bossBullets.remove(i);
  }
  
  if (currentBoss != null) {
    currentBoss.update(); currentBoss.show();
    if (playerX < currentBoss.x + currentBoss.w && playerX + playerSize > currentBoss.x && playerY < currentBoss.y + currentBoss.h && playerY + playerSize > currentBoss.y) {
       if (!isDashing && !shield) { HP--; shakeTime = 20; shakeStrength = 10; playerX -= 60; } else shield = false;
       if (HP <= 0) gameOver = true;
    }
  }
  
  if (!isBossPhase) {
    spawnTimer++; if (spawnTimer > 25) { obs.add(new Obstacle(frameCount/1200.0)); spawnTimer = 0; }
  }
  for (int i = obs.size()-1; i >= 0; i--) {
    Obstacle o = obs.get(i); o.update(); o.show();
    if (o.hitPlayer()) {
      if (!shield && !isDashing) { HP--; shakeTime = 15; shakeStrength = 8; } else shield = false;
      obs.remove(i); if (HP <= 0) gameOver = true;
    } else if (o.x < -150) obs.remove(i);
  }
  
  powerTimer++; if (powerTimer > 350) { pws.add(new PowerUp()); powerTimer = 0; }
  for (int i = pws.size()-1; i >= 0; i--) {
    PowerUp p = pws.get(i); p.update(); p.show();
    if (p.hitPlayer()) {
      if (p.type == 0) { maxHP = min(maxHP + 1, 20); HP = min(HP + 3, maxHP); }
      else if (p.type == 1) slowTimer = 300; 
      else if (p.type == 2) { shield = true; shieldTimer = 400; }
      else if (p.type == 3) bulletLevel = min(bulletLevel + 1, 4);
      pws.remove(i);
    } else if (p.x < -100) pws.remove(i);
  }
  drawUI();
}

void updatePlayer() {
  float vx = 0, vy = 0;
  if (wKey) vy = -currentSpeed; if (sKey) vy = currentSpeed;
  if (aKey) vx = -currentSpeed; if (dKey) vx = currentSpeed;
  if (isDashing) {
    playerX += dashVX; playerY += dashVY;
    afterImages.add(new AfterImage(playerX, playerY));
    dashTimer--; if (dashTimer <= 0) isDashing = false;
  } else { playerX += vx; playerY += vy; }
  if (dashCooldown > 0) dashCooldown--;
  playerX = constrain(playerX, 0, width - playerSize);
  playerY = constrain(playerY, 0, height - playerSize);
}

void fireBullet() {
  if (bulletLevel == 1) bullets.add(new Bullet(playerX + playerSize, playerY + playerSize/2, 1, 0));
  else if (bulletLevel == 2) { bullets.add(new Bullet(playerX + playerSize, playerY + playerSize/3, 2, 0)); bullets.add(new Bullet(playerX + playerSize, playerY + playerSize*0.66, 2, 0)); }
  else if (bulletLevel == 3) { bullets.add(new Bullet(playerX + playerSize, playerY + playerSize/2, 3, 0)); bullets.add(new Bullet(playerX + playerSize, playerY + playerSize/2, 3, -2)); bullets.add(new Bullet(playerX + playerSize, playerY + playerSize/2, 3, 2)); }
  else if (bulletLevel == 4) { 
    bullets.add(new Bullet(playerX + playerSize, playerY + playerSize/2, 4, 0)); 
    bulletLevel = 1; 
  }
}

void drawUI() {
  textAlign(LEFT); fill(255); textSize(18);
  text("HP: " + HP + " / " + maxHP + "  TIME: " + gameTime + "s", 10, 25);
  fill(0, 255, 255); text("BULLET LV: " + (bulletLevel == 4 ? "ULTIMATE READY!" : bulletLevel), 10, 50);
  if (slowTimer > 0) { fill(150, 150, 255); text("SLOW MOTION ACTIVE!", 10, 85); }
  fill(50); rect(10, 65, 100, 8);
  fill(0, 200, 255); rect(10, 65, map(dashCooldown, 0, dashCDTime, 100, 0), 8);
}

void startScreen() { textAlign(CENTER); fill(255); textSize(40); text("CYBER OBSTACLE AVOIDANCE SHOOTER", width/2, height/2); textSize(20); text("Press ENTER to Start", width/2, height/2+40); }
void gameOverScreen() { textAlign(CENTER); fill(255, 0, 0); textSize(40); text("GAME OVER", width/2, height/2); fill(255); textSize(20); text("Press R to Restart", width/2, height/2+40); }
void gameWinScreen() { background(0, 40, 0); textAlign(CENTER); fill(0, 255, 0); textSize(50); text("YOU WIN!", width/2, height/2); fill(255); textSize(20); text("Survival Time: " + gameTime + "s\nPress R to Play Again", width/2, height/2+60); }

void keyPressed() {
  if (keyCode == ENTER) gameStart = true;
  if (key == 'r' || key == 'R') restartGame();
  if (key == 'w' || key == 'W') wKey = true; if (key == 's' || key == 'S') sKey = true;
  if (key == 'a' || key == 'A') aKey = true; if (key == 'd' || key == 'D') dKey = true;
  if (key == ' ') fireBullet();
  if (keyCode == CONTROL && !isDashing && dashCooldown == 0) {
    isDashing = true; dashTimer = dashDuration; dashCooldown = dashCDTime;
    dashVX = (dKey?1:0) - (aKey?1:0); dashVY = (sKey?1:0) - (wKey?1:0);
    if (dashVX == 0 && dashVY == 0) dashVX = 1;
    dashVX *= baseSpeed * dashMultiplier; dashVY *= baseSpeed * dashMultiplier;
  }
}

void keyReleased() {
  if (key == 'w' || key == 'W') wKey = false; if (key == 's' || key == 'S') sKey = false;
  if (key == 'a' || key == 'A') aKey = false; if (key == 'd' || key == 'D') dKey = false;
}

void restartGame() {
  playerX = 100; playerY = 200; HP = 10; maxHP = 10; 
  gameTime = 0; bulletLevel = 1; slowTimer = 0;
  obs.clear(); pws.clear(); bullets.clear(); bossBullets.clear(); currentBoss = null;
  bgLines.clear(); bgIndex = 0; currentBG = color(0);
  gameOver = false; gameWin = false; frameCount = 0; isBossPhase = false; boss1Done = false; boss2Done = false;
}
