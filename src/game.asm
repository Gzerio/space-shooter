; Space Shooter Deluxe
; Compilar:
;   ml64 /c game.asm
;   link /SUBSYSTEM:WINDOWS /ENTRY:main game.obj user32.lib kernel32.lib gdi32.lib

option casemap:none

WINDOW_WIDTH        equ 500
WINDOW_HEIGHT       equ 600
PLAYER_WIDTH        equ 32
PLAYER_HEIGHT       equ 24
PLAYER_SPEED        equ 6
BULLET_WIDTH        equ 3
BULLET_HEIGHT       equ 10
BULLET_SPEED        equ 10
ENEMY_WIDTH         equ 28
ENEMY_HEIGHT        equ 20
MAX_BULLETS         equ 30
MAX_ENEMIES         equ 20
MAX_STARS           equ 80
MAX_ENEMY_BULLETS   equ 30
ENEMY_BULLET_WIDTH  equ 4
ENEMY_BULLET_HEIGHT equ 8
ENEMY_BULLET_SPEED  equ 5

CS_HREDRAW          equ 0002h
CS_VREDRAW          equ 0001h
WS_OVERLAPPED       equ 00000000h
WS_CAPTION          equ 00C00000h
WS_SYSMENU          equ 00080000h
WS_MINIMIZEBOX      equ 00020000h
WS_VISIBLE          equ 10000000h
IDC_ARROW           equ 32512

WM_DESTROY          equ 0002h
WM_PAINT            equ 000Fh
WM_TIMER            equ 0113h

VK_LEFT             equ 25h
VK_RIGHT            equ 27h
VK_SPACE            equ 20h
VK_RETURN           equ 0Dh

; Game states
STATE_MENU          equ 0
STATE_PLAYING       equ 1
STATE_GAMEOVER      equ 2
STATE_PAUSED        equ 3
STATE_UPGRADE       equ 4

; New constants for features
MAX_POWERUPS        equ 5
MAX_EXPLOSIONS      equ 15
MAX_PARTICLES       equ 50
MAX_COINS           equ 20
POWERUP_SIZE        equ 16
POWERUP_SPEED       equ 2
POWERUP_DOUBLE      equ 0
POWERUP_SHIELD      equ 1
POWERUP_SPEED_BOOST equ 2
POWERUP_LIFE        equ 3
POWERUP_BOMB        equ 4
MAX_LIVES           equ 5
INVINCIBLE_TIME     equ 120
EXPLOSION_FRAMES    equ 12
BOSS_WIDTH          equ 80
BOSS_HEIGHT         equ 40
BOSS_HP             equ 20
VK_W                equ 57h
VK_S                equ 53h
VK_B                equ 42h
VK_ESCAPE           equ 1Bh

; Combo system
COMBO_TIME          equ 60
MAX_COMBO           equ 20

; Upgrade costs
UPGRADE_DAMAGE_COST equ 5
UPGRADE_SPEED_COST  equ 5
UPGRADE_LIFE_COST   equ 10
UPGRADE_BOMB_COST   equ 8

; Parallax layers
STAR_LAYER_SLOW     equ 0
STAR_LAYER_MED      equ 1
STAR_LAYER_FAST     equ 2

; Text constants
TRANSPARENT_BG      equ 1
DT_CENTER           equ 1
DT_VCENTER          equ 4
DT_SINGLELINE       equ 20h

; -------------------------------------------------
; Structs
; -------------------------------------------------

WNDCLASSEXA struct 8
    cbSize          dd ?
    style           dd ?
    lpfnWndProc     dq ?
    cbClsExtra      dd ?
    cbWndExtra      dd ?
    hInstance       dq ?
    hIcon           dq ?
    hCursor         dq ?
    hbrBackground   dq ?
    lpszMenuName    dq ?
    lpszClassName   dq ?
    hIconSm         dq ?
WNDCLASSEXA ends

POINT_T struct
    ptx             dd ?
    pty             dd ?
POINT_T ends

MSG_T struct 8
    hwnd            dq ?
    message         dd ?
                    dd ?
    wParam          dq ?
    lParam          dq ?
    time            dd ?
    pt              POINT_T <>
                    dd ?
MSG_T ends

RECT_T struct
    left            dd ?
    top             dd ?
    right           dd ?
    bottom          dd ?
RECT_T ends

PAINTSTRUCT struct 8
    hdc             dq ?
    fErase          dd ?
    rcPaint         RECT_T <>
    fRestore        dd ?
    fIncUpdate      dd ?
    rgbReserved     db 32 dup(?)
PAINTSTRUCT ends

BULLET struct
    posX            dd ?
    posY            dd ?
    active          dd ?
BULLET ends

ENEMY struct
    posX            dd ?
    posY            dd ?
    alive           dd ?
    tipo            dd ?
    speedX          dd ?
    speedY          dd ?
    animFrame       dd ?
ENEMY ends

STAR struct
    posX            dd ?
    posY            dd ?
    speed           dd ?
    brightness      dd ?
STAR ends

ENEMY_BULLET struct
    posX            dd ?
    posY            dd ?
    active          dd ?
ENEMY_BULLET ends

POWERUP struct
    posX            dd ?
    posY            dd ?
    active          dd ?
    tipo            dd ?
POWERUP ends

EXPLOSION struct
    posX            dd ?
    posY            dd ?
    active          dd ?
    frameNum        dd ?
EXPLOSION ends

BOSS struct
    posX            dd ?
    posY            dd ?
    alive           dd ?
    hp              dd ?
    speedX          dd ?
    shootTimer      dd ?
BOSS ends

PARTICLE struct
    posX            dd ?
    posY            dd ?
    velX            dd ?
    velY            dd ?
    life            dd ?
    color           dd ?
PARTICLE ends

COIN struct
    posX            dd ?
    posY            dd ?
    active          dd ?
    velY            dd ?
COIN ends

; -------------------------------------------------
; Dados
; -------------------------------------------------

.data
    szClassName     db "SpaceShooter", 0
    szTitle         db "Space Shooter Deluxe", 0
    szGameTitle     db "SPACE SHOOTER", 0
    szDeluxe        db "DELUXE", 0
    szStartBtn      db "[ INICIAR JOGO ]", 0
    szPressEnter    db "Pressione ENTER para iniciar", 0
    szGameOver      db "GAME OVER", 0
    szScoreFmt      db "Pontuacao: %d", 0
    szLivesFmt      db "Vidas: %d", 0
    szWaveFmt       db "WAVE %d", 0
    szPaused        db "PAUSADO", 0
    szPressEsc      db "Pressione ESC para continuar", 0
    szPressRestart  db "Pressione ENTER para voltar ao menu", 0
    szHighScoreFmt  db "Recorde: %d", 0
    szNewRecord     db "NOVO RECORDE!", 0
    szBossWarning   db "!!! BOSS !!!", 0
    szComboFmt      db "COMBO x%d", 0
    szBombFmt       db "BOMBA: %d", 0
    szCoinsFmt      db "Moedas: %d", 0
    szControls1     db "A/D - Mover   W/S - Vertical", 0
    szControls2     db "SPACE - Atirar   B - Bomba", 0
    szControls3     db "ESC - Pausar", 0
    szStatsFmt      db "Kills: %d  Precisao: %d%%", 0
    szUpgradeTitle  db "LOJA DE UPGRADES", 0
    szUpgradeSpeed  db "[1] +Velocidade (5 moedas)", 0
    szUpgradeRate   db "[2] +Cadencia (5 moedas)", 0
    szUpgradeBullet db "[3] +Balas (8 moedas)", 0
    szUpgradeCont   db "[ENTER] Continuar", 0
    szBulletLvlFmt  db "Balas: %d/4", 0
    szDamageFmt     db "Dano: %d", 0
    szDbg1          db "1-Start", 0
    szDbg2          db "2-Brushes", 0
    szDbg3          db "3-Init", 0
    szDbg4          db "4-Window", 0
    szDbg5          db "5-Timer", 0
    szCap           db "Debug", 0
    szHighScoreFile db "highscore.dat", 0

.data?
    hInstance       dq ?
    hWndMain        dq ?
    wc              WNDCLASSEXA <>
    msgStruct       MSG_T <>
    ps              PAINTSTRUCT <>
    rect            RECT_T <>
    
    hBrushBlack     dq ?
    hBrushDarkBlue  dq ?
    hBrushCyan      dq ?
    hBrushRed       dq ?
    hBrushOrange    dq ?
    hBrushYellow    dq ?
    hBrushWhite     dq ?
    hBrushPurple    dq ?
    hBrushPink      dq ?
    hBrushDimStar   dq ?
    hBrushMedStar   dq ?
    hBrushWing      dq ?
    
    playerX         dd ?
    playerY         dd ?
    score           dd ?
    level           dd ?
    gameOver        dd ?
    gameState       dd ?
    shootCooldown   dd ?
    
    ; New variables
    lives           dd ?
    invincibleTimer dd ?
    highScore       dd ?
    wave            dd ?
    waveTimer       dd ?
    enemiesInWave   dd ?
    enemiesKilled   dd ?
    isPaused        dd ?
    escCooldown     dd ?
    
    ; Power-up variables
    hasDoubleShot   dd ?
    doubleTimer     dd ?
    hasShield       dd ?
    shieldTimer     dd ?
    hasSpeedBoost   dd ?
    speedTimer      dd ?
    playerSpeed     dd ?
    
    ; Boss variables
    bossActive      dd ?
    theBoss         BOSS <>
    
    ; Combo system
    comboCount      dd ?
    comboTimer      dd ?
    maxCombo        dd ?
    
    ; Bomb system
    bombCount       dd ?
    bombActive      dd ?
    bombTimer       dd ?
    
    ; Player damage upgrade
    playerDamage    dd ?
    
    ; Upgrade selection
    upgradeCooldown dd ?
    upgradeSelection dd ?
    upgradeSpeed    dd ?
    upgradeFireRate dd ?
    bulletLevel     dd ?       ; 1-4 balas
    baseShootCooldown dd ?     ; Cooldown base (afetado por upgrade)
    
    ; Coins/Stats
    coins           dd ?
    totalKills      dd ?
    shotsFired      dd ?
    shotsHit        dd ?
    
    ; Screen shake
    shakeTimer      dd ?
    shakeIntensity  dd ?
    
    ; Particles
    particles       PARTICLE MAX_PARTICLES dup(<>)
    coinItems       COIN MAX_COINS dup(<>)
    
    hFontTitle      dq ?
    hFontSubtitle   dq ?
    hFontButton     dq ?
    hFontSmall      dq ?
    scoreBuffer     db 32 dup(?)
    livesBuffer     db 32 dup(?)
    waveBuffer      db 32 dup(?)
    enterCooldown   dd ?
    spawnTimer      dd ?
    spawnDelay      dd ?
    enemyBaseSpeed  dd ?
    
    bullets         BULLET MAX_BULLETS dup(<>)
    enemies         ENEMY MAX_ENEMIES dup(<>)
    enemyBullets    ENEMY_BULLET MAX_ENEMY_BULLETS dup(<>)
    powerups        POWERUP MAX_POWERUPS dup(<>)
    explosions      EXPLOSION MAX_EXPLOSIONS dup(<>)
    stars           STAR MAX_STARS dup(<>)
    enemyShootTimer dd ?
    
    hBrushGreen     dq ?
    hBrushLightBlue dq ?
    hBrushDarkCyan  dq ?
    hBrushGold      dq ?
    hBrushDarkRed   dq ?
    
    wpHwnd          dq ?
    wpMsg           dd ?
    wpWParam        dq ?
    wpLParam        dq ?
    
    currentHdc      dq ?
    randSeed        dd ?
    randMax         dd ?

; -------------------------------------------------
; Imports
; -------------------------------------------------

.code

externdef GetModuleHandleA:proc
externdef RegisterClassExA:proc
externdef CreateWindowExA:proc
externdef GetMessageA:proc
externdef TranslateMessage:proc
externdef DispatchMessageA:proc
externdef DefWindowProcA:proc
externdef PostQuitMessage:proc
externdef LoadCursorA:proc
externdef ExitProcess:proc
externdef SetTimer:proc
externdef KillTimer:proc
externdef InvalidateRect:proc
externdef GetAsyncKeyState:proc
externdef BeginPaint:proc
externdef EndPaint:proc
externdef CreateSolidBrush:proc
externdef FillRect:proc
externdef GetTickCount:proc
externdef MessageBoxA:proc
externdef CreateFontA:proc
externdef SelectObject:proc
externdef SetTextColor:proc
externdef SetBkMode:proc
externdef DrawTextA:proc
externdef DeleteObject:proc
externdef wsprintfA:proc
externdef Beep:proc
externdef CreateFileA:proc
externdef ReadFile:proc
externdef WriteFile:proc
externdef CloseHandle:proc

; -------------------------------------------------
; Random (0 .. randMax-1)
; -------------------------------------------------

Random proc
    sub     rsp, 28h

    mov     eax, randSeed
    imul    eax, 1103515245
    add     eax, 12345
    mov     randSeed, eax
    and     eax, 7FFFFFFFh
    xor     edx, edx
    mov     ecx, randMax
    div     ecx
    mov     eax, edx

    add     rsp, 28h
    ret
Random endp

; -------------------------------------------------
; InitGame
; -------------------------------------------------

InitGame proc
    push    rbx
    push    rsi
    sub     rsp, 28h
    
    call    GetTickCount
    mov     randSeed, eax
    
    mov     dword ptr playerX, (WINDOW_WIDTH - PLAYER_WIDTH) / 2
    mov     dword ptr playerY, WINDOW_HEIGHT - PLAYER_HEIGHT - 30
    mov     dword ptr score, 0
    mov     dword ptr level, 1
    mov     dword ptr gameOver, 0
    mov     dword ptr gameState, STATE_MENU
    mov     dword ptr shootCooldown, 0
    mov     dword ptr enterCooldown, 30
    mov     dword ptr spawnTimer, 0
    mov     dword ptr spawnDelay, 60
    mov     dword ptr enemyBaseSpeed, 2
    mov     dword ptr enemyShootTimer, 0
    
    ; New variables
    mov     dword ptr lives, MAX_LIVES
    mov     dword ptr invincibleTimer, 0
    mov     dword ptr wave, 1
    mov     dword ptr waveTimer, 0
    mov     dword ptr enemiesInWave, 5
    mov     dword ptr enemiesKilled, 0
    mov     dword ptr isPaused, 0
    mov     dword ptr escCooldown, 0
    
    ; Power-ups
    mov     dword ptr hasDoubleShot, 0
    mov     dword ptr doubleTimer, 0
    mov     dword ptr hasShield, 0
    mov     dword ptr shieldTimer, 0
    mov     dword ptr hasSpeedBoost, 0
    mov     dword ptr speedTimer, 0
    mov     dword ptr playerSpeed, PLAYER_SPEED
    
    ; Boss
    mov     dword ptr bossActive, 0
    mov     dword ptr theBoss.alive, 0
    
    ; Combo system
    mov     dword ptr comboCount, 0
    mov     dword ptr comboTimer, 0
    mov     dword ptr maxCombo, 0
    
    ; Bomb system
    mov     dword ptr bombCount, 3
    mov     dword ptr bombActive, 0
    mov     dword ptr bombTimer, 0
    
    ; Player damage and upgrades
    mov     dword ptr playerDamage, 1
    mov     dword ptr upgradeCooldown, 0
    mov     dword ptr upgradeSelection, 0
    mov     dword ptr upgradeSpeed, 0
    mov     dword ptr upgradeFireRate, 0
    mov     dword ptr bulletLevel, 1       ; Começa com 1 bala
    mov     dword ptr baseShootCooldown, 15 ; Cooldown base
    
    ; Coins/Stats
    mov     dword ptr coins, 0
    mov     dword ptr totalKills, 0
    mov     dword ptr shotsFired, 0
    mov     dword ptr shotsHit, 0
    
    ; Screen shake
    mov     dword ptr shakeTimer, 0
    mov     dword ptr shakeIntensity, 0
    
    ; bullets = 0
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
zero_blt:
    mov     dword ptr [rbx].BULLET.active, 0
    add     rbx, sizeof BULLET
    dec     esi
    jnz     zero_blt
    
    ; enemies = 0
    lea     rbx, enemies
    mov     esi, MAX_ENEMIES
zero_enm:
    mov     dword ptr [rbx].ENEMY.alive, 0
    add     rbx, sizeof ENEMY
    dec     esi
    jnz     zero_enm
    
    ; enemy bullets = 0
    lea     rbx, enemyBullets
    mov     esi, MAX_ENEMY_BULLETS
zero_enm_blt:
    mov     dword ptr [rbx].ENEMY_BULLET.active, 0
    add     rbx, sizeof ENEMY_BULLET
    dec     esi
    jnz     zero_enm_blt
    
    ; power-ups = 0
    lea     rbx, powerups
    mov     esi, MAX_POWERUPS
zero_pwrup:
    mov     dword ptr [rbx].POWERUP.active, 0
    add     rbx, sizeof POWERUP
    dec     esi
    jnz     zero_pwrup
    
    ; explosions = 0
    lea     rbx, explosions
    mov     esi, MAX_EXPLOSIONS
zero_expl:
    mov     dword ptr [rbx].EXPLOSION.active, 0
    add     rbx, sizeof EXPLOSION
    dec     esi
    jnz     zero_expl
    
    ; particles = 0
    lea     rbx, particles
    mov     esi, MAX_PARTICLES
zero_part:
    mov     dword ptr [rbx].PARTICLE.life, 0
    add     rbx, sizeof PARTICLE
    dec     esi
    jnz     zero_part
    
    ; coins = 0
    lea     rbx, coinItems
    mov     esi, MAX_COINS
zero_coins:
    mov     dword ptr [rbx].COIN.active, 0
    add     rbx, sizeof COIN
    dec     esi
    jnz     zero_coins
    
    ; stars - com parallax (layer baseado em speed)
    lea     rbx, stars
    mov     esi, MAX_STARS
star_init:
    mov     dword ptr randMax, WINDOW_WIDTH
    call    Random
    mov     [rbx].STAR.posX, eax
    
    mov     dword ptr randMax, WINDOW_HEIGHT
    call    Random
    mov     [rbx].STAR.posY, eax
    
    mov     dword ptr randMax, 3
    call    Random
    inc     eax
    mov     [rbx].STAR.speed, eax
    
    mov     dword ptr randMax, 3
    call    Random
    mov     [rbx].STAR.brightness, eax
    
    add     rbx, sizeof STAR
    dec     esi
    jnz     star_init
    
    add     rsp, 28h
    pop     rsi
    pop     rbx
    ret
InitGame endp

; -------------------------------------------------
; SpawnEnemy
; -------------------------------------------------

SpawnEnemy proc
    push    rbx
    sub     rsp, 20h
    
    lea     rbx, enemies
    mov     eax, MAX_ENEMIES
find_slot:
    cmp     dword ptr [rbx].ENEMY.alive, 0
    je      slot_found
    add     rbx, sizeof ENEMY
    dec     eax
    jnz     find_slot
    jmp     spawn_done
    
slot_found:
    mov     dword ptr randMax, WINDOW_WIDTH - ENEMY_WIDTH - 20
    call    Random
    add     eax, 10
    mov     [rbx].ENEMY.posX, eax
    
    mov     dword ptr [rbx].ENEMY.posY, -30
    
    mov     dword ptr randMax, 4
    call    Random
    mov     [rbx].ENEMY.tipo, eax
    
    mov     dword ptr randMax, 5
    call    Random
    sub     eax, 2
    mov     [rbx].ENEMY.speedX, eax
    
    mov     eax, enemyBaseSpeed
    add     eax, 1
    mov     [rbx].ENEMY.speedY, eax
    
    mov     dword ptr [rbx].ENEMY.animFrame, 0
    mov     dword ptr [rbx].ENEMY.alive, 1
    
spawn_done:
    add     rsp, 20h
    pop     rbx
    ret
SpawnEnemy endp

; -------------------------------------------------
; SpawnPowerup (at position in ecx=X, edx=Y)
; -------------------------------------------------

SpawnPowerup proc
    push    rbx
    push    rsi
    push    rdi
    sub     rsp, 20h
    
    mov     esi, ecx        ; save X
    mov     edi, edx        ; save Y
    
    ; 30% chance to spawn powerup
    mov     dword ptr randMax, 100
    call    Random
    cmp     eax, 30
    jge     powerup_done
    
    ; Find free slot
    lea     rbx, powerups
    mov     eax, MAX_POWERUPS
find_pwrup_slot:
    cmp     dword ptr [rbx].POWERUP.active, 0
    je      pwrup_slot_found
    add     rbx, sizeof POWERUP
    dec     eax
    jnz     find_pwrup_slot
    jmp     powerup_done
    
pwrup_slot_found:
    mov     [rbx].POWERUP.posX, esi
    mov     [rbx].POWERUP.posY, edi
    mov     dword ptr [rbx].POWERUP.active, 1
    
    ; Random type
    mov     dword ptr randMax, 4
    call    Random
    mov     [rbx].POWERUP.tipo, eax
    
powerup_done:
    add     rsp, 20h
    pop     rdi
    pop     rsi
    pop     rbx
    ret
SpawnPowerup endp

; -------------------------------------------------
; CreateExplosion (at position in ecx=X, edx=Y)
; -------------------------------------------------

CreateExplosion proc
    push    rbx
    sub     rsp, 20h
    
    ; Find free slot
    lea     rbx, explosions
    mov     eax, MAX_EXPLOSIONS
find_expl_slot:
    cmp     dword ptr [rbx].EXPLOSION.active, 0
    je      expl_slot_found
    add     rbx, sizeof EXPLOSION
    dec     eax
    jnz     find_expl_slot
    jmp     expl_done
    
expl_slot_found:
    mov     [rbx].EXPLOSION.posX, ecx
    mov     [rbx].EXPLOSION.posY, edx
    mov     dword ptr [rbx].EXPLOSION.active, 1
    mov     dword ptr [rbx].EXPLOSION.frameNum, 0
    
    ; Add screen shake
    mov     dword ptr shakeTimer, 8
    mov     dword ptr shakeIntensity, 3
    
expl_done:
    add     rsp, 20h
    pop     rbx
    ret
CreateExplosion endp

; -------------------------------------------------
; SpawnParticles (ecx=X, edx=Y, r8d=count, r9d=color)
; -------------------------------------------------

SpawnParticles proc
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 20h
    
    mov     esi, ecx        ; X
    mov     edi, edx        ; Y
    mov     r12d, r8d       ; count
    mov     r13d, r9d       ; color
    
spawn_part_loop:
    cmp     r12d, 0
    jle     spawn_part_done
    
    lea     rbx, particles
    mov     eax, MAX_PARTICLES
find_part_slot:
    cmp     dword ptr [rbx].PARTICLE.life, 0
    jle     part_slot_found
    add     rbx, sizeof PARTICLE
    dec     eax
    jnz     find_part_slot
    jmp     spawn_part_done
    
part_slot_found:
    mov     [rbx].PARTICLE.posX, esi
    mov     [rbx].PARTICLE.posY, edi
    mov     [rbx].PARTICLE.color, r13d
    mov     dword ptr [rbx].PARTICLE.life, 20
    
    ; Random velocity
    mov     dword ptr randMax, 9
    call    Random
    sub     eax, 4
    mov     [rbx].PARTICLE.velX, eax
    
    mov     dword ptr randMax, 9
    call    Random
    sub     eax, 4
    mov     [rbx].PARTICLE.velY, eax
    
    dec     r12d
    jmp     spawn_part_loop
    
spawn_part_done:
    add     rsp, 20h
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    ret
SpawnParticles endp

; -------------------------------------------------
; SpawnCoin (at position ecx=X, edx=Y)
; -------------------------------------------------

SpawnCoin proc
    push    rbx
    sub     rsp, 20h
    
    lea     rbx, coinItems
    mov     eax, MAX_COINS
find_coin_slot:
    cmp     dword ptr [rbx].COIN.active, 0
    je      coin_slot_found
    add     rbx, sizeof COIN
    dec     eax
    jnz     find_coin_slot
    jmp     coin_done
    
coin_slot_found:
    mov     [rbx].COIN.posX, ecx
    mov     [rbx].COIN.posY, edx
    mov     dword ptr [rbx].COIN.active, 1
    mov     dword ptr [rbx].COIN.velY, 2
    
coin_done:
    add     rsp, 20h
    pop     rbx
    ret
SpawnCoin endp

; -------------------------------------------------
; ActivateBomb - Clear all enemies
; -------------------------------------------------

ActivateBomb proc
    push    rbx
    push    rsi
    sub     rsp, 28h
    
    cmp     dword ptr bombCount, 0
    jle     bomb_done
    
    dec     dword ptr bombCount
    mov     dword ptr bombActive, 1
    mov     dword ptr bombTimer, 30
    
    ; Screen flash/shake
    mov     dword ptr shakeTimer, 20
    mov     dword ptr shakeIntensity, 8
    
    ; Kill all enemies
    lea     rbx, enemies
    mov     esi, MAX_ENEMIES
bomb_kill_loop:
    cmp     dword ptr [rbx].ENEMY.alive, 0
    je      bomb_next
    
    mov     dword ptr [rbx].ENEMY.alive, 0
    add     dword ptr score, 50
    inc     dword ptr totalKills
    
    ; Create explosion
    mov     ecx, [rbx].ENEMY.posX
    add     ecx, ENEMY_WIDTH / 2
    mov     edx, [rbx].ENEMY.posY
    add     edx, ENEMY_HEIGHT / 2
    call    CreateExplosion
    
bomb_next:
    add     rbx, sizeof ENEMY
    dec     esi
    jnz     bomb_kill_loop
    
    ; Clear enemy bullets too
    lea     rbx, enemyBullets
    mov     esi, MAX_ENEMY_BULLETS
bomb_clear_blt:
    mov     dword ptr [rbx].ENEMY_BULLET.active, 0
    add     rbx, sizeof ENEMY_BULLET
    dec     esi
    jnz     bomb_clear_blt
    
bomb_done:
    add     rsp, 28h
    pop     rsi
    pop     rbx
    ret
ActivateBomb endp

; -------------------------------------------------
; SpawnBoss
; -------------------------------------------------

SpawnBoss proc
    sub     rsp, 28h
    
    mov     dword ptr bossActive, 1
    mov     dword ptr theBoss.posX, (WINDOW_WIDTH - BOSS_WIDTH) / 2
    mov     dword ptr theBoss.posY, -60
    mov     dword ptr theBoss.alive, 1
    mov     dword ptr theBoss.hp, BOSS_HP
    mov     dword ptr theBoss.speedX, 2
    mov     dword ptr theBoss.shootTimer, 0
    
    add     rsp, 28h
    ret
SpawnBoss endp

; -------------------------------------------------
; LoadHighScore
; -------------------------------------------------

LoadHighScore proc
    sub     rsp, 48h
    
    ; Try to open file
    lea     rcx, szHighScoreFile
    mov     edx, 80000000h          ; GENERIC_READ
    mov     r8d, 1                   ; FILE_SHARE_READ
    xor     r9d, r9d                 ; no security
    mov     dword ptr [rsp+20h], 3   ; OPEN_EXISTING
    mov     dword ptr [rsp+28h], 0   ; normal
    mov     qword ptr [rsp+30h], 0   ; no template
    call    CreateFileA
    
    cmp     rax, -1                  ; INVALID_HANDLE_VALUE
    je      load_failed
    
    mov     rbx, rax                 ; save handle
    
    ; Read 4 bytes
    mov     rcx, rbx
    lea     rdx, highScore
    mov     r8d, 4
    lea     r9, [rsp+38h]            ; bytes read
    mov     qword ptr [rsp+20h], 0
    call    ReadFile
    
    ; Close file
    mov     rcx, rbx
    call    CloseHandle
    jmp     load_done
    
load_failed:
    mov     dword ptr highScore, 0
    
load_done:
    add     rsp, 48h
    ret
LoadHighScore endp

; -------------------------------------------------
; SaveHighScore
; -------------------------------------------------

SaveHighScore proc
    push    rbx
    sub     rsp, 40h
    
    ; Check if current score beats high score
    mov     eax, score
    cmp     eax, highScore
    jle     save_done
    
    mov     highScore, eax
    
    ; Create/open file
    lea     rcx, szHighScoreFile
    mov     edx, 40000000h          ; GENERIC_WRITE
    mov     r8d, 0                   ; no share
    xor     r9d, r9d                 ; no security
    mov     dword ptr [rsp+20h], 2   ; CREATE_ALWAYS
    mov     dword ptr [rsp+28h], 80h ; FILE_ATTRIBUTE_NORMAL
    mov     qword ptr [rsp+30h], 0   ; no template
    call    CreateFileA
    
    cmp     rax, -1
    je      save_done
    
    mov     rbx, rax                 ; save handle
    
    ; Write 4 bytes
    mov     rcx, rbx
    lea     rdx, highScore
    mov     r8d, 4
    lea     r9, [rsp+30h]            ; bytes written
    mov     qword ptr [rsp+20h], 0
    call    WriteFile
    
    ; Close file
    mov     rcx, rbx
    call    CloseHandle
    
save_done:
    add     rsp, 40h
    pop     rbx
    ret
SaveHighScore endp

; -------------------------------------------------
; PlayerHit - Called when player takes damage
; -------------------------------------------------

PlayerHit proc
    sub     rsp, 28h
    
    ; Check if shielded
    cmp     dword ptr hasShield, 0
    je      no_shield
    mov     dword ptr hasShield, 0
    mov     dword ptr shieldTimer, 0
    jmp     hit_done
    
no_shield:
    ; Check if invincible
    cmp     dword ptr invincibleTimer, 0
    jg      hit_done
    
    ; Lose a life
    dec     dword ptr lives
    cmp     dword ptr lives, 0
    jle     player_dead
    
    ; Start invincibility
    mov     dword ptr invincibleTimer, INVINCIBLE_TIME
    jmp     hit_done
    
player_dead:
    mov     dword ptr gameOver, 1
    mov     dword ptr gameState, STATE_GAMEOVER
    call    SaveHighScore
    
hit_done:
    add     rsp, 28h
    ret
PlayerHit endp

; -------------------------------------------------
; UpdateGame
; -------------------------------------------------

UpdateGame proc
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    sub     rsp, 28h
    
    ; Check game state
    cmp     dword ptr gameState, STATE_MENU
    je      check_start_game
    cmp     dword ptr gameState, STATE_GAMEOVER
    je      check_restart
    cmp     dword ptr gameState, STATE_PAUSED
    je      check_unpause
    cmp     dword ptr gameState, STATE_UPGRADE
    je      check_upgrade
    jmp     do_update
    
check_upgrade:
    ; Update stars in upgrade screen
    lea     rbx, stars
    mov     esi, MAX_STARS
upgrade_star_upd:
    mov     eax, [rbx].STAR.speed
    add     [rbx].STAR.posY, eax
    cmp     dword ptr [rbx].STAR.posY, WINDOW_HEIGHT
    jl      upgrade_star_ok
    mov     dword ptr [rbx].STAR.posY, 0
upgrade_star_ok:
    add     rbx, sizeof STAR
    dec     esi
    jnz     upgrade_star_upd
    
    ; Decrement upgrade cooldown
    cmp     dword ptr upgradeCooldown, 0
    jle     upgrade_cd_done
    dec     dword ptr upgradeCooldown
    jmp     update_done
upgrade_cd_done:
    
    ; Check key 1 - Speed upgrade (cost 5 coins)
    mov     ecx, 31h          ; '1' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      check_key_2
    cmp     dword ptr coins, 5
    jl      check_key_2
    cmp     dword ptr playerSpeed, 12  ; Max speed
    jge     check_key_2
    sub     dword ptr coins, 5
    inc     dword ptr upgradeSpeed
    inc     dword ptr playerSpeed
    mov     dword ptr upgradeCooldown, 15  ; Small delay between purchases
    jmp     update_done
    
check_key_2:
    ; Check key 2 - Fire rate upgrade (cost 5 coins)
    mov     ecx, 32h          ; '2' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      check_key_3
    cmp     dword ptr coins, 5
    jl      check_key_3
    cmp     dword ptr baseShootCooldown, 7  ; Min cooldown base
    jle     check_key_3
    sub     dword ptr coins, 5
    inc     dword ptr upgradeFireRate
    ; Decrease base shoot cooldown (min 7)
    mov     eax, baseShootCooldown
    sub     eax, 2
    cmp     eax, 7
    jge     set_fire_rate
    mov     eax, 7
set_fire_rate:
    mov     baseShootCooldown, eax
    mov     dword ptr upgradeCooldown, 15  ; Small delay between purchases
    jmp     update_done
    
check_key_3:
    ; Check key 3 - Extra bullet (cost 8 coins, max 4)
    mov     ecx, 33h          ; '3' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      check_enter_skip
    cmp     dword ptr coins, 8
    jl      check_enter_skip
    cmp     dword ptr bulletLevel, 4    ; Max 4 balas
    jge     check_enter_skip
    sub     dword ptr coins, 8
    inc     dword ptr bulletLevel
    mov     dword ptr upgradeCooldown, 15  ; Small delay between purchases
    jmp     update_done
    
check_enter_skip:
    ; Check ENTER to continue to next wave
    mov     ecx, VK_RETURN
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      update_done
    
upgrade_continue_wave:
    ; Next wave
    inc     dword ptr wave
    mov     dword ptr enemiesKilled, 0
    add     dword ptr enemiesInWave, 3
    mov     dword ptr gameState, STATE_PLAYING
    mov     dword ptr upgradeCooldown, 30
    jmp     update_done
    
check_unpause:
    ; Update stars even when paused
    lea     rbx, stars
    mov     esi, MAX_STARS
pause_star_upd:
    mov     eax, [rbx].STAR.speed
    add     [rbx].STAR.posY, eax
    cmp     dword ptr [rbx].STAR.posY, WINDOW_HEIGHT
    jl      pause_star_ok
    mov     dword ptr [rbx].STAR.posY, 0
pause_star_ok:
    add     rbx, sizeof STAR
    dec     esi
    jnz     pause_star_upd
    
    ; Decrement ESC cooldown
    cmp     dword ptr escCooldown, 0
    jle     pause_esc_done
    dec     dword ptr escCooldown
pause_esc_done:
    
    cmp     dword ptr escCooldown, 0
    jg      update_done
    
    ; Check ESC to unpause
    mov     ecx, VK_ESCAPE
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      update_done
    mov     dword ptr gameState, STATE_PLAYING
    mov     dword ptr isPaused, 0
    mov     dword ptr escCooldown, 20
    jmp     update_done
    
check_start_game:
    ; Decrement enter cooldown
    cmp     dword ptr enterCooldown, 0
    jle     menu_cooldown_done
    dec     dword ptr enterCooldown
menu_cooldown_done:
    
    ; Update stars even in menu
    lea     rbx, stars
    mov     esi, MAX_STARS
menu_star_upd:
    mov     eax, [rbx].STAR.speed
    add     [rbx].STAR.posY, eax
    cmp     dword ptr [rbx].STAR.posY, WINDOW_HEIGHT
    jl      menu_star_ok
    mov     dword ptr [rbx].STAR.posY, 0
menu_star_ok:
    add     rbx, sizeof STAR
    dec     esi
    jnz     menu_star_upd
    
    ; Check cooldown before accepting ENTER
    cmp     dword ptr enterCooldown, 0
    jg      update_done
    
    ; Check ENTER to start
    mov     ecx, VK_RETURN
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      update_done
    mov     dword ptr gameState, STATE_PLAYING
    ; Reset player position and clear enemies/bullets for new game
    mov     dword ptr playerX, (WINDOW_WIDTH - PLAYER_WIDTH) / 2
    mov     dword ptr playerY, WINDOW_HEIGHT - PLAYER_HEIGHT - 30
    mov     dword ptr score, 0
    mov     dword ptr level, 1
    mov     dword ptr gameOver, 0
    mov     dword ptr spawnTimer, 0
    mov     dword ptr spawnDelay, 60
    mov     dword ptr enemyBaseSpeed, 2
    
    ; Reset new variables
    mov     dword ptr lives, MAX_LIVES
    mov     dword ptr invincibleTimer, 0
    mov     dword ptr wave, 1
    mov     dword ptr waveTimer, 0
    mov     dword ptr enemiesInWave, 5
    mov     dword ptr enemiesKilled, 0
    mov     dword ptr hasDoubleShot, 0
    mov     dword ptr hasShield, 0
    mov     dword ptr hasSpeedBoost, 0
    mov     dword ptr playerSpeed, PLAYER_SPEED
    mov     dword ptr bossActive, 0
    mov     dword ptr theBoss.alive, 0
    
    ; Reset combo/bomb/stats
    mov     dword ptr comboCount, 0
    mov     dword ptr comboTimer, 0
    mov     dword ptr bombCount, 3
    mov     dword ptr bombActive, 0
    mov     dword ptr playerDamage, 1
    mov     dword ptr coins, 0
    mov     dword ptr totalKills, 0
    mov     dword ptr shotsFired, 0
    mov     dword ptr shotsHit, 0
    mov     dword ptr shakeTimer, 0
    mov     dword ptr upgradeCooldown, 0
    mov     dword ptr upgradeSelection, 0
    mov     dword ptr upgradeSpeed, 0
    mov     dword ptr upgradeFireRate, 0
    mov     dword ptr bulletLevel, 1
    mov     dword ptr shootCooldown, 15
    mov     dword ptr baseShootCooldown, 15
    
    ; Clear bullets
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
clear_blt_menu:
    mov     dword ptr [rbx].BULLET.active, 0
    add     rbx, sizeof BULLET
    dec     esi
    jnz     clear_blt_menu
    
    ; Clear enemies
    lea     rbx, enemies
    mov     esi, MAX_ENEMIES
clear_enm_menu:
    mov     dword ptr [rbx].ENEMY.alive, 0
    add     rbx, sizeof ENEMY
    dec     esi
    jnz     clear_enm_menu
    
    ; Clear enemy bullets
    lea     rbx, enemyBullets
    mov     esi, MAX_ENEMY_BULLETS
clear_enm_blt_menu:
    mov     dword ptr [rbx].ENEMY_BULLET.active, 0
    add     rbx, sizeof ENEMY_BULLET
    dec     esi
    jnz     clear_enm_blt_menu
    
    jmp     update_done
    
check_restart:
    ; Update stars even in gameover
    lea     rbx, stars
    mov     esi, MAX_STARS
go_star_upd:
    mov     eax, [rbx].STAR.speed
    add     [rbx].STAR.posY, eax
    cmp     dword ptr [rbx].STAR.posY, WINDOW_HEIGHT
    jl      go_star_ok
    mov     dword ptr [rbx].STAR.posY, 0
go_star_ok:
    add     rbx, sizeof STAR
    dec     esi
    jnz     go_star_upd
    
    mov     ecx, VK_RETURN
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      update_done
    ; Reset game and go back to menu
    call    InitGame
    jmp     update_done
    
do_update:
    ; Check for ESC (pause)
    cmp     dword ptr escCooldown, 0
    jle     esc_cooldown_done
    dec     dword ptr escCooldown
esc_cooldown_done:
    cmp     dword ptr escCooldown, 0
    jg      skip_pause_check
    mov     ecx, VK_ESCAPE
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      skip_pause_check
    mov     dword ptr gameState, STATE_PAUSED
    mov     dword ptr isPaused, 1
    mov     dword ptr escCooldown, 20
    jmp     update_done
    
skip_pause_check:
    ; Decrement invincibility timer
    cmp     dword ptr invincibleTimer, 0
    jle     inv_done
    dec     dword ptr invincibleTimer
inv_done:
    
    ; Update power-up timers
    cmp     dword ptr hasDoubleShot, 0
    je      double_done
    dec     dword ptr doubleTimer
    cmp     dword ptr doubleTimer, 0
    jg      double_done
    mov     dword ptr hasDoubleShot, 0
double_done:
    
    cmp     dword ptr hasShield, 0
    je      shield_done
    dec     dword ptr shieldTimer
    cmp     dword ptr shieldTimer, 0
    jg      shield_done
    mov     dword ptr hasShield, 0
shield_done:
    
    cmp     dword ptr hasSpeedBoost, 0
    je      speed_done
    dec     dword ptr speedTimer
    cmp     dword ptr speedTimer, 0
    jg      speed_done
    mov     dword ptr hasSpeedBoost, 0
    ; Restore speed to base + upgrades (not just PLAYER_SPEED)
    mov     eax, PLAYER_SPEED
    add     eax, upgradeSpeed
    mov     playerSpeed, eax
speed_done:
    
    ; Update combo timer
    cmp     dword ptr comboTimer, 0
    jle     combo_done
    dec     dword ptr comboTimer
    cmp     dword ptr comboTimer, 0
    jg      combo_done
    ; Combo expired
    mov     eax, comboCount
    cmp     eax, maxCombo
    jle     reset_combo
    mov     maxCombo, eax
reset_combo:
    mov     dword ptr comboCount, 0
combo_done:
    
    ; Update bomb timer
    cmp     dword ptr bombTimer, 0
    jle     bomb_timer_done
    dec     dword ptr bombTimer
    cmp     dword ptr bombTimer, 0
    jg      bomb_timer_done
    mov     dword ptr bombActive, 0
bomb_timer_done:
    
    ; Update screen shake
    cmp     dword ptr shakeTimer, 0
    jle     shake_done
    dec     dword ptr shakeTimer
shake_done:
    
    ; Update particles
    lea     rbx, particles
    mov     esi, MAX_PARTICLES
part_upd:
    cmp     dword ptr [rbx].PARTICLE.life, 0
    jle     next_part
    dec     dword ptr [rbx].PARTICLE.life
    mov     eax, [rbx].PARTICLE.velX
    add     [rbx].PARTICLE.posX, eax
    mov     eax, [rbx].PARTICLE.velY
    add     [rbx].PARTICLE.posY, eax
next_part:
    add     rbx, sizeof PARTICLE
    dec     esi
    jnz     part_upd
    
    ; Update coins
    lea     rbx, coinItems
    mov     esi, MAX_COINS
coin_upd:
    cmp     dword ptr [rbx].COIN.active, 0
    je      next_coin_upd
    
    mov     eax, [rbx].COIN.velY
    add     [rbx].COIN.posY, eax
    
    ; Off screen?
    cmp     dword ptr [rbx].COIN.posY, WINDOW_HEIGHT
    jl      check_coin_collect
    mov     dword ptr [rbx].COIN.active, 0
    jmp     next_coin_upd
    
check_coin_collect:
    ; Check collision with player
    mov     eax, [rbx].COIN.posX
    cmp     eax, playerX
    jl      next_coin_upd
    mov     edx, playerX
    add     edx, PLAYER_WIDTH
    cmp     eax, edx
    jg      next_coin_upd
    mov     eax, [rbx].COIN.posY
    cmp     eax, playerY
    jl      next_coin_upd
    mov     edx, playerY
    add     edx, PLAYER_HEIGHT
    cmp     eax, edx
    jg      next_coin_upd
    
    ; Collected coin!
    mov     dword ptr [rbx].COIN.active, 0
    inc     dword ptr coins
    
next_coin_upd:
    add     rbx, sizeof COIN
    dec     esi
    jnz     coin_upd
    
    ; Check for bomb key (B)
    mov     ecx, VK_B
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      no_bomb
    cmp     dword ptr bombActive, 0
    jne     no_bomb
    call    ActivateBomb
no_bomb:
    
    ; Update explosions
    lea     rbx, explosions
    mov     esi, MAX_EXPLOSIONS
expl_upd:
    cmp     dword ptr [rbx].EXPLOSION.active, 0
    je      next_expl
    inc     dword ptr [rbx].EXPLOSION.frameNum
    mov     eax, [rbx].EXPLOSION.frameNum
    cmp     eax, EXPLOSION_FRAMES
    jl      next_expl
    mov     dword ptr [rbx].EXPLOSION.active, 0
next_expl:
    add     rbx, sizeof EXPLOSION
    dec     esi
    jnz     expl_upd
    
    ; stars - parallax effect (speed = layer)
    lea     rbx, stars
    mov     esi, MAX_STARS
star_upd:
    mov     eax, [rbx].STAR.speed
    add     [rbx].STAR.posY, eax
    cmp     dword ptr [rbx].STAR.posY, WINDOW_HEIGHT
    jl      star_ok
    mov     dword ptr [rbx].STAR.posY, 0
    ; Randomize X when wrapping
    mov     dword ptr randMax, WINDOW_WIDTH
    call    Random
    mov     [rbx].STAR.posX, eax
star_ok:
    add     rbx, sizeof STAR
    dec     esi
    jnz     star_upd
    
    ; left (A key) - simple movement
    mov     ecx, 41h          ; 'A' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      check_right
    mov     eax, playerX
    mov     ecx, playerSpeed
    sub     eax, ecx
    cmp     eax, 5
    jl      check_right
    mov     playerX, eax
    
check_right:
    mov     ecx, 44h          ; 'D' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      check_up
    mov     eax, playerX
    mov     ecx, playerSpeed
    add     eax, ecx
    cmp     eax, WINDOW_WIDTH - PLAYER_WIDTH - 5
    jg      check_up
    mov     playerX, eax
    
check_up:
    mov     ecx, VK_W          ; 'W' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      check_down
    mov     eax, playerY
    mov     ecx, playerSpeed
    sub     eax, ecx
    cmp     eax, WINDOW_HEIGHT / 2    ; Can't go above half screen
    jl      check_down
    mov     playerY, eax
    
check_down:
    mov     ecx, VK_S          ; 'S' key
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      spawn_thruster
    mov     eax, playerY
    mov     ecx, playerSpeed
    add     eax, ecx
    cmp     eax, WINDOW_HEIGHT - PLAYER_HEIGHT - 10
    jg      spawn_thruster
    mov     playerY, eax
    
spawn_thruster:
    ; Spawn thruster particles every few frames
    mov     eax, shakeTimer
    and     eax, 3              ; every 4 frames
    cmp     eax, 0
    jne     check_space
    
    ; Spawn 1-2 thruster particles at bottom of ship
    mov     ecx, playerX
    add     ecx, PLAYER_WIDTH / 2
    mov     edx, playerY
    add     edx, PLAYER_HEIGHT + 2
    mov     r8d, 1              ; 1 particle
    mov     r9d, 1              ; orange-ish
    call    SpawnParticles
    
check_space:
    cmp     dword ptr shootCooldown, 0
    jg      dec_cooldown
    
    mov     ecx, VK_SPACE
    call    GetAsyncKeyState
    test    ax, 8000h
    jz      update_bullets
    
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
find_bullet:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      create_bullet
    add     rbx, sizeof BULLET
    dec     esi
    jnz     find_bullet
    jmp     update_bullets
    
create_bullet:
    ; Create central bullet
    mov     eax, playerX
    add     eax, PLAYER_WIDTH / 2
    mov     [rbx].BULLET.posX, eax
    mov     eax, playerY
    mov     [rbx].BULLET.posY, eax
    mov     dword ptr [rbx].BULLET.active, 1
    ; Use base cooldown (affected by upgrades)
    mov     eax, baseShootCooldown
    mov     shootCooldown, eax
    inc     dword ptr shotsFired
    
    ; Check bullet level for extra bullets
    ; Level 1 = 1 bullet (center) - already done
    cmp     dword ptr bulletLevel, 2
    jl      check_doubleshot_powerup
    
    ; Level 2+ = 2 bullets (left + right)
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
find_bullet2:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      create_bullet2
    add     rbx, sizeof BULLET
    dec     esi
    jnz     find_bullet2
    jmp     check_doubleshot_powerup
    
create_bullet2:
    mov     eax, playerX
    add     eax, 3
    mov     [rbx].BULLET.posX, eax
    mov     eax, playerY
    mov     [rbx].BULLET.posY, eax
    mov     dword ptr [rbx].BULLET.active, 1
    
    cmp     dword ptr bulletLevel, 3
    jl      check_doubleshot_powerup
    
    ; Level 3+ = 3 bullets
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
find_bullet3:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      create_bullet3
    add     rbx, sizeof BULLET
    dec     esi
    jnz     find_bullet3
    jmp     check_doubleshot_powerup
    
create_bullet3:
    mov     eax, playerX
    add     eax, PLAYER_WIDTH - 3
    mov     [rbx].BULLET.posX, eax
    mov     eax, playerY
    mov     [rbx].BULLET.posY, eax
    mov     dword ptr [rbx].BULLET.active, 1
    
    cmp     dword ptr bulletLevel, 4
    jl      check_doubleshot_powerup
    
    ; Level 4 = 4 bullets (diagonal shots)
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
find_bullet4:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      create_bullet4
    add     rbx, sizeof BULLET
    dec     esi
    jnz     find_bullet4
    jmp     check_doubleshot_powerup
    
create_bullet4:
    mov     eax, playerX
    add     eax, PLAYER_WIDTH / 2
    mov     [rbx].BULLET.posX, eax
    mov     eax, playerY
    sub     eax, 10
    mov     [rbx].BULLET.posY, eax
    mov     dword ptr [rbx].BULLET.active, 1
    
check_doubleshot_powerup:
    ; Also check hasDoubleShot power-up for extra spread
    cmp     dword ptr hasDoubleShot, 0
    je      update_bullets
    
    ; Create 2 extra diagonal bullets
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
find_spread1:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      create_spread1
    add     rbx, sizeof BULLET
    dec     esi
    jnz     find_spread1
    jmp     update_bullets
    
create_spread1:
    mov     eax, playerX
    mov     [rbx].BULLET.posX, eax
    mov     eax, playerY
    mov     [rbx].BULLET.posY, eax
    mov     dword ptr [rbx].BULLET.active, 1
    
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
find_spread2:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      create_spread2
    add     rbx, sizeof BULLET
    dec     esi
    jnz     find_spread2
    jmp     update_bullets
    
create_spread2:
    mov     eax, playerX
    add     eax, PLAYER_WIDTH
    mov     [rbx].BULLET.posX, eax
    mov     eax, playerY
    mov     [rbx].BULLET.posY, eax
    mov     dword ptr [rbx].BULLET.active, 1
    jmp     update_bullets
    
dec_cooldown:
    dec     dword ptr shootCooldown
    
update_bullets:
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
bullet_loop:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      next_bullet
    
    sub     dword ptr [rbx].BULLET.posY, BULLET_SPEED
    cmp     dword ptr [rbx].BULLET.posY, 0
    jg      check_hit
    mov     dword ptr [rbx].BULLET.active, 0
    jmp     next_bullet
    
check_hit:
    ; rbx = bullet atual, rdi = enemies, r12d = contador enemies
    lea     rdi, enemies
    mov     r12d, MAX_ENEMIES
hit_loop:
    cmp     dword ptr [rdi].ENEMY.alive, 0
    je      next_enemy_hit
    
    mov     eax, [rbx].BULLET.posX
    cmp     eax, [rdi].ENEMY.posX
    jl      next_enemy_hit
    mov     edx, [rdi].ENEMY.posX
    add     edx, ENEMY_WIDTH
    cmp     eax, edx
    jg      next_enemy_hit
    
    mov     eax, [rbx].BULLET.posY
    cmp     eax, [rdi].ENEMY.posY
    jl      next_enemy_hit
    mov     edx, [rdi].ENEMY.posY
    add     edx, ENEMY_HEIGHT
    cmp     eax, edx
    jg      next_enemy_hit
    
    ; hit!
    mov     dword ptr [rdi].ENEMY.alive, 0
    mov     dword ptr [rbx].BULLET.active, 0
    
    ; Combo system - increase combo and reset timer
    inc     dword ptr comboCount
    mov     dword ptr comboTimer, COMBO_TIME
    
    ; Score with combo multiplier
    mov     eax, comboCount
    cmp     eax, MAX_COMBO
    jle     combo_ok
    mov     eax, MAX_COMBO
combo_ok:
    imul    eax, 100           ; base score * combo
    add     score, eax
    
    ; Stats
    inc     dword ptr shotsHit
    inc     dword ptr totalKills
    inc     dword ptr enemiesKilled
    
    ; Create explosion with particles
    mov     ecx, [rdi].ENEMY.posX
    add     ecx, ENEMY_WIDTH / 2
    mov     edx, [rdi].ENEMY.posY
    add     edx, ENEMY_HEIGHT / 2
    push    rcx
    push    rdx
    call    CreateExplosion
    pop     rdx
    pop     rcx
    mov     r8d, 8              ; particle count
    mov     r9d, 0              ; color (red-ish)
    call    SpawnParticles
    
    ; Spawn coin
    mov     ecx, [rdi].ENEMY.posX
    add     ecx, ENEMY_WIDTH / 2
    mov     edx, [rdi].ENEMY.posY
    call    SpawnCoin
    
    ; Spawn powerup chance
    mov     ecx, [rdi].ENEMY.posX
    mov     edx, [rdi].ENEMY.posY
    call    SpawnPowerup
    
    ; Check level up every 500 points
    mov     eax, score
    xor     edx, edx
    mov     r9d, 500
    div     r9d
    inc     eax
    cmp     eax, level
    jle     next_enemy_hit
    mov     level, eax
    ; Increase enemy speed slightly
    cmp     dword ptr enemyBaseSpeed, 8
    jge     skip_speedup
    inc     dword ptr enemyBaseSpeed
skip_speedup:
    ; Decrease spawn delay
    cmp     dword ptr spawnDelay, 15
    jle     next_enemy_hit
    sub     dword ptr spawnDelay, 3
    
next_enemy_hit:
    add     rdi, sizeof ENEMY
    dec     r12d
    jnz     hit_loop
    
next_bullet:
    add     rbx, sizeof BULLET
    dec     esi
    jnz     bullet_loop
    
    ; enemies
    lea     rbx, enemies
    mov     esi, MAX_ENEMIES
enemy_loop:
    cmp     dword ptr [rbx].ENEMY.alive, 0
    je      next_enemy
    
    ; Apply movement based on enemy type
    mov     eax, [rbx].ENEMY.tipo
    cmp     eax, 2
    je      enemy_zigzag
    cmp     eax, 3
    je      enemy_chaser
    jmp     enemy_normal_move
    
enemy_zigzag:
    ; Zig-zag type: oscillate more aggressively
    inc     dword ptr [rbx].ENEMY.animFrame
    mov     eax, [rbx].ENEMY.animFrame
    and     eax, 31
    cmp     eax, 16
    jl      zigzag_left
    mov     dword ptr [rbx].ENEMY.speedX, 4
    jmp     enemy_normal_move
zigzag_left:
    mov     dword ptr [rbx].ENEMY.speedX, -4
    jmp     enemy_normal_move
    
enemy_chaser:
    ; Chaser type: move towards player X position
    mov     eax, playerX
    add     eax, PLAYER_WIDTH / 2
    mov     edx, [rbx].ENEMY.posX
    add     edx, ENEMY_WIDTH / 2
    cmp     eax, edx
    jl      chase_left
    mov     dword ptr [rbx].ENEMY.speedX, 2
    jmp     enemy_normal_move
chase_left:
    mov     dword ptr [rbx].ENEMY.speedX, -2
    
enemy_normal_move:
    mov     eax, [rbx].ENEMY.speedX
    add     [rbx].ENEMY.posX, eax
    mov     eax, [rbx].ENEMY.speedY
    add     [rbx].ENEMY.posY, eax
    
    cmp     dword ptr [rbx].ENEMY.posX, 5
    jge     check_right_bnd
    neg     dword ptr [rbx].ENEMY.speedX
    mov     dword ptr [rbx].ENEMY.posX, 5
check_right_bnd:
    cmp     dword ptr [rbx].ENEMY.posX, WINDOW_WIDTH - ENEMY_WIDTH - 5
    jle     check_bot
    neg     dword ptr [rbx].ENEMY.speedX
    mov     dword ptr [rbx].ENEMY.posX, WINDOW_WIDTH - ENEMY_WIDTH - 5
    
check_bot:
    cmp     dword ptr [rbx].ENEMY.posY, WINDOW_HEIGHT
    jl      check_player
    mov     dword ptr [rbx].ENEMY.alive, 0
    jmp     next_enemy
    
check_player:
    mov     eax, [rbx].ENEMY.posX
    add     eax, ENEMY_WIDTH
    cmp     eax, playerX
    jl      next_enemy
    
    mov     eax, [rbx].ENEMY.posX
    mov     edx, playerX
    add     edx, PLAYER_WIDTH
    cmp     eax, edx
    jg      next_enemy
    
    mov     eax, [rbx].ENEMY.posY
    add     eax, ENEMY_HEIGHT
    cmp     eax, playerY
    jl      next_enemy
    
    mov     eax, [rbx].ENEMY.posY
    mov     edx, playerY
    add     edx, PLAYER_HEIGHT
    cmp     eax, edx
    jg      next_enemy
    
    ; Player hit by enemy!
    mov     dword ptr [rbx].ENEMY.alive, 0
    call    PlayerHit
    
next_enemy:
    add     rbx, sizeof ENEMY
    dec     esi
    jnz     enemy_loop
    
    ; Enemy shooting logic
    inc     dword ptr enemyShootTimer
    cmp     dword ptr enemyShootTimer, 45      ; shoot every ~45 frames
    jl      update_enemy_bullets
    mov     dword ptr enemyShootTimer, 0
    
    ; Pick a random enemy to shoot
    lea     rbx, enemies
    mov     esi, MAX_ENEMIES
    mov     dword ptr randMax, MAX_ENEMIES
    call    Random
    mov     edi, eax                            ; random enemy index
    
find_shooter:
    cmp     edi, 0
    jle     try_shoot
    add     rbx, sizeof ENEMY
    dec     edi
    dec     esi
    jnz     find_shooter
    jmp     update_enemy_bullets
    
try_shoot:
    ; Check if this enemy is alive and on screen
    cmp     dword ptr [rbx].ENEMY.alive, 0
    je      update_enemy_bullets
    cmp     dword ptr [rbx].ENEMY.posY, 50      ; Only shoot if visible on screen
    jl      update_enemy_bullets
    
    ; Find a free enemy bullet slot
    lea     rdi, enemyBullets
    mov     r12d, MAX_ENEMY_BULLETS
find_enemy_bullet_slot:
    cmp     dword ptr [rdi].ENEMY_BULLET.active, 0
    je      create_enemy_bullet
    add     rdi, sizeof ENEMY_BULLET
    dec     r12d
    jnz     find_enemy_bullet_slot
    jmp     update_enemy_bullets
    
create_enemy_bullet:
    mov     eax, [rbx].ENEMY.posX
    add     eax, ENEMY_WIDTH / 2
    mov     [rdi].ENEMY_BULLET.posX, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, ENEMY_HEIGHT
    mov     [rdi].ENEMY_BULLET.posY, eax
    mov     dword ptr [rdi].ENEMY_BULLET.active, 1
    
update_enemy_bullets:
    ; Update enemy bullets
    lea     rbx, enemyBullets
    mov     esi, MAX_ENEMY_BULLETS
enemy_bullet_loop:
    cmp     dword ptr [rbx].ENEMY_BULLET.active, 0
    je      next_enemy_bullet
    
    ; Move bullet down
    add     dword ptr [rbx].ENEMY_BULLET.posY, ENEMY_BULLET_SPEED
    
    ; Check if off screen
    cmp     dword ptr [rbx].ENEMY_BULLET.posY, WINDOW_HEIGHT
    jl      check_enemy_bullet_hit
    mov     dword ptr [rbx].ENEMY_BULLET.active, 0
    jmp     next_enemy_bullet
    
check_enemy_bullet_hit:
    ; Check collision with player
    mov     eax, [rbx].ENEMY_BULLET.posX
    cmp     eax, playerX
    jl      next_enemy_bullet
    mov     edx, playerX
    add     edx, PLAYER_WIDTH
    cmp     eax, edx
    jg      next_enemy_bullet
    
    mov     eax, [rbx].ENEMY_BULLET.posY
    cmp     eax, playerY
    jl      next_enemy_bullet
    mov     edx, playerY
    add     edx, PLAYER_HEIGHT
    cmp     eax, edx
    jg      next_enemy_bullet
    
    ; Hit player!
    mov     dword ptr [rbx].ENEMY_BULLET.active, 0
    call    PlayerHit
    
next_enemy_bullet:
    add     rbx, sizeof ENEMY_BULLET
    dec     esi
    jnz     enemy_bullet_loop
    
    ; Update powerups
    lea     rbx, powerups
    mov     esi, MAX_POWERUPS
powerup_loop:
    cmp     dword ptr [rbx].POWERUP.active, 0
    je      next_powerup
    
    ; Move powerup down
    add     dword ptr [rbx].POWERUP.posY, POWERUP_SPEED
    
    ; Check if off screen
    cmp     dword ptr [rbx].POWERUP.posY, WINDOW_HEIGHT
    jl      check_powerup_collect
    mov     dword ptr [rbx].POWERUP.active, 0
    jmp     next_powerup
    
check_powerup_collect:
    ; Check collision with player
    mov     eax, [rbx].POWERUP.posX
    cmp     eax, playerX
    jl      next_powerup
    mov     edx, playerX
    add     edx, PLAYER_WIDTH
    cmp     eax, edx
    jg      next_powerup
    
    mov     eax, [rbx].POWERUP.posY
    cmp     eax, playerY
    jl      next_powerup
    mov     edx, playerY
    add     edx, PLAYER_HEIGHT
    cmp     eax, edx
    jg      next_powerup
    
    ; Collected!
    mov     dword ptr [rbx].POWERUP.active, 0
    
    ; Apply powerup based on type
    mov     eax, [rbx].POWERUP.tipo
    cmp     eax, POWERUP_DOUBLE
    je      apply_double
    cmp     eax, POWERUP_SHIELD
    je      apply_shield
    cmp     eax, POWERUP_SPEED_BOOST
    je      apply_speed
    cmp     eax, POWERUP_LIFE
    je      apply_life
    jmp     next_powerup
    
apply_double:
    mov     dword ptr hasDoubleShot, 1
    mov     dword ptr doubleTimer, 600      ; ~10 seconds
    jmp     next_powerup
    
apply_shield:
    mov     dword ptr hasShield, 1
    mov     dword ptr shieldTimer, 480      ; ~8 seconds
    jmp     next_powerup
    
apply_speed:
    mov     dword ptr hasSpeedBoost, 1
    mov     dword ptr speedTimer, 480
    ; Speed boost adds 4 to current speed (including upgrades)
    mov     eax, PLAYER_SPEED
    add     eax, upgradeSpeed
    add     eax, 4
    mov     playerSpeed, eax
    jmp     next_powerup
    
apply_life:
    cmp     dword ptr lives, MAX_LIVES
    jge     next_powerup
    inc     dword ptr lives
    
next_powerup:
    add     rbx, sizeof POWERUP
    dec     esi
    jnz     powerup_loop
    
    ; Check for boss spawn (every 3rd wave)
    mov     eax, wave
    xor     edx, edx
    mov     ecx, 3
    div     ecx
    cmp     edx, 0
    jne     no_boss_check
    cmp     dword ptr bossActive, 0
    jne     update_boss
    ; Check if all wave enemies killed
    mov     eax, enemiesKilled
    cmp     eax, enemiesInWave
    jl      no_boss_check
    call    SpawnBoss
    jmp     update_boss
    
no_boss_check:
    ; spawn timer
    inc     dword ptr spawnTimer
    mov     eax, spawnTimer
    cmp     eax, spawnDelay
    jl      check_wave_complete
    mov     dword ptr spawnTimer, 0
    call    SpawnEnemy
    jmp     check_wave_complete
    
update_boss:
    cmp     dword ptr theBoss.alive, 0
    je      boss_dead
    
    ; Move boss
    mov     eax, theBoss.speedX
    add     theBoss.posX, eax
    
    ; Move boss down slowly at start
    cmp     dword ptr theBoss.posY, 50
    jge     boss_at_position
    inc     dword ptr theBoss.posY
    
boss_at_position:
    ; Bounce at edges
    cmp     dword ptr theBoss.posX, 10
    jge     check_boss_right
    neg     dword ptr theBoss.speedX
    mov     dword ptr theBoss.posX, 10
check_boss_right:
    cmp     dword ptr theBoss.posX, WINDOW_WIDTH - BOSS_WIDTH - 10
    jle     boss_shoot
    neg     dword ptr theBoss.speedX
    mov     dword ptr theBoss.posX, WINDOW_WIDTH - BOSS_WIDTH - 10
    
boss_shoot:
    inc     dword ptr theBoss.shootTimer
    cmp     dword ptr theBoss.shootTimer, 20
    jl      check_boss_hit
    mov     dword ptr theBoss.shootTimer, 0
    
    ; Boss shoots 3 bullets
    lea     rdi, enemyBullets
    mov     r12d, MAX_ENEMY_BULLETS
find_boss_bullet:
    cmp     dword ptr [rdi].ENEMY_BULLET.active, 0
    je      create_boss_bullet
    add     rdi, sizeof ENEMY_BULLET
    dec     r12d
    jnz     find_boss_bullet
    jmp     check_boss_hit
    
create_boss_bullet:
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH / 2
    mov     [rdi].ENEMY_BULLET.posX, eax
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT
    mov     [rdi].ENEMY_BULLET.posY, eax
    mov     dword ptr [rdi].ENEMY_BULLET.active, 1
    
check_boss_hit:
    ; Check if player bullets hit boss
    lea     rdi, bullets
    mov     r12d, MAX_BULLETS
boss_hit_loop:
    cmp     dword ptr [rdi].BULLET.active, 0
    je      next_boss_bullet
    
    mov     eax, [rdi].BULLET.posX
    cmp     eax, theBoss.posX
    jl      next_boss_bullet
    mov     edx, theBoss.posX
    add     edx, BOSS_WIDTH
    cmp     eax, edx
    jg      next_boss_bullet
    
    mov     eax, [rdi].BULLET.posY
    cmp     eax, theBoss.posY
    jl      next_boss_bullet
    mov     edx, theBoss.posY
    add     edx, BOSS_HEIGHT
    cmp     eax, edx
    jg      next_boss_bullet
    
    ; Hit boss!
    mov     dword ptr [rdi].BULLET.active, 0
    dec     dword ptr theBoss.hp
    add     dword ptr score, 50
    
    ; Check if boss dead
    cmp     dword ptr theBoss.hp, 0
    jg      next_boss_bullet
    
    ; Boss killed!
    mov     dword ptr theBoss.alive, 0
    mov     dword ptr bossActive, 0
    add     dword ptr score, 1000
    
    ; Boss explosion
    mov     ecx, theBoss.posX
    add     ecx, BOSS_WIDTH / 2
    mov     edx, theBoss.posY
    add     edx, BOSS_HEIGHT / 2
    call    CreateExplosion
    
next_boss_bullet:
    add     rdi, sizeof BULLET
    dec     r12d
    jnz     boss_hit_loop
    
    ; Check boss collision with player
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH
    cmp     eax, playerX
    jl      check_wave_complete
    
    mov     eax, theBoss.posX
    mov     edx, playerX
    add     edx, PLAYER_WIDTH
    cmp     eax, edx
    jg      check_wave_complete
    
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT
    cmp     eax, playerY
    jl      check_wave_complete
    
    mov     eax, theBoss.posY
    mov     edx, playerY
    add     edx, PLAYER_HEIGHT
    cmp     eax, edx
    jg      check_wave_complete
    
    call    PlayerHit
    jmp     check_wave_complete
    
boss_dead:
    mov     dword ptr bossActive, 0
    
check_wave_complete:
    ; Check if wave is complete (for non-boss waves)
    cmp     dword ptr bossActive, 1
    je      update_done
    mov     eax, enemiesKilled
    cmp     eax, enemiesInWave
    jl      update_done
    
    ; Wave complete! Check if upgrade screen should appear (every 5 waves)
    mov     eax, wave
    inc     eax                 ; Next wave number
    xor     edx, edx
    mov     ecx, 5
    div     ecx
    cmp     edx, 0              ; If wave divisible by 5, show upgrade
    jne     skip_upgrade_screen
    
    ; Show upgrade screen
    mov     dword ptr gameState, STATE_UPGRADE
    mov     dword ptr upgradeSelection, 0
    mov     dword ptr upgradeCooldown, 30  ; Small delay before input
    jmp     update_done
    
skip_upgrade_screen:
    ; Just advance to next wave without upgrade screen
    inc     dword ptr wave
    mov     dword ptr enemiesKilled, 0
    add     dword ptr enemiesInWave, 3
    
update_done:
    add     rsp, 28h
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    ret
UpdateGame endp

; -------------------------------------------------
; DrawGame (versão sem r13/r14, só voláteis)
; -------------------------------------------------

DrawGame proc
    push    rbx
    push    rsi
    push    rdi
    push    r12
    sub     rsp, 48h
    mov     currentHdc, rcx
    
    ; Background
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 0
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, WINDOW_HEIGHT
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushDarkBlue
    call    FillRect
    
    ; Stars (always draw)
    lea     rbx, stars
    mov     esi, MAX_STARS
draw_star_lp:
    mov     eax, [rbx].STAR.posX
    mov     rect.left, eax
    mov     eax, [rbx].STAR.posY
    mov     rect.top, eax
    mov     eax, [rbx].STAR.posX
    add     eax, 2
    mov     rect.right, eax
    mov     eax, [rbx].STAR.posY
    add     eax, 2
    mov     rect.bottom, eax
    
    mov     eax, [rbx].STAR.brightness
    cmp     eax, 0
    je      star_dim
    cmp     eax, 1
    je      star_med
    mov     r8, hBrushWhite
    jmp     draw_st
star_dim:
    mov     r8, hBrushDimStar
    jmp     draw_st
star_med:
    mov     r8, hBrushMedStar
draw_st:
    mov     rcx, currentHdc
    lea     rdx, rect
    call    FillRect
    
    add     rbx, sizeof STAR
    dec     esi
    jnz     draw_star_lp
    
    ; Check state - draw menu or game
    cmp     dword ptr gameState, STATE_MENU
    je      draw_menu
    cmp     dword ptr gameState, STATE_GAMEOVER
    je      draw_gameover
    cmp     dword ptr gameState, STATE_UPGRADE
    je      draw_upgrade
    jmp     draw_gameplay
    
draw_upgrade:
    ; Set transparent background for text
    mov     rcx, currentHdc
    mov     edx, TRANSPARENT_BG
    call    SetBkMode
    
    ; Select title font
    mov     rcx, currentHdc
    mov     rdx, hFontTitle
    call    SelectObject
    mov     r12, rax            ; Save old font
    
    ; Set text color to green for title
    mov     rcx, currentHdc
    mov     edx, 0000FF00h      ; Green
    call    SetTextColor
    
    ; Draw "UPGRADES"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 80
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 130
    mov     rcx, currentHdc
    lea     rdx, szUpgradeTitle
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Show coins - format and draw
    mov     rcx, currentHdc
    mov     edx, 00FFFFFFh      ; White
    call    SetTextColor
    
    mov     rcx, currentHdc
    mov     rdx, hFontButton
    call    SelectObject
    
    lea     rcx, waveBuffer
    lea     rdx, szCoinsFmt
    mov     r8d, coins
    call    wsprintfA
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 150
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 180
    mov     rcx, currentHdc
    lea     rdx, waveBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Select small font for options
    mov     rcx, currentHdc
    mov     rdx, hFontSmall
    call    SelectObject
    
    ; Draw option 1 - Speed (cost 5)
    mov     rcx, currentHdc
    mov     edx, 0080FFFFh      ; Cyan
    call    SetTextColor
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 220
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 250
    mov     rcx, currentHdc
    lea     rdx, szUpgradeSpeed
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Draw option 2 - Fire rate (cost 5)
    mov     rcx, currentHdc
    mov     edx, 0080FF80h      ; Light green
    call    SetTextColor
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 260
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 290
    mov     rcx, currentHdc
    lea     rdx, szUpgradeRate
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Draw option 3 - Bullets (cost 8)
    mov     rcx, currentHdc
    mov     edx, 00FF8080h      ; Light red
    call    SetTextColor
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 300
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 330
    mov     rcx, currentHdc
    lea     rdx, szUpgradeBullet
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Draw hint
    mov     rcx, currentHdc
    mov     edx, 00808080h      ; Gray
    call    SetTextColor
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 380
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 410
    mov     rcx, currentHdc
    lea     rdx, szUpgradeCont
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Restore old font
    mov     rcx, currentHdc
    mov     rdx, r12
    call    SelectObject
    
    jmp     draw_end
    
draw_menu:
    ; Set transparent background for text
    mov     rcx, currentHdc
    mov     edx, TRANSPARENT_BG
    call    SetBkMode
    
    ; Set text color to cyan for title
    mov     rcx, currentHdc
    mov     edx, 00FFFF00h      ; Cyan
    call    SetTextColor
    
    ; Select title font
    mov     rcx, currentHdc
    mov     rdx, hFontTitle
    call    SelectObject
    mov     r12, rax            ; Save old font
    
    ; Draw "SPACE SHOOTER"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 120
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 200
    mov     rcx, currentHdc
    lea     rdx, szGameTitle
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Set text color to yellow for "DELUXE"
    mov     rcx, currentHdc
    mov     edx, 0000FFFFh      ; Yellow
    call    SetTextColor
    
    ; Select subtitle font
    mov     rcx, currentHdc
    mov     rdx, hFontSubtitle
    call    SelectObject
    
    ; Draw "DELUXE"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 190
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 250
    mov     rcx, currentHdc
    lea     rdx, szDeluxe
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Set text color to white for button
    mov     rcx, currentHdc
    mov     edx, 00FFFFFFh      ; White
    call    SetTextColor
    
    ; Select button font
    mov     rcx, currentHdc
    mov     rdx, hFontButton
    call    SelectObject
    
    ; Draw "[ INICIAR JOGO ]"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 350
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 400
    mov     rcx, currentHdc
    lea     rdx, szStartBtn
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Set text color to gray for hint
    mov     rcx, currentHdc
    mov     edx, 00A0A0A0h      ; Gray
    call    SetTextColor
    
    ; Select small font
    mov     rcx, currentHdc
    mov     rdx, hFontSmall
    call    SelectObject
    
    ; Draw "Pressione ENTER para iniciar"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 400
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 430
    mov     rcx, currentHdc
    lea     rdx, szPressEnter
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Draw controls info
    mov     rcx, currentHdc
    mov     edx, 00808080h      ; Dark gray
    call    SetTextColor
    
    ; Line 1
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 480
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 500
    mov     rcx, currentHdc
    lea     rdx, szControls1
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Line 2
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 500
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 520
    mov     rcx, currentHdc
    lea     rdx, szControls2
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Line 3
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 520
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 540
    mov     rcx, currentHdc
    lea     rdx, szControls3
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Draw high score on menu
    mov     rcx, currentHdc
    mov     edx, 0000FF00h      ; Green
    call    SetTextColor
    
    lea     rcx, scoreBuffer
    lea     rdx, szHighScoreFmt
    mov     r8d, highScore
    call    wsprintfA
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 280
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 310
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Restore old font
    mov     rcx, currentHdc
    mov     rdx, r12
    call    SelectObject
    
    jmp     draw_end
    
draw_gameover:
    ; Set transparent background for text
    mov     rcx, currentHdc
    mov     edx, TRANSPARENT_BG
    call    SetBkMode
    
    ; Set text color to red for GAME OVER
    mov     rcx, currentHdc
    mov     edx, 000000FFh      ; Red
    call    SetTextColor
    
    ; Select title font
    mov     rcx, currentHdc
    mov     rdx, hFontTitle
    call    SelectObject
    mov     r12, rax            ; Save old font
    
    ; Draw "GAME OVER"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 180
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 260
    mov     rcx, currentHdc
    lea     rdx, szGameOver
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Set text color to yellow for score
    mov     rcx, currentHdc
    mov     edx, 0000FFFFh      ; Yellow
    call    SetTextColor
    
    ; Select button font for score
    mov     rcx, currentHdc
    mov     rdx, hFontButton
    call    SelectObject
    
    ; Format score string
    lea     rcx, scoreBuffer
    lea     rdx, szScoreFmt
    mov     r8d, score
    call    wsprintfA
    
    ; Draw score
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 280
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 330
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Set text color to gray for hint
    mov     rcx, currentHdc
    mov     edx, 00A0A0A0h      ; Gray
    call    SetTextColor
    
    ; Select small font
    mov     rcx, currentHdc
    mov     rdx, hFontSmall
    call    SelectObject
    
    ; Draw "Pressione ENTER para voltar ao menu"
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 380
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 420
    mov     rcx, currentHdc
    lea     rdx, szPressRestart
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Draw high score and new record indicator
    mov     rcx, currentHdc
    mov     edx, 0000FF00h      ; Green
    call    SetTextColor
    
    lea     rcx, scoreBuffer
    lea     rdx, szHighScoreFmt
    mov     r8d, highScore
    call    wsprintfA
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 340
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 370
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
    ; Check if new record
    mov     eax, score
    cmp     eax, highScore
    jle     no_new_record
    
    ; New record! Draw message in yellow
    mov     rcx, currentHdc
    mov     edx, 0000FFFFh      ; Yellow
    call    SetTextColor
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 250
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 280
    mov     rcx, currentHdc
    lea     rdx, szNewRecord
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
no_new_record:
    ; Draw stats
    mov     rcx, currentHdc
    mov     edx, 00808080h      ; Gray
    call    SetTextColor
    
    ; Calculate accuracy
    mov     eax, shotsFired
    cmp     eax, 0
    je      skip_stats
    
    mov     eax, shotsHit
    imul    eax, 100
    xor     edx, edx
    mov     ecx, shotsFired
    div     ecx                 ; eax = accuracy %
    mov     r9d, eax            ; save accuracy
    
    lea     rcx, scoreBuffer
    lea     rdx, szStatsFmt
    mov     r8d, totalKills
    ; r9d already has accuracy
    call    wsprintfA
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, 430
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, 460
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE
    call    DrawTextA
    
skip_stats:
    ; Restore old font
    mov     rcx, currentHdc
    mov     rdx, r12
    call    SelectObject
    
    jmp     draw_end
    
draw_gameplay:
    lea     rbx, bullets
    mov     esi, MAX_BULLETS
draw_blt_lp:
    cmp     dword ptr [rbx].BULLET.active, 0
    je      skip_blt_draw
    
    mov     eax, [rbx].BULLET.posX
    mov     rect.left, eax
    mov     eax, [rbx].BULLET.posY
    mov     rect.top, eax
    mov     eax, [rbx].BULLET.posX
    add     eax, BULLET_WIDTH
    mov     rect.right, eax
    mov     eax, [rbx].BULLET.posY
    add     eax, BULLET_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
skip_blt_draw:
    add     rbx, sizeof BULLET
    dec     esi
    jnz     draw_blt_lp
    
    ; Enemy Bullets (red/orange color)
    lea     rbx, enemyBullets
    mov     esi, MAX_ENEMY_BULLETS
draw_enm_blt_lp:
    cmp     dword ptr [rbx].ENEMY_BULLET.active, 0
    je      skip_enm_blt_draw
    
    mov     eax, [rbx].ENEMY_BULLET.posX
    mov     rect.left, eax
    mov     eax, [rbx].ENEMY_BULLET.posY
    mov     rect.top, eax
    mov     eax, [rbx].ENEMY_BULLET.posX
    add     eax, ENEMY_BULLET_WIDTH
    mov     rect.right, eax
    mov     eax, [rbx].ENEMY_BULLET.posY
    add     eax, ENEMY_BULLET_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushRed
    call    FillRect
    
skip_enm_blt_draw:
    add     rbx, sizeof ENEMY_BULLET
    dec     esi
    jnz     draw_enm_blt_lp
    
    ; Enemies
    lea     rbx, enemies
    mov     esi, MAX_ENEMIES
draw_enm_lp:
    cmp     dword ptr [rbx].ENEMY.alive, 0
    je      skip_enm_draw
    
    ; escolher cor em rdi (preservado)
    mov     eax, [rbx].ENEMY.tipo
    cmp     eax, 0
    je      en_red
    cmp     eax, 1
    je      en_ora
    cmp     eax, 2
    je      en_pur
    mov     rdi, hBrushPink
    jmp     draw_en_body
en_red:
    mov     rdi, hBrushRed
    jmp     draw_en_body
en_ora:
    mov     rdi, hBrushOrange
    jmp     draw_en_body
en_pur:
    mov     rdi, hBrushPurple
    
draw_en_body:
    ; Body
    mov     eax, [rbx].ENEMY.posX
    add     eax, 4
    mov     rect.left, eax
    mov     eax, [rbx].ENEMY.posY
    mov     rect.top, eax
    mov     eax, [rbx].ENEMY.posX
    add     eax, 24
    mov     rect.right, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 14
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, rdi
    call    FillRect
    
    ; Left wing
    mov     eax, [rbx].ENEMY.posX
    mov     rect.left, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 6
    mov     rect.top, eax
    mov     eax, [rbx].ENEMY.posX
    add     eax, 8
    mov     rect.right, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, ENEMY_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, rdi
    call    FillRect
    
    ; Right wing
    mov     eax, [rbx].ENEMY.posX
    add     eax, 20
    mov     rect.left, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 6
    mov     rect.top, eax
    mov     eax, [rbx].ENEMY.posX
    add     eax, ENEMY_WIDTH
    mov     rect.right, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, ENEMY_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, rdi
    call    FillRect
    
    ; Eyes
    mov     eax, [rbx].ENEMY.posX
    add     eax, 8
    mov     rect.left, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 3
    mov     rect.top, eax
    mov     eax, [rbx].ENEMY.posX
    add     eax, 12
    mov     rect.right, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 7
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
    mov     eax, [rbx].ENEMY.posX
    add     eax, 16
    mov     rect.left, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 3
    mov     rect.top, eax
    mov     eax, [rbx].ENEMY.posX
    add     eax, 20
    mov     rect.right, eax
    mov     eax, [rbx].ENEMY.posY
    add     eax, 7
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
skip_enm_draw:
    add     rbx, sizeof ENEMY
    dec     esi
    jnz     draw_enm_lp
    
    ; Player
    cmp     dword ptr gameOver, 1
    je      draw_end
    
    ; Body
    mov     eax, playerX
    add     eax, 8
    mov     rect.left, eax
    mov     eax, playerY
    add     eax, 8
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, 24
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    
    ; Cockpit
    mov     eax, playerX
    add     eax, 12
    mov     rect.left, eax
    mov     eax, playerY
    add     eax, 4
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, 20
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, 12
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushWhite
    call    FillRect
    
    ; Left wing
    mov     eax, playerX
    mov     rect.left, eax
    mov     eax, playerY
    add     eax, 14
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, 10
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushWing
    call    FillRect
    
    ; Right wing
    mov     eax, playerX
    add     eax, 22
    mov     rect.left, eax
    mov     eax, playerY
    add     eax, 14
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, PLAYER_WIDTH
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushWing
    call    FillRect
    
    ; Nose
    mov     eax, playerX
    add     eax, 14
    mov     rect.left, eax
    mov     eax, playerY
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, 18
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
    ; Draw HUD - Score
    mov     rcx, currentHdc
    mov     edx, TRANSPARENT_BG
    call    SetBkMode
    
    mov     rcx, currentHdc
    mov     edx, 00FFFFFFh      ; White
    call    SetTextColor
    
    mov     rcx, currentHdc
    mov     rdx, hFontSmall
    call    SelectObject
    
    ; Format score string
    lea     rcx, scoreBuffer
    lea     rdx, szScoreFmt
    mov     r8d, score
    call    wsprintfA
    
    ; Draw score at top left
    mov     dword ptr rect.left, 10
    mov     dword ptr rect.top, 10
    mov     dword ptr rect.right, 200
    mov     dword ptr rect.bottom, 35
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], 0      ; DT_LEFT
    call    DrawTextA
    
    ; Draw lives at top right
    lea     rcx, scoreBuffer
    lea     rdx, szLivesFmt
    mov     r8d, lives
    call    wsprintfA
    
    mov     dword ptr rect.left, WINDOW_WIDTH - 120
    mov     dword ptr rect.top, 10
    mov     dword ptr rect.right, WINDOW_WIDTH - 10
    mov     dword ptr rect.bottom, 35
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], 0      ; DT_LEFT
    call    DrawTextA
    
    ; Draw wave number
    lea     rcx, scoreBuffer
    lea     rdx, szWaveFmt
    mov     r8d, wave
    call    wsprintfA
    
    mov     dword ptr rect.left, WINDOW_WIDTH / 2 - 50
    mov     dword ptr rect.top, 10
    mov     dword ptr rect.right, WINDOW_WIDTH / 2 + 50
    mov     dword ptr rect.bottom, 35
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER
    call    DrawTextA
    
    ; Draw bombs at bottom left
    mov     rcx, currentHdc
    mov     edx, 00FF8000h      ; Orange
    call    SetTextColor
    
    lea     rcx, scoreBuffer
    lea     rdx, szBombFmt
    mov     r8d, bombCount
    call    wsprintfA
    
    mov     dword ptr rect.left, 10
    mov     dword ptr rect.top, WINDOW_HEIGHT - 30
    mov     dword ptr rect.right, 120
    mov     dword ptr rect.bottom, WINDOW_HEIGHT - 10
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], 0
    call    DrawTextA
    
    ; Draw coins at bottom right
    mov     rcx, currentHdc
    mov     edx, 0000FFFFh      ; Yellow
    call    SetTextColor
    
    lea     rcx, scoreBuffer
    lea     rdx, szCoinsFmt
    mov     r8d, coins
    call    wsprintfA
    
    mov     dword ptr rect.left, WINDOW_WIDTH - 120
    mov     dword ptr rect.top, WINDOW_HEIGHT - 30
    mov     dword ptr rect.right, WINDOW_WIDTH - 10
    mov     dword ptr rect.bottom, WINDOW_HEIGHT - 10
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], 0
    call    DrawTextA
    
    ; Draw combo if active
    cmp     dword ptr comboCount, 1
    jle     skip_combo_draw
    
    mov     rcx, currentHdc
    mov     edx, 0000FF00h      ; Green
    call    SetTextColor
    
    lea     rcx, scoreBuffer
    lea     rdx, szComboFmt
    mov     r8d, comboCount
    call    wsprintfA
    
    mov     dword ptr rect.left, WINDOW_WIDTH / 2 - 60
    mov     dword ptr rect.top, 40
    mov     dword ptr rect.right, WINDOW_WIDTH / 2 + 60
    mov     dword ptr rect.bottom, 65
    mov     rcx, currentHdc
    lea     rdx, scoreBuffer
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER
    call    DrawTextA
    
skip_combo_draw:
    ; Draw explosions
    lea     rbx, explosions
    mov     esi, MAX_EXPLOSIONS
draw_exp_loop:
    cmp     dword ptr [rbx].EXPLOSION.active, 0
    je      skip_exp_draw
    
    ; Calculate explosion size based on frame
    mov     eax, [rbx].EXPLOSION.frameNum
    shl     eax, 2                      ; frame * 4 = radius
    add     eax, 8                      ; base size 8
    mov     r12d, eax                   ; r12 = size
    
    mov     eax, [rbx].EXPLOSION.posX
    sub     eax, r12d
    mov     rect.left, eax
    mov     eax, [rbx].EXPLOSION.posY
    sub     eax, r12d
    mov     rect.top, eax
    mov     eax, [rbx].EXPLOSION.posX
    add     eax, r12d
    mov     rect.right, eax
    mov     eax, [rbx].EXPLOSION.posY
    add     eax, r12d
    mov     rect.bottom, eax
    
    ; Color based on frame (yellow -> orange -> red)
    mov     eax, [rbx].EXPLOSION.frameNum
    cmp     eax, 3
    jl      exp_yellow
    cmp     eax, 6
    jl      exp_orange
    mov     r8, hBrushRed
    jmp     draw_exp_rect
exp_yellow:
    mov     r8, hBrushYellow
    jmp     draw_exp_rect
exp_orange:
    mov     r8, hBrushOrange
    
draw_exp_rect:
    mov     rcx, currentHdc
    lea     rdx, rect
    call    FillRect
    
skip_exp_draw:
    add     rbx, sizeof EXPLOSION
    dec     esi
    jnz     draw_exp_loop
    
    ; Draw powerups with better shapes
    lea     rbx, powerups
    mov     esi, MAX_POWERUPS
draw_pow_loop:
    cmp     dword ptr [rbx].POWERUP.active, 0
    je      skip_pow_draw
    
    ; Check type to draw different shapes
    mov     eax, [rbx].POWERUP.tipo
    cmp     eax, POWERUP_DOUBLE
    je      draw_pow_double
    cmp     eax, POWERUP_SHIELD
    je      draw_pow_shield
    cmp     eax, POWERUP_SPEED_BOOST
    je      draw_pow_speed
    jmp     draw_pow_life
    
draw_pow_double:
    ; Draw double shot as 2 vertical bars (bullets)
    mov     eax, [rbx].POWERUP.posX
    add     eax, 3
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 2
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, 6
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, POWERUP_SIZE - 2
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    ; Second bar
    mov     eax, [rbx].POWERUP.posX
    add     eax, POWERUP_SIZE - 6
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 2
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, POWERUP_SIZE - 3
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, POWERUP_SIZE - 2
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    jmp     skip_pow_draw
    
draw_pow_shield:
    ; Draw shield as circular shape (cross pattern)
    ; Horizontal bar
    mov     eax, [rbx].POWERUP.posX
    add     eax, 2
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 6
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, POWERUP_SIZE - 2
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, POWERUP_SIZE - 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPurple
    call    FillRect
    ; Vertical bar
    mov     eax, [rbx].POWERUP.posX
    add     eax, 6
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 2
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, POWERUP_SIZE - 6
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, POWERUP_SIZE - 2
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPurple
    call    FillRect
    jmp     skip_pow_draw
    
draw_pow_speed:
    ; Draw speed as arrow shape (triangle-ish)
    ; Top arrow
    mov     eax, [rbx].POWERUP.posX
    add     eax, 5
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 2
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, POWERUP_SIZE - 5
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    ; Body
    mov     eax, [rbx].POWERUP.posX
    add     eax, 3
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 6
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, POWERUP_SIZE - 3
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, POWERUP_SIZE - 2
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    jmp     skip_pow_draw
    
draw_pow_life:
    ; Draw life as heart shape (cross + bottom)
    ; Top left
    mov     eax, [rbx].POWERUP.posX
    add     eax, 2
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 3
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, 7
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 8
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPink
    call    FillRect
    ; Top right
    mov     eax, [rbx].POWERUP.posX
    add     eax, 9
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 3
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, 14
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 8
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPink
    call    FillRect
    ; Center/bottom (triangle-ish)
    mov     eax, [rbx].POWERUP.posX
    add     eax, 4
    mov     rect.left, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 7
    mov     rect.top, eax
    mov     eax, [rbx].POWERUP.posX
    add     eax, 12
    mov     rect.right, eax
    mov     eax, [rbx].POWERUP.posY
    add     eax, 14
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPink
    call    FillRect
    
skip_pow_draw:
    add     rbx, sizeof POWERUP
    dec     esi
    jnz     draw_pow_loop
    
    ; Draw boss if active
    cmp     dword ptr bossActive, 0
    je      skip_boss_draw
    cmp     dword ptr theBoss.alive, 0
    je      skip_boss_draw
    
    ; Boss main body (dark red)
    mov     eax, theBoss.posX
    mov     rect.left, eax
    mov     eax, theBoss.posY
    add     eax, 10
    mov     rect.top, eax
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH
    mov     rect.right, eax
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT - 10
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushRed
    call    FillRect
    
    ; Boss top
    mov     eax, theBoss.posX
    add     eax, 20
    mov     rect.left, eax
    mov     eax, theBoss.posY
    mov     rect.top, eax
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH - 20
    mov     rect.right, eax
    mov     eax, theBoss.posY
    add     eax, 15
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushOrange
    call    FillRect
    
    ; Boss bottom (guns)
    mov     eax, theBoss.posX
    mov     rect.left, eax
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT - 5
    mov     rect.top, eax
    mov     eax, theBoss.posX
    add     eax, 15
    mov     rect.right, eax
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPurple
    call    FillRect
    
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH - 15
    mov     rect.left, eax
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT - 5
    mov     rect.top, eax
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH
    mov     rect.right, eax
    mov     eax, theBoss.posY
    add     eax, BOSS_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushPurple
    call    FillRect
    
    ; Boss eyes (yellow)
    mov     eax, theBoss.posX
    add     eax, 25
    mov     rect.left, eax
    mov     eax, theBoss.posY
    add     eax, 15
    mov     rect.top, eax
    mov     eax, theBoss.posX
    add     eax, 35
    mov     rect.right, eax
    mov     eax, theBoss.posY
    add     eax, 25
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH - 35
    mov     rect.left, eax
    mov     eax, theBoss.posY
    add     eax, 15
    mov     rect.top, eax
    mov     eax, theBoss.posX
    add     eax, BOSS_WIDTH - 25
    mov     rect.right, eax
    mov     eax, theBoss.posY
    add     eax, 25
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
skip_boss_draw:
    
    ; Draw particles
    lea     rbx, particles
    mov     esi, MAX_PARTICLES
draw_part_lp:
    cmp     dword ptr [rbx].PARTICLE.life, 0
    jle     skip_part_draw
    
    mov     eax, [rbx].PARTICLE.posX
    mov     rect.left, eax
    mov     eax, [rbx].PARTICLE.posY
    mov     rect.top, eax
    mov     eax, [rbx].PARTICLE.posX
    add     eax, 3
    mov     rect.right, eax
    mov     eax, [rbx].PARTICLE.posY
    add     eax, 3
    mov     rect.bottom, eax
    
    ; Color based on particle type (use life for fade)
    mov     eax, [rbx].PARTICLE.life
    cmp     eax, 15
    jg      part_yellow
    cmp     eax, 8
    jg      part_orange
    mov     r8, hBrushRed
    jmp     draw_part_rect
part_yellow:
    mov     r8, hBrushYellow
    jmp     draw_part_rect
part_orange:
    mov     r8, hBrushOrange
draw_part_rect:
    mov     rcx, currentHdc
    lea     rdx, rect
    call    FillRect
    
skip_part_draw:
    add     rbx, sizeof PARTICLE
    dec     esi
    jnz     draw_part_lp
    
    ; Draw coins with better coin shape
    lea     rbx, coinItems
    mov     esi, MAX_COINS
draw_coin_lp:
    cmp     dword ptr [rbx].COIN.active, 0
    je      skip_coin_draw
    
    ; Outer ring (gold/orange)
    mov     eax, [rbx].COIN.posX
    sub     eax, 6
    mov     rect.left, eax
    mov     eax, [rbx].COIN.posY
    sub     eax, 6
    mov     rect.top, eax
    mov     eax, [rbx].COIN.posX
    add     eax, 6
    mov     rect.right, eax
    mov     eax, [rbx].COIN.posY
    add     eax, 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushOrange
    call    FillRect
    
    ; Inner circle (yellow/gold center)
    mov     eax, [rbx].COIN.posX
    sub     eax, 4
    mov     rect.left, eax
    mov     eax, [rbx].COIN.posY
    sub     eax, 4
    mov     rect.top, eax
    mov     eax, [rbx].COIN.posX
    add     eax, 4
    mov     rect.right, eax
    mov     eax, [rbx].COIN.posY
    add     eax, 4
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushYellow
    call    FillRect
    
    ; Shine/highlight (small white square)
    mov     eax, [rbx].COIN.posX
    sub     eax, 2
    mov     rect.left, eax
    mov     eax, [rbx].COIN.posY
    sub     eax, 3
    mov     rect.top, eax
    mov     eax, [rbx].COIN.posX
    mov     rect.right, eax
    mov     eax, [rbx].COIN.posY
    sub     eax, 1
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushWhite
    call    FillRect
    
skip_coin_draw:
    add     rbx, sizeof COIN
    dec     esi
    jnz     draw_coin_lp
    
    ; Draw shield as animated ring (not solid rectangle)
    cmp     dword ptr hasShield, 0
    je      skip_shield_draw
    
    ; Draw shield ring - top
    mov     eax, playerX
    sub     eax, 6
    mov     rect.left, eax
    mov     eax, playerY
    sub     eax, 6
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, PLAYER_WIDTH + 6
    mov     rect.right, eax
    mov     eax, playerY
    sub     eax, 3
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    
    ; Shield ring - bottom
    mov     eax, playerX
    sub     eax, 6
    mov     rect.left, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT + 3
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, PLAYER_WIDTH + 6
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT + 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    
    ; Shield ring - left
    mov     eax, playerX
    sub     eax, 6
    mov     rect.left, eax
    mov     eax, playerY
    sub     eax, 6
    mov     rect.top, eax
    mov     eax, playerX
    sub     eax, 3
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT + 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    
    ; Shield ring - right
    mov     eax, playerX
    add     eax, PLAYER_WIDTH + 3
    mov     rect.left, eax
    mov     eax, playerY
    sub     eax, 6
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, PLAYER_WIDTH + 6
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT + 6
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushCyan
    call    FillRect
    
skip_shield_draw:
    
    ; Draw invincibility flash (blink player white when hit)
    cmp     dword ptr invincibleTimer, 0
    je      no_invincible_flash
    
    mov     eax, invincibleTimer
    and     eax, 4                      ; Toggle every 4 frames
    cmp     eax, 0
    je      no_invincible_flash
    
    ; Flash white overlay on player
    mov     eax, playerX
    add     eax, 8
    mov     rect.left, eax
    mov     eax, playerY
    add     eax, 8
    mov     rect.top, eax
    mov     eax, playerX
    add     eax, 24
    mov     rect.right, eax
    mov     eax, playerY
    add     eax, PLAYER_HEIGHT
    mov     rect.bottom, eax
    mov     rcx, currentHdc
    lea     rdx, rect
    mov     r8, hBrushWhite
    call    FillRect
    
no_invincible_flash:
    
    ; Check for pause state
    cmp     dword ptr isPaused, 0
    je      draw_end
    
    ; Draw semi-transparent pause overlay (just draw text)
    mov     rcx, currentHdc
    mov     edx, 0000FFFFh      ; Yellow
    call    SetTextColor
    
    mov     rcx, currentHdc
    mov     rdx, hFontTitle
    call    SelectObject
    
    mov     dword ptr rect.left, 0
    mov     dword ptr rect.top, WINDOW_HEIGHT / 2 - 30
    mov     dword ptr rect.right, WINDOW_WIDTH
    mov     dword ptr rect.bottom, WINDOW_HEIGHT / 2 + 30
    mov     rcx, currentHdc
    lea     rdx, szPaused
    mov     r8d, -1
    lea     r9, rect
    mov     dword ptr [rsp+20h], DT_CENTER or DT_SINGLELINE or DT_VCENTER
    call    DrawTextA
    
draw_end:
    add     rsp, 48h
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    ret
DrawGame endp

; -------------------------------------------------
; WndProc (sem pushes, stack certinho)
; -------------------------------------------------

WndProc proc
    sub     rsp, 28h

    mov     wpHwnd, rcx
    mov     wpMsg, edx
    mov     wpWParam, r8
    mov     wpLParam, r9
    
    cmp     edx, WM_DESTROY
    je      on_destroy
    cmp     edx, WM_TIMER
    je      on_timer
    cmp     edx, WM_PAINT
    je      on_paint
    
    mov     rcx, wpHwnd
    mov     edx, wpMsg
    mov     r8, wpWParam
    mov     r9, wpLParam
    call    DefWindowProcA
    add     rsp, 28h
    ret

on_destroy:
    mov     rcx, wpHwnd
    mov     edx, 1
    call    KillTimer
    xor     ecx, ecx
    call    PostQuitMessage
    xor     eax, eax
    add     rsp, 28h
    ret

on_timer:
    call    UpdateGame
    mov     rcx, wpHwnd
    xor     edx, edx
    xor     r8d, r8d
    call    InvalidateRect
    xor     eax, eax
    add     rsp, 28h
    ret

on_paint:
    mov     rcx, wpHwnd
    lea     rdx, ps
    call    BeginPaint
    mov     r10, rax
    mov     rcx, r10
    call    DrawGame
    mov     rcx, wpHwnd
    lea     rdx, ps
    call    EndPaint
    xor     eax, eax
    add     rsp, 28h
    ret
WndProc endp

; -------------------------------------------------
; main
; -------------------------------------------------

main proc
    sub     rsp, 78h

    ; Debug 1
    xor     ecx, ecx
    lea     rdx, szDbg1
    lea     r8, szCap
    xor     r9d, r9d
    call    MessageBoxA

    xor     ecx, ecx
    call    GetModuleHandleA
    mov     hInstance, rax

    ; WNDCLASS
    mov     dword ptr wc.cbSize, 80
    mov     dword ptr wc.style, CS_HREDRAW or CS_VREDRAW
    lea     rax, WndProc
    mov     wc.lpfnWndProc, rax
    mov     dword ptr wc.cbClsExtra, 0
    mov     dword ptr wc.cbWndExtra, 0
    mov     rax, hInstance
    mov     wc.hInstance, rax
    mov     qword ptr wc.hIcon, 0
    mov     qword ptr wc.hbrBackground, 0
    mov     qword ptr wc.lpszMenuName, 0
    lea     rax, szClassName
    mov     wc.lpszClassName, rax
    mov     qword ptr wc.hIconSm, 0

    xor     ecx, ecx
    mov     edx, IDC_ARROW
    call    LoadCursorA
    mov     wc.hCursor, rax

    lea     rcx, wc
    call    RegisterClassExA
    test    eax, eax
    jz      app_exit

    ; Brushes
    mov     ecx, 00000000h
    call    CreateSolidBrush
    mov     hBrushBlack, rax
    
    mov     ecx, 00201008h
    call    CreateSolidBrush
    mov     hBrushDarkBlue, rax
    
    mov     ecx, 00FFFF00h
    call    CreateSolidBrush
    mov     hBrushCyan, rax
    
    mov     ecx, 000000FFh
    call    CreateSolidBrush
    mov     hBrushRed, rax
    
    mov     ecx, 000080FFh
    call    CreateSolidBrush
    mov     hBrushOrange, rax
    
    mov     ecx, 0000FFFFh
    call    CreateSolidBrush
    mov     hBrushYellow, rax
    
    mov     ecx, 00FFFFFFh
    call    CreateSolidBrush
    mov     hBrushWhite, rax
    
    mov     ecx, 00FF00FFh
    call    CreateSolidBrush
    mov     hBrushPurple, rax
    
    mov     ecx, 008080FFh
    call    CreateSolidBrush
    mov     hBrushPink, rax
    
    mov     ecx, 00404040h
    call    CreateSolidBrush
    mov     hBrushDimStar, rax
    
    mov     ecx, 00808080h
    call    CreateSolidBrush
    mov     hBrushMedStar, rax
    
    mov     ecx, 00998800h
    call    CreateSolidBrush
    mov     hBrushWing, rax

    ; Create fonts
    ; Title font (large, bold)
    mov     ecx, 56                     ; height
    xor     edx, edx                    ; width
    xor     r8d, r8d                    ; escapement
    xor     r9d, r9d                    ; orientation
    mov     dword ptr [rsp+20h], 700    ; weight (bold)
    mov     dword ptr [rsp+28h], 0      ; italic
    mov     dword ptr [rsp+30h], 0      ; underline
    mov     dword ptr [rsp+38h], 0      ; strikeout
    mov     dword ptr [rsp+40h], 0      ; charset
    mov     dword ptr [rsp+48h], 0      ; out precision
    mov     dword ptr [rsp+50h], 0      ; clip precision
    mov     dword ptr [rsp+58h], 0      ; quality
    mov     dword ptr [rsp+60h], 0      ; pitch and family
    mov     qword ptr [rsp+68h], 0      ; face name (NULL = default)
    call    CreateFontA
    mov     hFontTitle, rax
    
    ; Subtitle font (medium, bold)
    mov     ecx, 36                     ; height
    xor     edx, edx                    ; width
    xor     r8d, r8d                    ; escapement
    xor     r9d, r9d                    ; orientation
    mov     dword ptr [rsp+20h], 700    ; weight (bold)
    mov     dword ptr [rsp+28h], 0      ; italic
    mov     dword ptr [rsp+30h], 0      ; underline
    mov     dword ptr [rsp+38h], 0      ; strikeout
    mov     dword ptr [rsp+40h], 0      ; charset
    mov     dword ptr [rsp+48h], 0      ; out precision
    mov     dword ptr [rsp+50h], 0      ; clip precision
    mov     dword ptr [rsp+58h], 0      ; quality
    mov     dword ptr [rsp+60h], 0      ; pitch and family
    mov     qword ptr [rsp+68h], 0      ; face name
    call    CreateFontA
    mov     hFontSubtitle, rax
    
    ; Button font (medium)
    mov     ecx, 28                     ; height
    xor     edx, edx                    ; width
    xor     r8d, r8d                    ; escapement
    xor     r9d, r9d                    ; orientation
    mov     dword ptr [rsp+20h], 400    ; weight (normal)
    mov     dword ptr [rsp+28h], 0      ; italic
    mov     dword ptr [rsp+30h], 0      ; underline
    mov     dword ptr [rsp+38h], 0      ; strikeout
    mov     dword ptr [rsp+40h], 0      ; charset
    mov     dword ptr [rsp+48h], 0      ; out precision
    mov     dword ptr [rsp+50h], 0      ; clip precision
    mov     dword ptr [rsp+58h], 0      ; quality
    mov     dword ptr [rsp+60h], 0      ; pitch and family
    mov     qword ptr [rsp+68h], 0      ; face name
    call    CreateFontA
    mov     hFontButton, rax
    
    ; Small font
    mov     ecx, 18                     ; height
    xor     edx, edx                    ; width
    xor     r8d, r8d                    ; escapement
    xor     r9d, r9d                    ; orientation
    mov     dword ptr [rsp+20h], 400    ; weight (normal)
    mov     dword ptr [rsp+28h], 0      ; italic
    mov     dword ptr [rsp+30h], 0      ; underline
    mov     dword ptr [rsp+38h], 0      ; strikeout
    mov     dword ptr [rsp+40h], 0      ; charset
    mov     dword ptr [rsp+48h], 0      ; out precision
    mov     dword ptr [rsp+50h], 0      ; clip precision
    mov     dword ptr [rsp+58h], 0      ; quality
    mov     dword ptr [rsp+60h], 0      ; pitch and family
    mov     qword ptr [rsp+68h], 0      ; face name
    call    CreateFontA
    mov     hFontSmall, rax

    ; Debug 2
    xor     ecx, ecx
    lea     rdx, szDbg2
    lea     r8, szCap
    xor     r9d, r9d
    call    MessageBoxA

    ; Init game
    call    InitGame
    
    ; Load high score
    call    LoadHighScore

    ; Debug 3
    xor     ecx, ecx
    lea     rdx, szDbg3
    lea     r8, szCap
    xor     r9d, r9d
    call    MessageBoxA

    ; CreateWindowExA args na stack (5+)
    mov     qword ptr [rsp+58h], 0              ; lpParam
    mov     rax, hInstance
    mov     [rsp+50h], rax                      ; hInstance
    mov     qword ptr [rsp+48h], 0              ; hMenu
    mov     qword ptr [rsp+40h], 0              ; hWndParent
    mov     dword ptr [rsp+38h], WINDOW_HEIGHT + 39 ; nHeight
    mov     dword ptr [rsp+30h], WINDOW_WIDTH  + 16 ; nWidth
    mov     dword ptr [rsp+28h], 50             ; Y
    mov     dword ptr [rsp+20h], 200            ; X

    xor     ecx, ecx                             ; dwExStyle
    lea     rdx, szClassName                     ; lpClassName
    lea     r8,  szTitle                         ; lpWindowName
    mov     r9d, WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_VISIBLE
    call    CreateWindowExA

    test    rax, rax
    jz      app_exit
    mov     hWndMain, rax

    ; Debug 4
    xor     ecx, ecx
    lea     rdx, szDbg4
    lea     r8, szCap
    xor     r9d, r9d
    call    MessageBoxA

    ; Timer
    mov     rcx, hWndMain
    mov     edx, 1
    mov     r8d, 16
    xor     r9, r9
    call    SetTimer

    ; Debug 5
    xor     ecx, ecx
    lea     rdx, szDbg5
    lea     r8, szCap
    xor     r9d, r9d
    call    MessageBoxA

; message loop
msg_lp:
    lea     rcx, msgStruct
    xor     edx, edx
    xor     r8d, r8d
    xor     r9d, r9d
    call    GetMessageA
    test    eax, eax
    jle     app_exit

    lea     rcx, msgStruct
    call    TranslateMessage

    lea     rcx, msgStruct
    call    DispatchMessageA
    jmp     msg_lp

app_exit:
    xor     ecx, ecx
    call    ExitProcess
main endp

end
