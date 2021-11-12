require daslib/media

require wit_enemies
require wit_utils
require wit_ui_common
require wit_sound
require wit_graphics

struct Weapon  
    id: int  
    isUnlocked: bool
    name: string
    dmg: float
    ammoMaxCount: int
    ammoCurCount: int
    bulletSpeed: float
    reloadTime: float
    reloadTimer: float
    reloadOneTime: float
    reloadOneTimer: float
    reloading: bool
    reloadingMode: string
    firingMode: string
    rateOfFire: float
    cooldownTimerForAttack: float
    bulletsPerShot: int
    enemyPenetration: bool
    effectiveRange: float
    expDmg: float
    expRadius: float
    reboundOfScreenBorder: bool
    bulletType: string
    startUpTime: float
    startUpTimeMax: float
    shotSpreadAngle: float
    movementSpeedWhenShootingMul: float
    tracerMul: float  
    bulletSize: float
    bulletColor: uint
    maxActiveBullets: int
    maxActiveBulletsIdx: int
    disableLaserSight: bool
    sound: string
    sound_vol: float
    sound_loop: bool
    sound_start: string
    sound_start_vol: float
    sound_start_loop: bool
    sound_end: string
    sound_end_vol: float
    img_idx: int
    bulletStartingPosShift: float2
    fire_fx_timer: float
    fire_fx_timer_max: float
    no_fire_fx: bool
    

struct Bullet
    pos: float2
    speed: float2
    lifeTime: float
    enemyPenetration: bool
    expDmg: float
    expRadius: float
    bulletType: string
    reboundOfScreenBorder: bool
    tracerMul: float   
    size: float 
    dmg:float
    color: uint
    maxActiveBullets: int
    maxActiveBulletsIdx: int
    bulletStartingPosShift: float2

struct Explosion
    pos: float2
    radius: float
    radiusMax: float
    dmg: float
    effectTime: float
    effectTimeMax: float
    anim: Anim2d

struct WeaponHUD
    weapon: string
    ammo: string

var 
    weapons: array<Weapon> 
    weapon: Weapon
    explosions: array<Explosion>
    firstWeaponUnlocked: bool
    bullets: array<Bullet>
    activeBullets: array<int>

let
    EXPLOSION_EFFECT_TIME = 0.584
    COLOR_BULLET = 0xFFFFFFFF
    COLOR_BULLET_RAY = 0xFF00D9FF
    COLOR_DISC = 0xFF000000
    WEAPON_FIRE_FX_TIME_MIN = 0.1
    WEAPON_FIRE_FX_TIME_MAX = 0.5

// weapon methods
def weapon_init()
    clear(weapons)
    clear(explosions)
    clear(bullets)
    all_weapons_set()
    weapon_set(weapon, weapons[0])
    firstWeaponUnlocked = false

def all_weapons_set()
    var w = [[Weapon id = 0, name = "Glock-19", isUnlocked = true, dmg = 1.0, ammoMaxCount = 15, ammoCurCount = 15, bulletSpeed = 375.0,
            reloadTime = 2.0, reloadingMode = "cartridge", reloading = false, firingMode = "single", rateOfFire = 0.05, effectiveRange = size_to_srcrn(150.0),
            sound = "sound/pistol.wav", sound_vol = 0.2, img_idx = 0, bulletStartingPosShift = float2(1.0,23.0)]]
    push(weapons, w)
    w = [[Weapon id = 1, name = "AK-47", isUnlocked = false, dmg = 3.0, ammoMaxCount = 30, ammoCurCount = 30, bulletSpeed = 900.0,
            reloadTime = 3.0, reloadingMode = "cartridge", reloading = false, firingMode = "auto", rateOfFire = 0.1, effectiveRange = size_to_srcrn(500.0),
            shotSpreadAngle = 5.0, sound = "sound/pistol.wav", sound_vol = 0.2, img_idx = 1, bulletStartingPosShift = float2(3.0,23.0)]]
    push(weapons, w)
    w = [[Weapon id = 2, name = "SPAS-12", isUnlocked = false, dmg = 0.5, ammoMaxCount = 6, ammoCurCount = 6, bulletSpeed = 250.0,
            reloadTime = 10.0, reloadingMode = "bullet", reloading = false, firingMode = "single", rateOfFire = 0.3, effectiveRange = size_to_srcrn(150.0),
            bulletsPerShot = 20, shotSpreadAngle = 45.0, tracerMul = 5.0, sound = "sound/shotgun.mp3", sound_vol = 0.2, img_idx = 1, bulletStartingPosShift = float2(3.0,23.0)]]
    push(weapons, w)
    w = [[Weapon id = 3, name = "PZB-39", isUnlocked = false, dmg = 1000.0, ammoMaxCount = 1, ammoCurCount = 1, bulletSpeed = 1210.0,
            reloadTime = 3.0, reloadingMode = "cartridge", reloading = false, firingMode = "single", rateOfFire = 0.01, effectiveRange = size_to_srcrn(1000.0),
            enemyPenetration = true, sound = "sound/pzb_39.mp3", sound_vol = 0.4, img_idx = 1, bulletStartingPosShift = float2(3.0,23.0)]]
    push(weapons, w)
    w = [[Weapon id = 4, name = "Bazooka", isUnlocked = false, dmg = 1.0, ammoMaxCount = 1, ammoCurCount = 1, bulletSpeed = 80.0,
            reloadTime = 3.0, reloadingMode = "cartridge", reloading = false, firingMode = "single", rateOfFire = 0.01, effectiveRange = size_to_srcrn(400.0),
            expDmg = 50.0, expRadius = size_to_srcrn(50.0), bulletType = "rocket", bulletColor = COLOR_BULLET, sound = "sound/bazooka.mp3", sound_vol = 0.2,
            img_idx = 1, bulletStartingPosShift = float2(3.0,10.0), no_fire_fx = true, disableLaserSight = true]]
    push(weapons, w)
    w = [[Weapon id = 5, name = "Minigun", isUnlocked = false, dmg = 1.0, ammoMaxCount = 500, ammoCurCount = 500, bulletSpeed = 850.0,
            reloadTime = 24.0, reloadingMode = "cartridge", reloading = false, firingMode = "auto", rateOfFire = 0.03, effectiveRange = size_to_srcrn(1000.0),
            startUpTimeMax = 1.0, startUpTime = 1.0, shotSpreadAngle = 20.0, movementSpeedWhenShootingMul = 0.2, sound = "sound/minigun.wav", sound_vol = 0.2,
            sound_loop = true, sound_start = "sound/minigun_start.mp3", sound_start_vol = 0.025, sound_start_loop = false,
            sound_end = "sound/minigun_end.wav", sound_end_vol = 0.2, img_idx = 2, bulletStartingPosShift = float2(1.0,35.0)]]
    push(weapons, w)
    w = [[Weapon id = 6, name = "DR-2000", isUnlocked = false, dmg = 0.5, ammoMaxCount = 600, ammoCurCount = 600, bulletSpeed = 1000.0,
            reloadTime = 15.0, reloadingMode = "cartridge", reloading = false, firingMode = "auto", rateOfFire = 0.001, effectiveRange = size_to_srcrn(1000.0),
            bulletType = "ray", startUpTimeMax = 1.0, startUpTime = 1.0, bulletSize = 3.0, bulletColor = COLOR_BULLET_RAY, movementSpeedWhenShootingMul = 0.1,
            disableLaserSight = true, sound = "sound/laser.wav", sound_vol = 0.2, sound_loop = true, no_fire_fx = true,
            sound_start = "sound/laser_start.wav", sound_start_vol = 0.01, sound_start_loop = false, img_idx = 2, bulletStartingPosShift = float2(1.0,32.0)]]
    push(weapons, w)
    w = [[Weapon id = 7, name = "Ripjack", isUnlocked = false, dmg = 1.0, ammoMaxCount = 1, ammoCurCount = 1, bulletSpeed = 100.0,
            reloadTime = 1.0, reloadingMode = "cartridge", reloading = false, firingMode = "single", rateOfFire = 0.01, effectiveRange = size_to_srcrn(5000.0),
            reboundOfScreenBorder = true, bulletType = "disk", enemyPenetration = true, bulletSize = 4.0, bulletColor = COLOR_DISC, no_fire_fx = true,
            maxActiveBullets = 6, maxActiveBulletsIdx = 0, sound = "sound/ripjack.wav", sound_vol = 0.2, img_idx = 1, bulletStartingPosShift = float2(1.0,10.0)]]
    push(activeBullets,0)
    push(weapons, w)

def weapon_unlock(id: int)    
    for w in weapons
        if w.id == id
            w.isUnlocked = true
            firstWeaponUnlocked = true
            break

def check_for_weapon_switch(var w: Weapon)
    if get_key_down(VK_1) && weapons[0].isUnlocked
        switch_weapon(w, weapons[0])
    if get_key_down(VK_2) && weapons[1].isUnlocked
        switch_weapon(w, weapons[1])
    if get_key_down(VK_3) && weapons[2].isUnlocked
        switch_weapon(w, weapons[2])  
    if get_key_down(VK_4) && weapons[3].isUnlocked
        switch_weapon(w, weapons[3])  
    if get_key_down(VK_5) && weapons[4].isUnlocked
        switch_weapon(w, weapons[4])  
    if get_key_down(VK_6) && weapons[5].isUnlocked
        switch_weapon(w, weapons[5])  
    if get_key_down(VK_7) && weapons[6].isUnlocked
        switch_weapon(w, weapons[6])  
    if get_key_down(VK_8) && weapons[7].isUnlocked
        switch_weapon(w, weapons[7])             

def switch_weapon(var w: Weapon; w_tpl: Weapon)
    weapons[w.id].ammoCurCount = w.ammoCurCount
    weapon_set(w, w_tpl)

def weapon_set(var w: Weapon; w_tpl: Weapon)
    w = w_tpl
    w.reloading = false
    if w.movementSpeedWhenShootingMul <= 0.0
        w.movementSpeedWhenShootingMul = 1.0

def weapon_update(dt: float; var player_reload_skill: float)
    check_for_weapon_switch(weapon)
    weapon.fire_fx_timer -= dt
    weapon.cooldownTimerForAttack -= dt
    if weapon.reloadingMode != "" && !weapon.reloading && (weapon.ammoCurCount == 0 || (weapon.ammoCurCount != weapon.ammoMaxCount && get_key(VK_R)))
        reload(weapon, player_reload_skill)
    elif weapon.reloading
        reload_update(weapon, dt) 
    if check_if_shooting() && weapon.reloading == false && weapon.startUpTime > 0.0
        weapon.startUpTime -= dt
        if length(weapon.sound_start) > 0 && !is_playing(startup_handle)
            snd_weapon_start_play(weapon.id)
    if !check_if_shooting() || weapon.reloading == true 
        if weapon.startUpTimeMax > 0.0
            weapon.startUpTime = weapon.startUpTimeMax 
        if weapon.sound_start_loop && is_playing(startup_handle)
            snd_stop(startup_handle)
        if weapon.sound_loop && is_playing(weapon_handle)
            snd_stop(weapon_handle)
            if length(weapon.sound_end) > 0
                snd_weapon_end_play(weapon.id)  



//shooting
def check_if_shooting()
    return weapon.firingMode == "single" && get_mouse_button_down(MB_LEFT) || weapon.firingMode == "auto" && get_mouse_button(MB_LEFT)        

def ready_to_shoot_check()  
    if (weapon.cooldownTimerForAttack < 0.0 && (!weapon.reloading || (weapon.ammoCurCount > 0 && weapon.reloadingMode == "bullet")) &&
        weapon.ammoCurCount > 0 && weapon.startUpTime <= 0.0 &&
        (weapon.maxActiveBullets <= 0 || activeBullets[weapon.maxActiveBulletsIdx] < weapon.maxActiveBullets))        
        weapon.reloading = false
        return true 
    else
        return false     
        
def weapon_shooting(shootingRateMul: float)
    weapon.ammoCurCount -= 1
    weapon.cooldownTimerForAttack = weapon.rateOfFire / shootingRateMul
    if !weapon.no_fire_fx && weapon.fire_fx_timer < -weapon.fire_fx_timer_max
        weapon.fire_fx_timer_max = min(WEAPON_FIRE_FX_TIME_MAX, max(WEAPON_FIRE_FX_TIME_MIN, weapon.cooldownTimerForAttack/2.0))
        weapon.fire_fx_timer = weapon.fire_fx_timer_max
    if length(weapon.sound) > 0 
        snd_weapon_play(weapon.id)       

//reload    
def reload(var w: Weapon; var player_reload_skill: float)
    w.reloading = true
    if weapon.ammoMaxCount > 1
        snd_reload_start_play()
    if player_reload_skill <= 0.0
        player_reload_skill = 1.0
    w.reloadTimer = w.reloadTime / player_reload_skill
    if w.reloadingMode == "bullet" && w.ammoMaxCount > 0
        w.reloadOneTime = w.reloadTimer / float(w.ammoMaxCount)
        w.reloadOneTimer = w.reloadOneTime

def reload_update(var w: Weapon; dt: float)
    if w.reloadTimer <= 0.0 || w.ammoCurCount >= w.ammoMaxCount 
        w.ammoCurCount = w.ammoMaxCount
        w.reloading = false
        weapon.cooldownTimerForAttack = 0.0
        snd_reload_end_play()
    else  
        if w.reloadingMode == "bullet"
            if w.reloadOneTimer <= 0.0 && w.ammoCurCount < w.ammoMaxCount 
                w.ammoCurCount++
                weapon.cooldownTimerForAttack = 0.0
                w.reloadOneTimer = w.reloadOneTime
            else  
                w.reloadOneTimer -= dt  
        w.reloadTimer -= dt
        
def restore_all_ammo()
    for w in weapons
        w.ammoCurCount = w.ammoMaxCount
    weapon.ammoCurCount = weapon.ammoMaxCount
    weapon.reloadTimer = -1.0
    snd_reload_end_play()

//explosions
def add_explosion(pos:float2; radius: float; dmg: float)  
    var exp <- [[Explosion pos = pos, radius = min(5.0, radius), radiusMax = radius, dmg = dmg, effectTime = EXPLOSION_EFFECT_TIME, effectTimeMax = EXPLOSION_EFFECT_TIME]]  
    set_explosion_anim(exp.anim, pos, radius) 
    emplace(explosions, exp)
    snd_explosion_play()

def update_explosion(var exp: Explosion; dt: float)
    exp.effectTime -= dt
    if exp.effectTime > 0.01
        exp.radius = exp.radiusMax * min((exp.effectTimeMax - (exp.effectTime - 0.01)) / (exp.effectTime - 0.01), 1.0)
        exp.anim.size = float2(exp.radius*2.0,exp.radius*2.0)
    update_explosion_anim(exp.anim, dt)

def explosion_render(var exp: Explosion)
    //fill_circle(exp.pos.x, exp.pos.y, exp.radius, COLOR_EXPLOSION)
    draw_explosion_anim(exp.anim)

def cleanup_explosions()
    var idx = length(explosions) - 1
    while idx >= 0
        if explosions[idx].effectTime <= 0.0
            erase(explosions, idx)
        idx--          

//ray weapon
def build_bullet_ray(speed: float2; pos: float2; dt: float)
    var newPos = pos
    while int(newPos.x) > 0 && int(newPos.x) < get_screen_width() && int(newPos.y) > 0 && int(newPos.y) < get_screen_height()
        newPos += speed * dt
        for e in enemies
            if length(e.pos - newPos) < e.radius
                return newPos
    return newPos   

def cleanup_old_ray_bullets() 
    var idx = length(bullets) - 1
    while idx >= 0
        if bullets[idx].bulletType == "ray"
            erase(bullets, idx)
        idx--          

//bullets
def bullet_add(var pos: float2; speed: float2; lifeTime: float; w: Weapon)
    var b = [[Bullet pos=pos, speed=speed, lifeTime=lifeTime, enemyPenetration=w.enemyPenetration, expDmg=w.expDmg, expRadius=w.expRadius,
                bulletType=w.bulletType, reboundOfScreenBorder=w.reboundOfScreenBorder, tracerMul=w.tracerMul, size=w.bulletSize, dmg=w.dmg,
                color=w.bulletColor, maxActiveBullets=w.maxActiveBullets, maxActiveBulletsIdx=w.maxActiveBulletsIdx,bulletStartingPosShift=w.bulletStartingPosShift]]
    emplace(bullets, b)


def bullet_update(var b: Bullet; dt: float)
    b.pos += b.speed * dt
    if int(b.pos.x) <= 0 || int(b.pos.x) >= get_screen_width() || int(b.pos.y) <= 0 || int(b.pos.y) >= get_screen_height()
        if b.reboundOfScreenBorder 
            if int(b.pos.x) <= 0 || int(b.pos.x) >= get_screen_width()
                b.speed.x *= -1.0    
            if int(b.pos.y) <= 0 || int(b.pos.y) >= get_screen_height()
                b.speed.y *= -1.0
        else
            b.lifeTime = -1.0
    elif b.lifeTime > 0.0
        b.lifeTime -= dt


def bullet_render(var b: Bullet; player_pos:float2)
    if length(b.pos-player_pos) < b.bulletStartingPosShift.y
        return

    if length(b.bulletType) > 0
        drawUniqueBullets(b, player_pos)
    else
        let tracerMul = b.tracerMul > 0.0 ? b.tracerMul : 1.0
        let p1 = b.pos
        let p2 = b.pos - b.speed * 0.01 * tracerMul
        line(p1.x, p1.y, p2.x, p2.y, COLOR_BULLET)

def get_bullet_dir(player_pos)
    var dir = normalize(get_mouse_position() - player_pos)
    var spreadAngle = atan2(dir.x, dir.y) + weapon.shotSpreadAngle/180.0*PI * (1.0 - random_float(seed) * 2.0) * 0.5
    dir = normalize(dir + float2(sin(spreadAngle), cos(spreadAngle)))      
    return dir

def cleanup_bullets(var arr)
    var idx = length(arr) - 1
    while idx >= 0
        if arr[idx].lifeTime < 0.0
            if arr[idx].maxActiveBullets > 0
                activeBullets[arr[idx].maxActiveBulletsIdx]--
            if arr[idx].expDmg > 0.0
                add_explosion(arr[idx].pos, arr[idx].expRadius, arr[idx].expDmg) 
            erase(arr, idx)
        idx-- 

//general render
def get_weapon_hud()
    var w_hud: WeaponHUD   
    w_hud.weapon = "{weapon.name}, switch: "
    var weapons_list_str = ""    
    var w_id = 1
    for w in weapons
        var new_weapon = ""
        if w.isUnlocked
            if weapon.name != w.name
                new_weapon = "{w_id}"
            else  
                new_weapon = "({w_id})"
        else
            new_weapon = "-"        
        if weapons_list_str != ""
            weapons_list_str += ", "
        weapons_list_str += new_weapon 
        w_id++

    w_hud.weapon += weapons_list_str 

    if weapon.ammoCurCount <= 0 && weapon.reloadingMode == ""
        w_hud.ammo = "No ammo left. Use crates to replenish"    
    elif weapon.maxActiveBullets > 0 && activeBullets[weapon.maxActiveBulletsIdx] >= weapon.maxActiveBullets
        w_hud.ammo = "Too many bullets active for this weapon"         
    else    
        w_hud.ammo = "Ammo:{weapon.ammoCurCount}/{weapon.ammoMaxCount}"
        if weapon.reloading
            w_hud.ammo += "(Reloading:{format("%.1f", weapon.reloadTimer)})"  

    return w_hud   

def unlock_all_weapons()
    for w in weapons    
        if !w.isUnlocked        
            w.isUnlocked = true     

def drawUniqueBullets(b: Bullet; player_pos: float2)  
    if b.bulletType == "rocket"
        var arr: array<float2>
        push(arr, b.pos)
        var angle = atan2(b.speed.x, b.speed.y) + 135.0/180.0*PI
        var r = get_diagonal(length(b.speed * 0.075)/2.0,length(b.speed * 0.075)/2.0)
        var p2 = b.pos + float2(sin(angle), cos(angle)) * r
        push(arr, p2)
        angle += 90.0/180.0*PI
        p2 += float2(sin(angle), cos(angle)) * r
        push(arr, p2)
        angle += 90.0/180.0*PI
        p2 += float2(sin(angle), cos(angle)) * r
        push(arr, p2)
        fill_convex_polygon(arr, b.color)  
        
        line(b.pos.x - b.speed.x*0.075, b.pos.y - b.speed.y*0.075, b.pos.x - b.speed.x*0.15, b.pos.y - b.speed.y*0.15, b.color)
        r = get_diagonal(length(b.speed * 0.1)/2.0,length(b.speed * 0.1)/2.0)
        angle = atan2(b.speed.x, b.speed.y) + 155.0/180.0*PI
        p2 = float2(b.pos.x - b.speed.x*0.15, b.pos.y - b.speed.y*0.15)
        line(p2.x, p2.y, p2.x+sin(angle)*r, p2.y+cos(angle)*r, b.color)
        angle = atan2(b.speed.x, b.speed.y) - 155.0/180.0*PI
        line(p2.x, p2.y, p2.x+sin(angle)*r, p2.y+cos(angle)*r, b.color) 

    if b.bulletType == "disk"
        fill_circle(b.pos.x, b.pos.y, b.size, COLOR_BULLET)
        fill_circle(b.pos.x, b.pos.y, b.size/1.5, b.color)

    if b.bulletType == "ray"
        let dir = normalize(player_pos - b.pos)
        var p_pos = player_pos - dir*b.bulletStartingPosShift.y
        var angle = atan2(dir.x, dir.y) + 90.0/180.0*PI
        var pos = b.pos + float2(sin(angle), cos(angle))*weapon.bulletStartingPosShift.x 
        p_pos += float2(sin(angle), cos(angle))*weapon.bulletStartingPosShift.x        
        line(pos.x, pos.y, p_pos.x, p_pos.y, b.color)
        pos += float2(sin(angle), cos(angle))
        p_pos += float2(sin(angle), cos(angle))
        line(pos.x, pos.y, p_pos.x, p_pos.y, b.color)
        pos -= float2(sin(angle), cos(angle)) * 2.0
        p_pos -= float2(sin(angle), cos(angle)) * 2.0
        line(pos.x, pos.y, p_pos.x, p_pos.y, b.color) 
