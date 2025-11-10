//week10_5_arduino_serial_joystrick_to_processing
//修改自week10_4_arduino_serial_monitor_joystrick_serial_println
//但是不使用 serial.println()要改用serial.write() 0-1023 vs 0-255 差了4倍
void setup() {
  Serial.begin(9600);//開啟USB傳輸
  pinMode(2, INPUT_PULLUP);//pin2按鈕 可以高(沒按) 可以低(按)
  pinMode(8, OUTPUT);//發出聲音

}

void loop() { //一秒鐘,會跑 1000HZ,太快了,要慢一點才行
  delay(30);//慢一點,避免 Processing 來不及處理眼睛看不到
   int now = analogRead(A3) / 4;//小心要除以4, 才能順利由Serial.write()送出
   Serial.write(now); //把0-255的數值送出去
   if(now>200) tone(8,784,100);
   if(now<50) tone(8,523,100);
}
