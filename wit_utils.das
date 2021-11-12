require daslib/random
require math
require graphics

var
    seed: int4

def shuffle_array(var arr:array<auto>)
    var idx = length(arr) - 1
    while idx > 0
        var newIdx = random_int(seed) % idx
        var arr_temp = arr[idx]
        arr[idx] = arr[newIdx]
        arr[newIdx] = arr_temp
        idx--

def setup_random_seed()        
    seed = random_seed(int(ref_time_ticks()))

def unfilled_rect(rect: float4; color: uint)    
    line(rect.x, rect.y, rect.z, rect.y, color)
    line(rect.x, rect.y, rect.x, rect.w, color)
    line(rect.z, rect.w, rect.x, rect.w, color)
    line(rect.z, rect.w, rect.z, rect.y, color)

def get_avg_weight_from_struct_array(arr: array<auto>)    
    var count = 0.0
    var weightSum = 0.0
    for i in arr   
        if i.weight > 0.0
            weightSum += i.weight
            count++
    if count > 0.0
        return weightSum/count 
    else
        return 1.0

def get_diagonal(x:float; y: float)        
    return sqrt(x*x+y*y)

def turn_vect(vect: float2; angle: float)    
    var newAngle = atan2(vect.x, vect.y) + angle/180.0*PI
    return float2(sin(newAngle), cos(newAngle))
