require daslib/media

require wit_utils
require wit_ui_common

struct MapObj
    img: ImageHandle
    pos: float2
    sizeMul: float

struct Anim2d
    curFrameImg: ImageHandle
    curFrameIdx: int
    pos: float2
    size: float2
    angle: float
    color: uint
    speed: float
    timer: float
    
struct Puddle
    img: ImageHandle
    radius: float
    pos: float2
    lifeTime: float
    lifeTime_max: float
    color: uint
    angle: float


var
    img_player: array<ImageHandle>
    img_enemies: array<ImageHandle>
    img_map: ImageHandle
    img_pickup: ImageHandle
    img_weapon_fire_fx: ImageHandle
    map_obj_list: array<MapObj>
    img_weapon_icons: array<ImageHandle>
    img_enemy_hits: array<ImageHandle>
    img_blood_puddle: array<ImageHandle>
    img_enemy_deaths: array<ImageHandle>
    img_explosions: array<ImageHandle>
    anim_enemy_hits: array<Anim2d>
    anim_enemy_deaths: array<Anim2d>
    //img_test: ImageHandle
    puddles: array<Puddle>
    img_main_menu_bg: ImageHandle  

def graphics_init()
    img_player |> emplace(create_managed_image("assets/player_pistol.png", true))
    img_player |> emplace(create_managed_image("assets/player_rifle.png", true))
    img_player |> emplace(create_managed_image("assets/player_minigun.png", true))

    
    for i in range(0,8)
        img_enemies |> emplace(create_managed_image("assets/zombie1_{i+1}.png", true))

    for i in range(0,14)
        img_enemy_deaths |> emplace(create_managed_image("assets/blood/death{i+1}.png", true))

    for i in range(0,2)
        img_blood_puddle |> emplace(create_managed_image("assets/blood/blood_pool{i+1}.png", true))

    for i in range(0,7)
        img_enemy_hits |> emplace(create_managed_image("assets/blood/hit{i+1}.png", true))

    for i in range(0,35)
        img_explosions |> emplace(create_managed_image("assets/explosion/exp{i+1}.png", true))

    img_map = create_managed_image("assets/groundv1_01.jpg", true)
    for i in range(0,10)
        var idx = random_int(seed) % 2
        var mapObj <- [[MapObj img = create_managed_image("assets/plant{idx+1}.png", true),
                        pos = float2(float(get_screen_width())*random_float(seed), float(get_screen_height())*random_float(seed)), sizeMul = (random_float(seed)*0.4+0.8)*0.1]]
        emplace(map_obj_list, mapObj)

    img_pickup <- create_managed_image("assets/box.jpg")    
    emplace(img_weapon_icons, create_managed_image("assets/w_pistol.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_ak47.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_shotgun.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_pzb39.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_bazooka.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_minigun.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_dr2000.png"))
    emplace(img_weapon_icons, create_managed_image("assets/w_ripjack.png"))

    img_weapon_fire_fx <- create_managed_image("assets/w_fire_fx.png")
    img_main_menu_bg <- create_managed_image("assets/doom_vs_zombie_army_poster.png")

    //img_test <- create_image("assets/.png")


    


//player
def draw_player(pos: float2; angle:float; idx:int) 
    if length(img_player) > idx
        img_player[idx] |> draw_image_transformed(pos.x, pos.y,float4(0,0,img_player[idx].width,img_player[idx].height),
                                                0xFFFFFFFF, float2(img_player[idx].width,img_player[idx].height)*0.9, -(angle-90.0/180.0*PI))

def draw_weapon_fire_fx(pos: float2; angle: float)
    img_weapon_fire_fx |> draw_image_transformed(pos.x, pos.y,float4(0.0,0.0,float(img_weapon_fire_fx.width),float(img_weapon_fire_fx.height)),
                                                0xFFFFFFFF, float2(img_weapon_fire_fx.width,img_weapon_fire_fx.height)*0.5, -(angle-90.0/180.0*PI))
                                            
//enemies
def set_enemy_anim(var a: Anim2d; pos: float2; sizeMul: float; color:uint)
    let img_size = float2(float(img_enemies[0].width), float(img_enemies[0].height))
    a := [[Anim2d curFrameImg := img_enemies[0], pos = pos, size = img_size*sizeMul, angle = 0.0, color = color, curFrameIdx = 1, speed = 1.0/10.0, timer = 1.0/10.0]]

def draw_enemy(a: Anim2d)
    a.curFrameImg |> draw_image_transformed(a.pos.x,a.pos.y, float4(0,0,a.curFrameImg.width,a.curFrameImg.height),
                                            a.color, a.size, a.angle+180.0/180.0*PI)


//hit animation
def add_enemy_hit_anim(pos: float2; sizeMul: float; color: uint; angle: float)
    let img_size = float2(float(img_enemy_hits[0].width), float(img_enemy_hits[0].height))
    var hitAnim <- [[Anim2d curFrameImg := img_enemy_hits[0], pos = pos, size = img_size * sizeMul, curFrameIdx = 1,
                    color = color, speed = 1.0/60.0, timer = 1.0/60.0, angle = angle]]
    emplace(anim_enemy_hits, hitAnim)

def update_enemy_hits(dt: float)
    var idx = 0
    while idx < length(anim_enemy_hits) 
        if anim_enemy_hits[idx].timer > 0.0
            anim_enemy_hits[idx].timer -= dt
        else
            anim_enemy_hits[idx].timer = anim_enemy_hits[idx].speed 
            anim_enemy_hits[idx].curFrameIdx++
            if anim_enemy_hits[idx].curFrameIdx < length(img_enemy_hits) 
                anim_enemy_hits[idx].curFrameImg := img_enemy_hits[anim_enemy_hits[idx].curFrameIdx]
            else
                puddle_add(anim_enemy_hits[idx].pos, size_to_srcrn(7.5), 10.0, anim_enemy_hits[idx].color)
                erase(anim_enemy_hits, idx) 
        idx++

def draw_enemy_hits() 
    var idx = 0
    while idx < length(anim_enemy_hits)      
        anim_enemy_hits[idx].curFrameImg |> draw_image_transformed(anim_enemy_hits[idx].pos.x,anim_enemy_hits[idx].pos.y,
                                                                    float4(0,0,anim_enemy_hits[idx].curFrameImg.width,anim_enemy_hits[idx].curFrameImg.height),
                                                                    anim_enemy_hits[idx].color, anim_enemy_hits[idx].size, anim_enemy_hits[idx].angle-135.0/180.0*PI)               
        idx++

//death animation
def add_enemy_death_anim(pos: float2; sizeMul: float; color: uint)
    let img_size = float2(img_enemy_deaths[0].width, img_enemy_deaths[0].height)
    var deathAnim <- [[Anim2d curFrameImg := img_enemy_deaths[0], pos = pos-img_size * sizeMul*0.5, size = img_size * sizeMul,
                        curFrameIdx = 1, color = color, speed = 1.0/60.0, timer = 1.0/60.0]]
    emplace(anim_enemy_deaths, deathAnim)

def update_enemy_deaths(dt: float)
    var idx = 0
    while idx < length(anim_enemy_deaths)
        if anim_enemy_deaths[idx].timer > 0.0
            anim_enemy_deaths[idx].timer -= dt
        else
            anim_enemy_deaths[idx].timer = anim_enemy_deaths[idx].speed
            anim_enemy_deaths[idx].curFrameIdx++
            if anim_enemy_deaths[idx].curFrameIdx < length(img_enemy_deaths)        
                anim_enemy_deaths[idx].curFrameImg := img_enemy_deaths[anim_enemy_deaths[idx].curFrameIdx]              
            else
                erase(anim_enemy_deaths, idx)
        idx++

def draw_enemy_deaths() 
    var idx = 0
    while idx < length(anim_enemy_deaths)
        anim_enemy_deaths[idx].curFrameImg |> draw_image(anim_enemy_deaths[idx].pos.x, anim_enemy_deaths[idx].pos.y,
                                                        anim_enemy_deaths[idx].color, anim_enemy_deaths[idx].size)         
        idx++

//blood puddle methods
def puddle_add(var pos: float2; radius: float; lifeTime: float; color: uint)
    let angle = random_float(seed)*360.0/180.0*PI
    let imgIdx = random_int(seed) % length(img_blood_puddle)
    var p <- [[Puddle img:=img_blood_puddle[imgIdx], radius=radius, pos=pos, lifeTime=lifeTime, lifeTime_max=lifeTime, color=color, angle = angle]]
    emplace(puddles, p)

def puddle_update(dt: float)
    for p in puddles
        p.lifeTime -= dt

def puddle_render(var p: Puddle)
    let sizeMul = p.radius/size_to_srcrn(26.0)
    p.img |> draw_image_transformed(p.pos.x, p.pos.y, float4(0,0,p.img.width,p.img.height), p.color, float2(p.img.width,p.img.height)*sizeMul, p.angle) 

//weapons
def set_explosion_anim(var a: Anim2d; pos: float2; radius: float)
    let img_size = float2(img_explosions[0].width, img_explosions[0].height)
    a := [[Anim2d curFrameImg := img_explosions[0], pos = pos, size = float2(radius*2.5,radius*2.5), curFrameIdx = 1, speed = 1.0/60.0, timer = 1.0/60.0]]

def update_explosion_anim(var a: Anim2d; dt: float)
    if a.timer > 0.0
        a.timer -= dt
    else
        a.timer = a.speed
        a.curFrameIdx++ 
        a.curFrameImg := img_explosions[a.curFrameIdx]

def draw_explosion_anim(var a: Anim2d) 
    if a.curFrameIdx < length(img_explosions)
        a.curFrameImg |> draw_image_transformed(a.pos.x,a.pos.y, float4(0,0,a.curFrameImg.width,a.curFrameImg.height), 0xFFFFFFFF, a.size, 0.0)


//map
def draw_map()
    let imgSizeMul = 1.0 
    var x = 0.0
    while x < float(get_screen_width())
        var y = 0.0
        while y < float(get_screen_width())
            img_map |> draw_image(x, y, 0xFF1B1B1B)
            y += float(img_map.height)
        x += float(img_map.width)

    var idx = 0
    while idx < length(map_obj_list)
        map_obj_list[idx].img |> draw_image(map_obj_list[idx].pos.x, map_obj_list[idx].pos.y, 0xFF2E2E2E,
                                            float2(map_obj_list[idx].img.width,map_obj_list[idx].img.width)*map_obj_list[idx].sizeMul)
        idx++

//pickups
def draw_pickup_box(pos: float2; box_size: float)      
    img_pickup |> draw_image(pos.x, pos.y, 0xFFFFFFFF, float2(box_size,box_size))

def draw_weapon_pickup(wIdx:int; pos: float2; box_size)
    img_weapon_icons[wIdx] |> draw_image(pos.x, pos.y, 0xFFFFFFFF, float2(box_size,box_size))

def draw_main_menu_img() 
    img_main_menu_bg |>  draw_image(0.0, float(get_screen_height()) - float(img_main_menu_bg.height)*0.6, 0xFFFFFFFF, float2(img_main_menu_bg.width,img_main_menu_bg.height)*0.6)   



