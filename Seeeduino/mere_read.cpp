# define DAC_PIN A0

void setup() 
{
  analogReadResolution(12);
  Serial.begin(9600);
}

void loop() 
{
  float voltage = analogRead(A1) * 3.3 / 4096.0;
  
  unsigned long currentTime = millis(); 
  Serial.print(currentTime);
  Serial.print(","); 
  Serial.println(voltage);
  delay(1);
}