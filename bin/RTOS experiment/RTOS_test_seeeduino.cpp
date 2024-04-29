#define START 0xAA  
#define END   0xFF  
#define READ  0x11
#define WRITE 0x22

#define LED_DEBUG A7

#define DAC_PIN A0

#define TH_COUNT 4

unsigned char mode = 0;
bool in_process = false;

void setup() {
  Serial.begin(9600);
  in_process = false;

  pinMode(LED_DEBUG, OUTPUT);
}

void loop() {
  if (in_process) { //in_process
    switch (mode) {
      case READ:
        readFunc();
        break;
      case WRITE:
        writeFunc();
        break;
    }
    if (Serial.available()) {
      in_process = !isEnd(serialRead());
    }
  } else { //not in process
    if (Serial.available()) {
      in_process = isStart(serialRead());
    }
  }
}

void readFunc() {
  float voltage = analogRead(A1) * 3.3 / 4096.0;
  Serial.println(voltage);
}

void writeFunc() {
  static float x = 0;
  static const float increment = 0.02;
  int dacVoltage = (int)(511.5 + 511.5 * sin(x));
  x += increment;

  analogWrite(DAC_PIN, dacVoltage);
  delay(1); // This delay ensures a manageable update rate for DAC
}

bool isStart(unsigned char byte) {
  static unsigned char count = 0;
  if (byte == START) {
    count++;

    if (count >= TH_COUNT) {
      mode = serialRead();
      debugVar(mode);
      if (mode == READ || mode == WRITE) {
        count = 0; // Reset count for next sequence detection
        return true;
      }
    }
  } else {
    count = 0;
  }
  return false;
}

bool isEnd(unsigned char byte) {
  static unsigned char count = 0;
  if (byte == END) {
    count++;
    if (count >= TH_COUNT) {
      count = 0; // Reset count for next sequence detection
      return true;
    }
  } else {
    count = 0;
  }
  return false;
}

char serialRead(){
  delay(1);
  char byte=Serial.read();
  delay(1);
  return byte;
}


void debug(int num){
  if(num==0){
    digitalWrite(LED_DEBUG, !digitalRead(LED_DEBUG));
  }
  else{
    for(int i=0; i<num; i++){
      digitalWrite(LED_DEBUG, true);
      delay(200);
      digitalWrite(LED_DEBUG, false);
      delay(150);
    }
  }
}

void debugVar(char byte) {
    for (int i = 7; i >= 0; i--) { // Iterate over each bit from MSB to LSB
        bool bitVal = byte & (1 << i); // Check if the i-th bit is set
        if (bitVal) {
            digitalWrite(LED_DEBUG, HIGH); // If the bit is set, turn LED on
        } else {
            digitalWrite(LED_DEBUG, LOW); // If the bit is not set, turn LED off
        }
        delay(500); // Wait for 200ms before checking the next bit
    }
    digitalWrite(LED_DEBUG, LOW);
}
