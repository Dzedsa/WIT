require daslib/media

require wit_utils

struct WeaponSound
    id: int
    fire: PcmSound
    start: PcmSound
    end: PcmSound
    fire_vol: float
    start_vol: float
    end_vol: float
    fire_loop: bool
    start_loop: bool


var 
    snd_enemy_death: PcmSound
    snd_reload_start: PcmSound
    snd_reload_end: PcmSound
    snd_explosion: PcmSound
    snd_no_ammo: PcmSound 
    snd_game_start: PcmSound 
    snd_lvl10: PcmSound 
    snd_lvl20: PcmSound 
    snd_lvl30: PcmSound 
    snd_button_click: PcmSound 
    snd_you_died: PcmSound
    snd_exit_button: array<PcmSound>
    startup_handle: PlayingSoundHandle
    weapon_handle: PlayingSoundHandle
    no_ammo_handle: PlayingSoundHandle
    snd_weapons: array<WeaponSound>
    snd_player_hurt: array<PcmSound>
    hurt_handle: PlayingSoundHandle
    snd_player_death: array<PcmSound>
    snd_weapon_pickup: PcmSound
    snd_pickup: PcmSound
    snd_zombie_horde_idle: PcmSound
    horde_handle: PlayingSoundHandle
    snd_zombie_attack: PcmSound

def sound_init(weapons)    
    snd_enemy_death <- create_sound("sound/death.wav")   
    snd_reload_start <- create_sound("sound/reload_start.mp3")  
    snd_reload_end <- create_sound("sound/reload_end.wav")  
    snd_no_ammo <- create_sound("sound/no_ammo.mp3") 
    snd_explosion <- create_sound("sound/explosion.wav")  
    snd_game_start <- create_sound("sound/game_start.wav")   
    snd_lvl10 <- create_sound("sound/lvl10.wav")   
    snd_lvl20 <- create_sound("sound/lvl20.wav")   
    snd_lvl30 <- create_sound("sound/lvl30.wav") 
    snd_button_click <- create_sound("sound/button_click.mp3") 
    snd_you_died <- create_sound("sound/you_died.mp3")
    emplace(snd_player_hurt, create_sound("sound/hurt1.wav"))
    emplace(snd_player_hurt, create_sound("sound/hurt2.wav"))
    emplace(snd_player_hurt, create_sound("sound/hurt3.wav"))
    emplace(snd_player_hurt, create_sound("sound/hurt4.wav"))
    emplace(snd_player_hurt, create_sound("sound/hurt5.wav"))
    emplace(snd_player_death, create_sound("sound/death1.wav"))
    emplace(snd_player_death, create_sound("sound/death2.wav"))
    snd_weapon_pickup <- create_sound("sound/weapon_pickup.wav")
    snd_pickup <- create_sound("sound/pickup.wav") 
    snd_zombie_horde_idle <- create_sound("sound/zombie_horde_idle.mp3") 
    snd_zombie_attack <- create_sound("sound/zombie_attack.wav") 

    for w in weapons
        var weaponSound <- [[WeaponSound id = w.id, fire <- create_sound(w.sound), 
                             fire_vol = w.sound_vol, start_vol = w.sound_start_vol, end_vol = w.sound_end_vol, fire_loop = w.sound_loop, start_loop = w.sound_start_loop]]
        if length(w.sound_start) > 0
            weaponSound.start <- create_sound(w.sound_start)
        if length(w.sound_end) > 0
            weaponSound.end <- create_sound(w.sound_end)            
        emplace(snd_weapons, weaponSound)    

    emplace(snd_exit_button, create_sound("sound/exit1.wav")) 
    emplace(snd_exit_button, create_sound("sound/exit2.wav")) 
    emplace(snd_exit_button, create_sound("sound/exit3.wav")) 
    emplace(snd_exit_button, create_sound("sound/exit4.wav")) 
    emplace(snd_exit_button, create_sound("sound/exit5.wav")) 

def snd_enemy_death_play()
    snd_enemy_death |> play_sound(0.1)    
def snd_reload_start_play()
    snd_reload_start |> play_sound(0.2)  
def snd_reload_end_play()
    snd_reload_end |> play_sound(0.2)  
def snd_explosion_play()    
    snd_explosion |> play_sound(0.4) 
def snd_no_ammo_play()
    if !is_playing(no_ammo_handle)    
        no_ammo_handle = snd_no_ammo |> play_sound(0.2) 
def snd_game_start_play()    
    snd_game_start |> play_sound(0.2) 
def snd_lvl10_play()    
    snd_lvl10 |> play_sound(0.2) 
def snd_lvl20_play()    
    snd_lvl20 |> play_sound(0.2) 
def snd_lvl30_play()    
    snd_lvl30 |> play_sound(0.2) 
def snd_button_click_play()    
    snd_button_click |> play_sound(0.2) 
def snd_you_died_play()    
    snd_you_died |> play_sound(1.0) 
def snd_player_hurt_play()
    stop_sound(hurt_handle)    
    var i = random_int(seed) % length(snd_player_hurt)     
    hurt_handle = snd_player_hurt[i] |> play_sound(1.0)  
def snd_player_death_play()
    var i = random_int(seed) % length(snd_player_death)     
    snd_player_death[i] |> play_sound(0.6)  
def snd_pickup_play()  
    snd_pickup |> play_sound(0.2)   
def snd_weapon_pickup_play()  
    snd_weapon_pickup |> play_sound(0.2) 
def snd_zombie_attack_play()  
    snd_zombie_attack |> play_sound(1.0) 
def snd_zombie_horde_idle_play()  
    horde_handle = snd_zombie_horde_idle |> play_sound_loop(0.2)     
     

def snd_exit_button_play(step: int)    
    snd_exit_button[step-1] |> play_sound(0.5)

def snd_weapon_play(weapIdx: int)
    if !is_playing(weapon_handle)
        if !snd_weapons[weapIdx].fire_loop
            stop_sound(weapon_handle)
            snd_weapons[weapIdx].fire |> play_sound(snd_weapons[weapIdx].fire_vol) 
        else
            stop_sound(startup_handle) 
            weapon_handle = snd_weapons[weapIdx].fire |> play_sound_loop(snd_weapons[weapIdx].fire_vol) 

def snd_weapon_start_play(weapIdx: int)
    if !snd_weapons[weapIdx].start_loop
        stop_sound(startup_handle) 
        snd_weapons[weapIdx].start |> play_sound(snd_weapons[weapIdx].start_vol) 
    else
        stop_sound(weapon_handle) 
        startup_handle = snd_weapons[weapIdx].start |> play_sound_loop(snd_weapons[weapIdx].start_vol)        

def snd_weapon_end_play(weapIdx: int)
    stop_sound(weapon_handle) 
    snd_weapons[weapIdx].end |> play_sound(snd_weapons[weapIdx].end_vol)


def snd_stop(handle: PlayingSoundHandle)
    stop_sound(handle)    
