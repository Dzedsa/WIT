require dasbox
require graphics
require math
require daslib/random
require strings

def get_typed_keyboard_symbol()
    if get_key(VK_LSHIFT) && get_key_down(VK_Q)
        return "Q"
    if get_key_down(VK_Q)
        return "q"
    if get_key(VK_LSHIFT) && get_key_down(VK_W)
        return "W"
    if get_key_down(VK_W)
        return "w"
    if get_key(VK_LSHIFT) && get_key_down(VK_E)
        return "E"
    if get_key_down(VK_E)
        return "e"
    if get_key(VK_LSHIFT) && get_key_down(VK_R)
        return "R"
    if get_key_down(VK_R)
        return "r"
    if get_key(VK_LSHIFT) && get_key_down(VK_T)
        return "T"
    if get_key_down(VK_T)
        return "t"
    if get_key(VK_LSHIFT) && get_key_down(VK_Y)
        return "Y"
    if get_key_down(VK_Y)
        return "y"
    if get_key(VK_LSHIFT) && get_key_down(VK_U)
        return "U"
    if get_key_down(VK_U)
        return "u"
    if get_key(VK_LSHIFT) && get_key_down(VK_I)
        return "I"
    if get_key_down(VK_I)
        return "i"
    if get_key(VK_LSHIFT) && get_key_down(VK_O)
        return "O"
    if get_key_down(VK_O)
        return "o"
    if get_key(VK_LSHIFT) && get_key_down(VK_P)
        return "P"
    if get_key_down(VK_P)
        return "p"
    if get_key(VK_LSHIFT) && get_key_down(VK_A)
        return "A"
    if get_key_down(VK_A)
        return "a"
    if get_key(VK_LSHIFT) && get_key_down(VK_S)
        return "S"
    if get_key_down(VK_S)
        return "s"
    if get_key(VK_LSHIFT) && get_key_down(VK_D)
        return "D"
    if get_key_down(VK_D)
        return "d"
    if get_key(VK_LSHIFT) && get_key_down(VK_F)
        return "F"
    if get_key_down(VK_F)
        return "f"
    if get_key(VK_LSHIFT) && get_key_down(VK_G)
        return "G"
    if get_key_down(VK_G)
        return "g"
    if get_key(VK_LSHIFT) && get_key_down(VK_H)
        return "H"
    if get_key_down(VK_H)
        return "h"
    if get_key(VK_LSHIFT) && get_key_down(VK_J)
        return "J"
    if get_key_down(VK_J)
        return "j"
    if get_key(VK_LSHIFT) && get_key_down(VK_K)
        return "K"
    if get_key_down(VK_K)
        return "k"
    if get_key(VK_LSHIFT) && get_key_down(VK_L)
        return "L"
    if get_key_down(VK_L)
        return "l"
    if get_key(VK_LSHIFT) && get_key_down(VK_Z)
        return "Z"
    if get_key_down(VK_Z)
        return "z"
    if get_key(VK_LSHIFT) && get_key_down(VK_X)
        return "X"
    if get_key_down(VK_X)
        return "x"
    if get_key(VK_LSHIFT) && get_key_down(VK_C)
        return "C"
    if get_key_down(VK_C)
        return "c"
    if get_key(VK_LSHIFT) && get_key_down(VK_V)
        return "V"
    if get_key_down(VK_V)
        return "v"
    if get_key(VK_LSHIFT) && get_key_down(VK_B)
        return "B"
    if get_key_down(VK_B)
        return "b"
    if get_key(VK_LSHIFT) && get_key_down(VK_N)
        return "N"
    if get_key_down(VK_N)
        return "n"
    if get_key(VK_LSHIFT) && get_key_down(VK_M)
        return "M"
    if get_key_down(VK_M)
        return "m"
    if get_key_down(VK_1)
        return "1"
    if get_key_down(VK_2)
        return "2"
    if get_key_down(VK_3)
        return "3"
    if get_key_down(VK_4)
        return "4"
    if get_key_down(VK_5)
        return "5"
    if get_key_down(VK_6)
        return "6"
    if get_key_down(VK_7)
        return "7"
    if get_key_down(VK_8)
        return "8"
    if get_key_down(VK_9)
        return "9"
    if get_key_down(VK_0)
        return "0"
    return ""
