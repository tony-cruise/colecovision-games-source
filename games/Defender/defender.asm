; ============================================================
; DEFENDER (1983) FOR COLECOVISION — Z80 DISASSEMBLY
; Annotated with inline comments.  Legend line numbers are
; absolute (1-indexed) in this file.
;
; ROM layout: $8000–$BFFF (16 KB), no existing legend.
; CPU: Z80; VDP: TMS9918A; Sound: SN76489A
; RAM: $7000–$73B8; Stack: grows down from $73B9
;
; KEY RAM LOCATIONS
;   $7000 WORK_BUFFER   — game flags (bit0=2P, bit5/6/7=start)
;   $7007 player-alive  — non-zero while game is active
;   $7037 game-active   — mirror of $7007 after init
;   $7038–$704F         — 4 SN76489A sound-channel state blocks
;   $7057 anim counter  — decremented each NMI frame
;   $7061 frame counter — incremented every NMI (8-bit)
;   $706A abs frames    — absolute frame counter
;   $706B 4-frame cycle — (frame & 3) for sprite animation
;   $7138 player X      — player sprite screen X position
;   $7139 X velocity    — player scroll speed (clamp $20–$B7)
;   $713A direction     — 0=right, NZ=left
;   $7154 world scroll  — world X accumulator (16-bit, wrap $0400)
;   $7180 VRAM base     — name-table scroll pointer
;   $718E enemy sprites — 8×11-byte enemy sprite records
;   $71E6 VRAM ptr      — saved write pointer after bullet sprites
;   $7207 bullets       — 4×8-byte bullet records (LOC_D3FE)
;   $7228 missiles      — 10×4-byte missile records (SUB_D8F8)
;   $7252 explosions    — 6×22-byte explosion records (SUB_DB45)
;   $72D6 abs sprite X  — $7138+$7154 masked to $03FF
;   $72DE bullet sprites — 8×10-byte bullet sprite records
;
; SUBROUTINE INDEX
;   CART_ENTRY          line   202  first word executed ($8000), jumps to NMI
;   START               line   207  one-time hardware init; calls VDP_REG_B2E8 etc.
;   LOC_8042            line   217  game/level re-entry; resets stack, reloads VRAM
;   LOC_8098            line   251  main game loop (one iteration per VBL frame)
;   NMI                 line   309  VBL NMI: JP(IX) dispatch, sound tick, sprite update
;   SUB_8146            line   335  game frame body: all render + subsystem calls
;   VDP_REG_818D        line   365  disable TMS9918A display (reg1=$C0/$81)
;   VDP_REG_8196        line   372  enable TMS9918A display (reg1=$E0/$81)
;   SUB_8251            line   402  NMI prologue: push all regs; JP(IX) dispatch
;   SUB_825B            line   411  NMI epilogue: pop all regs; EX(SP),IX; RET
;   VDP_REG_8266        line   421  init 8 VDP registers from table at $8278
;   VDP_REG_8280        line   437  set VRAM write address from HL
;   VDP_REG_8289        line   445  set VRAM read address from HL
;   VDP_DATA_829D       line   463  clear all VRAM + RAM; load tile data
;   VDP_DATA_844F       line   627  draw player-lives icons to name table
;   VDP_DATA_849A       line   676  draw shield/weapon icons to name table
;   VDP_DATA_857B       line   746  bulk tile/sprite bitmap load (title screen)
;   SUB_862E            line   831  check $7037 flag; update WORK_BUFFER bits 0/5/6
;   VDP_WRITE_868F      line   897  write UI panel (score/lives header) to VRAM
;   VDP_WRITE_86EE      line   942  draw title/attract-mode splash to VRAM
;   SUB_8E50            line  1238  dispatch stub → LOC_AFCF (game input)
;   SUB_8E54            line  1242  dispatch stub → LOC_AA02 (clear sprite VRAM)
;   SUB_8E57            line  1245  dispatch stub → LOC_AA4B (bg scroll write)
;   SUB_8E5A            line  1248  dispatch stub → LOC_AD8E (collision detect)
;   SUB_8E5D            line  1251  dispatch stub → LOC_9CCD (sprite anim frame)
;   SUB_8E60            line  1254  dispatch stub → LOC_ADC1 (score display)
;   SUB_8E63            line  1257  dispatch stub → ACFA+AD2D (bullets+enemies)
;   SUB_8E6A            line  1262  dispatch stub → LOC_9B7D (player sprite)
;   SUB_8E6D            line  1265  dispatch stub → LOC_AEB5 (explosion update)
;   SUB_8E71            line  1269  dispatch stub → LOC_B8C6 (wave/level init)
;   SUB_8E75            line  1273  dispatch stub → LOC_D630 (enemy physics)
;   SUB_8E78            line  1276  dispatch stub → LOC_D3FE (title/demo)
;   VDP_DATA_8E84       line  1281  VRAM copy: BC bytes from (DE) to addr HL
;   VDP_DATA_8E91       line  1294  VRAM fill: BC bytes of value E at addr HL
;   SUB_8E9D            line  1306  init 3 sprite colour planes in VRAM
;   VDP_REG_8EF2        line  1362  screen flash effect ($7140 counter)
;   LOC_9B7D            line  1844  write player sprite pair to VRAM $1B00
;   SUB_9BC5            line  1884  scroll player sprite Y from $7152 velocity
;   SUB_9C00            line  1915  scroll world forward (+2): $7154, $7188, $7189
;   SUB_9C26            line  1939  scroll world backward: $7154, $7188, $7189
;   SUB_9CA7            line  2022  compute IX = anim record for direction $7153
;   LOC_9CCD            line  2046  advance animation sequence frame pointer
;   LOC_AA02            line  2559  erase old sprite strips from VRAM
;   LOC_AA4B            line  2603  write scrolled background tile row to VRAM
;   VDP_DATA_AAB0       line  2667  write anim tile index to VRAM $2808/$0808
;   VDP_DATA_ACFA       line  2766  write 8 bullet sprites to VRAM $1B08
;   LOC_AD2D            line  2795  write 8 enemy sprites to VRAM from $718E
;   LOC_AD8E            line  2842  collision: 4 zones vs enemy positions $7207
;   LOC_ADC1            line  2873  update missile/score tiles from $7228 records
;   LOC_AEB5            line  2974  process 6 explosion objects at $7252
;   SOUND_WRITE_AEF9    line  3017  SN76489A sound via VRAM XOR ($7017/$7019)
;   SUB_AF58            line  3067  init sound pointers to idle defaults
;   LOC_AFCF            line  3088  game input: read 9 controller functions
;   CTRL_READ_AFEB      line  3100  read UP-stick; decelerate $7139
;   CTRL_READ_B019      line  3131  read DOWN-stick; accelerate $7139
;   CTRL_READ_B047      line  3162  read FIRE button; init fire slot $7147
;   GAME_DATA           line  3176  animation/sprite/level data block
;   VDP_REG_B2E8        line  3516  mute SN76489A; zero sound RAM $7038-$704F
;   SUB_B344            line  3590  sound sequencer: tick 4 channels each NMI
;   LOC_B8C6            line  3937  wave/level init: clear RAM, load tables
;   SUB_B992            line  4033  load sprite anim data for mode $701B
;   TILE_BITMAPS        line  4243  TMS9918A tile patterns at $BC00 (110 tiles)
;   SUB_C1AE            line  4509  write sprite tile ptrs to 6 VRAM addresses
;   SUB_C85F            line  5044  NMI: DEC $7057; update sprite pos $7138/$7154
;   VDP_REG_C8D9        line  5112  clear display flags if $7150 set
;   SUB_CB82            line  5270  compute sprite X from $7138+$7154; anim tick
;   LOC_D3FE            line  5746  spawn/update 4 bullet objects in $7207
;   LOC_D630            line  6032  enemy physics: update 8 records at $72DE
;   SUB_D8F8            line  6230  process 10 missiles in $7228; collision
;   SUB_DB45            line  6515  process 6 explosions at $7252; anim advance
;   VDP_REG_DD80        line  6684  update VDP scroll regs $7334/$7335/$7336
;   SUB_DDE4            line  6739  add BC to BCD score at $7003/$7006; display
; ============================================================
;
;
;
;
;
;
;
;
;
;

                                            ; BIOS entry-point definitions (EQU addresses in ROM)

BOOT_UP:                 EQU $0000          ; Cold-start / warm-start vector $0000
BIOS_NMI:                EQU $0066          ; BIOS NMI handler $0066
NUMBER_TABLE:            EQU $006C          ; BIOS number-table address $006C
PLAY_SONGS:              EQU $1F61          ; BIOS PLAY_SONGS $1F61
ACTIVATEP:               EQU $1F64          ; BIOS ACTIVATEP $1F64
REFLECT_VERTICAL:        EQU $1F6A          ; BIOS REFLECT_VERTICAL $1F6A
REFLECT_HORIZONTAL:      EQU $1F6D          ; BIOS REFLECT_HORIZONTAL $1F6D
ROTATE_90:               EQU $1F70          ; BIOS ROTATE_90 $1F70
ENLARGE:                 EQU $1F73          ; BIOS ENLARGE $1F73
CONTROLLER_SCAN:         EQU $1F76          ; BIOS CONTROLLER_SCAN $1F76
DECODER:                 EQU $1F79          ; BIOS DECODER $1F79
GAME_OPT:                EQU $1F7C          ; BIOS GAME_OPT $1F7C
LOAD_ASCII:              EQU $1F7F          ; BIOS LOAD_ASCII $1F7F
FILL_VRAM:               EQU $1F82          ; BIOS FILL_VRAM $1F82
MODE_1:                  EQU $1F85          ; BIOS MODE_1 $1F85
UPDATE_SPINNER:          EQU $1F88          ; BIOS UPDATE_SPINNER $1F88
INIT_TABLEP:             EQU $1F8B          ; BIOS INIT_TABLEP $1F8B
PUT_VRAMP:               EQU $1F91          ; BIOS PUT_VRAMP $1F91
INIT_SPR_ORDERP:         EQU $1F94          ; BIOS INIT_SPR_ORDERP $1F94
INIT_TIMERP:             EQU $1F9A          ; BIOS INIT_TIMERP $1F9A
REQUEST_SIGNALP:         EQU $1FA0          ; BIOS REQUEST_SIGNALP $1FA0
TEST_SIGNALP:            EQU $1FA3          ; BIOS TEST_SIGNALP $1FA3
WRITE_REGISTERP:         EQU $1FA6          ; BIOS WRITE_REGISTERP $1FA6
INIT_WRITERP:            EQU $1FAF          ; BIOS INIT_WRITERP $1FAF
SOUND_INITP:             EQU $1FB2          ; BIOS SOUND_INITP $1FB2
PLAY_ITP:                EQU $1FB5          ; BIOS PLAY_ITP $1FB5
INIT_TABLE:              EQU $1FB8          ; BIOS INIT_TABLE $1FB8
GET_VRAM:                EQU $1FBB          ; BIOS GET_VRAM $1FBB
PUT_VRAM:                EQU $1FBE          ; BIOS PUT_VRAM $1FBE
INIT_SPR_NM_TBL:         EQU $1FC1          ; BIOS INIT_SPR_NM_TBL $1FC1
WR_SPR_NM_TBL:           EQU $1FC4          ; BIOS WR_SPR_NM_TBL $1FC4
INIT_TIMER:              EQU $1FC7          ; BIOS INIT_TIMER $1FC7
FREE_SIGNAL:             EQU $1FCA          ; BIOS FREE_SIGNAL $1FCA
REQUEST_SIGNAL:          EQU $1FCD          ; BIOS REQUEST_SIGNAL $1FCD
TEST_SIGNAL:             EQU $1FD0          ; BIOS TEST_SIGNAL $1FD0
TIME_MGR:                EQU $1FD3          ; BIOS TIME_MGR $1FD3
TURN_OFF_SOUND:          EQU $1FD6          ; BIOS TURN_OFF_SOUND $1FD6
WRITE_REGISTER:          EQU $1FD9          ; BIOS WRITE_REGISTER $1FD9
READ_REGISTER:           EQU $1FDC          ; BIOS READ_REGISTER $1FDC
WRITE_VRAM:              EQU $1FDF          ; BIOS WRITE_VRAM $1FDF
READ_VRAM:               EQU $1FE2          ; BIOS READ_VRAM $1FE2
INIT_WRITER:             EQU $1FE5          ; BIOS INIT_WRITER $1FE5
WRITER:                  EQU $1FE8          ; BIOS WRITER $1FE8
POLLER:                  EQU $1FEB          ; BIOS POLLER $1FEB — reads controllers each frame into JOYSTICK_BUFFER
SOUND_INIT:              EQU $1FEE          ; BIOS SOUND_INIT $1FEE
PLAY_IT:                 EQU $1FF1          ; BIOS PLAY_IT $1FF1
SOUND_MAN:               EQU $1FF4          ; BIOS SOUND_MAN $1FF4
ACTIVATE:                EQU $1FF7          ; BIOS ACTIVATE $1FF7
PUTOBJ:                  EQU $1FFA          ; BIOS PUTOBJ $1FFA
RAND_GEN:                EQU $1FFD          ; BIOS RAND_GEN $1FFD — hardware random number generator

                                            ; I/O port definitions

KEYBOARD_PORT:           EQU $0080          ; KEYBOARD_PORT $80 — keypad/joystick mode select
DATA_PORT:               EQU $00BE          ; DATA_PORT $BE — TMS9918A VRAM data read/write
CTRL_PORT:               EQU $00BF          ; CTRL_PORT $BF — TMS9918A register/address write, status read
JOY_PORT:                EQU $00C0          ; JOY_PORT $C0 — joystick direction mode select
CONTROLLER_02:           EQU $00F5          ; CONTROLLER_02 $F5 — player 2 controller read port
CONTROLLER_01:           EQU $00FC          ; CONTROLLER_01 $FC — player 1 controller read port
SOUND_PORT:              EQU $00FF          ; SOUND_PORT $FF — SN76489A sound chip write port

                                            ; RAM / buffer definitions

JOYSTICK_BUFFER:         EQU $0000          ; JOYSTICK_BUFFER $0000 — BIOS POLLER writes controller state here
WORK_BUFFER:             EQU $7000          ; WORK_BUFFER $7000 — main work flags (bit0=2P, bit5/6/7=start-press)
CONTROLLER_BUFFER:       EQU $702B          ; CONTROLLER_BUFFER $702B — raw controller bytes from POLLER
STACKTOP:                EQU $73B9          ; STACKTOP $73B9 — top of stack

FNAME "output\DEFENDER-1983-NEW.ROM"        ; Output ROM filename (suffix -NEW so original is never overwritten)
CPU Z80                                     ; Target CPU: Z80

    ORG     $8000                           ; ROM base address — ColecoVision cartridge space starts at $8000

    DW      $AA55                           ; Cart magic word $AA55 — required by BIOS cart detection
    DB      $00, $00
    DB      $00, $00
    DB      $00, $00
    DW      JOYSTICK_BUFFER                 ; Pointer to controller buffer — BIOS POLLER writes here each frame
    DW      START                           ; Pointer to START — BIOS jumps here after warm boot
    DB      $3A, $69, $00, $FE, $32, $20, $08, $01
    DB      $BA, $01, $0B, $78, $B1, $20, $FB, $C3
    DB      $75, $DD, $C3, $1E, $80

CART_ENTRY:                                 ; CART_ENTRY: first word executed on cold start ($8000)
    JP      NMI                             ; Jump to NMI handler — CART_ENTRY repurposed as NMI dispatch target
    DB      $40, $D4, $70, $02, $36, $71, $40, $D4
    DB      $70, $00

START:                                      ; START: called by BIOS after cart detection; one-time hardware init
    LD      A, $80                          ; VDP reg 0 = $80 → disable display during init
    OUT     ($BF), A                        ; Write to CTRL_PORT: set TMS9918A register 0
    LD      A, $81                          ; VDP reg 1 = $81 → bitmap (Mode 2) + 16KB VRAM select
    OUT     ($BF), A                        ; Write to CTRL_PORT: latch VDP register address $81
    LD      SP, $73FF                       ; Init stack pointer to top of RAM ($73FF)
    CALL    VDP_REG_B2E8                    ; Mute SN76489A; clear sound RAM $7038-$704F
    CALL    VDP_REG_8266                    ; Write all 8 VDP registers from table at $8278
    CALL    VDP_DATA_857B                   ; Load title-screen tile/sprite bitmap data into VRAM

LOC_8042:                                   ; LOC_8042: game/level re-entry — jumped to at game-over or new level
    LD      SP, $73FF                       ; Reset stack to $73FF at start of each game session
    CALL    VDP_REG_818D                    ; Disable TMS9918A display (reg 1 = $C0/$81)
    CALL    VDP_REG_B2E8                    ; Mute SN76489A, clear sound RAM
    CALL    VDP_WRITE_86EE                  ; Draw title splash-screen panels to VRAM
    CALL    VDP_DATA_829D                   ; Clear VRAM ($4000 bytes) + RAM ($380 bytes); load tile data
    CALL    SUB_B992                        ; Load sprite animation data for current game mode ($701B)
    LD      A, ($7067)                      ; Load $7067 — game-active / attract-mode flag
    LD      ($7037), A                      ; Copy to $7037 — shadow of game-active flag
    XOR     A
    OUT     ($BF), A                        ; VDP reg 0 value $00 — re-enable display path
    LD      A, $87                          ; VDP reg 1 = $87 — display on, sprites enabled
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      SP, $73FF                       ; Reset SP again before entering display loop
    CALL    VDP_REG_B2E8                    ; Mute SN76489A (clear any lingering sound)
    CALL    SUB_862E                        ; Check $7037, update WORK_BUFFER flags (bits 0/5/6)
    CALL    VDP_WRITE_868F                  ; Write UI panel (lives, score header) to VRAM
    CALL    SUB_8E71                        ; Jump to difficulty/wave init (LOC_B8C6)
    LD      A, $01
    LD      ($706F), A                  ; RAM $706F
    LD      HL, $7136                   ; RAM $7136
    LD      ($706D), HL                 ; RAM $706D
    LD      SP, $7134                   ; RAM $7134
    CALL    VDP_REG_8196
    LD      A, ($7062)                  ; RAM $7062
    AND     A
    JR      Z, LOC_80D3
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    ADD     HL, SP
    LD      IX, ($706D)                 ; RAM $706D
    LD      (IX+0), L
    LD      (IX+1), H
    LD      SP, $73FF                   ; RAM $73FF

LOC_8098:                                   ; LOC_8098: main game loop — one iteration per VBL frame
    CALL    SUB_8146                        ; Game frame body: render all layers, update all subsystems
    IN      A, ($BF)                        ; Read VDP status register (clears interrupt flag)
    LD      A, $00                          ; Value $00 for frame-complete flag clear
    LD      ($7062), A                      ; $7062 = 0: clear VBL-done flag (will be set again by NMI)
    CALL    SUB_8E78                        ; Spawn/update 4 bullet objects in $7207 entries
    CALL    VDP_REG_818D                    ; Disable display: VDP reg 1 = $C0/$81
    CALL    SUB_8E6D                        ; Update 6 explosion objects at $7252
    CALL    VDP_REG_8196                    ; Enable display: VDP reg 1 = $E0/$81
    LD      A, ($713D)                      ; Load $713D — skip-sprite-update flag
    AND     A
    CALL    Z, SUB_CB82                     ; Calc sprite pos from $7138/$7154; update anim frame counter
    CALL    SUB_D8F8                        ; Process 10 missiles/projectiles; collision vs landscape
    CALL    SUB_DB45                        ; Process 6 explosions; advance animation frames
    LD      A, ($7062)                      ; Check $7062 VBL flag
    AND     A
    JR      NZ, LOC_8098                    ; Loop while VBL not yet done (wait for NMI)
    LD      HL, $706F                       ; Point HL to $706F — frame-pacing counter
    DEC     (HL)                            ; Decrement frame-pacing counter
    JR      Z, LOC_80E9                     ; Jump to re-entry if counter reached zero

LOC_80C7:
    LD      IX, ($706D)                 ; RAM $706D
    LD      L, (IX+0)
    LD      H, (IX+1)
    LD      SP, HL
    RET     

LOC_80D3:
    LD      A, ($706F)                  ; RAM $706F
    DEC     A
    LD      ($706F), A                  ; RAM $706F
    RET     NZ
    LD      IX, ($706D)                 ; RAM $706D
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    ADD     HL, SP
    LD      (IX+0), L
    LD      (IX+1), H

LOC_80E9:
    LD      IX, ($7070)                 ; RAM $7070
    LD      A, (IX+0)
    AND     A
    JR      NZ, LOC_80FA
    LD      IX, $8024
    LD      A, (IX+0)

LOC_80FA:
    LD      ($706F), A                  ; RAM $706F
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      ($706D), HL                 ; RAM $706D
    INC     IX
    INC     IX
    INC     IX
    LD      ($7070), IX                 ; RAM $7070
    JR      LOC_80C7

NMI:                                        ; NMI: fired by TMS9918A VBLANK; active NMI with JP (IX) dispatch
    CALL    SUB_8251                        ; NMI prologue: save all regs, then JP (IX) to frame body
    LD      A, ($7007)                      ; Load $7007 — player-alive / game-running flag
    AND     A
    JR      Z, LOC_8122                     ; Skip game main-loop if player dead ($7007 = 0)
    LD      A, ($7067)                      ; Load $7067 — game-active flag (0 = attract mode)
    AND     A
    CALL    Z, SUB_8E50                     ; Call game main-loop dispatch stub if game is running

LOC_8122:                                   ; LOC_8122: NMI body executed every frame regardless of game state
    CALL    SUB_B344                        ; Advance 4 sound channels (SN76489A sequence player)
    LD      A, $01                          ; Value $01 — VBL-done flag
    LD      ($7062), A                      ; $7062 = 1: signal main loop that VBL occurred
    LD      HL, $706A                       ; Point HL to $706A — absolute frame counter (never wraps)
    INC     (HL)                            ; Increment absolute frame counter $706A
    LD      A, ($7061)                      ; Load $7061 — 8-bit frame counter
    INC     A
    LD      ($7061), A                      ; $7061 incremented every NMI (wraps at 256)
    LD      A, ($706B)                      ; Load $706B — 4-frame sub-counter for sprite animation
    INC     A
    AND     $03                             ; Mask to 2 bits → 4-frame cycle (0-1-2-3-0...)
    LD      ($706B), A                      ; $706B = (old+1) & 3
    CALL    SUB_C85F                        ; DEC $7057 anim counter; update main sprite pos from $7138/$7154
    CALL    SUB_825B                        ; NMI epilogue: restore all regs, EX (SP),IX, RET
    RETN                                    ; Return from NMI with interrupt re-enable

SUB_8146:                                   ; SUB_8146: game frame body — called from main loop; renders all layers
    CALL    VDP_REG_818D                    ; Disable TMS9918A display before VRAM writes
    CALL    VDP_REG_8EF2                    ; Screen flash effect using XOR on $7140 / VDP colour register
    CALL    VDP_REG_DD80                    ; Update $7334-$7336 VDP scroll registers
    LD      A, ($7138)                      ; Load $7138 — player X scroll position (low byte)
    LD      L, A
    LD      H, $00
    LD      DE, ($7154)                     ; Load $7154 — world scroll accumulator
    ADD     HL, DE
    LD      A, H
    AND     $03                             ; Mask H to 2 bits (world wraps every $400 pixels)
    LD      H, A
    LD      ($72D6), HL                     ; $72D6 = ($7138 + $7154) & $03FF — absolute sprite X position
    CALL    VDP_REG_A9D6                    ; Swap $7182/$7185 sprite planes; write VDP colour register
    CALL    SUB_8E54                        ; Clear sprite VRAM strips (erase previous frame sprites)
    CALL    SUB_8E6A                        ; Write player sprite data to VRAM $1B00
    CALL    SUB_8E57                        ; Write background scroll tile row to VRAM
    LD      A, ($701E)                      ; Load $701E — number of active player bullets
    AND     A
    CALL    NZ, SUB_800C                    ; Write player ship graphic (if alive)
    CALL    SUB_8E63                        ; Write 8 bullet sprites to VRAM $1B08 + enemy sprites
    CALL    SUB_8E5D                        ; Advance sprite animation frame for current anim sequence
    CALL    SUB_8E5A                        ; Collision detection: check 4 collision zones
    CALL    SUB_8E60                        ; Update missile/score tiles in VRAM from $7228 entries
    CALL    SOUND_WRITE_AEF9                ; Sound effect playback via SN76489A (VRAM XOR method)
    CALL    SUB_8E75                        ; Enemy and bullet physics update (LOC_D630)
    CALL    VDP_REG_C8D9                    ; Clear $7150 display flag if set
    CALL    VDP_REG_8196                    ; Enable TMS9918A display after all VRAM writes done
    RET     

VDP_REG_818D:                               ; VDP_REG_818D: disable TMS9918A display — write reg 1 = $C0 (display off)
    LD      A, $C0                          ; Value $C0 — VDP register 1: display off, 16KB VRAM, no interrupts
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $81                          ; Register address $81 = write to reg 1
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET                                     ; Return after disabling display

VDP_REG_8196:                               ; VDP_REG_8196: enable TMS9918A display — write reg 1 = $E0 (display on)
    LD      A, $E0                          ; Value $E0 — VDP register 1: display on, sprites enabled, 16KB VRAM
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $81
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     
    DB      $CD, $4F, $84, $CD, $9A, $84, $CD, $81
    DB      $80, $CD, $F7, $81, $3A, $67, $70, $A7
    DB      $28, $28, $CD, $C7, $BD, $3A, $07, $70
    DB      $A7, $20, $0D, $AF, $D3, $BF, $3E, $87
    DB      $D3, $BF, $CD, $44, $C7, $CD, $8E, $B9
    DB      $3A, $1C, $70, $3D, $32, $1C, $70, $20
    DB      $03, $C3, $EC, $84, $CD, $8D, $81, $C3
    DB      $54, $80, $3A, $07, $70, $A7, $20, $13
    DB      $AF, $D3, $BF, $3E, $87, $D3, $BF, $CD
    DB      $44, $C7, $CD, $8D, $81, $CD, $8E, $B9
    DB      $C3, $54, $80, $CD, $81, $80, $18, $A8
    DB      $3A, $3B, $71, $A7, $C8, $CD, $E8, $B2
    DB      $3E, $A0, $D3, $BF, $3E, $81, $D3, $BF
    DB      $01, $24, $F4, $0B, $78, $B1, $20, $FB
    DB      $D3, $80, $E3, $E3, $DB, $FC, $2F, $E6
    DB      $7F, $FE, $09, $20, $F3, $3E, $E0, $D3
    DB      $BF, $3E, $81, $D3, $BF, $01, $24, $F4
    DB      $0B, $78, $B1, $20, $FB, $AF, $32, $3B
    DB      $71, $32, $62, $70, $DB, $BF, $CD, $96
    DB      $81, $C9, $ED, $5B, $54, $71, $ED, $53
    DB      $D9, $72, $CD, $7E, $8E, $CD, $7B, $8E
    DB      $3E, $01, $32, $6F, $70, $CD, $81, $80
    DB      $18, $E8

SUB_8251:                                   ; SUB_8251: NMI prologue — save all regs then JP (IX) to frame handler
    EX      (SP), IX                        ; EX (SP),IX: swap return address with IX (IX ← return addr)
    PUSH    IY                              ; Save IY (sprite table pointer)
    PUSH    AF                              ; Save AF (accumulator + flags)
    PUSH    HL                              ; Save HL
    PUSH    DE                              ; Save DE
    PUSH    BC                              ; Save BC
    JP      (IX)                            ; Indirect dispatch: jump to address stored in IX (return addr)

SUB_825B:                                   ; SUB_825B: NMI epilogue — restore all regs and return from frame
    POP     IX                              ; Pop BC … IY (reverse order of SUB_8251 pushes)
    POP     BC
    POP     DE
    POP     HL
    POP     AF
    POP     IY
    EX      (SP), IX                        ; EX (SP),IX: restore original return address onto stack
    RET                                     ; RET: resume interrupted code

VDP_REG_8266:                               ; VDP_REG_8266: init all 8 VDP registers from table at $8278
    LD      HL, $8278                       ; Point HL to VDP init table (8 value bytes)
    LD      C, $80                          ; C = $80: first register address (reg 0)
    LD      B, $08                          ; B = 8: write 8 registers

LOC_826D:                                   ; LOC_826D: write one value, advance register address
    LD      A, (HL)
    INC     HL
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, C
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    INC     C
    DJNZ    LOC_826D
    RET     
    DB      $02, $80, $06, $7F, $07, $36, $07, $11

VDP_REG_8280:                               ; VDP_REG_8280: set VRAM write address from HL (HL | $4000)
    LD      A, L                            ; Write low byte of address to CTRL_PORT
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H                            ; OR $40 to set VRAM-write bit in address high byte
    OR      $40                             ; Write high byte (with write flag) to CTRL_PORT
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     

VDP_REG_8289:                               ; VDP_REG_8289: set VRAM read address from HL (no $40 flag needed)
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    NOP                                     ; Two NOPs: TMS9918A setup time before read
    NOP     
    RET     

LOC_8292:
    DEC     HL
    LD      (HL), D
    DEC     HL
    LD      (HL), E
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

VDP_DATA_829D:                              ; VDP_DATA_829D: full VRAM clear + RAM clear + load tile data from ROM
    LD      A, $00                          ; Clear $701B — game mode index (reset to 0)
    LD      ($701B), A                  ; RAM $701B
    LD      HL, JOYSTICK_BUFFER             ; Set VRAM write address to $0000
    CALL    VDP_REG_8280
    LD      BC, $4000                       ; BC = $4000 — clear all 16 KB of VRAM

LOC_82AB:
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_82AB
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    PUSH    AF
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    LD      BC, $0380

LOC_82BD:
    XOR     A
    LD      (HL), A
    INC     HL
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_82BD
    POP     AF
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    LD      A, $08
    LD      ($7016), A                  ; RAM $7016
    LD      A, $03
    LD      ($7015), A                  ; RAM $7015
    LD      DE, $929D
    LD      HL, $3800
    LD      BC, $0068
    CALL    VDP_DATA_8E84
    LD      DE, $9305
    LD      HL, $3880
    LD      BC, $0320
    CALL    VDP_DATA_8E84
    LD      DE, $9A6D
    LD      HL, $2320
    LD      BC, $0050
    CALL    VDP_DATA_8E84
    LD      E, $F0
    LD      HL, $0320
    LD      BC, $0050
    CALL    VDP_DATA_8E91
    LD      DE, $9B5D
    LD      HL, $2370
    LD      BC, $0010
    CALL    VDP_DATA_8E84
    LD      DE, $9B6D
    LD      HL, $0370
    LD      BC, $0010
    CALL    VDP_DATA_8E84
    LD      DE, $9A6D
    LD      HL, $2850
    LD      BC, $00F0
    CALL    VDP_DATA_8E84
    LD      E, $30
    LD      HL, $0850
    LD      BC, $00F0
    CALL    VDP_DATA_8E91
    LD      DE, $9625
    LD      HL, $3000
    LD      BC, $0258
    CALL    VDP_DATA_8E84
    LD      E, $60
    LD      HL, $1000
    LD      BC, $0258
    CALL    VDP_DATA_8E91
    LD      DE, $987D
    LD      HL, $26C0
    LD      BC, $0020
    CALL    VDP_DATA_8E84
    LD      DE, $989D
    LD      HL, $06C0
    LD      BC, $0020
    CALL    VDP_DATA_8E84
    LD      DE, $987D
    LD      HL, $2EC0
    LD      BC, $0020
    CALL    VDP_DATA_8E84
    LD      DE, $989D
    LD      HL, $0EC0
    LD      BC, $0020
    CALL    VDP_DATA_8E84
    LD      DE, $987D
    LD      HL, $36C0
    LD      BC, $0020
    CALL    VDP_DATA_8E84
    LD      DE, $989D
    LD      HL, $16C0
    LD      BC, $0020
    CALL    VDP_DATA_8E84
    LD      DE, $9A0D
    LD      HL, $2690
    LD      BC, $0030
    CALL    VDP_DATA_8E84
    LD      DE, $9A3D
    LD      HL, $0690
    LD      BC, $0030
    CALL    VDP_DATA_8E84
    LD      DE, $9A0D
    LD      HL, $2E90
    LD      BC, $0030
    CALL    VDP_DATA_8E84
    LD      DE, $9A3D
    LD      HL, $0E90
    LD      BC, $0030
    CALL    VDP_DATA_8E84
    LD      DE, $9A0D
    LD      HL, $3690
    LD      BC, $0030
    CALL    VDP_DATA_8E84
    LD      DE, $9A3D
    LD      HL, $1690
    LD      BC, $0030
    CALL    VDP_DATA_8E84
    CALL    SUB_8E9D
    CALL    SUB_AF58
    CALL    VDP_DATA_8F0C
    CALL    SUB_C1AE
    LD      DE, $8239
    LD      IX, $70D4                   ; RAM $70D4
    LD      HL, $70D4                   ; RAM $70D4
    CALL    LOC_8292
    LD      DE, $819F
    LD      IX, $7136                   ; RAM $7136
    LD      HL, $7136                   ; RAM $7136
    CALL    LOC_8292
    LD      HL, $8024
    LD      ($7070), HL                 ; RAM $7070
    LD      DE, $2020
    LD      ($7138), DE                 ; RAM $7138
    LD      A, $05
    LD      ($701C), A                  ; RAM $701C
    LD      ($701D), A                  ; RAM $701D
    LD      BC, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SUB_DDE4
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     7, A
    RET     Z
    SET     0, A
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    CALL    SUB_B992
    LD      BC, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    CALL    SUB_DDE4
    CALL    VDP_DATA_844F
    CALL    VDP_DATA_849A
    LD      A, $01
    LD      ($7037), A                  ; RAM $7037
    LD      ($7067), A                  ; RAM $7067
    CALL    SUB_862E
    LD      HL, $701F                   ; RAM $701F
    LD      DE, $7007                   ; RAM $7007
    LD      BC, $0018
    LDIR    
    LD      HL, WORK_BUFFER             ; WORK_BUFFER
    SET     0, (HL)
    RET     

VDP_DATA_844F:                              ; VDP_DATA_844F: draw player-lives icons to VRAM name table $1800/$1C00
    LD      DE, $0021                       ; DE = $0021 — P1 column offset in name table
    LD      A, (WORK_BUFFER)                ; Check WORK_BUFFER bit 0: 1 = two-player game
    BIT     0, A
    JR      Z, LOC_845C
    LD      DE, $003A                       ; DE = $003A — P2 column offset if two-player mode

LOC_845C:
    LD      C, $05                          ; C = 5: max lives icons to draw
    LD      A, ($701C)                      ; Load $701C — current lives count
    DEC     A
    RET     M
    JR      Z, LOC_8481
    LD      B, A

LOC_8466:
    LD      HL, $1800
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      A, $6E
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1C00
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      A, $6E
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     C
    RET     Z
    INC     DE
    DJNZ    LOC_8466

LOC_8481:
    LD      B, C

LOC_8482:
    LD      HL, $1800
    ADD     HL, DE
    CALL    VDP_REG_8280
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1C00
    ADD     HL, DE
    CALL    VDP_REG_8280
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     DE
    DJNZ    LOC_8482
    RET     

VDP_DATA_849A:                              ; VDP_DATA_849A: draw shield/special-weapon icons to VRAM $1800/$1C00
    LD      DE, $0006                       ; DE = $0006 — P1 icon column offset
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     0, A                            ; Check WORK_BUFFER bit 0 for 2-player mode
    JR      Z, LOC_84A7
    LD      DE, $0019

LOC_84A7:
    LD      C, $03                          ; C = 3: max icons
    LD      A, ($701D)                      ; Load $701D — current shield/weapon count
    AND     A
    JR      Z, LOC_84CF
    LD      B, A

LOC_84B0:
    LD      HL, $1800
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      A, $6F
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1C00
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      A, $6F
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     C
    RET     Z
    LD      HL, $0020
    ADD     HL, DE
    DB      $EB
    DJNZ    LOC_84B0

LOC_84CF:
    LD      B, C

LOC_84D0:
    LD      HL, $1800
    ADD     HL, DE
    CALL    VDP_REG_8280
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1C00
    ADD     HL, DE
    CALL    VDP_REG_8280
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $0020
    ADD     HL, DE
    DB      $EB
    DJNZ    LOC_84D0
    RET     
    DB      $CD, $8D, $81, $CD, $E8, $B2, $AF, $D3
    DB      $BF, $3E, $87, $D3, $BF, $21, $00, $1B
    DB      $CD, $80, $82, $3E, $D0, $D3, $BE, $3E
    DB      $06, $D3, $BF, $3E, $82, $D3, $BF, $21
    DB      $80, $18, $CD, $80, $82, $01, $80, $02
    DB      $AF, $D3, $BE, $0B, $78, $B1, $20, $F8
    DB      $21, $87, $19, $CD, $80, $82, $06, $12
    DB      $21, $69, $85, $7E, $23, $D3, $BE, $10
    DB      $FA, $3A, $00, $70, $CB, $7F, $28, $18
    DB      $CB, $47, $20, $04, $CB, $B7, $18, $02
    DB      $CB, $AF, $32, $00, $70, $CD, $B7, $86
    DB      $3A, $00, $70, $E6, $60, $C2, $54, $80
    DB      $06, $05, $11, $00, $00, $D3, $80, $E3
    DB      $E3, $DB, $FC, $2F, $E6, $06, $FE, $06
    DB      $CA, $42, $80, $1B, $7A, $B3, $20, $ED
    DB      $10, $E8, $C3, $42, $80, $25, $00, $14
    DB      $00, $1C, $00, $1A, $00, $00, $00, $00
    DB      $1B, $00, $19, $00, $1A, $00, $26

VDP_DATA_857B:                              ; VDP_DATA_857B: bulk tile/sprite bitmap transfer to VRAM (title screen)
    LD      HL, $1B00
    CALL    VDP_REG_8280
    LD      A, $D0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $2000
    LD      DE, $8AC0
    LD      BC, $01A0
    CALL    VDP_DATA_8E84
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    LD      BC, $01A0
    LD      E, $E0
    CALL    VDP_DATA_8E91
    LD      HL, $2800
    LD      DE, $8AC0
    LD      BC, $01A0
    CALL    VDP_DATA_8E84
    LD      HL, $0800
    LD      BC, $01A0
    LD      E, $E0
    CALL    VDP_DATA_8E91
    LD      HL, $29E0
    LD      DE, $8C58
    LD      BC, $01F8
    CALL    VDP_DATA_8E84
    LD      HL, $09E0
    LD      BC, $01F8
    LD      E, $F0
    CALL    VDP_DATA_8E91
    LD      HL, $3000
    LD      DE, $8978
    LD      BC, $0150
    CALL    VDP_DATA_8E84
    LD      HL, $1008
    LD      BC, $0150
    LD      E, $A6
    CALL    VDP_DATA_8E91
    LD      HL, $1000
    LD      BC, $0008
    LD      E, $00
    CALL    VDP_DATA_8E91
    LD      HL, $31E0
    LD      DE, $8C58
    LD      BC, $01F8
    CALL    VDP_DATA_8E84
    LD      HL, $11E0
    LD      BC, $01F8
    LD      E, $F0
    CALL    VDP_DATA_8E91
    LD      HL, $1800
    CALL    VDP_REG_8280
    LD      HL, $87AF

LOC_860C:
    LD      A, (HL)
    CP      $00
    JR      Z, LOC_861E
    LD      B, A
    INC     HL
    LD      A, (HL)
    INC     HL

LOC_8615:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    NOP     
    DJNZ    LOC_8615
    JR      LOC_860C

LOC_861E:
    CALL    VDP_REG_818D
    LD      B, $0A

LOC_8623:
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER

LOC_8626:
    DEC     DE
    LD      A, D
    OR      E
    JR      NZ, LOC_8626
    DJNZ    LOC_8623
    RET     

SUB_862E:                                   ; SUB_862E: read $7037 game flag; update WORK_BUFFER bits 0/5/6
    LD      A, ($7037)                  ; RAM $7037
    AND     A
    RET     Z
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    AND     A
    RET     Z
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     7, A
    RET     Z
    BIT     0, A
    JR      NZ, LOC_8649
    BIT     5, A
    RET     Z
    SET     0, A
    JR      LOC_864E

LOC_8649:
    BIT     6, A
    RET     Z
    RES     0, A

LOC_864E:
    LD      (WORK_BUFFER), A            ; WORK_BUFFER
    LD      HL, $701F                   ; RAM $701F
    LD      DE, $7007                   ; RAM $7007
    LD      B, $18

LOC_8659:
    LD      A, (DE)
    LD      C, (HL)
    LD      (HL), A
    LD      A, C
    LD      (DE), A
    INC     HL
    INC     DE
    DJNZ    LOC_8659
    LD      HL, $3C00
    LD      DE, $3E00
    LD      BC, $0200

LOC_866B:
    PUSH    BC
    CALL    VDP_REG_8289
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    LD      C, A
    DB      $EB
    CALL    VDP_REG_8289
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    PUSH    AF
    CALL    VDP_REG_8280
    LD      A, C
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DB      $EB
    CALL    VDP_REG_8280
    POP     AF
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     HL
    INC     DE
    POP     BC
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_866B
    RET     

VDP_WRITE_868F:                             ; VDP_WRITE_868F: write UI panel row (score/lives header) to VRAM
    LD      A, ($7037)                  ; RAM $7037
    AND     A
    RET     Z
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    BIT     7, A
    RET     Z
    LD      HL, $1B00
    CALL    VDP_REG_8280
    LD      A, $D0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1880
    LD      E, $00
    LD      BC, $0280
    CALL    VDP_DATA_8E91
    LD      A, $06
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $82
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, (WORK_BUFFER)            ; WORK_BUFFER
    LD      DE, $86DA
    BIT     0, A
    JR      Z, LOC_86C4
    LD      DE, $86E4

LOC_86C4:
    LD      HL, $190B
    LD      BC, $000A
    CALL    VDP_DATA_8E84
    LD      B, $06

LOC_86CF:
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER

LOC_86D2:
    DEC     DE
    LD      A, D
    OR      E
    JR      NZ, LOC_86D2
    DJNZ    LOC_86CF
    RET     
    DB      $1D, $1E, $14, $27, $1A, $26, $00, $1B
    DB      $21, $1A, $1D, $1E, $14, $27, $1A, $26
    DB      $00, $15, $18, $1B

VDP_WRITE_86EE:                             ; VDP_WRITE_86EE: draw title/attract-mode splash screen panels to VRAM
    LD      HL, $1B00                       ; Set VRAM write addr to $1B00 (sprite attribute table row 0)
    CALL    VDP_REG_8280
    LD      A, $D0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      DE, $15A3
    LD      HL, $2800
    LD      BC, $0300
    CALL    VDP_DATA_8E84                   ; Copy title panel data from ROM to VRAM $2800 area
    LD      HL, $1800
    LD      E, $00
    LD      BC, $0300
    CALL    VDP_DATA_8E91
    LD      A, $04
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      HL, $0800
    LD      E, $F0
    LD      BC, $0300
    CALL    VDP_DATA_8E91
    LD      HL, $1904
    LD      DE, $877D
    LD      BC, $0019
    PUSH    BC
    CALL    VDP_DATA_8E84
    POP     BC
    LD      HL, $1964
    LD      DE, $8796
    CALL    VDP_DATA_8E84
    NOP     
    NOP     
    LD      A, $06
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $82
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      HL, $0064

LOC_8746:                                   ; LOC_8746: outer delay loop — wait for joystick press on title screen
    LD      DE, JOYSTICK_BUFFER             ; DE = JOYSTICK_BUFFER (start of delay counter)

LOC_8749:                                   ; LOC_8749: inner poll loop — set keypad mode
    LD      A, $80                          ; Write $80 to KEYBOARD_PORT: select keypad input mode
    OUT     ($80), A                    ; KEYBOARD_PORT - set keypad mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                        ; Read controller 1 port ($FC)
    CP      $7D                             ; Check for fire/start button code $7D
    JR      Z, LOC_876D
    CP      $77
    JR      Z, LOC_8773
    IN      A, ($FF)                        ; Read controller 2 (port $FF)
    CP      $7D
    JR      Z, LOC_876D
    CP      $77
    JR      Z, LOC_8773
    DEC     DE                              ; Decrement DE loop counter (inner)
    LD      A, E
    OR      D
    JR      NZ, LOC_8749
    DEC     HL                              ; Decrement HL loop counter (outer)
    LD      A, L
    OR      H
    JR      NZ, LOC_8746

LOC_876D:                                   ; LOC_876D: no button pressed — set WORK_BUFFER = $00 (1-player default)
    LD      HL, WORK_BUFFER                 ; Point HL to WORK_BUFFER
    LD      (HL), $00                       ; Clear WORK_BUFFER: single-player attract mode
    RET     

LOC_8773:                                   ; LOC_8773: start button pressed — set WORK_BUFFER = $E0 (2-player bits)
    LD      HL, WORK_BUFFER                 ; Point HL to WORK_BUFFER
    LD      (HL), $80                       ; Set WORK_BUFFER bit 7: start-button latched
    SET     6, (HL)                         ; Set bit 6: player 2 present
    SET     5, (HL)                         ; Set bit 5: multiplayer flag
    RET     
    DB      $30, $32, $25, $33, $33, $00, $11, $00
    DB      $26, $2F, $32, $00, $11, $00, $30, $2C
    DB      $21, $39, $25, $32, $00, $27, $21, $2D
    DB      $25, $30, $32, $25, $33, $33, $00, $12
    DB      $00, $26, $2F, $32, $00, $12, $00, $30
    DB      $2C, $21, $39, $25, $32, $00, $27, $21
    DB      $2D, $25, $20, $00, $0E, $00, $01, $01
    DB      $01, $02, $01, $03, $01, $04, $0E, $00
    DB      $0E, $00, $01, $05, $01, $07, $01, $09
    DB      $01, $0B, $0E, $00, $0E, $00, $01, $06
    DB      $01, $08, $01, $0A, $01, $0C, $0E, $00
    DB      $0E, $00, $01, $0E, $01, $10, $01, $12
    DB      $01, $14, $0E, $00, $0D, $00, $01, $0D
    DB      $01, $0F, $01, $11, $01, $13, $01, $15
    DB      $01, $16, $0D, $00, $0D, $00, $01, $18
    DB      $01, $1A, $01, $1C, $01, $1E, $01, $20
    DB      $01, $22, $0D, $00, $0C, $00, $01, $17
    DB      $01, $19, $01, $1B, $01, $1D, $01, $1F
    DB      $01, $21, $01, $23, $01, $24, $0C, $00
    DB      $0A, $00, $01, $25, $01, $27, $01, $29
    DB      $01, $2B, $01, $00, $01, $1D, $01, $1F
    DB      $01, $00, $01, $2C, $01, $2D, $01, $2F
    DB      $01, $31, $0A, $00, $0A, $00, $01, $26
    DB      $01, $28, $01, $2A, $01, $00, $01, $00
    DB      $01, $1D, $01, $1F, $01, $00, $01, $00
    DB      $01, $2E, $01, $30, $01, $32, $0A, $00
    DB      $20, $00, $20, $00, $0B, $00, $01, $40
    DB      $01, $41, $01, $42, $01, $43, $01, $44
    DB      $01, $45, $01, $00, $01, $46, $01, $47
    DB      $01, $48, $01, $49, $01, $3C, $01, $3E
    DB      $08, $00, $0B, $00, $01, $4A, $01, $4B
    DB      $01, $4C, $01, $4D, $01, $4E, $01, $4F
    DB      $01, $50, $01, $51, $01, $52, $01, $53
    DB      $01, $54, $01, $3D, $01, $3F, $08, $00
    DB      $0A, $00, $01, $55, $01, $56, $01, $57
    DB      $01, $58, $01, $59, $01, $5A, $01, $5B
    DB      $01, $5C, $01, $5D, $01, $5E, $01, $5F
    DB      $01, $60, $0A, $00, $0A, $00, $01, $61
    DB      $01, $62, $01, $63, $01, $64, $01, $65
    DB      $01, $66, $01, $67, $01, $68, $01, $69
    DB      $01, $6A, $01, $6B, $01, $6C, $02, $00
    DB      $01, $6D, $01, $6E, $01, $6F, $01, $70
    DB      $01, $71, $01, $72, $01, $73, $01, $74
    DB      $18, $00, $01, $75, $01, $76, $01, $77
    DB      $01, $78, $01, $79, $01, $7A, $02, $00
    DB      $60, $00, $08, $00, $01, $01, $01, $02
    DB      $01, $09, $01, $0A, $01, $11, $01, $12
    DB      $01, $09, $01, $0A, $01, $19, $01, $1A
    DB      $01, $01, $01, $02, $01, $09, $01, $0A
    DB      $01, $21, $01, $22, $08, $00, $08, $00
    DB      $01, $03, $01, $04, $01, $0B, $01, $0C
    DB      $01, $13, $01, $14, $01, $0B, $01, $0C
    DB      $01, $1B, $01, $1C, $01, $03, $01, $04
    DB      $01, $0B, $01, $0C, $01, $23, $01, $24
    DB      $08, $00, $08, $00, $01, $05, $01, $06
    DB      $01, $0D, $01, $0E, $01, $15, $01, $16
    DB      $01, $0D, $01, $0E, $01, $1D, $01, $1E
    DB      $01, $05, $01, $06, $01, $0D, $01, $0E
    DB      $01, $25, $01, $26, $08, $00, $08, $00
    DB      $01, $07, $01, $08, $01, $0F, $01, $10
    DB      $01, $17, $01, $18, $01, $0F, $01, $10
    DB      $01, $1F, $01, $20, $01, $07, $01, $08
    DB      $01, $0F, $01, $10, $01, $27, $01, $28
    DB      $08, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $7F, $7F, $7F, $7F, $7F
    DB      $7F, $78, $78, $E0, $F0, $FC, $FE, $FE
    DB      $FE, $FF, $3F, $78, $78, $78, $78, $78
    DB      $78, $78, $78, $3F, $1F, $1F, $1F, $1F
    DB      $1F, $1F, $1F, $78, $78, $78, $78, $78
    DB      $78, $78, $78, $1F, $1F, $1F, $1F, $1F
    DB      $1F, $1F, $3F, $78, $78, $7F, $7F, $7F
    DB      $7F, $7F, $7F, $3F, $7F, $FE, $FE, $FC
    DB      $FC, $F8, $C0, $7F, $7F, $7F, $7F, $7F
    DB      $7F, $78, $78, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $00, $00, $78, $78, $78, $78, $78
    DB      $7F, $7F, $7F, $00, $00, $00, $00, $00
    DB      $F0, $F0, $F0, $7F, $7F, $7F, $78, $78
    DB      $78, $78, $78, $F0, $F0, $F0, $00, $00
    DB      $00, $00, $00, $78, $78, $7F, $7F, $7F
    DB      $7F, $7F, $7F, $00, $00, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $7F, $7F, $7F, $7F, $7F
    DB      $7F, $78, $78, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $00, $00, $78, $78, $78, $78, $78
    DB      $7F, $7F, $7F, $00, $00, $00, $00, $00
    DB      $F0, $F0, $F0, $7F, $7F, $7F, $78, $78
    DB      $78, $78, $78, $F0, $F0, $F0, $00, $00
    DB      $00, $00, $00, $78, $78, $78, $78, $78
    DB      $78, $78, $78, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $78, $7C, $7C, $7E, $7E
    DB      $7E, $7F, $7F, $1F, $1F, $1F, $1F, $1F
    DB      $1F, $1F, $1F, $7F, $7F, $7F, $7F, $7F
    DB      $7F, $7F, $7F, $9F, $9F, $DF, $DF, $DF
    DB      $FF, $FF, $FF, $7F, $7B, $7B, $7B, $79
    DB      $79, $78, $78, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $78, $78, $78, $78, $78
    DB      $78, $78, $78, $7F, $7F, $7F, $3F, $3F
    DB      $1F, $1F, $1F, $7F, $7F, $7F, $7F, $7F
    DB      $7F, $78, $78, $E0, $F8, $FC, $FC, $FE
    DB      $FE, $7E, $3E, $78, $78, $78, $78, $78
    DB      $78, $7F, $7F, $3E, $3E, $3E, $7E, $FE
    DB      $FE, $FC, $F8, $7F, $7F, $7B, $7B, $79
    DB      $79, $78, $78, $F0, $E0, $E0, $E0, $F0
    DB      $F0, $F8, $F8, $78, $78, $78, $78, $78
    DB      $78, $78, $78, $7C, $7C, $7C, $3E, $3E ; "xxx|||>>"
    DB      $1E, $1E, $1E, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $0F, $0F, $0F
    DB      $0F, $0F, $0F, $00, $00, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $00, $00, $F9, $F9, $F9
    DB      $F9, $F9, $F9, $00, $00, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $0F, $0F, $0F, $0F, $0F
    DB      $0F, $0F, $0F, $0F, $0F, $0F, $0F, $1F
    DB      $1F, $1F, $1F, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $F9, $F9, $F9, $F9, $F9
    DB      $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9
    DB      $F9, $F9, $F9, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F8
    DB      $F8, $F8, $F8, $00, $00, $00, $00, $00
    DB      $00, $01, $01, $1F, $1F, $1F, $1F, $3F
    DB      $3F, $3F, $3F, $7F, $7F, $7F, $FF, $FF
    DB      $FF, $FF, $FF, $9F, $9F, $9F, $9F, $9F
    DB      $9F, $9F, $9F, $9F, $9F, $1F, $1F, $1F
    DB      $1F, $1F, $1F, $F9, $F9, $F9, $F9, $F9
    DB      $F9, $F9, $F9, $F9, $F9, $F8, $F8, $F8
    DB      $F8, $F8, $F8, $F8, $F8, $F8, $F8, $FC
    DB      $FC, $FC, $FC, $FE, $FE, $FE, $FF, $FF
    DB      $FF, $FF, $FF, $00, $00, $00, $00, $00
    DB      $00, $80, $80, $00, $00, $01, $03, $07
    DB      $0F, $1F, $7F, $03, $03, $07, $07, $0F
    DB      $0F, $1F, $3F, $7F, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FE, $FE, $FE, $FE, $FC
    DB      $FC, $FC, $F8, $F8, $F0, $F0, $E0, $E0
    DB      $C0, $C0, $80, $1F, $1F, $1F, $1F, $1F
    DB      $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F
    DB      $1F, $1F, $1F, $F8, $F8, $F8, $F8, $F8
    DB      $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8
    DB      $F8, $F8, $F8, $7F, $7F, $7F, $7F, $3F
    DB      $3F, $3F, $1F, $1F, $0F, $0F, $07, $07
    DB      $03, $03, $01, $C0, $C0, $E0, $E0, $F0
    DB      $F0, $F8, $FC, $FE, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $00, $00, $80, $C0, $E0
    DB      $F0, $F8, $FE, $00, $00, $00, $00, $03
    DB      $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    DB      $0F, $0F, $0E, $01, $07, $1F, $7F, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $F8, $C0, $00, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FC, $F0, $C0, $00
    DB      $00, $00, $00, $FF, $FE, $FC, $F8, $F0
    DB      $E0, $C0, $80, $FF, $7F, $3F, $1F, $0F
    DB      $07, $03, $01, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $3F, $0F, $03, $00
    DB      $00, $00, $00, $80, $E0, $F8, $FE, $FF
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $1F, $03, $00, $00, $00, $00, $00, $C0
    DB      $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $70, $3F, $40, $9C, $92, $92
    DB      $9C, $94, $92, $40, $3F, $00, $00, $00
    DB      $00, $00, $00, $00, $80, $40, $40, $40
    DB      $40, $40, $40, $80, $00, $00, $00, $00
    DB      $00, $00, $00, $07, $0F, $0F, $1F, $1F
    DB      $1F, $3F, $3F, $80, $C0, $C0, $E0, $E0
    DB      $E0, $F0, $F0, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $03, $03, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $F0, $F0, $C0, $C0, $C0, $C1, $C1
    DB      $C1, $03, $03, $78, $FC, $FC, $FE, $FE
    DB      $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FC, $FC, $F8, $FE, $FF, $FF, $FF
    DB      $FF, $1F, $0F, $03, $03, $03, $83, $C3
    DB      $C3, $E3, $E3, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $3F, $3F, $7C, $7C, $7C
    DB      $FC, $F8, $F8, $F0, $F0, $F8, $F8, $F8
    DB      $FC, $7C, $7C, $03, $03, $03, $03, $03
    DB      $03, $03, $03, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $03, $03, $07, $07, $07
    DB      $0F, $0F, $0F, $FF, $FF, $CF, $CF, $CF
    DB      $CF, $87, $87, $00, $00, $80, $80, $80
    DB      $C0, $C0, $C0, $FC, $FC, $FC, $FC, $FC
    DB      $FC, $FC, $FC, $07, $07, $07, $0F, $0F
    DB      $1F, $3F, $7F, $E3, $E3, $E3, $C3, $C3
    DB      $83, $83, $03, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $00, $01, $01, $01, $01
    DB      $03, $03, $03, $F8, $F8, $FF, $FF, $FF
    DB      $FF, $FF, $E0, $7C, $7E, $FE, $FE, $FE
    DB      $FF, $FF, $1F, $03, $03, $03, $03, $03
    DB      $03, $03, $03, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $0F, $1F, $1F, $1F, $1F
    DB      $3F, $3F, $3E, $87, $87, $FF, $FF, $FF
    DB      $FF, $FF, $01, $C0, $E0, $E0, $E0, $E0
    DB      $F0, $F0, $F0, $FC, $FD, $FD, $FC, $FC
    DB      $FC, $FC, $FC, $FE, $FC, $FC, $FC, $FE
    DB      $7E, $7F, $3F, $03, $03, $03, $03, $03
    DB      $03, $03, $03, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $03, $07, $07, $07, $07
    DB      $0F, $0F, $00, $E0, $E0, $E0, $C0, $C0
    DB      $C0, $C0, $00, $1F, $1F, $1F, $0F, $0F
    DB      $0F, $0F, $00, $03, $83, $83, $83, $83
    DB      $C3, $C3, $00, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $00, $3E, $7E, $7E, $7C, $7C
    DB      $FC, $FC, $00, $01, $01, $01, $00, $00
    DB      $00, $00, $00, $F0, $F8, $F8, $F8, $F8
    DB      $FC, $FC, $00, $FC, $FC, $FC, $FC, $FC
    DB      $FC, $FC, $00, $3F, $1F, $1F, $0F, $0F
    DB      $07, $07, $00, $83, $83, $C3, $C3, $E3
    DB      $E3, $F3, $00, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $00, $3C, $42, $99, $A1, $A1
    DB      $99, $42, $3C, $00, $2E, $2A, $2A, $2E
    DB      $22, $22, $00, $00, $EE, $AA, $AA, $EA
    DB      $AA, $EE, $00, $00, $20, $20, $11, $15
    DB      $0A, $0A, $00, $00, $A8, $A8, $28, $28
    DB      $28, $2E, $00, $00, $89, $8A, $8A, $8B
    DB      $8A, $EA, $00, $00, $22, $B6, $AA, $A2
    DB      $A2, $A2, $00, $00, $60, $80, $40, $20
    DB      $20, $C0, $00, $3C, $42, $99, $A1, $A1
    DB      $99, $42, $3C, $00, $2E, $2A, $2A, $2E
    DB      $22, $22, $00, $00, $EE, $A2, $A2, $E6
    DB      $A2, $EE, $00, $00, $13, $29, $29, $39
    DB      $29, $29, $00, $00, $93, $2A, $2A, $3B
    DB      $2A, $2A, $00, $00, $20, $A0, $A0, $20
    DB      $A0, $A0, $00

SUB_8E50:                                   ; SUB_8E50: dispatch stub — game main-loop controller input (LOC_AFCF)
    JP      LOC_AFCF                        ; JP LOC_AFCF: 9 controller-read functions (sticks + fire + smartbomb)
    DB      $C9

SUB_8E54:                                   ; SUB_8E54: dispatch stub — clear sprite VRAM strips (LOC_AA02)
    JP      LOC_AA02                        ; JP LOC_AA02: erase old sprite positions from VRAM

SUB_8E57:                                   ; SUB_8E57: dispatch stub — background scroll write (LOC_AA4B)
    JP      LOC_AA4B                        ; JP LOC_AA4B: write scrolled background tile row to VRAM

SUB_8E5A:                                   ; SUB_8E5A: dispatch stub — collision detection (LOC_AD8E)
    JP      LOC_AD8E                        ; JP LOC_AD8E: check 4 collision zones vs enemy sprite positions

SUB_8E5D:                                   ; SUB_8E5D: dispatch stub — sprite animation frame advance (LOC_9CCD)
    JP      LOC_9CCD                        ; JP LOC_9CCD: update current animation sequence frame pointer

SUB_8E60:                                   ; SUB_8E60: dispatch stub — score/lives display (LOC_ADC1)
    JP      LOC_ADC1                        ; JP LOC_ADC1: update missile/score tiles in VRAM from $7228 entries

SUB_8E63:                                   ; SUB_8E63: dispatch stub — bullet + enemy sprite write (combined)
    CALL    VDP_DATA_ACFA                   ; Write 8 bullet sprites to VRAM $1B08 from $72DE entries
    JP      LOC_AD2D                        ; JP LOC_AD2D: then write 8 enemy sprites to VRAM
    DB      $C9

SUB_8E6A:                                   ; SUB_8E6A: dispatch stub — write player sprite to VRAM (LOC_9B7D)
    JP      LOC_9B7D                        ; JP LOC_9B7D: write player sprite pair at VRAM $1B00

SUB_8E6D:                                   ; SUB_8E6D: dispatch stub — explosion state update (LOC_AEB5)
    JP      LOC_AEB5                        ; JP LOC_AEB5: process 6 explosion objects at $7252
    DB      $C9

SUB_8E71:                                   ; SUB_8E71: dispatch stub — wave/level init (LOC_B8C6)
    JP      LOC_B8C6                        ; JP LOC_B8C6: clear RAM, load anim tables, seed player position
    DB      $C9

SUB_8E75:                                   ; SUB_8E75: dispatch stub — enemy/bullet physics (LOC_D630)
    JP      LOC_D630                        ; JP LOC_D630: update 8 enemy records at $72DE

SUB_8E78:                                   ; SUB_8E78: dispatch stub — title/demo mode (LOC_D3FE)
    JP      LOC_D3FE                        ; JP LOC_D3FE: spawn/update 4 bullet objects in $7207
    DB      $C3, $3F, $D8, $C3, $98, $C9, $C3, $45
    DB      $DB

VDP_DATA_8E84:                              ; VDP_DATA_8E84: copy BC bytes from (DE) to VRAM starting at HL
    CALL    VDP_REG_8280                    ; Set VRAM write address from HL

LOC_8E87:                                   ; LOC_8E87: write loop — OUT ($BE),A; INC DE; DEC BC until done
    LD      A, (DE)
    INC     DE
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_8E87
    RET     

VDP_DATA_8E91:                              ; VDP_DATA_8E91: fill BC VRAM bytes with constant value E at address HL
    CALL    VDP_REG_8280                    ; Set VRAM write address from HL

LOC_8E94:                                   ; LOC_8E94: fill loop — OUT ($BE),E; DEC BC until zero
    LD      A, E
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_8E94
    RET     

SUB_8E9D:                                   ; SUB_8E9D: init sprite colour palette — three colour planes $06E0, $0EE0, $16E0
    LD      HL, $06E0                       ; HL = $06E0: first colour plane VRAM address
    CALL    VDP_DATA_8EB5                   ; Write 280 bytes of sprite colour data to this plane
    LD      HL, $0EE0                       ; HL = $0EE0: second colour plane
    CALL    VDP_DATA_8EB5
    LD      HL, $16E0                       ; HL = $16E0: third colour plane
    CALL    VDP_DATA_8EB5
    LD      A, $0A                          ; LD A, $0A → $701E: set 10 active bullets after init
    LD      ($701E), A                  ; RAM $701E
    RET     

VDP_DATA_8EB5:                              ; VDP_DATA_8EB5: write sprite colour bitmap block to one VRAM colour plane
    DB      $EB
    LD      HL, $2000
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      HL, $98BD
    LD      BC, $0118

LOC_8EC3:
    LD      A, (HL)
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JP      NZ, LOC_8EC3
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      B, $07
    LD      HL, $99D5

LOC_8ED9:
    PUSH    BC
    LD      B, $05

LOC_8EDC:
    PUSH    BC
    PUSH    HL
    LD      B, $08

LOC_8EE0:
    LD      A, (HL)
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_8EE0
    POP     HL
    POP     BC
    DJNZ    LOC_8EDC
    LD      DE, $0008
    ADD     HL, DE
    POP     BC
    DJNZ    LOC_8ED9
    RET     

VDP_REG_8EF2:                               ; VDP_REG_8EF2: screen-flash effect — XOR $7140 flash counter with $0F
    LD      A, ($7140)                      ; Load $7140 — flash counter (0 = no flash active)
    AND     A                               ; Return if flash counter is zero (no flash this frame)
    RET     Z
    LD      A, ($7141)                  ; RAM $7141
    XOR     $0F
    LD      ($7141), A                  ; RAM $7141
    JR      NZ, LOC_8F05
    LD      HL, $7140                   ; RAM $7140
    DEC     (HL)

LOC_8F05:
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     

VDP_DATA_8F0C:
    LD      DE, $8FDD
    LD      HL, $2008
    LD      BC, $0200
    CALL    VDP_DATA_8E84
    LD      HL, $0008
    LD      BC, $0200
    LD      E, $90
    CALL    VDP_DATA_8E91
    LD      DE, $91DD
    LD      HL, $2208
    LD      BC, $0060
    CALL    VDP_DATA_8E84
    LD      DE, $923D
    LD      HL, $0208
    LD      BC, $0060
    CALL    VDP_DATA_8E84
    LD      HL, $1F02
    CALL    VDP_REG_8280
    LD      A, $0C
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    LD      A, $0E
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, FILL_VRAM
    CALL    VDP_REG_8280
    LD      A, $0C
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    LD      A, $0E
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1F6C
    CALL    VDP_DATA_8F74
    LD      HL, $1FEC
    CALL    VDP_DATA_8F74
    LD      HL, $1800
    CALL    VDP_DATA_8F8F
    LD      HL, $1C00
    CALL    VDP_DATA_8F8F
    RET     

VDP_DATA_8F74:
    CALL    VDP_REG_8280
    LD      B, $05

LOC_8F79:
    LD      A, $1C
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    NOP     
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_8F79
    RET     

VDP_DATA_8F8F:
    CALL    VDP_REG_8280
    LD      HL, $8FA4

LOC_8F95:
    LD      A, (HL)
    AND     A
    RET     Z
    LD      B, A
    INC     HL
    LD      A, (HL)
    INC     HL

LOC_8F9C:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_8F9C
    JR      LOC_8F95
    DB      $07, $00, $01, $41, $05, $42, $01, $47
    DB      $04, $4B, $01, $48, $05, $42, $01, $45
    DB      $07, $00, $07, $00, $01, $41, $10, $00
    DB      $01, $45, $07, $00, $07, $00, $01, $41
    DB      $10, $00, $01, $45, $07, $00, $07, $44
    DB      $01, $43, $05, $44, $01, $49, $04, $4C
    DB      $01, $4A, $05, $44, $01, $46, $07, $44
    DB      $00, $00, $00, $00, $FF, $00, $00, $00
    DB      $00, $00, $00, $03, $FC, $00, $00, $00
    DB      $00, $1E, $21, $C0, $00, $00, $00, $00
    DB      $00, $00, $C0, $30, $0E, $01, $00, $00
    DB      $00, $00, $00, $06, $39, $C0, $00, $00
    DB      $00, $00, $00, $00, $00, $81, $7E, $00
    DB      $00, $00, $00, $3C, $43, $80, $00, $00
    DB      $00, $03, $0C, $10, $E0, $00, $00, $00
    DB      $00, $E0, $10, $08, $07, $00, $00, $00
    DB      $00, $00, $00, $00, $83, $4C, $30, $00
    DB      $00, $00, $00, $00, $E0, $1F, $00, $00
    DB      $00, $00, $00, $00, $06, $C9, $30, $00
    DB      $00, $00, $00, $00, $00, $F3, $0C, $00
    DB      $00, $00, $00, $18, $E7, $00, $00, $00
    DB      $00, $00, $01, $02, $3C, $C0, $00, $00
    DB      $00, $00, $F6, $09, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $FF, $00, $00, $00
    DB      $00, $00, $00, $0F, $F0, $00, $00, $00
    DB      $00, $78, $87, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $C0, $38, $07, $00, $00
    DB      $00, $00, $00, $18, $E4, $02, $01, $00
    DB      $00, $00, $00, $00, $01, $06, $F8, $00
    DB      $00, $00, $00, $F0, $0F, $00, $00, $00
    DB      $00, $0F, $30, $40, $80, $00, $00, $00
    DB      $00, $80, $40, $20, $1E, $01, $00, $00
    DB      $00, $00, $00, $00, $0F, $30, $C0, $00
    DB      $00, $00, $00, $00, $80, $7F, $00, $00
    DB      $00, $00, $00, $00, $18, $27, $C0, $00
    DB      $00, $00, $00, $00, $03, $CC, $30, $00
    DB      $00, $00, $00, $60, $9C, $03, $00, $00
    DB      $00, $00, $07, $08, $F0, $00, $00, $00
    DB      $00, $00, $D8, $24, $03, $00, $00, $00
    DB      $00, $00, $00, $00, $FF, $00, $00, $00
    DB      $00, $01, $02, $3C, $C0, $00, $00, $00
    DB      $00, $E0, $1C, $03, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $E3, $1C, $00, $00
    DB      $00, $00, $00, $60, $90, $08, $07, $00
    DB      $00, $00, $00, $03, $04, $18, $E0, $00
    DB      $00, $00, $00, $C1, $3E, $00, $00, $00
    DB      $00, $3E, $C1, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $78, $04, $03, $00
    DB      $00, $00, $00, $00, $3E, $C1, $00, $00
    DB      $00, $00, $00, $00, $00, $FC, $03, $00
    DB      $00, $00, $00, $00, $60, $9F, $00, $00
    DB      $00, $00, $00, $01, $0E, $30, $C0, $00
    DB      $00, $00, $00, $80, $73, $0C, $00, $00
    DB      $00, $00, $1F, $20, $C0, $00, $00, $00
    DB      $00, $00, $60, $90, $0F, $00, $00, $00
    DB      $00, $00, $00, $00, $FF, $00, $00, $00
    DB      $00, $07, $08, $F0, $00, $00, $00, $00
    DB      $00, $80, $70, $0C, $03, $00, $00, $00
    DB      $00, $00, $00, $01, $8E, $70, $00, $00
    DB      $00, $00, $00, $80, $40, $20, $1F, $00
    DB      $00, $00, $00, $0F, $10, $60, $80, $00
    DB      $00, $00, $03, $04, $F8, $00, $00, $00
    DB      $00, $F8, $04, $02, $01, $00, $00, $00
    DB      $00, $00, $00, $00, $E0, $13, $0C, $00
    DB      $00, $00, $00, $00, $F8, $07, $00, $00
    DB      $00, $00, $00, $00, $01, $F2, $0C, $00
    DB      $00, $00, $00, $00, $80, $7C, $03, $00
    DB      $00, $00, $00, $06, $39, $C0, $00, $00
    DB      $00, $00, $00, $00, $CF, $30, $00, $00
    DB      $00, $00, $7D, $82, $00, $00, $00, $00
    DB      $00, $00, $80, $40, $3F, $00, $00, $00
    DB      $00, $0F, $0F, $0F, $0F, $0F, $0F, $0F
    DB      $0F, $FF, $FF, $FF, $FF, $00, $00, $00
    DB      $00, $0F, $0F, $0F, $0F, $FF, $FF, $FF
    DB      $FF, $00, $00, $00, $00, $FF, $FF, $FF
    DB      $FF, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $F0, $F0, $F0, $F0, $FF, $FF, $FF
    DB      $FF, $FC, $FC, $FC, $FC, $03, $03, $03
    DB      $03, $3F, $3F, $3F, $3F, $C0, $C0, $C0
    DB      $C0, $03, $03, $03, $03, $FC, $FC, $FC
    DB      $FC, $C0, $C0, $C0, $C0, $3F, $3F, $3F
    DB      $3F, $FF, $FF, $FF, $FF, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $FF, $FF, $FF
    DB      $FF, $70, $70, $70, $70, $70, $70, $70
    DB      $70, $70, $70, $70, $70, $00, $00, $00
    DB      $00, $70, $70, $70, $70, $70, $70, $70
    DB      $70, $00, $00, $00, $00, $70, $70, $70
    DB      $70, $70, $70, $70, $70, $70, $70, $70 ; "pppppppp"
    DB      $70, $70, $70, $70, $70, $70, $70, $70 ; "pppppppp"
    DB      $70, $7E, $7E, $7E, $7E, $E0, $E0, $E0
    DB      $E0, $7E, $7E, $7E, $7E, $E0, $E0, $E0
    DB      $E0, $E0, $E0, $E0, $E0, $7E, $7E, $7E
    DB      $7E, $E0, $E0, $E0, $E0, $7E, $7E, $7E
    DB      $7E, $E0, $E0, $E0, $E0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $E0, $E0, $E0
    DB      $E0, $7E, $FF, $99, $FF, $7E, $5A, $99
    DB      $99, $18, $5A, $BD, $BD, $BD, $5A, $99
    DB      $99, $3C, $7E, $99, $7E, $00, $00, $00
    DB      $00, $3E, $22, $FA, $AA, $BE, $88, $F8
    DB      $00, $20, $70, $A8, $70, $00, $00, $00
    DB      $00, $A8, $70, $F8, $70, $A8, $00, $00
    DB      $00, $C0, $C0, $00, $00, $00, $00, $00
    DB      $00, $A0, $40, $A0, $00, $00, $00, $00
    DB      $00, $00, $70, $78, $FC, $FF, $FF, $FF
    DB      $78, $00, $00, $00, $00, $C0, $FE, $F0
    DB      $00, $00, $00, $00, $00, $03, $7F, $0F
    DB      $00, $00, $0E, $1E, $3F, $FF, $FF, $FF
    DB      $1E, $40, $E0, $40, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $45, $08, $01, $24, $00, $01, $08
    DB      $02, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $04, $20, $89, $41, $10, $09, $80
    DB      $10, $22, $00, $08, $00, $01, $00, $00
    DB      $00, $49, $00, $12, $00, $45, $20, $04
    DB      $00, $12, $82, $00, $15, $20, $04, $08
    DB      $01, $42, $50, $00, $48, $8C, $91, $10
    DB      $00, $04, $60, $04, $10, $00, $82, $24
    DB      $11, $10, $81, $80, $09, $00, $00, $24
    DB      $02, $00, $60, $02, $88, $09, $10, $41
    DB      $04, $00, $A2, $10, $04, $80, $46, $00
    DB      $00, $55, $10, $04, $40, $01, $90, $44
    DB      $40, $91, $04, $41, $32, $00, $04, $80
    DB      $11, $04, $40, $48, $00, $00, $80, $00
    DB      $00, $21, $84, $08, $42, $10, $80, $10
    DB      $80, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $04, $92, $00, $40, $15, $40, $22
    DB      $00, $28, $02, $01, $08, $00, $06, $00
    DB      $01, $41, $04, $41, $04, $20, $08, $41
    DB      $02, $08, $21, $02, $0A, $40, $00, $28
    DB      $12, $30, $0B, $00, $62, $18, $10, $01
    DB      $20, $20, $02, $42, $88, $00, $45, $20
    DB      $80, $06, $00, $40, $01, $08, $40, $80
    DB      $0A, $08, $42, $02, $20, $18, $80, $04
    DB      $50, $00, $08, $89, $31, $12, $00, $0A
    DB      $42, $88, $24, $41, $00, $08, $20, $06
    DB      $20, $40, $24, $00, $00, $90, $01, $81
    DB      $08, $20, $82, $08, $90, $11, $40, $06
    DB      $00, $42, $50, $00, $48, $8C, $91, $10
    DB      $00, $04, $60, $04, $10, $00, $82, $24
    DB      $11, $10, $81, $80, $09, $00, $00, $24
    DB      $02, $00, $60, $02, $88, $09, $10, $41
    DB      $04, $49, $91, $02, $00, $20, $90, $02
    DB      $20, $00, $12, $40, $40, $91, $00, $04
    DB      $88, $11, $00, $20, $92, $00, $00, $80
    DB      $24, $00, $00, $48, $20, $00, $10, $80
    DB      $40, $42, $50, $00, $48, $8C, $91, $10
    DB      $00, $04, $60, $04, $10, $00, $82, $24
    DB      $11, $10, $81, $80, $09, $00, $00, $24
    DB      $02, $00, $60, $02, $88, $09, $10, $41
    DB      $04, $00, $08, $89, $31, $12, $00, $0A
    DB      $42, $88, $24, $41, $00, $08, $20, $06
    DB      $20, $40, $24, $00, $00, $90, $01, $81
    DB      $08, $20, $82, $08, $90, $11, $40, $06
    DB      $00, $30, $0B, $00, $62, $18, $10, $01
    DB      $20, $20, $02, $42, $88, $00, $45, $20
    DB      $80, $06, $00, $40, $01, $08, $40, $80
    DB      $0A, $08, $42, $02, $20, $18, $80, $04
    DB      $50, $04, $80, $08, $18, $46, $00, $D0
    DB      $0C, $01, $04, $A2, $00, $11, $42, $40
    DB      $04, $50, $01, $02, $10, $80, $02, $00
    DB      $60, $0A, $20, $01, $18, $04, $40, $42
    DB      $10, $42, $50, $00, $48, $8C, $91, $10
    DB      $00, $04, $60, $04, $10, $00, $82, $24
    DB      $11, $10, $81, $80, $09, $00, $00, $24
    DB      $02, $00, $60, $02, $88, $09, $10, $41
    DB      $04, $00, $01, $00, $04, $02, $00, $08
    DB      $11, $00, $05, $20, $04, $21, $10, $01
    DB      $44, $4A, $00, $04, $41, $10, $00, $21
    DB      $00, $04, $20, $09, $00, $42, $00, $00
    DB      $12, $00, $08, $89, $31, $12, $00, $0A
    DB      $42, $88, $24, $41, $00, $08, $20, $06
    DB      $20, $40, $24, $00, $00, $90, $01, $81
    DB      $08, $20, $82, $08, $90, $11, $40, $06
    DB      $00, $30, $0B, $00, $62, $18, $10, $01
    DB      $20, $20, $02, $42, $88, $00, $45, $20
    DB      $80, $06, $00, $40, $01, $08, $40, $80
    DB      $0A, $08, $42, $02, $20, $18, $80, $04
    DB      $50, $42, $50, $00, $48, $8C, $91, $10
    DB      $00, $04, $60, $04, $10, $00, $82, $24
    DB      $11, $10, $81, $80, $09, $00, $00, $24
    DB      $02, $00, $60, $02, $88, $09, $10, $41
    DB      $04, $22, $84, $10, $02, $48, $04, $20
    DB      $82, $08, $20, $81, $04, $48, $01, $20
    DB      $82, $00, $00, $80, $00, $80, $50, $00
    DB      $00, $44, $08, $00, $22, $00, $08, $80
    DB      $21, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $01, $02, $00, $09, $00, $24, $01, $10
    DB      $45, $00, $00, $00, $00, $00, $04, $00
    DB      $20, $02, $80, $48, $01, $4A, $A0, $00
    DB      $49, $01, $0A, $20, $80, $05, $20, $01
    DB      $44, $04, $40, $08, $01, $20, $01, $08
    DB      $12, $42, $50, $00, $48, $8C, $91, $10
    DB      $00, $04, $60, $04, $10, $00, $82, $24
    DB      $11, $10, $81, $80, $09, $00, $00, $24
    DB      $02, $00, $60, $02, $88, $09, $10, $41
    DB      $04, $80, $08, $10, $01, $82, $40, $10
    DB      $00, $44, $82, $00, $90, $24, $80, $2C
    DB      $00, $00, $00, $00, $00, $20, $00, $04
    DB      $80, $11, $20, $09, $60, $04, $81, $10
    DB      $42, $00, $00, $00, $00, $00, $00, $00
    DB      $80, $40, $00, $90, $00, $24, $80, $08
    DB      $A2, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $01, $03, $06, $0C, $18, $30, $60
    DB      $C0, $00, $00, $00, $00, $1F, $30, $60
    DB      $C0, $1F, $30, $60, $C0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $FF, $00, $00
    DB      $00, $80, $C0, $60, $30, $18, $0C, $06
    DB      $03, $00, $00, $00, $00, $F8, $0C, $06
    DB      $03, $F8, $0C, $06, $03, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FF, $00, $00, $00, $00, $18, $3C, $66
    DB      $C3, $00, $00, $01, $03, $06, $0C, $18
    DB      $30, $60, $F0, $98, $0C, $06, $03, $01
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $C0, $00, $00, $00, $00, $07, $0C, $18
    DB      $30, $00, $00, $00, $00, $FE, $03, $01
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $3F, $00, $00, $01, $03, $06, $0C, $18
    DB      $F0, $40, $C0, $80, $00, $00, $00, $00
    DB      $00, $3E, $03, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $C0, $3E, $03, $01
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $C0, $00, $00, $80, $C0, $3F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $80
    DB      $FF, $20, $30, $18, $0C, $06, $03, $01
    DB      $00, $07, $0C, $18, $30, $C0, $00, $00
    DB      $00, $C0, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $06, $0F, $19
    DB      $F0, $00, $00, $00, $00, $06, $0F, $99
    DB      $F0, $FE, $03, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $03, $06, $0C, $98
    DB      $F0, $7E, $C3, $81, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $07, $0C, $98
    DB      $F0, $00, $00, $00, $00, $07, $0C, $18
    DB      $F0, $07, $0C, $98, $F0, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $01, $03, $06
    DB      $0C, $18, $3C, $66, $C3, $81, $00, $00
    DB      $00, $00, $00, $00, $00, $80, $C0, $60
    DB      $30, $00, $00, $00, $00, $00, $00, $00
    DB      $0F, $00, $00, $00, $00, $01, $03, $06
    DB      $FC, $10, $30, $60, $C0, $80, $00, $00
    DB      $00, $0F, $00, $00, $00, $00, $00, $00
    DB      $00, $80, $C0, $60, $30, $0F, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $F0, $00, $00, $00, $00, $80, $C0, $60
    DB      $3F, $08, $0C, $06, $03, $01, $00, $00
    DB      $00, $01, $03, $06, $0C, $F0, $00, $00
    DB      $00, $F0, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $81, $C3, $66
    DB      $3C, $FF, $00, $00, $00, $00, $00, $00
    DB      $00, $1F, $30, $60, $C0, $80, $00, $00
    DB      $00, $81, $C3, $66, $3C, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $01
    DB      $03, $06, $0F, $19, $30, $60, $C0, $80
    DB      $00, $00, $00, $80, $C0, $60, $30, $18
    DB      $0C, $00, $00, $00, $00, $7F, $C0, $80
    DB      $00, $00, $00, $00, $00, $E0, $30, $18
    DB      $0C, $00, $00, $00, $00, $00, $00, $00
    DB      $03, $00, $00, $00, $00, $00, $00, $01
    DB      $FF, $04, $0C, $18, $30, $60, $C0, $80
    DB      $00, $03, $00, $00, $00, $00, $00, $00
    DB      $00, $E0, $30, $18, $0C, $03, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $FC, $00, $00, $00, $00, $E0, $30, $18
    DB      $0F, $02, $03, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $03, $7C, $C0, $80
    DB      $00, $7C, $C0, $80, $00, $00, $00, $00
    DB      $00, $00, $00, $80, $C0, $60, $30, $18
    DB      $0F, $00, $00, $00, $00, $60, $F0, $99
    DB      $0F, $00, $00, $00, $00, $60, $F0, $98
    DB      $0C, $00, $00, $01, $03, $FC, $00, $00
    DB      $00, $7F, $C0, $80, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $E0, $30, $19
    DB      $0F, $07, $0C, $18, $30, $60, $C0, $80
    DB      $00, $00, $00, $80, $C0, $60, $30, $19
    DB      $0F, $E0, $30, $19, $0F, $00, $00, $00
    DB      $00, $CC, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $DE, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $28, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $CE
    DB      $00, $69, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $45, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $FE, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $CD
    DB      $00, $60, $60, $F0, $F0, $F0, $60, $60
    DB      $60, $18, $18, $3C, $3C, $3C, $18, $18
    DB      $18, $06, $06, $0F, $0F, $0F, $06, $06
    DB      $06, $01, $01, $03, $03, $03, $01, $01
    DB      $01, $80, $80, $C0, $C0, $C0, $80, $80
    DB      $80, $00, $00, $60, $60, $F0, $F0, $F0
    DB      $60, $00, $00, $18, $18, $3C, $3C, $3C
    DB      $18, $00, $00, $06, $06, $0F, $0F, $0F
    DB      $06, $00, $00, $01, $01, $03, $03, $03
    DB      $01, $00, $00, $80, $80, $C0, $C0, $C0
    DB      $80, $60, $60, $00, $00, $00, $00, $00
    DB      $00, $18, $18, $00, $00, $00, $00, $00
    DB      $00, $06, $06, $00, $00, $00, $00, $00
    DB      $00, $01, $01, $00, $00, $00, $00, $00
    DB      $00, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $60, $60, $F0
    DB      $F0, $00, $00, $00, $00, $18, $18, $3C
    DB      $3C, $00, $00, $00, $00, $06, $06, $0F
    DB      $0F, $00, $00, $00, $00, $01, $01, $03
    DB      $03, $00, $00, $00, $00, $80, $80, $C0
    DB      $C0, $F0, $60, $60, $60, $00, $00, $00
    DB      $00, $3C, $18, $18, $18, $00, $00, $00
    DB      $00, $0F, $06, $06, $06, $00, $00, $00
    DB      $00, $03, $01, $01, $01, $00, $00, $00
    DB      $00, $C0, $80, $80, $80, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $60
    DB      $60, $00, $00, $00, $00, $00, $00, $18
    DB      $18, $00, $00, $00, $00, $00, $00, $06
    DB      $06, $00, $00, $00, $00, $00, $00, $01
    DB      $01, $00, $00, $00, $00, $00, $00, $80
    DB      $80, $F0, $F0, $F0, $60, $60, $60, $00
    DB      $00, $3C, $3C, $3C, $18, $18, $18, $00
    DB      $00, $0F, $0F, $0F, $06, $06, $06, $00
    DB      $00, $03, $03, $03, $01, $01, $01, $00
    DB      $00, $C0, $C0, $C0, $80, $80, $80, $00
    DB      $00, $A0, $A0, $D0, $D0, $D0, $80, $80
    DB      $80, $00, $00, $A0, $A0, $D0, $D0, $D0
    DB      $80, $80, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $A0, $A0, $D0
    DB      $D0, $D0, $80, $80, $80, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $A0
    DB      $A0, $D0, $D0, $D0, $80, $80, $80, $00
    DB      $00, $80, $00, $00, $19, $18, $00, $00
    DB      $10, $00, $00, $24, $00, $00, $24, $00
    DB      $00, $00, $00, $18, $00, $18, $00, $00
    DB      $00, $00, $60, $40, $02, $06, $00, $18
    DB      $10, $00, $24, $00, $00, $20, $02, $10
    DB      $00, $00, $40, $04, $10, $08, $20, $02
    DB      $00, $F0, $00, $00, $F0, $F0, $00, $00
    DB      $F0, $00, $00, $B0, $00, $00, $B0, $00
    DB      $00, $00, $00, $60, $00, $60, $00, $00
    DB      $00, $00, $F0, $D0, $F0, $D0, $00, $F0
    DB      $F0, $00, $20, $00, $00, $B0, $20, $B0
    DB      $00, $00, $D0, $40, $D0, $40, $D0, $D0
    DB      $00, $00, $3C, $66, $66, $66, $66, $66
    DB      $3C, $00, $18, $38, $18, $18, $18, $18
    DB      $3C, $00, $3C, $66, $06, $3C, $60, $60
    DB      $7E, $00, $3C, $66, $06, $1C, $06, $66
    DB      $38, $00, $1E, $36, $66, $7F, $06, $06
    DB      $06, $00, $7E, $60, $60, $7C, $06, $66
    DB      $3C, $00, $3C, $66, $60, $7C, $66, $66
    DB      $3C, $00, $7E, $46, $04, $0C, $08, $18
    DB      $18, $00, $3C, $66, $66, $3C, $66, $66
    DB      $3C, $00, $3C, $66, $66, $3C, $06, $66
    DB      $3C, $00, $3C, $66, $66, $7E, $66, $66
    DB      $66, $00, $7E, $18, $18, $18, $18, $18
    DB      $18, $00, $3C, $76, $62, $60, $62, $76
    DB      $3C, $00, $66, $6C, $78, $78, $6C, $66
    DB      $62, $00, $C6, $C6, $C6, $C6, $D6, $7C
    DB      $28, $00, $66, $66, $66, $24, $24, $38
    DB      $18, $00, $7E, $60, $60, $78, $60, $60
    DB      $7E, $00, $3C, $66, $66, $66, $66, $66
    DB      $3C, $00, $62, $76, $7E, $6A, $62, $62
    DB      $62, $00, $7C, $66, $66, $7C, $60, $60
    DB      $60, $00, $60, $60, $60, $60, $60, $60
    DB      $7E, $00, $7C, $66, $62, $62, $62, $66
    DB      $7C, $00, $7C, $66, $66, $7C, $66, $66
    DB      $7C, $00, $66, $76, $7E, $6E, $66, $66
    DB      $66, $00, $66, $66, $66, $66, $66, $66
    DB      $3C, $00, $3C, $66, $60, $3C, $06, $66
    DB      $3C, $81, $C3, $66, $3C, $18, $3C, $66
    DB      $C3, $00, $3C, $76, $60, $6E, $62, $76
    DB      $3C, $00, $7C, $66, $66, $7C, $78, $6C
    DB      $66, $00, $42, $66, $3C, $18, $18, $18
    DB      $18, $00, $00, $00, $00, $C0, $E0, $F8
    DB      $FE, $00, $00, $00, $60, $7E, $7F, $7E
    DB      $60, $F0, $F0, $F0, $F0, $F0, $F0, $F0
    DB      $F0, $70, $70, $70, $70, $70, $70, $70
    DB      $70

LOC_9B7D:                                   ; LOC_9B7D: write player sprite pair to VRAM sprite attribute table $1B00
    LD      A, ($713A)                      ; Load $713A — player direction flag (0=right, NZ=left)
    AND     A
    LD      B, $0A                          ; B = 10: sprite width in pixels (normal)
    JR      NZ, LOC_9B87                    ; Jump to LOC_9B87 if player facing left
    LD      B, $08                          ; B = 8: sprite width when facing right

LOC_9B87:                                   ; LOC_9B87: write first sprite entry (Y, X, pattern, colour)
    LD      HL, $1B00                       ; HL = $1B00: VRAM sprite attribute table base
    CALL    VDP_REG_8280                    ; Set VRAM write address to $1B00
    LD      C, $BE
    LD      DE, ($7138)                     ; DE = ($7138): player X position (low=X pixel, high=direction)
    OUT     (C), D                          ; OUT ($BE): write Y byte (D) to sprite attribute table
    CALL    SUB_9BC1                        ; Timing delay (3 NOPs)
    OUT     (C), E                          ; Write X byte (E) to sprite attribute table
    CALL    SUB_9BC1
    OUT     (C), B
    CALL    SUB_9BC1
    LD      A, ($706C)                      ; Load $706C — sprite colour/pattern index byte
    OUT     (C), A
    INC     B
    LD      A, E                            ; INC B: pattern for second sprite is B+1
    ADD     A, $08                          ; E += 8: second sprite X offset (+8 pixels)
    LD      E, A
    OUT     (C), D
    CALL    SUB_9BC1
    OUT     (C), E
    CALL    SUB_9BC1
    OUT     (C), B
    CALL    SUB_9BC1
    LD      A, ($706C)                  ; RAM $706C
    OUT     (C), A
    RET     

SUB_9BC1:                                   ; SUB_9BC1: 3-NOP timing delay (TMS9918A port settling)
    NOP     
    NOP     
    NOP     
    RET     

SUB_9BC5:                                   ; SUB_9BC5: scroll player sprite Y — update $705D from $7152 velocity
    LD      HL, $705D                       ; Point HL to $705D (player sprite Y position)
    LD      A, ($7152)                      ; Load $7152 — Y velocity (positive = up, negative = down)
    AND     A
    RET     Z                               ; Return if velocity = 0 (no movement)
    JP      M, LOC_9BE8                     ; JP M: velocity negative → move down (LOC_9BE8)
    INC     (HL)                            ; Move up: INC (HL) twice (move sprite Y +2)
    INC     (HL)
    DEC     A
    LD      ($7152), A                      ; $7152 velocity decremented by 1
    LD      A, ($7153)                  ; RAM $7153
    DEC     A                               ; $7153 animation direction = (old-1) & $03
    AND     $03
    LD      ($7153), A                  ; RAM $7153
    CALL    SUB_9C4E
    CALL    SUB_9C00
    JP      SUB_9BC5

LOC_9BE8:                                   ; LOC_9BE8: move down — DEC (HL) twice
    DEC     (HL)
    DEC     (HL)
    INC     A
    LD      ($7152), A                  ; RAM $7152
    CALL    SUB_9C7A
    LD      A, ($7153)                  ; RAM $7153
    INC     A
    AND     $03
    LD      ($7153), A                  ; RAM $7153
    CALL    SUB_9C26
    JP      SUB_9BC5

SUB_9C00:                                   ; SUB_9C00: scroll world forward — INC $7154 by 2, update $7188/$7189
    LD      HL, ($7154)                     ; Load $7154 — world X scroll accumulator
    INC     HL                              ; INC HL twice: advance world 2 units
    INC     HL
    LD      A, H                            ; Mask H to 2 bits (world wraps at $400)
    AND     $03
    LD      H, A
    LD      ($7154), HL                     ; Store updated scroll value in $7154
    LD      HL, $7188                       ; Point HL to $7188 — tile column animation sub-counter
    LD      A, (HL)
    INC     A
    AND     $07                             ; Increment and mask to 3 bits (8-frame tile cycle)
    LD      (HL), A
    RET     NZ                              ; Return if sub-counter not wrapped to 0
    LD      A, ($7189)                      ; Update $7189 — tile column index (0-31)
    INC     A
    AND     $1F                             ; Mask to 5 bits: wraps every 32 columns
    LD      ($7189), A                  ; RAM $7189
    LD      C, A                            ; C = new column index
    LD      A, $20                          ; $718A = 32 - C: complementary column for right edge
    SUB     C
    LD      ($718A), A                  ; RAM $718A
    RET     

SUB_9C26:                                   ; SUB_9C26: scroll world backward — DEC $7154 by 2, update $7188/$7189
    LD      HL, ($7154)                 ; RAM $7154
    DEC     HL
    DEC     HL
    LD      A, H
    AND     $03
    LD      H, A
    LD      ($7154), HL                 ; RAM $7154
    LD      HL, $7188                   ; RAM $7188
    LD      A, (HL)
    DEC     A
    AND     $07
    LD      (HL), A
    CP      $07
    RET     NZ
    LD      A, ($7189)                  ; RAM $7189
    DEC     A
    AND     $1F
    LD      ($7189), A                  ; RAM $7189
    LD      C, A
    LD      A, $20
    SUB     C
    LD      ($718A), A                  ; RAM $718A
    RET     

SUB_9C4E:                                   ; SUB_9C4E: advance animation sequence pointer forward using IX record
    CALL    SUB_9CA7
    LD      L, (IX+0)
    LD      H, (IX+1)
    CALL    SUB_9C61
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

SUB_9C61:                                   ; SUB_9C61: find next valid (bit7=1) animation frame pointer (forward)
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_9C6D
    LD      L, (IX+2)
    LD      H, (IX+3)
    JR      LOC_9C70

LOC_9C6D:
    INC     HL
    INC     HL
    INC     HL

LOC_9C70:
    PUSH    HL
    POP     IY
    BIT     7, (IY+2)
    JR      Z, SUB_9C61
    RET     

SUB_9C7A:                                   ; SUB_9C7A: advance animation sequence pointer backward using IX record
    CALL    SUB_9CA7
    LD      L, (IX+0)
    LD      H, (IX+1)
    CALL    SUB_9C8D
    LD      (IX+0), L
    LD      (IX+1), H
    RET     

SUB_9C8D:                                   ; SUB_9C8D: find next valid animation frame pointer (backward)
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_9C9A
    LD      L, (IX+4)
    LD      H, (IX+5)
    JP      LOC_9C9B

LOC_9C9A:
    DEC     HL

LOC_9C9B:
    DEC     HL
    DEC     HL
    PUSH    HL
    POP     IY
    BIT     7, (IY+2)
    JR      Z, SUB_9C8D
    RET     

SUB_9CA7:                                   ; SUB_9CA7: compute IX = $7156 + ($7153 × 10) — select animation record
    LD      A, ($7153)                      ; Load $7153 — animation direction index (0-3)
    SLA     A                               ; SLA A: A × 2
    LD      E, A
    SLA     A                               ; SLA A × 2 more: A × 8 total; then add original → A × 10
    SLA     A
    ADD     A, E
    LD      HL, $7156                       ; HL = $7156: base of animation records table
    LD      E, A
    LD      D, $00                          ; DE = A × 10 offset into table
    ADD     HL, DE
    PUSH    HL                              ; IX = &anim_record[$7153]
    POP     IX
    RET     

SUB_9CBD:                                   ; SUB_9CBD: load IY from (IX+8/9), HL from (IX+6/7) — read anim record fields
    LD      E, (IX+8)
    LD      D, (IX+9)
    PUSH    DE
    POP     IY
    LD      L, (IX+6)
    LD      H, (IX+7)
    RET     

LOC_9CCD:                                   ; LOC_9CCD: sprite animation frame update — advance current anim sequence
    LD      A, ($701E)                      ; Load $701E — number of active entities (skip if 0)
    AND     A
    RET     Z                               ; Return if no entities active
    CALL    SUB_9CA7                        ; Compute IX = animation record for current direction
    CALL    SUB_9CBD                        ; Load IY and HL from animation record
    LD      DE, ($7154)                     ; Load $7154 — world scroll accumulator
    LD      A, D
    CP      $03                             ; Check if high byte = $03 (near wrap boundary)
    JR      NZ, LOC_9CE7
    LD      A, E
    CP      $02
    JP      NC, LOC_9D2B

LOC_9CE7:
    LD      DE, ($7154)                 ; RAM $7154
    SRL     D
    RR      E
    SRL     D
    RR      E
    LD      A, E
    AND     $FE
    LD      E, A
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      B, (HL)

VDP_REG_9CFB:
    LD      HL, $0200
    ADD     HL, DE
    LD      DE, ($7180)                 ; RAM $7180
    ADD     HL, DE
    DB      $EB
    LD      L, (IX+0)
    LD      H, (IX+1)
    LD      ($717E), SP                 ; RAM $717E
    LD      SP, HL
    DB      $EB
    POP     DE
    DEC     SP
    LD      C, $BF
    SET     6, H

LOC_9D17:
    OUT     (C), L
    OUT     (C), H
    POP     AF
    AND     $7F
    POP     DE
    DEC     SP
    ADD     HL, DE
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    DJNZ    LOC_9D17
    LD      SP, ($717E)                 ; RAM $717E
    RET     

LOC_9D2B:
    SRL     D
    RR      E
    SRL     D
    RR      E
    LD      A, E
    AND     $FE
    LD      C, A
    SRL     A
    SUB     (IY-1)
    CP      $1F
    JR      NC, LOC_9CE7
    LD      E, A
    ADD     IY, DE
    LD      B, (IY+0)
    LD      E, C
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      A, (HL)
    SUB     B
    PUSH    AF
    CALL    VDP_REG_9CFB
    DB      $EB
    POP     BC
    LD      L, (IX+2)
    LD      H, (IX+3)
    LD      ($717E), SP                 ; RAM $717E
    LD      SP, HL
    DB      $EB
    POP     DE
    ADD     HL, DE
    DEC     SP
    LD      C, $BF
    JP      LOC_9D17
    DB      $B1, $9E, $B1, $9E, $30, $A0, $8E, $9D
    DB      $8F, $9E, $57, $A1, $57, $A1, $66, $A3
    DB      $34, $A0, $35, $A1, $8D, $A4, $8D, $A4
    DB      $9C, $A6, $6A, $A3, $6B, $A4, $C3, $A7
    DB      $C3, $A7, $D2, $A9, $A0, $A6, $A1, $A7
    DB      $60, $20, $80, $20, $80, $20, $80, $20
    DB      $80, $20, $80, $20, $80, $20, $80, $20
    DB      $80, $20, $80, $20, $80, $20, $80, $20
    DB      $80, $20, $80, $20, $60, $20, $60, $20
    DB      $60, $20, $60, $20, $40, $20, $20, $20 ; "` ` @   "
    DB      $20, $20, $20, $20, $20, $20, $40, $20 ; "      @ "
    DB      $40, $20, $40, $20, $40, $20, $60, $20 ; "@ @ @ ` "
    DB      $80, $20, $80, $20, $80, $20, $A0, $20
    DB      $A0, $20, $A0, $20, $80, $20, $80, $20
    DB      $80, $20, $60, $20, $60, $20, $80, $20
    DB      $A0, $20, $C0, $20, $C0, $20, $C0, $20
    DB      $C0, $20, $C0, $20, $A0, $20, $A0, $20
    DB      $A0, $20, $80, $20, $60, $20, $60, $20
    DB      $60, $20, $60, $20, $80, $20, $80, $20
    DB      $80, $20, $80, $20, $80, $20, $60, $20
    DB      $40, $20, $20, $20, $20, $20, $00, $20
    DB      $00, $20, $20, $20, $20, $20, $40, $20
    DB      $60, $20, $80, $20, $80, $20, $80, $20
    DB      $80, $20, $A0, $20, $A0, $20, $A0, $20
    DB      $A0, $20, $A0, $20, $80, $20, $80, $20
    DB      $60, $20, $80, $20, $80, $20, $A0, $20
    DB      $A0, $20, $A0, $20, $A0, $20, $A0, $20
    DB      $A0, $20, $A0, $20, $C0, $20, $C0, $20
    DB      $A0, $20, $80, $20, $80, $20, $A0, $20
    DB      $A0, $20, $80, $20, $A0, $20, $A0, $20
    DB      $C0, $20, $C0, $20, $A0, $20, $A0, $20
    DB      $80, $20, $80, $20, $60, $20, $60, $20
    DB      $60, $20, $80, $20, $80, $20, $80, $20
    DB      $A0, $20, $A0, $20, $80, $20, $60, $20
    DB      $60, $20, $60, $20, $60, $20, $40, $20 ; "` ` ` @ "
    DB      $40, $20, $20, $20, $20, $20, $40, $20 ; "@     @ "
    DB      $40, $20, $40, $20, $40, $20, $60, $20 ; "@ @ @ ` "
    DB      $61, $1F, $1E, $1D, $1C, $1B, $1A, $19
    DB      $18, $17, $16, $15, $14, $13, $12, $11
    DB      $10, $0F, $0E, $0D, $0C, $0B, $0A, $09
    DB      $08, $07, $06, $05, $04, $03, $02, $01
    DB      $00, $00, $00, $01, $00, $88, $21, $00
    DB      $87, $01, $00, $86, $01, $00, $89, $01
    DB      $00, $89, $01, $00, $81, $01, $00, $87
    DB      $01, $00, $84, $01, $00, $86, $01, $00
    DB      $82, $01, $00, $86, $01, $00, $89, $01
    DB      $00, $82, $01, $00, $83, $E1, $FF, $82
    DB      $01, $00, $84, $01, $00, $84, $01, $00
    DB      $83, $E1, $FF, $81, $E1, $FF, $82, $01
    DB      $00, $84, $01, $00, $84, $01, $00, $86
    DB      $21, $00, $87, $01, $00, $84, $01, $00
    DB      $86, $01, $00, $88, $21, $00, $85, $21
    DB      $00, $85, $01, $00, $89, $01, $00, $89
    DB      $21, $00, $85, $01, $00, $82, $01, $00
    DB      $83, $E1, $FF, $82, $01, $00, $84, $01
    DB      $00, $83, $E1, $FF, $81, $01, $00, $85
    DB      $21, $00, $85, $21, $00, $85, $21, $00
    DB      $85, $01, $00, $89, $01, $00, $89, $01
    DB      $00, $89, $01, $00, $81, $E1, $FF, $88
    DB      $01, $00, $82, $01, $00, $83, $E1, $FF
    DB      $81, $E1, $FF, $82, $01, $00, $83, $01
    DB      $00, $87, $01, $00, $86, $21, $00, $85
    DB      $01, $00, $82, $01, $00, $84, $01, $00
    DB      $84, $01, $00, $83, $E1, $FF, $81, $E1
    DB      $FF, $81, $E1, $FF, $88, $01, $00, $81
    DB      $E1, $FF, $81, $01, $00, $85, $21, $00
    DB      $87, $01, $00, $86, $21, $00, $85, $21
    DB      $00, $85, $21, $00, $85, $01, $00, $82
    DB      $01, $00, $86, $01, $00, $89, $21, $00
    DB      $85, $01, $00, $88, $01, $00, $88, $01
    DB      $00, $82, $01, $00, $83, $E1, $FF, $82
    DB      $01, $00, $83, $E1, $FF, $88, $21, $00
    DB      $87, $01, $00, $86, $21, $00, $87, $01
    DB      $00, $84, $01, $00, $84, $01, $00, $86
    DB      $01, $00, $89, $01, $00, $89, $01, $00
    DB      $89, $21, $00, $87, $01, $00, $83, $E1
    DB      $FF, $81, $E1, $FF, $81, $01, $00, $85
    DB      $21, $00, $85, $01, $00, $81, $E1, $FF
    DB      $88, $21, $00, $85, $01, $00, $89, $21
    DB      $00, $87, $01, $00, $83, $E1, $FF, $82
    DB      $01, $00, $83, $E1, $FF, $82, $01, $00
    DB      $83, $E1, $FF, $88, $01, $00, $81, $01
    DB      $00, $85, $21, $00, $87, $01, $00, $84
    DB      $01, $00, $86, $21, $00, $87, $01, $00
    DB      $83, $E1, $FF, $81, $E1, $FF, $88, $01
    DB      $00, $88, $01, $00, $88, $01, $00, $81
    DB      $E1, $FF, $82, $01, $00, $83, $E1, $FF
    DB      $88, $01, $00, $88, $21, $00, $85, $01
    DB      $00, $88, $01, $00, $89, $01, $00, $89
    DB      $21, $00, $85, $00, $00, $00, $60, $28
    DB      $80, $27, $80, $28, $80, $28, $80, $28
    DB      $80, $29, $80, $29, $80, $2A, $80, $2B
    DB      $80, $2C, $80, $2C, $80, $2C, $80, $2C
    DB      $60, $2C, $60, $2C, $60, $2C, $60, $2C ; "`,`,`,`,"
    DB      $40, $2D, $20, $2D, $20, $2C, $20, $2C ; "@- - , ,"
    DB      $20, $2C, $20, $2D, $40, $2C, $40, $2C ; " , -@,@,"
    DB      $40, $2C, $40, $2C, $60, $2C, $80, $2C
    DB      $80, $2D, $80, $2D, $A0, $2D, $A0, $2D
    DB      $80, $2E, $80, $2D, $80, $2E, $60, $2F
    DB      $60, $2F, $60, $2F, $80, $2E, $A0, $2D
    DB      $C0, $2D, $C0, $2D, $C0, $2D, $C0, $2D
    DB      $A0, $2D, $A0, $2D, $A0, $2D, $80, $2E
    DB      $60, $2E, $60, $2D, $60, $2E, $60, $2E ; "`.`-`.`."
    DB      $60, $2E, $80, $2D, $80, $2D, $80, $2D
    DB      $80, $2D, $60, $2E, $40, $2D, $20, $2D
    DB      $20, $2D, $00, $2D, $00, $2D, $00, $2D
    DB      $20, $2D, $20, $2E, $40, $2D, $60, $2D ; " - .@-`-"
    DB      $80, $2C, $80, $2D, $80, $2D, $80, $2E
    DB      $A0, $2D, $A0, $2E, $A0, $2E, $A0, $2E
    DB      $80, $2F, $80, $2E, $60, $2E, $60, $2E
    DB      $80, $2D, $80, $2E, $A0, $2E, $A0, $2E
    DB      $A0, $2E, $A0, $2E, $A0, $2F, $A0, $2F
    DB      $A0, $30, $C0, $2F, $A0, $30, $80, $2F
    DB      $80, $2E, $80, $2E, $A0, $2E, $80, $2E
    DB      $80, $2E, $A0, $2D, $A0, $2D, $C0, $2C
    DB      $A0, $2C, $A0, $2B, $80, $2B, $80, $2A
    DB      $60, $2A, $60, $29, $60, $29, $60, $29 ; "`*`)`)`)"
    DB      $80, $28, $80, $29, $80, $29, $A0, $28
    DB      $80, $28, $60, $28, $60, $28, $60, $28
    DB      $60, $28, $40, $28, $40, $28, $20, $28 ; "`(@(@( ("
    DB      $20, $27, $20, $27, $40, $27, $40, $28 ; " ' '@'@("
    DB      $40, $28, $40, $28, $60, $28, $60, $2D ; "@(@(`(`-"
    DB      $2B, $29, $28, $26, $25, $23, $22, $20 ; "+)(&%#" "
    DB      $1F, $1D, $1C, $1B, $19, $18, $17, $15
    DB      $14, $12, $10, $0F, $0E, $0D, $0B, $0A
    DB      $08, $07, $05, $04, $03, $02, $00, $00
    DB      $00, $01, $00, $96, $01, $00, $94, $20
    DB      $00, $12, $01, $00, $93, $01, $00, $9B
    DB      $01, $00, $9B, $01, $00, $9D, $01, $00
    DB      $9E, $01, $00, $95, $01, $00, $8E, $01
    DB      $00, $9F, $01, $00, $8E, $01, $00, $9B
    DB      $01, $00, $9F, $01, $00, $98, $E1, $FF
    DB      $8D, $20, $00, $19, $E1, $FF, $84, $01
    DB      $00, $84, $01, $00, $98, $E1, $FF, $8A
    DB      $20, $00, $19, $C1, $FF, $8D, $20, $00
    DB      $11, $E1, $FF, $84, $01, $00, $84, $01
    DB      $00, $8E, $01, $00, $8C, $20, $00, $12
    DB      $01, $00, $95, $01, $00, $8E, $01, $00
    DB      $96, $01, $00, $94, $20, $00, $17, $01
    DB      $00, $8C, $20, $00, $17, $01, $00, $9B
    DB      $01, $00, $9B, $01, $00, $8C, $20, $00
    DB      $17, $01, $00, $9F, $01, $00, $98, $E1
    DB      $FF, $8D, $20, $00, $19, $E1, $FF, $84
    DB      $01, $00, $98, $E1, $FF, $8A, $20, $00
    DB      $19, $E1, $FF, $8B, $01, $00, $8C, $20
    DB      $00, $17, $01, $00, $8C, $20, $00, $17
    DB      $01, $00, $8C, $20, $00, $17, $01, $00
    DB      $9B, $01, $00, $9B, $01, $00, $9B, $01
    DB      $00, $9D, $E1, $FF, $8F, $20, $00, $11
    DB      $E1, $FF, $A0, $01, $00, $98, $E1, $FF
    DB      $8A, $20, $00, $19, $C1, $FF, $8D, $20
    DB      $00, $11, $E1, $FF, $98, $01, $00, $9C
    DB      $01, $00, $93, $01, $00, $8C, $20, $00
    DB      $17, $01, $00, $9F, $01, $00, $84, $01
    DB      $00, $84, $01, $00, $98, $E1, $FF, $8A
    DB      $20, $00, $19, $C1, $FF, $8A, $20, $00
    DB      $11, $C1, $FF, $8F, $20, $00, $11, $E1
    DB      $FF, $90, $E1, $FF, $8A, $20, $00, $11
    DB      $E1, $FF, $8B, $01, $00, $8C, $20, $00
    DB      $12, $01, $00, $93, $01, $00, $8C, $20
    DB      $00, $17, $01, $00, $8C, $20, $00, $17
    DB      $01, $00, $8C, $20, $00, $17, $01, $00
    DB      $9F, $01, $00, $8E, $01, $00, $9B, $01
    DB      $00, $8C, $20, $00, $17, $01, $00, $96
    DB      $01, $00, $88, $01, $00, $A0, $01, $00
    DB      $98, $E1, $FF, $8D, $20, $00, $19, $E1
    DB      $FF, $98, $E1, $FF, $8F, $20, $00, $19
    DB      $E1, $FF, $94, $20, $00, $12, $01, $00
    DB      $93, $01, $00, $8C, $20, $00, $12, $01
    DB      $00, $95, $01, $00, $84, $01, $00, $8E
    DB      $01, $00, $9B, $01, $00, $9B, $01, $00
    DB      $9B, $01, $00, $8C, $20, $00, $12, $01
    DB      $00, $A1, $E1, $FF, $8A, $20, $00, $19
    DB      $C1, $FF, $8A, $20, $00, $11, $E1, $FF
    DB      $8B, $01, $00, $8C, $20, $00, $17, $01
    DB      $00, $9D, $E1, $FF, $8F, $20, $00, $11
    DB      $E1, $FF, $94, $20, $00, $17, $01, $00
    DB      $9B, $01, $00, $8C, $20, $00, $12, $01
    DB      $00, $A1, $E1, $FF, $8D, $20, $00, $19
    DB      $E1, $FF, $98, $E1, $FF, $8D, $20, $00
    DB      $19, $E1, $FF, $98, $E1, $FF, $8F, $20
    DB      $00, $19, $E1, $FF, $90, $01, $00, $8B
    DB      $01, $00, $8C, $20, $00, $12, $01, $00
    DB      $95, $01, $00, $8E, $01, $00, $8C, $20
    DB      $00, $12, $01, $00, $A1, $E1, $FF, $8A
    DB      $20, $00, $19, $C1, $FF, $8F, $20, $00
    DB      $11, $E1, $FF, $88, $01, $00, $88, $01
    DB      $00, $90, $E1, $FF, $8D, $20, $00, $11
    DB      $E1, $FF, $98, $E1, $FF, $8F, $20, $00
    DB      $19, $E1, $FF, $88, $01, $00, $94, $20
    DB      $00, $17, $01, $00, $96, $01, $00, $9A
    DB      $01, $00, $9B, $01, $00, $8C, $20, $00
    DB      $17, $00, $00, $00, $60, $28, $80, $27
    DB      $80, $28, $80, $28, $80, $28, $80, $29
    DB      $80, $29, $80, $2A, $80, $2B, $80, $2C
    DB      $80, $2C, $80, $2C, $80, $2C, $60, $2C
    DB      $60, $2C, $60, $2C, $60, $2C, $40, $2D ; "`,`,`,@-"
    DB      $20, $2D, $20, $2C, $20, $2C, $20, $2C ; " - , , ,"
    DB      $20, $2D, $40, $2C, $40, $2C, $40, $2C ; " -@,@,@,"
    DB      $40, $2C, $60, $2C, $80, $2C, $80, $2D
    DB      $80, $2D, $A0, $2D, $A0, $2D, $80, $2E
    DB      $80, $2D, $80, $2E, $60, $2F, $60, $2F
    DB      $60, $2F, $80, $2E, $A0, $2D, $C0, $2D
    DB      $C0, $2D, $C0, $2D, $C0, $2D, $A0, $2D
    DB      $A0, $2D, $A0, $2D, $80, $2E, $60, $2E
    DB      $60, $2D, $60, $2E, $60, $2E, $60, $2E ; "`-`.`.`."
    DB      $80, $2D, $80, $2D, $80, $2D, $80, $2D
    DB      $60, $2E, $40, $2D, $20, $2D, $20, $2D ; "`.@- - -"
    DB      $00, $2D, $00, $2D, $00, $2D, $20, $2D
    DB      $20, $2E, $40, $2D, $60, $2D, $80, $2C
    DB      $80, $2D, $80, $2D, $80, $2E, $A0, $2D
    DB      $A0, $2E, $A0, $2E, $A0, $2E, $80, $2F
    DB      $80, $2E, $60, $2E, $60, $2E, $80, $2D
    DB      $80, $2E, $A0, $2E, $A0, $2E, $A0, $2E
    DB      $A0, $2E, $A0, $2F, $A0, $2F, $A0, $30
    DB      $C0, $2F, $A0, $30, $80, $2F, $80, $2E
    DB      $80, $2E, $A0, $2E, $80, $2E, $80, $2E
    DB      $A0, $2D, $A0, $2D, $C0, $2C, $A0, $2C
    DB      $A0, $2B, $80, $2B, $80, $2A, $60, $2A
    DB      $60, $29, $60, $29, $60, $29, $80, $28
    DB      $80, $29, $80, $29, $A0, $28, $80, $28
    DB      $60, $28, $60, $28, $60, $28, $60, $28 ; "`(`(`(`("
    DB      $40, $28, $40, $28, $20, $28, $20, $27 ; "@(@( ( '"
    DB      $20, $27, $40, $27, $40, $28, $40, $28 ; " '@'@(@("
    DB      $40, $28, $60, $28, $60, $2D, $2B, $29 ; "@(`(`-+)"
    DB      $28, $26, $25, $23, $22, $20, $1F, $1D
    DB      $1C, $1B, $19, $18, $17, $15, $14, $12
    DB      $10, $0F, $0E, $0D, $0B, $0A, $08, $07
    DB      $05, $04, $03, $02, $00, $00, $00, $01
    DB      $00, $AB, $01, $00, $AA, $20, $00, $28
    DB      $01, $00, $A9, $01, $00, $AF, $01, $00
    DB      $AF, $01, $00, $AF, $01, $00, $B1, $01
    DB      $00, $A9, $01, $00, $84, $01, $00, $AF
    DB      $01, $00, $84, $01, $00, $AF, $01, $00
    DB      $AF, $01, $00, $AD, $E1, $FF, $A2, $20
    DB      $00, $2E, $E1, $FF, $84, $01, $00, $84
    DB      $01, $00, $AD, $E1, $FF, $A2, $20, $00
    DB      $2E, $C1, $FF, $A2, $20, $00, $27, $E1
    DB      $FF, $84, $01, $00, $84, $01, $00, $84
    DB      $01, $00, $A4, $20, $00, $28, $01, $00
    DB      $A9, $01, $00, $84, $01, $00, $AB, $01
    DB      $00, $AA, $20, $00, $2C, $01, $00, $A4
    DB      $20, $00, $2C, $01, $00, $AF, $01, $00
    DB      $AF, $01, $00, $A4, $20, $00, $2C, $01
    DB      $00, $AF, $01, $00, $AD, $E1, $FF, $A2
    DB      $20, $00, $2E, $E1, $FF, $84, $01, $00
    DB      $AD, $E1, $FF, $A2, $20, $00, $2E, $E1
    DB      $FF, $A3, $01, $00, $A4, $20, $00, $2C
    DB      $01, $00, $A4, $20, $00, $2C, $01, $00
    DB      $A4, $20, $00, $2C, $01, $00, $AF, $01
    DB      $00, $AF, $01, $00, $AF, $01, $00, $AF
    DB      $E1, $FF, $A5, $20, $00, $27, $E1, $FF
    DB      $A6, $01, $00, $AD, $E1, $FF, $A2, $20
    DB      $00, $2E, $C1, $FF, $A2, $20, $00, $27
    DB      $E1, $FF, $AD, $01, $00, $B0, $01, $00
    DB      $A9, $01, $00, $A4, $20, $00, $2C, $01
    DB      $00, $AF, $01, $00, $84, $01, $00, $84
    DB      $01, $00, $AD, $E1, $FF, $A2, $20, $00
    DB      $2E, $C1, $FF, $A2, $20, $00, $27, $C1
    DB      $FF, $A5, $20, $00, $27, $E1, $FF, $A6
    DB      $E1, $FF, $A2, $20, $00, $27, $E1, $FF
    DB      $A3, $01, $00, $A4, $20, $00, $28, $01
    DB      $00, $A9, $01, $00, $A4, $20, $00, $2C
    DB      $01, $00, $A4, $20, $00, $2C, $01, $00
    DB      $A4, $20, $00, $2C, $01, $00, $AF, $01
    DB      $00, $84, $01, $00, $AF, $01, $00, $A4
    DB      $20, $00, $2C, $01, $00, $AB, $01, $00
    DB      $88, $01, $00, $A6, $01, $00, $AD, $E1
    DB      $FF, $A2, $20, $00, $2E, $E1, $FF, $AD
    DB      $E1, $FF, $A5, $20, $00, $2E, $E1, $FF
    DB      $AA, $20, $00, $28, $01, $00, $A9, $01
    DB      $00, $A4, $20, $00, $28, $01, $00, $A9
    DB      $01, $00, $84, $01, $00, $84, $01, $00
    DB      $AF, $01, $00, $AF, $01, $00, $AF, $01
    DB      $00, $A4, $20, $00, $28, $01, $00, $B2
    DB      $E1, $FF, $A2, $20, $00, $2E, $C1, $FF
    DB      $A2, $20, $00, $27, $E1, $FF, $A3, $01
    DB      $00, $A4, $20, $00, $2C, $01, $00, $AF
    DB      $E1, $FF, $A5, $20, $00, $27, $E1, $FF
    DB      $AA, $20, $00, $2C, $01, $00, $AF, $01
    DB      $00, $A4, $20, $00, $28, $01, $00, $B2
    DB      $E1, $FF, $A2, $20, $00, $2E, $E1, $FF
    DB      $AD, $E1, $FF, $A2, $20, $00, $2E, $E1
    DB      $FF, $AD, $E1, $FF, $A5, $20, $00, $2E
    DB      $E1, $FF, $A6, $01, $00, $A3, $01, $00
    DB      $A4, $20, $00, $28, $01, $00, $A9, $01
    DB      $00, $84, $01, $00, $A4, $20, $00, $28
    DB      $01, $00, $B2, $E1, $FF, $A2, $20, $00
    DB      $2E, $C1, $FF, $A5, $20, $00, $27, $E1
    DB      $FF, $88, $01, $00, $88, $01, $00, $A6
    DB      $E1, $FF, $A2, $20, $00, $27, $E1, $FF
    DB      $AD, $E1, $FF, $A5, $20, $00, $2E, $E1
    DB      $FF, $88, $01, $00, $AA, $20, $00, $2C
    DB      $01, $00, $AB, $01, $00, $A6, $01, $00
    DB      $AF, $01, $00, $A4, $20, $00, $2C, $00
    DB      $00, $00, $60, $28, $80, $27, $80, $28
    DB      $80, $28, $80, $28, $80, $29, $80, $29
    DB      $80, $2A, $80, $2B, $80, $2C, $80, $2C
    DB      $80, $2C, $80, $2C, $60, $2C, $60, $2C
    DB      $60, $2C, $60, $2C, $40, $2D, $20, $2D ; "`,`,@- -"
    DB      $20, $2C, $20, $2C, $20, $2C, $20, $2D ; " , , , -"
    DB      $40, $2C, $40, $2C, $40, $2C, $40, $2C ; "@,@,@,@,"
    DB      $60, $2C, $80, $2C, $80, $2D, $80, $2D
    DB      $A0, $2D, $A0, $2D, $80, $2E, $80, $2D
    DB      $80, $2E, $60, $2F, $60, $2F, $60, $2F
    DB      $80, $2E, $A0, $2D, $C0, $2D, $C0, $2D
    DB      $C0, $2D, $C0, $2D, $A0, $2D, $A0, $2D
    DB      $A0, $2D, $80, $2E, $60, $2E, $60, $2D
    DB      $60, $2E, $60, $2E, $60, $2E, $80, $2D
    DB      $80, $2D, $80, $2D, $80, $2D, $60, $2E
    DB      $40, $2D, $20, $2D, $20, $2D, $00, $2D
    DB      $00, $2D, $00, $2D, $20, $2D, $20, $2E
    DB      $40, $2D, $60, $2D, $80, $2C, $80, $2D
    DB      $80, $2D, $80, $2E, $A0, $2D, $A0, $2E
    DB      $A0, $2E, $A0, $2E, $80, $2F, $80, $2E
    DB      $60, $2E, $60, $2E, $80, $2D, $80, $2E
    DB      $A0, $2E, $A0, $2E, $A0, $2E, $A0, $2E
    DB      $A0, $2F, $A0, $2F, $A0, $30, $C0, $2F
    DB      $A0, $30, $80, $2F, $80, $2E, $80, $2E
    DB      $A0, $2E, $80, $2E, $80, $2E, $A0, $2D
    DB      $A0, $2D, $C0, $2C, $A0, $2C, $A0, $2B
    DB      $80, $2B, $80, $2A, $60, $2A, $60, $29
    DB      $60, $29, $60, $29, $80, $28, $80, $29
    DB      $80, $29, $A0, $28, $80, $28, $60, $28
    DB      $60, $28, $60, $28, $60, $28, $40, $28 ; "`(`(`(@("
    DB      $40, $28, $20, $28, $20, $27, $20, $27 ; "@( ( ' '"
    DB      $40, $27, $40, $28, $40, $28, $40, $28 ; "@'@(@(@("
    DB      $60, $28, $60, $2D, $2B, $29, $28, $26 ; "`(`-+)(&"
    DB      $25, $23, $22, $20, $1F, $1D, $1C, $1B
    DB      $19, $18, $17, $15, $14, $12, $10, $0F
    DB      $0E, $0D, $0B, $0A, $08, $07, $05, $04
    DB      $03, $02, $00, $00, $00, $01, $00, $C2
    DB      $01, $00, $BD, $20, $00, $3B, $01, $00
    DB      $BC, $01, $00, $C7, $01, $00, $C3, $01
    DB      $00, $C3, $01, $00, $C8, $01, $00, $BC
    DB      $01, $00, $84, $01, $00, $C7, $01, $00
    DB      $B6, $01, $00, $C7, $01, $00, $C3, $01
    DB      $00, $C0, $E1, $FF, $B3, $20, $00, $41
    DB      $E1, $FF, $B6, $01, $00, $84, $01, $00
    DB      $C5, $E1, $FF, $B3, $20, $00, $41, $C1
    DB      $FF, $B3, $20, $00, $3A, $E1, $FF, $B6
    DB      $01, $00, $84, $01, $00, $84, $01, $00
    DB      $B7, $20, $00, $3B, $01, $00, $BC, $01
    DB      $00, $84, $01, $00, $BE, $01, $00, $BD
    DB      $20, $00, $3F, $01, $00, $B5, $20, $00
    DB      $3F, $01, $00, $C9, $01, $00, $C3, $01
    DB      $00, $C4, $20, $00, $3F, $01, $00, $C9
    DB      $01, $00, $C0, $E1, $FF, $B3, $20, $00
    DB      $41, $E1, $FF, $B6, $01, $00, $C5, $E1
    DB      $FF, $B3, $20, $00, $41, $E1, $FF, $B4
    DB      $01, $00, $B5, $20, $00, $3F, $01, $00
    DB      $B5, $20, $00, $3F, $01, $00, $B5, $20
    DB      $00, $3F, $01, $00, $C9, $01, $00, $C3
    DB      $01, $00, $C3, $01, $00, $C3, $E1, $FF
    DB      $B8, $20, $00, $3A, $E1, $FF, $B9, $01
    DB      $00, $C0, $E1, $FF, $B3, $20, $00, $41
    DB      $C1, $FF, $B3, $20, $00, $3A, $E1, $FF
    DB      $C0, $01, $00, $C6, $01, $00, $BC, $01
    DB      $00, $B7, $20, $00, $3F, $01, $00, $C9
    DB      $01, $00, $B6, $01, $00, $84, $01, $00
    DB      $C5, $E1, $FF, $B3, $20, $00, $41, $C1
    DB      $FF, $B3, $20, $00, $3A, $C1, $FF, $B8
    DB      $20, $00, $3A, $E1, $FF, $B9, $E1, $FF
    DB      $B3, $20, $00, $3A, $E1, $FF, $B4, $01
    DB      $00, $B5, $20, $00, $3B, $01, $00, $BC
    DB      $01, $00, $B7, $20, $00, $3F, $01, $00
    DB      $B5, $20, $00, $3F, $01, $00, $B5, $20
    DB      $00, $3F, $01, $00, $C9, $01, $00, $B6
    DB      $01, $00, $C7, $01, $00, $C4, $20, $00
    DB      $3F, $01, $00, $C2, $01, $00, $88, $01
    DB      $00, $B9, $01, $00, $C0, $E1, $FF, $B3
    DB      $20, $00, $41, $E1, $FF, $C0, $E1, $FF
    DB      $B8, $20, $00, $41, $E1, $FF, $BD, $20
    DB      $00, $3B, $01, $00, $BC, $01, $00, $B7
    DB      $20, $00, $3B, $01, $00, $BC, $01, $00
    DB      $84, $01, $00, $84, $01, $00, $C7, $01
    DB      $00, $C3, $01, $00, $C3, $01, $00, $C4
    DB      $20, $00, $3B, $01, $00, $CA, $E1, $FF
    DB      $B3, $20, $00, $41, $C1, $FF, $B3, $20
    DB      $00, $3A, $E1, $FF, $B4, $01, $00, $B5
    DB      $20, $00, $3F, $01, $00, $C9, $E1, $FF
    DB      $B8, $20, $00, $3A, $E1, $FF, $BD, $20
    DB      $00, $3F, $01, $00, $C9, $01, $00, $C4
    DB      $20, $00, $3B, $01, $00, $CA, $E1, $FF
    DB      $B3, $20, $00, $41, $E1, $FF, $C0, $E1
    DB      $FF, $B3, $20, $00, $41, $E1, $FF, $C0
    DB      $E1, $FF, $B8, $20, $00, $41, $E1, $FF
    DB      $B9, $01, $00, $B4, $01, $00, $B5, $20
    DB      $00, $3B, $01, $00, $BC, $01, $00, $84
    DB      $01, $00, $B7, $20, $00, $3B, $01, $00
    DB      $CA, $E1, $FF, $B3, $20, $00, $41, $C1
    DB      $FF, $B8, $20, $00, $3A, $E1, $FF, $88
    DB      $01, $00, $88, $01, $00, $B9, $E1, $FF
    DB      $B3, $20, $00, $3A, $E1, $FF, $C0, $E1
    DB      $FF, $B8, $20, $00, $41, $E1, $FF, $88
    DB      $01, $00, $BD, $20, $00, $3F, $01, $00
    DB      $C2, $01, $00, $B9, $01, $00, $C3, $01
    DB      $00, $C4, $20, $00, $3F, $00, $00, $00

VDP_REG_A9D6:
    LD      IX, $7182                   ; RAM $7182
    LD      IY, $7185                   ; RAM $7185
    LD      B, $03

LOC_A9E0:
    LD      C, (IX+0)
    LD      A, (IY+0)
    LD      (IY+0), C
    LD      (IX+0), A
    INC     IX
    INC     IY
    DJNZ    LOC_A9E0
    LD      A, ($7182)                  ; RAM $7182
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $82
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      HL, ($7186)                 ; RAM $7186
    LD      ($7180), HL                 ; RAM $7180
    RET     

LOC_AA02:                                   ; LOC_AA02: erase old sprite positions from VRAM (clear sprite strips)
    LD      A, ($701E)                      ; Load $701E — active entity count
    AND     A
    JR      Z, LOC_AA13                     ; Skip first erase block if no entities
    LD      HL, ($7180)                     ; Load $7180 — current VRAM name-table base (scrolls by frame)
    LD      DE, $0200                       ; DE = $0200 — first VRAM erase region offset
    LD      B, $10                          ; B = 16 rows to erase
    CALL    VDP_WRITE_AA1E                  ; CALL VDP_WRITE_AA1E: clear 16×16 bytes at HL+DE in VRAM

LOC_AA13:                                   ; LOC_AA13: always erase second region
    CALL    VDP_DATA_AAB0                   ; Write tile animation frame index to VRAM $2808/$0808
    LD      HL, ($7180)                     ; Load $7180 — VRAM base
    LD      DE, $0080                       ; DE = $0080 — second erase region offset
    LD      B, $08                          ; B = 8 rows

VDP_WRITE_AA1E:                             ; VDP_WRITE_AA1E: set VRAM write addr to HL+DE, then clear B×16 bytes
    ADD     HL, DE                          ; HL += DE: compute target VRAM address
    LD      A, L                            ; Write low byte of address to CTRL_PORT
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OR      $40                             ; OR $40: set write-mode bit
    OUT     ($BF), A                        ; Write high byte of address
    XOR     A

LOC_AA28:                                   ; LOC_AA28: clear loop — write 16 zero bytes, then DJNZ
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_AA28
    RET     

LOC_AA4B:                                   ; LOC_AA4B: write scrolled background tile row to VRAM
    CALL    SUB_9BC5                        ; Update $7152/$7153 scroll velocity and direction
    LD      HL, ($7180)                     ; Load $7180 — current VRAM base
    LD      DE, $0100                       ; DE = $0100 — offset to background tile row
    ADD     HL, DE
    CALL    VDP_REG_8280                    ; Set VRAM write address to HL+DE
    LD      A, ($7016)                      ; Load $7016 — scroll tile source index
    LD      ($718B), A                      ; Store to $718B — tile count for this row write
    LD      IX, $AAFA                       ; IX = $AAFA — pointer to tile pattern data for this scroll position
    LD      BC, ($7189)                 ; RAM $7189

LOC_AA66:
    LD      D, $00
    LD      E, C
    PUSH    BC
    PUSH    IX
    POP     HL
    PUSH    HL
    ADD     HL, DE

LOC_AA6F:
    LD      A, (HL)
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_AA6F
    POP     HL
    LD      B, C
    LD      A, B
    AND     A
    JR      Z, LOC_AA81

LOC_AA7B:
    LD      A, (HL)
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_AA7B

LOC_AA81:
    POP     BC
    LD      DE, $0020
    ADD     IX, DE
    LD      HL, $718B                   ; RAM $718B
    LD      A, ($701E)                  ; RAM $701E
    AND     A
    JR      NZ, LOC_AAAC
    LD      A, (HL)
    CP      $08
    JR      NZ, LOC_AAAC
    IN      A, ($BF)                    ; CTRL_PORT - read VDP status
    LD      A, $36
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $85
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      HL, ($7180)                 ; RAM $7180
    LD      DE, $0220
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      HL, $718B                   ; RAM $718B

LOC_AAAC:
    DEC     (HL)
    JR      NZ, LOC_AA66
    RET     

VDP_DATA_AAB0:                              ; VDP_DATA_AAB0: write animation tile index byte to VRAM $2808 and $0808
    LD      A, ($7188)                      ; Load $7188 — tile animation sub-counter (0-7)
    LD      E, A
    LD      D, $00
    LD      HL, $AAF2                       ; HL = $AAF2: look-up table of tile indices (8 entries)
    ADD     HL, DE
    LD      C, (HL)                         ; C = tile index for this frame
    LD      HL, $2808                       ; HL = $2808: VRAM address for top animation tile
    CALL    VDP_REG_8280
    LD      A, C
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $0808
    CALL    VDP_REG_8280
    LD      A, $F0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, ($701E)                  ; RAM $701E
    AND     A
    RET     NZ
    LD      A, ($7188)                  ; RAM $7188
    LD      E, A
    LD      D, $00
    LD      HL, $AAF2
    ADD     HL, DE
    LD      C, (HL)
    LD      HL, $3260
    CALL    VDP_REG_8280
    LD      A, C
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $1260
    CALL    VDP_REG_8280
    LD      A, $F0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    RET     
    DB      $01, $02, $04, $08, $10, $20, $40, $80
    DB      $00, $00, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $01, $00, $00, $00, $00, $00
    DB      $01, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $01, $00, $00
    DB      $00, $00, $00, $00, $01, $00, $00, $00
    DB      $00, $00, $00, $00, $01, $00, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $01
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $01
    DB      $00, $00, $00, $00, $00, $00, $01, $00
    DB      $00, $00, $01, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $01, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $01, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $01, $00, $00, $01, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $01, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $01, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $01
    DB      $00, $00, $00, $00, $01, $00, $00, $00
    DB      $00, $00, $00, $01, $00, $01, $01, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $01, $00, $00, $00, $01, $00, $00
    DB      $00, $01, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $01, $00
    DB      $00, $00, $00, $4C, $00, $4C, $4C, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $4C, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $4C, $00, $00
    DB      $00, $00, $00, $00, $4C, $00, $00, $00
    DB      $00, $00, $00, $00, $4C, $00, $00, $00
    DB      $00, $00, $00, $4C, $00, $00, $00, $4C
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $4C, $00
    DB      $00, $00, $00, $4C, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $4C
    DB      $00, $00, $00, $00, $00, $00, $4C, $00
    DB      $00, $00, $4C, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $4C, $00
    DB      $00, $00, $00, $00, $00, $4C, $00, $00
    DB      $00, $00, $00, $4C, $00, $00, $00, $00
    DB      $00, $00, $4C, $00, $00, $00, $00, $00
    DB      $00, $00, $4C, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $4C, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $4C
    DB      $00, $00, $00, $00, $4C, $00, $00, $00
    DB      $00, $00, $4C, $00, $00, $4C, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $4C, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $4C, $00
    DB      $00, $4C, $00, $00, $00, $4C, $00, $00
    DB      $00, $4C, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $4C, $00, $00, $00, $00
    DB      $00, $00, $00, $4C, $00, $00, $00, $00

VDP_DATA_ACFA:                              ; VDP_DATA_ACFA: write 8 active bullet sprites to VRAM $1B08 from $72DE
    LD      HL, $1B08                       ; HL = $1B08: sprite attribute table offset for bullets (after player)
    CALL    VDP_REG_8280
    LD      B, $08
    LD      IX, $72DE                   ; RAM $72DE
                                            ; IX = $72DE: pointer to first bullet record (10 bytes each)
LOC_AD06:                                   ; LOC_AD06: check bit 7 of flag byte — bullet active?
    BIT     7, (IX+0)                       ; Skip inactive bullet entries
    JR      Z, LOC_AD22
    LD      A, (IX+2)
    OUT     ($BE), A                        ; Write bullet Y position to VRAM
    LD      A, (IX+1)                       ; Write bullet X position to VRAM
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     HL
    LD      A, $06
    OUT     ($BE), A                        ; Write bullet pattern index $06
    INC     HL
    INC     HL
    LD      A, $0F
    OUT     ($BE), A                        ; Write bullet colour $0F (white)

LOC_AD22:                                   ; LOC_AD22: advance IX by 10 (next bullet record)
    LD      DE, $000A
    ADD     IX, DE
    DJNZ    LOC_AD06                        ; DJNZ: loop over all 8 bullet records
    LD      ($71E6), HL                     ; Save updated VRAM write pointer to $71E6
    RET     

LOC_AD2D:                                   ; LOC_AD2D: write 8 enemy sprites to VRAM from $718E records
    LD      HL, ($71E6)                     ; Restore VRAM write pointer from $71E6
    CALL    VDP_REG_8280
    LD      IX, $718E                       ; IX = $718E: enemy sprite records (11 bytes each)
    LD      B, $08                          ; B = 8 enemies

LOC_AD39:                                   ; LOC_AD39: check bit 7 — enemy active?
    BIT     7, (IX+0)                       ; Skip inactive enemy entries
    JR      Z, LOC_AD82
    RES     5, (IX+0)                       ; Clear bit 5 of flag (onscreen-visible flag)
    LD      L, (IX+1)                       ; Load enemy X position low byte
    LD      H, (IX+2)                       ; Load enemy X position high byte
    LD      DE, ($7154)                     ; Load $7154 — world scroll
    SBC     HL, DE
    LD      A, H
    AND     $03                             ; Mask H to 2 bits (wrap check)
    JR      NZ, LOC_AD82
    SET     5, (IX+0)                       ; Set bit 5: mark enemy as currently on-screen
    LD      (IX+10), L                      ; Store X offset to (IX+10)
    LD      A, (IX+4)
    CP      $10
    JR      Z, LOC_AD82
    LD      A, (IX+3)
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, L
    LD      (IX+10), A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, (IX+0)
    AND     $07
    LD      DE, $000B
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      A, (IX+9)
    ADD     IX, DE
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_AD39
    JR      LOC_AD89

LOC_AD82:
    LD      DE, $000B
    ADD     IX, DE
    DJNZ    LOC_AD39

LOC_AD89:
    LD      A, $D0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    RET     

LOC_AD8E:                                   ; LOC_AD8E: collision detection — check 4 bullet collision zones vs $7207
    LD      IX, $7207                       ; IX = $7207: bullet collision zone records
    LD      C, $04                          ; C = 4: number of collision zones

LOC_AD94:                                   ; LOC_AD94: check bit 7 — zone active?
    BIT     7, (IX+0)
    JR      Z, LOC_ADB8                     ; Skip inactive zones
    LD      L, (IX+1)                       ; Load zone X low/high
    LD      H, (IX+2)
    LD      DE, ($7180)                     ; Load $7180 — VRAM scroll base
    ADD     HL, DE                          ; HL += DE: compute on-screen X
    LD      A, L
    OUT     ($BF), A                        ; Write X low byte to CTRL_PORT
    LD      A, H
    OR      $40                             ; OR $40: set VRAM write mode
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      B, (IX+3)                       ; B = zone width
    LD      A, (IX+4)

LOC_ADB3:                                   ; LOC_ADB3: fill zone with pattern byte A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     HL
    DJNZ    LOC_ADB3

LOC_ADB8:                                   ; LOC_ADB8: advance IX by 8 (next collision zone)
    LD      DE, $0008
    ADD     IX, DE
    DEC     C                               ; DEC C: process next zone
    JR      NZ, LOC_AD94
    RET     

LOC_ADC1:                                   ; LOC_ADC1: update missile/score tiles in VRAM from $7228 missile records
    LD      A, ($701E)                      ; Load $701E — active missile count
    AND     A
    RET     Z                               ; Return if no missiles active
    LD      B, $0A                          ; B = 10: max missiles
    LD      IX, $7228                       ; IX = $7228: missile records (4 bytes each)

LOC_ADCC:                                   ; LOC_ADCC: check bit 7 — missile active?
    BIT     7, (IX+0)
    JR      Z, LOC_ADFB                     ; Skip inactive missiles
    RES     5, (IX+0)                       ; Clear bit 5 (will be re-set if on-screen)
    LD      L, (IX+1)                       ; Load missile X low byte
    LD      H, (IX+2)
    LD      DE, ($7154)                     ; Load $7154 — world scroll
    SBC     HL, DE                          ; SBC HL, DE: compute relative screen X
    LD      A, H
    AND     $03
    JR      NZ, LOC_ADFB                    ; Jump if missile off-screen (H & $03 != 0)
    SET     5, (IX+0)                       ; Set bit 5: missile visible on screen
    PUSH    BC
    PUSH    IX                              ; CALL SUB_AE66: write missile tile glyph to VRAM name table
    LD      C, L
    LD      B, (IX+3)
    LD      HL, $AE03
    CALL    SUB_AE66
    POP     IX
    POP     BC

LOC_ADFB:
    LD      DE, $0004
    ADD     IX, DE
    DJNZ    LOC_ADCC
    RET     
    DB      $23, $AE, $26, $AE, $29, $AE, $2C, $AE
    DB      $30, $AE, $34, $AE, $38, $AE, $3C, $AE
    DB      $42, $AE, $46, $AE, $4A, $AE, $4E, $AE
    DB      $54, $AE, $58, $AE, $5C, $AE, $60, $AE
    DB      $01, $01, $DC, $01, $01, $DD, $01, $01
    DB      $DE, $02, $01, $DF, $E0, $01, $02, $E1
    DB      $E6, $01, $02, $E2, $E7, $01, $02, $E3
    DB      $E8, $02, $02, $E4, $E5, $E9, $EA, $01
    DB      $02, $EB, $F0, $01, $02, $EC, $F1, $01
    DB      $02, $ED, $F2, $02, $02, $EE, $EF, $F3
    DB      $F4, $01, $02, $F5, $FA, $01, $02, $F6
    DB      $FB, $01, $02, $F7, $FC, $02, $02, $F8
    DB      $F9, $FD, $FE

SUB_AE66:
    LD      A, C
    AND     $07
    SRL     A
    LD      E, A
    LD      A, B
    AND     $06
    SLA     A
    ADD     A, E
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, E
    PUSH    HL
    POP     IX
    SRL     C
    SRL     C
    SRL     C
    LD      A, B
    AND     $F8
    LD      H, $00
    LD      L, A
    ADD     HL, HL
    ADD     HL, HL
    LD      B, $00
    ADD     HL, BC
    LD      BC, ($7180)                 ; RAM $7180
    ADD     HL, BC
    LD      C, (IX+0)
    LD      B, (IX+1)

LOC_AE9A:
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OR      $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      D, C

LOC_AEA3:
    LD      A, (IX+2)
    INC     IX
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     D
    JP      NZ, LOC_AEA3
    LD      DE, $0020
    ADD     HL, DE
    DJNZ    LOC_AE9A
    RET     

LOC_AEB5:                                   ; LOC_AEB5: process 6 explosion objects — draw expanding ring to VRAM
    LD      IX, $7252                       ; IX = $7252: explosion records (0x16 bytes each)
    LD      E, $06                          ; E = 6: number of explosion slots

LOC_AEBB:                                   ; LOC_AEBB: check bit 7 of flag byte — explosion active?
    BIT     7, (IX+0)                       ; BIT 7, (IX+0): test active flag
    JR      Z, LOC_AEF0
    LD      A, (IX+5)                       ; Load (IX+5) — explosion timer (0 = done)
    AND     A
    JR      Z, LOC_AEF0
    PUSH    DE                              ; PUSH DE: save loop counter
    LD      DE, ($7180)                     ; Load $7180 — VRAM base; set bit 6 (sprite page)
    SET     6, D
    LD      ($717E), SP                     ; $717E = SP: save stack pointer (used as scratch)
    PUSH    IX                              ; PUSH IX: push explosion record base
    POP     HL
    LD      BC, $0004
    ADD     HL, BC                          ; BC = $0004: offset to explosion X/Y fields
    LD      SP, HL
    POP     BC
    LD      A, C
    LD      C, $BF
    POP     HL
    ADD     HL, DE

LOC_AEE0:
    OUT     (C), L
    OUT     (C), H
    POP     HL
    ADD     HL, DE
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    DJNZ    LOC_AEE0
    LD      SP, ($717E)                 ; RAM $717E
    POP     DE

LOC_AEF0:
    LD      BC, $0016
    ADD     IX, BC
    DEC     E
    JR      NZ, LOC_AEBB
    RET     

SOUND_WRITE_AEF9:                           ; SOUND_WRITE_AEF9: SN76489A sound-effect writer using VRAM XOR method
    LD      A, ($7065)                      ; Load $7065 — sound-busy flag (NZ = sound engine busy)
    AND     A
    RET     NZ                              ; Return if sound engine is still playing
    LD      HL, ($7017)                     ; Load $7017 — current VRAM read/write base address
    LD      IX, ($7019)                     ; Load $7019 — pointer to current sound descriptor entry
    LD      A, (IX+0)                       ; Load first byte of sound entry (0 = pad, $FF = end)
    CP      $FF                             ; Compare to $FF: check for end-of-sequence sentinel
    JP      NZ, LOC_AF19                    ; Jump to LOC_AF19 if not end of sequence
    LD      A, $FF                          ; Sound sequence finished — set busy flag $7065 = $FF
    LD      ($7065), A                  ; RAM $7065
    LD      IX, $AF65                       ; Reset IX to start of default idle sequence
    LD      HL, $36E0                       ; Reset VRAM address to $36E0 (idle region)

LOC_AF19:                                   ; LOC_AF19: skip zero (pad) entries, advance IX by 3
    LD      A, (IX+0)
    AND     A
    JP      NZ, LOC_AF2C
    LD      DE, $0008
    ADD     HL, DE
    LD      DE, $0003
    ADD     IX, DE
    JP      LOC_AF19

LOC_AF2C:                                   ; LOC_AF2C: EX DE,HL to swap pointers; load entry count
    DB      $EB
    LD      L, (IX+1)
    LD      H, $00
    ADD     HL, DE
    LD      B, A

LOC_AF34:                                   ; LOC_AF34: XOR loop — read VRAM byte, XOR with entry mask, write back
    CALL    VDP_REG_8289                    ; Set VRAM read address from HL
    IN      A, ($BE)                        ; Read one VRAM byte
    XOR     (IX+2)                          ; XOR with pattern byte from sound entry
    LD      C, A
    CALL    VDP_REG_8280                    ; Set VRAM write address
    LD      A, C                            ; Write XOR result back to VRAM (visual flash effect)
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     HL
    DJNZ    LOC_AF34                        ; DJNZ: repeat for B bytes
    DB      $EB
    LD      DE, $0008
    ADD     HL, DE
    LD      ($7017), HL                     ; $7017 updated to next VRAM row
    LD      DE, $0003
    ADD     IX, DE
    LD      ($7019), IX                     ; $7019 updated to next sound entry
    RET     

SUB_AF58:                                   ; SUB_AF58: init sound sequence pointers to idle/default state
    LD      HL, $AF65                       ; HL = $AF65: pointer to first sound descriptor entry
    LD      ($7019), HL                     ; $7019 = $AF65: sound entry pointer initialised
    LD      HL, $36E0                       ; HL = $36E0: VRAM region for idle sound visual
    LD      ($7017), HL                     ; $7017 = $36E0: VRAM sound-XOR base address
    RET     
    DB      $03, $05, $20, $03, $05, $08, $03, $05
    DB      $02, $00, $00, $00, $03, $05, $80, $01
    DB      $07, $20, $01, $07, $08, $01, $07, $02
    DB      $00, $00, $00, $01, $07, $80, $02, $00
    DB      $20, $02, $00, $08, $02, $00, $02, $00
    DB      $00, $00, $02, $00, $80, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $03, $01, $20, $03
    DB      $01, $08, $03, $01, $02, $00, $00, $00
    DB      $03, $01, $80, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $03, $03, $20, $03, $03, $08
    DB      $03, $03, $02, $00, $00, $00, $03, $03
    DB      $80, $FF

LOC_AFCF:                                   ; LOC_AFCF: game input handler — read 9 controller functions each frame
    CALL    CTRL_READ_AFEB                  ; Read UP-stick → decelerate $7139 (player X velocity)
    CALL    CTRL_READ_B019                  ; Read DOWN-stick → accelerate $7139
    CALL    CTRL_READ_B047                  ; Read FIRE button → activate fire slot at IX=$7147
    CALL    CTRL_READ_B069                  ; Read fourth input function
    CALL    SUB_B244                        ; CALL SUB_B244: process input function 5
    CALL    SUB_B274                        ; CALL SUB_B274: process input function 6
    CALL    SUB_B2A5                        ; CALL SUB_B2A5: process input function 7 (smart-bomb?)
    CALL    CTRL_READ_B2C7                  ; Read input function 8
    CALL    CTRL_READ_B2D6                  ; Read input function 9
    RET     

CTRL_READ_AFEB:                             ; CTRL_READ_AFEB: read UP-stick; update $7143 edge-flag; decelerate $7139
    OUT     ($C0), A                        ; Write $C0 to JOY_PORT: select joystick direction mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                        ; Read controller 1 ($FC)
    CPL                                     ; CPL: invert bits (active-low → active-high)
    AND     $01                             ; AND $01: isolate UP bit
    JR      NZ, LOC_AFFA                    ; JR NZ: UP pressed → LOC_AFFA
    LD      ($7143), A                      ; $7143 = 0: clear UP edge flag
    RET     

LOC_AFFA:                                   ; LOC_AFFA: UP stick held
    LD      A, ($7143)                      ; Load $7143 — UP edge flag
    AND     A
    JR      NZ, LOC_B00A                    ; JR NZ: already latched, just update velocity
    LD      A, $01                          ; $7143 = 1: latch UP edge
    LD      ($7143), A                  ; RAM $7143
    LD      A, $04                          ; $7142 = 4: set UP cooldown timer
    LD      ($7142), A                  ; RAM $7142

LOC_B00A:
    LD      A, ($7139)                      ; Load $7139 — player X velocity
    SUB     $02                             ; SUB 2: decelerate by 2 units
    CP      $20                             ; CP $20: clamp at minimum $20
    JR      NC, LOC_B015
    LD      A, $20                          ; $7139 = $20 if below minimum

LOC_B015:
    LD      ($7139), A                      ; $7139 updated with new (clamped) velocity
    RET     

CTRL_READ_B019:                             ; CTRL_READ_B019: read DOWN-stick; update $7145; accelerate $7139
    OUT     ($C0), A                    ; JOY_PORT - set joystick mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $04                             ; AND $04: isolate DOWN bit
    JR      NZ, LOC_B028                    ; JR NZ: DOWN pressed → LOC_B028
    LD      ($7145), A                      ; $7145 = 0: clear DOWN edge flag
    RET     

LOC_B028:                                   ; LOC_B028: DOWN stick held
    LD      A, ($7145)                  ; RAM $7145
    AND     A
    JR      NZ, LOC_B038
    LD      A, $01
    LD      ($7145), A                      ; $7145 = 1: latch DOWN edge
    LD      A, $04
    LD      ($7144), A                      ; $7144 = 4: set DOWN cooldown timer

LOC_B038:
    LD      A, ($7139)                      ; Load $7139 — player X velocity
    ADD     A, $02                          ; ADD 2: accelerate by 2 units
    CP      $B8                             ; CP $B8: clamp at maximum $B7
    JR      C, LOC_B043
    LD      A, $B7                          ; $7139 = $B7 if over maximum

LOC_B043:
    LD      ($7139), A                      ; $7139 updated
    RET     

CTRL_READ_B047:                             ; CTRL_READ_B047: read FIRE button; init fire slot at $7147
    LD      IX, $7147                       ; IX = $7147: pointer to fire slot record
    OUT     ($C0), A                    ; JOY_PORT - set joystick mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                        ; Read controller 1
    CPL     
    AND     $08                             ; AND $08: isolate FIRE bit

; ============================================================
; GAME DATA  ($B054 - $BBFF)
; Animation, sprite, level, and name-table data.
; (Tracer did not reach this area via static flow; kept as DB.)
; ============================================================
GAME_DATA:                                  ; GAME_DATA: animation, sprite, level, and name-table data block ($B054-)
    LD      B, A
    LD      A, ($713A)                  ; RAM $713A
    AND     A
    JP      NZ, LOC_B08B
    BIT     3, B
    RET     Z
    XOR     A
    LD      ($714A), A                  ; RAM $714A
    LD      ($7146), A                  ; RAM $7146
    JP      LOC_B163

CTRL_READ_B069:
    LD      IX, $7146                   ; RAM $7146
    OUT     ($C0), A                    ; JOY_PORT - set joystick mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $02
    LD      B, A
    LD      A, ($713A)                  ; RAM $713A
    AND     A
    JP      Z, LOC_B08B
    BIT     1, B
    RET     Z
    XOR     A
    LD      ($714A), A                  ; RAM $714A
    LD      ($7147), A                  ; RAM $7147
    JP      LOC_B163

LOC_B08B:
    LD      A, ($714A)                  ; RAM $714A
    AND     A
    JP      NZ, LOC_B163
    LD      A, ($714D)                  ; RAM $714D
    AND     A
    JR      Z, LOC_B09E
    LD      A, B
    AND     A
    JR      NZ, LOC_B0AC
    JR      LOC_B0A2

LOC_B09E:
    LD      A, B
    AND     A
    JR      Z, LOC_B0AC

LOC_B0A2:
    LD      ($714D), A                  ; RAM $714D
    LD      A, $01
    LD      ($714B), A                  ; RAM $714B
    JR      LOC_B0AF

LOC_B0AC:
    LD      ($714D), A                  ; RAM $714D

LOC_B0AF:
    LD      A, ($714D)                  ; RAM $714D
    AND     A
    JP      Z, LOC_B12D
    BIT     0, (IX+0)
    JR      NZ, LOC_B0CF
    LD      A, $03
    LD      ($714E), A                  ; RAM $714E
    LD      A, $01
    LD      ($7063), A                  ; RAM $7063
    LD      (IX+0), A
    LD      ($714B), A                  ; RAM $714B
    LD      ($714C), A                  ; RAM $714C

LOC_B0CF:
    LD      A, $01
    LD      ($713C), A                  ; RAM $713C
    LD      HL, ($704A)                 ; RAM $704A
    LD      A, H
    OR      L
    CALL    Z, SUB_B431
    LD      HL, $714B                   ; RAM $714B
    DEC     (HL)
    JR      NZ, LOC_B10C
    LD      HL, $714E                   ; RAM $714E
    INC     (HL)
    LD      A, (HL)
    CP      $45
    JR      C, LOC_B0ED
    LD      (HL), $45

LOC_B0ED:
    LD      E, (HL)
    LD      D, $00
    LD      HL, $B1B8
    ADD     HL, DE
    LD      A, (HL)
    LD      ($714B), A                  ; RAM $714B

LOC_B0F8:
    LD      A, ($713A)                  ; RAM $713A
    AND     A
    JR      NZ, LOC_B106
    LD      A, $20
    ADD     A, E
    LD      ($7138), A                  ; RAM $7138
    JR      LOC_B10C

LOC_B106:
    LD      A, $CF
    SUB     E
    LD      ($7138), A                  ; RAM $7138

LOC_B10C:
    LD      HL, $714C                   ; RAM $714C
    DEC     (HL)
    RET     NZ
    LD      HL, $B1FE
    LD      A, ($714E)                  ; RAM $714E
    LD      E, A
    LD      D, $00
    ADD     HL, DE
    LD      A, (HL)
    LD      ($714C), A                  ; RAM $714C
    LD      A, ($713A)                  ; RAM $713A
    AND     A
    LD      A, $01
    JR      Z, LOC_B129
    LD      A, $FF

LOC_B129:
    LD      ($7152), A                  ; RAM $7152
    RET     

LOC_B12D:
    BIT     0, (IX+0)
    RET     Z
    LD      A, ($713C)                  ; RAM $713C
    AND     A
    JR      Z, LOC_B13F
    XOR     A
    LD      ($713C), A                  ; RAM $713C
    CALL    SUB_B442

LOC_B13F:
    LD      HL, $714B                   ; RAM $714B
    DEC     (HL)
    JR      NZ, LOC_B10C
    LD      HL, $714E                   ; RAM $714E
    DEC     (HL)
    JR      NZ, LOC_B14F
    LD      (IX+0), $00

LOC_B14F:
    LD      E, (HL)
    LD      A, $45
    SUB     E
    LD      C, E
    LD      D, $00
    LD      E, A
    LD      HL, $B1B8
    ADD     HL, DE
    LD      A, (HL)
    LD      ($714B), A                  ; RAM $714B
    LD      E, C
    JP      LOC_B0F8

LOC_B163:
    LD      A, ($714A)                  ; RAM $714A
    AND     A
    JR      NZ, LOC_B181
    LD      ($714E), A                  ; RAM $714E
    LD      (IX+0), A
    INC     A
    LD      ($714B), A                  ; RAM $714B
    LD      ($714C), A                  ; RAM $714C
    LD      ($714A), A                  ; RAM $714A
    LD      A, ($713A)                  ; RAM $713A
    XOR     $01
    LD      ($713A), A                  ; RAM $713A

LOC_B181:
    LD      A, ($713A)                  ; RAM $713A
    AND     A
    LD      A, ($7138)                  ; RAM $7138
    JR      NZ, LOC_B19D
    SUB     $02
    CP      $20
    JR      NC, LOC_B192
    LD      A, $20

LOC_B192:
    LD      ($7138), A                  ; RAM $7138
    LD      A, $01
    LD      ($7152), A                  ; RAM $7152
    JR      C, LOC_B1B0
    RET     

LOC_B19D:
    ADD     A, $02
    CP      $CF
    JR      C, LOC_B1A5
    LD      A, $CF

LOC_B1A5:
    LD      ($7138), A                  ; RAM $7138
    LD      A, $FF
    LD      ($7152), A                  ; RAM $7152
    JR      NC, LOC_B1B0
    RET     

LOC_B1B0:
    XOR     A
    LD      ($714A), A                  ; RAM $714A
    LD      ($714E), A                  ; RAM $714E
    RET     
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $02, $02, $02
    DB      $02, $02, $02, $02, $04, $04, $04, $04
    DB      $04, $04, $05, $05, $05, $05, $05, $06
    DB      $06, $06, $06, $07, $07, $07, $08, $08
    DB      $08, $09, $09, $0A, $0A, $0C, $0E, $0E
    DB      $10, $3C, $3C, $3C, $3C, $3C, $06, $06
    DB      $06, $06, $06, $07, $04, $04, $04, $04
    DB      $03, $03, $03, $03, $03, $02, $02, $02
    DB      $02, $02, $02, $02, $02, $02, $02, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $01
    DB      $01, $01, $01, $01

SUB_B244:
    LD      A, ($7148)                  ; RAM $7148
    AND     A
    JR      Z, LOC_B24F
    DEC     A
    LD      ($7148), A                  ; RAM $7148
    RET     

LOC_B24F:
    OUT     ($C0), A                    ; JOY_PORT - set joystick mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $40
    JR      NZ, LOC_B25E
    LD      ($7149), A                  ; RAM $7149
    RET     

LOC_B25E:
    LD      A, ($7149)                  ; RAM $7149
    AND     A
    RET     NZ
    LD      A, $0A
    LD      ($7148), A                  ; RAM $7148
    LD      ($7149), A                  ; RAM $7149
    LD      A, $FF
    LD      ($7227), A                  ; RAM $7227
    CALL    SUB_B448
    RET     

SUB_B274:
    LD      A, ($713F)                  ; RAM $713F
    AND     A
    JR      Z, LOC_B27F
    DEC     A
    LD      ($713F), A                  ; RAM $713F
    RET     

LOC_B27F:
    OUT     ($80), A                    ; KEYBOARD_PORT - set keypad mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $40
    RET     Z
    LD      A, ($701D)                  ; RAM $701D
    AND     A
    RET     Z
    DEC     A
    LD      ($701D), A                  ; RAM $701D
    LD      A, $0F
    LD      ($713F), A                  ; RAM $713F
    LD      A, $02
    LD      ($713D), A                  ; RAM $713D
    LD      A, $06
    LD      ($7140), A                  ; RAM $7140
    CALL    SUB_B46A
    RET     

SUB_B2A5:
    LD      A, ($714F)                  ; RAM $714F
    AND     A
    JR      Z, LOC_B2B0
    DEC     A
    LD      ($714F), A                  ; RAM $714F
    RET     

LOC_B2B0:
    OUT     ($80), A                    ; KEYBOARD_PORT - set keypad mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $7F
    CP      $05
    RET     NZ
    LD      A, $14
    LD      ($714F), A                  ; RAM $714F
    LD      A, $FF
    LD      ($7150), A                  ; RAM $7150
    RET     

CTRL_READ_B2C7:
    OUT     ($80), A                    ; KEYBOARD_PORT - set keypad mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $7F
    CP      $06
    RET     NZ
    JP      LOC_8042

CTRL_READ_B2D6:
    OUT     ($80), A                    ; KEYBOARD_PORT - set keypad mode
    DB      $E3
    DB      $E3
    IN      A, ($FC)                    ; CONTROLLER_01 - read controller 1
    CPL     
    AND     $7F
    CP      $09
    RET     NZ
    LD      A, $01
    LD      ($713B), A                  ; RAM $713B
    RET     

VDP_REG_B2E8:                               ; VDP_REG_B2E8: mute SN76489A (4×$9F+$BF); zero sound RAM $7038-$704F
    LD      A, $9F
    OUT     ($FF), A                    ; SOUND_PORT - write SN76489A
    LD      A, $BF
    OUT     ($FF), A                    ; SOUND_PORT - write SN76489A
    LD      A, $DF
    OUT     ($FF), A                    ; SOUND_PORT - write SN76489A
    LD      A, $FF
    OUT     ($FF), A                    ; SOUND_PORT - write SN76489A
    LD      B, $18
    LD      HL, $7038                   ; RAM $7038
    SUB     A

LOC_B2FE:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_B2FE
    RET     

SUB_B303:
    PUSH    AF
    RES     7, A
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      HL, $B888
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      D, (HL)
    LD      A, (DE)
    ADD     A, A
    LD      B, A
    ADD     A, A
    ADD     A, B
    LD      C, A
    LD      B, $00
    LD      HL, $7038                   ; RAM $7038
    ADD     HL, BC
    LD      C, (HL)
    INC     HL
    POP     AF
    BIT     7, A
    JR      NZ, LOC_B331
    LD      B, (HL)
    LD      A, B
    OR      C
    JR      Z, LOC_B331
    PUSH    DE
    DB      $EB
    AND     A
    SBC     HL, BC
    DB      $EB
    POP     DE
    RET     NC

LOC_B331:
    INC     DE
    LD      A, (DE)
    INC     DE
    LD      (HL), D
    DEC     HL
    LD      (HL), E
    INC     HL
    INC     HL
    LD      (HL), A
    INC     HL
    LD      (HL), $01
    INC     HL
    LD      (HL), $00
    INC     HL
    LD      (HL), $00
    RET     

SUB_B344:                                   ; SUB_B344: sound channel sequencer — tick 4 channels ($7038,$703E,$7044,$704A)
    LD      HL, $7038                       ; HL = $7038: channel 0 state block
    CALL    SUB_B359                        ; CALL SUB_B359: advance channel 0 one step
    LD      HL, $703E                       ; HL = $703E: channel 1
    CALL    SUB_B359
    LD      HL, $7044                       ; HL = $7044: channel 2
    CALL    SUB_B359
    LD      HL, $704A                       ; HL = $704A: channel 3

SUB_B359:                                   ; SUB_B359: advance one channel — read pointer; decrement duration; output note
    PUSH    HL                              ; PUSH HL → BC: save channel base
    POP     BC
    LD      E, (HL)                         ; DE = (HL): load note pointer
    INC     HL
    LD      D, (HL)
    LD      A, D                            ; OR E: test if pointer is $0000 (silent)
    OR      E
    RET     Z                               ; Return if channel silent
    INC     HL
    LD      A, (HL)                         ; Load duration byte (offset +2)
    INC     HL
    DEC     (HL)                            ; DEC duration; return if not expired
    RET     NZ
    LD      (HL), A
    LD      A, (DE)                         ; Duration expired — load next note byte from (DE)
    BIT     7, A                            ; BIT 7: check for command byte ($80+)
    JR      Z, LOC_B39B                     ; JR Z: not a command → normal note (LOC_B39B)
    INC     DE                              ; INC DE: advance to next byte in sequence
    CP      $E8                             ; CP $E8: check for end-of-sequence sentinel ($E8)
    JR      NZ, LOC_B376
    SUB     A
    LD      (BC), A
    INC     BC
    LD      (BC), A
    RET     

LOC_B376:
    OUT     ($FF), A                        ; LOC_B376: write raw tone/noise byte to SN76489A port $FF
    AND     $70
    JR      Z, LOC_B384
    CP      $20
    JR      Z, LOC_B384
    CP      $40
    JR      NZ, LOC_B395

LOC_B384:
    LD      A, (DE)
    BIT     6, A
    RES     6, A
    OUT     ($FF), A                    ; SOUND_PORT - write SN76489A
    INC     DE
    JR      Z, LOC_B395
    CALL    LOC_B395
    LD      (HL), $01
    JR      LOC_B3AB

LOC_B395:
    LD      A, E
    LD      (BC), A
    INC     BC
    LD      A, D
    LD      (BC), A
    RET     

LOC_B39B:
    BIT     6, A
    JR      NZ, LOC_B3CA
    AND     A
    JR      NZ, LOC_B3B0

LOC_B3A2:
    INC     DE
    LD      A, (DE)
    LD      (BC), A
    INC     DE
    INC     BC
    LD      A, (DE)
    LD      (BC), A

LOC_B3A9:
    LD      (HL), $01

LOC_B3AB:
    DEC     BC
    PUSH    BC
    POP     HL
    JR      SUB_B359

LOC_B3B0:
    INC     HL
    EX      AF, AF'
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_B3BB
    EX      AF, AF'
    LD      (HL), A
    DEC     HL
    JR      LOC_B3A2

LOC_B3BB:
    DEC     A
    LD      (HL), A
    DEC     HL
    JR      NZ, LOC_B3A2
    INC     DE
    INC     DE

LOC_B3C2:
    INC     DE
    LD      A, E
    LD      (BC), A
    INC     BC
    LD      A, D
    LD      (BC), A
    JR      LOC_B3A9

LOC_B3CA:
    INC     HL
    INC     HL
    EX      AF, AF'
    LD      A, (HL)
    AND     A
    JR      NZ, LOC_B3D6
    EX      AF, AF'
    AND     $1F
    LD      (HL), A
    RET     

LOC_B3D6:
    DEC     A
    LD      (HL), A
    RET     NZ
    DEC     HL
    DEC     HL
    JR      LOC_B3C2
    DB      $3E, $80, $CD, $03, $B3, $3E, $81, $CD
    DB      $03, $B3, $C9, $3E, $82, $CD, $03, $B3
    DB      $3E, $83, $CD, $03, $B3, $C9, $3E, $04
    DB      $CD, $03, $B3, $3E, $05, $CD, $03, $B3
    DB      $C9, $3E, $86, $CD, $03, $B3, $C9, $3E
    DB      $87, $CD, $03, $B3, $3E, $88, $CD, $03
    DB      $B3, $C9

SUB_B40F:
    LD      A, $09
    CALL    SUB_B303
    RET     
    DB      $3E, $8A, $CD, $03, $B3, $3E, $8B, $CD
    DB      $03, $B3, $C9

SUB_B420:
    LD      A, $0C
    CALL    SUB_B303
    LD      A, $0D
    CALL    SUB_B303
    RET     
    DB      $3E, $0E, $CD, $03, $B3, $C9

SUB_B431:
    LD      A, $0F
    CALL    SUB_B303
    RET     

SUB_B437:
    LD      A, $10
    CALL    SUB_B303
    LD      A, $11
    CALL    SUB_B303
    RET     

SUB_B442:
    LD      A, $12
    CALL    SUB_B303
    RET     

SUB_B448:
    LD      A, $93
    CALL    SUB_B303
    LD      A, $94
    CALL    SUB_B303
    RET     
    DB      $3E, $95, $CD, $03, $B3, $3E, $96, $CD
    DB      $03, $B3, $C9

SUB_B45E:
    LD      A, $17
    CALL    SUB_B303
    RET     
    DB      $3E, $18, $CD, $03, $B3, $C9

SUB_B46A:
    LD      A, $99
    CALL    SUB_B303
    LD      A, $9A
    CALL    SUB_B303
    RET     

SUB_B475:
    LD      A, $1B
    CALL    SUB_B303
    LD      A, $1C
    CALL    SUB_B303
    RET     

SUB_B480:
    LD      A, $1D
    CALL    SUB_B303
    LD      A, $1E
    CALL    SUB_B303
    RET     
    DB      $00, $01, $88, $4D, $94, $88, $0E, $88
    DB      $0F, $41, $80, $0F, $80, $0E, $80, $0D
    DB      $9F, $9F, $07, $8D, $B4, $E8, $01, $01
    DB      $BF, $46, $A0, $4C, $B6, $41, $BF, $46
    DB      $A8, $4B, $B6, $41, $BF, $46, $A0, $4B
    DB      $B6, $41, $BF, $46, $A8, $4A, $B6, $41
    DB      $BF, $46, $A0, $4A, $B6, $41, $BF, $46
    DB      $A8, $49, $B6, $41, $BF, $46, $A0, $49
    DB      $B6, $41, $BF, $46, $A8, $48, $B6, $41
    DB      $BF, $E8, $00, $04, $8F, $71, $94, $98
    DB      $96, $98, $95, $98, $96, $98, $02, $DD
    DB      $B4, $94, $98, $96, $98, $95, $98, $96
    DB      $9F, $E8, $01, $04, $AC, $71, $B8, $56
    DB      $BF, $E8, $01, $01, $A0, $4C, $B4, $41
    DB      $A6, $0B, $41, $AB, $0A, $41, $A2, $0A
    DB      $A9, $09, $A0, $0C, $41, $A6, $0B, $41
    DB      $AB, $0A, $41, $A2, $0A, $A9, $09, $A0
    DB      $09, $A0, $08, $A2, $07, $A5, $06, $A0
    DB      $06, $AB, $05, $41, $BF, $E8, $00, $02
    DB      $88, $40, $92, $89, $00, $8A, $00, $8B
    DB      $00, $8C, $00, $8D, $00, $8E, $00, $8F
    DB      $00, $80, $01, $81, $01, $82, $01, $83
    DB      $01, $84, $01, $85, $01, $86, $01, $87
    DB      $01, $88, $01, $89, $01, $8A, $01, $8B
    DB      $01, $8C, $01, $8D, $01, $8E, $01, $8F
    DB      $01, $9F, $E8, $01, $01, $A1, $45, $B7
    DB      $A5, $05, $A1, $45, $B8, $A0, $46, $B9
    DB      $AB, $45, $BA, $A6, $43, $BC, $B9, $A9
    DB      $43, $B7, $A6, $43, $B9, $AC, $43, $BC
    DB      $A1, $45, $BC, $A5, $45, $B9, $A1, $45
    DB      $B7, $A0, $46, $B9, $AB, $45, $BC, $AC
    DB      $43, $B7, $A6, $43, $B7, $A9, $43, $B8
    DB      $A6, $43, $B9, $A0, $44, $BA, $A1, $45
    DB      $B7, $A5, $05, $A1, $45, $B9, $A5, $45
    DB      $BB, $A0, $46, $BD, $AB, $45, $B7, $A5
    DB      $06, $A0, $46, $B9, $A2, $47, $BB, $A5
    DB      $46, $BD, $BF, $E8, $00, $01, $8F, $61
    DB      $96, $94, $93, $93, $94, $94, $95, $95
    DB      $96, $96, $97, $97, $03, $B1, $B5, $9F
    DB      $E8, $01, $01, $AE, $61, $B6, $4B, $AD
    DB      $21, $4B, $AB, $21, $4B, $A8, $21, $4B
    DB      $BF, $E8, $01, $01, $AE, $45, $B5, $A1
    DB      $06, $A4, $06, $A7, $06, $AA, $06, $AD
    DB      $06, $04, $D7, $B5, $BF, $E8, $00, $03
    DB      $89, $43, $9F, $9B, $98, $97, $42, $96
    DB      $96, $97, $97, $96, $96, $01, $F4, $B5
    DB      $9F, $E8, $01, $03, $A1, $45, $BD, $B9
    DB      $B7, $B6, $42, $B7, $B7, $B6, $B6, $B7
    DB      $B7, $01, $08, $B6, $BF, $E8, $03, $01
    DB      $E7, $F6, $F4, $F0, $F2, $F3, $43, $F7
    DB      $F5, $F1, $F3, $F4, $43, $F8, $F6, $F2
    DB      $F4, $F5, $43, $F9, $F7, $F3, $F5, $F6
    DB      $43, $FA, $F8, $F4, $F6, $F7, $43, $FB
    DB      $F9, $F5, $F7, $F8, $43, $F9, $FA, $FB
    DB      $FC, $FD, $FF, $E8, $02, $01, $41, $C7
    DB      $4D, $DA, $C0, $52, $D8, $C6, $55, $D2
    DB      $D6, $D8, $42, $D9, $C7, $4D, $DA, $C0
    DB      $52, $D9, $C6, $55, $D3, $D7, $D9, $42
    DB      $DA, $C7, $4D, $DB, $C0, $52, $D9, $C6
    DB      $55, $D4, $D8, $DA, $42, $DB, $C7, $4D
    DB      $DC, $C0, $52, $DA, $C6, $55, $D5, $D9
    DB      $DB, $42, $DD, $C7, $4D, $DE, $C0, $52
    DB      $DB, $C6, $55, $D6, $DA, $DC, $42, $DE
    DB      $C7, $4D, $DF, $C0, $52, $DC, $C6, $55
    DB      $D7, $DB, $DD, $44, $DE, $43, $DF, $E8
    DB      $03, $01, $E7, $F3, $49, $FF, $E8, $02
    DB      $01, $41, $C6, $43, $D5, $C9, $43, $D8
    DB      $CC, $43, $DA, $C0, $44, $DB, $C4, $44
    DB      $DC, $DC, $DD, $DD, $DE, $DE, $DF, $E8
    DB      $03, $01, $E2, $F0, $F4, $F7, $F9, $FB
    DB      $FC, $FD, $FE, $FE, $FF, $E8, $03, $01
    DB      $E7, $F3, $F5, $F7, $F9, $FB, $FC, $F5
    DB      $F7, $F9, $FB, $FC, $FD, $F7, $F9, $FB
    DB      $FD, $FE, $F9, $FB, $FD, $FE, $FA, $FC
    DB      $FD, $FE, $FB, $FD, $FE, $FF, $E8, $02
    DB      $01, $DF, $C4, $04, $C1, $05, $C0, $06
    DB      $CC, $06, $C9, $07, $C0, $08, $C0, $04
    DB      $C8, $04, $C1, $05, $CB, $05, $C0, $06
    DB      $C5, $06, $CC, $03, $C4, $04, $C8, $04
    DB      $CC, $04, $C1, $05, $C9, $03, $C0, $04
    DB      $C4, $04, $C8, $04, $C9, $03, $CC, $03
    DB      $C0, $04, $C4, $04, $C6, $03, $C9, $03
    DB      $CC, $03, $C0, $04, $E8, $03, $01, $E7
    DB      $F3, $4D, $FF, $E8, $02, $01, $DF, $C8
    DB      $44, $D7, $41, $CC, $04, $C1, $45, $D8
    DB      $C5, $05, $CB, $05, $C0, $06, $C5, $06
    DB      $CC, $06, $C2, $07, $C9, $07, $C0, $08
    DB      $C8, $08, $C0, $09, $DF, $E8, $03, $02
    DB      $E7, $F0, $59, $F2, $F4, $F6, $F8, $FA
    DB      $FC, $FE, $FF, $E8, $02, $02, $DF, $C0
    DB      $04, $C1, $04, $C2, $04, $C3, $04, $C4
    DB      $04, $C5, $04, $C6, $04, $C7, $04, $C8
    DB      $04, $C9, $04, $CA, $04, $CB, $04, $CC
    DB      $04, $CD, $04, $CE, $04, $CF, $04, $C0
    DB      $05, $C1, $05, $C2, $05, $C3, $05, $C4
    DB      $05, $C5, $05, $C6, $05, $C7, $05, $C8
    DB      $05, $C9, $05, $CA, $05, $CB, $05, $CC
    DB      $05, $CD, $05, $CE, $05, $CF, $05, $C0
    DB      $04, $E8, $03, $01, $E7, $F0, $42, $F1
    DB      $42, $F2, $46, $F3, $45, $F4, $47, $F5
    DB      $48, $F6, $4B, $FF, $E8, $02, $01, $DF
    DB      $C5, $05, $CB, $05, $C0, $06, $C5, $06
    DB      $CC, $06, $C2, $07, $C9, $07, $C0, $08
    DB      $C8, $08, $C0, $09, $C9, $09, $C2, $0A
    DB      $CB, $0A, $C6, $0B, $41, $C0, $0C, $41
    DB      $CB, $0C, $41, $C7, $0D, $41, $C4, $0E
    DB      $41, $C2, $0F, $41, $C1, $10, $41, $C0
    DB      $11, $42, $C0, $12, $42, $C1, $13, $42
    DB      $C3, $14, $42, $C6, $15, $42, $CB, $16
    DB      $42, $C0, $18, $42, $E8, $03, $01, $E7
    DB      $F6, $4B, $F5, $48, $F4, $47, $F3, $45
    DB      $F2, $46, $F1, $42, $F0, $42, $FF, $E8
    DB      $02, $01, $DF, $C0, $18, $42, $CB, $16
    DB      $42, $C6, $15, $42, $C3, $14, $42, $C1
    DB      $13, $42, $C0, $12, $42, $C0, $11, $42
    DB      $C1, $10, $41, $C2, $0F, $41, $C4, $0E
    DB      $41, $C7, $0D, $41, $CB, $0C, $41, $C0
    DB      $0C, $41, $C6, $0B, $41, $CB, $0A, $C2
    DB      $0A, $C9, $09, $C0, $09, $C8, $08, $C0
    DB      $08, $C9, $07, $C2, $07, $CC, $06, $C5
    DB      $06, $C0, $06, $CB, $05, $C5, $05, $E8
    DB      $03, $0A, $E7, $F0, $F2, $F3, $F2, $F1
    DB      $F3, $F5, $F7, $F9, $FB, $FD, $FF, $E8
    DB      $02, $0A, $DF, $C0, $06, $C6, $06, $CB
    DB      $06, $CF, $06, $C2, $07, $C4, $07, $C6
    DB      $07, $C8, $07, $CA, $07, $CC, $07, $CE
    DB      $07, $E8, $03, $01, $FF, $E8, $03, $01
    DB      $E6, $F9, $00, $84, $B8, $11, $B6, $3F
    DB      $B6, $93, $B6, $9A, $B6, $E9, $B5, $FD
    DB      $B5, $B3, $B6, $C1, $B6, $E2, $B6, $F5
    DB      $B4, $20, $B7, $27, $B7, $D5, $B4, $ED
    DB      $B4, $56, $B5, $81, $B8, $49, $B7, $57
    DB      $B7, $7D, $B8, $9D, $B7, $B0, $B7, $F8
    DB      $B7, $0B, $B8, $21, $B5, $D5, $B5, $53
    DB      $B8, $63, $B8, $8B, $B4, $A1, $B4, $AF
    DB      $B5, $C4, $B5

LOC_B8C6:                                   ; LOC_B8C6: wave/level init — clear RAM, load anim tables, seed player pos
    LD      HL, $7037                       ; HL = $7037: start of game-state RAM to clear
    LD      BC, $02E8                       ; BC = $02E8: number of bytes to zero

LOC_B8CC:                                   ; LOC_B8CC: zero-fill loop
    XOR     A
    LD      (HL), A
    INC     HL
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_B8CC
    LD      A, $20                          ; $7250 = $20: set enemy-count threshold
    LD      ($7250), A                  ; RAM $7250
    CALL    VDP_DATA_BDAB                   ; Load initial VDP data (colour tables etc.)
    LD      HL, $9D66                       ; HL = $9D66: animation record table in ROM
    LD      DE, $7156                       ; DE = $7156: animation record RAM destination
    LD      BC, $0028                       ; BC = 40 bytes: copy 4 animation records × 10 bytes
    LDIR    
    LD      HL, $B982                       ; HL = $B982: sprite plane data source
    LD      DE, $7182                       ; DE = $7182: sprite plane RAM destination
    LD      BC, $0006                       ; BC = 6 bytes: copy 3 plane pairs
    LDIR    
    LD      DE, $8239                       ; DE = $8239: sprite init data source for record at $70D4
    LD      IX, $70D4                   ; RAM $70D4
    LD      HL, $70D4                   ; RAM $70D4
    CALL    SUB_B97F                        ; Copy sprite init data to $70D4
    LD      DE, $819F                       ; DE = $819F: sprite init data for record at $7136
    LD      IX, $7136                   ; RAM $7136
    LD      HL, $7136                   ; RAM $7136
    CALL    SUB_B97F                        ; Copy sprite init data to $7136
    LD      HL, $8024                       ; HL = $8024: start of dispatch table for main loop
    LD      ($7070), HL                     ; $7070 = $8024: init dispatch pointer
    LD      A, $01                          ; A = $01: game-active flag value
    LD      ($706F), A                      ; $706F = 1: set frame-pacing counter
    LD      A, $6B                          ; A = $6B: initial player X velocity
    LD      ($7139), A                      ; $7139 = $6B: player scroll speed
    LD      A, $20                          ; A = $20: initial player X position
    LD      ($7138), A                      ; $7138 = $20: player sprite X
    LD      A, $00
    LD      ($713A), A                      ; $713A = 0: player direction = right
    LD      DE, $2000                       ; DE = $2000: initial tile column index / scroll
    LD      ($7189), DE                     ; $7189 = $2000
    CALL    SUB_BA3A                        ; CALL SUB_BA3A: additional level-init setup
    CALL    DELAY_LOOP_C5DC                 ; CALL DELAY_LOOP_C5DC: short title-screen display delay
    CALL    SUB_BCD0                        ; CALL SUB_BCD0: randomise initial missile positions
    CALL    VDP_DATA_DDA7                   ; CALL VDP_DATA_DDA7: write initial VDP scroll data
    LD      A, $0E                          ; A = $0E → $706C: sprite colour register value
    LD      ($706C), A                  ; RAM $706C
    LD      A, $3C                          ; A = $3C → $7057: sprite animation frame counter initial value
    LD      ($7057), A                  ; RAM $7057
    XOR     A                               ; $700B = 0: clear extra-life pending flag
    LD      ($700B), A                  ; RAM $700B
    LD      A, ($7007)                      ; Load $7007 — player-alive count
    LD      C, A
    SLA     A                               ; Compute A = ($7007 × 3) clamped to $5A
    ADD     A, C
    CP      $5A
    JR      C, LOC_B954                     ; JP C: clamp if over $5A
    LD      A, $5A

LOC_B954:
    LD      ($700A), A                      ; $700A = clamped lives × 3
    LD      A, R                            ; LD A, R: use refresh counter as entropy source
    AND     $0F
    OR      $08                             ; Mask and seed $7068 — enemy spawn timer
    LD      ($7068), A                  ; RAM $7068
    AND     $03                             ; AND $03: low 2 bits → 0-3
    ADD     A, $01
    LD      ($7069), A                      ; $7069 = (R & $03) + 1: first enemy wave delay
    XOR     A
    LD      ($72D8), A                      ; $72D8 = 0: clear explosion-pending flag
    LD      A, $07                          ; A = $07 → $7151: max active enemies
    LD      ($7151), A                  ; RAM $7151
    LD      A, ($701C)                      ; Load $701C — lives remaining
    CP      $05                             ; CP $05: check if earned bonus
    RET     NZ
    LD      A, ($701B)                  ; RAM $701B
    CP      $00
    CALL    Z, SUB_B420                     ; Conditional bonus award (CALL Z SUB_B420)
    RET     

SUB_B97F:
    JP      LOC_8292
    DB      $06, $00, $18, $07, $00, $1C

DELAY_LOOP_B988:
    XOR     A

LOC_B989:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_B989
    RET     
    DB      $21, $1B, $70, $34

SUB_B992:                                   ; SUB_B992: load sprite animation data based on $701B game mode (0-4)
    LD      A, ($701B)                      ; Load $701B — game mode / animation set index
    CP      $04
    JR      C, LOC_B99B                     ; Clamp to max 3
    LD      A, $03

LOC_B99B:                                   ; LOC_B99B: double A as index into $BB15 pointer table
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      IX, $BB15                       ; IX = $BB15: table of pointers to animation data blocks
    ADD     IX, DE
    LD      E, (IX+0)                       ; Load pointer to selected animation data
    LD      D, (IX+1)
    PUSH    DE
    POP     IX                              ; IX = animation data block start
    LD      HL, $3C00                       ; HL = $3C00: VRAM destination for animation tiles
    CALL    VDP_REG_8280                    ; Set VRAM write address
    XOR     A
    LD      ($7008), A                  ; RAM $7008
    CALL    DELAY_LOOP_B9D5
    CALL    DELAY_LOOP_B9E2
    CALL    DELAY_LOOP_B9F2
    CALL    DELAY_LOOP_BA02
    LD      A, ($7008)                  ; RAM $7008
    LD      ($7007), A                  ; RAM $7007
    XOR     A
    LD      ($700B), A                  ; RAM $700B
    LD      ($7010), A                  ; RAM $7010
    LD      ($7014), A                  ; RAM $7014
    RET     

DELAY_LOOP_B9D5:
    LD      B, (IX+0)

LOC_B9D8:
    PUSH    BC
    LD      A, $80
    CALL    DELAY_LOOP_BA20
    POP     BC
    DJNZ    LOC_B9D8
    RET     

DELAY_LOOP_B9E2:
    LD      A, (IX+1)
    AND     A
    RET     Z
    LD      B, A

LOC_B9E8:
    PUSH    BC
    LD      A, $83
    CALL    DELAY_LOOP_BA20
    POP     BC
    DJNZ    LOC_B9E8
    RET     

DELAY_LOOP_B9F2:
    LD      A, (IX+2)
    AND     A
    RET     Z
    LD      B, A

LOC_B9F8:
    PUSH    BC
    LD      A, $85
    CALL    DELAY_LOOP_BA20
    POP     BC
    DJNZ    LOC_B9F8
    RET     

DELAY_LOOP_BA02:
    LD      A, (IX+2)
    AND     A
    RET     Z
    LD      B, A
    LD      HL, $700C                   ; RAM $700C

LOC_BA0B:
    PUSH    BC
    LD      B, (IX+3)
    LD      (HL), B
    INC     HL

LOC_BA11:
    PUSH    BC
    LD      A, $0C
    CALL    DELAY_LOOP_BA20
    POP     BC
    DJNZ    LOC_BA11
    INC     IX
    POP     BC
    DJNZ    LOC_BA0B
    RET     

DELAY_LOOP_BA20:
    CALL    VDP_DATA_BA33
    XOR     A
    LD      B, $08

LOC_BA26:
    CALL    VDP_DATA_BA33
    DJNZ    LOC_BA26
    LD      A, ($7008)                  ; RAM $7008
    INC     A
    LD      ($7008), A                  ; RAM $7008
    RET     

VDP_DATA_BA33:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    NOP     
    NOP     
    RET     

SUB_BA3A:
    LD      IX, $71E8                   ; RAM $71E8
    XOR     A
    LD      ($72D6), A                  ; RAM $72D6
    LD      ($72DB), A                  ; RAM $72DB
    LD      ($72DD), A                  ; RAM $72DD
    LD      ($72DC), A                  ; RAM $72DC
    LD      A, $1F
    LD      ($72D7), A                  ; RAM $72D7
    LD      A, R
    AND     $1F
    LD      ($72D8), A                  ; RAM $72D8
    LD      A, ($7008)                  ; RAM $7008
    LD      B, A
    LD      HL, $3C00
    LD      ($71FE), HL                 ; RAM $71FE
    LD      ($7200), HL                 ; RAM $7200
    LD      A, $09
    LD      ($7202), A                  ; RAM $7202

LOC_BA69:
    PUSH    BC
    CALL    VDP_DATA_CC19
    LD      A, ($71E8)                  ; RAM $71E8
    BIT     7, A
    JR      Z, LOC_BA95
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $BA80
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    JP      (HL)
    DB      $C3, $A3, $BA, $C3, $BB, $BA, $C3, $9C
    DB      $BA, $C3, $C3, $BA, $C3, $CE, $BA, $C3
    DB      $D9, $BA, $CD, $2D, $CC

LOC_BA95:
    CALL    SUB_CC0D
    POP     BC
    DJNZ    LOC_BA69
    RET     
    DB      $DD, $36, $00, $00, $C3, $92, $BA, $3A
    DB      $1E, $70, $A7, $20, $07, $3E, $81, $32
    DB      $E8, $71, $18, $0B, $CD, $B2, $BC, $3E
    DB      $00, $21, $32, $BB, $C3, $E4, $BA, $3E
    DB      $05, $21, $B2, $BB, $C3, $E4, $BA, $CD
    DB      $68, $BD, $3E, $08, $21, $B2, $BB, $C3
    DB      $E4, $BA, $CD, $84, $BD, $3E, $0C, $21
    DB      $B2, $BB, $C3, $E4, $BA, $CD, $90, $BD
    DB      $3E, $0F, $21, $32, $BC, $C3, $E4, $BA
    DB      $DD, $77, $04, $3A, $D8, $72, $5F, $16
    DB      $00, $3C, $E6, $1F, $32, $D8, $72, $CB
    DB      $23, $CB, $23, $19, $7E, $23, $DD, $77
    DB      $01, $7E, $23, $DD, $77, $02, $7E, $23
    DB      $DD, $77, $03, $7E, $DD, $B6, $00, $DD
    DB      $77, $00, $DD, $36, $05, $01, $C3, $92
    DB      $BA, $1D, $BB, $21, $BB, $25, $BB, $2B
    DB      $BB, $0F, $00, $00, $00, $14, $03, $01
    DB      $08, $14, $04, $03, $04, $07, $02, $14
    DB      $06, $04, $02, $08, $03, $07, $00, $00
    DB      $02, $40, $0C, $00, $02, $00, $82, $02
    DB      $01, $40, $DE, $02, $04, $00, $C8, $00
    DB      $04, $00, $2C, $01, $02, $40, $44, $01
    DB      $02, $40, $1C, $00, $02, $40, $F4, $01
    DB      $05, $00, $DE, $03, $02, $00, $E0, $03
    DB      $02, $00, $84, $00, $01, $00, $A0, $00
    DB      $02, $40, $EA, $01, $03, $00, $22, $01
    DB      $02, $40, $E8, $03, $02, $00, $24, $00
    DB      $04, $00, $00, $01, $05, $40, $22, $01
    DB      $02, $40, $BC, $02, $04, $00, $DC, $02
    DB      $01, $40, $FE, $03, $06, $00, $DC, $00
    DB      $02, $00, $42, $01, $02, $40, $00, $00
    DB      $01, $40, $58, $01, $05, $40, $B0, $02
    DB      $06, $00, $9A, $00, $02, $00, $04, $01
    DB      $04, $00, $26, $02, $02, $40, $A4, $01
    DB      $01, $40, $80, $00, $08, $00, $00, $02
    DB      $3C, $40, $1E, $02, $28, $40, $58, $02
    DB      $40, $40, $64, $02, $32, $40, $64, $02
    DB      $36, $40, $58, $02, $30, $40, $AA, $02
    DB      $78, $40, $A2, $02, $8C, $40, $A6, $02
    DB      $82, $40, $BC, $02, $26, $40, $BE, $02
    DB      $64, $40, $00, $02, $3C, $40, $E8, $03
    DB      $A0, $40, $F4, $03, $70, $40, $92, $02
    DB      $74, $40, $D0, $02, $84, $40, $26, $02
    DB      $62, $40, $3C, $02, $54, $40, $02, $02
    DB      $8C, $40, $80, $02

; ============================================================
; TILE / SPRITE BITMAPS  ($BC00 - $BF6F)
; TMS9918A pattern table -- 8 bytes per tile (one byte per row).
; 110 tiles total.
; ============================================================
TILE_BITMAPS:                               ; TILE_BITMAPS: TMS9918A tile/sprite patterns at $BC00 (110 tiles, 8 bytes each)
    DB      $8A, $40, $6E, $02, $70, $40, $4A, $02; Tile 0: player ship frame A — first 8-byte pattern
    DB      $B4, $40, $DA, $03, $B6, $40, $4A, $03 ; tile 1
    DB      $3C, $40, $44, $02, $30, $40, $5A, $02 ; tile 2
    DB      $B2, $40, $7E, $02, $82, $40, $14, $02 ; tile 3
    DB      $4E, $40, $86, $03, $B4, $40, $64, $02 ; tile 4
    DB      $40, $40, $EA, $03, $A0, $40, $C8, $02 ; tile 5
    DB      $50, $40, $84, $03, $20, $40, $68, $01 ; tile 6
    DB      $B4, $40, $54, $01, $28, $40, $98, $03 ; tile 7
    DB      $AC, $40, $AC, $03, $30, $40, $40, $01 ; tile 8
    DB      $A4, $40, $2C, $01, $38, $40, $C0, $03 ; tile 9
    DB      $9C, $40, $D4, $03, $40, $40, $18, $01 ; tile 10
    DB      $94, $40, $04, $01, $48, $40, $E8, $03 ; tile 11
    DB      $8C, $40, $FC, $03, $50, $40, $F0, $00 ; tile 12
    DB      $84, $40, $DC, $00, $58, $40, $00, $00 ; tile 13
    DB      $7C, $40, $14, $00, $60, $40, $C8, $00 ; tile 14
    DB      $74, $40, $B4, $00, $68, $40, $28, $00 ; tile 15
    DB      $6C, $40, $3C, $00, $70, $40, $A0, $00 ; tile 16
    DB      $64, $40, $8C, $00, $78, $40, $50, $00 ; tile 17
    DB      $5C, $40, $64, $00, $80, $40, $78, $00 ; tile 18
    DB      $54, $40, $64, $00, $88, $40, $78, $00 ; tile 19
    DB      $4C, $40, $8C, $00, $90, $40, $50, $00 ; tile 20
    DB      $44, $40, $3C, $00, $98, $40, $A0, $00 ; tile 21
    DB      $3C, $40, $3A, $D6, $72, $FE, $05, $20 ; tile 22
    DB      $0C, $3A, $D7, $72, $D6, $08, $32, $D7 ; tile 23
    DB      $72, $AF, $32, $D6, $72, $3A, $D7, $72 ; tile 24
    DB      $DD, $77, $06, $21, $D6, $72, $34, $C9 ; tile 25

SUB_BCD0:                                   ; SUB_BCD0: randomise initial active-missile slot positions
    LD      A, ($701E)                  ; RAM $701E
    AND     A
    RET     Z
    LD      B, A
    LD      A, R
    AND     $1F
    LD      E, A
    LD      D, $00
    LD      IX, $7228                   ; RAM $7228

LOC_BCE1:
    LD      HL, $BD08
    ADD     HL, DE
    ADD     HL, DE
    ADD     HL, DE
    INC     E
    RES     5, E
    LD      A, (HL)
    INC     HL
    LD      (IX+1), A
    LD      A, (HL)
    INC     HL
    LD      (IX+2), A
    LD      A, (HL)
    SET     7, A
    LD      (IX+0), A
    LD      (IX+3), $B6
    PUSH    DE
    LD      DE, $0004
    ADD     IX, DE
    POP     DE
    DJNZ    LOC_BCE1
    RET     
    DB      $00, $00, $00, $0A, $00, $40, $20, $00
    DB      $00, $E8, $03, $00, $C8, $00, $40, $00
    DB      $00, $40, $2C, $01, $00, $84, $03, $40
    DB      $E0, $01, $00, $E8, $00, $00, $18, $01
    DB      $00, $C0, $03, $40, $DE, $03, $40, $FC
    DB      $03, $00, $C0, $01, $40, $00, $00, $00
    DB      $0A, $00, $00, $A8, $02, $40, $D0, $02
    DB      $00, $20, $03, $40, $32, $00, $00, $E9
    DB      $02, $40, $28, $03, $00, $64, $00, $00
    DB      $E6, $00, $40, $B8, $01, $40, $F4, $01
    DB      $00, $20, $02, $00, $94, $02, $00, $0C
    DB      $00, $40, $52, $00, $00, $FE, $03, $00
    DB      $3A, $DB, $72, $3C, $FE, $03, $20, $09
    DB      $3A, $DC, $72, $EE, $40, $32, $DC, $72
    DB      $AF, $32, $DB, $72, $3A, $DC, $72, $C6
    DB      $83, $DD, $77, $07, $3A, $DD, $72, $DD
    DB      $77, $06, $C6, $40, $32, $DD, $72, $C9
    DB      $DD, $36, $05, $01, $DD, $36, $06, $01
    DB      $ED, $5F, $47, $3A, $6A, $70, $A8, $ED
    DB      $4F, $E6, $3F, $DD, $77, $07, $E6, $0F
    DB      $28, $E6, $C9

VDP_DATA_BDAB:
    LD      HL, $3C00
    LD      A, ($7008)                  ; RAM $7008
    LD      B, A
    LD      DE, $0009

LOC_BDB5:
    CALL    VDP_REG_8289
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    RES     5, A
    PUSH    AF
    CALL    VDP_REG_8280
    POP     AF
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    ADD     HL, DE
    DJNZ    LOC_BDB5
    RET     
    DB      $CD, $6A, $B4, $3E, $10, $32, $DC, $72
    DB      $3E, $0E, $32, $6C, $70, $3A, $62, $70
    DB      $A7, $28, $FA, $3A, $6C, $70, $FE, $0E
    DB      $3E, $06, $28, $02, $3E, $0E, $32, $6C
    DB      $70, $3E, $02, $32, $6F, $70, $CD, $81
    DB      $80, $21, $DC, $72, $35, $20, $DE, $3E
    DB      $04, $32, $40, $71, $3E, $02, $32, $6F
    DB      $70, $3A, $40, $71, $A7, $28, $05, $CD
    DB      $81, $80, $18, $F0, $CD, $6E, $C0, $CD
    DB      $6C, $BE, $3E, $E3, $D3, $BF, $3E, $81
    DB      $D3, $BF, $06, $1F, $3A, $62, $70, $A7
    DB      $28, $FA, $C5, $CD, $5A, $BE, $CD, $B1
    DB      $BE, $C1, $DB, $BF, $AF, $32, $62, $70
    DB      $CD, $4D, $BE, $10, $E7, $06, $3C, $3A
    DB      $62, $70, $A7, $28, $FA, $C5, $CD, $5A
    DB      $BE, $CD, $BF, $BE, $C1, $DB, $BF, $AF
    DB      $32, $62, $70, $10, $EA, $C9, $3A, $62
    DB      $70, $A7, $28, $FA, $DB, $BF, $AF, $32
    DB      $62, $70, $C9, $21, $00, $1B, $CD, $80
    DB      $82, $21, $8E, $71, $06, $65, $7E, $23
    DB      $D3, $BE, $10, $FA, $C9, $21, $4A, $C1
    DB      $11, $52, $72, $01, $64, $00, $ED, $B0
    DB      $3A, $38, $71, $C6, $08, $5F, $3A, $39
    DB      $71, $C6, $04, $57, $21, $E5, $C0, $DD
    DB      $21, $8E, $71, $06, $19, $7E, $23, $82
    DB      $DD, $77, $00, $DD, $23, $7E, $23, $83
    DB      $DD, $77, $00, $DD, $23, $7E, $23, $DD
    DB      $77, $00, $DD, $23, $7E, $23, $DD, $77
    DB      $00, $DD, $23, $10, $E0, $DD, $36, $00
    DB      $D0, $C9, $DD, $21, $52, $72, $FD, $21
    DB      $8E, $71, $CD, $BF, $BE, $C3, $0A, $C0
    DB      $21, $9E, $71, $11, $D7, $72, $01, $04
    DB      $00, $ED, $B0, $21, $9D, $71, $11, $A1
    DB      $71, $01, $10, $00, $ED, $B8, $21, $D7
    DB      $72, $11, $8E, $71, $01, $04, $00, $ED
    DB      $B0, $21, $62, $72, $11, $D7, $72, $01
    DB      $04, $00, $ED, $B0, $21, $61, $72, $11
    DB      $65, $72, $01, $10, $00, $ED, $B8, $21
    DB      $D7, $72, $11, $52, $72, $01, $04, $00
    DB      $ED, $B0, $21, $B2, $71, $11, $D7, $72
    DB      $01, $04, $00, $ED, $B0, $21, $B1, $71
    DB      $11, $B5, $71, $01, $10, $00, $ED, $B8
    DB      $21, $D7, $72, $11, $A2, $71, $01, $04
    DB      $00, $ED, $B0, $21, $76, $72, $11, $D7
    DB      $72, $01, $04, $00, $ED, $B0, $21, $75
    DB      $72, $11, $79, $72, $01, $10, $00, $ED
    DB      $B8, $21, $D7, $72, $11, $66, $72, $01
    DB      $04, $00, $ED, $B0, $21, $C6, $71, $11
    DB      $D7, $72, $01, $04, $00, $ED, $B0, $21
    DB      $C5, $71, $11, $C9, $71, $01, $10, $00
    DB      $ED, $B8, $21, $D7, $72, $11, $B6, $71
    DB      $01, $04, $00, $ED, $B0, $21, $8A, $72
    DB      $11, $D7, $72, $01, $04, $00, $ED, $B0
    DB      $21

; ============================================================
; ZERO PADDING  ($BF70 - $BFFF)
; ============================================================
    DB      $89, $72, $11, $8D, $72, $01, $10, $00
    DB      $ED, $B8, $21, $D7, $72, $11, $7A, $72
    DB      $01, $04, $00, $ED, $B0, $21, $DA, $71
    DB      $11, $D7, $72, $01, $04, $00, $ED, $B0
    DB      $21, $D9, $71, $11, $DD, $71, $01, $10
    DB      $00, $ED, $B8, $21, $D7, $72, $11, $CA
    DB      $71, $01, $04, $00, $ED, $B0, $21, $9E
    DB      $72, $11, $D7, $72, $01, $04, $00, $ED
    DB      $B0, $21, $9D, $72, $11, $A1, $72, $01
    DB      $10, $00, $ED, $B8, $21, $D7, $72, $11
    DB      $8E, $72, $01, $04, $00, $ED, $B0, $21
    DB      $EE, $71, $11, $D7, $72, $01, $04, $00
    DB      $ED, $B0, $21, $ED, $71, $11, $F1, $71
    DB      $01, $10, $00, $ED, $B8, $21, $D7, $72
    DB      $11, $DE, $71, $01, $04, $00, $ED, $B0
    DB      $21, $B2, $72, $11, $D7, $72, $01, $04
    DB      $00, $ED, $B0, $21, $B1, $72, $11, $B5
    DB      $72, $01, $10, $00, $ED, $B8, $21, $D7
    DB      $72, $11, $A2, $72, $01, $04, $00, $ED
    DB      $B0, $C9, $06, $19, $DD, $CB, $00, $46
    DB      $20, $3D, $DD, $7E, $03, $A7, $28, $37
    DB      $3D, $DD, $77, $03, $21, $C5, $C0, $16
    DB      $00, $5F, $19, $4E, $FD, $7E, $03, $E6
    DB      $80, $B1, $FD, $77, $03, $FD, $7E, $00
    DB      $DD, $86, $01, $FD, $77, $00, $FE, $BE
    DB      $30, $22, $FE, $20, $38, $1E, $FD, $7E
    DB      $01, $DD, $86, $02, $FD, $77, $01, $FE
    DB      $FE, $30, $11, $FE, $01, $38, $0D, $11
    DB      $04, $00, $DD, $19, $11, $04, $00, $FD
    DB      $19, $10, $B1, $C9, $DD, $CB, $00, $C6
    DB      $FD, $36, $00, $00, $FD, $36, $01, $00
    DB      $FD, $36, $03, $00, $18, $E1

SUB_C06E:
    LD      HL, $3C00
    LD      ($71FE), HL                 ; RAM $71FE
    LD      ($7200), HL                 ; RAM $7200
    LD      A, $09
    LD      ($7202), A                  ; RAM $7202
    LD      A, ($7008)                  ; RAM $7008
    LD      B, A

LOC_C080:
    PUSH    BC
    CALL    VDP_DATA_CC19
    LD      IX, $71E8                   ; RAM $71E8
    BIT     7, (IX+0)
    JR      Z, LOC_C0BE
    BIT     5, (IX+0)
    JR      Z, LOC_C0BE
    LD      A, (IX+8)
    LD      C, A
    SLA     A
    LD      B, A
    SLA     A
    SLA     A
    ADD     A, B
    ADD     A, C
    LD      E, A
    LD      D, $00
    LD      IY, $718E                   ; RAM $718E
    ADD     IY, DE
    RES     5, (IX+0)
    BIT     7, (IY+0)
    JR      NZ, LOC_C0BB
    LD      (IY+0), $00
    CALL    SUB_C987

LOC_C0BB:
    CALL    VDP_DATA_CC2D

LOC_C0BE:
    CALL    SUB_CC0D
    POP     BC
    DJNZ    LOC_C080
    RET     
    DB      $00, $06, $08, $08, $09, $09, $09, $09
    DB      $00, $08, $08, $08, $00, $06, $06, $06
    DB      $0A, $0A, $0B, $0B, $04, $04, $05, $05
    DB      $07, $07, $0E, $0E, $0F, $0F, $0F, $0F
    DB      $00, $00, $10, $0F, $00, $00, $14, $0F
    DB      $00, $00, $18, $0F, $00, $20, $1C, $8F
    DB      $00, $20, $20, $8F, $00, $00, $24, $0F
    DB      $00, $00, $28, $0F, $00, $00, $2C, $0F
    DB      $00, $20, $30, $8F, $00, $20, $34, $8F
    DB      $00, $00, $38, $0F, $00, $00, $3C, $0F
    DB      $00, $00, $40, $0F, $00, $20, $44, $8F
    DB      $00, $20, $48, $8F, $00, $00, $4C, $0F
    DB      $00, $00, $50, $0F, $00, $00, $54, $0F
    DB      $00, $20, $58, $8F, $00, $20, $5C, $8F
    DB      $00, $00, $60, $0F, $00, $00, $64, $0F
    DB      $00, $00, $68, $0F, $00, $20, $6C, $8F
    DB      $00, $20, $70, $8F, $D0, $00, $02, $FE
    DB      $20, $00, $02, $FF, $20, $00, $02, $00
    DB      $20, $00, $02, $01, $20, $00, $02, $02
    DB      $20, $00, $01, $FE, $20, $00, $01, $FF
    DB      $20, $00, $01, $00, $20, $00, $01, $01
    DB      $20, $00, $01, $02, $20, $00, $00, $FE
    DB      $20, $00, $00, $FF, $20, $00, $00, $00
    DB      $20, $00, $00, $01, $20, $00, $00, $02
    DB      $20, $00, $FF, $FE, $20, $00, $FF, $FF
    DB      $20, $00, $FF, $00, $20, $00, $FF, $01
    DB      $20, $00, $FF, $02, $20, $00, $FE, $FE
    DB      $20, $00, $FE, $FF, $20, $00, $FE, $00
    DB      $20, $00, $FE, $01, $20, $00, $FE, $02
    DB      $20

SUB_C1AE:                                   ; SUB_C1AE: write sprite tile-index pointers to 6 VRAM sprite-attr addresses
    LD      HL, $2280
    LD      DE, $C496
    LD      BC, $0030
    CALL    VDP_WRITE_C1F7
    LD      HL, $0280
    LD      DE, $C4C6
    LD      BC, $0030
    CALL    VDP_WRITE_C1F7
    LD      HL, $2A80
    LD      DE, $C496
    LD      BC, $0030
    CALL    VDP_WRITE_C1F7
    LD      HL, $0A80
    LD      DE, $C4C6
    LD      BC, $0030
    CALL    VDP_WRITE_C1F7
    LD      HL, $3280
    LD      DE, $C496
    LD      BC, $0030
    CALL    VDP_WRITE_C1F7
    LD      HL, $1280
    LD      DE, $C4C6
    LD      BC, $0030
    CALL    VDP_WRITE_C1F7
    RET     

VDP_WRITE_C1F7:
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OR      $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register

LOC_C1FF:
    LD      A, (DE)
    INC     DE
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JP      NZ, LOC_C1FF
    RET     

LOC_C20A:
    LD      IX, $71E8                   ; RAM $71E8
    LD      HL, $3C00
    LD      ($71FE), HL                 ; RAM $71FE
    LD      ($7200), HL                 ; RAM $7200
    LD      A, $09
    LD      ($7202), A                  ; RAM $7202
    LD      A, ($7008)                  ; RAM $7008
    LD      B, A

LOC_C220:
    PUSH    BC
    CALL    VDP_DATA_CC19
    BIT     7, (IX+0)
    JR      Z, LOC_C274
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      DE, ($7154)                 ; RAM $7154
    AND     A
    SBC     HL, DE
    LD      A, H
    AND     $03
    JR      NZ, LOC_C250
    BIT     7, L
    LD      HL, $FE70
    JR      Z, LOC_C246
    LD      HL, $0190

LOC_C246:
    ADD     HL, DE
    LD      A, H
    AND     $03
    LD      (IX+2), A
    LD      (IX+1), L

LOC_C250:
    LD      A, (IX+0)
    AND     $07
    CP      $00
    JR      NZ, LOC_C271
    LD      (IX+0), $81
    LD      (IX+4), $05
    LD      A, (IX+3)
    CP      $20
    JR      NC, LOC_C271
    LD      A, R
    AND     $7F
    OR      $20
    LD      (IX+3), A

LOC_C271:
    CALL    VDP_DATA_CC2D

LOC_C274:
    CALL    SUB_CC0D
    POP     BC
    DJNZ    LOC_C220
    RET     

VDP_DATA_C27B:
    CALL    SUB_C06E
    LD      HL, $1B08
    CALL    VDP_REG_8280
    LD      A, $D0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    LD      HL, $72DE                   ; RAM $72DE
    LD      B, $50
    CALL    DELAY_LOOP_B988
    LD      HL, $7252                   ; RAM $7252
    LD      B, $84
    CALL    DELAY_LOOP_B988
    LD      HL, $7207                   ; RAM $7207
    LD      B, $20
    CALL    DELAY_LOOP_B988
    LD      HL, $718E                   ; RAM $718E
    LD      B, $58
    CALL    DELAY_LOOP_B988
    LD      A, $00
    LD      ($7346), A                  ; RAM $7346
    LD      ($7345), A                  ; RAM $7345
    LD      A, $10
    LD      ($7016), A                  ; RAM $7016
    CALL    DELAY_LOOP_C311

LOC_C2B8:
    LD      A, ($7062)                  ; RAM $7062
    AND     A
    JR      Z, LOC_C2B8
    IN      A, ($BF)                    ; CTRL_PORT - read VDP status
    XOR     A
    LD      ($7062), A                  ; RAM $7062
    LD      A, ($7346)                  ; RAM $7346
    OR      A
    JR      Z, LOC_C2D1
    DEC     A
    LD      ($7346), A                  ; RAM $7346
    LD      A, ($7345)                  ; RAM $7345

LOC_C2D1:
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, ($706B)                  ; RAM $706B
    AND     $01
    JR      Z, LOC_C2EE
    LD      HL, ($7183)                 ; RAM $7183
    LD      DE, $0080
    ADD     HL, DE
    LD      BC, $0280
    XOR     A
    CALL    VDP_WRITE_C2FE
    JR      LOC_C2F1

LOC_C2EE:
    CALL    LOC_9B7D

LOC_C2F1:
    LD      A, ($7337)                  ; RAM $7337
    OR      A
    JP      Z, LOC_C20A
    CALL    SUB_C330
    JP      LOC_C2B8

VDP_WRITE_C2FE:
    LD      E, A
    LD      A, L
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, H
    OR      $40
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register

LOC_C307:
    LD      A, E
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JP      NZ, LOC_C307
    RET     

DELAY_LOOP_C311:
    LD      A, $01
    LD      ($7337), A                  ; RAM $7337
    LD      ($733C), A                  ; RAM $733C
    LD      HL, $C426
    LD      ($7338), HL                 ; RAM $7338
    LD      HL, $C473
    LD      ($733A), HL                 ; RAM $733A
    LD      B, $08
    LD      HL, $733D                   ; RAM $733D
    XOR     A

LOC_C32B:
    LD      (HL), A
    INC     HL
    DJNZ    LOC_C32B
    RET     

SUB_C330:
    LD      A, ($733C)                  ; RAM $733C
    DEC     A
    JR      Z, LOC_C353
    LD      C, A
    LD      A, ($7346)                  ; RAM $7346
    OR      A
    JR      NZ, LOC_C350
    INC     A
    LD      ($7346), A                  ; RAM $7346
    LD      A, R
    AND     $03
    LD      E, A
    LD      D, $00
    LD      HL, $C492
    ADD     HL, DE
    LD      A, (HL)
    LD      ($7345), A                  ; RAM $7345

LOC_C350:
    LD      A, C
    JR      LOC_C384

LOC_C353:
    LD      HL, ($7338)                 ; RAM $7338
    INC     HL
    INC     HL
    INC     HL
    LD      ($7338), HL                 ; RAM $7338
    LD      HL, ($733A)                 ; RAM $733A
    INC     HL
    LD      A, (HL)
    OR      A
    JR      NZ, LOC_C36B
    LD      ($7337), A                  ; RAM $7337
    LD      ($7346), A                  ; RAM $7346
    RET     

LOC_C36B:
    BIT     7, A
    RES     7, A
    LD      C, A
    JR      NZ, LOC_C374
    SRL     A

LOC_C374:
    LD      ($7346), A                  ; RAM $7346
    XOR     A
    LD      ($7345), A                  ; RAM $7345
    LD      A, C
    LD      ($733A), HL                 ; RAM $733A
    PUSH    AF
    CALL    SUB_B46A
    POP     AF

LOC_C384:
    LD      ($733C), A                  ; RAM $733C
    LD      DE, $C48A
    LD      HL, $733D                   ; RAM $733D
    LD      B, $08

LOC_C38F:
    LD      A, (DE)
    ADD     A, (HL)
    LD      (HL), A
    INC     DE
    INC     HL
    DJNZ    LOC_C38F
    LD      IY, ($7338)                 ; RAM $7338
    LD      DE, ($7183)                 ; RAM $7183
    LD      B, $05

LOC_C3A0:
    PUSH    BC
    EXX     
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    LD      DE, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    EXX     
    CALL    SUB_C3CE
    EXX     
    LD      HL, $FF01
    EXX     
    CALL    SUB_C3CE
    EXX     
    LD      DE, $FF01
    EXX     
    CALL    SUB_C3CE
    EXX     
    LD      HL, JOYSTICK_BUFFER         ; JOYSTICK_BUFFER
    EXX     
    CALL    SUB_C3CE
    INC     IY
    INC     IY
    INC     IY
    POP     BC
    DJNZ    LOC_C3A0
    RET     

SUB_C3CE:
    LD      IX, $733D                   ; RAM $733D
    LD      B, $04

LOC_C3D4:
    LD      A, (IX+0)
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    EXX     
    XOR     H
    ADD     A, L
    EXX     
    ADD     A, (IY+0)
    AND     $1F
    LD      L, A
    LD      A, (IX+1)
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    EXX     
    XOR     D
    ADD     A, E
    EXX     
    ADD     A, (IY+1)
    CP      $08
    JR      NC, LOC_C403
    ADD     A, $0A
    JR      LOC_C40B

LOC_C403:
    CP      $18
    JR      C, LOC_C40B
    SUB     $0F
    JR      LOC_C403

LOC_C40B:
    LD      H, A
    RRCA    
    RRCA    
    RRCA    
    AND     $E0
    OR      L
    LD      L, A
    SRL     H
    SRL     H
    SRL     H
    ADD     HL, DE
    CALL    VDP_REG_8280
    LD      A, (IY+2)
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    INC     IX
    INC     IX
    DJNZ    LOC_C3D4
    RET     
    DB      $03, $12, $50, $19, $14, $51, $11, $15
    DB      $52, $07, $13, $53, $0A, $11, $54, $14
    DB      $10, $55, $04, $16, $50, $0F, $14, $51
    DB      $1C, $12, $52, $15, $14, $53, $0B, $13
    DB      $54, $06, $15, $55, $11, $13, $50, $1D
    DB      $13, $51, $02, $13, $52, $15, $13, $53
    DB      $0C, $12, $54, $06, $14, $55, $1A, $13
    DB      $50, $10, $14, $51, $02, $14, $52, $0B
    DB      $14, $53, $1B, $13, $54, $16, $14, $55
    DB      $10, $13, $50, $02, $02, $03, $03, $03
    DB      $04, $04, $05, $05, $06, $06, $07, $07
    DB      $08, $08, $09, $0A, $0B, $0B, $DA, $00
    DB      $00, $03, $00, $02, $01, $01, $01, $01
    DB      $02, $03, $09, $0B, $0F, $00, $00, $00
    DB      $18, $18, $00, $00, $00, $06, $04, $00
    DB      $00, $20, $70, $00, $00, $40, $C0, $00
    DB      $00, $04, $01, $04, $00, $00, $02, $10
    DB      $80, $00, $20, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $30, $10, $00, $00, $00
    DB      $80, $08, $60, $00, $00, $00, $00, $00
    DB      $F0, $F0, $00, $00, $00, $A0, $A0, $00
    DB      $00, $60, $60, $00, $00, $F0, $F0, $00
    DB      $00, $A0, $A0, $A0, $00, $00, $F0, $F0
    DB      $F0, $00, $F0, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $60, $60, $00, $00, $00
    DB      $90, $90, $90, $00, $00

LOC_C4F6:
    LD      (IX+5), B
    XOR     A
    LD      (IX+7), A
    LD      (IX+6), C
    LD      (IX+4), $10
    RET     
    DB      $3A, $6B, $70, $E6, $01, $C0, $DD, $CB
    DB      $00, $6E, $CA, $68, $C5, $DD, $7E, $07
    DB      $A7, $CC, $53, $B4, $DD, $5E, $07, $16
    DB      $00, $CB, $23, $21, $0A, $C6, $19, $7E
    DB      $23, $66, $6F, $E5, $FD, $E1, $FD, $7E
    DB      $00, $A7, $28, $37, $47, $FD, $23, $FD
    DB      $5E, $00, $FD, $23, $DD, $7E, $0A, $CB
    DB      $3F, $CB, $3F, $CB, $3F, $83, $FE, $20
    DB      $30, $1B, $5F, $DD, $7E, $03, $E6, $F8
    DB      $6F, $26, $00, $29, $29, $16, $00, $19
    DB      $ED, $5B, $80, $71, $19, $CD, $80, $82
    DB      $DD, $7E, $05, $D3, $BE, $10, $D0, $DD
    DB      $36, $08, $3F, $DD, $34, $07, $DD, $7E
    DB      $07, $FE, $20, $C0, $DD, $7E, $06, $DD
    DB      $77, $04, $DD, $7E, $00, $E6, $07, $FE
    DB      $05, $20, $1B, $DD, $36, $05, $01, $DD
    DB      $36, $06, $01, $ED, $5F, $47, $3A, $6A
    DB      $70, $A8, $ED, $4F, $E6, $3F, $DD, $77
    DB      $07, $E6, $0F, $28, $E6, $C9, $DD, $36
    DB      $05, $01, $ED, $5F, $E6, $03, $DD, $77
    DB      $06, $C0, $DD, $36, $06, $02, $C9

SUB_C5AC:
    LD      DE, ($7154)                 ; RAM $7154
    LD      L, (IX+1)
    LD      H, (IX+2)
    AND     A
    SBC     HL, DE
    LD      A, H
    AND     $03
    RET     NZ
    LD      A, (IX+3)
    CP      $20
    RET     C
    LD      A, (IX+0)
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $C5D6
    ADD     HL, DE
    LD      B, (HL)
    LD      C, (IX+4)
    JP      LOC_C4F6
    DB      $D6, $D3, $D6, $00, $00, $D7

DELAY_LOOP_C5DC:
    LD      IX, $71E8                   ; RAM $71E8
    LD      HL, $3C00
    LD      ($71FE), HL                 ; RAM $71FE
    LD      ($7200), HL                 ; RAM $7200
    LD      HL, $0009
    LD      ($7202), HL                 ; RAM $7202
    LD      A, ($7008)                  ; RAM $7008
    LD      B, A

LOC_C5F3:
    PUSH    BC
    CALL    VDP_DATA_CC19
    BIT     7, (IX+0)
    JR      Z, LOC_C603
    CALL    SUB_C5AC
    CALL    VDP_DATA_CC2D

LOC_C603:
    CALL    SUB_CC0D
    POP     BC
    DJNZ    LOC_C5F3
    RET     
    DB      $4A, $C6, $54, $C6, $5E, $C6, $68, $C6
    DB      $6D, $C6, $72, $C6, $77, $C6, $81, $C6
    DB      $86, $C6, $8E, $C6, $91, $C6, $99, $C6
    DB      $A2, $C6, $AA, $C6, $B2, $C6, $BA, $C6
    DB      $C0, $C6, $CD, $C6, $D6, $C6, $E1, $C6
    DB      $EA, $C6, $F3, $C6, $FF, $C6, $06, $C7
    DB      $12, $C7, $18, $C7, $20, $C7, $28, $C7
    DB      $30, $C7, $36, $C7, $3C, $C7, $3F, $C7
    DB      $09, $F0, $F4, $F8, $FC, $01, $04, $08
    DB      $0C, $10, $09, $F1, $F4, $F8, $FC, $FF
    DB      $04, $08, $0C, $10, $09, $F1, $F5, $F8
    DB      $FC, $01, $04, $08, $0C, $0F, $04, $F2
    DB      $F9, $FF, $08, $04, $01, $04, $0B, $0E
    DB      $04, $04, $07, $0A, $0E, $09, $F3, $F6
    DB      $F9, $FC, $FF, $04, $07, $0A, $0D, $04
    DB      $F4, $FA, $FF, $FC, $07, $F4, $F7, $FA
    DB      $FD, $06, $09, $0C, $02, $FA, $FD, $07
    DB      $F8, $FA, $01, $03, $06, $09, $0B, $08
    DB      $F5, $F8, $FD, $01, $03, $06, $08, $0B
    DB      $07, $F6, $FB, $FD, $FF, $03, $05, $08
    DB      $07, $F7, $F9, $FB, $FF, $03, $05, $0A
    DB      $07, $F7, $F9, $FB, $FF, $03, $05, $07
    DB      $05, $FA, $FE, $01, $05, $09, $0C, $E8
    DB      $E9, $F8, $FA, $FC, $FE, $01, $04, $06
    DB      $08, $17, $18, $08, $EA, $FC, $FE, $01
    DB      $02, $04, $06, $08, $0A, $EC, $F9, $FB
    DB      $FC, $FE, $FF, $02, $04, $07, $15, $08
    DB      $ED, $FE, $FF, $02, $04, $05, $07, $13
    DB      $08, $EE, $FA, $FC, $FD, $01, $02, $05
    DB      $12, $0B, $EF, $F0, $FB, $FD, $FE, $FF
    DB      $02, $03, $06, $10, $11, $06, $FB, $FC
    DB      $03, $04, $05, $0F, $0B, $F2, $F3, $FC
    DB      $FD, $FF, $01, $02, $03, $04, $05, $0D
    DB      $05, $F4, $FC, $FE, $04, $0C, $07, $F6
    DB      $FD, $FF, $01, $02, $04, $0B, $07, $F7
    DB      $FD, $FE, $01, $03, $08, $09, $07, $F8
    DB      $FE, $FF, $01, $02, $03, $07, $05, $F8
    DB      $FE, $FF, $02, $06, $05, $FB, $FC, $FF
    DB      $01, $04, $02, $FF, $01, $04, $FE, $FF
    DB      $01, $02, $3E, $06, $D3, $BF, $3E, $82
    DB      $D3, $BF, $21, $00, $1B, $CD, $80, $82
    DB      $3E, $D0, $D3, $BE, $21, $80, $18, $CD
    DB      $80, $82, $01, $80, $02, $AF, $D3, $BE
    DB      $0B, $78, $B1, $20, $F8, $21, $0A, $19
    DB      $11, $1E, $C8, $CD, $E2, $C7, $21, $4B
    DB      $19, $11, $2A, $C8, $CD, $E2, $C7, $21
    DB      $AB, $19, $11, $34, $C8, $CD, $E2, $C7
    DB      $CD, $EF, $C7, $21, $B3, $19, $CD, $80
    DB      $82, $3A, $1B, $70, $3C, $FE, $06, $38
    DB      $02, $3E, $05, $57, $C6, $0A, $D3, $BE
    DB      $3A, $1E, $70, $A7, $28, $21, $47, $21
    DB      $0B, $1A, $CD, $80, $82, $3E, $DC, $D3
    DB      $BE, $23, $E5, $D5, $C5, $42, $0E, $00
    DB      $CD, $E4, $DD, $06, $0F, $CD, $4D, $BE
    DB      $10, $FB, $C1, $D1, $E1, $10, $E3, $3A
    DB      $1B, $70, $47, $3A, $15, $70, $B8, $20
    DB      $0F, $C6, $05, $32, $15, $70, $3E, $0A
    DB      $32, $1E, $70, $3E, $08, $32, $16, $70
    DB      $06, $78, $CD, $4D, $BE, $10, $FB, $C9
    DB      $CD, $80, $82, $1A, $13, $47, $1A, $13
    DB      $D3, $BE, $10, $FA, $C9, $21, $16, $19
    DB      $CD, $80, $82, $3A, $1B, $70, $3C, $FE
    DB      $64, $38, $07, $06, $64, $CD, $0F, $C8
    DB      $18, $04, $FE, $0A, $38, $05, $06, $0A
    DB      $CD, $0F, $C8, $06, $01, $0E, $0A, $90
    DB      $38, $03, $0C, $18, $FA, $80, $F5, $79
    DB      $D3, $BE, $F1, $C9, $0B, $14, $15, $15
    DB      $14, $16, $17, $00, $18, $14, $19, $1A
    DB      $09, $16, $1B, $1C, $1D, $1E, $1A, $15
    DB      $1A, $1F, $0B, $20, $1B, $21, $22, $23
    DB      $00, $24, $00, $00, $0A, $0A, $DD, $36
    DB      $00, $82, $2A, $51, $70, $DD, $75, $01
    DB      $DD, $74, $02, $3A, $53, $70, $DD, $77
    DB      $03, $06, $D6, $0E, $11, $CD, $F6, $C4
    DB      $AF, $32, $50, $70, $C9

SUB_C85F:                                   ; SUB_C85F: NMI sprite update — DEC $7057 anim counter; copy $7138/$7154 to sprite pos
    LD      HL, $7057                   ; RAM $7057
    DEC     (HL)
    RET     NZ
    LD      (HL), $3C
    LD      HL, $700A                   ; RAM $700A
    DEC     (HL)
    JP      NZ, LOC_C8A1
    LD      A, ($7138)                  ; RAM $7138
    LD      E, A
    LD      D, $00
    LD      HL, ($7154)                 ; RAM $7154
    ADD     HL, DE
    LD      A, H
    AND     $03
    LD      H, A
    LD      ($7051), HL                 ; RAM $7051
    LD      A, ($7139)                  ; RAM $7139
    LD      ($7053), A                  ; RAM $7053
    LD      A, $01
    LD      ($7050), A                  ; RAM $7050
    LD      A, ($700B)                  ; RAM $700B
    LD      E, A
    LD      D, $00
    INC     A
    AND     $07
    JR      NZ, LOC_C896
    LD      A, $07

LOC_C896:
    LD      ($700B), A                  ; RAM $700B
    LD      HL, $C8D1
    ADD     HL, DE
    LD      A, (HL)
    LD      ($700A), A                  ; RAM $700A

LOC_C8A1:
    LD      A, ($72D8)                  ; RAM $72D8
    AND     A
    RET     NZ
    LD      HL, $7068                   ; RAM $7068
    DEC     (HL)
    RET     NZ
    LD      A, ($701B)                  ; RAM $701B
    CP      $0C
    JR      NC, LOC_C8BB
    LD      A, R
    AND     $0F
    OR      $04
    LD      (HL), A
    JR      LOC_C8C2

LOC_C8BB:
    LD      A, R
    AND     $07
    OR      $01
    LD      (HL), A

LOC_C8C2:
    LD      A, R
    AND     $07
    OR      $02
    LD      ($7069), A                  ; RAM $7069
    LD      A, $01
    LD      ($72D8), A                  ; RAM $72D8
    RET     
    DB      $0E, $0C, $07, $06, $05, $04, $03, $02

VDP_REG_C8D9:                               ; VDP_REG_C8D9: if $7150 flag set — clear display flag and update VDP colour reg
    LD      A, ($7150)                  ; RAM $7150
    AND     A
    RET     Z
    XOR     A
    LD      ($7150), A                  ; RAM $7150
    LD      ($7140), A                  ; RAM $7140
    LD      ($714E), A                  ; RAM $714E
    LD      ($714B), A                  ; RAM $714B
    LD      ($714C), A                  ; RAM $714C
    LD      ($714A), A                  ; RAM $714A
    LD      ($714D), A                  ; RAM $714D
    LD      ($713D), A                  ; RAM $713D
    LD      ($7147), A                  ; RAM $7147
    LD      ($7146), A                  ; RAM $7146
    LD      ($713A), A                  ; RAM $713A
    LD      A, $20
    LD      ($7138), A                  ; RAM $7138
    LD      A, $70
    LD      ($7139), A                  ; RAM $7139
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $87
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      HL, $1B00
    CALL    VDP_REG_8280
    LD      A, $D0
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    CALL    SUB_C06E
    LD      HL, $72DE                   ; RAM $72DE
    LD      B, $50
    CALL    DELAY_LOOP_B988
    LD      HL, $7252                   ; RAM $7252
    LD      B, $84
    CALL    DELAY_LOOP_B988
    LD      HL, $7207                   ; RAM $7207
    LD      B, $20
    CALL    DELAY_LOOP_B988
    LD      HL, $718E                   ; RAM $718E
    LD      B, $58
    CALL    DELAY_LOOP_B988
    LD      HL, $1880
    CALL    VDP_REG_8280
    LD      BC, $0280

LOC_C946:
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_C946
    LD      HL, $1C80
    CALL    VDP_REG_8280
    LD      BC, $0280

LOC_C957:
    XOR     A
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DEC     BC
    LD      A, B
    OR      C
    JR      NZ, LOC_C957
    LD      A, $80
    LD      ($7152), A                  ; RAM $7152
    CALL    SUB_9BC5
    LD      A, $80
    LD      ($7152), A                  ; RAM $7152
    CALL    SUB_9BC5
    LD      A, R
    AND     $07
    JR      NZ, LOC_C976
    INC     A

LOC_C976:
    LD      C, A
    LD      A, ($7151)                  ; RAM $7151
    SUB     C
    LD      ($7151), A                  ; RAM $7151
    JR      C, LOC_C981
    RET     NZ

LOC_C981:
    LD      A, $01
    LD      ($7067), A                  ; RAM $7067
    RET     

SUB_C987:
    LD      A, (IX+0)
    LD      (IX+0), $00
    AND     $07
    CP      $02
    RET     Z
    LD      HL, $7007                   ; RAM $7007
    DEC     (HL)
    RET     
    DB      $3A, $61, $70, $32, $60, $70, $AF, $32
    DB      $61, $70, $AF, $32, $09, $70, $32, $DB
    DB      $72, $21, $00, $3C, $22, $FE, $71, $22
    DB      $00, $72, $21, $09, $00, $22, $02, $72
    DB      $CD, $3A, $DC, $DD, $21, $E8, $71, $3A
    DB      $08, $70, $4F, $C5, $CD, $D0, $DD, $CD
    DB      $19, $CC, $CD, $CB, $DE, $CD, $D0, $DD
    DB      $DD, $CB, $00, $7E, $C2, $E8, $C9, $DD
    DB      $CB, $00, $5E, $C2, $62, $CB, $3A, $50
    DB      $70, $A7, $CA, $62, $CB, $CD, $40, $C8
    DB      $DD, $7E, $00, $E6, $07, $FE, $02, $28
    DB      $04, $21, $09, $70, $34, $DD, $CB, $00
    DB      $6E, $CA, $8E, $CA, $DD, $7E, $08, $FE
    DB      $09, $38, $0A, $DD, $36, $00, $00, $CD
    DB      $2D, $CC, $C3, $62, $CB, $4F, $CB, $27
    DB      $47, $CB, $27, $CB, $27, $80, $81, $5F
    DB      $16, $00, $FD, $21, $8E, $71, $FD, $19
    DB      $FD, $CB, $00, $7E, $20, $13, $CD, $87
    DB      $C9, $CD, $2D, $CC, $AF, $32, $DB, $72
    DB      $FD, $77, $00, $CD, $D0, $DD, $C3, $62
    DB      $CB, $FD, $CB, $00, $6E, $28, $35, $3A
    DB      $3D, $71, $A7, $28, $1A, $CD, $87, $C9
    DB      $CD, $2D, $CC, $FD, $E5, $DD, $E5, $FD
    DB      $E5, $DD, $E1, $CD, $29, $DA, $CD, $D0
    DB      $DD, $DD, $E1, $FD, $E1, $18, $CD, $FD
    DB      $7E, $01, $DD, $77, $01, $FD, $7E, $02
    DB      $DD, $77, $02, $FD, $7E, $03, $DD, $77
    DB      $03, $C3, $5A, $CB, $FD, $E5, $E1, $DD
    DB      $E5, $D1, $01, $09, $00, $ED, $B0, $DD
    DB      $7E, $00, $E6, $C7, $DD, $77, $00, $AF
    DB      $FD, $77, $00, $32, $DB, $72, $3A, $60
    DB      $70, $E6, $0F, $20, $02, $3E, $0F, $47
    DB      $C5, $CD, $D0, $DD, $CD, $54, $CD, $C1
    DB      $10, $F6, $DD, $6E, $01, $DD, $66, $02
    DB      $ED, $5B, $54, $71, $E5, $A7, $ED, $52
    DB      $7C, $E1, $E6, $03, $C2, $54, $CB, $DD
    DB      $7E, $03, $FE, $20, $DA, $54, $CB, $FE
    DB      $C0, $D2, $54, $CB, $3A, $DB, $72, $A7
    DB      $28, $10, $11, $00, $01, $19, $7C, $E6
    DB      $03, $DD, $75, $01, $DD, $77, $02, $C3
    DB      $54, $CB, $06, $08, $0E, $00, $FD, $21
    DB      $8E, $71, $11, $0B, $00, $FD, $CB, $00
    DB      $66, $28, $15, $FD, $7E, $00, $E6, $07
    DB      $FE, $07, $28, $0C, $FD, $19, $0C, $10
    DB      $EC, $3E, $01, $32, $DB, $72, $18, $CA
    DB      $ED, $5B, $54, $71, $A7, $ED, $52, $DD
    DB      $CB, $00, $5E, $28, $06, $DD, $CB, $00
    DB      $9E, $18, $08, $CB, $7D, $2E, $08, $28
    DB      $02, $2E, $F8, $26, $00, $19, $DD, $75
    DB      $01, $DD, $74, $02, $79, $DD, $E5, $E1
    DB      $FD, $E5, $D1, $01, $09, $00, $ED, $B0
    DB      $DD, $CB, $00, $EE, $FD, $CB, $00, $E6
    DB      $DD, $77, $08, $ED, $5F, $E6, $3F, $F6
    DB      $20, $FD, $77, $08, $DD, $7E, $00, $E6
    DB      $07, $06, $00, $4F, $21, $F4, $CB, $09
    DB      $7E, $FD, $77, $09, $CD, $2D, $CC, $CD
    DB      $D0, $DD, $DD, $7E, $00, $E6, $07, $CD
    DB      $E9, $DC, $CD, $0D, $CC, $C1, $0D, $C2
    DB      $C3, $C9, $CD, $55, $DD, $3A, $09, $70
    DB      $ED, $4B, $10, $70, $81, $32, $07, $70
    DB      $3A, $3D, $71, $A7, $C8, $3D, $32, $3D
    DB      $71, $C9

SUB_CB82:                                   ; SUB_CB82: main-loop sprite calc — compute sprite X from $7138+$7154; update anim
    LD      A, ($7055)                      ; Load $7055 — previous sprite X (for delta)
    LD      C, A
    LD      A, ($7138)                      ; Load $7138 — player screen X
    LD      L, A
    LD      H, $00
    LD      DE, ($7154)                     ; Load $7154 — world scroll accumulator
    ADD     HL, DE                          ; HL = $7138 + $7154: absolute sprite X (16-bit)
    LD      A, H
    AND     $03                             ; Mask H to 2 bits: wrap at $0400
    LD      H, A
    LD      ($7055), HL                     ; $7055 = new absolute X
    LD      A, L
    SUB     C                               ; A = new X - old X: compute delta for this frame
    LD      ($7054), A                      ; $7054 = delta X (used for momentum/scroll-sync)
    LD      A, ($705B)                      ; Load $705B — animation tick counter
    LD      ($705C), A                      ; $705C = old tick (saved for double-update check)
    XOR     A
    LD      ($705B), A                      ; $705B = 0: clear animation tick
    LD      ($705F), A                  ; RAM $705F
    LD      B, $08
    LD      IX, $718E                       ; IX = $718E: enemy sprite record array

LOC_CBB0:                                   ; LOC_CBB0: process each enemy entry
    BIT     7, (IX+0)                       ; BIT 7: check active
    JR      Z, LOC_CBCE
    BIT     5, (IX+0)                       ; BIT 5: check on-screen
    JR      Z, LOC_CBCE
    PUSH    BC
    CALL    SUB_CC41
    CALL    SUB_CD54
    LD      A, ($705C)                  ; RAM $705C
    AND     A
    CALL    NZ, SUB_CD54
    CALL    SUB_D545
    POP     BC

LOC_CBCE:
    CALL    SUB_D7F3
    LD      DE, $000B
    ADD     IX, DE
    DEC     B
    RET     Z
    LD      A, ($7062)                  ; RAM $7062
    AND     A
    JR      Z, LOC_CBB0
    PUSH    IX
    PUSH    BC
    CALL    SUB_8146
    POP     BC
    POP     IX
    IN      A, ($BF)                    ; CTRL_PORT - read VDP status
    XOR     A
    LD      ($7062), A                  ; RAM $7062
    LD      A, $01
    LD      ($705B), A                  ; RAM $705B
    JR      LOC_CBB0
    DB      $02, $0A, $03, $0D, $06, $07, $0F, $0F
    DB      $4D, $AF, $06, $08, $CB, $1B, $30, $01
    DB      $81, $1F, $CB, $1B, $10, $F8, $67, $6B
    DB      $C9

SUB_CC0D:
    LD      HL, ($7200)                 ; RAM $7200
    LD      E, $09
    LD      D, $00
    ADD     HL, DE
    LD      ($7200), HL                 ; RAM $7200
    RET     

VDP_DATA_CC19:
    PUSH    BC
    LD      HL, ($7200)                 ; RAM $7200
    CALL    VDP_REG_8289
    LD      B, $09
    LD      HL, $71E8                   ; RAM $71E8

LOC_CC25:
    IN      A, ($BE)                    ; DATA_PORT - read VRAM
    LD      (HL), A
    INC     HL
    DJNZ    LOC_CC25
    POP     BC
    RET     

VDP_DATA_CC2D:
    PUSH    BC
    LD      HL, ($7200)                 ; RAM $7200
    CALL    VDP_REG_8280
    LD      B, $09
    LD      HL, $71E8                   ; RAM $71E8

LOC_CC39:
    LD      A, (HL)
    INC     HL
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    DJNZ    LOC_CC39
    POP     BC
    RET     

SUB_CC41:
    LD      A, (IX+4)
    CP      $10
    RET     Z
    LD      IY, $71F3                   ; RAM $71F3
    LD      A, (IX+10)
    LD      (IY+4), A
    LD      A, (IX+3)
    LD      (IY+6), A
    LD      A, (IX+0)
    AND     $07
    CP      $07
    PUSH    AF
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      HL, $CD02
    ADD     HL, DE
    LD      A, (HL)
    LD      (IY+5), A
    INC     HL
    LD      A, (HL)
    LD      (IY+7), A
    POP     AF
    JP      Z, LOC_CCDB
    CALL    SUB_CC7D
    JP      NC, LOC_CCDB
    JP      LOC_CCFA

SUB_CC7D:
    LD      (IY+1), $10
    LD      (IY+3), $03
    PUSH    IX
    LD      IX, $7207                   ; RAM $7207
    LD      B, $04

LOC_CC8D:
    BIT     7, (IX+0)
    JR      Z, LOC_CCD1
    BIT     1, (IX+7)
    JR      NZ, LOC_CCD1
    LD      A, (IX+5)
    BIT     0, (IX+7)
    JR      NZ, LOC_CCA8
    ADD     A, (IX+3)
    DEC     A
    JR      LOC_CCAB

LOC_CCA8:
    SUB     (IX+3)

LOC_CCAB:
    ADD     A, A
    ADD     A, A
    ADD     A, A
    LD      (IY+0), A
    LD      A, (IX+6)
    ADD     A, A
    ADD     A, A
    ADD     A, A
    LD      C, A
    LD      A, (IX+4)
    SUB     $D8
    ADD     A, A
    ADD     A, C
    LD      (IY+2), A
    PUSH    BC
    CALL    SUB_CD12
    POP     BC
    JR      NC, LOC_CCD1
    RES     7, (IX+0)
    POP     IX
    SCF     
    RET     

LOC_CCD1:
    LD      DE, $0008
    ADD     IX, DE
    DJNZ    LOC_CC8D
    POP     IX
    RET     

LOC_CCDB:
    LD      A, ($7138)                  ; RAM $7138
    LD      (IY+0), A
    LD      A, ($7139)                  ; RAM $7139
    ADD     A, $02
    LD      (IY+2), A
    LD      (IY+1), $0F
    LD      (IY+3), $04
    CALL    SUB_CD12
    RET     NC
    LD      A, $01
    LD      ($7067), A                  ; RAM $7067

LOC_CCFA:
    RES     7, (IX+0)
    CALL    SUB_DA29
    RET     
    DB      $08, $08, $08, $08, $08, $06, $08, $08
    DB      $05, $05, $06, $06, $02, $02, $03, $03

SUB_CD12:
    LD      B, (IY+0)
    LD      C, (IY+1)
    LD      D, (IY+4)
    CALL    SUB_CD4B
    JR      C, LOC_CD40
    LD      E, (IY+5)
    CALL    SUB_CD42
    JR      C, LOC_CD40
    LD      B, (IY+2)
    LD      C, (IY+3)
    LD      D, (IY+6)
    CALL    SUB_CD4B
    JR      C, LOC_CD40
    LD      E, (IY+7)
    CALL    SUB_CD42
    JR      C, LOC_CD40

LOC_CD3E:
    SCF     
    RET     

LOC_CD40:
    AND     A
    RET     

SUB_CD42:
    LD      A, D
    ADD     A, E
    JR      C, LOC_CD40
    CP      B
    JR      C, LOC_CD3E
    JR      LOC_CD40

SUB_CD4B:
    LD      A, B
    ADD     A, C
    JR      C, LOC_CD40
    CP      D
    JR      C, LOC_CD3E
    JR      LOC_CD40

SUB_CD54:
    LD      E, (IX+4)
    LD      D, $00
    SLA     E
    LD      HL, $CD64
    ADD     HL, DE
    LD      E, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, E
    JP      (HL)
    DB      $8C, $CD, $AE, $CD, $DA, $CD, $28, $CF
    DB      $52, $CF, $CE, $CF, $DA, $CF, $55, $D0
    DB      $83, $D1, $79, $D7, $CA, $D7, $DF, $D7
    DB      $05, $D1, $18, $D1, $63, $D2, $0E, $D7
    DB      $05, $C5, $2E, $DF, $3B, $DF, $AC, $CE
    DB      $DD, $7E, $06, $DD, $46, $03, $DD, $70
    DB      $06, $DD, $70, $07, $DD, $77, $03, $DD
    DB      $36, $04, $01, $DD, $36, $05, $40, $3A
    DB      $1B, $70, $FE, $02, $D8, $DD, $36, $05
    DB      $20, $C9, $DD, $35, $05, $C0, $DD, $36
    DB      $05, $40, $3A, $1B, $70, $FE, $02, $38
    DB      $04, $DD, $36, $05, $20, $DD, $34, $03
    DB      $DD, $7E, $03, $FE, $20, $C0, $DD, $36
    DB      $04, $02, $DD, $36, $05, $01, $DD, $36
    DB      $03, $40, $CD, $AC, $C5, $C9, $DD, $35
    DB      $05, $C0, $DD, $7E, $06, $DD, $77, $05
    DB      $DD, $6E, $01, $DD, $66, $02, $E5, $CB
    DB      $3C, $CB, $1D, $CB, $3C, $CB, $1D, $CB
    DB      $3D, $11, $2B, $CE, $19, $7E, $D6, $20
    DB      $47, $DD, $7E, $03, $B8, $CA, $10, $CE
    DB      $DA, $0D, $CE, $DD, $35, $03, $C3, $10
    DB      $CE, $DD, $34, $03, $E1, $DD, $CB, $00
    DB      $76, $C2, $1C, $CE, $23, $C3, $1D, $CE
    DB      $2B, $7C, $E6, $03, $67, $DD, $75, $01
    DB      $DD, $74, $02, $CD, $AD, $CE, $C9, $98
    DB      $98, $9C, $9C, $9C, $98, $98, $9C, $9C
    DB      $9C, $9C, $9C, $9C, $98, $94, $94, $94
    DB      $90, $88, $84, $84, $84, $84, $88, $8C
    DB      $8C, $90, $90, $98, $9C, $9C, $A0, $A4
    DB      $A0, $9C, $9C, $98, $90, $90, $98, $A0
    DB      $A8, $AC, $AC, $AC, $A8, $A8, $A4, $A0
    DB      $98, $94, $90, $90, $94, $98, $9C, $9C
    DB      $9C, $98, $90, $88, $88, $80, $80, $80
    DB      $80, $84, $88, $90, $98, $9C, $9C, $9C
    DB      $A0, $A8, $A8, $A4, $A0, $9C, $98, $98
    DB      $98, $9C, $A0, $A4, $A4, $A4, $A4, $A4
    DB      $A4, $A8, $A8, $A0, $98, $98, $A0, $A0
    DB      $A0, $A0, $A4, $A8, $A8, $A4, $A0, $9C
    DB      $98, $98, $90, $90, $98, $9C, $9C, $A0
    DB      $A0, $98, $98, $98, $98, $90, $8C, $88
    DB      $88, $88, $88, $90, $8C, $8C, $90, $FF
    DB      $C9, $3A, $D8, $72, $A7, $C8, $3A, $1E
    DB      $70, $A7, $C8, $06, $0A, $FD, $21, $28
    DB      $72, $0E, $00, $FD, $CB, $00, $7E, $28
    DB      $3E, $FD, $CB, $00, $56, $20, $38, $FD
    DB      $CB, $00, $66, $20, $32, $DD, $6E, $01
    DB      $DD, $66, $02, $FD, $5E, $01, $FD, $56
    DB      $02, $ED, $52, $20, $22, $FD, $CB, $00
    DB      $D6, $DD, $36, $04, $03, $DD, $7E, $06
    DB      $DD, $77, $05, $DD, $71, $07, $DD, $36
    DB      $06, $02, $CD, $2B, $B4, $21, $69, $70
    DB      $35, $C0, $AF, $32, $D8, $72, $C9, $0C
    DB      $11, $04, $00, $FD, $19, $10, $B4, $C9

SUB_CF0C:
    LD      A, (IX+7)
    ADD     A, A
    ADD     A, A
    LD      E, A
    LD      D, $00
    LD      IY, $7228                   ; RAM $7228
    ADD     IY, DE
    RET     
    DB      $DD, $7E, $01, $FD, $77, $01, $DD, $7E
    DB      $02, $FD, $77, $02, $C9, $DD, $35, $05
    DB      $C0, $DD, $7E, $06, $DD, $77, $05, $CD
    DB      $0C, $CF, $FD, $CB, $00, $7E, $C8, $DD
    DB      $34, $03, $CD, $1B, $CF, $FD, $7E, $03
    DB      $D6, $08, $DD, $BE, $03, $C0, $DD, $36
    DB      $04, $04, $DD, $36, $06, $02, $C9, $DD
    DB      $35, $05, $C0, $DD, $7E, $06, $DD, $77
    DB      $05, $CD, $0C, $CF, $DD, $35, $03, $FD
    DB      $35, $03, $CD, $1B, $CF, $DD, $7E, $03
    DB      $FE, $20, $30, $04, $DD, $36, $03, $20
    DB      $FD, $CB, $00, $7E, $28, $3C, $FD, $7E
    DB      $03, $FE, $20, $C0, $DD, $36, $04, $05
    DB      $DD, $7E, $00, $E6, $F0, $F6, $01, $DD
    DB      $77, $00, $DD, $CB, $00, $6E, $28, $04
    DB      $DD, $36, $09, $0A, $DD, $36, $03, $20
    DB      $FD, $36, $00, $00, $DD, $CB, $00, $6E
    DB      $20, $05, $CD, $37, $B4, $18, $03, $CD
    DB      $BF, $DA, $21, $1E, $70, $35, $CC, $7B
    DB      $C2, $C9, $2A, $54, $71, $11, $90, $01
    DB      $19, $7C, $E6, $03, $DD, $75, $01, $DD
    DB      $77, $02, $DD, $36, $03, $20, $DD, $36
    DB      $04, $02, $C9, $DD, $36, $06, $04, $CD
    DB      $AA, $D0, $DD, $36, $04, $06, $C9, $CD
    DB      $AA, $D0, $38, $1C, $CD, $E0, $D0, $30
    DB      $17, $DD, $36, $04, $07, $DD, $36, $05
    DB      $02, $DD, $CB, $00, $76, $28, $04, $DD
    DB      $36, $05, $FE, $DD, $36, $06, $02, $C9
    DB      $DD, $6E, $01, $DD, $66, $02, $DD, $CB
    DB      $00, $76, $20, $03, $23, $18, $01, $2B
    DB      $7C, $E6, $03, $DD, $77, $02, $DD, $75
    DB      $01, $DD, $7E, $06, $A7, $FA, $39, $D0
    DB      $DD, $34, $03, $DD, $7E, $03, $FE, $C0
    DB      $20, $04, $DD, $36, $03, $20, $DD, $35
    DB      $06, $C0, $ED, $5F, $E6, $0F, $F6, $04
    DB      $ED, $44, $DD, $77, $06, $C9, $DD, $35
    DB      $03, $DD, $7E, $03, $FE, $1F, $20, $04
    DB      $DD, $36, $03, $B8, $DD, $34, $06, $C0
    DB      $ED, $5F, $E6, $0F, $F6, $04, $DD, $77
    DB      $06, $C9, $CD, $AA, $D0, $38, $05, $CD
    DB      $E0, $D0, $38, $05, $DD, $36, $04, $06
    DB      $C9, $DD, $35, $06, $20, $14, $DD, $36
    DB      $06, $02, $3A, $39, $71, $DD, $BE, $03
    DB      $38, $05, $DD, $34, $03, $18, $03, $DD
    DB      $35, $03, $DD, $7E, $05, $A7, $DD, $6E
    DB      $01, $DD, $66, $02, $FA, $96, $D0, $23
    DB      $DD, $35, $05, $20, $10, $DD, $36, $05
    DB      $FE, $18, $0A, $2B, $DD, $34, $05, $20
    DB      $04, $DD, $36, $05, $02, $7C, $E6, $03
    DB      $DD, $75, $01, $DD, $77, $02, $C9, $3A
    DB      $D7, $72, $E6, $02, $4F, $DD, $7E, $02
    DB      $E6, $02, $B9, $28, $0E, $38, $06, $DD
    DB      $CB, $00, $B6, $37, $C9, $DD, $CB, $00
    DB      $F6, $37, $C9, $2A, $D6, $72, $DD, $5E
    DB      $01, $DD, $56, $02, $A7, $ED, $52, $38
    DB      $06, $DD, $CB, $00, $B6, $A7, $C9, $DD
    DB      $CB, $00, $F6, $A7, $C9, $DD, $6E, $01
    DB      $DD, $66, $02, $E5, $11, $04, $00, $19
    DB      $ED, $5B, $D6, $72, $A7, $ED, $52, $30
    DB      $03, $E1, $18, $0C, $21, $0C, $00, $19
    DB      $EB, $E1, $ED, $52, $30, $02, $37, $C9
    DB      $A7, $C9, $DD, $36, $04, $0D, $DD, $7E
    DB      $06, $DD, $77, $05, $DD, $36, $06, $00
    DB      $DD, $36, $07, $10, $C9, $DD, $35, $07
    DB      $C2, $F3, $D1, $ED, $5F, $E6, $0F, $F6
    DB      $08, $DD, $77, $07, $3A, $63, $70, $A7
    DB      $28, $70, $DD, $46, $00, $CD, $AA, $D0
    DB      $DA, $9D, $D1, $DD, $70, $00, $DD, $6E
    DB      $01, $DD, $66, $02, $ED, $5B, $D6, $72
    DB      $ED, $52, $30, $22, $EB, $A7, $21, $00
    DB      $00, $ED, $52, $A7, $11, $64, $00, $ED
    DB      $52, $DA, $9D, $D1, $DD, $CB, $00, $76
    DB      $CA, $9D, $D1, $DD, $CB, $00, $B6, $DD
    DB      $36, $06, $00, $C3, $9D, $D1, $11, $64
    DB      $00, $ED, $52, $DA, $9D, $D1, $DD, $CB
    DB      $00, $76, $C2, $9D, $D1, $DD, $CB, $00
    DB      $F6, $DD, $36, $06, $00, $C3, $9D, $D1
    DB      $DD, $36, $04, $09, $DD, $7E, $06, $DD
    DB      $77, $05, $DD, $36, $06, $00, $DD, $7E
    DB      $00, $E6, $30, $DD, $B6, $07, $DD, $77
    DB      $00, $C9, $DD, $5E, $05, $CB, $3B, $CB
    DB      $3B, $CB, $3B, $CB, $3B, $CB, $3B, $CB
    DB      $3B, $16, $00, $21, $FA, $D2, $19, $3A
    DB      $39, $71, $DD, $BE, $03, $38, $19, $DD
    DB      $96, $03, $BE, $38, $2E, $28, $2C, $DD
    DB      $34, $06, $DD, $CB, $06, $BE, $DD, $CB
    DB      $06, $F6, $DD, $36, $04, $0E, $18, $1E
    DB      $47, $DD, $7E, $03, $90, $BE, $38, $13
    DB      $28, $11, $DD, $34, $06, $DD, $CB, $06
    DB      $BE, $DD, $CB, $06, $B6, $DD, $36, $04
    DB      $0E, $18, $03, $DD, $34, $06, $18, $03
    DB      $DD, $34, $06, $DD, $CB, $00, $76, $DD
    DB      $6E, $01, $DD, $66, $02, $16, $00, $20
    DB      $03, $23, $18, $01, $2B, $7C, $E6, $03
    DB      $DD, $77, $02, $DD, $75, $01, $DD, $5E
    DB      $05, $21, $FE, $D2, $19, $DD, $7E, $06
    DB      $CB, $7F, $20, $1A, $CB, $77, $20, $08
    DB      $5F, $19, $DD, $7E, $03, $96, $18, $28
    DB      $E6, $3F, $5F, $3E, $3F, $93, $5F, $19
    DB      $7E, $DD, $86, $03, $18, $1A, $CB, $77
    DB      $20, $0A, $E6, $3F, $5F, $19, $7E, $DD
    DB      $86, $03, $18, $0C, $E6, $3F, $5F, $3E
    DB      $3F, $93, $5F, $19, $DD, $7E, $03, $96
    DB      $FE, $C0, $38, $02, $3E, $20, $FE, $20
    DB      $30, $02, $3E, $BF, $DD, $77, $03, $C9
    DB      $DD, $35, $07, $C2, $CB, $D2, $ED, $5F
    DB      $E6, $0F, $F6, $08, $DD, $77, $07, $3A
    DB      $63, $70, $A7, $28, $53, $DD, $46, $00
    DB      $CD, $AA, $D0, $DA, $CB, $D2, $DD, $70
    DB      $00, $DD, $6E, $01, $DD, $66, $02, $ED
    DB      $5B, $D6, $72, $ED, $52, $30, $22, $EB
    DB      $A7, $21, $00, $00, $ED, $52, $A7, $11
    DB      $64, $00, $ED, $52, $DA, $CB, $D2, $DD
    DB      $CB, $00, $76, $CA, $CB, $D2, $DD, $CB
    DB      $00, $B6, $DD, $36, $06, $00, $C3, $CB
    DB      $D2, $11, $64, $00, $ED, $52, $DA, $CB
    DB      $D2, $DD, $CB, $00, $76, $C2, $9D, $D1
    DB      $DD, $CB, $00, $F6, $DD, $36, $06, $00
    DB      $3A, $39, $71, $DD, $BE, $03, $20, $07
    DB      $DD, $36, $04, $0D, $C3, $F3, $D1, $38
    DB      $0F, $DD, $CB, $06, $BE, $DD, $CB, $06
    DB      $F6, $DD, $CB, $06, $AE, $C3, $F3, $D1
    DB      $DD, $CB, $06, $BE, $DD, $CB, $06, $B6
    DB      $DD, $CB, $06, $AE, $C3, $F3, $D1, $20
    DB      $10, $18, $30, $00, $01, $01, $00, $01
    DB      $01, $01, $00, $01, $01, $01, $01, $00
    DB      $01, $01, $01, $00, $01, $01, $00, $01
    DB      $01, $00, $01, $01, $00, $01, $01, $00
    DB      $01, $00, $01, $01, $00, $01, $00, $01
    DB      $00, $01, $00, $01, $00, $00, $01, $00
    DB      $01, $00, $00, $01, $00, $00, $00, $01
    DB      $00, $00, $00, $00, $01, $00, $00, $00
    DB      $00, $00, $00, $00, $00, $01, $00, $01
    DB      $00, $00, $01, $00, $01, $00, $00, $01
    DB      $00, $00, $01, $00, $00, $01, $00, $01
    DB      $00, $00, $01, $00, $00, $01, $00, $00
    DB      $00, $01, $00, $00, $01, $00, $00, $00
    DB      $01, $00, $00, $00, $01, $00, $00, $00
    DB      $00, $00, $01, $00, $00, $00, $00, $00
    DB      $00, $01, $00, $00, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $01, $00, $01, $00
    DB      $01, $01, $00, $01, $00, $01, $00, $01
    DB      $01, $00, $01, $00, $01, $00, $01, $00
    DB      $01, $00, $01, $00, $01, $00, $01, $00
    DB      $01, $00, $01, $00, $00, $01, $00, $01
    DB      $00, $00, $01, $00, $00, $01, $00, $00
    DB      $00, $01, $00, $00, $00, $01, $00, $00
    DB      $00, $00, $00, $01, $00, $00, $00, $00
    DB      $00, $00, $00, $00, $01, $01, $02, $01
    DB      $01, $01, $01, $01, $02, $01, $01, $01
    DB      $01, $01, $01, $01, $01, $02, $01, $01
    DB      $01, $01, $01, $01, $01, $01, $01, $00
    DB      $01, $01, $01, $01, $01, $01, $00, $01
    DB      $01, $01, $00, $01, $01, $00, $01, $00
    DB      $01, $00, $01, $00, $01, $00, $01, $00
    DB      $00, $01, $00, $00, $00, $00, $01, $00
    DB      $00, $00, $00

LOC_D3FE:                                   ; LOC_D3FE: spawn/update 4 bullet objects in $7207 — called from SUB_8E78
    LD      A, ($7227)                      ; Load $7227 — spawn-bullet flag
    AND     A
    JP      Z, LOC_D462                     ; JP Z if no new bullet to spawn
    XOR     A                               ; Clear $7227 spawn flag
    LD      ($7227), A                  ; RAM $7227
    LD      B, $04                          ; B = 4: scan all 4 bullet slots
    LD      IX, $7207                       ; IX = $7207: bullet records
    LD      DE, $0008                       ; DE = $0008: stride between bullet records

LOC_D412:                                   ; LOC_D412: find an inactive slot (bit 7 = 0)
    BIT     7, (IX+0)
    JR      Z, LOC_D41F                     ; JR Z: slot is inactive — use it
    ADD     IX, DE
    DJNZ    LOC_D412
    JP      LOC_D462                        ; All slots busy: JP LOC_D462 (no spawn)

LOC_D41F:                                   ; LOC_D41F: init new bullet in this slot
    LD      A, ($7138)                      ; Load $7138 — player X position
    LD      HL, $713A                   ; RAM $713A
    LD      B, $08
    BIT     0, (HL)                         ; BIT 0, ($713A): check player direction
    JP      Z, LOC_D42E
    LD      B, $08                          ; B = 8: bullet speed for left-facing player

LOC_D42E:                                   ; LOC_D42E: compute bullet X velocity from player X and direction
    ADD     A, B
    SRL     A
    SRL     A                               ; SRL × 3: divide by 8
    SRL     A
    LD      (IX+5), A                       ; (IX+5) = bullet X velocity
    LD      A, ($7139)                      ; Load $7139 — player scroll speed
    ADD     A, $05
    SRL     A
    SRL     A
    SRL     A
    LD      (IX+6), A                       ; (IX+6) = bullet Y position (from $7139)
    LD      A, ($7139)                  ; RAM $7139
    ADD     A, $05
    AND     $07
    SRL     A
    ADD     A, $D8
    LD      (IX+4), A
    LD      A, ($713A)                      ; Load $713A — direction flag
    LD      (IX+7), A                       ; (IX+7) = bullet direction byte
    LD      (IX+3), $00
    SET     7, (IX+0)                       ; SET 7, (IX+0): activate bullet slot

LOC_D462:                                   ; LOC_D462: update all active bullets
    LD      IX, $7207                       ; IX = $7207: scan all 4 bullet slots
    LD      B, $04

LOC_D468:                                   ; LOC_D468: for each active bullet call SUB_D477
    BIT     7, (IX+0)                       ; BIT 7: is slot active?
    CALL    NZ, SUB_D477                    ; CALL NZ SUB_D477: update active bullet
    LD      DE, $0008
    ADD     IX, DE
    DJNZ    LOC_D468
    RET     

SUB_D477:                                   ; SUB_D477: update one bullet — move and check bounds
    BIT     1, (IX+7)
    JP      Z, LOC_D488
    BIT     0, (IX+7)
    JP      Z, LOC_D513
    JP      LOC_D4EF

LOC_D488:
    BIT     0, (IX+7)
    JP      Z, LOC_D4C3
    JP      LOC_D492

LOC_D492:
    INC     (IX+3)
    INC     (IX+3)
    DEC     (IX+5)
    LD      A, (IX+5)
    SUB     (IX+3)
    JR      NC, LOC_D4B1
    SET     1, (IX+7)
    LD      A, (IX+5)
    INC     A
    LD      (IX+3), A
    JP      LOC_D4EF

LOC_D4B1:
    CALL    SUB_D52F
    LD      E, (IX+3)
    LD      D, $00
    AND     A
    SBC     HL, DE
    LD      (IX+1), L
    LD      (IX+2), H
    RET     

LOC_D4C3:
    INC     (IX+3)
    INC     (IX+3)
    INC     (IX+5)
    LD      A, (IX+5)
    ADD     A, (IX+3)
    CP      $20
    JR      C, LOC_D4E5
    SET     1, (IX+7)
    LD      A, $20
    SUB     (IX+5)
    LD      (IX+3), A
    JP      LOC_D513

LOC_D4E5:
    CALL    SUB_D52F
    LD      (IX+1), L
    LD      (IX+2), H
    RET     

LOC_D4EF:
    DEC     (IX+5)
    DEC     (IX+3)
    JP      Z, LOC_D540
    DEC     (IX+5)
    DEC     (IX+3)
    JP      Z, LOC_D540
    CALL    SUB_D52F
    LD      E, (IX+5)
    LD      D, $00
    AND     A
    SBC     HL, DE
    LD      (IX+1), L
    LD      (IX+2), H
    RET     

LOC_D513:
    INC     (IX+5)
    INC     (IX+5)
    DEC     (IX+3)
    JP      Z, LOC_D540
    DEC     (IX+3)
    JP      Z, LOC_D540
    CALL    SUB_D52F
    LD      (IX+1), L
    LD      (IX+2), H
    RET     

SUB_D52F:
    LD      L, (IX+6)
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      E, (IX+5)
    LD      D, $00
    ADD     HL, DE
    RET     

LOC_D540:
    RES     7, (IX+0)
    RET     

SUB_D545:
    LD      A, (IX+0)
    AND     $07
    CP      $03
    RET     Z
    CP      $05
    RET     Z
    CP      $07
    RET     Z
    DEC     (IX+8)
    RET     NZ
    LD      B, A
    LD      A, R
    AND     $7F
    OR      $20
    LD      (IX+8), A
    LD      A, B
    CP      $04
    JR      NZ, LOC_D56A
    CALL    SUB_D61D
    RET     NC

LOC_D56A:
    LD      B, $08
    LD      IY, $72DE                   ; RAM $72DE
    LD      DE, $000A

LOC_D573:
    BIT     7, (IY+0)
    JR      Z, LOC_D57E
    ADD     IY, DE
    DJNZ    LOC_D573
    RET     

LOC_D57E:
    LD      (IY+0), $00
    LD      A, (IX+10)
    LD      (IY+1), A
    LD      B, A
    LD      A, ($7138)                  ; RAM $7138
    CP      B
    JR      NC, LOC_D596
    SET     0, (IY+0)
    LD      C, A
    LD      A, B
    LD      B, C

LOC_D596:
    SUB     B
    LD      (IY+3), A
    LD      A, (IX+3)
    LD      (IY+2), A
    LD      B, A
    LD      A, ($7139)                  ; RAM $7139
    CP      B
    JR      NC, LOC_D5AE
    SET     1, (IY+0)
    LD      C, A
    LD      A, B
    LD      B, C

LOC_D5AE:
    SUB     B
    LD      (IY+4), A
    LD      A, (IY+3)
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    SRL     A
    INC     A
    LD      (IY+7), A
    SET     7, (IY+0)
    LD      (IY+9), $00
    LD      A, (IX+0)
    AND     $07
    CP      $00
    JR      Z, LOC_D600
    BIT     7, (IY+4)
    JR      NZ, LOC_D600
    BIT     7, (IY+3)
    JR      NZ, LOC_D600

LOC_D5E2:
    BIT     7, (IY+4)
    JR      NZ, LOC_D600
    BIT     7, (IY+3)
    JR      NZ, LOC_D600
    LD      A, (IY+3)
    SLA     A
    LD      (IY+3), A
    LD      A, (IY+4)
    SLA     A
    LD      (IY+4), A
    JR      LOC_D5E2

LOC_D600:
    LD      A, (IX+0)
    AND     $07
    LD      E, A
    LD      D, $00
    SLA     E
    LD      HL, $D613
    ADD     HL, DE
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    JP      (HL)
    DB      $E8, $B3, $15, $B4, $E8, $B3, $1D, $D6
    DB      $64, $B4

SUB_D61D:
    LD      A, ($7138)                  ; RAM $7138
    BIT     6, (IX+0)
    JR      NZ, LOC_D62C
    LD      B, A
    LD      A, (IX+10)
    CP      B
    RET     

LOC_D62C:
    CP      (IX+10)
    RET     

LOC_D630:                                   ; LOC_D630: enemy physics — update 8 enemy records at $72DE each frame
    LD      B, $08                          ; B = 8: loop over all 8 enemy slots
    LD      IX, $72DE                       ; IX = $72DE: enemy records (10 bytes each)
    LD      A, ($705D)                      ; Load $705D — player Y position (used for target tracking)
    LD      ($705E), A                      ; $705E = $705D: save previous Y for this frame
    XOR     A
    LD      ($705D), A                      ; $705D = 0: clear for rebuild
    LD      IY, $71F3                       ; IY = $71F3: first enemy homing data block
    LD      DE, ($7138)                     ; DE = ($7138): player X position
    LD      A, E
    ADD     A, $02
    LD      (IY+0), A                       ; (IY+0) = player X + 2 (homing target X)
    LD      (IY+1), $0C                     ; (IY+1) = $0C: homing target Y offset
    LD      A, D                            ; (IY+2) = player direction + 2
    ADD     A, $02
    LD      (IY+2), A
    LD      (IY+3), $04
    LD      (IY+5), $02
    LD      (IY+7), $02

LOC_D664:                                   ; LOC_D664: for each active enemy (bit 7) call SUB_D673
    BIT     7, (IX+0)                       ; BIT 7, (IX+0): check active
    CALL    NZ, SUB_D673
    LD      DE, $000A                       ; Advance IX by 10 to next enemy
    ADD     IX, DE
    DJNZ    LOC_D664
    RET     

SUB_D673:                                   ; SUB_D673: update one enemy — apply velocity, boundary-wrap, homing
    PUSH    BC
    LD      H, (IX+3)                       ; H = (IX+3): enemy X velocity high
    LD      L, (IX+4)                       ; L = (IX+4): enemy X velocity low
    LD      D, (IX+5)                       ; D = (IX+5): enemy Y velocity
    LD      E, (IX+6)
    LD      B, (IX+7)                       ; B = (IX+7): enemy behaviour flags

LOC_D683:                                   ; LOC_D683: apply velocity and advance enemy position
    LD      A, D                            ; D += H: add X velocity
    ADD     A, H
    LD      D, A
    JR      NC, LOC_D6A1                    ; JR NC: no carry — still on same screen half
    BIT     0, (IX+0)
    JR      NZ, LOC_D696                    ; BIT 0, (IX+0): check horizontal direction
    INC     (IX+1)                          ; INC (IX+1): enemy X column +1
    JP      Z, LOC_D708
    JR      LOC_D6A1

LOC_D696:                                   ; LOC_D696: enemy moving right — DEC (IX+1)
    LD      A, (IX+1)
    SUB     $01                             ; SUB $01: decrement and check carry for boundary
    JP      C, LOC_D708
    LD      (IX+1), A

LOC_D6A1:                                   ; LOC_D6A1: process Y velocity carry
    LD      A, E
    ADD     A, L
    LD      E, A
    JR      NC, LOC_D6B4
    BIT     1, (IX+0)                       ; BIT 1, (IX+0): check vertical direction
    JR      NZ, LOC_D6B1
    INC     (IX+2)                          ; INC (IX+2): enemy Y row +1
    JR      LOC_D6B4

LOC_D6B1:                                   ; LOC_D6B1: DEC (IX+2): enemy Y row -1
    DEC     (IX+2)

LOC_D6B4:                                   ; LOC_D6B4: DJNZ back to velocity application loop
    DJNZ    LOC_D683
    LD      (IX+5), D                       ; Store updated X velocity
    LD      (IX+6), E                       ; Store updated Y velocity
    LD      A, ($705E)                      ; Load $705E — previous player Y
    AND     A
    JP      P, LOC_D6CF                     ; JP P: positive → enemy above player
    NEG     
    ADD     A, (IX+1)
    JR      C, LOC_D708
    LD      (IX+1), A
    JR      LOC_D6D9

LOC_D6CF:
    LD      C, A
    LD      A, (IX+1)
    SUB     C
    JR      C, LOC_D708
    LD      (IX+1), A

LOC_D6D9:
    LD      A, (IX+2)
    CP      $20
    JR      C, LOC_D708
    CP      $C0
    JR      NC, LOC_D708
    DEC     (IX+9)
    JR      Z, LOC_D708
    LD      IY, $71F3                   ; RAM $71F3
    LD      A, (IX+1)
    LD      (IY+4), A
    LD      A, (IX+2)
    LD      (IY+6), A
    CALL    SUB_CD12
    POP     BC
    RET     NC
    LD      A, $01
    LD      ($7067), A                  ; RAM $7067
    RES     7, (IX+0)
    RET     

LOC_D708:
    POP     BC
    RES     7, (IX+0)
    RET     
    DB      $DD, $35, $08, $DD, $CB, $08, $46, $C8
    DB      $DD, $7E, $05, $3D, $FA, $4B, $D7, $20
    DB      $29, $DD, $7E, $07, $47, $E6, $10, $20
    DB      $0E, $DD, $34, $01, $20, $19, $DD, $34
    DB      $02, $DD, $CB, $02, $96, $18, $10, $DD
    DB      $6E, $01, $DD, $66, $02, $2B, $7C, $E6
    DB      $03, $DD, $77, $02, $DD, $75, $01, $78
    DB      $E6, $03, $DD, $77, $05, $DD, $7E, $06
    DB      $3D, $F8, $20, $23, $DD, $7E, $07, $47
    DB      $E6, $20, $DD, $7E, $03, $20, $09, $3C
    DB      $FE, $C0, $38, $0B, $3E, $20, $18, $07
    DB      $3D, $FE, $20, $30, $02, $3E, $B8, $DD
    DB      $77, $03, $78, $1F, $1F, $E6, $03, $DD
    DB      $77, $06, $C9, $DD, $CB, $00, $6E, $20
    DB      $0B, $ED, $5F, $E6, $07, $F6, $01, $DD
    DB      $77, $08, $18, $35, $DD, $7E, $08, $A7
    DB      $20, $0F, $ED, $5F, $E6, $7F, $F6, $40
    DB      $DD, $77, $08, $DD, $36, $04, $0B, $18
    DB      $20, $DD, $CB, $01, $5E, $28, $1A, $3E
    DB      $01, $32, $5F, $70, $DD, $7E, $01, $32
    DB      $04, $72, $DD, $7E, $02, $32, $05, $72
    DB      $DD, $7E, $03, $32, $06, $72, $DD, $35
    DB      $08, $DD, $35, $07, $DD, $CB, $07, $46
    DB      $C8, $C3, $F3, $D1, $DD, $CB, $00, $6E
    DB      $28, $0A, $3A, $6B, $70, $E6, $01, $C8
    DB      $DD, $35, $07, $C0, $DD, $36, $00, $00
    DB      $C9, $DD, $35, $08, $20, $DB, $ED, $5F
    DB      $E6, $07, $F6, $01, $DD, $77, $08, $DD
    DB      $36, $04, $09, $18, $CC

SUB_D7F3:
    LD      A, ($705F)                  ; RAM $705F
    AND     A
    JR      Z, LOC_D82D
    BIT     4, (IX+0)
    JR      NZ, LOC_D82D
    LD      (IX+0), $87
    SET     4, (IX+0)
    LD      A, ($7204)                  ; RAM $7204
    LD      (IX+1), A
    LD      A, ($7205)                  ; RAM $7205
    LD      (IX+2), A
    LD      A, ($7206)                  ; RAM $7206
    LD      (IX+3), A
    LD      (IX+4), $0A
    LD      A, R
    OR      $40
    LD      (IX+7), A
    LD      (IX+9), $0F
    XOR     A
    LD      ($705F), A                  ; RAM $705F
    RET     

LOC_D82D:
    BIT     5, (IX+0)
    RET     NZ
    LD      A, (IX+0)
    AND     $07
    CP      $07
    RET     NZ
    LD      (IX+0), $00
    RET     
    DB      $3A, $1E, $70, $A7, $C8, $AF, $32, $51
    DB      $72, $21, $50, $72, $35, $20, $0E, $3E
    DB      $FF, $32, $51, $72, $ED, $5F, $E6, $3F
    DB      $F6, $10, $32, $50, $72, $06, $0A, $DD
    DB      $21, $28, $72, $DD, $CB, $00, $7E, $CA
    DB      $EA, $D8, $3E, $06, $CD, $E9, $DC, $3A
    DB      $65, $70, $A7, $28, $76, $DD, $CB, $00
    DB      $6E, $28, $70, $DD, $CB, $00, $56, $C2
    DB      $EA, $D8, $DD, $CB, $00, $66, $C2, $EA
    DB      $D8, $3A, $51, $72, $A7, $28, $08, $DD
    DB      $7E, $00, $EE, $40, $DD, $77, $00, $DD
    DB      $CB, $00, $76, $28, $21, $DD, $6E, $01
    DB      $DD, $66, $02, $2B, $2B, $7C, $E6, $03
    DB      $DD, $75, $01, $DD, $77, $02, $DD, $34
    DB      $03, $DD, $7E, $03, $FE, $B9, $38, $33
    DB      $DD, $36, $03, $B8, $18, $2D, $DD, $5E
    DB      $01, $DD, $56, $02, $D5, $CB, $3A, $CB
    DB      $1B, $CB, $3A, $CB, $1B, $CB, $3B, $21
    DB      $2B, $CE, $19, $EB, $E1, $23, $23, $1A
    DB      $C6, $0A, $DD, $BE, $03, $30, $C6, $DD
    DB      $35, $03, $7C, $E6, $03, $DD, $75, $01
    DB      $DD, $77, $02, $11, $04, $00, $DD, $19
    DB      $05, $C2, $62, $D8, $AF, $32, $65, $70
    DB      $C9

SUB_D8F8:                                   ; SUB_D8F8: process 10 missiles/projectiles in $7228; collision vs landscape
    LD      A, ($701E)                      ; Load $701E — active missile count
    AND     A
    RET     Z                               ; Return if no missiles
    LD      B, $0A                          ; B = 10: process up to 10 missile records
    LD      IX, $7228                       ; IX = $7228: missile records (4 bytes each)

LOC_D903:                                   ; LOC_D903: check bit 7 (active) and bit 4 (in-flight)
    PUSH    BC                              ; PUSH BC: save loop counter
    BIT     7, (IX+0)                       ; BIT 7, (IX+0): missile active?
    JP      Z, LOC_D9E9
    BIT     4, (IX+0)                       ; BIT 4, (IX+0): check in-flight flag
    JP      Z, LOC_D988
    LD      A, ($706B)                      ; Load $706B — explosion-phase counter
    AND     A
    JR      NZ, LOC_D988                    ; JR NZ: in explosion phase (not landing)
    LD      HL, $CE2B                       ; HL = $CE2B: landscape height table
    LD      E, (IX+1)
    LD      D, (IX+2)
    LD      A, D                            ; D = (IX+2) & $03: masked VRAM column byte
    AND     $03
    LD      D, A
    SRL     D                               ; Compute landscape index from position
    RR      E
    SRL     D
    RR      E
    SRL     E
    ADD     HL, DE
    INC     (IX+3)                          ; INC (IX+3): advance missile phase counter
    LD      A, (HL)                         ; Load landscape height byte for this column
    SUB     $04
    CP      (IX+3)                          ; CP (IX+3): has missile reached the ground?
    JP      NC, LOC_D988                    ; JP NC: not yet landed
    RES     4, (IX+0)                       ; RES 4, (IX+0): clear in-flight flag (missile has landed)
    BIT     1, (IX+0)                       ; BIT 1, (IX+0): check if homing type
    JP      Z, LOC_D957
    CALL    SUB_B480                        ; Add score 500: missile hit homing target
    LD      BC, $0500
    CALL    SUB_DDE4                        ; CALL SUB_DDE4: score update and display
    RES     1, (IX+0)
    JP      LOC_D9E9                        ; RES 1, (IX+0): clear homing flag

LOC_D957:
    BIT     3, (IX+0)                       ; LOC_D957: non-homing missile landed
    RES     3, (IX+0)                       ; BIT 3 / RES 3: check and clear bonus-hit flag
    JR      NZ, LOC_D96A
    LD      BC, $0250                       ; Score 250: standard missile hit
    CALL    SUB_DDE4
    JP      LOC_D9E9                        ; JP LOC_D9E9

LOC_D96A:
    RES     7, (IX+0)                       ; LOC_D96A: missile destroyed — RES 7 (deactivate)
    BIT     5, (IX+0)
    JR      Z, LOC_D979
    CALL    SUB_DA25                        ; CALL SUB_DA25: missile-hit explosion effect
    JR      LOC_D97C

LOC_D979:
    CALL    SUB_B437                        ; LOC_D979: CALL SUB_B437: missile-hit sound

LOC_D97C:
    LD      HL, $701E                       ; Point HL to $701E — missile counter
    DEC     (HL)                            ; DEC ($701E): one fewer active missile
    JP      NZ, LOC_D9E9                    ; JP NZ LOC_D9E9: still more missiles
    POP     BC
    CALL    VDP_DATA_C27B                   ; All missiles done — trigger wave-complete sequence
    RET     

LOC_D988:
    BIT     5, (IX+0)
    JR      Z, LOC_D9E9
    BIT     1, (IX+0)
    JR      Z, LOC_D9AE
    LD      HL, ($72D6)                 ; RAM $72D6
    LD      DE, $0008
    ADD     HL, DE
    LD      A, H
    AND     $03
    LD      (IX+1), L
    LD      (IX+2), A
    LD      A, ($7139)                  ; RAM $7139
    ADD     A, $08
    LD      (IX+3), A
    JR      LOC_D9E9

LOC_D9AE:
    CALL    SUB_D9F4
    BIT     7, (IX+0)
    JR      Z, LOC_D9E9
    BIT     4, (IX+0)
    JR      Z, LOC_D9E9
    LD      IY, $71F3                   ; RAM $71F3
    LD      BC, ($7138)                 ; RAM $7138
    LD      (IY+0), C
    LD      (IY+1), $10
    LD      (IY+2), B
    LD      (IY+3), $08
    CALL    SUB_CD12
    JR      NC, LOC_D9E9
    SET     1, (IX+0)
    RES     3, (IX+0)
    CALL    SUB_B40F
    LD      BC, $0500
    CALL    SUB_DDE4

LOC_D9E9:
    POP     BC
    LD      DE, $0004
    ADD     IX, DE
    DEC     B
    JP      NZ, LOC_D903
    RET     

SUB_D9F4:
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      DE, ($7154)                 ; RAM $7154
    AND     A
    SBC     HL, DE
    LD      IY, $71F3                   ; RAM $71F3
    LD      (IY+4), L
    LD      A, (IX+3)
    LD      (IY+6), A
    LD      (IY+5), $04
    LD      (IY+7), $08
    CALL    SUB_CC7D
    RET     NC
    RES     7, (IX+0)
    LD      HL, $701E                   ; RAM $701E
    DEC     (HL)
    CALL    Z, VDP_DATA_C27B

SUB_DA25:
    JP      LOC_DABF
    DB      $C9

SUB_DA29:
    CALL    SUB_DE9E
    LD      A, (IX+0)
    AND     $07
    CP      $06
    JR      NC, LOC_DA63
    PUSH    AF
    LD      E, A
    LD      D, $00
    LD      A, ($713D)                  ; RAM $713D
    AND     A
    JR      Z, LOC_DA44
    CALL    SUB_B46A
    JR      LOC_DA53

LOC_DA44:
    LD      HL, $DADE
    SLA     E
    ADD     HL, DE
    LD      A, (HL)
    INC     HL
    LD      H, (HL)
    LD      L, A
    LD      DE, LOC_DA53
    PUSH    DE
    JP      (HL)

LOC_DA53:
    POP     AF
    LD      E, A
    LD      D, $00
    SLA     E
    LD      HL, $DACE
    ADD     HL, DE
    LD      C, (HL)
    INC     HL
    LD      B, (HL)
    CALL    SUB_DDE4

LOC_DA63:
    LD      A, (IX+0)
    AND     $07
    CP      $00
    JR      NZ, LOC_DAB0
    CALL    SUB_CF0C
    PUSH    IY
    POP     HL
    LD      A, (IX+4)
    CP      $03
    JR      NZ, LOC_DA7D
    RES     2, (HL)
    JR      LOC_DAB0

LOC_DA7D:
    CP      $04
    JR      NZ, LOC_DAB0
    RES     2, (HL)
    RES     3, (HL)
    SET     4, (HL)
    PUSH    HL
    LD      E, (IX+1)
    LD      D, (IX+2)
    SRL     D
    RR      E
    SRL     D
    RR      E
    SRL     E
    LD      HL, $CE2B
    ADD     HL, DE
    LD      E, (IY+3)
    LD      A, (HL)
    POP     HL
    ADD     A, $04
    SUB     E
    JR      C, LOC_DAAD
    CP      $28
    JP      C, LOC_DAAD
    SET     3, (HL)

LOC_DAAD:
    CALL    SUB_B45E

LOC_DAB0:
    LD      A, (IX+0)
    AND     $07
    LD      E, A
    LD      D, $00
    LD      HL, $DAC6
    ADD     HL, DE
    LD      A, (HL)
    JR      LOC_DAEA

LOC_DABF:
    CALL    SUB_B437
    LD      A, $D7
    JR      LOC_DAEA
    DB      $D6, $D3, $D6, $D5, $D4, $D7, $D2, $D2
    DB      $50, $01, $50, $01, $00, $02, $50, $02
    DB      $50, $01, $00, $10, $25, $00, $25, $00
    DB      $FE, $B3, $FE, $B3, $04, $B4, $DD, $B3
    DB      $04, $B4, $F3, $B3

LOC_DAEA:
    PUSH    AF
    LD      IY, $7252                   ; RAM $7252
    LD      B, $06
    LD      DE, $0016
    XOR     A

LOC_DAF5:
    BIT     7, (IY+0)
    JR      Z, LOC_DB0D
    CP      (IY+3)
    JR      NC, LOC_DB06
    LD      A, (IY+3)
    PUSH    IY
    POP     HL

LOC_DB06:
    ADD     IY, DE
    DJNZ    LOC_DAF5
    PUSH    HL
    POP     IY

LOC_DB0D:
    POP     AF
    LD      (IY+4), A
    LD      (IY+5), $00
    LD      (IY+0), $80
    LD      (IY+3), $00
    LD      A, (IX+3)
    ADD     A, $04
    SRL     A
    SRL     A
    SRL     A
    LD      (IY+2), A
    LD      L, (IX+1)
    LD      H, (IX+2)
    AND     A
    LD      DE, ($7154)                 ; RAM $7154
    SBC     HL, DE
    LD      A, L
    ADD     A, $04
    SRL     A
    SRL     A
    SRL     A
    LD      (IY+1), A
    RET     

SUB_DB45:                                   ; SUB_DB45: process 6 explosion objects at $7252; advance animation
    LD      A, ($706B)                      ; Load $706B — explosion phase (AND $01: only every 2 frames)
    AND     $01
    RET     Z                               ; Return if not on odd frame
    LD      IX, $7252                       ; IX = $7252: explosion records (22 bytes each)
    LD      B, $06                          ; B = 6: number of explosion slots

LOC_DB51:                                   ; LOC_DB51: check bit 7 — explosion active?
    BIT     7, (IX+0)
    JR      Z, LOC_DB75                     ; JR Z: skip inactive
    LD      A, (IX+3)                       ; Load (IX+3): explosion animation frame counter
    INC     A                               ; INC A: advance frame
    AND     $0F                             ; AND $0F: wrap at 16 frames
    JR      NZ, LOC_DB65                    ; JR NZ: not done — continue
    RES     7, (IX+0)                       ; RES 7, (IX+0): deactivate explosion (16 frames elapsed)
    JR      LOC_DB75

LOC_DB65:                                   ; LOC_DB65: explosion still active
    LD      (IX+3), A                       ; Store incremented frame counter
    CALL    SUB_DB95                        ; CALL SUB_DB95: write explosion tiles to VRAM name table
    LD      A, (IX+5)
    AND     A                               ; Load (IX+5) — tile write success flag
    JR      NZ, LOC_DB75
    RES     7, (IX+0)                       ; RES 7 if no tiles written (explosion moved off screen)

LOC_DB75:                                   ; LOC_DB75: advance IX by 22 (next explosion record)
    LD      DE, $0016
    ADD     IX, DE
    DEC     B
    RET     Z
    LD      A, ($7062)                  ; RAM $7062
    AND     A
    JP      Z, LOC_DB51
    PUSH    IX
    PUSH    BC
    CALL    SUB_8146
    POP     BC
    POP     IX
    IN      A, ($BF)                    ; CTRL_PORT - read VDP status
    XOR     A
    LD      ($7062), A                  ; RAM $7062
    JP      LOC_DB51

SUB_DB95:
    PUSH    IX
    POP     IY
    LD      DE, $0006
    ADD     IY, DE
    LD      (IX+5), $00
    LD      A, (IX+1)
    SUB     (IX+3)
    LD      E, A
    LD      L, (IX+2)
    CALL    SUB_DC17
    LD      A, (IX+1)
    SUB     (IX+3)
    LD      E, A
    LD      A, (IX+2)
    SUB     (IX+3)
    LD      L, A
    CALL    SUB_DC17
    LD      E, (IX+1)
    LD      A, (IX+2)
    SUB     (IX+3)
    LD      L, A
    CALL    SUB_DC17
    LD      A, (IX+1)
    ADD     A, (IX+3)
    LD      E, A
    LD      A, (IX+2)
    SUB     (IX+3)
    LD      L, A
    CALL    SUB_DC17
    LD      A, (IX+1)
    ADD     A, (IX+3)
    LD      E, A
    LD      L, (IX+2)
    CALL    SUB_DC17
    LD      A, (IX+1)
    ADD     A, (IX+3)
    LD      E, A
    LD      A, (IX+2)
    ADD     A, (IX+3)
    LD      L, A
    CALL    SUB_DC17
    LD      E, (IX+1)
    LD      A, (IX+2)
    ADD     A, (IX+3)
    LD      L, A
    CALL    SUB_DC17
    LD      A, (IX+1)
    SUB     (IX+3)
    LD      E, A
    LD      A, (IX+2)
    ADD     A, (IX+3)
    LD      L, A

SUB_DC17:
    LD      A, L
    CP      $04
    RET     C
    CP      $18
    RET     NC
    LD      A, E
    CP      $20
    RET     NC
    INC     (IX+5)
    LD      H, $00
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    ADD     HL, HL
    LD      D, $00
    ADD     HL, DE
    LD      (IY+0), L
    LD      (IY+1), H
    INC     IY
    INC     IY
    RET     
    DB      $2A, $54, $71, $11, $80, $01, $A7, $ED
    DB      $52, $7C, $E6, $03, $67, $22, $2E, $73
    DB      $7D, $CB, $6F, $20, $0C, $CB, $67, $20
    DB      $04, $1E, $01, $18, $0E, $1E, $11, $18
    DB      $0A, $CB, $67, $20, $04, $1E, $21, $18
    DB      $02, $1E, $31, $2A, $2E, $73, $CB, $3C
    DB      $CB, $1D, $CB, $3C, $CB, $1D, $CB, $3D
    DB      $CB, $3D, $CB, $3D, $CB, $3D, $55, $21
    DB      $48, $18, $CD, $BC, $DC, $21, $48, $1C
    DB      $CD, $BC, $DC, $CD, $D0, $DD, $3A, $39
    DB      $71, $CB, $3F, $CB, $3F, $CB, $3F, $47
    DB      $3A, $38, $71, $CB, $3F, $CB, $3F, $CB
    DB      $3F, $C6, $70, $4F, $21, $00, $1F, $CD
    DB      $DC, $DC, $21, $80, $1F, $CD, $DC, $DC
    DB      $3E, $1A, $32, $30, $73, $21, $04, $1F
    DB      $22, $32, $73, $AF, $32, $31, $73, $C3
    DB      $D0, $DD, $CD, $80, $82, $3A, $1E, $70
    DB      $A7, $28, $0C, $06, $10, $7A, $83, $D3
    DB      $BE, $14, $CB, $A2, $10, $F7, $C9, $06
    DB      $10, $AF, $D3, $BE, $00, $00, $00, $10
    DB      $F9, $C9, $CD, $80, $82, $78, $D3, $BE
    DB      $00, $00, $00, $79, $D3, $BE, $C9, $21
    DB      $4E, $DD, $5F, $16, $00, $19, $4E, $DD
    DB      $7E, $03, $FE, $20, $D8, $2A, $32, $73
    DB      $CD, $80, $82, $11, $04, $00, $19, $22
    DB      $32, $73, $DD, $7E, $03, $CB, $3F, $CB
    DB      $3F, $CB, $3F, $D3, $BE, $DD, $6E, $01
    DB      $DD, $66, $02, $ED, $5B, $2E, $73, $A7
    DB      $ED, $52, $CB, $3C, $CB, $1D, $CB, $3C
    DB      $CB, $1D, $CB, $3D, $7D, $C6, $40, $D3
    DB      $BE, $00, $00, $00, $3E, $06, $D3, $BE
    DB      $00, $00, $00, $79, $D3, $BE, $21, $30
    DB      $73, $35, $C0, $21, $84, $1F, $22, $32
    DB      $73, $3E, $1A, $32, $30, $73, $3E, $01
    DB      $32, $31, $73, $C9, $0C, $0A, $03, $07
    DB      $06, $0D, $0E, $2A, $32, $73, $23, $23
    DB      $23, $3A, $30, $73, $47, $11, $04, $00
    DB      $CD, $80, $82, $AF, $D3, $BE, $19, $10
    DB      $F7, $CD, $D0, $DD, $3A, $31, $73, $32
    DB      $36, $73, $C9

LOC_DD75:
    IN      A, ($BF)                    ; CTRL_PORT - read VDP status
    LD      A, $36
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $85
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     

VDP_REG_DD80:                               ; VDP_REG_DD80: read VDP status; update scroll regs $7334/$7335/$7336
    LD      A, $01
    LD      ($7334), A                  ; RAM $7334
    LD      A, ($7336)                  ; RAM $7336
    AND     A
    JR      NZ, LOC_DD94

LOC_DD8B:
    LD      A, $3E
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $85
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     

LOC_DD94:
    LD      A, ($7335)                  ; RAM $7335
    XOR     $01
    LD      ($7335), A                  ; RAM $7335
    JR      Z, LOC_DD8B
    LD      A, $3F
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    LD      A, $85
    OUT     ($BF), A                    ; CTRL_PORT - write VDP register
    RET     

VDP_DATA_DDA7:
    LD      HL, $1F04
    CALL    VDP_REG_8280
    LD      B, $68
    XOR     A

LOC_DDB0:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_DDB0
    LD      HL, $1F84
    CALL    VDP_REG_8280
    LD      B, $68
    XOR     A

LOC_DDBF:
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    NOP     
    NOP     
    DJNZ    LOC_DDBF
    XOR     A
    LD      ($7336), A                  ; RAM $7336
    LD      ($7331), A                  ; RAM $7331
    LD      ($7335), A                  ; RAM $7335
    RET     
    DB      $DD, $E5, $FD, $E5, $E5, $D5, $C5, $F5
    DB      $CD, $81, $80, $F1, $C1, $D1, $E1, $FD
    DB      $E1, $DD, $E1, $C9

SUB_DDE4:                                   ; SUB_DDE4: score add — save regs; read controller; add BC to BCD score
    EXX                                     ; EXX: swap to alternate register set
    PUSH    BC                              ; PUSH BC: save score increment in alt BC
    EXX     
    PUSH    AF                              ; PUSH AF / BC / DE / HL: save main regs
    PUSH    BC
    PUSH    DE
    PUSH    HL
    LD      HL, WORK_BUFFER                 ; Load WORK_BUFFER — check bit 0 for player 1 or 2
    BIT     0, (HL)                         ; BIT 0, (HL): 0 = player 1
    JR      NZ, LOC_DDFA                    ; JR NZ: player 2 score at $7006
    LD      DE, $7003                       ; DE = $7003: player 1 score BCD buffer (3 bytes)
    LD      HL, $0040                       ; HL = $0040: max score threshold
    JR      LOC_DE00
                                            ; LOC_DDFA: player 2 path
LOC_DDFA:
    LD      DE, $7006                       ; DE = $7006: player 2 score BCD buffer
    LD      HL, $005A

LOC_DE00:                                   ; LOC_DE00: CALL SUB_DE0B: add BC to BCD score at DE
    CALL    SUB_DE0B
    POP     HL                              ; Restore all saved registers
    POP     DE
    POP     BC
    POP     AF
    EXX     
    POP     BC
    EXX     
    RET                                     ; Return from score-update routine

SUB_DE0B:                                   ; SUB_DE0B: BCD add — add C to (DE), carry into (DE-1), then (DE-2)
    LD      A, (DE)                         ; Load score byte 2 (ones/tens)
    ADD     A, C                            ; ADD A, C: add low score increment
    DAA                                     ; DAA: adjust to BCD
    LD      (DE), A                         ; Store result back
    LD      ($705A), A                      ; $705A = updated ones/tens byte (for display)
    DEC     DE
    LD      A, (DE)                         ; Load score byte 1 (hundreds/thousands)
    ADC     A, B                            ; ADC A, B: add high increment + carry
    DAA                                     ; DAA: BCD adjust
    LD      (DE), A                         ; Store result back
    LD      ($7059), A                      ; $7059 = hundreds/thousands (for display)
    DEC     DE
    LD      A, (DE)                         ; Load score byte 0 (ten-thousands and above)
    JR      NC, LOC_DE31                    ; JR NC: no carry into top byte
    PUSH    AF
    PUSH    HL
    PUSH    DE
    PUSH    BC
    CALL    SUB_B475                        ; CALL SUB_B475: extra-life award threshold check
    LD      HL, $701C                   ; RAM $701C
    INC     (HL)                            ; INC ($701C): gained extra life
    LD      HL, $701D                   ; RAM $701D
    INC     (HL)                            ; INC ($701D): increment bonus counter
    POP     BC
    POP     DE
    POP     HL
    POP     AF

LOC_DE31:
    ADC     A, $00
    DAA     
    LD      (DE), A
    LD      ($7058), A                  ; RAM $7058
    PUSH    HL
    POP     BC
    LD      HL, $7058                       ; HL = $7058: pointer to top score byte
    LD      E, $00
    EXX     
    LD      B, $03                          ; EXX: switch to alt regs for digit extraction
                                            ; B = 3: three BCD bytes = 6 digits to display
LOC_DE42:
    EXX                                     ; LOC_DE42: convert BCD nibbles to tile indices and write to VRAM
    SUB     A
    RLD     
    AND     $0F
    JR      NZ, LOC_DE56
    BIT     0, E
    JR      NZ, LOC_DE56
    LD      A, $00
    CALL    VDP_DATA_DE85
    SUB     A
    JR      LOC_DE5D

LOC_DE56:
    ADD     A, $64
    SET     0, E
    CALL    VDP_DATA_DE85

LOC_DE5D:
    INC     BC
    RLD     
    AND     $0F
    JR      NZ, LOC_DE6F
    BIT     0, E
    JR      NZ, LOC_DE6F
    LD      A, $00
    CALL    VDP_DATA_DE85
    JR      LOC_DE76

LOC_DE6F:
    ADD     A, $64
    SET     0, E
    CALL    VDP_DATA_DE85

LOC_DE76:
    INC     BC
    INC     HL
    EXX     
    DJNZ    LOC_DE42
    EXX     
    DEC     BC
    CP      $00
    RET     NZ
    LD      A, $64
    JP      VDP_DATA_DE85

VDP_DATA_DE85:
    PUSH    HL
    PUSH    AF
    LD      HL, $1800
    ADD     HL, BC
    CALL    VDP_REG_8280
    POP     AF
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    PUSH    AF
    LD      HL, $1C00
    ADD     HL, BC
    CALL    VDP_REG_8280
    POP     AF
    OUT     ($BE), A                    ; DATA_PORT - write VRAM
    POP     HL
    RET     

SUB_DE9E:
    LD      A, (IX+0)
    AND     $07
    CP      $05
    RET     NZ
    LD      HL, $700C                   ; RAM $700C
    LD      A, ($7014)                  ; RAM $7014
    LD      E, A
    INC     A
    LD      ($7014), A                  ; RAM $7014
    LD      D, $00
    ADD     HL, DE
    LD      A, ($7010)                  ; RAM $7010
    ADD     A, (HL)
    LD      ($7010), A                  ; RAM $7010
    LD      L, (IX+1)
    LD      H, (IX+2)
    LD      A, (IX+3)
    LD      ($7011), HL                 ; RAM $7011
    LD      ($7013), A                  ; RAM $7013
    RET     
    DB      $DD, $7E, $00, $E6, $0F, $FE, $0C, $C0
    DB      $3A, $10, $70, $A7, $C8, $3D, $32, $10
    DB      $70, $ED, $5F, $4F, $E6, $1F, $5F, $16
    DB      $00, $2A, $11, $70, $CB, $79, $20, $03
    DB      $19, $18, $02, $ED, $52, $7C, $E6, $03
    DB      $DD, $77, $02, $DD, $75, $01, $DD, $CB
    DB      $00, $FE, $DD, $36, $04, $0C, $ED, $5F
    DB      $E6, $03, $CB, $0F, $CB, $0F, $DD, $77
    DB      $06, $ED, $5F, $4F, $E6, $0F, $CB, $79
    DB      $28, $02, $ED, $44, $4F, $3A, $13, $70
    DB      $81, $FE, $20, $30, $04, $3E, $26, $18
    DB      $06, $FE, $C0, $38, $02, $3E, $BA, $DD
    DB      $77, $03, $C9, $DD, $36, $05, $00, $DD
    DB      $36, $06, $02, $DD, $36, $04, $12, $C9
    DB      $DD, $CB, $00, $6E, $28, $06, $3A, $6B
    DB      $70, $E6, $01, $C0, $DD, $35, $06, $20
    DB      $51, $ED, $5F, $47, $3A, $55, $70, $A8
    DB      $ED, $4F, $47, $E6, $0F, $3C, $DD, $77
    DB      $06, $3A, $6A, $70, $A8, $E6, $07, $5F
    DB      $16, $00, $21, $E3, $DF, $19, $19, $4E
    DB      $23, $46, $B7, $2A, $55, $70, $DD, $5E
    DB      $01, $DD, $56, $02, $ED, $52, $D2, $80
    DB      $DF, $79, $ED, $44, $4F, $3A, $54, $70
    DB      $81, $E6, $0F, $4F, $3A, $39, $71, $DD
    DB      $BE, $03, $78, $D2, $93, $DF, $ED, $44
    DB      $17, $17, $17, $17, $E6, $F0, $B1, $DD
    DB      $77, $05, $DD, $46, $05, $78, $E6, $0F
    DB      $CB, $5F, $28, $02, $F6, $F0, $6F, $26
    DB      $00, $CB, $7D, $28, $01, $25, $DD, $5E
    DB      $01, $DD, $56, $02, $19, $7C, $E6, $03
    DB      $DD, $75, $01, $DD, $77, $02, $78, $1F
    DB      $1F, $1F, $1F, $E6, $0F, $CB, $5F, $28
    DB      $02, $F6, $F0, $DD, $86, $03, $FE, $20
    DB      $30, $04, $C6, $A0, $18, $06, $FE, $C0
    DB      $38, $02, $D6, $A0, $DD, $77, $03, $C9
    DB      $FF, $03, $00, $03, $01, $03, $02, $02
    DB      $03, $01, $03, $00, $03, $FF, $03, $01
    DB      $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    DB      $FF, $FF, $FF, $FF, $FF

; ---- mid-instruction label aliases (EQU) ----
SUB_800C:        EQU $800C
LOC_8016:        EQU $8016
LOC_801B:        EQU $801B
