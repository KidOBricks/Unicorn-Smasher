# Unicorn-Smasher

readme.txt

Unicorn Smasher

(C) 2024 Zyfn Kothavala and TU/e, for use in Challenge 2 for DBB100 Creative Programming
unicorn_smasher_serial_1_3.pde and unicorn_smasher_arduino_1_0.ino
Works with Processing 4, Arduino IDE 2.3.2, and Arduino Uno R3 over Serial.

Welcome to Unicorn Smasher!

This is a whac-a-mole style game, where the user has to smash unicorns that appear on the onscreen grid using an Arduino keypad of 16 buttons.

GAME AND CODE INFO:
PROCESSING:
	- A minimum screen size of 800*1000px is required for the game to display correctly. For example, 720p, 1024*768 and 1600*900 displays are too small, but it works well on a 1080p display or higher. Tested only on 4K and WQXGA displays.)
	- Class Mole handles the generation and management of moles on the grid.
	- DeadMole and DisappearedMole are child classes of Mole that handle moles after they are hit (dead) or disappear due to inactivity (disappeared).
	- Class Game manages the game info, and acts as the 'game master'.
	- Logs from the most recent game of Unicorn Smasher are stored in 'logfile.txt' in the game folder.
	- Game assets including images and audio files are stored in the game folder. 
	- The top 3 high scores and their date-time of creation are stored in 'hs.txt' and are updated after every game.
ARDUINO:
	- Default row pins (R0-R3) are 9, 8, 7, 6
	- Default column pins (C0-C3) are 10, 11, 12, 13
	- Make sure the Serial Monitor is NOT active while running the code
HIGH SCORES:
	- High scores are stored in the 'hs.txt' file. This includes the top 3 scores as well as their date and time of creation
	- The format of the document is Score 1 - Time - Score 2 - Time Score 3 - Time, each on a different line for a total of 6 different lines
	- If the player scores over 1500 points in one game, then a message saying "You Smashed It" is displayed onscreen.

USER GUIDE:
1. Connect a 4*4 matrix keypad to the Arduino. The pins used (rPins and cPins) can be edited in the code. 
2. Connect the Arduino to USB and run the unicorn_smasher_arduino.ide code (Make sure the Serial Monitor is DISABLED). 
3. Run the unicorn_smasher_pde code in Processing. (If the Arduino is not detected, make sure to UNCOMMENT 'printArray(Serial.list());' in the Processing code to find the Serial port of the Arduino) and then rerun the code.
4. Have fun!

RULES AND SCORING
- The game lasts 30 seconds and begins when the code starts running
- Unicorns will appear randomly in a 4*4 grid.
- The goal of the game is to hit the unicorn by pressing the appropriate button on the Arduino as soon as possible.
- Each unicorn will stay onscreen for a maximum of 2 seconds before it disappears and appears in another square.
- When the unicorn is hit, and animation and sound will play, and the unicorn will appear in another square on the grid.
- Scoring: Each unicorn starts with a score of 100. Every 20ms, the score decreases by 1 until score reaches 0. If the mole is hit, its score at that point is added to the player's score. If the mole is not hit within 2000ms (2s), its score drops to 0, it disappears, and the player's score remains the same.
      
