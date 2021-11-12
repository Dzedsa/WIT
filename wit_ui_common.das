require dasbox
require graphics
require strings

require wit_utils
require wit_lb
require wit_sound

struct Button
    coord: float4
    text: string
    onClickEvent: function
    parent_name: string
    mouse_hover: bool

var 
    buttons: array<Button>
    main_menu_window_active: bool
    lb_window_active: bool
    help_window_active: bool
    shouldGoPlay: bool
    choose_perk_window_active: bool
    game_over_window_active: bool
    you_died_window_active: bool
    isGameInProgress: bool
    should_record_results_to_lb: bool
    exit_button_step: float
    you_died_timer: float
    you_died_color: uint
    you_died_font_size: float

let
    SAFE_AREA = size_to_srcrn(30.0)
    COLOR_TEXT = 0xFFFFFFFF
    COLOR_HEADER = 0xFFDFBD27
    COLOR_WARNING = 0xFFDF2727
    COLOR_WINDOW_BORDER = 0xFFB3B3B3
    COLOR_BUTTON_HIGHLIGHT = 0xFFFFFFFF
    COLOR_WINDOW =0xD8000000
    COLOR_DARK_TEXT = 0xFF000000

def player_in_menues()
    return (main_menu_window_active || help_window_active || lb_window_active || choose_perk_window_active ||
            game_over_window_active || you_died_window_active)

def interface_init()
    main_menu_window_active = false
    lb_window_active = false
    help_window_active = false
    game_over_window_active = false
    shouldGoPlay = false
    should_record_results_to_lb = false
    exit_button_step = 0.0
    you_died_timer = 3.7
    you_died_color = 0x00660000
    you_died_font_size = 100.0    


def check_buttons_mouse_hover()
    for btn in buttons
        if (get_mouse_position().x > btn.coord.x && get_mouse_position().x < btn.coord.z &&
            get_mouse_position().y > btn.coord.y && get_mouse_position().y < btn.coord.w)
            btn.mouse_hover = true
        else
            btn.mouse_hover = false
            

def check_buttons_mouse_click()
    for btn in buttons
        if btn.mouse_hover && get_mouse_button_down(MB_LEFT)
            snd_button_click_play()
            return btn.onClickEvent
    let fn <- @@ <| ( a : int )
        return 
    return fn


def add_button(coord: float4; text: string; event: function; parent_name: string)
    var btn = [[Button coord = coord, text = text, onClickEvent = event, parent_name = parent_name]]
    for b in buttons
        if b.coord == btn.coord
            return
    push(buttons, btn)

def draw_buttons()    
    check_buttons_mouse_hover()
    for btn in buttons
        let text = btn.text
        let size = get_text_size(text)
        if !btn.mouse_hover
            unfilled_rect(btn.coord, COLOR_BUTTON_HIGHLIGHT)          
            text_out(int((btn.coord.x + btn.coord.z)/2.0 - size.x/2.0), int((btn.coord.y + btn.coord.w)/2.0 - size.y/2.0), text, COLOR_TEXT)
        else
            fill_rect(btn.coord.x, btn.coord.y, btn.coord.z - btn.coord.x, btn.coord.w - btn.coord.y, COLOR_BUTTON_HIGHLIGHT)
            text_out(int((btn.coord.x + btn.coord.z)/2.0 - size.x/2.0), int((btn.coord.y + btn.coord.w)/2.0 - size.y/2.0), text, COLOR_DARK_TEXT)

def draw_window(wnd: float4)    
    fill_rect(wnd.x, wnd.y, wnd.z - wnd.x, wnd.w - wnd.y, COLOR_WINDOW)
    unfilled_rect(wnd, COLOR_WINDOW_BORDER)  

def you_died_window_update(dt: float; player_score: int)
    if you_died_timer > 0.0
        you_died_timer -= dt
        if you_died_timer > 2.8 && you_died_timer < 3.1
            you_died_color += 0x09000000
        if you_died_timer > 0.5 && you_died_timer  < 0.8
            you_died_color -= 0x08000000
        if you_died_timer  <= 0.5
            you_died_color = 0x00000000
        if you_died_timer > 2.1 && you_died_timer < 3.1   
            you_died_font_size += 1.0         
            set_font_size(you_died_font_size)
    else
        you_died_window_active = false
        if player_score > 0
            game_over_window_active = true
        else
            main_menu_window_active = true

        set_font_size(16)    

def go_play()
    shouldGoPlay = true   

def open_lb_window()
    lb_window_active = true
    main_menu_window_active = false

def open_help_window()
    help_window_active = true
    main_menu_window_active = false

def exit_game()
    exit_button_step++
    snd_exit_button_play(int(exit_button_step))

def go_to_main_menu()
    lb_window_active = false
    help_window_active = false
    game_over_window_active = false
    main_menu_window_active = true  

def record_results_to_leaderboard() 
    should_record_results_to_lb = true 

def size_to_srcrn(size: float)
    return float(get_screen_height()/720)*size

def main_menu_window_show()
    draw_window(float4(0.0, 0.0, float(get_screen_width()), float(get_screen_height())))
    var text = "PLAY"     
    var size = get_text_size(text)
    if isGameInProgress
        text = "CONTINUE"
    var btn_coord = float4(float(get_screen_width())/2.0-size.x*3.0, float(get_screen_height())*0.25-size.y*1.5, 
                     float(get_screen_width())/2.0+size.x*3.0, float(get_screen_height())*0.25+size.y*1.5)
    add_button(btn_coord, text, @@go_play, "main_menu_window")   
    btn_coord = float4(float(get_screen_width())/2.0-size.x*3.0, float(get_screen_height())*0.375-size.y*1.5, 
                     float(get_screen_width())/2.0+size.x*3.0, float(get_screen_height())*0.375+size.y*1.5)
    add_button(btn_coord, "LEADERBOARDS", @@open_lb_window, "main_menu_window")    
    btn_coord = float4(float(get_screen_width())/2.0-size.x*3.0, float(get_screen_height())*0.5-size.y*1.5, 
                     float(get_screen_width())/2.0+size.x*3.0, float(get_screen_height())*0.5+size.y*1.5)
    add_button(btn_coord, "HELP & CREDITS", @@open_help_window, "main_menu_window")    
    btn_coord = float4(float(get_screen_width())/2.0-size.x*3.0, float(get_screen_height())*0.625-size.y*1.5+size.y*3.0*exit_button_step, 
                     float(get_screen_width())/2.0+size.x*3.0, float(get_screen_height())*0.625+size.y*1.5+size.y*3.0*exit_button_step)
    add_button(btn_coord, "EXIT", @@exit_game, "main_menu_window")   

def lb_window_show(player_name: string; player_score: int)
    draw_window(float4(0.0, 0.0, float(get_screen_width()), float(get_screen_height())))

    var text = "LEADERBOARDS" 
    var size = get_text_size(text) 
    var line_size = size.y  
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA), text, COLOR_HEADER)

    var idx = 0
    while idx < length(lb_name_arr)
        text_out(int(SAFE_AREA*13.0), int(SAFE_AREA+line_size*float(idx*2+4)), "{idx+1}.", COLOR_TEXT)
        let name = lb_name_arr[idx]
        let name_size = get_text_size(lb_name_arr[idx])
        text_out(get_screen_width()/2-int(name_size.x/2.0), int(SAFE_AREA+line_size*float(idx*2+4)), name, COLOR_TEXT)
        text_out(int(float(get_screen_width())-SAFE_AREA*13.0), int(SAFE_AREA+line_size*float(idx*2+4)), lb_score_arr[idx], COLOR_TEXT)
        idx++

    var i = length(lb_name_arr) + 1
    while i <= 10
        text_out(int(SAFE_AREA*13.0), int(SAFE_AREA+line_size*float(i+1)*2.0), "{i}.", COLOR_TEXT)
        text = "---"
        size = get_text_size(text)      
        text_out(int(float(get_screen_width())/2.0-size.x/2.0), int(SAFE_AREA+line_size*float(i+1)*2.0), text, COLOR_TEXT)
        i++
    if length(lb_name_arr) == 10 && player_score > 0 && player_score < to_int(lb_score_arr[9])
        text = "Last run:"
        size = get_text_size(text)  
        text_out(int(SAFE_AREA*13.0-size.x+get_text_size("10.").x), int(SAFE_AREA+line_size*24.0), text, COLOR_TEXT)
        text = player_name
        size = get_text_size(text)  
        text_out(get_screen_width()/2-int(size.x/2.0), int(SAFE_AREA+line_size*24.0), text, COLOR_TEXT) 
        text_out(int(float(get_screen_width())-SAFE_AREA*13.0), int(SAFE_AREA+line_size*24.0), "{player_score}", COLOR_TEXT)  


    text = "BACK"     
    size = get_text_size(text)
    var btn_coord = float4(float(get_screen_width())*0.9-size.x*2.0, float(get_screen_height())*0.9-size.y*1.5, 
                     float(get_screen_width())*0.9+size.x*2.0, float(get_screen_height())*0.9+size.y*1.5)
    add_button(btn_coord, text, @@go_to_main_menu, "main_menu_window")  

def help_window_show()
    draw_window(float4(0.0, 0.0, float(get_screen_width()), float(get_screen_height())))

    var text = "HELP & CREDITS" 
    var size = get_text_size(text) 
    var line_size = size.y  
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA), text, COLOR_HEADER)
    text = "HOW TO PLAY:" 
    size = get_text_size(text)     
    text_out(int(SAFE_AREA), int(SAFE_AREA+line_size*2.0), text, COLOR_HEADER)
    text = "Kill enemies, collect pickups and new weapons from crates that they drop
Get exp for kills, level up your character, choose powerful perks
Try to kill as many enemies as you can for a higher score"     
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*2.0), text, COLOR_TEXT)

    text = "CONTROLS:"  
    var header_size = get_text_size(text)   
    text_out(int(SAFE_AREA+size.x/2.0-header_size.x/2.0), int(SAFE_AREA+line_size*6.0), text, COLOR_HEADER)
    text = "W,A,S,D - movement, LMB - shoot, from 1 to 8 - switch weapon"     
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*6.0), text, COLOR_TEXT)

    text = "WEAPONS:" 
    header_size = get_text_size(text)    
    text_out(int(SAFE_AREA+size.x/2.0-header_size.x/2.0), int(SAFE_AREA+line_size*8.0), text, COLOR_HEADER)
    text = "(1) Glock19 - default pistol and back up weapon
(2) AK-47 - powerful automatic rifle, average rate of fire, high dmg
(3) SPAS-12 - pump action shotgun, single shot reload system
(4) PZB-39 - anti-tank rifle, bullets penetrate enemies
(5) Bazooka - shoots rockets that explode on impact
(6) Minigun - very high rate of fire, low accuracy, 1 sec warmup before firing, slowes movements when firing
(7) DR-2000 - death ray 2000, shoots laser beam, 1 sec warmup before firing, slowes movements when firing
(8) Ripjack - discs fly through enemies and bounce of the walls, only 6 projectiles allowed at the same time"     
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*8.0), text, COLOR_TEXT)
    
    text = "PICKUPS:"  
    header_size = get_text_size(text)   
    text_out(int(SAFE_AREA+size.x/2.0-header_size.x/2.0), int(SAFE_AREA+line_size*17.0), text, COLOR_HEADER)
    text = "5 health restored; Restore ammo for all your weapons; Huge explosion; +100% shooting speed for your weapons;
Bullet time; Double EXP; Bind enemies in place - marked as yellow box, bonuses are temprory
All weapons - maked as a circle with W in it"     
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*17.0), text, COLOR_TEXT)

    text = "PERKS:"   
    header_size = get_text_size(text) 
    text_out(int(SAFE_AREA+size.x/2.0-header_size.x/2.0), int(SAFE_AREA+line_size*21.0), text, COLOR_HEADER)
    text = "Maximum HP; Reload speed; XP gain; Bonus pickup radius; Pickup drop chance; Ponger pickup bonuses;
Movement speed; Explode on dmg taken; Revive on next death; Regenerate 1 HP; Laser sight"     
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*21.0), text, COLOR_TEXT)

    text = "CHEATS:"   
    header_size = get_text_size(text) 
    text_out(int(SAFE_AREA+size.x/2.0-header_size.x/2.0), int(SAFE_AREA+line_size*24.0), text, COLOR_HEADER)
    text = "ALT+H - Level Up; ALT+J - Immortality; ALT+K - Unlock all weapons; ALT+P - Periodically spawn pickups"    
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*24.0), text, COLOR_TEXT)
    text = "WARNING:"   
    header_size = get_text_size(text)  
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*25.0), text, COLOR_WARNING)  
    text = "using cheats will disable score and leaderboards for this run"    
    text_out(int(SAFE_AREA+size.x+header_size.x), int(SAFE_AREA+line_size*25.0), text, COLOR_TEXT)

    text = "CREDITS:"   
    header_size = get_text_size(text) 
    text_out(int(SAFE_AREA+size.x/2.0-header_size.x/2.0), int(SAFE_AREA+line_size*27.0), text, COLOR_HEADER)
    text = "Originally based on"  
    text_out(int(SAFE_AREA+size.x), int(SAFE_AREA+line_size*27.0), text, COLOR_TEXT)
    var text_size = get_text_size(text) 
    text = "Alexey Borisov's"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*27.0), text, COLOR_HEADER)
    text_size += get_text_size(text) 
    text = "'space_rocks_and_lasers'. Also helped with resource manager"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*27.0), text, COLOR_TEXT)
    text_size = float2(0.0,0.0)
    text = "Dmitry Gordeev"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*28.0), text, COLOR_HEADER)
    text_size += get_text_size(text) 
    text = " - game prototype"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*28.0), text, COLOR_TEXT)
    text_size = float2(0.0,0.0)
    text = "Sergey Kolganov"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*29.0), text, COLOR_HEADER)
    text_size += get_text_size(text) 
    text = " - weapons, perks, pickups, additional enemies, menues, leaderboard,
   sounds, graphics, animations"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*29.0), text, COLOR_TEXT)
    text_size = float2(0.0,0.0)
    text = "Part of Gaijin(c) november 2021 daScript Hackathone"
    text_out(int(SAFE_AREA+size.x+text_size.x), int(SAFE_AREA+line_size*31.0), text, COLOR_TEXT)

    text = "BACK"     
    size = get_text_size(text)
    var btn_coord = float4(float(get_screen_width())*0.9-size.x*2.0, float(get_screen_height())*0.9-size.y*1.5, 
                     float(get_screen_width())*0.9+size.x*2.0, float(get_screen_height())*0.9+size.y*1.5)
    add_button(btn_coord, text, @@go_to_main_menu, "main_menu_window")  

def you_died_window_show()    
    draw_window(float4(0.0, 0.0, float(get_screen_width()), float(get_screen_height())))

    var text = "YOU DIED" 

    var size = get_text_size(text) 
    var line_size = size.y  
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(float(get_screen_height())*0.5 - size.y/2.0), text, you_died_color)

def game_over_window_show(score: int; time: float)    
    draw_window(float4(0.0, 0.0, float(get_screen_width()), float(get_screen_height())))

    var text = "LEADERBOARDS" 
    var size = get_text_size(text) 
    var line_size = size.y  
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA), text, COLOR_HEADER)

    text = "Score: {score}, Time: {time}" 
    size = get_text_size(text) 
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA+line_size*4.0), text, COLOR_TEXT)  

    text = "Enter your name for the leaderboards:" 
    size = get_text_size(text) 
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA+line_size*10.0), text, COLOR_TEXT)  
    text = player_name
    while length(text) < 16
        text += "_" 
    size = get_text_size(text) 
    text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA+line_size*12.0), text, COLOR_TEXT) 

    if length(player_name) < 3
        text = "(name have to be at least 3 symbols)" 
        size = get_text_size(text) 
        text_out(int(float(get_screen_width())*0.5 - size.x/2.0), int(SAFE_AREA+line_size*14.0), text, COLOR_TEXT)  
    else
        text = "Confirm"     
        size = get_text_size(text)
        var btn_coord = float4(float(get_screen_width())*0.5-size.x*2.0, SAFE_AREA+line_size*20.0, 
                            float(get_screen_width())*0.5+size.x*2.0, SAFE_AREA+line_size*20.0+size.y*3.0)
        add_button(btn_coord, text, @@record_results_to_leaderboard, "game_over_window")      



    text = "Cancel"     
    size = get_text_size(text)
    var btn_coord = float4(float(get_screen_width())*0.8-size.x*2.0, float(get_screen_height())*0.9-size.y*1.5, 
                     float(get_screen_width())*0.8+size.x*2.0, float(get_screen_height())*0.9+size.y*1.5)
    add_button(btn_coord, text, @@go_to_main_menu, "main_menu_window")  


