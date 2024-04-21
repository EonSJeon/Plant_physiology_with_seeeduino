#include <CircularBuffer.h>
//////////////////////////////////////////////////
// CONST DEF
// PIN DEF
#define PLAYBACK_PIN A0
#define RECORD_PIN A1
#define DEBUG_LED A7
#define IDLE_LED A8

// STATE DEF
#define St_IDLE 0
#define St_UPL 1
#define St_MON 2


// SIGNAL DEF
// Assuming numerical values for each command for demonstration purposes
#define SIG_UPLOAD_CODE 0x5550 // UP
#define SIG_MONITOR_CODE 0x4D4E // MN
#define SIG_IMPULSE_CODE 0x4950 // IP
#define SIG_FLUSH_CODE 0x464C //FL

#define SIG_START_CODE 0x5354 // ST
#define SIG_END_CODE 0x4544 // ED

// MAX
#define MAX_OUT_V_NUM_OF_BIN 1023
#define MAX_IN_V_NUM_OF_BIN  4095
#define MAX_mV 3300

// ETC
#define IMPULSE_LEN 30
#define BUF_SIZE 1500
#define STD_INV_MS 0
#define INIT_TIME_LEN 100
//////////////////////////////////////////////////
// Buffer
// Needed for play back and impulse response
CircularBuffer<uint16_t, BUF_SIZE> dtBuf;
CircularBuffer<uint16_t, BUF_SIZE> playback_vBuf;

CircularBuffer<unsigned long, BUF_SIZE> impulse_tBuf;
CircularBuffer<float, BUF_SIZE> impulse_In_vBuf;
CircularBuffer<float, BUF_SIZE> impulse_Out_vBuf;
//////////////////////////////////////////////////
// GLOBAL VARS
int state =0;
int ledState=LOW;
//////////////////////////////////////////////////
void setup() {
    pinMode(DEBUG_LED, OUTPUT);
    pinMode(IDLE_LED, OUTPUT);
    analogWriteResolution(10);
    analogReadResolution(12);

    flush();

    state = St_IDLE;
    digitalWrite(IDLE_LED, HIGH);

    
    Serial.begin(9600);
}

void loop() {
    // Declare variables outside the switch to avoid cross-initialization errors
    unsigned long t_ms = 0;
    uint16_t dt = 0;
    float vin_mV = 0;
    uint16_t vout = 0;
    float vout_mV = 0;

    if (Serial.available() >= 4) {
        uint8_t bytes[4];
        for (int i = 0; i < 4; ++i) {
            if (Serial.available() > 0) {
                bytes[i] = Serial.read();
            }
        }
        uint16_t t = bytes[0] | (bytes[1] << 8);
        uint16_t v = bytes[2] | (bytes[3] << 8);

        if(v > MAX_OUT_V_NUM_OF_BIN){
            interpretInstruction(t, v);
        } else if (state == St_UPL) {
            dtBuf.push(t);
            playback_vBuf.push(v);
        }
    }

   if(state ==St_MON){
      debug();
      t_ms = millis();
      vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;
      vout = playback_vBuf.shift();;
      analogWrite(PLAYBACK_PIN, vout);
      vout_mV = vout * MAX_mV / MAX_OUT_V_NUM_OF_BIN;

      dt = dtBuf.shift();

      send2Matlab(t_ms, vin_mV, vout_mV);

      if(dt>5){
        delay(dt);
      }

      playback_vBuf.push(vout);
      dtBuf.push(dt);
   }
}


void send2Matlab(unsigned long t_ms, float vin_mV, float vout_mV){
    Serial.print(t_ms);
    Serial.print(",");
    Serial.print(vin_mV);
    Serial.print(",");
    Serial.print(vout_mV);
    Serial.print(";");
}

void interpretInstruction(uint16_t arg1, uint16_t arg2) {
    if (state == St_IDLE) {
        if (arg2 == SIG_START_CODE) {
            if (arg1 == SIG_MONITOR_CODE) { // St_IDLE -> St_MON
                digitalWrite(IDLE_LED, LOW);
                state = St_MON;
            } else if (arg1 == SIG_UPLOAD_CODE) { // St_IDLE -> St_UPL
                digitalWrite(IDLE_LED, LOW);
                flush();
                state = St_UPL;
            } else if (arg1 == SIG_IMPULSE_CODE){ // measure IR
                digitalWrite(IDLE_LED, LOW);
                measureIR();
                digitalWrite(IDLE_LED, HIGH);
            } else if (arg1==SIG_FLUSH_CODE){ // flush
                digitalWrite(IDLE_LED, LOW);
                flush();
                digitalWrite(IDLE_LED, HIGH);
            }
        } 

    } else if(arg1 == SIG_END_CODE && arg2 == SIG_END_CODE){ //END END Any -> St_IDLE
      state=St_IDLE;
    } else if (state == St_MON) {
        if (arg1 == SIG_MONITOR_CODE && arg2 == SIG_END_CODE) { // St_MON -> St_IDLE
            digitalWrite(IDLE_LED, HIGH);
            state = St_IDLE;
        }
    } else if (state == St_UPL) {
        if (arg1 == SIG_UPLOAD_CODE && arg2 == SIG_END_CODE) {  // St_UPL -> St_IDLE
            digitalWrite(IDLE_LED, HIGH);
            state = St_IDLE;
        }
    }
}

void measureIR(){
  unsigned long t_ms = 0;
  float vin_mV = 0;

  for (int i = 0; i < INIT_TIME_LEN; i++) {
        t_ms = millis();
        analogWrite(PLAYBACK_PIN, 0);
        vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;

        impulse_tBuf.push(t_ms);
        impulse_Out_vBuf.push(0);
        impulse_In_vBuf.push(vin_mV);

        delay(STD_INV_MS);
  }

  for (int i = 0; i < IMPULSE_LEN; i++) {
      t_ms = millis();
      analogWrite(PLAYBACK_PIN, MAX_OUT_V_NUM_OF_BIN);
      vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;

      impulse_tBuf.push(t_ms);
      impulse_Out_vBuf.push(MAX_mV);
      impulse_In_vBuf.push(vin_mV);

      delay(STD_INV_MS);
  }
    
  for (int i = 0; i < (BUF_SIZE-IMPULSE_LEN-INIT_TIME_LEN); i++) {
      t_ms = millis();
      analogWrite(PLAYBACK_PIN, 0);
      vin_mV = analogRead(RECORD_PIN) * MAX_mV / MAX_IN_V_NUM_OF_BIN;

      impulse_tBuf.push(t_ms);
      impulse_Out_vBuf.push(0);
      impulse_In_vBuf.push(vin_mV);

      delay(STD_INV_MS);
  }
  for (int i = 0; i < BUF_SIZE; i++) {
      send2Matlab(impulse_tBuf.first(), impulse_In_vBuf.first(), impulse_Out_vBuf.first());
      impulse_tBuf.shift(); // Assuming .shift() method exists to remove elements
      impulse_In_vBuf.shift();
      impulse_Out_vBuf.shift();
  }
}

void flush() {
  // Reinitialize the playback data buffers
  for(int i=0; i<BUF_SIZE; i++){
    playback_vBuf.push(0);
    dtBuf.push(STD_INV_MS);
    impulse_tBuf.push(0);
    impulse_In_vBuf.push(0);
    impulse_Out_vBuf.push(0);
  }
}

void debug(){
  ledState = !ledState;  // Change the state
  digitalWrite(DEBUG_LED, ledState); // Apply the new state to the LED
}