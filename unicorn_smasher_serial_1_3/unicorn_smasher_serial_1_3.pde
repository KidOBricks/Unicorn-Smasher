/*
(C) 2024 Zyfn Kothavala and TU/e, for use in Challenge 2 for DBB100 Creative Programming
unicorn_smasher_serial_1_3.pde
Works with Processing 4, Arduino IDE 2.3.2, and Arduino Uno R3 over Serial.

Welcome to Unicorn Smasher!

This is a whac-a-mole style game, where the user has to smash unicorns that appear on the onscreen grid using an Arduino keypad of 16 buttons.

GAME AND CODE INFO:
- A minimum screen size of 800*1000px is required for the game to display correctly. (For example, 720p, 1024*768 and 1600*900 displays are too small, but it works well on a 1080p display or higher. Tested only on 4K and WQXGA displays.)
- The game is scalable. The canvas size should be set to a 4:5 aspect ratio, and every resolution should work fine. (For example, you could use 1000*1250, 800*1000, 400*500, or others)
- Class Mole handles the generation and management of moles on the grid.
- DeadMole and DisappearedMole are child classes of Mole that handle moles after they are hit (dead) or disappear due to inactivity (disappeared).
- Class Game manages the game info, and acts as the 'game master'.
- Logs from the most recent game of Unicorn Smasher are stored in 'logfile.txt' in the game folder.
- Game assets including images and audio files are stored in the game folder. 
- The top 3 high scores and their date-time of creation are stored in 'hs.txt', displayed at the end of a game, and are updated after every game.

HOW TO RUN:
1. Connect the Arduino and run the unicorn_smasher_arduino.ide code (Make sure the Serial Monitor is DISABLED). More information on setting up the Arduino and hardware is in the user guide.
2. Run the unicorn_smasher_serial.pde code in Processing. (If the Arduino is not detected, make sure to UNCOMMENT 'printArray(Serial.list());' to find the Serial port of the Arduino) and then rerun the code.
3. Have fun!

*/

//Importing required libraries
import processing.serial.*;  //For Serial Communication with Arduino
import processing.sound.*;  //For sound output, the Processing Sound library must be installed for this to work (https://processing.org/reference/libraries/sound/index.html)

//Class to create and manage moles on grid
class Mole
{
  String[] moleStates = {"active", "dead", "disappeared", "initial"};  //Stores all possible mole states (moleState initial is used onl when the game starts)
  String moleState;  //Stores current mole state

  int score;  //Current mole score
  int x;  //Current mole x-coordinate
  int y;  //Current mole y-coordinate

  int triggerKey;  //Key that triggers death of current mole (based on x and y coordinate
  int [][] keyMap =  //Maps arduino keypad to keys 1-16
    {
    {1, 2, 3, 4},
    {5, 6, 7, 8},
    {9, 10, 11, 12},
    {13, 14, 15, 16}
  };

  int birthTime;  //Stores gametime of current mole birth

  //Parameterised constuctor to create mole while game is running
  Mole(int X, int Y)
  {
    x = X;
    y = Y;
    score = 0; 
    moleState = moleStates[0];  //Sets mole to active state
    triggerKey = keyMap[y][x];  //Gives triggerKey corresponding to current x-y coordinates of mole onscreen
    birthTime = millis();  //Records birth time of mole
  }

  //Default constructor (used during game start)
  Mole()
  {
   //This mole is not displayed onscreen, or used to calculate score, but is required to create the first 'real' mole of the game
    x = -1;  
    y = -1;
    score = 0;
    moleState = moleStates[3];  //Gives mole 'initial' state
    triggerKey = ' ';
    birthTime = 0;
  }
  
  
  //Gives new score to current mole
  void setScore(int newScore)
  {
    score = newScore;
  }
  
  //Sets current mole state to dead or disappeared
  void setMoleState(int state)
  {
    moleState = moleStates[state];  //'dead' if state == 1, 'disappeared' if state == 2
  }
  

  //Gets score of current mole
  int getScore()
  {
    return score;  
  }

  //Gets x-coordinate of current mole (Not used in final game but useful for debugging)
  int getMoleX()
  {
    return x;
  }

  //Gets y-coordinate of current mole (Not used in final game but useful for debugging)
  int getMoleY()
  {
    return y;
  }

  //Draws mole on the screen, based on size of cell
  void drawMole(int cellSize)
  {
    //Calculations are done to ensure the image fits in the cell nicely
    //For example, in a cell size of 250*250 px, the image will be 200*200 px and centered in the cell
    image(unicorn, (x * cellSize) + (cellSize / 10), ((y + 1) * cellSize) + (cellSize / 10), cellSize * 0.8, cellSize * 0.8);  
  }

  //Removes mole if it is hit using triggerKey, or if it disappears
  void removeMole(int cellSize)
  {
    //Removes image by replacing with rectangle of background color
    fill(#F4C2C2);  
    stroke(0);
    rect(x * cellSize, (y * cellSize + cellSize), cellSize, cellSize);  
    
    if(moleState == "dead")  //If mole has been hit using triggerKey
    {
      deadMole = new DeadMole(this.x, this.y);  //Creates new DeadMole object at same coordinates of current mole
      smash.play();  //Plays smash sound for mole hit
    }
    if(moleState == "disappeared")  //If mole has disappeared due to not being hit for 2000ms
    {
      disappearedMole = new DisappearedMole(this.x, this.y);  //Creates new DisappearedMole object at same coordinates of current mole
      poof.play();  //Plays 'poof' sound for mole disappearance
    }
  }

  //Checks if mole has been hit
  boolean isHit()
  {
    if (val == this.triggerKey)  //If input on serial is the triggerKey of the mole
    {
      return true;  //Mole is hit
    }
    return false;   //Mole is not hit
  }
}



//Child class DeadMole to handle Mole object once it dies
class DeadMole extends Mole
{
  int x;  //x-coordinate of dead mole
  int y;  //y-coordinate of dead mole
  boolean exists;  //Stores whether dead mole exists or not
  int deathTime;  //Stores time of death of mole
  

  //Parameterised constructor used when mole has been hit while game is running
  DeadMole(int X, int Y)
  {
    x = X;  //X-coordinate of dead mole (from previously alive mole)
    y = Y;  //Y-coordinate of dead mole (from previously alive mole)
    exists = true;  //Sets its existence to true
    deathTime = millis();  //Stores deathTime as object creation time
  }

  //Default constructor (used during game start)
  DeadMole()
  {
    //This dead mole is not displayed onscreen, or used to calculate score, but is required to create the first 'real' dead mole of the game
    x = -1;
    y = -1;
    exists = false;
    deathTime = 0;
  }
  

  //Draws dead mole image
  void drawDeadMole()
  {
    //Calculations are done to ensure the image fits in the cell nicely
    //For example, in a cell size of 250*250 px, the image will be 200*200 px and centered in the cell
    image(hammer, (x * cellSize) + (cellSize / 10), ((y + 1) * cellSize) + (cellSize / 10), cellSize * 0.8, cellSize * 0.8);
  }

  //Deletes dead mole (this method is called if the dead mole image has been active for 400ms)
  void deleteDeadMole()
  {
    //Removes image by replacing with rectangle of background color
    fill(#F4C2C2);
    stroke(0);
    rect(x * cellSize, (y * cellSize + cellSize), cellSize, cellSize);
    
    exists = false; //Sets existence of dead mole to false
  }
}



//Child class DisappearedMole to handle Mole object once it disappears
class DisappearedMole extends Mole
{
  int x;  //x-coordinate of dead mole
  int y;  //y-coordinate of dead mole
  boolean exists;  //Stores whether dead mole exists or not
  int disappearTime;  //Stores time of disappearance of mole


  //Parameterised constructor used when mole has been hit while game is running
  DisappearedMole(int X, int Y)
  {
    x = X;  //X-coordinate of disappeared mole (from previously alive mole)
    y = Y;  //Y-coordinate of disappeaered mole (from previously alive mole)
    exists = true;  //Sets its existence to true
    disappearTime = millis();  //Stores disappearTime as object creation time
  }
  
  //Default constructor (used during game start)
  DisappearedMole()
  {
    //This disappeared mole is not displayed onscreen, or used to calculate score, but is required to create the first 'real' dead mole of the game
    x = -1;
    y = -1;
    exists = false;
    disappearTime = 0;
  }


  //Draws dead mole image
  void drawDisappearedMole()
  {
    //Calculations are done to ensure the image fits in the cell nicely
    //For example, in a cell size of 250*250 px, the image will be 200*200 px and centered in the cell
    image(disappear, (x * cellSize) + (cellSize / 10), ((y + 1) * cellSize) + (cellSize / 10), cellSize * 0.8, cellSize * 0.8);
  }

  void deleteDisappearedMole()
  {
    //Removes image by replacing with rectangle of background color
    fill(#F4C2C2);
    stroke(0);
    rect(x * cellSize, (y * cellSize + cellSize), cellSize, cellSize);
    
    exists = false;  //Sets existence of disappeared mole to false
  }
}



//Class to handle game features. Acts as the 'game master' and controls all essential functions
class Game
{
  
  int playerScore;  //Stores current score of player
  boolean running;  //Stores whether game is currently running
  int timeLeft;  //Stores time left of the game in seconds
  boolean scoresUpdated;
  
  String[] highScores;  //This is used to store top 3 scores and their date and time of creation
  

  //Constructor method - called at the start of the program. Does not take any parameters.
  Game()
  {
    playerScore = 0;  //Sets player score to 0
    running = true;  //Starts game
    timeLeft = 30;  //Sets game time left to 30s
    scoresUpdated = false;
    
    highScores = loadStrings("hs.txt");  //Loads high scores from hs.txt
    
    
    //Used for debugging high scores
    for (int i = 0; i < 6; i++)
    {
      System.out.println(highScores[i]);
    }
     
  }
  
  
  //Updates game info (gridlines, player score and time left)
  void updateInfo(int cellSize)
  {
    //Loop used to print gridlines
    for (int i = 0; i < gridSize; i++)
    {
      line(i * cellSize, cellSize, i * cellSize, height);  //Vertical Lines
      line(0, cellSize + (i * cellSize), width, cellSize + (i * cellSize));  //Horizontal Lines
    }

    //Display game name onscreen
    textAlign(CENTER);
    textSize(cellSize / 2.5);
    fill(0);
    text("Unicorn Smasher", width / 2, cellSize / 2);


    // Display player score onscreen
    textAlign(LEFT);
    textSize(cellSize / 5);
    fill(0);
    text("Player Score: " + playerScore, 10, cellSize * 0.9);

    // Display time left onscreen
    textAlign(RIGHT);
    fill(0);
    text("Time: " + timeLeft, width - 10, cellSize * 0.9);
  }

  //Updates player score
  void updatePlayerScore(Mole mole)
  {
    playerScore += mole.getScore();  //Calls getScore method of Mole object to add to player score
  }

  //Method run when game ends
  void over()
  {
    //int overTime = millis();  //To close game
    background(#F4C2C2);  //Redraws background
    
    //Prints game over message
    textSize(cellSize / 2.5);
    textAlign(CENTER);
    text("Game Over\nFinal Score: " + playerScore, width/2, height/8);
    game.printLog(4, mole);

    //Easter egg: Motivational message printed if final score > 1500
    if (playerScore > 1500)
    {
      text("You Smashed It!", width/2, height * 0.8);  //Displays message
    }

    for (int i = 0; i <= 5; i+=2)  //Checks if score is a new high score
    {
      if (this.playerScore > Integer.parseInt(this.highScores[i]))  //Compares current final score to top 3 scores (For more info about how hs.txt works, check the readme)
      {
        game.rewriteHS(i);  //Rewrites required high score
        this.scoresUpdated = true;  //Prevents scores from updating again when game.over() runs
        break;
      }  
    }
    
    //Displays high scores ons
    textSize(cellSize / 2.5);
    textAlign(CENTER);
    text("HIGH SCORES:\n", width / 2, ((height / 4) + (cellSize / 2.5) + (cellSize / 10)));
    
    textSize(cellSize / 5);
    text("1. " + highScores[0] + " - " + highScores[1] + "\n2. " + highScores[2] + " - " + highScores[3] + "\n3. " + highScores[4] + " - " + highScores[5], width / 2, ((height / 4) + 2*((cellSize / 2.5)) + (cellSize / 10)));
    
    
    //Closes logging
    output.flush();
    output.close();

  }

  //Changes time left
  void timerChange()
  {
    if (frameCount % 100 == 0)  //Reduces timeLeft by 1 if frameCount is a multiple of 100 (where game framerate is 100)
    {
      timeLeft--;
    }
  }

  //Checks if game is running
  boolean isRunning()  
  {
    if (timeLeft <= 0)
    {
      running = false;  //Sets game state to not running if timeLeft is 0
    }
    return running;
  }

  //Used to print logs and create log file
  void printLog(int log, Mole mole)
  { 
    //Prints current date-time at the start of every log
    output.print(year() + "-" + month() + "-" + day() + " " + hour() + ":" + minute() + ":" + second() + ":\t");

    switch(log)
    {
    case 0:  //Logtype 0 signifies new game started
      output.println("New Unicorn Smasher Game started.");  //Prints required information
      break;
    case 1:  //Logtype 1 signifies new mole created
      output.println("New unicorn created at " + mole.x + ", " + mole.y);  //Prints required information
      break;
    case 2:  //Logtype 2 signified mole has been killed. Prints alive time of mole and current player score
      output.println("Unicorn smashed.\t\tAlive Time: " + (millis() - mole.birthTime) + "ms\t\tUnicorn Score: " + mole.score + "\t\t Current Score: " + this.playerScore);  //Prints required information
      break;
    case 3:  //Logtype 3 signifies mole has disappered. Prints current player score
      output.println("Unicorn disappeared. Current Score: " + this.playerScore);  //Prints required information
      break;
    case 4: //Logtype 4 signifies game is over. Prints final player score
      output.println("Unicorn Smasher Game Over.\tFinal Score: " + this.playerScore); 
      break;
    }
  }
  
  //Rewrites highscores
  void rewriteHS(int overridenScore)
  {    
    if(!this.scoresUpdated)  //Runs code in method only if scores have not been updated before
    {
      String[] newHighScores = new String[6];  //Stores newly written high scores
      
      if(overridenScore == 0)
      {
        newHighScores[0] = Integer.toString(this.playerScore);
        newHighScores[1] = (year() + "-" + month() + "-" + day() + " " + hour() + ":" + minute() + ":" + second());
        newHighScores[2] = this.highScores[0];
        newHighScores[3] = this.highScores[1];
        newHighScores[4] = this.highScores[2];
        newHighScores[5] = this.highScores[3];
      }
      
      else if(overridenScore == 2)
      {
        newHighScores[0] = this.highScores[0];
        newHighScores[1] = this.highScores[1];
        newHighScores[2] = Integer.toString(this.playerScore);
        newHighScores[3] = (year() + "-" + month() + "-" + day() + " " + hour() + ":" + minute() + ":" + second());
        newHighScores[4] = this.highScores[2];
        newHighScores[5] = this.highScores[3];
      }
      
      else if(overridenScore == 4)
      {
        newHighScores[0] = this.highScores[0];
        newHighScores[1] = this.highScores[1];
        newHighScores[2] = this.highScores[2];
        newHighScores[3] = this.highScores[3];
        newHighScores[4] = Integer.toString(this.playerScore);
        newHighScores[5] = (year() + "-" + month() + "-" + day() + " " + hour() + ":" + minute() + ":" + second());
      }
      
      //Used for debugging high scores
      for (int i = 0; i < 6; i++)
      {
        System.out.println(newHighScores[i]);
      }
    
      for(int i = 0; i < 6; i++)    //Store new high scores in highScores array
      {
        this.highScores[i] = newHighScores[i];
      }


      saveStrings("hs.txt", highScores); 
    }//Outputs new high scores to 'hs.txt'
  }
}


//Instance (global) variables
Serial port;  //For Arduino communication
int val;  //Stores data received from Arduino
int gridSize;  //Stores size of game grid
int cellSize;  //Stores size of game cell

//Initializes required objects as global
Mole mole;
Game game;
DeadMole deadMole;
DisappearedMole disappearedMole;

//Initializes required images
PImage unicorn;
PImage disappear;
PImage hammer;

//Initializes required sound files
SoundFile smash;
SoundFile poof;

//Variables to create and store mole position
int lastX;
int lastY;
int moleX;
int moleY;

//PrintWriter object for logging
PrintWriter output;

//Initial run-once code goes here
void setup()
{
  size(800, 1000);  //Creates game in canvas of 800*1000 px
  frameRate(100);  //Sets game framerate to 100
  
  /*UNCOMMENT THIS BLOCK TO FIND ARDUINO COM PORT
  
  printArray(Serial.list());  //To find Arduino Serial port
  
  */
  
  //Loads required images from game folder
  unicorn = loadImage("unicorn-png-2.png");
  disappear = loadImage("disappear-png-1.png");
  hammer = loadImage("hammer-png-1.png");

  //Loads required sound files from game folder
  smash = new SoundFile(this, "smash-mp3-1.mp3");
  poof = new SoundFile(this, "poof-mp3-1.mp3");
  
  String arduinoPort = Serial.list()[0];  //Stores Arduino port
  port = new Serial(this, arduinoPort, 9600);  //Creates Serial object at Arduino port with baud rate 9600
  //port.bufferUntil('\n');

  gridSize = 4;  //Sets grid to be 4*4
  cellSize = width/gridSize;  //Sets cellSize to be 1/4 of gridSize in this case
  
  game = new Game();  //Starts game by creating Game object
  
  //Creates objects of all types of moles using default constructors (required to run draw() code)
  mole = new Mole();
  deadMole = new DeadMole();
  disappearedMole = new DisappearedMole();

  //Creates logging txt file and prints required information
  output = createWriter("logfile.txt");
  output.println("Unicorn Smasher Log File");
  game.printLog(0, mole);  //Prints game start log
}

void draw()
{
  background(#F4C2C2);  //Sets background color

  game.updateInfo(cellSize);  //Updates game info (gridlines, player score, and player s

  if (game.isRunning())  //If game is running (i.e. timeLeft != 0)
  {
    // Update timer
    game.timerChange();

    //If mole is not active (i.e. "dead", "disappeared", or "initial")
    if (!(mole.moleState.equals("active")))
    {
      //Makes sure that new mole being created is not in the same x-y coordinates of the previous mole
      boolean cellRepeating = true;
      while (cellRepeating)
      {
        moleX = int(random(gridSize));
        moleY = int(random(gridSize));
        if (!((moleX == lastX) && (moleY == lastY)))
        {
          cellRepeating = false;
        }
      }
      
      mole = new Mole(moleX, moleY); //Creates new mole object at moleX and moleY as calculated above
      mole.setScore(100);  //Sets score of new mole to 100
      game.printLog(1, mole);  //Prints new mole creation log
      mole.drawMole(cellSize);  //Draws mole on screen
      
      //Resets lastX and lastY
      lastX = moleX;
      lastY = moleY;

    } 
    else  //if mole is active
    {
      mole.drawMole(cellSize);  //Redraws mole in the same coordinates
      
      //Change score of current mole
      //Scoring method: Mole starts with a score of 100. Every 20ms, the score decreases by 1 until score reaches 0. 
      //If the mole is hit, its score at that point is added to the playerScore. 
      //If the mole is not hit within 2000ms (2s), its score becomes 0, it disappears, and playerScore remains the same.
      
      mole.setScore(100 - (int)((millis() - mole.birthTime)/20));
      
      if (millis() - mole.birthTime >= 2000)  //If mole has existed for 2000ms (2s)
      {
        game.printLog(3, mole);  //Prints mole disappearance log
        mole.setMoleState(2);  //Sets mole state to "disappeared"
        mole.removeMole(cellSize);  //Removes mole
        disappearedMole.drawDisappearedMole();  //Draws disappeared mole
      }
    }
    
    
    //Drawing/deleting dead and disappeared moles
    if (deadMole.exists)  //If there is a dead mole
    {
      if (millis() - deadMole.deathTime >= 400)  //If the dead mole has been existing for > 400ms
      {
        deadMole.deleteDeadMole();  //Deletes dead mole
      } 
      else  //If dead mole has not existed for > 400ms
      {
        deadMole.drawDeadMole();  //Draws dead mole
      }
    }

    if (disappearedMole.exists)  //If there is a disappeared mole
    {
      if (millis() - disappearedMole.disappearTime >= 400)  //If the disappeared mole has been existing for > 400ms
      {
        disappearedMole.deleteDisappearedMole();   //Deletes disappeared mole
      } 
      else  //If disappeared mole has not existed for > 400ms
      {
        disappearedMole.drawDisappearedMole();  //Draws disappeared mole
      }
    }

    //Serial communication with Arduino
    if (port.available() > 0)  //If there exists data to be read on the port
    {
      val = port.read();  //Reads data

      if (mole.isHit())  //If mole is hit (i.e. killed)
      {
        game.updatePlayerScore(mole);  //Updates player score
        game.printLog(2, mole);  //Prints mole hit log
        mole.setMoleState(1);  //Sets mole state to "dead"
        mole.removeMole(cellSize);  //Removes alive mole
        deadMole.drawDeadMole();  //Draws dead mole
      }
    }
  } 
  
  else  //If game is not running (i.e. timeLeft == 0)
  {
    background(#F4C2C2);  //Displays background
    game.over();  //Runs game over method code     
  }
}
