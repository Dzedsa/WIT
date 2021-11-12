require daslib/media

require wit_weapons
require wit_pickups
require wit_perks
require wit_ui_common
require wit_utils
require wit_enemies
require wit_text_input
require wit_lb
require wit_sound
require wit_graphics


options debugger
require daslib/debug


struct Player
    radius: float
    pos: float2
    speed: float2
    speedMax: float
    hp: float
    hpMax: float
    exp: int
    level: int
    reloadSkill: float
    xpMult: float
    pickupRadiusMult: float
    shootingRateMul: float
    dtMul: float
    explodeOnDamageTakenRadius: float
    cheatDeath: float    
    regenerationCooldown: float
    regenerationTimer: float
    weaponLaserSight: bool
    invincibilityTimer: float
    hurt_sound_timer: float

var
    player: Player
    playerBonuses: Player
    is_game_active: bool = false
    time_to_add_next_enemy: float
    enemy_spawn_period: float
    enemy_max_count: int
    enemy_max_count_reach_time: float
    enemy_add_count: int
    enemy_add_time: float
    enemy_add_timer_cur: float
    player_score: int
    score_enabled: bool
    playing_time: float
    last_player_dir: float2
    min_fps: float
    avg_fps_arr: array<float>
    avg_fps: float
    fps_timer: float
    fps_alt: int
    fps_alt_counter: int
    start_game_first_enemy_timer: float

let
    COLOR_PLAYER_PUDDLE = 0xD0FF0000
    COLOR_LASER = 0xAEFF4F4F


// Auxiliary functions
def game_params_reset()
    time_to_add_next_enemy = -1.0
    enemy_spawn_period = 1.0
    enemy_max_count = 15
    enemy_max_count_reach_time = 5.0
    enemy_add_count = 3
    enemy_add_time = 3.0
    enemy_add_timer_cur = 5.0
    player_score = 0
    score_enabled = true
    playing_time = 0.0
    start_game_first_enemy_timer = 2.5


def cleanup_death_items(var arr)
    var idx = length(arr) - 1
    while idx >= 0
        if arr[idx].lifeTime < 0.0
            erase(arr, idx)
        idx--


// Player methods
def player_set(var p: Player)
    p.pos = float2(float(get_screen_width()) * 0.5, float(get_screen_height()) * 0.5)
    p.speed = float2(0.0)
    p.speedMax = 100.0
    p.radius = size_to_srcrn(5.0)
    p.hpMax = 30.0
    p.hp = 30.0
    p.level = 1
    p.exp = 0
    p.reloadSkill = 1.0
    p.xpMult = 1.0
    p.pickupRadiusMult = 1.0
    p.shootingRateMul = 1.0
    p.dtMul = 1.0
    p.explodeOnDamageTakenRadius = 0.0
    p.cheatDeath = 0.0
    player.regenerationCooldown = -1.0
    player.regenerationTimer = -1.0
    player.weaponLaserSight = false
    player.invincibilityTimer = 0.5
    player.hurt_sound_timer = -1.0


def player_update(var p: Player; dt: float)
    player.invincibilityTimer -= dt
    player.hurt_sound_timer -= dt
    if player.hurt_sound_timer <= 0.0 && player.hurt_sound_timer > -1.0
        snd_player_hurt_play()
        player.hurt_sound_timer = -1.0

    let weaponMul = check_if_shooting() && weapon.reloading == false ? weapon.movementSpeedWhenShootingMul : 1.0
    player_move_update(p, dt)
    p.pos += p.speed * dt * weaponMul
    p.speed = lerp(p.speed, float2(0, 0), float2(dt * 4.0)) 
    if p.regenerationCooldown > 0.0
        if p.regenerationTimer <= 0.0
            player.hp = min(player.hp+1.0, player.hpMax)
            p.regenerationTimer = p.regenerationCooldown
        else
            p.regenerationTimer -= dt        

def player_move(var p: Player; move_dir: float2)
    p.speed += move_dir * 20.0
    if length(p.speed) > p.speedMax
        p.speed = normalize(p.speed) * (p.speedMax + playerBonuses.speedMax)

def player_move_update(var p: Player; dt: float)
    let nextPos = p.pos + p.speed * dt
    if (int(nextPos.x - SAFE_AREA) < 0) || (int(nextPos.x + SAFE_AREA) > get_screen_width())
        p.speed.x = 0.0
    if (int(nextPos.y - SAFE_AREA) < 0) || (int(nextPos.y + SAFE_AREA) > get_screen_height())
        p.speed.y = 0.0

def damage_player(dmg)
    if player.invincibilityTimer <= 0.0
        player.hp -= dmg
        player.invincibilityTimer = 0.1
        puddle_add(player.pos, player.radius * 3.0, 20.0, COLOR_PLAYER_PUDDLE)
        player.hurt_sound_timer = 0.2
        if player.explodeOnDamageTakenRadius > 0.0
            add_explosion(player.pos, size_to_srcrn(player.explodeOnDamageTakenRadius), 1000.0)

def apply_player_bonuses(var player: Player)
    var EmptyPlayer: Player
    playerBonuses = EmptyPlayer
    bind_enemies = false
    for p in active_pickups
        if p.lifeTime > 0.0 && (p.activeTimeMax > 0.0 || (p.activeTimeMax <= 0.0 && !p.bonusGranted))
            if p.id == 1
                player.hp += 5.0
                if player.hp > player.hpMax
                    player.hp = player.hpMax
            if p.id == 2    
                playerBonuses.speedMax = player.speedMax * 0.5
            if p.id == 3    
                restore_all_ammo()               
            if p.id == 4    
                add_explosion(p.pos, size_to_srcrn(150.0), 100.0)                
            if p.id == 5    
                playerBonuses.shootingRateMul = player.shootingRateMul       
            if p.id == 6    
                playerBonuses.dtMul = -0.8               
            if p.id == 7    
                playerBonuses.xpMult = player.xpMult   
            if p.id == 8    
                bind_enemies = true
            if p.activeTimeMax <= 0.0  
                p.bonusGranted = true 

def check_for_player_lvlup(var p: Player)
    if player.level >= MAX_LEVEL
        return
    if p.exp >= level_exp[player.level - 1]
        p.exp -= level_exp[player.level - 1]
        p.level++       
        choose_perk_window_active = true
        if p.level == 10
            snd_lvl10_play()
        if p.level == 20
            snd_lvl20_play()
        if p.level == 30
            snd_lvl30_play()

def add_perk_bonus_to_player(var arr_to_apply: array<int>)
    for perk in arr_to_apply
        if perk == 1
            player.hpMax += 10.0
            player.hp += 10.0
        if perk == 2
            player.reloadSkill += 0.5   
        if perk == 3
            player.xpMult += 1.0     
        if perk == 4
            player.pickupRadiusMult += 1.0
        if perk == 5
            pickup_drop_chance += 0.1   
        if perk == 6
            bonusTimeMul += 0.5
        if perk == 7
            player.speedMax += 20.0
        if perk == 8
            if player.explodeOnDamageTakenRadius < 30.0
                player.explodeOnDamageTakenRadius = 30.0
            else
                player.explodeOnDamageTakenRadius += size_to_srcrn(15.0)
        if perk == 9
            player.cheatDeath += 5.0
        if perk == 10
            if player.regenerationCooldown > 0.0
                player.regenerationCooldown *= 0.5
                if player.regenerationTimer > player.regenerationCooldown
                    player.regenerationTimer = player.regenerationCooldown
            else
                player.regenerationCooldown = 20.0  
                player.regenerationTimer = 20.0 
        if perk == 11         
            player.weaponLaserSight = true
    clear(arr_to_apply)        

def damage_enemy(var e: Enemy; dmg: float; bullet_dir: float2)
    e.hp -= dmg
    let damageAngle = atan2(bullet_dir.x, bullet_dir.y)
    let exitWoundPos = e.pos + float2(sin(damageAngle), cos(damageAngle)) * e.radius*1.5
    add_enemy_hit_anim(exitWoundPos, 0.6, e.deathColor, -damageAngle)
    if e.hp <= 0.0
        snd_enemy_death_play()
        add_enemy_death_anim(e.pos, e.radius/size_to_srcrn(26.0), e.deathColor)
        puddle_add(e.pos, e.radius, size_to_srcrn(10.0), e.deathColor)
        if score_enabled
            player_score += int(1.0 * e.killScoreMul)
        player.exp += int(1.0 * (player.xpMult + playerBonuses.xpMult) * e.killScoreMul)
        e.alive = false
        if random_float(seed) < pickup_drop_chance * e.killScoreMul
            create_pickup(e.pos)  

def check_for_cheats()              
    if get_key(VK_LALT) && get_key_down(VK_H)
        if player.level < MAX_LEVEL
            player.exp += level_exp[player.level-1]
            score_enabled = false
            player_score = 0 
    if get_key(VK_LALT) && get_key_down(VK_J)
        player.invincibilityTimer=10000000.0
        score_enabled = false
        player_score = 0
    if get_key(VK_LALT) && get_key_down(VK_P)
        shouldSpawnPickups = true
        score_enabled = false
        player_score = 0
    if get_key(VK_LALT) && get_key_down(VK_K)
        unlock_all_weapons()
        firstWeaponUnlocked = true
        score_enabled = false
        player_score = 0
    if get_key(VK_LALT) && get_key_down(VK_R)
        restore_all_ammo()
        score_enabled = false
        player_score = 0
    if get_key(VK_LALT) && get_key_down(VK_X)
        player.hp = 0.0
    if get_key(VK_LALT) && get_key_down(VK_V)  
        player.hp = 100.0      
        for e in enemies
            damage_enemy(e, 1000.0, float2(0.0,0.0))
        score_enabled = false
        player_score = 0
    if get_key(VK_LALT) && get_key_down(VK_B) 
        if player.dtMul != 1.0
            player.dtMul = 1.0
        else
            player.dtMul = 0.2
        score_enabled = false
        player_score = 0
    if get_key(VK_LALT) && get_key_down(VK_T) 
        if bind_enemies_cheat
            bind_enemies_cheat = false
        else
            bind_enemies_cheat = true
        score_enabled = false
        player_score = 0

def game_start()
    set_font_size(16)
    setup_random_seed()
    player_set(player)
    weapon_init()
    game_params_reset()
    pickup_init(false)
    perks_init()
    enemies_init()
    interface_init()

[export]
def initialize()
    set_window_title("What's Inside Them?")
    lb_init()
    set_antialiasing(4)
    all_weapons_set()
    sound_init(weapons)//should be called after weapons set
    graphics_init()
    game_start()

[export]
def act(var dt: float)
    if is_game_active
        if fps_timer < 0.0
            fps_timer = 1.0
            fps_alt = fps_alt_counter
            fps_alt_counter = 0
            avg_fps = 0.0
            min_fps = 10000.0
            var idx = 0
            while idx < length(avg_fps_arr)
                avg_fps += max(avg_fps_arr[idx], 60.0)
                if min_fps > avg_fps_arr[idx]
                    min_fps = avg_fps_arr[idx]
                idx++
            clear(avg_fps_arr)
            if idx > 0
                avg_fps /= float(idx)
        else
            fps_timer -= dt 
            if dt > 0.0
                push(avg_fps_arr, 1.0/dt)
            

    if !is_game_active
        snd_stop(startup_handle)
        snd_stop(weapon_handle)
        snd_stop(horde_handle)

    if should_record_results_to_lb    
        game_over_window_active = false
        lb_update(player_name, player_score)
        lb_save(lb_name_arr, lb_score_arr)
        should_record_results_to_lb = false 
        lb_window_active = true  

    if you_died_window_active
        you_died_window_update(dt, player_score)

    let btn_fn = check_buttons_mouse_click()
    invoke(btn_fn)
    if game_over_window_active
        if length(player_name) < 16
            player_name += get_typed_keyboard_symbol()
        if get_key_down(VK_DELETE) || get_key_down(VK_BACK)
            player_name = slice(player_name, 0, length(player_name)-1)

    if !player_in_menues() && (!isGameInProgress || get_key_down(VK_ESCAPE))
        is_game_active = false
        main_menu_window_active = true  
    elif get_key_down(VK_ESCAPE) && (help_window_active || lb_window_active || game_over_window_active)
        help_window_active = false
        lb_window_active = false
        game_over_window_active = false
        main_menu_window_active = true     
    elif (main_menu_window_active && (get_key_down(VK_SPACE) || get_key_down(VK_ESCAPE))) || shouldGoPlay
        main_menu_window_active = false
        shouldGoPlay = false
        is_game_active = true
        if !isGameInProgress
            isGameInProgress = true
            game_start()
            snd_game_start_play()  

    if !isGameInProgress
        return

    if !player_in_menues()
        is_game_active = true
    if choose_perk_window_active
        is_game_active = false  
        check_perk_window_shortcuts()
    if !is_game_active
        return

    check_for_cheats() 

    dt *= max((player.dtMul + playerBonuses.dtMul),0.1)
    playing_time += dt   
    
    if length(perks_to_apply) > 0
        add_perk_bonus_to_player(perks_to_apply)

    if length(enemies) > 0  && !is_playing(horde_handle) && is_game_active
        snd_zombie_horde_idle_play()
    if (length(enemies) <= 0 && is_playing(horde_handle))
        snd_stop(horde_handle)

    for e in enemies
        enemy_update(e, player.pos, dt)
        var dmg = enemy_attack(e, player.pos, player.radius)
        if dmg > 0.0
            damage_player(dmg)

    for b in bullets
        if b.bulletType != "ray"
            bullet_update(b, dt)
        for e in enemies
            if length(e.pos - b.pos) < e.radius+b.size
                if !b.enemyPenetration
                    b.lifeTime = -1.0   
                damage_enemy(e, b.dmg, b.speed)
                break

    for exp in explosions
        update_explosion(exp, dt)
        for e in enemies
            if length(e.pos - exp.pos) < e.radius + exp.radius
                damage_enemy(e, exp.dmg, normalize(e.pos - exp.pos))

    puddle_update(dt)
    update_enemy_deaths(dt)
    update_enemy_hits(dt)
        

    cleanup_death_enemies()
    cleanup_bullets(bullets)
    cleanup_death_items(puddles)
    cleanup_explosions()

    var moveDir = float2(0.0,0.0)
    if get_key(VK_W)
        moveDir += float2(0.0, -1.0)
    if get_key(VK_D)
        moveDir += float2(1.0, 0.0)
    if get_key(VK_A)
        moveDir += float2(-1.0, 0.0)
    if get_key(VK_S)
        moveDir += float2(0.0, 1.0)
    player_move(player, normalize(moveDir))

    cleanup_old_ray_bullets()
    if check_if_shooting() && player.hp > 0.0
        if ready_to_shoot_check()
            var bulletsNum = weapon.bulletsPerShot > 0 ? weapon.bulletsPerShot : 1
            while bulletsNum > 0
                let dir = get_bullet_dir(player.pos)
                let lifeTime = weapon.bulletSpeed > 0.0 ? weapon.effectiveRange / weapon.bulletSpeed : 0.0
                var speed = dir * weapon.bulletSpeed
                var angle = atan2(dir.x, dir.y) + 90.0/180.0*PI
                var pos = player.pos - float2(sin(angle), cos(angle))*weapon.bulletStartingPosShift.x
                if weapon.bulletType == "ray"
                    pos = build_bullet_ray(speed, pos, dt)
                    speed = float2(0.0,0.0)
                bullet_add(pos, speed, lifeTime, weapon)
                bulletsNum--
                if weapon.maxActiveBullets > 0
                    activeBullets[weapon.maxActiveBulletsIdx]++
            weapon_shooting(player.shootingRateMul + playerBonuses.shootingRateMul)
        elif weapon.reloading
            snd_no_ammo_play()

    weapon_update(dt, player.reloadSkill)
    apply_player_bonuses(player)
    player_update(player, dt)
    check_for_player_lvlup(player)
    pickup_update(player.pos, player.radius * player.pickupRadiusMult, dt)
    

    if player.hp <= 0.0
        if player.cheatDeath > 0.0
            player.hp = player.cheatDeath
            player.cheatDeath = 0.0
            add_explosion(player.pos, size_to_srcrn(100.0), 1000.0)
            player.invincibilityTimer = 0.5
            var p: Pickup
            p.desc = "Rise like a phoenix!"
            p.lifeTime = 3.0
            push(active_pickups,p)
        else
            is_game_active = false
            isGameInProgress = false
            you_died_window_active = true
            snd_player_death_play()
            snd_you_died_play()
            set_font_size(20)

    if start_game_first_enemy_timer <= 0.0
        enemy_spawn_period = enemy_max_count_reach_time / float(enemy_max_count)
        enemy_add_timer_cur -= dt
        if enemy_add_timer_cur <= 0.0 && player.level >= 3
            enemy_add_timer_cur = enemy_add_time
            enemy_max_count += enemy_add_count

        if is_game_active && length(enemies) < enemy_max_count && time_to_add_next_enemy < 0.0
            time_to_add_next_enemy = enemy_spawn_period
            enemy_add(player.level)
        else
            time_to_add_next_enemy -= dt
    else    
        start_game_first_enemy_timer -= dt

[export]
def draw()
    enable_alpha_blend()
    draw_map()

    for p in puddles
        puddle_render(p)

    pickups_draw(is_game_active) 

    enemies_render()
    draw_enemy_hits()
    draw_enemy_deaths()

    for b in bullets
        bullet_render(b, player.pos)

    for exp in explosions
        explosion_render(exp)

    text_out(int(SAFE_AREA), get_screen_height()-int(SAFE_AREA*0.75f), "MIN FPS:{format("%.1f", min_fps)}", COLOR_TEXT)        

    if player.hp > 0.0
        var angle = atan2(last_player_dir.x, last_player_dir.y) + 90.0/180.0*PI               
        var p_pos = player.pos + last_player_dir*weapon.bulletStartingPosShift.y
        p_pos -= float2(sin(angle), cos(angle))*weapon.bulletStartingPosShift.x 
        draw_player(player.pos, atan2(last_player_dir.x, last_player_dir.y), weapon.img_idx)
        if weapon.fire_fx_timer > 0.0
            draw_weapon_fire_fx(p_pos,atan2(last_player_dir.x,last_player_dir.y))
        if is_game_active
            last_player_dir = normalize(get_mouse_position() - player.pos)
            if player.weaponLaserSight && !weapon.disableLaserSight 
                var aim_pos = get_mouse_position() - float2(sin(angle), cos(angle))*weapon.bulletStartingPosShift.x 
                line(p_pos.x, p_pos.y, aim_pos.x, aim_pos.y, COLOR_LASER)
        

        var text = "HP:{int(player.hp)}/{int(player.hpMax)}"
        text_out(int(SAFE_AREA), int(SAFE_AREA*0.25f), text, COLOR_TEXT)

        var w_hud = get_weapon_hud()
        var size = get_text_size(text)
        text_out(int(SAFE_AREA + size.x + size_to_srcrn(5.0)), int(SAFE_AREA*0.25f), w_hud.weapon, COLOR_TEXT)
        text_out(int(SAFE_AREA + size.x + size_to_srcrn(5.0)), int(SAFE_AREA*1.0f), w_hud.ammo, COLOR_TEXT)

        text = "Score:{player_score}"
        if !score_enabled
            text = "Cheater!"
        size = get_text_size(text)
        text_out(int(float(get_screen_width())*0.75 - size.x - size_to_srcrn(2.5)), int(SAFE_AREA*0.25f), text, COLOR_TEXT)
        text_out(int(float(get_screen_width())*0.75 + size_to_srcrn(2.5)), int(SAFE_AREA*0.25f), "Time:{format("%.1f", playing_time)}", COLOR_TEXT)

        var level_hud_str = "Level: {player.level}"
        var level_len = get_text_size(level_hud_str)
        text_out(get_screen_width() - int(SAFE_AREA + level_len.x), int(SAFE_AREA*0.25f), "{level_hud_str}", COLOR_TEXT)
        var exp_hud_str = player.level < MAX_LEVEL ? "Exp: {player.exp}/{level_exp[player.level - 1]}" : "MAX"
        var exp_len = get_text_size(exp_hud_str)    
        text_out(get_screen_width() - int(SAFE_AREA + exp_len.x), int(SAFE_AREA*1.0f), "{exp_hud_str}", COLOR_TEXT)

        pickup_hud_draw()

    clear(buttons)
    if !is_game_active 
        if choose_perk_window_active
            perks_window_show()
        if main_menu_window_active
            main_menu_window_show()            
            draw_main_menu_img()
        if lb_window_active
            lb_window_show(player_name, player_score)
        if help_window_active
            help_window_show()
        if game_over_window_active
            game_over_window_show(player_score, playing_time)   
        if you_died_window_active
            you_died_window_show()           
        draw_buttons() 

    fps_alt_counter++
    return
