CUR_ROM_BANK                    equ     $fffd
SELECT_ROM_BANK                 equ     $2000

OBP0                            equ     $ff48
OBP1                            equ     $ff49

BUTTON_A                        equ     $01
BUTTON_B                        equ     $02
BUTTON_SELECT                   equ     $04
BUTTON_START                    equ     $08
BUTTON_RIGHT                    equ     $10
BUTTON_LEFT                     equ     $20
BUTTON_UP                       equ     $40
BUTTON_DOWN                     equ     $80

CUR_WORLD_AND_LEVEL             equ     $ffb4
CUR_LEVEL                       equ     $ffe4
CUR_CHECKPOINT                  equ     $ffe5

TILE_BLANK                      equ     $2c

TILE_ARROWS_ACTIVE              equ     $30
TILE_ARROWS_INACTIVE            equ     $31
TILE_FIREFLOWER                 equ     $32
TILE_VERSION_1                  equ     $33
TILE_VERSION_2                  equ     $34

TILE_MUSHROOM                   equ     $ac
TILE_DASH                       equ     $29

MENU_Y                          equ     $78

NUM_GRAPHICS                    equ     5

JOYPAD0                         equ     $ff80
JOYPAD1                         equ     $ff81

MY_ROM_BANK                     equ     4

CUR_BIGNESS                     equ     $ff99
FIREFLOWER_FLAG                 equ     $ffb5

rLCDC                           equ     $ff40
rLY                             equ     $ff44
rNR50                           equ     $ff24
rNR51                           equ     $ff25
rNR52                           equ     $ff26
LINE_VBLANK                     equ     $90

NUM_LIVES                       equ     $da15

FIRST_RUN_MAGIC                 equ     $ca

SPRITE_BUFFER                   equ     $c000

HARD_MODE_FLAG                  equ     $ff9a
HARD_MODE_Y_COORD               equ     $84

SPRITE_SLOT_SELECTIONS          equ     $c000
SPRITE_SLOT_ARROWS              equ     $c010
SPRITE_SLOT_VERSION             equ     $c020
SPRITE_SLOT_HARD                equ     $c028

DELAY_FRAMES                    equ     60


SECTION "overwrite_before_deletion", ROM0[$01be]
        jp      jump_preserve_variables

SECTION "overwrite_title_screen", ROM0[$02c4]
        dw      jump_title_screen

SECTION "overwrite_game_start", ROM0[$02c8]
        dw      jump_game_start

SECTION "overwrite_boot", ROM0[$0425]
        call    jump_boot

SECTION "overwrite_demo", ROM0[$0519]
        ret
; no demo makes room for own code
SECTION "read_joypad", ROM0[$051a]
read_joypad:
        ld      a, 3
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        call    $47f2
        ld      a, MY_ROM_BANK
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        ret

my_level_music_start_before:
        ld      a, [CUR_ROM_BANK]
        ld      [LAST_ROM_BANK], a
        ld      a, 3
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        ret

IF VERSION == 10
SECTION "overwrite_lives", ROM0[$3d3f]
ELSE
SECTION "overwrite_lives", ROM0[$3d48]
ENDC
        ld      a, $20

; fix starman crash
IF VERSION == 10
SECTION "overwrite_level_music_start_before", ROM0[$0791]
ELSE
SECTION "overwrite_level_music_start_before", ROM0[$07a8]
ENDC
        call    my_level_music_start_before
        nop
        nop

IF VERSION == 10
SECTION "overwrite_level_music_start_after", ROM0[$0799]
ELSE
SECTION "overwrite_level_music_start_after", ROM0[$07b0]
ENDC
        call    my_level_music_start_after
        nop
        nop

IF VERSION == 10
SECTION "level_music_after", ROM0[$00f1]
ELSE
SECTION "level_music_after", ROM0[$001b]
ENDC
my_level_music_start_after:
        ld      a, [LAST_ROM_BANK]
        ld      [CUR_ROM_BANK], a
        ld      [SELECT_ROM_BANK], a
        ret

IF VERSION == 10
SECTION "overwrite_checkpoint", ROM0[$0dca]
ELSE
SECTION "overwrite_checkpoint", ROM0[$0dca+9]
ENDC
        di
        ld      a, MY_ROM_BANK
        ld      [SELECT_ROM_BANK], a
        call    checkpoint_overwrite
        ld      a, [LAST_ROM_BANK]
        ld      [SELECT_ROM_BANK], a
        ei
        nop
        nop
        nop
        nop
        nop
        nop


SECTION "jump1", ROM0[$3fce]
jump_game_start:
        di
        ld      a, MY_ROM_BANK
        ld      [SELECT_ROM_BANK], a
        call    game_start
        ld      a, 2
        ld      [SELECT_ROM_BANK], a

IF VERSION == 10
        jp      $055f
ELSE
        jp      $0576
ENDC

jump_boot:
        di
        ld      a, MY_ROM_BANK
        ld      [SELECT_ROM_BANK], a
        call    boot
        ei
        ret

jump_title_screen:
        di
        ld      a, MY_ROM_BANK
        ld      [SELECT_ROM_BANK], a
        call    title_screen
        ei

        ; replace original instructions
        jp      $04c3

jump_preserve_variables:
        di
        ld      a, MY_ROM_BANK
        ld      [SELECT_ROM_BANK], a
        jp      preserve_variables


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SECTION "code", ROMX[$4800], BANK[MY_ROM_BANK]
boot:
        ld      a, $00
        ld      [OBP1], a

        call    init_variables
        call    copy_graphics
        call    remove_start_text
        call    write_own_text
        call    draw_version
        call    init_arrows
        call    init_selections
        call    init_hard_mode_sprites

        call    draw_hard_mode
        call    draw_selections
        call    draw_arrows

        ; replace original instructions
        xor     a
        ldh     [$ff0f], a
        ret



init_variables:
        ld      a, [FIRST_RUN]
        cp      FIRST_RUN_MAGIC
        ret     z
        ld      a, FIRST_RUN_MAGIC
        ld      [FIRST_RUN], a
        ld      a, 1
        ld      [SELECTED_WORLD], a
        ld      [SELECTED_LEVEL], a
        ld      [SELECTED_CHECKPOINT], a
        ld      [FIRST_LEVEL], a
        xor     a
        ld      [HARD_MODE_ON], a
        ld      [SELECTED_POWERUP], a
        ld      [CALCULATED_LEVEL], a
        ld      [CUR_SELECTION], a
        ld      a, $11
        ld      [CALCULATED_WORLD_AND_LEVEL], a
        ld      a, 3
        ld      [CALCULATED_CHECKPOINT], a
        ld      [CALCULATED_MAX_CHECKPOINTS], a
        ret

draw_version:
        xor     a
        ld      [SPRITE_SLOT_VERSION+3], a
        ld      [SPRITE_SLOT_VERSION+7], a

        ld      a, 144 + 8
        ld      [SPRITE_SLOT_VERSION+0], a
        ld      a, 160 - 8
        ld      [SPRITE_SLOT_VERSION+1], a
        ld      a, TILE_VERSION_1
        ld      [SPRITE_SLOT_VERSION+2], a

        ld      a, 144 + 8
        ld      [SPRITE_SLOT_VERSION+4], a
        ld      a, 160 - 0
        ld      [SPRITE_SLOT_VERSION+5], a
        ld      a, TILE_VERSION_2
        ld      [SPRITE_SLOT_VERSION+6], a

        ret

write_own_text:
        ld      a, "W" - "A" + 10
        ld      [$99a1], a

        ld      a, "L" - "A" + 10
        ld      [$99a6], a

        ld      a, "P" - "A" + 10
        ld      [$99ab], a

        ld      a, "C" - "A" + 10
        ld      [$99b0], a

        ret

init_arrows:
        ; Y
        ld      a, MENU_Y
        ld      [SPRITE_SLOT_ARROWS+0], a
        ld      [SPRITE_SLOT_ARROWS+4], a
        ld      [SPRITE_SLOT_ARROWS+8], a
        ld      [SPRITE_SLOT_ARROWS+12], a

        ; WORLD ARROWS
        ld      a, $18
        ld      [SPRITE_SLOT_ARROWS+1], a

        ; LEVEL ARROWS
        ld      a, $40
        ld      [SPRITE_SLOT_ARROWS+5], a

        ; POWERUP ARROWS
        ld      a, $68
        ld      [SPRITE_SLOT_ARROWS+9], a

        ; CHECKPOINT ARROWS
        ld      a, $90
        ld      [SPRITE_SLOT_ARROWS+13], a

        ret


draw_arrows:
        ld      a, TILE_ARROWS_INACTIVE
        ld      [SPRITE_SLOT_ARROWS+2], a
        ld      [SPRITE_SLOT_ARROWS+6], a
        ld      [SPRITE_SLOT_ARROWS+10], a
        ld      [SPRITE_SLOT_ARROWS+14], a

        ld      a, [CUR_SELECTION]
        sla     a
        sla     a
        ld      hl, SPRITE_SLOT_ARROWS+2
        ld      d, 0
        ld      e, a
        add     hl, de
        ld      [hl], TILE_ARROWS_ACTIVE

        ret


init_selections:
        ; Y
        ld      a, MENU_Y
        ld      [SPRITE_SLOT_SELECTIONS+0], a
        ld      [SPRITE_SLOT_SELECTIONS+4], a
        ld      [SPRITE_SLOT_SELECTIONS+8], a
        ld      [SPRITE_SLOT_SELECTIONS+12], a

        ; 0X
        ld      a, $20
        ld      [SPRITE_SLOT_SELECTIONS+1], a

        ; 1X
        ld      a, $48
        ld      [SPRITE_SLOT_SELECTIONS+5], a

        ; 2X
        ld      a, $70
        ld      [SPRITE_SLOT_SELECTIONS+9], a

        ; 3X
        ld      a, $98
        ld      [SPRITE_SLOT_SELECTIONS+13], a

        ret

draw_selections:
        ld      a, [SELECTED_WORLD]
        ld      [SPRITE_SLOT_SELECTIONS+2], a

        ld      a, [SELECTED_LEVEL]
        ld      [SPRITE_SLOT_SELECTIONS+6], a

        ld      a, [SELECTED_POWERUP]
        ld      hl, tile_table
        ld      d, 0
        ld      e, a
        add     hl, de
        ld      a, [hl]
        ld      [SPRITE_SLOT_SELECTIONS+10], a

        ld      a, [SELECTED_CHECKPOINT]
        ld      [SPRITE_SLOT_SELECTIONS+14], a

        ret

remove_start_text:
        ld      hl, $99a6
        ld      a, TILE_BLANK
        ld      b, 5
.loop
        ld      [hl+], a
        dec     b
        jr      nz, .loop
        ret

copy_graphics:
        ld      hl, graphics
        ld      b, NUM_GRAPHICS*16
        ld      de, $8300
.loop
        ld      a, [hl+]
        ld      [de], a
        inc     de
        dec     b
        jr      nz, .loop
        ret

title_screen:
        call    check_joypad
        call    recalculate
        call    draw_selections
        call    draw_arrows
        call    draw_hard_mode
        ret

recalculate:
.recalculate_world_and_level
        ld      a, [SELECTED_LEVEL]
        ld      b, a
        ld      a, [SELECTED_WORLD]
        sla     a
        sla     a
        sla     a
        sla     a
        or      b
        ld      [CALCULATED_WORLD_AND_LEVEL], a
.recalculate_level:
        ld      a, [SELECTED_WORLD]
        ld      b, a
        ld      a, -3
.loop
        add     3
        dec     b
        jr      nz, .loop
        ld      b, a
        ld      a, [SELECTED_LEVEL]
        add     b
        dec     a
        ld      [CALCULATED_LEVEL], a
.recalculate_checkpoint
        ld      a, [SELECTED_CHECKPOINT]
        ld      b, $03
        dec     a
        jr      z, .set_checkpoint
        ld      b, $08
        dec     a
        jr      z, .set_checkpoint
        ld      b, $0c
        dec     a
        jr      z, .set_checkpoint
        ld      b, $10
        dec     a
        jr      z, .set_checkpoint
        ld      b, $14
        dec     a
        jr      z, .set_checkpoint
        ld      b, $18
.set_checkpoint
        ld      a, b
        ld      [CALCULATED_CHECKPOINT], a
.recalculate_max_checkpoints
        ld      a, [SELECTED_LEVEL]
        dec     a
        ld      b, a
        ld      a, [SELECTED_WORLD]
        dec     a
        sla     a
        sla     a
        or      b
        ld      hl, checkpoint_table
        ld      d, 0
        ld      e, a
        add     hl, de
        ld      a, [hl]
        ld      [CALCULATED_MAX_CHECKPOINTS], a
        ret


action_down:
.check_world
        ld      a, [CUR_SELECTION]
        ld      b, a
        cp      0
        jr      nz, .check_level
.have_world
        ld      a, 1
        ld      [SELECTED_CHECKPOINT], a
        ld      a, [SELECTED_WORLD]
        cp      1
        jr      nz, .world_normal
.world_back_down
        ld      a, 4
        jr      .world_cont
.world_normal
        dec     a
.world_cont
        ld      [SELECTED_WORLD], a
.check_level
        ld      a, b
        cp      1
        jr      nz, .check_powerup
.have_level
        ld      a, 1
        ld      [SELECTED_CHECKPOINT], a
        ld      a, [SELECTED_LEVEL]
        cp      1
        jr      nz, .level_normal
.level_back_down
        ld      a, 3
        jr      .level_cont
.level_normal
        dec     a
.level_cont
        ld      [SELECTED_LEVEL], a
.check_powerup
        ld      a, b
        cp      2
        jr      nz, .check_checkpoint
.have_powerup
        ld      a, [SELECTED_POWERUP]
        cp      0
        jr      nz, .powerup_normal
.powerup_back_down
        ld      a, 2
        jr      .powerup_cont
.powerup_normal
        dec     a
.powerup_cont
        ld      [SELECTED_POWERUP], a
.check_checkpoint
        ld      a, b
        cp      3
        ret     nz
.have_checkpoint
        ld      a, [SELECTED_CHECKPOINT]
        cp      1
        jr      nz, .checkpoint_normal
.checkpoint_back_down
        ld      a, [CALCULATED_MAX_CHECKPOINTS]
        jr      .checkpoint_cont
.checkpoint_normal
        dec     a
.checkpoint_cont
        ld      [SELECTED_CHECKPOINT], a
        ret


action_up:
.check_world
        ld      a, [CUR_SELECTION]
        ld      b, a
        cp      0
        jr      nz, .check_level
.have_world
        ld      a, 1
        ld      [SELECTED_CHECKPOINT], a
        ld      a, [SELECTED_WORLD]
        cp      4
        jr      nz, .world_normal
.world_back_up
        ld      a, 1
        jr      .world_cont
.world_normal
        inc     a
.world_cont
        ld      [SELECTED_WORLD], a
.check_level
        ld      a, b
        cp      1
        jr      nz, .check_powerup
.have_level
        ld      a, 1
        ld      [SELECTED_CHECKPOINT], a
        ld      a, [SELECTED_LEVEL]
        cp      3
        jr      nz, .level_normal
.level_back_up
        ld      a, 1
        jr      .level_cont
.level_normal
        inc     a
.level_cont
        ld      [SELECTED_LEVEL], a
.check_powerup
        ld      a, b
        cp      2
        jr      nz, .check_checkpoint
.have_powerup
        ld      a, [SELECTED_POWERUP]
        cp      2
        jr      nz, .powerup_normal
.powerup_back_up
        xor     a
        jr      .powerup_cont
.powerup_normal
        inc     a
.powerup_cont
        ld      [SELECTED_POWERUP], a
.check_checkpoint
        ld      a, b
        cp      3
        ret     nz
.have_checkpoint
        ld      a, [SELECTED_CHECKPOINT]
        ld      hl, CALCULATED_MAX_CHECKPOINTS
        cp      [hl]
        jr      nz, .checkpoint_normal
.checkpoint_back_up
        ld      a, 1
        jr      .checkpoint_cont
.checkpoint_normal
        inc     a
.checkpoint_cont
        ld      [SELECTED_CHECKPOINT], a
        ret


action_right:
        ld      a, [CUR_SELECTION]
        cp      3
        jr      nz, .right_normal
.right_back_left
        xor     a
        jr      .right_cont
.right_normal:
        inc     a
.right_cont
        ld      [CUR_SELECTION], a
        ret


action_left:
        ld      a, [CUR_SELECTION]
        cp      0
        jr      nz, .left_normal
.left_back_right
        ld      a, 3
        jr      .left_cont
.left_normal:
        dec     a
.left_cont
        ld      [CUR_SELECTION], a
        ret


check_joypad:
        ld      a, [JOYPAD0]
        ld      c, a
        ld      a, [JOYPAD1]
        and     c
        ld      c, a

        ld      a, c
        cp      BUTTON_DOWN
        call    z, action_down

        ld      a, c
        cp      BUTTON_UP
        call    z, action_up

        ld      a, c
        cp      BUTTON_RIGHT
        call    z, action_right

        ld      a, c
        cp      BUTTON_LEFT
        call    z, action_left

        ld      a, c
        cp      BUTTON_SELECT
        call    z, toggle_hard_mode

        ret


init_hard_mode_sprites:
        xor     a
        ld      [SPRITE_SLOT_HARD+3], a
        ld      [SPRITE_SLOT_HARD+7], a
        ld      [SPRITE_SLOT_HARD+11], a
        ld      [SPRITE_SLOT_HARD+15], a

        ld      a, $a0
        ld      [SPRITE_SLOT_HARD+0], a
        ld      [SPRITE_SLOT_HARD+4], a
        ld      [SPRITE_SLOT_HARD+8], a
        ld      [SPRITE_SLOT_HARD+12], a

        ld      a, 72 + 8*0
        ld      [SPRITE_SLOT_HARD+1], a
        ld      a, "H" - "A" + 10
        ld      [SPRITE_SLOT_HARD+2], a

        ld      a, 72 + 8*1
        ld      [SPRITE_SLOT_HARD+5], a
        ld      a, "A" - "A" + 10
        ld      [SPRITE_SLOT_HARD+6], a

        ld      a, 72 + 8*2
        ld      [SPRITE_SLOT_HARD+9], a
        ld      a, "R" - "A" + 10
        ld      [SPRITE_SLOT_HARD+10], a

        ld      a, 72 + 8*3
        ld      [SPRITE_SLOT_HARD+13], a
        ld      a, "D" - "A" + 10
        ld      [SPRITE_SLOT_HARD+14], a

        ret

draw_hard_mode:
        ld      a, [HARD_MODE_ON]
        and     a
        jr      nz, .hard_mode_on
.hard_mode_off
        ld      a, $a0
        jr      .cont
.hard_mode_on
        ld      a, HARD_MODE_Y_COORD
.cont
        ld      [SPRITE_SLOT_HARD+0], a
        ld      [SPRITE_SLOT_HARD+4], a
        ld      [SPRITE_SLOT_HARD+8], a
        ld      [SPRITE_SLOT_HARD+12], a
        ret

toggle_hard_mode:
        ld      a, [HARD_MODE_ON]
        xor     1
        ld      [HARD_MODE_ON], a
        ret


wait_vblank:
        ld      a, [rLY]
        cp      LINE_VBLANK+2
        ret     nc
        jp      wait_vblank

wait_new_frame:
        ld      a, [rLY]
        cp      LINE_VBLANK
        ret     c
        jp      wait_new_frame


start_delay:
        di
        call    wait_vblank

        ld      a, [rLCDC]
        and     $fc
        ld      [rLCDC], a

        ld      a, DELAY_FRAMES
        ld      b, a
.loop
        push    bc

IF VERSION == 10
        ld      a, 1
        ld      [$ff12], a
        ld      [$ff17], a
        ld      [$ff21], a
        xor     a
        ld      [$ff10], a
        ld      [$ff1a], a
ELSE
        ld      a, $ff
        ld      [$ff25], a
        ld      a, $08
        ld      [$ff12], a
        ld      [$ff17], a
        ld      [$ff21], a
        ld      a, $80
        ld      [$ff14], a
        ld      [$ff19], a
        ld      [$ff23], a
        xor     a
        ld      [$ff10], a
        ld      [$ff1a], a
ENDC

        call    read_joypad
        call    wait_vblank
        call    wait_new_frame
        pop     bc
        dec     b
        jr      nz, .loop
.end
        call    wait_vblank
        ld      a, [rLCDC]
        or      $03
        ld      [rLCDC], a

        ret

game_start:
        ld      a, $54
        ld      [OBP1], a

        call    start_delay

        ld      a, [CALCULATED_WORLD_AND_LEVEL]
        ld      [CUR_WORLD_AND_LEVEL], a
        ld      a, [CALCULATED_LEVEL]
        ld      [CUR_LEVEL], a

        ld      a, [HARD_MODE_ON]
        ld      [HARD_MODE_FLAG], a

        ld      a, 1
        ld      [FIRST_LEVEL], a

        ld      a, [SELECTED_POWERUP]
        ld      b, a
.check_small
        cp      0
        jr      nz, .check_mushroom
.have_small
        xor     a
        ld      [CUR_BIGNESS], a
        ld      [FIREFLOWER_FLAG], a
        ret
.check_mushroom
        ld      a, b
        cp      1
        jr      nz, .check_fireflower
.have_mushroom
        ld      a, 2
        ld      [CUR_BIGNESS], a
        xor     a
        ld      [FIREFLOWER_FLAG], a
        ret
.check_fireflower
        ld      a, b
        cp      2
        ret     nz
.have_fireflower
        ld      a, 2
        ld      [CUR_BIGNESS], a
        ld      [FIREFLOWER_FLAG], a
        ret


preserve_variables:
.save_variables
        ld      hl, variables
        ld      de, $9800
        ld      b, end_of_variables-variables
.save_variables_loop
        ld      a, [hl+]
        ld      [de], a
        inc     de
        dec     b
        jr      nz, .save_variables_loop
.clear_memory
        xor     a
        ld      hl, $dfff
        ld      c, $40
        ld      b, 0
.clear_memory_loop
        ld      [hl-], a
        dec     b
        jr      nz, .clear_memory_loop
        dec     c
        jr      nz, .clear_memory_loop
.restore_variables
        ld      hl, $9800
        ld      de, variables
        ld      b, end_of_variables-variables
.restore_variables_loop
        ld      a, [hl+]
        ld      [de], a
        inc     de
        dec     b
        jr      nz, .restore_variables_loop

        jp      $01cc


checkpoint_overwrite:
        ; replace original instructions
        xor     a
        ld      [$ff0f], a
        ld      a, $c3
        ld      [$ff40], a

        ld      a, [FIRST_LEVEL]
        dec     a
        ld      a, 3
        jr      nz, .cont
.overwrite
        xor     a
        ld      [FIRST_LEVEL], a
        ld      a, [CALCULATED_CHECKPOINT]
.cont
        ld      [CUR_CHECKPOINT], a

        ; replace original instructions
        xor     a
        ld      [$c0d2], a
        ld      [$fff9], a
        ld      a, 2
        ld      [$ffb3], a

        ret

        

graphics:
        incbin  "gfx/out/up_down_arrows_active.2bpp"
        incbin  "gfx/out/up_down_arrows_inactive.2bpp"
        incbin  "gfx/fireflower.2bpp"
        incbin  "gfx/out/version.2bpp"

tile_table:
        db      TILE_DASH, TILE_MUSHROOM, TILE_FIREFLOWER

checkpoint_table:
        db      4, 4, 4, 0
        db      4, 4, 5, 0
        db      6, 4, 4, 0
        db      6, 5, 6, 0


SECTION "variables", WRAM0[$cb00]
variables:
CUR_SELECTION:                  db
SELECTED_WORLD:                 db
SELECTED_LEVEL:                 db
SELECTED_POWERUP:               db
SELECTED_CHECKPOINT:            db
CALCULATED_WORLD_AND_LEVEL:     db
CALCULATED_LEVEL:               db
CALCULATED_CHECKPOINT:          db
CALCULATED_MAX_CHECKPOINTS:     db
FIRST_RUN:                      db
FIRST_LEVEL:                    db
HARD_MODE_ON:                   db
LAST_ROM_BANK:                  db
TEMP:                           db
end_of_variables:
