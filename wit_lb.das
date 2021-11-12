require daslib/media
require fio


var
    lb_name_arr: array<string>
    lb_score_arr: array<string>
    player_name: string

def lb_init()
    clear(lb_name_arr)
    clear(lb_score_arr)
    player_name = local_storage_get("lb_last_used_name") 
    var check_first_name_length = length(local_storage_get("lb_name_1"))
    if  check_first_name_length <= 0 
        local_storage_set("lb_name_1", "Dzed")    
        local_storage_set("lb_name_2", "Dzedich")    
        local_storage_set("lb_name_3", "NAGIBATOR666")    
        local_storage_set("lb_name_4", "Hildpld")    
        local_storage_set("lb_name_5", "Dzedochka")    
        local_storage_set("lb_name_6", "CrimsonBlend")     
        local_storage_set("lb_name_7", "YOMAMA")     
        local_storage_set("lb_name_8", "JustBetterThanYou")     
        local_storage_set("lb_name_9", "Jesus2005")
        local_storage_set("lb_score_1", "2146")    
        local_storage_set("lb_score_2", "1317")    
        local_storage_set("lb_score_3", "1089")    
        local_storage_set("lb_score_4", "920")    
        local_storage_set("lb_score_5", "673")    
        local_storage_set("lb_score_6", "426")    
        local_storage_set("lb_score_7", "357")    
        local_storage_set("lb_score_8", "269")    
        local_storage_set("lb_score_9", "114")
    for i in range(1,11)
        let name_key = "lb_name_{i}"
        let name = local_storage_get(name_key)
        let score = local_storage_get("lb_score_{i}")
        if length(name) > 0
            push(lb_name_arr, name)
            push(lb_score_arr, score)
        else
            break

def lb_update(player_name: string; var score: int)
    var got_to_the_lb = false
    var name = player_name   
    if score > 0             
        var idx = 0
        while idx < length(lb_name_arr)
            if score >= to_int(lb_score_arr[idx])
                let temp_score = to_int(lb_score_arr[idx])
                let temp_name = lb_name_arr[idx]
                lb_score_arr[idx] = string(score) 
                lb_name_arr[idx] = name    
                score = temp_score
                name = temp_name
                got_to_the_lb = true
            idx++
        if idx < 10 
            push(lb_score_arr,string(score))
            push(lb_name_arr,name)
            got_to_the_lb = true  
    return got_to_the_lb

def lb_save(name_arr: array<string>; score_arr: array<string>) 
    local_storage_set("lb_last_used_name", player_name)
    var idx = 0
    while idx < length(name_arr) 
        local_storage_set("lb_name_{idx+1}", name_arr[idx])    
        local_storage_set("lb_score_{idx+1}", score_arr[idx]) 
        idx++
