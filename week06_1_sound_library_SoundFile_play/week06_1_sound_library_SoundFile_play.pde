//week06_1_sound_library_SoundFile_play
//Sketch-library-ManageLibraries,找Sound安裝他
//File-Examples-Libraries-Sound-soundfile-SimplePlayback
import processing.sound.*;//聲音外掛模組
SoundFile sound;//宣告SoundFile物件變數
void setup(){
  size(500,400);//視窗大小
 sound = new SoundFile(this, "music.mp3");//將音樂檔設定好
 sound.play();
}
void draw(){
  
}
