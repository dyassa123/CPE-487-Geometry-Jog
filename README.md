# Geometry Jog Game
> *I pledge my Honor that I have abided by the Stevens Honor System.*

## *Brief Overview*
Geometry Jog Game is an interactive game inspired by titles like the Chrome Dinosaur Game, Flappy Bird, and Geometry Dash. It's developed for the Nexys-A7 100T board, featuring a player-controlled magenta ball. The player's objective is to avoid red squares while scoring points by collecting blue squares. The score is updated and portrayed on 7-segment anode displays of the Nexys board. The game is playable through button inputs on the board, with one button for jumping and another for resetting the game.

## *Required Attachments*
* Nexys-A7 100T Board
* VGA Connector for display output

## *Expected Behavior*
This game requires the VGA connector to display on an external screen. Once connected to the screen and FPGA run synthesis, and implementation, generate bitstream, and program the board to get the game running. Once running, the player, as a magenta ball, can press the middle button (BTNC) to jump. They can also press the top button (BTNU) to reset the game to the initial starting spot. Red and blue squares will quickly and randomly come at the player. If touched, the blue squares will increment the player’s score which is displayed on the board in hexadecimal. Conversely, the red squares will cause the game to reset along with the player’s score. 
  * Gameplay: Control a magenta ball to avoid red squares and collect blue squares.
  * Controls: Use the board buttons to jump and reset the game.
  * Display: The score is displayed on the Nexys board.

## *High-Level Block Diagram*

* Input Processing: Button inputs on the Nexys board.
* Game Logic: Handles player movements, collision detection, and score updates.
* Display Output: VGA output to display the game state.
* Score Display: Seven-segment display on the Nexys board for the score.

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
