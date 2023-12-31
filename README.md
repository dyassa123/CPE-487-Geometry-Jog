# Geometry Jog Game
> *I pledge my Honor that I have abided by the Stevens Honor System.*
> David Martinez and Daniel Yassa

## *Brief Overview*
Geometry Jog Game is an interactive game inspired by titles like the [Chrome Dinosaur Game](https://en.wikipedia.org/wiki/Dinosaur_Game), [Flappy Bird](https://en.wikipedia.org/wiki/Flappy_Bird), and [Geometry Dash](https://en.wikipedia.org/wiki/Geometry_Dash). It's developed for the Nexys-A7 100T board, featuring a player-controlled magenta ball. The player's objective is to avoid red squares while scoring points by collecting blue squares. The score is updated and portrayed on seven-segment anode displays on the board. The game is playable through button inputs on the board, with one button for jumping and another for resetting the game.

## *Expected Behavior*
This game requires the VGA connector to display on an external screen. Once connected to the screen and FPGA run synthesis, and implementation, generate bitstream, and program the board to get the game running. Once running, the player, as a magenta ball, can press the middle button (BTNC) to jump. They can also press the top button (BTNU) to reset the game to the initial starting spot. Red and blue squares will quickly and randomly come at the player. If touched, the blue squares will increment the player’s score which is displayed on the board in hexadecimal. Conversely, the red squares will cause the game to reset along with the player’s score. 
  * Gameplay: Control a magenta ball to avoid red squares and collect blue squares.
  * Controls: Use the board buttons to jump and reset the game.
  * Display: The score is displayed on the Nexys board.

## *Required Attachments*
* Nexys-A7 100T Board
* VGA Connector for Display Output

## *High-Level Block Diagram*
![Schematic](/BallGamePics/circuit.png)

* Input Processing: Button inputs on the Nexys board.
* Game Logic: Handles player movements, collision detection, and score updates.
* Display Output: VGA output to display the game state.
* Score Display: Seven-segment display on the Nexys board for the score.

* The ***BallGame.vhd*** module serves as the top-level that integrates all other components.
  *  Generates and manages various clock signals for different modules.
  *  Connects sub-modules like ***bat_n_ball, vga_sync,*** and ***leddecNew***.
  *  Routes signals between sub-modules and the Nexys-A7 board's physical ports.
  *  Processes button inputs for game control (jump and reset).
 
* The ***bat_n_ball.vhd*** module serves as the core game logic and rendering module for our game. 
  *  Manages the player's (ball's) movements, including jumping.
  *  Controls the appearance and movement of obstacles (*big*, *med*, and *sml*).
  *  Checks for collisions between the player and obstacles.
  *  Manages the scoring system of the game.
  *  Determines what is displayed at each pixel for the VGA output.
 
*  The ***vga_sync.vhd*** module manages vga synchronization and display output. 
  * Generates horizontal and vertical sync signals for VGA.
  * Calculates pixel row and column for the current frame.
  * Controls the RGB output for each pixel to be displayed on the VGA screen.

* The ***leddecNew.vhd*** module drives the seven-segment LED display on the Nexys-A7 board.
  * Chooses which digit on the seven-segment display to activate.
  * Determines which segments to light up for displaying numbers.
  * Shows the player's score or other numerical data on the LED display.
 
## *Project in Action*

### Game In Action (Player Jumping)
![Game](/BallGamePics/game.jpg)

### Score Display
![Board](/BallGamePics/board.jpg)

## *Steps To Run The Project*

**1. Setup in Vivado: Create a new RTL project *geometryjog* in Vivado Quick Start**
   
   * Create six new source files of file type VHDL called ***BallGame, bat_n_ball, clk_wiz_0, clk_wiz_0_clk_wiz, leddecNew,*** and ***vga_sync***
     
     * ***clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd*** and ***vga_sync.vhd*** are the same files as in Lab 3 and Lab 6
       
     * ***bat_n_ball.vhd and BallGame.vhd*** were extracted from Lab 6 and then modified.
       
       * ***BallGame.vhd*** was constrcuted and modified off of ***pong.vhd*** (Lab 6)
         
   * ***leddecNew.vhd*** was constructed and modified off of ***leddec.vhd*** (Lab 4)
  
   * Create a new constraint file of file type XDC called ***BallGame***
  
   * Choose Nexys A7-100T board for the project
  
   * Click 'Finish'
  
   * Click design sources and copy the VHDL code from ***BallGame,vhd, bat_n_ball.vhd, clk_wiz_0.vhd, clk_wiz_0_clk_wiz.vhd, leddecNew.vhd,*** and ***vga_sync.vhd***
  
   * Click constraints and copy the code from ***BallGame.xdc***
     
**2. Run Synthesis**

**3. Run Implementation and Open Implemented Design**

**4. Generate Bitstream, Open Hardware Manager, and Program Device**

  * Click 'Generate Bitstream'
    
  * Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

  * Click 'Program Device' then xc7a100t_0 to download ***BallGame.bit*** to the Nexys A7-100T board

  * The program will start to run. You will notice the red and blue blocks starting to move and approach the ball. Push BTNC to get the ball to jump and keep pressing it when necessary to keep the game in play.

## *Modifications*
Many of the files from *Lab 6: 'Pong'* were untouched. The constraint file removed the switch inputs and exchanged them for another button. The top-level file ***BallGame.vhd***(***Pong.vhd*** equivalent) added new ports and mapped them correctly. The ***adc_if.vhd*** file was completely removed from the project as we did not need the potentiometer. Most of the changes came in the ***bat_n_ball.vhd*** file which housed the logic for the game. Many signals were added to fit the game but followed the same format as previous *Pong* elements. Certain components of the *Pong* game were reused/reworked to fit the context:

1. The bat was retooled to be a static component that spanned the entire width of the screen but still recycled the original code. The square obstacles also used this logic to be drawn.

![Draw1](/BallGamePics/draw1.png)

![Draw2](/BallGamePics/draw2.png)

2.  Collision Detection

![Collision](/BallGamePics/collision.png)

3.  We changed the motion from the original ***bat_n_ball.vhd*** file to better suit our needs for the game.
   
 * First we gave each component its own speed, and declared a time factor that would be able to manipulate the speed of each component proportionally.

 * The game logic also gave each object its own ‘count’ variable.
   
 * The product of the time factor and the object’s own speed act as a threshold.
   
 * Each clock cycle the object’s count will increment by 1.
   
 * Once the object reaches the threshold it will move to its next position
   
 * In this case, the higher the speed/time factor, the slower the object will move as it needs to reach a higher threshold before it can update.
   
 * This is also used in conjunction with the jump movement for the player which will decrement its y pixel until it is at its apex position, in which case it will increment the y position where it reaches the ground once more.

![Jump](/BallGamePics/jump.png)

4. Random Number Generator

 * We used a linear feedback shift register to generate pseudo-random numbers.
   
 * This operation XORs the two most significant bits of a vector and stores the result in a temporary variable.
   
 * The initial vector then has each of its bits shifted to the right and replaces the least significant bit with the XOR result.
   
 * This new vector is then converted into an integer and used as the random number.

 ![Random](/BallGamePics/rand.png)

 * This random number was used when spawning in new obstacles.
 
 * Each obstacle would start on the right side of the screen or even further past it.
 
 * The motion described before would take it to the left side where its x component becomes 0.
 
 * At this point, the object then respawns at the right side of the screen (800 pixels in the x) plus a random amount of pixels in addition to that using the previously generated random number.
 
 * Each of the objects also has another factor added as well as moving at different speeds to make the generation of them feel more random.


![Move](/BallGamePics/move.png)

## *Development Process and Summary*
 * Team Contributions
   * Each member contributed equally as although Danny’s computer was unable to run the program (we found this out during Lab 3), we both worked together to figure out, code, and tweak each component as well as write the report.
 * Timeline
   * The process began with identifying modules that could be reused and anything that needed to be added. We knew we would be able to reuse the drawing from pong and rework it/add more components to fit the game situation. We also thought that we could reuse the motion for the ball but this proved difficult later on. Another component was the random number generator as we did not want to make the game predictable. The first change was removing the adc_if file completely and any variables or signals related to it across the program. Next we tweaked the inputs in the constraint and top level files to match what we needed (jump and reset). After that we drew the new components and colored them differently. Next we researched how to generate random numbers and implement them in VHDL as we knew we would need a random number at some point and it was then implemented as the LFSR. We came up with the new motion system that also used the random number. We then recycled the ball bouncing off the bat system as our hit detection system which would either reset the game back to initial inputs, or increment the score to be displayed in the same manner as was with the Pong game.
 * Challenges and Solutions
   *  We tried to implement the motion from the ball originally in pong but this system proved somewhat complicated and wanted to start from the ground up. Eventually we found the time factor and threshold method that is the basis for all of our motion and allowed us to integrate the random number by placing objects off screen.

## *Conclusion*

In conclusion, the Geometry Jog Game project was more than a mere academic exercise; it was a comprehensive learning journey that touched upon various aspects of digital system design. It underscored the importance of teamwork, perseverance, and creative problem-solving in the field of engineering. This project has not only left us with a functional and entertaining game but also a wealth of knowledge and skills that will be instrumental in our future endeavors as engineers.
