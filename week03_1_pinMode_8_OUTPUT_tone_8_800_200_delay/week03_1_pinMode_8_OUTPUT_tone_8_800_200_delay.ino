//week03_1_pinMode_8_OUTPUT_tone_8_800_200_delay
void setup() {
  // put your setup code here, to run once:
  pinMode(8,OUTPUT);//負責發聲
  tone(8, 800, 200);
  delay(1000);
  tone(8,800,200);
  delay(1000);
  tone(8,800,200);
  delay(1000);
}

void loop() {
  // put your main code here, to run repeatedly:

}
