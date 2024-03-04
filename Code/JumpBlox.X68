*-----------------------------------------------------------
* Title      : Jumpblox
* Written by : Diarmuid & Isaiah & Stuart
* Date       : 04/03/2024
* Description: An endless runner game in which you have to avoid hitting the red blocks increase both your score and distance.
*              The green block adds health and as your distance increases so does the difficulty level.
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position

TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_HEALTH_INIT EQU   100          ; Players initial health
DMG_INIT    EQU         25          ; Enemy initial damage
HEAL_INIT   EQU         15          ; HEALTH PICKUP INITIAL HEALING VALUE

PLYR_W_INIT EQU         08          ; Players initial Width
PLYR_H_INIT EQU         08          ; Players initial Height

PLYR_DFLT_V EQU         00          ; Default Player Velocity
PLYR_JUMP_V EQU        -12          ; Player Jump Velocity
PLYR_DFLT_G EQU         01          ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False
GND_W       EQU         10000       ; Ground width
GND_H       EQU         01          ; Ground height

HEALTH_H    EQU         10          ; HEALTHBAR HEIGHT

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index
POWERUP_INDEX   EQU     03          ; POWERUP SOUND INDEX

ENMY_W_INIT EQU         08          ; Enemy initial Width
ENMY_H_INIT EQU         08          ; Enemy initial Height

POWERUP_W_INIT   EQU    08          ; POWERUP INITIAL WIDTH
POWERUP_H_INIT   EQU    08          ; POWERUP INITIAL HEIGHT

PLYR_GROWTH_INIT EQU    00          ; Player Initial Growth Value
PLAYER_GROWTH_VALUE EQU 10          ; Amount that player grows by
GROWTH_W      EQU       04          ; GROWTH Width
GROWTH_H      EQU       04          ; GROWTH Height

CLOUD_W_INIT EQU        40          ; Cloud Ellipse Width
CLOUD_H_INIT EQU        20          ; Cloud Ellipse Height

*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode

*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory
    BSR     POWERUP_LOAD            ; LOAD POWERUP SOUND INTO MEMORY
    
    ; INITIALISE LEVEL FLAGS AND LEVEL
    CLR.L   D1
    MOVE.B  #00,        D1
    MOVE.B  D1,         LEVEL2_FLAG
    MOVE.B  D1,         LEVEL3_FLAG
    
    CLR.L   D1
    MOVE.L  #01,        D1
    MOVE.L  D1,         LEVEL
    
    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position
    
    ; Initailise Player Health
    CLR.L   D1                                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_HEALTH_INIT,        D1                ; Init Health
    MOVE.L  D1,                       PLAYER_HEALTH
    
    ; Initailise Damage
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #DMG_INIT,  D1          ; Init Health
    MOVE.L  D1,         DAMAGE
    
    ; INITIALISE HEALING FROM HEALTH POWERUP
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.L  #HEAL_INIT, D1          ; INIT HEALING FORM POWERUPS
    MOVE.L  D1,         HEAL     
    
    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE
    
    ; INITILISE PLAYER DISTANCE
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.L  #00,        D1          ; INIT DISTANCE
    MOVE.L  D1,         DISTANCE
    
    ; Initialise Player Growth Value
    CLR.L   D1                      ; Clearing the contents of D1
    MOVE.L  #PLYR_GROWTH_INIT, D1   ; Init Player Growth
    MOVE.L  D1, PLAYER_GROWTH 
    
    ; Initial Position for GROWTH
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         GROWTH_X    ; GROWTH X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis  
    SUB.L   #30,        D1          ; Brings the position of GROWTH up 15 pixels of the screen
    MOVE.L  D1,         GROWTH_Y    ; GROWTH Y Position

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1         ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position
    
    ; INITIAL COLLISION FLAGS
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.B  #00,         D1          ; MOVE 0 TO D1
    MOVE.B  D1,         ENEMY_C
    MOVE.B  D1,         ENEMY2_C
    MOVE.B  D1,         ENEMY3_C
    MOVE.B  D1,         POWERUP_C
    
    ; Initial Position for Enemy2
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY2_X    ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY2_Y    ; Enemy Y Position
    
    ; Initial Position for Enemy3
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY3_X    ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY3_Y    ; Enemy Y Position
    
    ; Initial Position for POWERUP
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         POWERUP_X   ; POWERUP X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    SUB.W   #35,        D1
    MOVE.L  D1,         POWERUP_Y   ; POWERUP Y Position
    
    ; Inital position for ground line
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  0,   D1                 ; Place Screen width in D1
    MOVE.L  D1,         GND_X       ; GROUNDLINE X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    ADD.W   #09,         D1
    MOVE.L  D1,         GND_Y       ; GROUNDLINE Y Position
    
    ; Inital position for HEALTH BAR
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #340,   D1                     ; Place Screen width in D1
    MOVE.L  D1,         HEALTH_X        ; HEALTHBAR X Position

    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #32,        D1
    MOVE.L  D1,         HEALTH_Y        ; HEALTHBAR Y Position
    
    CLR.L   D1
    MOVE.L  #100,       D1
    MOVE.L  D1,         HEALTH_W
    
    ; Initialise Cloud Position
    CLR.L   D1
    MOVE.W  SCREEN_W,   D1          ; Move Screen Width to D1
    ADD.L   #CLOUD_W_INIT,D1        ; Add Cloud Width to Screen Width
    MOVE.L  D1,         CLOUD_X     ; Move D1 to Cloud X
    
    MOVE.W  SCREEN_H,   D1          ; Move Ground Y to D1
    DIVU    #4,         D1          ; Divide by 2
    MOVE.L  D1,         CLOUD_Y     ; Move D1 to Cloud Y
    

    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)
	
INITIALISE_C_FLAGS:
    ; INITIAL COLLISION FLAGS
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.B  #00,         D1          ; MOVE 0 TO D1
    MOVE.B  D1,         ENEMY_C
    MOVE.B  D1,         ENEMY2_C
    MOVE.B  D1,         ENEMY3_C
    MOVE.B  D1,         POWERUP_C

*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    BSR     DELAY                   ; Delay Running
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_ALL_COLLISIONS    ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    MOVE.L  #$4144201B, D1          ; Setup Data Register (checks for pressing of A,D,Space,Escape)
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  D1,         D2          ; Move last key D1 to D2
    BSR     PROCESS_INPUT           ; Process Key
    RTS

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.B  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.B   #$FF,       CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    LSR     #8,         D2          ; Logical Shift Right (basically accesses 0000XX00 of the long, going from 0000XX00 to 000000XX)
    MOVE.B  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.B   #$FF,       CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    CLR.L   CURRENT_KEY             ; Set Current Key to nothing (no key is pressed if it reaches here)
    BRA     IDLE                    ; Go To Idle If No Keypress
*-----------------------------------------------------------
* Subroutine    : Delay
* Description   : Slows down game by implementing delay
*-----------------------------------------------------------
DELAY:
    MOVE.L #3, D1                   ; Set delay to 3/100ths of a second
    MOVE.L #23, D0                  ; Trap Code for Delay
    TRAP #15                        ; Execute Trap
    RTS                             ; Return to Subroutine
*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ADD.L   D2,         D1          ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 

    ; Move the Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D1          ; Move the Enemy X Position to D0
    CMP.L   #00,        D1          ; Check if enemy is off screen
    BLE     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    BSR     MOVE_ENEMY              ; Move the Enemy
    
    ; Move the Enemy2
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  ENEMY2_X,    D1         ; Move the Enemy X Position to D0
    CMP.L   #00,        D1          ; Check if enemy is off screen
    BLE     RESET_ENEMY2_POSITION   ; Reset Enemy if off Screen
    BSR     MOVE_ENEMY2             ; Move the Enemy
    
    ; Move the Enemy3
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  ENEMY3_X,    D1         ; Move the Enemy X Position to D0
    CMP.L   #00,        D1          ; Check if enemy is off screen
    BLE     RESET_ENEMY3_POSITION   ; Reset Enemy if off Screen
    BSR     MOVE_ENEMY3             ; Move the Enemy
    
    ; Move POWERUP
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D0                      ; Clear the contents of D0
    MOVE.L  POWERUP_X,    D1        ; Move the POWERUP X Position to D1
    CMP.L   #00,        D1          ; Check if POWERUP is off screen
    BLE     RESET_POWERUP_POSITION  ; Reset POWERUP if off Screen
    BSR     MOVE_POWERUP            ; Move the POWERUP
    
    ; INCREASE SCORE AND DISTANCE AS GAME GOES ON
    CLR.L   D1
    ADD.L   #POINTS,     D1         ; Move points upgrade to D1
    ADD.L   PLAYER_SCORE,D1         ; Add to current player score
    MOVE.L  D1, PLAYER_SCORE        ; Update player score in memory
    
    CLR.L   D1
    ADD.L   #POINTS,     D1         ; MOVE POINTS UPGRADE TO D1
    ADD.L   DISTANCE,    D1         ; ADD CURRENT DISTANCE TO D1
    MOVE.L  D1,          DISTANCE   ; MOVE THE UPDATED DISTANCE TO DISTANCE
    
    ; Move the Cloud
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  CLOUD_X,    D1          ; Move the Cloud X Position to D0   
    CMP.L   #00,        D1          ; Check if cloud is off screen
    BLE     RESET_CLOUD_POSITION    ; Reset Cloud if off Screen
    BSR     MOVE_CLOUD              ; Move the Cloud
    
    ;Move GROWTH
    CLR.L   D1                      ; Clear the contents of D1
    MOVE.L  GROWTH_X,    D1         ; Move the GROWTH Position to D1
    CMP.L   #00,       D1
    BLE     RESET_GROWTH_POSITION   ; Reset GROWTH if off Screen
    BSR     MOVE_GROWTH             ; Move the GROWTH Object 

    RTS                             ; Return to subroutine  
    
*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_CLOUD:
    SUB.L   #1,        CLOUD_X      ; Move enemy by X Value
    RTS

*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_CLOUD_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    ADD.L   #CLOUD_W_INIT,D1
    MOVE.L  D1,         CLOUD_X     ; Enemy X Position
    RTS

*-----------------------------------------------------------
* Subroutines   : INCREASE DIFFICULTY LEVEL
* Description   : INCREASES THE DIFFICULTY OF THE GAME AFTER A CERTAIN DISTANCE IS REACHED
*-----------------------------------------------------------

LEVEL2_TEST:                        ; CHECKS IF A DISTANCE OF 600 HAS BEEN REACHED
    MOVE.L  #600,       D1          
    MOVE.L  DISTANCE,   D2
    CMP.L   D1,         D2
    
    BEQ     LEVEL2_UPDATE
    
    RTS
    
LEVEL2_UPDATE:                      ; SWITHCES THE LEVEL2_FLAG WHICH CHANGES ENEMY BEHAVIOUR
    MOVE.B   #1,        LEVEL2_FLAG
    MOVE.L   #02,       LEVEL
    
    RTS
    
CNG_ENEMY:
    MOVE.L  ENEMY_Y,    D1          ; MOVES ENEMY_Y TO D1
    EOR     #%00000000000000000000000000110000, D1      ; CHANGES ENEMY_Y BY 
    MOVE.L  D1,         ENEMY_Y     
    CLR.L   D1
    
    RTS
    
CNG_ENEMY3:
    
    MOVE.L  ENEMY3_Y,   D1
    EOR     #%00000000000000000000000000011000, D1
    MOVE.L  D1,         ENEMY3_Y
    CLR.L   D1
    
    RTS
    
LEVEL3_TEST:                        ; CHECKS IF A DISTANCE OF 1200 HAS BEEN REACHED
    MOVE.L  #1200,       D1          
    MOVE.L  DISTANCE,   D2
    CMP.L   D1,         D2
    
    BEQ     LEVEL3_UPDATE
    
    RTS
    
LEVEL3_UPDATE:                      ; SWITHCES THE LEVEL3_FLAG WHICH CHANGES ENEMY BEHAVIOUR
    MOVE.B   #1,        LEVEL3_FLAG
    MOVE.L   #03,       LEVEL
    
    RTS

*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #05,        ENEMY_X     ; Move enemy by X Value
    BSR LEVEL2_TEST
    BSR LEVEL3_TEST
    
    RTS
    
MOVE_ENEMY2:
    SUB.L   #08,        ENEMY2_X     ; Move enemy by X Value
    RTS
    
MOVE_ENEMY3:
    SUB.L   #03,        ENEMY3_X     ; Move enemy by X Value
    RTS
    
MOVE_POWERUP:
    SUB.L   #02,        POWERUP_X    ; MOVE POWERUP BY X VALUE
    RTS
    
MOVE_GROWTH
    SUB.L   #04,        GROWTH_X     ; Move GROWTH by X Value
    RTS

*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.B  #00,        D1          ; MOVE 0 TO D1
    MOVE.B  D1,         ENEMY_C     ; RESET COLLISION FLAG
    
    TST.B   LEVEL2_FLAG
    BNE     CNG_ENEMY
    
    RTS
    
RESET_ENEMY2_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY2_X    ; Enemy X Position
    
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.B  #00,        D1          ; MOVE 0 TO D1
    MOVE.B  D1,         ENEMY2_C    ; RESET COLLISION FLAG
    

    
    RTS
    
RESET_ENEMY3_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY3_X    ; Enemy X Position
    
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.B  #00,        D1          ; MOVE 0 TO D1
    MOVE.B  D1,         ENEMY3_C    ; RESET COLLISION FLAG
    
    TST.B   LEVEL2_FLAG
    BNE     CNG_ENEMY3
    
    RTS
    
RESET_POWERUP_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         POWERUP_X   ; POWERUP X Position
    
    CLR.L   D1                      ; CLEAR CONTENTS OF D1
    MOVE.B  #00,        D1          ; MOVE 0 TO D1
    MOVE.B  D1,         POWERUP_C   ; RESET COLLISION FLAG
    RTS
    
RESET_GROWTH_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         GROWTH_X    ; Enemy X Position
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_SKY                ; Draw Sky at level 3
    BSR     DRAW_CLOUD              ; Draw Cloud at level 3
    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_GND                ; DRAW GROUND
    BSR     DRAW_GROUND             ; Draw ground at level 2
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    BSR     DRAW_ENEMY2             ; Draw Enemy
    BSR     DRAW_ENEMY3             ; Draw Enemy
    BSR     DRAW_POWERUP            ; DRAW POWERUP
    BSR     DRAW_GROWTH             ; Draw GROWTH
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)

    ; Player Menu Message
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Pen color
    MOVE.B  #80,        D0          ; Task for Pen Color
    TRAP    #15                     ; Trap (Perform action)
    ; Set X, Y, Width and Height
    CLR.L   D1
    MOVE.W  #5,   D1          ; Indent Menu Bar by 1/50th of screen
    MOVE.W  #5,   D2          ; Y - Indent the same amount as on the left and right
    MOVE.W  SCREEN_W,   D3          ; 
    SUB.W   #5,     D3          ; Indent right side by 1/50th of screen, same as the left
    MOVE.W  SCREEN_H,   D4 
    DIVU    #5,         D4          ; Height - Bar Spans 1/5th of Screen
    
    ; Draw Bar
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0901,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player DISTANCE Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     DISTANCE_MSG, A1        ; DISTANCE Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player DISTANCE
    MOVE.B  #TC_CURSR_P, D0         ; Set Cursor Position
    MOVE.W  #$0C02,     D1          ; Col 12, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  DISTANCE,   D1          ; Move DISTANCE to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; LEVEL Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     LEVEL_MSG,      A1      ; LEVEL Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; CURRENT LEVEL
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0903,     D1          ; Col 09, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  LEVEL,     D1          ; 
    TRAP    #15                     ; Trap (Perform action)
    
    ; Show  GROWTH Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2003,     D1          ; Col 20, Row 3
    TRAP    #15                     ; Trap (Perform action)    
    LEA     GROWTH_MSG, A1          ; Move Health Message to D1
    MOVE.B  #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ;Player GROWTH
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2903,     D1          ; Col 29, Row 3
    TRAP    #15                     ; Trap (Perform action) 
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_GROWTH, D1       ; Move Health to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3001,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Health Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2002,     D1          ; Col 20, Row 2
    TRAP    #15                     ; Trap (Perform action)    
    LEA     HEALTH_MSG, A1          ; Move Health Message to D1
    MOVE.B  #13,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)
    
    ; Show Health BAR   
    BSR     DRAW_H_BAR

    RTS  
    
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1              ; Place Screen width in D1
    DIVU    #02,        D1              ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y        ; Reset the Player Y Position
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1              ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY   ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND     ; Player is on Ground
    RTS

*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND     ; Player if off Ground
    RTS                                 ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
JUMP:
    MOVE.L  #$20,   CURRENT_KEY
    CMP.L   #GND_TRUE,PLYR_ON_GND       ; Player is on the Ground ?
    BEQ     PERFORM_JUMP                ; Do Jump
    BRA     JUMP_DONE               
PERFORM_JUMP:
    BSR     PLAY_JUMP                   ; Play jump sound
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY  ; Set the players velocity to true
    RTS                                 ; Return to subroutine
JUMP_DONE:
    RTS                                 ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:
    BEQ     PLAY_RUN                    ; Play Run Wav
    RTS                                 ; Return to subroutine

*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1              ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1              ; Assign it INDEX
    MOVE    #71,        D0              ; Load into memory
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1              ; Load Sound INDEX
    MOVE    #72,        D0              ; Play Sound
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1              ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1              ; Assign it INDEX
    MOVE    #71,        D0              ; Load into memory
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine

PLAY_JUMP:
    MOVE    #76,        D0              ; STOPS ALL PREVIOUS SOUNDS TO ALLOW JUMP TO PLAY
    MOVE.L  #3,         D2
    TRAP    #15
    
    MOVE    #JMP_INDEX, D1              ; Load Sound INDEX
    MOVE    #72,        D0              ; Play Sound
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1              ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1              ; Assign it INDEX
    MOVE    #71,        D0              ; Load into memory
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine

PLAY_OPPS:
    MOVE    #76,        D0              ; STOP ALL SOUNDS TO ALLOW OPPS TO PLAY
    MOVE.L  #3,         D2
    TRAP    #15
    
    MOVE    #OPPS_INDEX,D1              ; Load Sound INDEX
    MOVE    #72,        D0              ; Play Sound
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine
    
POWERUP_LOAD:
    LEA     POWERUP_WAV,    A1          ; Load Wav File into A1
    MOVE    #POWERUP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,            D0          ; Load into memory
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine
    
PLAY_POWERUP:
    MOVE    #76,        D0              ; STOP ALL SOUNDS TO ALLOW POWERUP TO PLAY
    MOVE.L  #3,         D2
    TRAP    #15
    
    MOVE    #POWERUP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,            D0          ; Play Sound
    TRAP    #15                         ; Trap (Perform action)
    RTS                                 ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1              ; Set Pen color
    MOVE.B  #80,        D0              ; Task for Pen Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,        D0              ; Task for Fill Color
    TRAP    #15         D0              ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1              ; X
    MOVE.L  PLAYER_Y,   D2              ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3          ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4          ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0              ; Draw Player
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL                  ; Clears Fill Color
    RTS                                 ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Clear Fill
* Description   : Clear Fill Color (is necessary after filling player/enemy)
*-----------------------------------------------------------
CLEAR_FILL:
    MOVE.L  #BLACK,     D1              ; Set Fill Color
    MOVE.B  #81,        D0              ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform Action)
    RTS
*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #RED,           D1          ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,        D1          ; X
    MOVE.L  ENEMY_Y,        D2          ; Y
    MOVE.L  ENEMY_X,        D3
    ADD.L   #ENMY_W_INIT,   D3          ; Width
    MOVE.L  ENEMY_Y,        D4 
    ADD.L   #ENMY_H_INIT,   D4          ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0              ; Draw Enemy
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                                 ; Return to subroutine
    
DRAW_ENEMY2:
    ; Set Pixel Colors
    MOVE.L  #RED,           D1          ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY2_X,        D1         ; X
    MOVE.L  ENEMY2_Y,        D2         ; Y
    MOVE.L  ENEMY2_X,        D3
    ADD.L   #ENMY_W_INIT,   D3          ; Width
    MOVE.L  ENEMY2_Y,        D4 
    ADD.L   #ENMY_H_INIT,   D4          ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0              ; Draw Enemy
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS   
    
DRAW_ENEMY3:
    ; Set Pixel Colors
    MOVE.L  #RED,           D1          ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY3_X,        D1         ; X
    MOVE.L  ENEMY3_Y,        D2         ; Y
    MOVE.L  ENEMY3_X,        D3
    ADD.L   #ENMY_W_INIT,   D3          ; Width
    MOVE.L  ENEMY3_Y,        D4 
    ADD.L   #ENMY_H_INIT,   D4          ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0              ; Draw Enemy
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS   
    
DRAW_POWERUP:
    ; Set Pixel Colors
    MOVE.L  #GREEN,           D1        ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  POWERUP_X,          D1      ; X
    MOVE.L  POWERUP_Y,          D2      ; Y
    MOVE.L  POWERUP_X,          D3
    ADD.L   #POWERUP_W_INIT,    D3      ; Width
    MOVE.L  POWERUP_Y,          D4 
    ADD.L   #POWERUP_H_INIT,    D4      ; Height
    
    ; Draw POWERUP    
    MOVE.B  #87,        D0              ; Draw POWERUP
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                                 ; Return to subroutine
    
DRAW_GROWTH:
    ; Set Pixel Colors
    MOVE.L  #GOLD,      D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0          ; Fills Rectangle with the same color as the outlines
    TRAP    #15

    ; Set X, Y, Width and Height
    MOVE.L  GROWTH_X,    D1          ; X
   ; SUB.L   #3,        D1
    MOVE.L  GROWTH_Y,    D2          ; Y
    ;SUB.L   #3,        D2
    MOVE.L  GROWTH_X,    D3      
    ADD.L   #GROWTH_W,   D3          ; Width
    MOVE.L  GROWTH_Y,    D4          
    ADD.L   #GROWTH_H,   D4          ; Height
    
    ; Draw GROWTH
    MOVE.B  #87,        D0          ; Draw GROWTH
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
DRAW_GND:
        ; Set Pixel Colors
    MOVE.L  #RED,         D1            ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  GND_X,        D1            ; X
    MOVE.L  GND_Y,        D2            ; Y
    MOVE.L  GND_X,        D3
    ADD.L   #GND_W,       D3            ; Width
    MOVE.L  GND_Y,        D4 
    ADD.L   #GND_H,       D4                ; Height
    
    ; Draw GROUND    
    MOVE.B  #87,        D0              ; Draw GROUND
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS  
    
DRAW_H_BAR:

    ; Set Pixel Colors
    MOVE.L  #RED,           D1          ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)
    
    ; Set X, Y, Width and Height
    MOVE.L  HEALTH_X,        D1         ; X
    MOVE.L  HEALTH_Y,        D2         ; Y
    MOVE.L  HEALTH_X,        D3
    ADD.L   #100,            D3         ; Width
    MOVE.L  HEALTH_Y,        D4 
    ADD.L   #10,             D4         ; Height
    
    ; Draw HEALTHBAR RED   
    MOVE.B  #87,             D0         ; Draw HEALTHBAR
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    
    ; Set Pixel Colors
    MOVE.L  #GREEN,         D1          ; Set Background color
    MOVE.B  #80,            D0          ; Task for Background Color
    TRAP    #15                         ; Trap (Perform action)
    MOVE.B  #81,            D0          ; Task for Fill Color
    TRAP    #15                         ; Trap (Perform action)
    
    ; Set X, Y, Width and Height
    MOVE.L  HEALTH_X,        D1         ; X
    MOVE.L  HEALTH_Y,        D2         ; Y
    MOVE.L  HEALTH_X,        D3
    ADD.L   HEALTH_W,        D3         ; Width
    MOVE.L  HEALTH_Y,        D4 
    ADD.L   #HEALTH_H,       D4         ; Height
    
    ; Draw HEALTHBAR GREEN   
    MOVE.B  #87,             D0         ; Draw HEALTHBAR
    TRAP    #15                         ; Trap (Perform action)
    BSR     CLEAR_FILL
    
    RTS 
*-----------------------------------------------------------
* Subroutine    : Draw Ground
* Description   : Draw Ground
*-----------------------------------------------------------
DRAW_GROUND:
    TST.L   LEVEL2_FLAG
    BEQ     SKIP_DRAW
    ; Set Pixel Colors
    MOVE.L  #GREEN,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0          ; Task for Fill Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    CLR.L   D1
    CLR.L   D2
    CLR.L   D3
    CLR.L   D4
    MOVE.L  #0,         D1          ; LEFTMOST X
    MOVE.W  SCREEN_H,   D2          ; UPPER Y
    DIVU    #2,         D2
    ADD.L   #9,         D2
    MOVE.W  SCREEN_W,   D3          ; RIGHTMOST X
    MOVE.W  SCREEN_H,   D4          ; LOWER Y
    
    ; Draw Ground    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    
    ; Set Pixel Colors
    MOVE.L  #DARK_GREEN,D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0          ; Task for Fill Color
    TRAP    #15                     ; Trap (Perform action)
    
    ; Alter dimensions from above
    MOVE.L  #0,         D1
    MOVE.L  D2,         D4
    ADD.L   #20,        D4
    
    ; Draw Shading
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine
    
SKIP_DRAW:
    RTS
*-----------------------------------------------------------
* Subroutine    : Draw Sky
* Description   : Draw Sky Square
*-----------------------------------------------------------
DRAW_SKY:
    TST.B   LEVEL3_FLAG
    BEQ     SKIP_DRAW
    ; Set Pixel Colors
    MOVE.L  #SKY_BLUE,  D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0          ; Task for Fill Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  #0,         D1          ; X
    CLR.L   D2
    MOVE.L  #0,         D2
    MOVE.W  SCREEN_W,    D3         ; Width
    MOVE.W  SCREEN_H,    D4         ; Sky starts at ground y
    DIVU    #2,         D4
    ADD.L   #9,     D4
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Cloud
* Description   : Draw Cloud Square
*-----------------------------------------------------------
DRAW_CLOUD:
    TST.B   LEVEL3_FLAG
    BEQ     SKIP_DRAW
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Pen color
    MOVE.B  #80,        D0          ; Task for Pen Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81,        D0          ; Task for Fill Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  CLOUD_X,   D1          ; X
    MOVE.L  CLOUD_Y,   D2          ; Y
    MOVE.L  CLOUD_X,   D3
    SUB.L   #CLOUD_W_INIT,   D3      ; Width
    MOVE.L  CLOUD_Y,   D4 
    ADD.L   #CLOUD_H_INIT,   D4      ; Height
    
    ; Draw Cloud
    MOVE.B  #88,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    BSR     CLEAR_FILL              ; Clears Fill Color
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Collision Checks
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_ALL_COLLISIONS:
    BSR     CHECK_COLLISIONS         ; CHECKING FOR COLLISIONS WITH ENEMIES
    BSR     CHECK_COLLISIONS2
    BSR     CHECK_COLLISIONS3
    BSR     CHECK_POWERUP_COLLISIONS ; CHECKING FOR POWERUP COLLISIONS 
    BSR     CHECK_GROWTH_COLLISIONS
    
    RTS
    
CHECK_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    LEA     ENEMY_C,     A2         ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,D2          ; Set Enemy width X + Width    ADDED #
    CMP.L   D2,         D1          ; Do the Overlap ?              SWAPPED D2 AND D1
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:     ; Check player is not           ADDED #
    ADD.L   #PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal    CHANGED BGE TO BLE
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
    
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Y to D2
    SUB.L   #ENMY_H_INIT,D2          ; Set Enemy Height to D2       ADDED #, ADD CHANGED TO SUB
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:     ; Less than or Equal ?          CHANGED ADD TO SUB
    SUB.L   #PLYR_H_INIT,D1         ; Add Player Height to D1       ADDED #
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
COLLISION_CHECK_DONE:               
    
    RTS                             ; Return to subroutine

COLLISION:
    TST.B   (A2)                    ; TESTS THE COLLISION FLAG TO AVOID MULTIPLE COLLISIONS
    BNE     COLLISION_CHECK_DONE
    BSR     PLAY_OPPS               ; Play Opps Wav
    LEA     DAMAGE, A1
    MOVE.L  (A1), D1
    
    
    
    SUB.L   D1, PLAYER_HEALTH       ; Subtract damage from player health
    SUB.L   D1, HEALTH_W
    MOVE.B  #01,        (A2)        ; SET COLLISION FLAG TO 1 (A HIT HAS BEEN REGISTERED)
    
    
    TST.L   PLAYER_HEALTH           ; TESTS IF PLAYER HEALTH IS 0
    BLE     EXIT                    ; IF SO, GAME OVER
    
    MOVE.L  PLAYER_SCORE,   D1      ; MOVE PLAYER_SCORE TO D1
    MOVE.L  #1000,          D2      ; MOVE 1000 TO D2
    CMP.L   D1,             D2      ; COMPARE PLAYER_SCORE TO 1000
    
    BGE     UPDATE_LOWSCORE         ; IF 1000 IS GREATER THAN PLAYER_SCORE, RESET SCORE TO 0 (THIS PREVENTS NEGATIVE SCORE)
    
    SUB.L   #1000,   PLAYER_SCORE   ; IF PLAYER_SCORE IS GREATER THAN 1000, SUBTRACT 1000 FROM PLAYER_SCORE UPON A COLLISION
    
    RTS                             ; Return to subroutine
    
UPDATE_LOWSCORE:
        MOVE.L  #00, PLAYER_SCORE       ; Reset Player Score
        
        RTS
    
POWERUP_COLLISION:
    CLR.L   D1
    CLR.L   D2
    
    TST.B   (A2)                    ; TESTS THE COLLISION FLAG TO AVOID MULTIPLE COLLISIONS
    BNE     COLLISION_CHECK_DONE
    
    MOVE.L  PLAYER_HEALTH,   D1     ; MOVING PLAYER HEALTH TO D1
    MOVE.L  #100,            D2     ; MOVING 100 (MAXIMUM HEALTH ALLOWED) TO D2
    CMP.L   D1,              D2     ; CHECKING IF PLAYER IS AT MAXIMUM HEALTH
    BLE     COLLISION_CHECK_DONE
    
    BSR     PLAY_POWERUP            ; Play Opps Wav
    LEA     HEAL,       A1
    MOVE.L  (A1),       D1
    
    ADD.L   D1, PLAYER_HEALTH       ; ADD HEALTH TO player health
    ADD.L   D1, HEALTH_W
    
    CMP.L   D1,         D2          ; CHECKING IF PLAYER IS AT MAXIMUM HEALTH
    BGE     PREVENT_OVERHEAL
    
    MOVE.B  #01,        (A2)        ; SET COLLISION FLAG TO 1 (A HIT HAS BEEN REGISTERED)
    
    RTS                             ; Return to subroutine
    
PREVENT_OVERHEAL:
    MOVE.L  #100,       PLAYER_HEALTH   ; SET HEALTH TO 100
    MOVE.L  #100,       HEALTH_W        ; SET HEALTHBAR WIDTH TO 100
    
    RTS
    
CHECK_COLLISIONS2:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    LEA     ENEMY2_C,   A2          ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_ENEMY2_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY2_X,    D2         ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,D2         ; Set Enemy width X + Width
    CMP.L   D2,         D1          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY2_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_ENEMY2_X:    ; Check player is not  
    ADD.L   #PLYR_W_INIT,D1         ; Move Player Width to D1
    MOVE.L  ENEMY2_X,    D2         ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_ENEMY2_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_ENEMY2_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY2_Y,    D2         ; Move Enemy Y to D2
    SUB.L   #ENMY_H_INIT,D2         ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY2_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY2_Y:    ; Less than or Equal ?
    SUB.L   #PLYR_H_INIT,D1         ; Add Player Height to D1
    MOVE.L  ENEMY2_Y,    D2         ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
CHECK_COLLISIONS3:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    LEA     ENEMY3_C,     A2        ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_ENEMY3_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY3_X,    D2         ; Move Enemy X to D2
    ADD.L   #ENMY_W_INIT,D2         ; Set Enemy width X + Width
    CMP.L   D2,         D1          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY3_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_ENEMY3_X:    ; Check player is not  
    ADD.L   #PLYR_W_INIT,D1         ; Move Player Width to D1
    MOVE.L  ENEMY3_X,    D2         ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_ENEMY3_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_ENEMY3_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY3_Y,    D2         ; Move Enemy Y to D2
    SUB.L   #ENMY_H_INIT,D2         ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY3_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY3_Y:    ; Less than or Equal ?
    SUB.L   #PLYR_H_INIT,D1         ; Add Player Height to D1
    MOVE.L  ENEMY3_Y,    D2         ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
CHECK_POWERUP_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2  
    LEA     POWERUP_C,     A2       ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_POWERUP_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  POWERUP_X,    D2        ; Move Enemy X to D2
    ADD.L   #POWERUP_W_INIT,D2      ; Set Enemy width X + Width
    CMP.L   D2,         D1          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_POWERUP_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_POWERUP_X:   ; Check player is not  
    ADD.L   #PLYR_W_INIT,D1         ; Move Player Width to D1
    MOVE.L  POWERUP_X,    D2        ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BLE     PLAYER_Y_LTE_TO_POWERUP_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_POWERUP_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  POWERUP_Y,    D2        ; Move Enemy Y to D2
    SUB.L   #POWERUP_H_INIT,D2      ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_POWERUP_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_POWERUP_Y:   ; Less than or Equal ?
    SUB.L   #PLYR_H_INIT,D1         ; Add Player Height to D1
    MOVE.L  POWERUP_Y,    D2        ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     POWERUP_COLLISION       ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
CHECK_GROWTH_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
PLAYER_X_LTE_TO_GROWTH_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  GROWTH_X,    D2         ; Move GROWTH X to D2
    ADD.L   GROWTH_W,D2             ; Set GROWTH X + Width
    SUB.L   #05,D2                  ; Subtracting 10 from D2 makes the collision more lenient
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_GROWTH_X  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_GROWTH_X:    ;  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  GROWTH_X,    D2         ; Move GROWTH X to D2
    ADD.L   #05,D2                  ; Adding 10 to D2 makes the collision more lenient
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_GROWTH_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_GROWTH_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  GROWTH_Y,    D2         ; Move GROWTH Y to D2
    ADD.L   GROWTH_H,D2             ; Set GROWTH Height to D2
    SUB.L   #15,        D2          ; Brings the collision of the lower part of the rectangle upwards
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_GROWTH_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_GROWTH_Y:    ; Less than or Equal ?
    ADD.L   PLYR_H_INIT,D1          ; Add Player Height to D1
    MOVE.L  GROWTH_Y,    D2         ; Move GROWTH Height to D2
    SUB.L   #15,        D2          ; Brings the collision of the upper part of the rectangle upwards
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     GROWTH_COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
                            
GROWTH_COLLISION:
    ADD.L   #01,  PLAYER_GROWTH             ;Subtracting the enemy damage from the player's health
    RTS                                     ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:

    ; Clear screen
    MOVE.B  #TC_CURSR_P,D0          ; SET CURSOR POSITION
    MOVE.W  #$FF00,     D1
    TRAP    #15                     ; Trap (Perform action)
    
    
    ; WRITE GAME OVER MESSAGE
    MOVE    #21,        D0
    MOVE.L  #RED,       D1          ; SETTING FONT COLOUR
    MOVE.L  #$01090001, D2          ; FONT : FIXEDSYS, SIZE : 9, BOLD
    TRAP    #15                     ; TRAP (PERFORM ACTION)
    
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1E0D,     D1          ; Col 18, Row 13
    TRAP    #15                     ; Trap (Perform action)    
    LEA     GAME_OVER_MSG, A1       ; Move GAME OVER Message to D1
    MOVE.B  #13,        D0          ; Display the contents of D1
    TRAP    #15  

    ; Player Score Message
    MOVE    #21,        D0
    MOVE.L  #WHITE,     D1          ; SETTING FONT COLOUR
    MOVE.L  #$01090000, D2          ; FONT : FIXEDSYS, SIZE : 9, BOLD
    TRAP    #15                     ; TRAP (PERFORM ACTION)
    
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$220F,     D1          ; Col 22, Row 15
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2A0F,     D1          ; Col 30, Row 15
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player DISTANCE Message
    MOVE    #21,        D0
    MOVE.L  #WHITE,     D1          ; SETTING FONT COLOUR
    MOVE.L  #$01090000, D2          ; FONT : FIXEDSYS, SIZE : 9, BOLD
    TRAP    #15                     ; TRAP (PERFORM ACTION)
    
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2111,     D1          ; Col 21, Row 11
    TRAP    #15                     ; Trap (Perform action)
    LEA     DISTANCE_MSG, A1        ; DISTANCE Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player DISTANCE Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2B11,     D1          ; Col 31 , Row 11
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  DISTANCE,   D1          ; Move DISTANCE to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player GOLD Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2113,     D1          ; Col 32, Row 12
    TRAP    #15                     ; Trap (Perform action)
    LEA     GAME_OVER_MSG2,      A1 ; Second Game Over Message to show gold
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player GROWTH
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2B13,     D1          ; Col 30, Row 12
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_GROWTH,   D1     ; Move Player_Growth to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Enable back buffer
    MOVE.B  #94,        D0          ; This copies the off screen buffer to the on screen buffer
    TRAP    #15
    
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------
SCORE_MSG       DC.B    'Score : ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode : ', 0     ; Keycode Message
HEALTH_MSG      DC.B    'Health : ',0       ; Health Message
JUMP_MSG        DC.B    'Jump....', 0       ; Jump Message
GROWTH_MSG      DC.B    'Gold:', 0        ; Wealth Message
GAME_OVER_MSG2  DC.B    'Gold :', 0

DISTANCE_MSG    DC.B    'Distance :', 0      ; Distance Message
LEVEL_MSG       DC.B    'Level :',0          ; DIFFICULTY LEVEL MESSAGE

GAME_OVER_MSG   DC.B    'GAME OVER!', 0     ; GAME OVER MESSAGE

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
BLACK           EQU     $00000000
GREEN           EQU     $0000FF00
GOLD            EQU     $0000D7FF
BLUE            EQU     $00FF0000
DARK_GREEN      EQU     $00009900
SKY_BLUE        EQU     $00FFCC99

*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_HEALTH   DS.L    01  ; Reserve Space for Player Health
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score
DISTANCE        DS.L    01  ; RESERVE SPACE FOR PLAYER DISTANCE

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    01  ; Reserve Space for Enemy Y Position
ENEMY_C         DS.B    01  ; RESERVES SPACE FOR ENEMY COLLISION FLAG

ENEMY2_X        DS.L    01  ; RESERVE SPACE FOR ENEMY2 X POSITION
ENEMY2_Y        DS.L    01  ; RESERVE SPACE FOR EMEMY2 Y POSITION
ENEMY2_C        DS.B    01  ; RESERVES SPACE FOR ENEMY2 COLLISION FLAG

ENEMY3_X        DS.L    01  ; RESERVE SPACE FOR ENEMY3 X POSITION
ENEMY3_Y        DS.L    01  ; RESERVE SPACE FOR ENEMY3 X POSITION
ENEMY3_C        DS.B    01  ; RESERVES SPACE FOR ENEMY3 COLLISION FLAG

POWERUP_X       DS.L    01  ; RESERVE SPACE FOR POWERUP X POSITION
POWERUP_Y       DS.L    01  ; RESERVE SPACE FOR POWERUP Y POSITION
POWERUP_C       DS.B    01  ; RESERVES SPACE FOR POWERUP COLLISION FLAG

GROWTH_X        DS.L    01  ; Reserve Space for GROWTH X Position
GROWTH_Y        DS.L    01  ; Reserve Space for GROWTH Y Position
PLAYER_GROWTH   DS.L    01  ; Reserve Space for Player Growth

GND_X           DS.L    01  ; RESERVE SPACE FOR GROUND X POSITION
GND_Y           DS.L    01  ; RESERVE SPACE FOE GROUND Y POSITION

HEALTH_X        DS.L    01  ; RESERVE SPACE FOR HEALTHBAR X
HEALTH_Y        DS.L    01  ; RESERVE SPACE FOR HEALTHBAR Y
HEALTH_W        DS.L    01  ; RESERVE SPACE FOR HEALTHBAR WIDTH

DAMAGE          DS.L    01  ; Reserve Space for damage
HEAL            DS.L    01  ; RESERVE SPACE FOR HEAL POWERUP

LEVEL2_FLAG     DS.B    01  ; RESERVE SPACE FOR THE LEVEL 2 FLAG
LEVEL3_FLAG     DS.B    01  ; RESERVE SPACE FOR THE LEVEL 3 FLAG
LEVEL           DS.L    01  ; RESERVE SPACE FOR LEVEL

CLOUD_X         DS.L    01  ; Reserve Space for Cloud X Position
CLOUD_Y         DS.L    01  ; Reserve Space for Cloud Y Position

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given    
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to           
* generate and Audacity to convert MP3 to WAV                                                      
*-----------------------------------------------------------                                  
JUMP_WAV        DC.B    'jump.wav',0            ; Jump Sound
RUN_WAV         DC.B    'steps.wav',0           ; Run Sound          
OPPS_WAV        DC.B    'hit.wav',0             ; Collision Opps
POWERUP_WAV     DC.B    'powerup.wav',0         ; POWERUP SOUND

    END    START        ; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
