/*
(C) 2024 Zyfn Kothavala and TU/e, for use in Challenge 2 for DBB100 Creative Programming
unicorn_smasher_arduino_1_0.ino
Works with Processing 4, Arduino IDE 2.3.2, and Arduino Uno R3 over Serial.
Thanks to Mark Stanley and Alexander Brevig for the Keypad library and the CustomKeypad example code.

Welcome to Unicorn Smasher!

This is a whac-a-mole style game, where the user has to smash unicorns that appear on the onscreen grid using an Arduino keypad of 16 buttons.

GAME AND CODE INFO:
- Default row pins (R0-R3) are 9, 8, 7, 6
- Default column pins (C0-C3) are 10, 11, 12, 13

HOW TO RUN:
1. Connect a 4*4 matrix keypad to the Arduino. The pins used (rPins and cPins) can be edited in the code below. Connect the Arduino to USB and run the unicorn_smasher_arduino.ide code (Make sure the Serial Monitor is DISABLED). 
2. Run the unicorn_smasher_pde code in Processing. (If the Arduino is not detected, make sure to UNCOMMENT 'printArray(Serial.list());' in the Processing code to find the Serial port of the Arduino) and then rerun the code.
3. Have fun!

*/

#include <Keypad.h> //Inlcudes Keypad library (v. 3.1.0)

const byte rows= 4; //Keypad rows
const byte cols= 4; //Keypad columns

byte keymap[rows][cols]=  //Keymap of keys on keypad
{
{1, 2, 3, 4},
{5, 6, 7, 8},
{9, 10, 11, 12},
{13, 14, 15, 16}
};

//Connections to Arduino pins
byte rPins[rows]= {9, 8, 7, 6} ; //Rows 0 to 3
byte cPins[cols]= {10, 11, 12, 13}; //Columns 0 to 3

//initializes an instance of the Keypad class with required rows, columns, and pins
Keypad buttons= Keypad(makeKeymap(keymap), rPins, cPins, rows, cols);

void setup()
{
     Serial.begin(9600);  // initializing Serial communication
}


void loop()
{
     byte keypressed = buttons.getKey();  //Gets key pressed information from Keypad

     if (keypressed)  //If a key is pressed:
     { 
          //Serial.println(keypressed); //Uncomment for debugging
          Serial.write((byte)keypressed); //Writes the pressed key to Serial
     }
     delay(50); //Delay to prevent overloading Serial port
}