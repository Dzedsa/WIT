require dasbox
require graphics
require daslib/random
require math

require wit_ui_common
require wit_utils

struct Perk
    id: int
    desc: string
    weight: float
    unique: bool

var 
    level_exp: array<int>
    perks_list: array<Perk>
    perks_to_apply: array<int>

let
    MAX_LEVEL = 100
    PERKS_PER_LEVEL = 2

def setup_level_exp()
    var lvl = 1
    var exp_add = 10
    var prevLvlExp = 0
    while lvl < MAX_LEVEL
        var exp = prevLvlExp + exp_add * (1 + int(float(lvl) / 10.0) * 2)
        push(level_exp, exp)
        prevLvlExp = exp
        lvl++

def perks_init()
    setup_level_exp()
    clear(perks_list)
    create_perks_list()
    

def create_perks_list()
    var perksCount = MAX_LEVEL-1
    perksCount *= PERKS_PER_LEVEL

    var perk_types: array<Perk>
    var p = [[Perk id = 1, desc = "Maximum HP +10", weight = 1.0]] 
    push(perk_types, p)
    p = [[Perk id = 2, desc = "Reload speed +50%", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 3, desc = "+100% XP gain", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 4, desc = "+100% bonus pickup radius", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 5, desc = "+100% pickup drop chance", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 6, desc = "+50% longer pickup bonuses", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 7, desc = "+20% movement speed", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 8, desc = "Explode on dmg taken, +50% to radius", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 9, desc = "Revive on next death with 5 HP", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 10, desc = "Regenerate 1 HP each 20 seconds", weight = 1.0]]
    push(perk_types, p)
    p = [[Perk id = 11, desc = "Laser sight", unique = true, weight = 0.3]]
    push(perk_types, p)

    var avgWeight = get_avg_weight_from_struct_array(perk_types)
    while length(perks_list) < perksCount
        var temp_arr: array<Perk>
        for tp in perk_types
            if tp.weight >= random_float(seed) * avgWeight
                var num = max(int(tp.weight / avgWeight),1)
                if tp.weight / avgWeight - float(num) > random_float(seed)
                    num++
                if tp.unique
                    num = 1
                    tp.weight = -1.0
                while num > 0
                    push(temp_arr, tp)
                    num--                 
        shuffle_array(temp_arr)
        for tp in temp_arr
            push(perks_list, tp)



def close_perk_window()
    choose_perk_window_active = false
    erase(perks_list, 0)
    erase(perks_list, 0)

def choose_perk1()
    push(perks_to_apply,perks_list[0].id)
    close_perk_window()        

def choose_perk2()     
    push(perks_to_apply,perks_list[1].id)  
    close_perk_window()   

def check_perk_window_shortcuts()
    if get_key_down(VK_Q)  
        choose_perk1()
        return  
    if get_key_down(VK_E)    
        choose_perk2()
        return              

def perks_window_show()
    var wnd = float4(SAFE_AREA * 4.0, SAFE_AREA * 4.0, float(get_screen_width()) - SAFE_AREA * 4.0, float(get_screen_height()) - SAFE_AREA * 4.0)
    draw_window(wnd)

    var text = "New level reached!"
    var size = get_text_size(text)
    text_out(int(get_screen_width()/2 - int(size.x/2.0)), int(SAFE_AREA * 4.5), text, COLOR_TEXT)
    text = "Choose your new perk:"
    size = get_text_size(text)
    text_out(int(get_screen_width()/2 - int(size.x/2.0)), int(SAFE_AREA * 5.5), text, COLOR_TEXT)

    text = perks_list[0].desc 
    size = get_text_size(text)
    text_out(int(wnd.x + (wnd.z-wnd.x)*0.25 - size.x/2.0), int(wnd.y + (wnd.w - wnd.y)/3.0), text, COLOR_TEXT)
    text = perks_list[1].desc 
    size = get_text_size(text)
    text_out(int(wnd.x + (wnd.z-wnd.x)*0.75 - size.x/2.0), int(wnd.y + (wnd.w - wnd.y)/3.0), text, COLOR_TEXT)

    text = "Choose (Q)" 
    size = get_text_size(text)
    var btn_coord = float4(wnd.x + (wnd.z-wnd.x)*0.25 - size.x/2.0*2.0, wnd.y + (wnd.w - wnd.y)*0.75 - size.y/2.0*2.0, 
                     wnd.x + (wnd.z-wnd.x)*0.25 + size.x/2.0*2.0, wnd.y + (wnd.w - wnd.y)*0.75 + size.y/2.0*2.0)
    add_button(btn_coord, text, @@choose_perk1, "perks_window")
    text = "Choose (E)" 
    btn_coord = float4(wnd.x + (wnd.z-wnd.x)*0.75 - size.x/2.0*2.0, wnd.y + (wnd.w - wnd.y)*0.75 - size.y/2.0*2.0, 
                     wnd.x + (wnd.z-wnd.x)*0.75 + size.x/2.0*2.0, wnd.y + (wnd.w - wnd.y)*0.75 + size.y/2.0*2.0)
    add_button(btn_coord, text, @@choose_perk2, "perks_window")            