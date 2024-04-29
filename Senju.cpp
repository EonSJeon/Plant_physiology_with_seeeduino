#include <CircularBuffer.h>
//////////////////////////////////////////////////
// CONST DEF
// PIN DEF
// Function PINs
#define PLAYBACK_PIN A0
#define RECORD_PIN A1
// State PINs
#define IDLE_LED A9
#define UPLOAD_LED A8
#define MONITOR_LED A7
// Debug PIN
#define DEBUG_LED A10

// STATE DEF
#define St_IDLE 0
#define St_UPL 1
#define St_MON 2

// SIGNAL DEF
#define SIG_UPLOAD 0x554C // UL
#define SIG_MONITOR 0x4D4E  // MN
#define SIG_IMPULSE 0x4950  // IP
#define SIG_FLUSH 0x464C    // FL
#define SIG_IDLE 0x4944 // ID

// MAX
#define MAX_OUT_V_NUM_OF_BIN 1023
#define MAX_IN_V_NUM_OF_BIN  4095
#define MAX_mV 3300

// BUFFER
#define PLAYBACK_BUF_SIZE 10000 // MAX = 20 sec 
#define IMP_BUF_SIZE 500

// IMPULSE
#define IMPULSE_LEN 10
#define INIT_TIME_LEN 100

// ETC
#define STD_INTERVAL_MS 2 // Fs=500 Hz
//////////////////////////////////////////////////
// Buffer
// Needed for play back and impulse response
CircularBuffer<uint16_t, PLAYBACK_BUF_SIZE> playback_vBuf;

CircularBuffer<unsigned long, IMP_BUF_SIZE> impulse_tBuf;
CircularBuffer<float, IMP_BUF_SIZE> impulse_In_vBuf;
CircularBuffer<float, IMP_BUF_SIZE> impulse_Out_vBuf;
//////////////////////////////////////////////////
// GLOBAL VARS
int state =0;
int ledState=LOW;
uint16_t tSt_ms=0;

bool uploaded = false;
//////////////////////////////////////////////////
void setup() {
    // LED SET UP
    pinMode(DEBUG_LED, OUTPUT);
    pinMode(IDLE_LED, OUTPUT);
    pinMode(UPLOAD_LED, OUTPUT);
    pinMode(MONITOR_LED, OUTPUT);
    analogWriteResolution(10);
    analogReadResolution(12);
  
    playback_vBuf.clear();
    impulse_tBuf.clear();
    impulse_In_vBuf.clear();
    impulse_Out_vBuf.clear();

    uploaded = false;

    state = St_IDLE;
    digitalWrite(IDLE_LED, HIGH);

    Serial.begin(9600);
}

void loop() {
    // Declare variables outside the switch to avoid cross-initialization errors
    unsigned long ct_ms = 0;
    uint16_t vout = 0;
    float vin_mV = 0;
    float vout_mV = 0; 

    // Matlab -> Seeeduino
    if (Serial.available() >= 2) {
        uint16_t arg = Serial.read() | (Serial.read() << 8);
        if(arg > MAX_OUT_V_NUM_OF_BIN){
            interpretInstruction(arg);
        } else if (state == St_UPL) {
            upload_blink();
            playback_vBuf.push(arg);
        }
    }

   // Seeeduino -> Matlab
   if(state ==St_MON){
      vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;
      ct_ms = millis();
      int scaledTime = int((ct_ms- tSt_ms)/STD_INTERVAL_MS);
      int idx = scaledTime % PLAYBACK_BUF_SIZE;
      vout = playback_vBuf[idx];
      analogWrite(PLAYBACK_PIN, vout);
      vout_mV = vout * MAX_mV / MAX_OUT_V_NUM_OF_BIN;
      send2Matlab(ct_ms, vin_mV, vout_mV);
   }

   delay(5);
}


void send2Matlab(unsigned long t_ms, float vin_mV, float vout_mV){
    Serial.print(t_ms);
    Serial.print(",");
    Serial.print(vin_mV);
    Serial.print(",");
    Serial.print(vout_mV);
    Serial.print(";");
}

void interpretInstruction(uint16_t instruction) {
  switch(instruction){
    case SIG_IDLE:
      digitalWrite(IDLE_LED, HIGH);
      digitalWrite(MONITOR_LED, LOW);
      state = St_IDLE;

      if (uploaded){
        digitalWrite(UPLOAD_LED, HIGH);
      }else{
        digitalWrite(UPLOAD_LED, LOW);
      }
      break;
    case SIG_UPLOAD:
      digitalWrite(IDLE_LED, LOW);
      state = St_UPL;
      uploaded = true;
      tSt_ms = millis();
      break;
    case SIG_MONITOR:
      digitalWrite(MONITOR_LED, HIGH);
      digitalWrite(IDLE_LED, LOW);
      state = St_MON;
      break;
    case SIG_IMPULSE:
      digitalWrite(IDLE_LED, LOW);
      impulse();
      digitalWrite(IDLE_LED, HIGH);
      break;
    case SIG_FLUSH:
      digitalWrite(IDLE_LED, LOW);

      playback_vBuf.clear(); 
      uploaded = false;
      digitalWrite(UPLOAD_LED, LOW);
      
      digitalWrite(IDLE_LED, HIGH);
      break;
  }
}

void impulse(){ // 50 ms impulse
  unsigned long t_ms = 0;
  float vin_mV = 0;

  impulse_tBuf.clear();
  impulse_In_vBuf.clear();
  impulse_Out_vBuf.clear();

  for (int i = 0; i < INIT_TIME_LEN; i++) {
        t_ms = millis();
        analogWrite(PLAYBACK_PIN, 0);
        vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;

        impulse_tBuf.push(t_ms);
        impulse_Out_vBuf.push(0);
        impulse_In_vBuf.push(vin_mV);

        delay(STD_INTERVAL_MS);
  }

  for (int i = 0; i < IMPULSE_LEN; i++) {
      t_ms = millis();
      analogWrite(PLAYBACK_PIN, MAX_OUT_V_NUM_OF_BIN);
      vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;

      impulse_tBuf.push(t_ms);
      impulse_Out_vBuf.push(MAX_mV);
      impulse_In_vBuf.push(vin_mV);

      delay(STD_INTERVAL_MS);
  }

  for (int i = 0; i < (IMP_BUF_SIZE-IMPULSE_LEN-INIT_TIME_LEN); i++) {
      t_ms = millis();
      analogWrite(PLAYBACK_PIN, 0);
      vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;

      impulse_tBuf.push(t_ms);
      impulse_Out_vBuf.push(0);
      impulse_In_vBuf.push(vin_mV);

      delay(STD_INTERVAL_MS);
  }
  for (int i = 0; i < PLAYBACK_BUF_SIZE; i++) {
      send2Matlab(impulse_tBuf[i], impulse_In_vBuf[i], impulse_Out_vBuf[i]);
  }
  impulse_tBuf.clear();
  impulse_In_vBuf.clear();
  impulse_Out_vBuf.clear();
}


void upload_blink(){
  static uint8_t count = 0;
  count++;
  if(count == 10){
    bool ledState = digitalRead(UPLOAD_LED);  
    digitalWrite(UPLOAD_LED, !ledState);
    count = 0; 
  }
}

void debug(){
  bool ledState = digitalRead(DEBUG_LED);  
  digitalWrite(DEBUG_LED, !ledState); 
}