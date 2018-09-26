--[[
local modname = "CameraMod"
local M = {}
_G[modname] = M
package.loaded[modname] = M
local _G = _G
setmetatable(M, {__index = _G})
setfenv(1, M)
--]]

local M = module("mod_camera", package.seeall)

local mathmod = require "mod_math"

--[[
=======================================================================
============  GLSL Hacker CAMERA  functions  ==========================
=======================================================================
--]]

M._do_rotate = 0
M._camera_old_mouse_x = 0
M._camera_old_mouse_y = 0
M._orbit_yaw = 0
M._orbit_pitch = 0
M._keyboard_speed = 20

function M._init_camera_orbit(camera, x, y)
	_camera_old_mouse_x = x
	_camera_old_mouse_y = y
end

function M._init_camera_angles(camera, pitch, yaw)
	_orbit_yaw = yaw
	_orbit_pitch = pitch
end


function M._rotate_camera_position_around_point(camera, lookat_point_x, lookat_point_y, lookat_point_z, pitch, yaw, roll)
	local cam_pos_x, cam_pos_y, cam_pos_z = gh_object.get_position(camera)
		
	local vx = cam_pos_x - lookat_point_x
	local vy = cam_pos_y - lookat_point_y
	local vz = cam_pos_z - lookat_point_z

	local angX = pitch * mathmod._PI_OVER_180
	local angY = yaw * mathmod._PI_OVER_180
	local angZ = roll * mathmod._PI_OVER_180

	local mag = math.sqrt(vx*vx + vy*vy + vz*vz)

	local new_cam_pos_x = lookat_point_x + mag * math.cos(angY) * math.cos(angX)
	local new_cam_pos_y = lookat_point_y + mag * math.sin(angX)
	local new_cam_pos_z = lookat_point_z + mag * math.sin(angY) * math.cos(angX)

	gh_camera.set_position(camera, new_cam_pos_x, new_cam_pos_y, new_cam_pos_z)
  gh_camera.set_lookat(camera, lookat_point_x, lookat_point_y, lookat_point_z, 1)
end

function M._rotate_camera_orbit(camera, x, y, lookat_x, lookat_y, lookat_z)
	local dx = x - _camera_old_mouse_x
	local dy = y - _camera_old_mouse_y

	_camera_old_mouse_x = x
	_camera_old_mouse_y = y

	local dyaw = dx * 0.1
	local dpitch = dy * 0.1

	_orbit_yaw = _orbit_yaw + dyaw
	_orbit_pitch = _orbit_pitch + dpitch
	
	if (_orbit_pitch >= 80.0) then
		_orbit_pitch = 80.0
	end
	
	if (_orbit_pitch <= -80.0) then
		_orbit_pitch = -80.0
	end

	_rotate_camera_position_around_point(camera, lookat_x, lookat_y, lookat_z, _orbit_pitch, _orbit_yaw, 0.0)
end

function M.DoCameraOrbit(camera, lookat_x, lookat_y, lookat_z)
	local LEFT_BUTTON = 1
	local is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
	if ((is_down == 1) and (_do_rotate == 0)) then
		local mx
		local my
		mx, my = gh_input.mouse_getpos()
		_init_camera_orbit(camera, mx, my)
		_do_rotate = 1
	end
	
	if (is_down == 0) then
		_do_rotate = 0
	end
	
	if (_do_rotate == 1) then
		local mx
		local my
		mx, my = gh_input.mouse_getpos()
		
		if ((mx ~= _camera_old_mouse_x) or (my ~= _camera_old_mouse_y)) then
			--_rotate_camera_orbit(camera, mx, my, lookat_x, lookat_y, lookat_z)
			
			local cam_lookat = mathmod.new_vec3()
			cam_lookat:set(lookat_x, lookat_y, lookat_z)
			_rotate_camera_orbit_v2(camera, mx, my, cam_lookat)
		end
	end
end





function M._rotate_camera_position_around_point_v2(camera, lookat_point, pitch, yaw, roll)
	local cam_pos = mathmod.new_vec3()
	cam_pos.x, cam_pos.y, cam_pos.z = gh_object.get_position(camera)
		
	local v = mathmod.new_vec3()
	v = cam_pos - lookat_point
	
	local angX = pitch * mathmod._PI_OVER_180
	local angY = yaw * mathmod._PI_OVER_180
	local angZ = roll * mathmod._PI_OVER_180

	local mag = v:len()

	local new_cam_pos_x = lookat_point.x + mag * math.cos(angY) * math.cos(angX)
	local new_cam_pos_y = lookat_point.y + mag * math.sin(angX)
	local new_cam_pos_z = lookat_point.z + mag * math.sin(angY) * math.cos(angX)

	gh_camera.set_position(camera, new_cam_pos_x, new_cam_pos_y, new_cam_pos_z)
	gh_camera.set_lookat(camera, lookat_point.x, lookat_point.y, lookat_point.z, 1)
end

function M._rotate_camera_orbit_v2(camera, x, y, cam_lookat)
	local dx = x - _camera_old_mouse_x
	local dy = y - _camera_old_mouse_y

	_camera_old_mouse_x = x
	_camera_old_mouse_y = y

	local dyaw = dx * 0.1
	local dpitch = dy * 0.1

	_orbit_yaw = _orbit_yaw + dyaw
	_orbit_pitch = _orbit_pitch + dpitch
	
	if (_orbit_pitch >= 80.0) then
		_orbit_pitch = 80.0
	end
	
	if (_orbit_pitch <= -80.0) then
		_orbit_pitch = -80.0
	end

	_rotate_camera_position_around_point_v2(camera, cam_lookat, _orbit_pitch, _orbit_yaw, 0.0)
end

function M.DoCameraOrbit_v2(camera, cam_lookat)
	local LEFT_BUTTON = 1
	local is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
	if ((is_down == 1) and (_do_rotate == 0)) then
		local mx
		local my
		mx, my = gh_input.mouse_getpos()
		_init_camera_orbit(camera, mx, my)
		_do_rotate = 1
	end
	
	if (is_down == 0) then
		_do_rotate = 0
	end
	
	if (_do_rotate == 1) then
		local mx
		local my
		mx, my = gh_input.mouse_getpos()
		
		if ((mx ~= _camera_old_mouse_x) or (my ~= _camera_old_mouse_y)) then
			_rotate_camera_orbit_v2(camera, mx, my, cam_lookat)
		end
	end
end


function M.InitCameraRotation(camera, cam_lookat, pitch, yaw)
	M._init_camera_angles(camera, pitch, yaw)
	M._rotate_camera_position_around_point_v2(camera, cam_lookat, pitch, yaw, 0)
end


function M.CameraMoveAlongView(camera, dist_x, dist_y, dist_z)
	local px, py, pz = gh_camera.get_position(camera)
	local vx, vy, vz = gh_camera.get_view_vector(camera)
	px = px + (vx * dist_x)
	py = py + (vy * dist_y)
	pz = pz + (vz * dist_z)
	gh_camera.set_position(camera, px, py, pz)
end

function M.CameraRotateView(camera, pitch, yaw)
  gh_camera.set_yaw(camera, yaw)
  gh_camera.set_pitch(camera, pitch)
end

function M.CameraStrafe(camera, dist)
	local v = mathmod.new_vec3()
	local u = mathmod.new_vec3()
	v.x, v.y, v.z = gh_camera.get_view_vector(camera)
  v:neg()
	u.x, u.y, u.z = gh_camera.get_up_vector(camera)
  local xvec = v:cross(u)
  local p = mathmod.new_vec3()
	p.x, p.y, p.z = gh_camera.get_position(camera)
  p = p + (xvec * dist)
	gh_camera.set_position(camera, p.x, p.y, p.z)
end

function M.CameraStrafe_V(camera, dist)
  -- Vertical strafe
	local v = mathmod.new_vec3()
	local u = mathmod.new_vec3()
	v.x, v.y, v.z = gh_camera.get_view_vector(camera)
  v:neg()
	u.x, u.y, u.z = gh_camera.get_up_vector(camera)
  local xvec = v:cross(u)
  local p = mathmod.new_vec3()
	p.x, p.y, p.z = gh_camera.get_position(camera)
  p = p + (u * dist)
	gh_camera.set_position(camera, p.x, p.y, p.z)
end

function M.SetCameraKeyboardSpeed(speed)
  _keyboard_speed = speed
end  

function M.ProcessCamera(camera, dt)

  -- OSX platform.
  local	KC_UP = 200
  local	KC_LEFT = 203
  local KC_RIGHT = 205
  local	KC_DOWN = 208
  
  -- Override for Windows plateform.
  if (gh_utils.get_platform() == 1) then
    KC_UP = 72
    KC_DOWN = 80
    KC_RIGHT = 77
    KC_LEFT = 75
  end


  local KC_W = 17
  local KC_S = 31
  local KC_A = 30
  local KC_D = 32
  local KC_R = 19
  local KC_F = 33
  

  local cam_speed = _keyboard_speed * dt
  if ((gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)) then
    CameraMoveAlongView(camera, cam_speed, cam_speed, cam_speed)
  end
  if ((gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)) then
    CameraMoveAlongView(camera, -cam_speed, -cam_speed, -cam_speed)
  end
  if ((gh_input.keyboard_is_key_down(KC_A) == 1) or (gh_input.keyboard_is_key_down(KC_LEFT) == 1)) then
    CameraStrafe(camera, cam_speed)
  end
  if ((gh_input.keyboard_is_key_down(KC_D) == 1) or (gh_input.keyboard_is_key_down(KC_RIGHT) == 1)) then
    CameraStrafe(camera, -cam_speed)
  end
  
  if (gh_input.keyboard_is_key_down(KC_R) == 1) then
    CameraStrafe_V(camera, cam_speed)
  end
  if (gh_input.keyboard_is_key_down(KC_F) == 1) then
    CameraStrafe_V(camera, -cam_speed)
  end
  

  local LEFT_BUTTON = 1
  local is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
  if ((is_down == 1) and (_do_rotate == 0)) then
    _camera_old_mouse_x, _camera_old_mouse_y = gh_input.mouse_getpos()
    _do_rotate = 1
  end

  if (is_down == 0) then
    _do_rotate = 0
  end

  if (_do_rotate == 1) then
    local mx
    local my
    mx, my = gh_input.mouse_getpos()
    
    local mouse_dx = (mx-_camera_old_mouse_x) * 3.14159/180.0
    local mouse_dy =(my-_camera_old_mouse_y) * 3.14159/180.0

    _camera_old_mouse_x = mx
    _camera_old_mouse_y = my
    
    local mouse_speed = 10.0
    CameraRotateView(camera, -mouse_dy * mouse_speed, -mouse_dx * mouse_speed)
  end
end

function M.ProcessCameraFly_v2(camera, dt)
  
  -- ProcessCameraFly_v2: function developed for the OpenGL Viewer demo.
  --
  
  -- OSX platform.
  local	KC_UP = 200
  local	KC_LEFT = 203
  local KC_RIGHT = 205
  local	KC_DOWN = 208
  
  -- Override for Windows plateform.
  if (gh_utils.get_platform() == 1) then
    KC_UP = 72
    KC_DOWN = 80
    KC_RIGHT = 77
    KC_LEFT = 75
  end


  local KC_W = 17
  local KC_S = 31
  local KC_A = 30
  local KC_D = 32
  local KC_R = 19
  local KC_F = 33
  

  local cam_speed = _keyboard_speed * dt
  if (gh_input.keyboard_is_key_down(KC_W) == 1) then
    CameraMoveAlongView(camera, cam_speed, cam_speed, cam_speed)
  end
  if (gh_input.keyboard_is_key_down(KC_S) == 1) then
    CameraMoveAlongView(camera, -cam_speed, -cam_speed, -cam_speed)
  end
  if ((gh_input.keyboard_is_key_down(KC_LEFT) == 1) or (gh_input.keyboard_is_key_down(KC_A) == 1)) then
    CameraStrafe(camera, cam_speed)
  end
  if ((gh_input.keyboard_is_key_down(KC_RIGHT) == 1) or (gh_input.keyboard_is_key_down(KC_D) == 1) )then
    CameraStrafe(camera, -cam_speed)
  end
  if (gh_input.keyboard_is_key_down(KC_UP) == 1) then
    CameraStrafe_V(camera, cam_speed)
  end
  if (gh_input.keyboard_is_key_down(KC_DOWN) == 1) then
    CameraStrafe_V(camera, -cam_speed)
  end
  

  local LEFT_BUTTON = 1
  local is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
  if ((is_down == 1) and (_do_rotate == 0)) then
    _camera_old_mouse_x, _camera_old_mouse_y = gh_input.mouse_getpos()
    _do_rotate = 1
  end

  if (is_down == 0) then
    _do_rotate = 0
  end

  if (_do_rotate == 1) then
    local mx
    local my
    mx, my = gh_input.mouse_getpos()
    
    local mouse_dx = (mx-_camera_old_mouse_x) * 3.14159/180.0
    local mouse_dy =(my-_camera_old_mouse_y) * 3.14159/180.0

    _camera_old_mouse_x = mx
    _camera_old_mouse_y = my
    
    local mouse_speed = 10.0
    CameraRotateView(camera, -mouse_dy * mouse_speed, -mouse_dx * mouse_speed)
  end
end

function M.ProcessCameraOrbit(camera, dt, lookat_x, lookat_y, lookat_z)
  -- OSX platform.
  local	KC_UP = 200
  local	KC_LEFT = 203
  local KC_RIGHT = 205
  local	KC_DOWN = 208
  
  -- Override for Windows plateform.
  if (gh_utils.get_platform() == 1) then
    KC_UP = 72
    KC_DOWN = 80
    KC_RIGHT = 77
    KC_LEFT = 75
  end


  local KC_W = 17
  local KC_S = 31
  local KC_A = 30
  local KC_D = 32

  
  local cam_speed = _keyboard_speed * dt
  if ((gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)) then
    CameraMoveAlongView(camera, cam_speed, cam_speed, cam_speed)
  end
  if ((gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)) then
    CameraMoveAlongView(camera, -cam_speed, -cam_speed, -cam_speed)
  end
  
  
	local cam_lookat = mathmod.new_vec3()
  cam_lookat.x = lookat_x
  cam_lookat.y = lookat_y
  cam_lookat.z = lookat_z
  DoCameraOrbit_v2(camera, cam_lookat)
end

return M

