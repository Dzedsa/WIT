require daslib/media

require wit_utils
require wit_ui_common

require wit_weapons
require wit_graphics
require wit_sound

struct Pickup
    id: int
    weight: float
    desc: string
    pos: float2
    activeTimeMax: float
    lifeTime: float
    blinkHideTime: float
    blinkHideTimeCooldown: float
    activated: bool
    bonusGranted: bool
    weaponUnlockId: int
    size: float

var private
    pickup_types: array<Pickup>
    pickups_list: array<Pickup>
    spawned_pickups: array<Pickup>
    spawnCooldownCur: float 

var 
    active_pickups: array<Pickup>
    pickup_drop_chance: float   
    shouldSpawnPickups: bool 
    bonusTimeMul: float

    
let
    COLOR_PICKUP = 0xC53B3B3B 
    COLOR_ACTIVATE = 0xABFFFB07 
    COLOR_PICKUP_TEXT = 0xC5F8F400 
    BOX_SIZE = size_to_srcrn(20.0)
    SPAWN_COOLDOWN = 1.0 
    LIFE_TIME = 10.0
    BLINK_LIFE_LEFT = 2.0
    BLINK_TIME = 0.3
    MIN_DROP_CHANCE = 0.001
    MAX_WEAPONS_PER_PICKUP_LIST = 1

def pickup_init(shouldSpawn: bool)
    shouldSpawnPickups = shouldSpawn
    clear(spawned_pickups)
    clear(pickups_list)
    clear(pickup_types)
    clear(active_pickups)
    spawnCooldownCur = SPAWN_COOLDOWN
    pickup_drop_chance = 0.3
    bonusTimeMul = 1.0    

def setup_pickups()
    clear(pickup_types)
    var p = [[Pickup id = 1, weight = 2.0, desc = "5 health restored!"]]
    push(pickup_types, p)
    /*p = [[Pickup id = 2, weight = 1.0, desc = "+50% movement speed", activeTimeMax = 10.0]]
    push(pickup_types, p)*/
    if firstWeaponUnlocked
        p = [[Pickup id = 3, weight = 1.0, desc = "Restore ammo for all your weapons!"]]
        push(pickup_types, p)
        p = [[Pickup id = 4, weight = 0.3, desc = "Boom!"]]
        push(pickup_types, p)
        p = [[Pickup id = 5, weight = 1.0, desc = "+100% shooting speed for your weapons", activeTimeMax = 10.0]]
        push(pickup_types, p)
        p = [[Pickup id = 6, weight = 1.0, desc = "Bullet time", activeTimeMax = 2.5]]
        push(pickup_types, p)
        p = [[Pickup id = 7, weight = 1.0, desc = "Double EXP", activeTimeMax = 10.0]]
        push(pickup_types, p)
        p = [[Pickup id = 8, weight = 1.0, desc = "Bind enemies in place", activeTimeMax = 5.0]]
        push(pickup_types, p)
    var avgWeight = get_avg_weight_from_struct_array(pickup_types)
    for pt in pickup_types
        if pt.weight >= random_float(seed) * avgWeight
            var num = max(int(pt.weight / avgWeight),1)
            while num > 0
                push(pickups_list, pt)
                num--

    var lockedWeapons: array<Pickup>
    for w in weapons
        if !w.isUnlocked
            p = [[Pickup id = 100 + w.id, weight = 1.0, desc = "New weapon:{w.name}", weaponUnlockId = w.id]]
            push(lockedWeapons, p)
    if length(lockedWeapons) > 0
        shuffle_array(lockedWeapons)
        var i = 0
        while i < MAX_WEAPONS_PER_PICKUP_LIST && i < length(lockedWeapons)
            push(pickups_list, lockedWeapons[i])                     
            i++

    shuffle_array(pickups_list)


def spawn_pickup()
    let scr_h = float(get_screen_height()) - SAFE_AREA * 2.0
    let scr_w = float(get_screen_width()) - SAFE_AREA * 2.0
    var pos: float2
    pos.x = random_float(seed) * scr_w + SAFE_AREA
    pos.y = random_float(seed) * scr_h + SAFE_AREA
    create_pickup(pos)
    spawnCooldownCur = SPAWN_COOLDOWN

def create_pickup(pos: float2)      
    if length(pickups_list) <= 0
        setup_pickups()
    var p = pickups_list[0]
    p.pos = pos
    p.lifeTime = LIFE_TIME
    p.size = BOX_SIZE
    push(spawned_pickups, p)
    erase(pickups_list, 0)
    if pickup_drop_chance > MIN_DROP_CHANCE
        pickup_drop_chance *= 0.85

def check_should_blink(var p: Pickup; dt: float)
    p.blinkHideTime -= dt
    p.blinkHideTimeCooldown -= dt
    if p.blinkHideTimeCooldown <= 0.0 && p.lifeTime < BLINK_LIFE_LEFT
        p.blinkHideTime = BLINK_TIME
        p.blinkHideTimeCooldown = BLINK_TIME * 2.0    

def check_player_collision_with_pickups(player_pos, player_radius)
    for p in spawned_pickups
        if !p.activated && length(p.pos - player_pos) < player_radius + BOX_SIZE
            activate_pickup(p)

def activate_pickup(var p: Pickup)
    p.activated = true
    p.lifeTime = 0.05
    var active_p = p
    if active_p.activeTimeMax < 3.0
        active_p.lifeTime = 3.0
    else
        active_p.lifeTime = active_p.activeTimeMax * bonusTimeMul  
    push(active_pickups,active_p)
    if active_p.weaponUnlockId > 0
        weapon_unlock(active_p.weaponUnlockId) 
        snd_weapon_pickup_play()    
    else    
        snd_pickup_play()

def pickup_cleaning(var arr)
    var idx = length(arr) - 1
    while idx >= 0
        if arr[idx].lifeTime < 0.0
            erase(arr, idx)
        idx--
    
def pickup_update(var player_pos: float2; var player_radius: float; dt: float)
    spawnCooldownCur -= dt
    if spawnCooldownCur <= 0.0 && shouldSpawnPickups
        spawn_pickup()
    for p in spawned_pickups 
        p.lifeTime -= dt
        check_should_blink(p, dt)
    for p in active_pickups
        p.lifeTime -= dt
    check_player_collision_with_pickups(player_pos, player_radius)
    pickup_cleaning(spawned_pickups)
    pickup_cleaning(active_pickups)

//render
def pickup_hud_draw()
    var i = 0.0
    for p in active_pickups
        var active_bonus_str = p.desc               
        if p.activeTimeMax > 0.0
            active_bonus_str += ": {format("%.1f", p.lifeTime)}"
        let size = get_text_size(active_bonus_str)        
        text_out(int(get_screen_width()/2 - int(size.x/2.0)), int(SAFE_AREA*(1.0f+i*0.75f)), active_bonus_str, COLOR_PICKUP_TEXT)
        i++
    
    
def pickups_draw(should_update: bool)
    for p in spawned_pickups
        var color = COLOR_PICKUP
        if p.activated
            if should_update      
                p.size *= 1.1
            color = COLOR_ACTIVATE
        else 
            if p.blinkHideTime > 0.0            
                continue
        if p.weaponUnlockId > 0
            fill_circle(p.pos.x, p.pos.y, BOX_SIZE/1.5, color)
            draw_weapon_pickup(p.weaponUnlockId, float2(p.pos.x - p.size, p.pos.y - p.size), p.size*2.0)
        else
            draw_pickup_box(float2(p.pos.x - p.size/2.0, p.pos.y - p.size/2.0), p.size)  