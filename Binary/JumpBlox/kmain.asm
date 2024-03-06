*-----------------------------------------------------------
* Title      :: Jumpblox
* Written by :: Diarmuid & Isaiah & Stuart
* Date       :: 04/03/2024
* Description:: An endless runner game in which you have to avoid hitting the red blocks increase both your score and distance.
*              The green block adds health and as your distance increases so does the difficulty level.
*-----------------------------------------------------------
        ORG     $1000
kmain::

*-----------------------------------------------------------
* Section       :: Trap Codes
* Description   :: Trap Codes used throughout StarterKit
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
* Section       :: Charater Setup
* Description   :: Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_HEALTH_INIT EQU   100          ; Players initial health
DMG_INIT    EQU         25          ; Enemy initial damage
HEAL_INIT   EQU         15          ; HEALTH PICKUP INITIAL HEALING VALUE

SCREEN_R_M  EQU         37
SCREEN_C_M  EQU         180

PLYR_W_INIT EQU         05          ; Players initial Width
PLYR_H_INIT EQU         03          ; Players initial Height

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

ENMY_W_INIT EQU         05          ; Enemy initial Width
ENMY_H_INIT EQU         03          ; Enemy initial Height

POWERUP_W_INIT   EQU    05          ; POWERUP INITIAL WIDTH
POWERUP_H_INIT   EQU    03          ; POWERUP INITIAL HEIGHT

PLYR_GROWTH_INIT EQU    00          ; Player Initial Growth Value
PLAYER_GROWTH_VALUE EQU 10          ; Amount that player grows by
GROWTH_W      EQU       04          ; GROWTH Width
GROWTH_H      EQU       04          ; GROWTH Height


*-----------------------------------------------------------
* Section       :: Game Stats
* Description   :: Points
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added

*-----------------------------------------------------------
* Section       :: Keyboard Keys
* Description   :: Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode

*-----------------------------------------------------------
* Subroutine    :: Initialise
* Description   :: Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE::
    ; Initialise Sounds
    bsr     RUN_LOAD                ; Load Run Sound into Memory
    bsr     JUMP_LOAD               ; Load Jump Sound into Memory
    bsr     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory
    bsr     POWERUP_LOAD            ; LOAD POWERUP SOUND INTO MEMORY
    
    ; INITIALISE LEVEL FLAGS AND LEVEL
    clr.l   D1
    move.b  #00,D1
    move.b  D1,LEVEL2_FLAG
    move.b  D1,LEVEL3_FLAG
    move.b  #1,MOVE_POWER_FLG
    move.b  #1,MOVE_GROWTH_FLG
    
    clr.l   D1
    move.l  #01,D1
    move.l  D1,LEVEL
    
    ; Screen Size
    move.b  #37,SCREEN_H             ; place screen height in memory location
    move.b  #180,SCREEN_W             ; place screen width in memory location

    ; Place the Player at the center of the screen
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on X Axis
    move.l  D1,PLAYER_X             ; Players X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis
    move.l  D1,PLAYER_Y             ; Players Y Position
    
    ; Initailise Player Health
    clr.l   D1                                          ; Clear contents of D1 (XOR is faster)
    move.l  #PLYR_HEALTH_INIT,D1                        ; Init Health
    move.l  D1,PLAYER_HEALTH
    
    ; Initailise Damage
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.l  #DMG_INIT,D1            ; Init Health
    move.l  D1,DAMAGE
    
    ; INITIALISE HEALING FROM HEALTH POWERUP
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.l  #HEAL_INIT,D1           ; INIT HEALING FORM POWERUPS
    move.l  D1,HEAL     
    
    ; Initialise Player Score
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.l  #00,D1                  ; Init Score
    move.l  D1,PLAYER_SCORE
    
    ; INITILISE PLAYER DISTANCE
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.l  #00,D1                  ; INIT DISTANCE
    move.l  D1,DISTANCE
    
    ; Initialise Player Growth Value
    clr.l   D1                      ; Clearing the contents of D1
    move.l  #PLYR_GROWTH_INIT,D1    ; Init Player Growth
    move.l  D1,PLAYER_GROWTH 
    
    ; Initial Position for GROWTH
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,GROWTH_X             ; GROWTH X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis  
    sub.l   #30,D1                  ; Brings the position of GROWTH up 15 pixels of the screen
    move.l  D1,GROWTH_Y             ; GROWTH Y Position

    ; Initialise Player Velocity
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  #PLYR_DFLT_V,D1         ; Init Player Velocity
    move.l  D1,PLYR_VELOCITY

    ; Initialise Player Gravity
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.l  #PLYR_DFLT_G,D1         ; Init Player Gravity
    move.l  D1,PLYR_GRAVITY

    ; Initialize Player on Ground
    move.l  #GND_TRUE,PLYR_ON_GND   ; Init Player on Ground

    ; Initial Position for Enemy
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,ENEMY_X              ; Enemy X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis
    move.l  D1,ENEMY_Y              ; Enemy Y Position
    
    ; INITIAL COLLISION FLAGS
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.b  #00,D1                  ; move 0 TO D1
    move.b  D1,ENEMY_C
    move.b  D1,ENEMY2_C
    move.b  D1,ENEMY3_C
    move.b  D1,POWERUP_C
    
    ; Initial Position for Enemy2
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,ENEMY2_X             ; Enemy X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis
    move.l  D1,ENEMY2_Y             ; Enemy Y Position
    
    ; Initial Position for Enemy3
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,ENEMY3_X             ; Enemy X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis
    move.l  D1,ENEMY3_Y             ; Enemy Y Position
    
    ; Initial Position for POWERUP
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,POWERUP_X            ; POWERUP X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis
    sub.w   #35,D1
    move.l  D1,POWERUP_Y            ; POWERUP Y Position
    
    ; Inital position for ground line
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.l  #0,D1                    ; Place Screen width in D1
    move.l  D1,GND_X                ; GROUNDLINE X Position

    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_H,D1             ; Place Screen width in D1
    divu    #02,D1                  ; divide by 2 for center on Y Axis
    add.w   #09,D1
    move.l  D1,GND_Y                ; GROUNDLINE Y Position

    ; Clear the screen (see easy 68k help)
    bsr     CLEAR_SCREEN
	
INITIALISE_C_FLAGS::
    ; INITIAL COLLISION FLAGS
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.b  #00,D1                  ; move 0 TO D1
    move.b  D1,ENEMY_C
    move.b  D1,ENEMY2_C
    move.b  D1,ENEMY3_C
    move.b  D1,POWERUP_C

*-----------------------------------------------------------
* Subroutine    :: Game
* Description   :: Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME::
    bsr     PLAY_RUN                ; Play Run Wav
GAMELOOP::
    ; Main Gameloop
    bsr     INPUT                   ; Check Keyboard Input
    bsr     UPDATE                  ; Update positions and points
    bsr     IS_PLAYER_ON_GND        ; Check if player is on ground
    bsr     CHECK_ALL_COLLISIONS    ; Check for Collisions
    bsr     DRAW                    ; Draw the Scene
    bra     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    :: Input
* Description   :: Process Keyboard Input
*-----------------------------------------------------------
INPUT::
    ; Process Input
    bsr     READCHAR
    bsr     PROCESS_INPUT           ; Process Key
    rts

*-----------------------------------------------------------
* Subroutine    :: Process Input
* Description   :: Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT::
    move.b  D0,CURRENT_KEY          ; Put Current Key in Memory
    cmp.b   #$1B,CURRENT_KEY        ; Is Current Key Escape
    beq     EXIT                    ; Exit if Escape
    cmp.b   #$20,CURRENT_KEY        ; Is Current Key Spacebar
    beq     JUMP                    ; Jump
    clr.l   CURRENT_KEY             ; Set Current Key to nothing (no key is pressed if it reaches here)
    bra     IDLE                    ; Go To Idle If No Keypress
*-----------------------------------------------------------
* Subroutine    :: Update
* Description   :: Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE::
    ; Update the Players Positon based on Velocity and Gravity
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.l  PLYR_VELOCITY,D1        ; Fetch Player Velocity
    move.l  PLYR_GRAVITY,D2         ; Fetch Player Gravity
    add.l   D2,D1                   ; Add Gravity to Velocity
    move.l  D1,PLYR_VELOCITY        ; Update Player Velocity
    add.l   PLAYER_Y,D1             ; Add Velocity to Player
    move.l  D1,PLAYER_Y             ; Update Players Y Position 

    ; Move the Enemy
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    clr.l   D0                      ; Clear the contents of D0
    move.l  ENEMY_X,D1              ; Move the Enemy X Position to D0
    cmp.l   #00,D1                  ; Check if enemy is off screen
    ble     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    bsr     MOVE_ENEMY              ; Move the Enemy
    
    ; Move the Enemy2
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    clr.l   D0                      ; Clear the contents of D0
    move.l  ENEMY2_X,D1             ; Move the Enemy X Position to D0
    cmp.l   #00,D1                  ; Check if enemy is off screen
    ble     RESET_ENEMY2_POSITION   ; Reset Enemy if off Screen
    bsr     MOVE_ENEMY2             ; Move the Enemy
    
    ; Move the Enemy3
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    clr.l   D0                      ; Clear the contents of D0
    move.l  ENEMY3_X,D1             ; Move the Enemy X Position to D0
    cmp.l   #00,D1                  ; Check if enemy is off screen
    ble     RESET_ENEMY3_POSITION   ; Reset Enemy if off Screen
    bsr     MOVE_ENEMY3             ; Move the Enemy
    
    ; Move POWERUP
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    clr.l   D0                      ; Clear the contents of D0
    move.l  POWERUP_X,D1            ; Move the POWERUP X Position to D1
    cmp.l   #00,D1                  ; Check if POWERUP is off screen
    ble     RESET_POWERUP_POSITION  ; Reset POWERUP if off Screen
    bsr     MOVE_POWERUP            ; Move the POWERUP
    
    ; INCREASE SCORE AND DISTANCE AS GAME GOES ON
    clr.l   D1
    add.l   #POINTS,D1              ; Move points upgrade to D1
    add.l   PLAYER_SCORE,D1         ; Add to current player score
    move.l  D1,PLAYER_SCORE         ; Update player score in memory
    
    clr.l   D1
    add.l   #POINTS,D1              ; move POINTS UPGRADE TO D1
    add.l   DISTANCE,D1             ; ADD CURRENT DISTANCE TO D1
    move.l  D1,DISTANCE             ; move THE UPDATED DISTANCE TO DISTANCE
    
    ;Move GROWTH
    clr.l   D1                      ; Clear the contents of D1
    move.l  GROWTH_X,D1             ; Move the GROWTH Position to D1
    cmp.l   #00,D1
    ble     RESET_GROWTH_POSITION   ; Reset GROWTH if off Screen
    bsr     MOVE_GROWTH             ; Move the GROWTH Object 

    rts                             ; Return to subroutine  

*-----------------------------------------------------------
* Subroutines   :: INCREASE DIFFICULTY LEVEL
* Description   :: INCREASES THE DIFFICULTY OF THE GAME AFTER A CERTAIN DISTANCE IS REACHED
*-----------------------------------------------------------

LEVEL2_TEST::                        ; CHECKS IF A DISTANCE OF 600 HAS BEEN REACHED
    move.l  #600,D1          
    move.l  DISTANCE,D2
    cmp.l   D1,D2
    
    beq     LEVEL2_UPDATE
    
    rts
    
LEVEL2_UPDATE::                      ; SWITHCES THE LEVEL2_FLAG WHICH CHANGES ENEMY BEHAVIOUR
    move.b   #1,LEVEL2_FLAG
    move.l   #02,LEVEL
    
    rts
    
CNG_ENEMY::
    move.l  ENEMY_Y,D1                                  ; MOVES ENEMY_Y TO D1
    eor     #%00000000000000000000000000000100,D1       ; CHANGES ENEMY_Y BY 
    move.l  D1,ENEMY_Y     
    clr.l   D1
    
    rts
    
CNG_ENEMY3::
    
    move.l  ENEMY3_Y,D1
    eor     #%00000000000000000000000000001000,D1
    move.l  D1,ENEMY3_Y
    clr.l   D1
    
    rts
    
LEVEL3_TEST::                        ; CHECKS IF A DISTANCE OF 1200 HAS BEEN REACHED
    move.l  #1200,D1          
    move.l  DISTANCE,D2
    cmp.l   D1,D2
    
    beq     LEVEL3_UPDATE
    
    rts
    
LEVEL3_UPDATE::                      ; SWITHCES THE LEVEL3_FLAG WHICH CHANGES ENEMY BEHAVIOUR
    move.b   #1,LEVEL3_FLAG
    move.l   #03,LEVEL
    
    rts

*-----------------------------------------------------------
* Subroutine    :: Move Enemy
* Description   :: Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY::
    sub.l   #02,ENEMY_X                 ; Move enemy by X Value
    bsr LEVEL2_TEST
    bsr LEVEL3_TEST
    
    rts
    
MOVE_ENEMY2::
    sub.l   #03,ENEMY2_X                ; Move enemy by X Value
    rts
    
MOVE_ENEMY3::
    sub.l   #01,ENEMY3_X                ; Move enemy by X Value
    rts
    
MOVE_POWERUP::
    eor.b   #%00000001,MOVE_POWER_FLG
    tst.b   MOVE_POWER_FLAG
    beq     SKIPMOVE
    sub.l   #02,POWERUP_X               ; move POWERUP BY X VALUE
    rts
    
MOVE_GROWTH::
    eor.b   #%00000001,MOVE_GROWTH_FLG
    tst.b   MOVE_GROWTH_FLAG
    beq     SKIPMOVE
    sub.l   #01,GROWTH_X                ; Move GROWTH by X Value
    rts
SKIPMOVE::
    rts
*-----------------------------------------------------------
* Subroutine    :: Reset Enemy
* Description   :: Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION::
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,ENEMY_X              ; Enemy X Position
    
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.b  #00,D1                  ; move 0 TO D1
    move.b  D1,ENEMY_C              ; RESET COLLISION FLAG
    
    tst.b   LEVEL2_FLAG
    BNE     CNG_ENEMY
    
    rts
    
RESET_ENEMY2_POSITION::
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,ENEMY2_X             ; Enemy X Position
    
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.b  #00,D1                  ; move 0 TO D1
    move.b  D1,ENEMY2_C             ; RESET COLLISION FLAG
    

    
    rts
    
RESET_ENEMY3_POSITION::
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1             ; Place Screen width in D1
    move.l  D1,ENEMY3_X             ; Enemy X Position
    
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.b  #00,D1                  ; move 0 TO D1
    move.b  D1,ENEMY3_C             ; RESET COLLISION FLAG
    
    tst.b   LEVEL2_FLAG
    BNE     CNG_ENEMY3
    
    rts
    
RESET_POWERUP_POSITION::
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1          ; Place Screen width in D1
    move.l  D1,POWERUP_X   ; POWERUP X Position
    
    clr.l   D1                      ; CLEAR CONTENTS OF D1
    move.b  #00,D1          ; move 0 TO D1
    move.b  D1,POWERUP_C   ; RESET COLLISION FLAG
    rts
    
RESET_GROWTH_POSITION::
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    move.b  SCREEN_W,D1          ; Place Screen width in D1
    move.l  D1,GROWTH_X    ; Enemy X Position
    rts

*-----------------------------------------------------------
* Subroutine    :: Draw
* Description   :: Draw Screen
*-----------------------------------------------------------
DRAW:: 

    ; Clear the screen
    bsr     CLEAR_SCREEN

    bsr     DRAW_SKY                ; Draw Sky at level 3
    bsr     DRAW_CLOUD              ; Draw Cloud at level 3
    bsr     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    bsr     DRAW_GND                ; DRAW GROUND
    bsr     DRAW_GROUND             ; Draw ground at level 2
    bsr     DRAW_PLAYER             ; Draw Player
    bsr     DRAW_ENEMY              ; Draw Enemy
    bsr     DRAW_ENEMY2             ; Draw Enemy
    bsr     DRAW_ENEMY3             ; Draw Enemy
    bsr     DRAW_POWERUP            ; DRAW POWERUP
    bsr     DRAW_GROWTH             ; Draw GROWTH
    rts                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    :: Player is on Ground
* Description   :: Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND::
    ; Check if Player is on Ground
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    clr.l   D2                      ; Clear contents of D2 (XOR is faster)
    move.b  SCREEN_H,D1          ; Place Screen width in D1
    divu    #02,D1          ; divide by 2 for center on Y Axis
    move.l  PLAYER_Y,D2          ; Player Y Position
    CMP     D1,D2          ; Compare middle of Screen with Players Y Position 
    bge     SET_ON_GROUND           ; The Player is on the Ground Plane
    blt     SET_OFF_GROUND          ; The Player is off the Ground
    rts                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    :: On Ground
* Description   :: Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND::
    clr.l   D1                          ; Clear contents of D1 (XOR is faster)
    move.w  SCREEN_H,D1              ; Place Screen width in D1
    divu    #02,D1              ; divide by 2 for center on Y Axis
    move.l  D1,PLAYER_Y        ; Reset the Player Y Position
    clr.l   D1                          ; Clear contents of D1 (XOR is faster)
    move.l  #00,D1              ; Player Velocity
    move.l  D1,PLYR_VELOCITY   ; Set Player Velocity
    move.l  #GND_TRUE,PLYR_ON_GND     ; Player is on Ground
    rts

*-----------------------------------------------------------
* Subroutine    :: Off Ground
* Description   :: Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND::
    move.l  #GND_FALSE,PLYR_ON_GND     ; Player if off Ground
    rts                                 ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    :: Jump
* Description   :: Perform a Jump
*-----------------------------------------------------------
JUMP::
    move.l  #$20,CURRENT_KEY
    cmp.l   #GND_TRUE,PLYR_ON_GND       ; Player is on the Ground ?
    beq     PERFORM_JUMP                ; Do Jump
    bra     JUMP_DONE               
PERFORM_JUMP::
    bsr     PLAY_JUMP                   ; Play jump sound
    move.l  #PLYR_JUMP_V,PLYR_VELOCITY  ; Set the players velocity to true
    rts                                 ; Return to subroutine
JUMP_DONE::
    rts                                 ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    :: Idle
* Description   :: Perform a Idle
*----------------------------------------------------------- 
IDLE::
    beq     PLAY_RUN                    ; Play Run Wav
    rts                                 ; Return to subroutine

*-----------------------------------------------------------
* Subroutines   :: Sound Load and Play
* Description   :: Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD::
    lea     RUN_WAV,A1              ; Load Wav File into A1
    move    #RUN_INDEX,D1              ; Assign it INDEX
    move    #71,D0              ; Load into memory
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine

PLAY_RUN::
    move    #RUN_INDEX,D1              ; Load Sound INDEX
    move    #72,D0              ; Play Sound
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine

JUMP_LOAD::
    lea     JUMP_WAV,A1              ; Load Wav File into A1
    move    #JMP_INDEX,D1              ; Assign it INDEX
    move    #71,D0              ; Load into memory
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine

PLAY_JUMP::
    move    #76,D0              ; STOPS ALL PREVIOUS SOUNDS TO ALLOW JUMP TO PLAY
    move.l  #3,D2
    trap    #15
    
    move    #JMP_INDEX,D1              ; Load Sound INDEX
    move    #72,D0              ; Play Sound
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine

OPPS_LOAD::
    lea     OPPS_WAV,A1              ; Load Wav File into A1
    move    #OPPS_INDEX,D1              ; Assign it INDEX
    move    #71,D0              ; Load into memory
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine

PLAY_OPPS::
    move    #76,D0              ; STOP ALL SOUNDS TO ALLOW OPPS TO PLAY
    move.l  #3,D2
    trap    #15
    
    move    #OPPS_INDEX,D1              ; Load Sound INDEX
    move    #72,D0              ; Play Sound
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine
    
POWERUP_LOAD::
    lea     POWERUP_WAV,A1          ; Load Wav File into A1
    move    #POWERUP_INDEX,D1          ; Assign it INDEX
    move    #71,D0          ; Load into memory
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine
    
PLAY_POWERUP::
    move    #76,D0              ; STOP ALL SOUNDS TO ALLOW POWERUP TO PLAY
    move.l  #3,D2
    trap    #15
    
    move    #POWERUP_INDEX,D1          ; Load Sound INDEX
    move    #72,D0          ; Play Sound
    trap    #15                         ; Trap (Perform action)
    rts                                 ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    :: Draw Player
* Description   :: Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER::
    ; Set Pixel Colors
    move.l  #WHITE,D1              ; Set Pen color
    move.b  #80,D0              ; Task for Pen Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0              ; Task for Fill Color
    trap    #15            ; Trap (Perform action)

    ; Set X, Y, Width and Height
    move.l  PLAYER_X,D1              ; X
    move.l  PLAYER_Y,D2              ; Y
    move.l  PLAYER_X,D3
    add.l   #PLYR_W_INIT,D3          ; Width
    move.l  PLAYER_Y,D4 
    add.l   #PLYR_H_INIT,D4          ; Height
    
    ; Draw Player
    move.b  #87,D0              ; Draw Player
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL                  ; Clears Fill Color
    rts                                 ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    :: Clear Fill
* Description   :: Clear Fill Color (is necessary after filling player/enemy)
*-----------------------------------------------------------
CLEAR_FILL::
    lea     BLACK,A1   ; Set Fill Color
    bsr     PRINT
    rts
*-----------------------------------------------------------
* Subroutine    :: Draw Enemy
* Description   :: Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY::
    ; Set Pixel Colors
    move.l  #RED,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    move.l  ENEMY_X,D1          ; X
    move.l  ENEMY_Y,D2          ; Y
    move.l  ENEMY_X,D3
    add.l   #ENMY_W_INIT,D3          ; Width
    move.l  ENEMY_Y,D4 
    add.l   #ENMY_H_INIT,D4          ; Height
    
    ; Draw Enemy    
    move.b  #87,D0              ; Draw Enemy
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts                                 ; Return to subroutine
    
DRAW_ENEMY2::
    ; Set Pixel Colors
    move.l  #RED,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    move.l  ENEMY2_X,D1         ; X
    move.l  ENEMY2_Y,D2         ; Y
    move.l  ENEMY2_X,D3
    add.l   #ENMY_W_INIT,D3          ; Width
    move.l  ENEMY2_Y,D4 
    add.l   #ENMY_H_INIT,D4          ; Height
    
    ; Draw Enemy    
    move.b  #87,D0              ; Draw Enemy
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts   
    
DRAW_ENEMY3::
    ; Set Pixel Colors
    move.l  #RED,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    move.l  ENEMY3_X,D1         ; X
    move.l  ENEMY3_Y,D2         ; Y
    move.l  ENEMY3_X,D3
    add.l   #ENMY_W_INIT,D3          ; Width
    move.l  ENEMY3_Y,D4 
    add.l   #ENMY_H_INIT,D4          ; Height
    
    ; Draw Enemy    
    move.b  #87,D0              ; Draw Enemy
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts   
    
DRAW_POWERUP::
    ; Set Pixel Colors
    move.l  #GREEN,D1        ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    move.l  POWERUP_X,D1      ; X
    move.l  POWERUP_Y,D2      ; Y
    move.l  POWERUP_X,D3
    add.l   #POWERUP_W_INIT,D3      ; Width
    move.l  POWERUP_Y,D4 
    add.l   #POWERUP_H_INIT,D4      ; Height
    
    ; Draw POWERUP    
    move.b  #87,D0              ; Draw POWERUP
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts                                 ; Return to subroutine
    
DRAW_GROWTH::
    ; Set Pixel Colors
    move.l  #GOLD,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                     ; Trap (Perform action)
    move.b  #81,D0          ; Fills Rectangle with the same color as the outlines
    trap    #15

    ; Set X, Y, Width and Height
    move.l  GROWTH_X,D1          ; X
   ; sub.l   #3,D1
    move.l  GROWTH_Y,D2          ; Y
    ;sub.l   #3,D2
    move.l  GROWTH_X,D3      
    add.l   #GROWTH_W,D3          ; Width
    move.l  GROWTH_Y,D4          
    add.l   #GROWTH_H,D4          ; Height
    
    ; Draw GROWTH
    move.b  #87,D0          ; Draw GROWTH
    trap    #15                     ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts                             ; Return to subroutine
    
DRAW_GND::
        ; Set Pixel Colors
    move.l  #RED,D1            ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)

    ; Set X, Y, Width and Height
    move.l  GND_X,D1            ; X
    move.l  GND_Y,D2            ; Y
    move.l  GND_X,D3
    add.l   #GND_W,D3            ; Width
    move.l  GND_Y,D4 
    add.l   #GND_H,D4                ; Height
    
    ; Draw GROUND    
    move.b  #87,D0              ; Draw GROUND
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts  
    
DRAW_H_BAR::

    ; Set Pixel Colors
    move.l  #RED,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)
    
    ; Set X, Y, Width and Height
    move.l  HEALTH_X,D1         ; X
    move.l  HEALTH_Y,D2         ; Y
    move.l  HEALTH_X,D3
    add.l   #100,D3         ; Width
    move.l  HEALTH_Y,D4 
    add.l   #10,D4         ; Height
    
    ; Draw HEALTHBAR RED   
    move.b  #87,D0         ; Draw HEALTHBAR
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    
    ; Set Pixel Colors
    move.l  #GREEN,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                         ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                         ; Trap (Perform action)
    
    ; Set X, Y, Width and Height
    move.l  HEALTH_X,D1         ; X
    move.l  HEALTH_Y,D2         ; Y
    move.l  HEALTH_X,D3
    add.l   HEALTH_W,D3         ; Width
    move.l  HEALTH_Y,D4 
    add.l   #HEALTH_H,D4         ; Height
    
    ; Draw HEALTHBAR GREEN   
    move.b  #87,D0         ; Draw HEALTHBAR
    trap    #15                         ; Trap (Perform action)
    bsr     CLEAR_FILL
    
    rts 
*-----------------------------------------------------------
* Subroutine    :: Draw Ground
* Description   :: Draw Ground
*-----------------------------------------------------------
DRAW_GROUND::
    tst.l   LEVEL2_FLAG
    beq     SKIP_DRAW
    ; Set Pixel Colors
    move.l  #GREEN,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                     ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    clr.l   D1
    clr.l   D2
    clr.l   D3
    clr.l   D4
    move.l  #0,D1          ; LEFTMOST X
    move.w  SCREEN_H,D2          ; UPPER Y
    divu    #2,D2
    add.l   #9,D2
    move.w  SCREEN_W,D3          ; RIGHTMOST X
    move.w  SCREEN_H,D4          ; LOWER Y
    
    ; Draw Ground    
    move.b  #87,D0          ; Draw Enemy
    trap    #15                     ; Trap (Perform action)
    
    ; Set Pixel Colors
    move.l  #DARK_GREEN,D1          ; Set Background color
    move.b  #80,D0          ; Task for Background Color
    trap    #15                     ; Trap (Perform action)
    move.b  #81,D0          ; Task for Fill Color
    trap    #15                     ; Trap (Perform action)
    
    ; Alter dimensions from above
    move.l  #0,D1
    move.l  D2,D4
    add.l   #20,D4
    
    ; Draw Shading
    move.b  #87,D0          ; Draw Enemy
    trap    #15                     ; Trap (Perform action)
    bsr     CLEAR_FILL
    rts                             ; Return to subroutine
    
SKIP_DRAW::
    rts
*-----------------------------------------------------------
* Subroutine    :: Draw Sky
* Description   :: Draw Sky Square
*-----------------------------------------------------------
DRAW_SKY::
    tst.b   LEVEL3_FLAG
    beq     SKIP_DRAW
    ; Set Pixel Colors
    clr     d1
    move.w  #$0005,d1
    bsr     MOVECURSOR
    lea     LIGHT_BLUE,A1
    bsr     PRINT
    move.w  #B417,d1
    bsr     MOVECURSOR

    bsr     CLEAR_FILL
    rts                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    :: Collision Checks
* Description   :: Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_ALL_COLLISIONS::
    bsr     CHECK_COLLISIONS         ; CHECKING FOR COLLISIONS WITH ENEMIES
    bsr     CHECK_COLLISIONS2
    bsr     CHECK_COLLISIONS3
    bsr     CHECK_POWERUP_COLLISIONS ; CHECKING FOR POWERUP COLLISIONS 
    bsr     CHECK_GROWTH_COLLISIONS
    
    rts
    
CHECK_COLLISIONS::
    clr.l   D1                      ; Clear D1
    clr.l   D2                      ; Clear D2
    lea     ENEMY_C,A2         ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W::
    move.l  PLAYER_X,D1          ; Move Player X to D1
    move.l  ENEMY_X,D2          ; Move Enemy X to D2
    add.l   #ENMY_W_INIT,D2          ; Set Enemy width X + Width    ADDED #
    cmp.l   D2,D1          ; Do the Overlap ?              SWAPPED D2 AND D1
    ble     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    bra     COLLISION_CHECK_DONE    ; If not no collision
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X::     ; Check player is not           ADDED #
    add.l   #PLYR_W_INIT,D1          ; Move Player Width to D1
    move.l  ENEMY_X,D2          ; Move Enemy X to D2
    cmp.l   D1,D2          ; Do they OverLap ?
    ble     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal    CHANGED bge TO ble
    bra     COLLISION_CHECK_DONE    ; If not no collision   
    
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H::     
    move.l  PLAYER_Y,D1          ; Move Player Y to D1
    move.l  ENEMY_Y,D2          ; Move Enemy Y to D2
    sub.l   #ENMY_H_INIT,D2          ; Set Enemy Height to D2       ADDED #, ADD CHANGED TO SUB
    cmp.l   D1,D2          ; Do they Overlap ?
    ble     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision 
    
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y::     ; Less than or Equal ?          CHANGED ADD TO SUB
    sub.l   #PLYR_H_INIT,D1         ; Add Player Height to D1       ADDED #
    move.l  ENEMY_Y,D2          ; Move Enemy Height to D2  
    cmp.l   D1,D2          ; Do they OverLap ?
    bge     COLLISION               ; Collision !
    bra     COLLISION_CHECK_DONE    ; If not no collision
    
COLLISION_CHECK_DONE::               
    
    rts                             ; Return to subroutine

COLLISION::
    tst.b   (A2)                    ; TESTS THE COLLISION FLAG TO AVOID MULTIPLE COLLISIONS
    BNE     COLLISION_CHECK_DONE
    bsr     PLAY_OPPS               ; Play Opps Wav
    lea     DAMAGE,A1
    move.l  (A1),D1
    
    
    
    sub.l   D1,PLAYER_HEALTH       ; Subtract damage from player health
    sub.l   D1,HEALTH_W
    move.b  #01,(A2)        ; SET COLLISION FLAG TO 1 (A HIT HAS BEEN REGISTERED)
    
    
    tst.l   PLAYER_HEALTH           ; TESTS IF PLAYER HEALTH IS 0
    ble     EXIT                    ; IF SO, GAME OVER
    
    move.l  PLAYER_SCORE,D1      ; move PLAYER_SCORE TO D1
    move.l  #1000,D2      ; move 1000 TO D2
    cmp.l   D1,D2      ; COMPARE PLAYER_SCORE TO 1000
    
    bge     UPDATE_LOWSCORE         ; IF 1000 IS GREATER THAN PLAYER_SCORE, RESET SCORE TO 0 (THIS PREVENTS NEGATIVE SCORE)
    
    sub.l   #1000,PLAYER_SCORE   ; IF PLAYER_SCORE IS GREATER THAN 1000, SUBTRACT 1000 FROM PLAYER_SCORE UPON A COLLISION
    
    rts                             ; Return to subroutine
    
UPDATE_LOWSCORE::
        move.l  #00,PLAYER_SCORE       ; Reset Player Score
        
        rts
    
POWERUP_COLLISION::
    clr.l   D1
    clr.l   D2
    
    tst.b   (A2)                    ; TESTS THE COLLISION FLAG TO AVOID MULTIPLE COLLISIONS
    BNE     COLLISION_CHECK_DONE
    
    move.l  PLAYER_HEALTH,D1     ; MOVING PLAYER HEALTH TO D1
    move.l  #100,D2     ; MOVING 100 (MAXIMUM HEALTH ALLOWED) TO D2
    cmp.l   D1,D2     ; CHECKING IF PLAYER IS AT MAXIMUM HEALTH
    ble     COLLISION_CHECK_DONE
    
    bsr     PLAY_POWERUP            ; Play Opps Wav
    lea     HEAL,A1
    move.l  (A1),D1
    
    add.l   D1,PLAYER_HEALTH       ; ADD HEALTH TO player health
    add.l   D1,HEALTH_W
    
    cmp.l   D1,D2          ; CHECKING IF PLAYER IS AT MAXIMUM HEALTH
    bge     PREVENT_OVERHEAL
    
    move.b  #01,(A2)        ; SET COLLISION FLAG TO 1 (A HIT HAS BEEN REGISTERED)
    
    rts                             ; Return to subroutine
    
PREVENT_OVERHEAL::
    move.l  #100,PLAYER_HEALTH   ; SET HEALTH TO 100
    move.l  #100,HEALTH_W        ; SET HEALTHBAR WIDTH TO 100
    
    rts
    
CHECK_COLLISIONS2::
    clr.l   D1                      ; Clear D1
    clr.l   D2                      ; Clear D2
    lea     ENEMY2_C,A2          ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_ENEMY2_X_PLUS_W::
    move.l  PLAYER_X,D1          ; Move Player X to D1
    move.l  ENEMY2_X,D2         ; Move Enemy X to D2
    add.l   #ENMY_W_INIT,D2         ; Set Enemy width X + Width
    cmp.l   D2,D1          ; Do the Overlap ?
    ble     PLAYER_X_PLUS_W_LTE_TO_ENEMY2_X  ; Less than or Equal ?
    bra     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_ENEMY2_X::    ; Check player is not  
    add.l   #PLYR_W_INIT,D1         ; Move Player Width to D1
    move.l  ENEMY2_X,D2         ; Move Enemy X to D2
    cmp.l   D1,D2          ; Do they OverLap ?
    ble     PLAYER_Y_LTE_TO_ENEMY2_Y_PLUS_H  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_ENEMY2_Y_PLUS_H::     
    move.l  PLAYER_Y,D1          ; Move Player Y to D1
    move.l  ENEMY2_Y,D2         ; Move Enemy Y to D2
    sub.l   #ENMY_H_INIT,D2         ; Set Enemy Height to D2
    cmp.l   D1,D2          ; Do they Overlap ?
    ble     PLAYER_Y_PLUS_H_LTE_TO_ENEMY2_Y  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY2_Y::    ; Less than or Equal ?
    sub.l   #PLYR_H_INIT,D1         ; Add Player Height to D1
    move.l  ENEMY2_Y,D2         ; Move Enemy Height to D2  
    cmp.l   D1,D2          ; Do they OverLap ?
    bge     COLLISION               ; Collision !
    bra     COLLISION_CHECK_DONE    ; If not no collision
    
CHECK_COLLISIONS3::
    clr.l   D1                      ; Clear D1
    clr.l   D2                      ; Clear D2
    lea     ENEMY3_C,A2        ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_ENEMY3_X_PLUS_W::
    move.l  PLAYER_X,D1          ; Move Player X to D1
    move.l  ENEMY3_X,D2         ; Move Enemy X to D2
    add.l   #ENMY_W_INIT,D2         ; Set Enemy width X + Width
    cmp.l   D2,D1          ; Do the Overlap ?
    ble     PLAYER_X_PLUS_W_LTE_TO_ENEMY3_X  ; Less than or Equal ?
    bra     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_ENEMY3_X::    ; Check player is not  
    add.l   #PLYR_W_INIT,D1         ; Move Player Width to D1
    move.l  ENEMY3_X,D2         ; Move Enemy X to D2
    cmp.l   D1,D2          ; Do they OverLap ?
    ble     PLAYER_Y_LTE_TO_ENEMY3_Y_PLUS_H  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_ENEMY3_Y_PLUS_H::     
    move.l  PLAYER_Y,D1          ; Move Player Y to D1
    move.l  ENEMY3_Y,D2         ; Move Enemy Y to D2
    sub.l   #ENMY_H_INIT,D2         ; Set Enemy Height to D2
    cmp.l   D1,D2          ; Do they Overlap ?
    ble     PLAYER_Y_PLUS_H_LTE_TO_ENEMY3_Y  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY3_Y::    ; Less than or Equal ?
    sub.l   #PLYR_H_INIT,D1         ; Add Player Height to D1
    move.l  ENEMY3_Y,D2         ; Move Enemy Height to D2  
    cmp.l   D1,D2          ; Do they OverLap ?
    bge     COLLISION               ; Collision !
    bra     COLLISION_CHECK_DONE    ; If not no collision
    
CHECK_POWERUP_COLLISIONS::
    clr.l   D1                      ; Clear D1
    clr.l   D2                      ; Clear D2  
    lea     POWERUP_C,A2       ; LOADING THE COLLISION FLAG INTO A2 IN PREPARATION FOR A POTENTIAL COLLISON
    
PLAYER_X_LTE_TO_POWERUP_X_PLUS_W::
    move.l  PLAYER_X,D1          ; Move Player X to D1
    move.l  POWERUP_X,D2        ; Move Enemy X to D2
    add.l   #POWERUP_W_INIT,D2      ; Set Enemy width X + Width
    cmp.l   D2,D1          ; Do the Overlap ?
    ble     PLAYER_X_PLUS_W_LTE_TO_POWERUP_X  ; Less than or Equal ?
    bra     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_POWERUP_X::   ; Check player is not  
    add.l   #PLYR_W_INIT,D1         ; Move Player Width to D1
    move.l  POWERUP_X,D2        ; Move Enemy X to D2
    cmp.l   D1,D2          ; Do they OverLap ?
    ble     PLAYER_Y_LTE_TO_POWERUP_Y_PLUS_H  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_POWERUP_Y_PLUS_H::     
    move.l  PLAYER_Y,D1          ; Move Player Y to D1
    move.l  POWERUP_Y,D2        ; Move Enemy Y to D2
    sub.l   #POWERUP_H_INIT,D2      ; Set Enemy Height to D2
    cmp.l   D1,D2          ; Do they Overlap ?
    ble     PLAYER_Y_PLUS_H_LTE_TO_POWERUP_Y  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_POWERUP_Y::   ; Less than or Equal ?
    sub.l   #PLYR_H_INIT,D1         ; Add Player Height to D1
    move.l  POWERUP_Y,D2        ; Move Enemy Height to D2  
    cmp.l   D1,D2          ; Do they OverLap ?
    bge     POWERUP_COLLISION       ; Collision !
    bra     COLLISION_CHECK_DONE    ; If not no collision
    
CHECK_GROWTH_COLLISIONS::
    clr.l   D1                      ; Clear D1
    clr.l   D2                      ; Clear D2
PLAYER_X_LTE_TO_GROWTH_X_PLUS_W::
    move.l  PLAYER_X,D1          ; Move Player X to D1
    move.l  GROWTH_X,D2         ; Move GROWTH X to D2
    add.l   GROWTH_W,D2             ; Set GROWTH X + Width
    sub.l   #05,D2                  ; Subtracting 10 from D2 makes the collision more lenient
    cmp.l   D1,D2          ; Do the Overlap ?
    ble     PLAYER_X_PLUS_W_LTE_TO_GROWTH_X  ; Less than or Equal ?
    bra     COLLISION_CHECK_DONE    ; If not no collision
PLAYER_X_PLUS_W_LTE_TO_GROWTH_X::    ;  
    add.l   PLYR_W_INIT,D1          ; Move Player Width to D1
    move.l  GROWTH_X,D2         ; Move GROWTH X to D2
    add.l   #05,D2                  ; Adding 10 to D2 makes the collision more lenient
    cmp.l   D1,D2          ; Do they OverLap ?
    bge     PLAYER_Y_LTE_TO_GROWTH_Y_PLUS_H  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision   
PLAYER_Y_LTE_TO_GROWTH_Y_PLUS_H::     
    move.l  PLAYER_Y,D1          ; Move Player Y to D1
    move.l  GROWTH_Y,D2         ; Move GROWTH Y to D2
    add.l   GROWTH_H,D2             ; Set GROWTH Height to D2
    sub.l   #15,D2          ; Brings the collision of the lower part of the rectangle upwards
    cmp.l   D1,D2          ; Do they Overlap ?
    ble     PLAYER_Y_PLUS_H_LTE_TO_GROWTH_Y  ; Less than or Equal
    bra     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_GROWTH_Y::    ; Less than or Equal ?
    add.l   PLYR_H_INIT,D1          ; Add Player Height to D1
    move.l  GROWTH_Y,D2         ; Move GROWTH Height to D2
    sub.l   #15,D2          ; Brings the collision of the upper part of the rectangle upwards
    cmp.l   D1,D2          ; Do they OverLap ?
    bge     GROWTH_COLLISION               ; Collision !
    bra     COLLISION_CHECK_DONE    ; If not no collision
                            
GROWTH_COLLISION::
    add.l   #01,PLAYER_GROWTH             ;Subtracting the enemy damage from the player's health
    rts                                     ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    :: EXIT
* Description   :: Exit message and End Game
*-----------------------------------------------------------
EXIT::

    ; Clear screen
    move.b  #TC_CURSR_P,D0          ; SET CURSOR POSITION
    move.w  #$FF00,D1
    trap    #15                     ; Trap (Perform action)
    
    
    ; WRITE GAME OVER MESSAGE
    move    #21,D0
    move.l  #RED,D1          ; SETTING FONT COLOUR
    move.l  #$01090001,D2          ; FONT :: FIXEDSYS, SIZE :: 9, BOLD
    trap    #15                     ; trap (PERFORM ACTION)
    
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$1E0D,D1          ; Col 18, Row 13
    trap    #15                     ; Trap (Perform action)    
    lea     GAME_OVER_MSG,A1       ; Move GAME OVER Message to D1
    move.b  #13,D0          ; Display the contents of D1
    trap    #15  

    ; Player Score Message
    move    #21,D0
    move.l  #WHITE,D1          ; SETTING FONT COLOUR
    move.l  #$01090000,D2          ; FONT :: FIXEDSYS, SIZE :: 9, BOLD
    trap    #15                     ; trap (PERFORM ACTION)
    
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$220F,D1          ; Col 22, Row 15
    trap    #15                     ; Trap (Perform action)
    lea     SCORE_MSG,A1          ; Score Message
    move    #13,D0          ; No Line feed
    trap    #15                     ; Trap (Perform action)

    ; Player Score Value
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$2A0F,D1          ; Col 30, Row 15
    trap    #15                     ; Trap (Perform action)
    move.b  #03,D0          ; Display number at D1.L
    move.l  PLAYER_SCORE,D1         ; Move Score to D1.L
    trap    #15                     ; Trap (Perform action)
    
    ; Player DISTANCE Message
    move    #21,D0
    move.l  #WHITE,D1          ; SETTING FONT COLOUR
    move.l  #$01090000,D2          ; FONT :: FIXEDSYS, SIZE :: 9, BOLD
    trap    #15                     ; trap (PERFORM ACTION)
    
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$2111,D1          ; Col 21, Row 11
    trap    #15                     ; Trap (Perform action)
    lea     DISTANCE_MSG,A1        ; DISTANCE Message
    move    #13,D0          ; No Line feed
    trap    #15                     ; Trap (Perform action)
    
    ; Player DISTANCE Value
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$2B11,D1          ; Col 31 , Row 11
    trap    #15                     ; Trap (Perform action)
    move.b  #03,D0          ; Display number at D1.L
    move.l  DISTANCE,D1          ; Move DISTANCE to D1.L
    trap    #15                     ; Trap (Perform action)
    
    ; Player GOLD Message
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$2113,D1          ; Col 32, Row 12
    trap    #15                     ; Trap (Perform action)
    lea     GAME_OVER_MSG2,A1 ; Second Game Over Message to show gold
    move    #13,D0          ; No Line feed
    trap    #15                     ; Trap (Perform action)
    
    ; Player GROWTH
    move.b  #TC_CURSR_P,D0          ; Set Cursor Position
    move.w  #$2B13,D1          ; Col 30, Row 12
    trap    #15                     ; Trap (Perform action)
    move.b  #03,D0          ; Display number at D1.L
    move.l  PLAYER_GROWTH,D1     ; Move Player_Growth to D1.L
    trap    #15                     ; Trap (Perform action)

    ; Enable back buffer
    move.b  #94,D0          ; This copies the off screen buffer to the on screen buffer
    trap    #15
    
    move.b  #TC_EXIT,D0          ; Exit Code
    trap    #15                     ; Trap (Perform action)
   
*-----------------------------------------------------------
* Subroutine    :: Draw Player Data
* Description   :: Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA::
    clr.l   D1                      ; Clear contents of D1 (XOR is faster)
    clr.l   d2
    move.b  #10,D2          ; Move Number Base to D2.B

    bsr     CLEAR_SCREEN

    ; Player Score Message
    lea     SCORE_MSG,A1         ; Score Message to A1
    bsr     PRINT                ; BSR to print

    ; Player Score Value    
    move.l  PLAYER_SCORE,D1         ; Move Score to D1.L
    bsr     PRINTNUM        ; BSR to printNum

    bsr     TAB
    
    ; Player DISTANCE Message
    lea     DISTANCE_MSG,A1        ; DISTANCE Message
    bsr     PRINT
    
    ; Player DISTANCE
    move.l  DISTANCE,D1          ; Move DISTANCE to D1.L
    bsr     PRINTNUM

    ; LEVEL Message
    lea     LEVEL_MSG,A1      ; LEVEL Message
    bsr     PRINT
    
    ; CURRENT LEVEL
    move.l  LEVEL,D1          ; 
    bsr     PRINTNUM

    bsr     TAB
    
    ; Show  GROWTH Message 
    lea     GROWTH_MSG,A1          ; Move Growth Message to A1
    bsr     PRINT
    
    ;Player GROWTH
    move.l  PLAYER_GROWTH,D1       ; Move Health to D1.L
    bsr     PRINTNUM

    bsr     LINE

    ; Show Keys Pressed
    lea     KEYCODE_MSG,A1         ; Keycode
    bsr     PRINT

    ; Show KeyCode   
    move.l  CURRENT_KEY,D1          ; Move Key Pressed to D1
    bsr     PRINTNUM    

    bsr     LINE

    ; Player Health Message

    lea     HEALTH_MSG,A1          ; Display the contents of D1
    bsr     PRINT

    ; Player Health Value
    move.l  PLAYER_HEALTH,D1
    bsr     PRINTNUM
    
    bsr     LINE
    bsr     LINE
    bsr     LINE
    bsr     LINE
    bsr     LINE
    bsr     LINE
    lea     BLOCK,A1
    bsr     PRINT
    rts
*------------------------------------------------------------
*   Subroutine  :   Print
*   Description :   Prints to screen
*------------------------------------------------------------
PRINT::
    move.l  #14,D0                     ; Func code is 0 PRINT
    trap    #15                       ; TRAP to firmware
    rts   
PRINTNUM::
    move.l  #15,D0                     ; Func code is 0 PRINT
    trap    #15                       ; TRAP to firmware
    rts   
LINE::
    move.l  #13,D0
    lea     LINEBREAK,A1
    trap    #15
    rts
TAB::
    lea     TABMSG,A1
    bsr     PRINT
    rts
CLEAR_SCREEN::
    move.l  #11,D0                          ; Function code is '11' for clearing the screen
    move.w  #$FF00,D1                       ; Special case for clear screen
    trap    #15                             ; Call TRAP firmware routine to clear the screen
    rts                                     ; Return from subroutine
READCHAR::
    move.l  #5,D0                     ; Func code is 5
    trap    #15                       ; TRAP to Easy68k firmware
    eor.l   D0,D0                     ; Zero D0...
    move.b  D1,D0                     ; ... and place return value there
    rts                               ; We're done.
WRITECHAR::
    move.l  #6,D0                     ; Func code is 6
    trap    #15                       ; TRAP to Easy68k firmware
    rts                               ; We're done.
MOVECURSOR::
    ;;Store XXYY in d1
    move.l  #11,D0                    ; Func code is 11
    trap    #15                       ; TRAP to Easy68k firmware
    rts                               ; We're done.
*-----------------------------------------------------------
* Section       :: Messages
* Description   :: Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------
SCORE_MSG       DC.B    'Score : ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode : ', 0     ; Keycode Message
HEALTH_MSG      DC.B    'Health : ',0       ; Health Message
JUMP_MSG        DC.B    'Jump....', 0       ; Jump Message
GROWTH_MSG      DC.B    'Gold:', 0        ; Wealth Message
GAME_OVER_MSG2  DC.B    'Gold :', 0
LINEBREAK       DC.B    '', 0

DISTANCE_MSG    DC.B    'Distance :', 0      ; Distance Message
LEVEL_MSG       DC.B    'Level :',0          ; DIFFICULTY LEVEL MESSAGE

GAME_OVER_MSG   DC.B    'GAME OVER!', 0     ; GAME OVER MESSAGE
TABMSG          DC.B    '    ', 0
BLOCK1          DC.B    ' ___ ', 0
BLOCK2          DC.B    '|   |',0
BLOCK3          DC.B    '|___|',0
GROWTHBLOCK     DC.B    'o',0
                         
*-----------------------------------------------------------
* Section       :: Graphic Colors
* Description   :: Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
BLACK           DC.B    '\033[40m',0
GREEN           EQU     $0000FF00
GOLD            EQU     $0000D7FF
BLUE            EQU     $00FF0000
DARK_GREEN      EQU     $00009900
SKY_BLUE        EQU     $00FFCC99
LIGHT_BLUE      DC.B    '\033[014m',0
LIGHT_GREEN     DC.B    '\033[102m',0
GRASS           DC.B    '\033[42m',0

*-----------------------------------------------------------
* Section       :: Screen Size
* Description   :: Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       :: Keyboard Input
* Description   :: Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       :: Character Positions
* Description   :: Player and Enemy Position Memory Locations
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

MOVE_POWER_FLG  DS.B    01  
MOVE_GROWTH_FLG DS.B    01

*-----------------------------------------------------------
* Section       :: Sounds
* Description   :: Sound files, which are then loaded and given    
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https:://voicemaker.in/ to           
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
