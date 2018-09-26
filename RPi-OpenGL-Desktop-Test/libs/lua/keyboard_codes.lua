-- GLSL Hacker keyboard codes

-- letters
KC_A            = 30
KC_B            = 48
KC_C            = 46
KC_D            = 32
KC_E            = 18
KC_F            = 33
KC_G            = 34
KC_H            = 35
KC_I            = 23
KC_J            = 36
KC_K            = 37
KC_L            = 38
KC_M            = 50
KC_N            = 49
KC_O            = 24
KC_P            = 25
KC_Q            = 16
KC_R            = 19
KC_S            = 31
KC_T            = 20
KC_U            = 22
KC_V            = 47
KC_W            = 17
KC_X            = 45
KC_Y            = 21
KC_Z            = 44

-- numbers (top)
KC_1            =  2
KC_2            =  3
KC_3            =  4
KC_4            =  5
KC_5            =  6
KC_6            =  7
KC_7            =  8
KC_8            =  9
KC_9            = 10
KC_0            = 11

-- arrows
-- OSX platform.
KC_UP           = 200
KC_LEFT         = 203
KC_RIGHT        = 205
KC_DOWN         = 208

--[[  
-- Override for Windows platform.
if (gh_utils.get_platform() == 1) then
  KC_UP           = 72
  KC_DOWN         = 80
  KC_RIGHT        = 77
  KC_LEFT         = 75
end
--]]
-- FXX keys
KC_F1           = 59
KC_F2           = 60
KC_F3           = 61
KC_F4           = 62
KC_F5           = 63
KC_F6           = 64
KC_F7           = 65
KC_F8           = 66
KC_F9           = 67
KC_F10          = 68
KC_F11          = 87
KC_F12          = 88

-- others
KC_SPACE        = 57
KC_LEFT_SHIFT   = 42
KC_RIGHT_SHIFT  = 54
KC_ESCAPE       =  1
KC_BACK         = 14
KC_TAB          = 15
KC_RETURN       = 28
KC_PGDOWN       = 209
KC_PGUP         = 201
KC_HOME         = 199
KC_END          = 207
KC_INSERT       = 210
KC_DELETE       = 211

KC_LEFT_CTRL    = 29
KC_RIGHT_CTRL   = 157
KC_LEFT_ALT     = 56
KC_RIGHT_ALT    = 184
KC_CAPITAL      = 58
KC_SCROLL       = 70

-- Left and right Windows keys.
KC_LWIN         = 219
KC_RWIN         = 220

KC_APPS         = 221
KC_SLEEP        = 223

-- Numeric keypad.
KC_ADD         = 78
KC_SUBTRACT    = 74
KC_MULTIPLY    = 55
KC_DIVIDE      = 181
KC_NUMLOCK     = 69
KC_NUMPAD1     = 79
KC_NUMPAD2     = 80
KC_NUMPAD3     = 81
KC_NUMPAD4     = 75
KC_NUMPAD5     = 76
KC_NUMPAD6     = 77
KC_NUMPAD7     = 71
KC_NUMPAD8     = 72
KC_NUMPAD9     = 73
KC_NUMPAD0     = 82
KC_NUMPAD_ENTER = 156

KC_DECIMAL     = 83
