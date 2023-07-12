int tachPin = 5;
int PWMpin = 3;
int buttonPin = 7;

int greenPin = 10;
int yellowPin = 9;
int redPin = 8;

int buttonState = 0;
int lastButtonState = 0;
unsigned long buttonPressStartTime = 0;
unsigned long requiredHoldTime = 1000;

bool isOff = false;

unsigned long previousMillis = 0;
unsigned long interval = 1000;

void setup() {
  Serial.begin(9600);
  pinMode(PWMpin, OUTPUT);
  pinMode(buttonPin, INPUT);

  pinMode(greenPin, OUTPUT);
  pinMode(yellowPin, OUTPUT);
  pinMode(redPin, OUTPUT);

  pinMode(LED_BUILTIN, OUTPUT);

  digitalWrite(greenPin, HIGH);

  pinMode(tachPin, INPUT_PULLUP);

  TCCR1A &= ~(_BV(WGM11) | _BV(WGM10));
  TCCR1B &= ~(_BV(WGM13) | _BV(WGM12) | _BV(CS12) | _BV(CS11) | _BV(CS10));
  // Set clock source to T1, falling edge (set CS10 for rising edge)
  TCCR1B |= _BV(CS12) | _BV(CS11);
}

int getControl() {
  int pot = analogRead(A0);
  return pot * (255 / 1023.0);
}

void logValues(int pwm, bool isNormalMode) {
  int rpm = TCNT1 * 60;
  if (isNormalMode) {
    if (rpm < 500) {
      digitalWrite(redPin, HIGH);
      digitalWrite(yellowPin, LOW);
      digitalWrite(greenPin, LOW);
    } else if (rpm < 1000) {
      digitalWrite(redPin, LOW);
      digitalWrite(yellowPin, HIGH);
      digitalWrite(greenPin, LOW);
    } else {
      digitalWrite(redPin, LOW);
      digitalWrite(yellowPin, LOW);
      digitalWrite(greenPin, HIGH);
    }
  }
  TCNT1 = 0;
  Serial.print("RPM: ");
  Serial.print(rpm);
  Serial.print(" | PWM: ");
  Serial.println(pwm); 
  //Serial.println(rpm);
}

void loop() {
  unsigned long currentMillis = millis();

  buttonState = digitalRead(buttonPin);

  if (buttonState != lastButtonState) {
    if (buttonState == HIGH) {
      buttonPressStartTime = currentMillis;
    } else {
      unsigned long buttonPressDuration = currentMillis - buttonPressStartTime;

      if (buttonPressDuration >= requiredHoldTime) {
        isOff = !isOff;
        digitalWrite(redPin, isOff ? LOW : HIGH);
        digitalWrite(greenPin, isOff ? LOW : HIGH);
        digitalWrite(yellowPin, isOff ? LOW : HIGH);
        digitalWrite(LED_BUILTIN, isOff ? HIGH : LOW);
        analogWrite(PWMpin, isOff ? 0 : 250);
        Serial.println(isOff ? "----------DISABLE FAN----------" : "----------ENABLE FAN----------");

        if (!isOff) {
          for (int i = 0; i <= getControl(); i++) {
            analogWrite(PWMpin, i);
            if (i % 10 == 0) { logValues(i, false); }
            delay(100);
          }
        }
      } else {
        digitalWrite(redPin, HIGH);
        digitalWrite(yellowPin, HIGH);
        digitalWrite(greenPin, HIGH);
        digitalWrite(LED_BUILTIN, HIGH);
        for (int i = 0; i <= getControl(); i++) {
          analogWrite(PWMpin, i);
          if (i % 10 == 0) { logValues(i, false); }
          delay(100);
        }
        digitalWrite(redPin, LOW);
        digitalWrite(yellowPin, LOW);
        digitalWrite(greenPin, LOW);
        digitalWrite(LED_BUILTIN, LOW);
      }
    }
  }

  lastButtonState = buttonState;

  if (!isOff) {
    int fan_speed = getControl();

    analogWrite(PWMpin, fan_speed);

    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;

      logValues(fan_speed, true);
    }
  }
}
