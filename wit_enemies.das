require daslib/media

require wit_utils
require wit_ui_common
require wit_sound
require wit_graphics

struct Enemy
    id: int
    radius: float
    hp: float
    speedMax: float
    damage: float
    color: uint
    deathColor: uint
    killScoreMul: float
    cooldownTimerForMovement: float
    cooldownTimerForAttack: float
    pos: float2
    alive: bool
    minPlayerLevel: int
    numToSpawn: int
    chanceToSpawn: float
    isFirstSpawned: bool
    ignoreCollision: bool
    anim: Anim2d
    
var private
    enemy_types: array<Enemy>

var
    enemies: array<Enemy>
    firstSpawned: array<bool>
    bind_enemies: bool
    bind_enemies_cheat: bool

let    
    RANDOM_SPEED_PERC = 0.1
    COLOR_ENEMY = 0xFF228B22
    COLOR_ENEMY_PUDDLE = 0xBB228B22
    COLOR_ENEMY_RADIACTIVE = 0xFF05FF05
    COLOR_ENEMY_RADIACTIVE_PUDDLE = 0xBB05FF05
    COLOR_ENEMY_SPIDER = 0xFFFF05DE 
    COLOR_ENEMY_SPIDER_PUDDLE = 0xBBFF05DE           
    COLOR_ENEMY_OGRE = 0xFFCF5A07           
    COLOR_ENEMY_OGRE_PUDDLE = 0xBBCF5A07    


// Enemy methods
def enemies_init()
    clear(enemies)
    clear(puddles)
    clear(enemy_types)

    var e <- [[Enemy id = 1, hp = 1.0, killScoreMul = 1.0, radius=size_to_srcrn(15.0), speedMax=40.0, alive=true,
              damage=5.0, cooldownTimerForMovement = 0.0, cooldownTimerForAttack = 0.0, color = COLOR_ENEMY, deathColor = COLOR_ENEMY_PUDDLE, chanceToSpawn = 1.0]]
    emplace(enemy_types, e)
    e <- [[Enemy id = 2, hp = 5.0, killScoreMul = 2.0, radius=size_to_srcrn(18.0), speedMax=40.0, alive=true,
              damage=15.0, cooldownTimerForMovement = 0.0, cooldownTimerForAttack = 0.0, color = COLOR_ENEMY_RADIACTIVE, deathColor = COLOR_ENEMY_RADIACTIVE_PUDDLE, chanceToSpawn = 0.1]]
    emplace(enemy_types, e)
    e <- [[Enemy id = 3, hp = 1.0, killScoreMul = 2.0, radius=size_to_srcrn(8.0), speedMax=125.0, alive=true,
              damage=3.0, cooldownTimerForMovement = 0.0, cooldownTimerForAttack = 0.0, color = COLOR_ENEMY_SPIDER, deathColor = COLOR_ENEMY_SPIDER_PUDDLE,
              minPlayerLevel = 10, chanceToSpawn = 0.01, numToSpawn = 5, ignoreCollision = true]]
    emplace(enemy_types, e)
    e <- [[Enemy id = 4, hp = 50.0, killScoreMul = 10.0, radius=size_to_srcrn(50.0), speedMax=10.0, alive=true,
              damage=100.0, cooldownTimerForMovement = 0.0, cooldownTimerForAttack = 0.0, color = COLOR_ENEMY_OGRE_PUDDLE, deathColor = COLOR_ENEMY_OGRE,
              minPlayerLevel = 5, chanceToSpawn = 0.02]]
    emplace(enemy_types, e)
    var idx = 0
    while idx < length(enemy_types)
        push(firstSpawned, false)
        idx++

def enemy_add(player_level: int)
    var idx = length(enemy_types) - 1
    while idx >= 0
        var e := enemy_types[idx]
        if (e.minPlayerLevel == player_level && !firstSpawned[idx]) || (player_level > e.minPlayerLevel && e.chanceToSpawn * float(1 + int(player_level / 10)) >= random_float(seed))
            var num = max(e.numToSpawn, 1)
            firstSpawned[idx] = true
            while num > 0
                spawn_enemy(e)
                num--
            break        
        idx--

def spawn_enemy(e: Enemy)        
    var newEnemy := e
    newEnemy.pos = get_enemy_spawn_pos()
    newEnemy.speedMax = newEnemy.speedMax * (1.0 - RANDOM_SPEED_PERC * (1.0 - random_float(seed) * 2.0))
    let sizeMul = e.radius/size_to_srcrn(26.0)
    set_enemy_anim(newEnemy.anim, newEnemy.pos, sizeMul, e.color)
    emplace(enemies, newEnemy)


def enemy_update(var e: Enemy; player_pos: float2; dt: float)
    if bind_enemies || bind_enemies_cheat
        return
    let enemyDir = normalize(player_pos - e.pos)        
    if e.cooldownTimerForMovement <= 0.0
        var eNewPos = enemyDir * e.speedMax * dt
        if !e.ignoreCollision
            for eCol in enemies
                if e.pos == eCol.pos
                    continue
                var enemiesDist = length(e.pos + eNewPos - eCol.pos)
                var eDistPlayer = length(player_pos - e.pos + eNewPos)
                var cColDistPlayer = length(player_pos - eCol.pos)
                if (enemiesDist < max(e.radius, eCol.radius) && eDistPlayer > cColDistPlayer)
                    return
        e.pos += eNewPos
    else
        e.cooldownTimerForMovement -= dt
    e.cooldownTimerForAttack -= dt
    e.anim.pos = e.pos
    e.anim.angle = -atan2(enemyDir.x,enemyDir.y)
    if e.anim.timer > 0.0
        e.anim.timer -= dt
    else
        e.anim.timer = e.anim.speed
        e.anim.curFrameIdx++ 
        if e.anim.curFrameIdx >= length(img_enemies)
            e.anim.curFrameIdx = 0
        e.anim.curFrameImg := img_enemies[e.anim.curFrameIdx]    

def enemy_attack(var e: Enemy; player_pos: float2; player_radius: float)    
    var dmg = 0.0
    if e.cooldownTimerForAttack <= 0.0 && length(e.pos - player_pos) < e.radius + player_radius
        e.cooldownTimerForMovement = 2.0
        e.cooldownTimerForAttack = 2.0
        dmg = e.damage
        snd_zombie_attack_play()
    return dmg


def enemies_render()
    for e in enemies
        draw_enemy(e.anim)

def get_enemy_spawn_pos()
    let scrH = float(get_screen_height())
    let scrW = float(get_screen_width())
    let isSideXConst = sign(random_float(seed) - 0.5) > 0.0
    let isConstSideValMax = sign(random_float(seed) - 0.5) > 0.0
    var spawnPos = float2(0.0,0.0)
    if isSideXConst
        spawnPos = float2(isConstSideValMax ? scrW : 0.0, scrH * random_float(seed))
    else 
        spawnPos = float2(scrW * random_float(seed), isConstSideValMax ? scrH : 0.0)
    return spawnPos


def cleanup_death_enemies()
    var idx = length(enemies) - 1
    while idx >= 0
        if !enemies[idx].alive
            erase(enemies, idx)
        idx--