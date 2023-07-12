import processing.serial.*;

Serial myPort;
int[] rpmData = new int[100];
int[] pwmData = new int[100];
int currentIndex = 0;

void setup() {
  fullScreen();
  
  myPort = new Serial(this, Serial.list()[1], 9600);
}

void draw() {
  if (myPort.available() > 0) {
    String val = myPort.readStringUntil('\n');
    if (val != null) {
      processData(val);
    }
  }
  
  background(255);
  drawGraph();
}

void processData(String data) {
  data = data.trim();
  println(data);
  if (data.startsWith("RPM: ") && data.indexOf(" | PWM: ") != -1) {
    int rpmIndex = data.indexOf("RPM: ") + 5;
    int rpmEndIndex = data.indexOf(" |");
    int pwmIndex = data.indexOf("PWM: ") + 5;
  
    int rpm = int(data.substring(rpmIndex, rpmEndIndex));
    int pwm = int(data.substring(pwmIndex));
  
    rpmData[currentIndex] = rpm;
    pwmData[currentIndex] = pwm;
    currentIndex++;
  
    if (currentIndex >= rpmData.length) {
      for (int i = 1; i < currentIndex; i++) {
        rpmData[i - 1] = rpmData[i];
        pwmData[i - 1] = pwmData[i];
      }
      currentIndex--;
    }
  }
}

void drawGraph() {
  int maxRPM = max(rpmData);
  int maxPWM = max(pwmData);
  
  stroke(0);
  line(50, height - 50, width - 50, height - 50);
  
  line(50, height - 50, 50, 50);
  
  stroke(0, 0, 255);
  fill(0, 0, 255);
  
  for (int i = 0; i < currentIndex; i++) {
    float x = map(i, 0, currentIndex - 1, 50, width - 50);
    float y1 = map(rpmData[i], 0, maxRPM, height - 50, 50);
    
    ellipse(x, y1, 5, 5);
    
    if (i > 0) {
      float prevX = map(i - 1, 0, currentIndex - 1, 50, width - 50);
      float prevY1 = map(rpmData[i - 1], 0, maxRPM, height - 50, 50);
      line(prevX, prevY1, x, y1);
    }
  }
  
  stroke(255, 0, 0);
  fill(255, 0, 0);
  
  for (int i = 0; i < currentIndex; i++) {
    float x = map(i, 0, currentIndex - 1, 50, width - 50);
    float y2 = map(pwmData[i], 0, maxPWM, height - 50, 50);
    
    ellipse(x, y2, 5, 5);
    
    if (i > 0) {
      float prevX = map(i - 1, 0, currentIndex - 1, 50, width - 50);
      float prevY2 = map(pwmData[i - 1], 0, maxPWM, height - 50, 50);
      line(prevX, prevY2, x, y2);
    }
  }
  
  noFill();
  stroke(0, 0, 255);
  beginShape();
  
  for (int i = 0; i < currentIndex; i++) {
    float x = map(i, 0, currentIndex - 1, 50, width - 50);
    float y = map(rpmData[i], 0, maxRPM, height - 50, 50);
    curveVertex(x, y);
  }
  
  endShape();
  
  noFill();
  stroke(255, 0, 0);
  beginShape();
  
  for (int i = 0; i < currentIndex; i++) {
    float x = map(i, 0, currentIndex - 1, 50, width - 50);
    float y = map(pwmData[i], 0, maxPWM, height - 50, 50);
    curveVertex(x, y);
  }
  
  endShape();
  
  fill(0);
  textAlign(RIGHT, CENTER);
  
  for (int i = 0; i <= 20; i++) {
    float value = round(map(i, 0, 20, 0, maxRPM));
    float y = map(value, 0, maxRPM, height - 50, 50);
    text(nf(value, 0, 0), 45, y);
  }
  
  textAlign(LEFT, CENTER);
  
  for (int i = 0; i <= 20; i++) {
    float value = round(map(i, 0, 20, 0, maxPWM));
    float y = map(value, 0, maxPWM, height - 50, 50);
    text(nf(value, 0, 0), width - 45, y);
  }
  
  fill(0);
  textAlign(CENTER);
  
  int numLabels = 10;
  for (int i = 0; i <= numLabels; i++) {
    float x = map(i, 0, numLabels, 50, width - 50);
    int time = round(map(i, 0, numLabels, 0, currentIndex - 1));
    text(time, x, height - 25);
  }
  
  textAlign(RIGHT);
  text("RPM", 40, height / 2);
  
  textAlign(LEFT);
  text("PWM", width - 40, height / 2);
}
