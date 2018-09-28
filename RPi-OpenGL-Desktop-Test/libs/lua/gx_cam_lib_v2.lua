package.path = gh_utils.get_scripting_libs_dir() ..  "lua/?.lua;" .. package.path
package.loaded["mod_math"] = nil
mathmod = require "mod_math"



gx_camera = {
  _lib_name = "gxCamera",
  _version_str = "0.1.0",
  _version_major = 0,
  _version_minor = 1,
  _version_patch = 0,
  _all_cameras = {},
  _num_cameras = 0,
  _MODE_ORBIT = 1,
  _MODE_FLY = 2,
  _MODE_FPS = 3,
  _grid = 0,
  _grid_program = 0
}


function gx_camera.get_lib_name()
  return gx_camera._lib_name
end

function gx_camera.get_lib_version_str()
  local str = string.format("%d.%d.%d", gx_camera._version_major, gx_camera._version_minor, gx_camera._version_patch)
  return str
end

function gx_camera.get_lib_version()
  return gx_camera._version_major, gx_camera._version_minor, gx_camera._version_patch
end


function gx_camera._create()
  local camera = {
  _id = 0,
  _name= "",
  _viewport = {x=0, y=0, width=0, height=0},
  _fov = 60,
  _znear = 1,
  _zfar = 1000,
  _ctrl_key = 0,
  _mouse_wheel_delta = 0,
  _do_rotate = 0,
  _do_pan = 0,
  _pan_mx = 0,
  _pan_my = 0,
  _pan_speed_factor = 0.25,
  _old_mouse_x = 0,
  _old_mouse_y = 0,
  _mouse_speed_x = 0.1,
  _mouse_speed_y = 0.1,
  _mouse_speed_fly_x = 10.0,
  _mouse_speed_fly_y = 10.0,
  _orbit_yaw = 0,
  _orbit_pitch = 0,
  _keyboard_speed = 0.5,
  _move_view_speed = 2.0,
  _lookat_x = 0,
  _lookat_y = 0,
  _lookat_z = 0,
  _mode = gx_camera._MODE_ORBIT,
  _is_moving = 0
  }
  gx_camera._num_cameras = gx_camera._num_cameras + 1
  gx_camera._all_cameras[gx_camera._num_cameras] = camera
  return camera
end

function gx_camera.getid(camera)
  return camera._id
end

function gx_camera.set_mode(camera, mode)
  camera._mode = mode
end

function gx_camera.set_mode_orbit(camera)
  camera._mode = gx_camera._MODE_ORBIT
end

function gx_camera.set_mode_fly(camera)
  camera._mode = gx_camera._MODE_FLY
end

function gx_camera.set_mode_fps(camera)
  camera._mode = gx_camera._MODE_FPS
end

function gx_camera.create_perspective(fov, is_vertical_fov, viewport_x, viewport_y, viewport_width, viewport_height, znear, zfar)
  local camera = gx_camera._create()
  camera._viewport.x = viewport_x
  camera._viewport.y = viewport_y
  camera._viewport.width = viewport_width
  camera._viewport.height = viewport_height
  camera._fov = fov
  camera._znear = znear
  camera._zfar = zfar
  local aspect = viewport_width / viewport_height
  camera._id = gh_camera.create_persp_v2(fov, is_vertical_fov, aspect, znear, zfar)
  gh_camera.set_viewport(camera._id, viewport_x, viewport_y, viewport_width, viewport_height)
  gh_camera.setpos(camera._id, 0, 0, 20)
  gh_camera.setlookat(camera._id, 0, 0, 0, 1)
  gh_camera.setupvec(camera._id, 0, 1, 0, 0)
  return camera
end  

function gx_camera.update_perspective(camera, fov, is_vertical_fov, viewport_x, viewport_y, viewport_width, viewport_height, znear, zfar)
  camera._viewport.x = viewport_x
  camera._viewport.y = viewport_y
  camera._viewport.width = viewport_width
  camera._viewport.height = viewport_height
  camera._fov = fov
  camera._znear = znear
  camera._zfar = zfar
  local aspect = viewport_width / viewport_height
  gh_camera.update_persp_v2(camera._id, fov, is_vertical_fov, aspect, znear, zfar)
  gh_camera.set_viewport(camera._id, viewport_x, viewport_y, viewport_width, viewport_height)
end


function gx_camera._init_camera_angles(camera, pitch, yaw)
	camera._orbit_yaw = yaw
	camera._orbit_pitch = pitch
end

function gx_camera._init_camera_orbit(camera, x, y)
	camera._old_mouse_x = x
	camera._old_mouse_y = y
end

function gx_camera._rotate_camera_position_around_point(camera, lookat_point_x, lookat_point_y, lookat_point_z, pitch, yaw, roll)
	local cam_pos_x, cam_pos_y, cam_pos_z = gh_object.get_position(camera._id)
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
	gh_camera.set_position(camera._id, new_cam_pos_x, new_cam_pos_y, new_cam_pos_z)
  camera._lookat_x = lookat_point_x
  camera._lookat_y = lookat_point_y
  camera._lookat_z = lookat_point_z
  gh_camera.set_lookat(camera._id, lookat_point_x, lookat_point_y, lookat_point_z, 1)
end

function gx_camera._rotate_camera_orbit(camera, mouse_x, mouse_y, lookat_x, lookat_y, lookat_z)
	local dx = mouse_x - camera._old_mouse_x
	local dy = mouse_y - camera._old_mouse_y

	camera._old_mouse_x = mouse_x
	camera._old_mouse_y = mouse_y

	local dyaw = dx * camera._mouse_speed_x
	local dpitch = dy * camera._mouse_speed_y

	camera._orbit_yaw = camera._orbit_yaw + dyaw
	camera._orbit_pitch = camera._orbit_pitch + dpitch
	
	if (camera._orbit_pitch >= 80.0) then
		camera._orbit_pitch = 80.0
	end
	
	if (camera._orbit_pitch <= -80.0) then
		camera._orbit_pitch = -80.0
	end

	gx_camera._rotate_camera_position_around_point(camera, lookat_x, lookat_y, lookat_z, camera._orbit_pitch, camera._orbit_yaw, 0.0)
end

function gx_camera.orbit(camera, lookat_x, lookat_y, lookat_z)
	local LEFT_BUTTON = 1
  gx_camera.orbit_v2(camera, lookat_x, lookat_y, lookat_z, LEFT_BUTTON)
end

function gx_camera.orbit_v2(camera, lookat_x, lookat_y, lookat_z, mouse_button)
	--local LEFT_BUTTON = 1
	--local RIGHT_BUTTON = 2
	local is_down = gh_input.mouse_get_button_state(mouse_button) 
	if ((is_down == 1) and (camera._do_rotate == 0)) then
		local mx
		local my
		mx, my = gh_input.mouse_getpos()

    if (gh_utils.get_platform() == 2) then -- OSX    
		  gx_camera._init_camera_orbit(camera, mx, -my)
    else  -- Windows and Linux
      gx_camera._init_camera_orbit(camera, mx, my)
    end
		camera._do_rotate = 1
	end
	
	if (is_down == 0) then
		camera._do_rotate = 0
	end
	
	if (camera._do_rotate == 1) then
		local mx
		local my
		mx, my = gh_input.mouse_getpos()
		
		if ((mx ~= camera._old_mouse_x) or (my ~= camera._old_mouse_y)) then
      if (gh_utils.get_platform() == 2) then -- OSX    
  			gx_camera._rotate_camera_orbit(camera, mx, -my, lookat_x, lookat_y, lookat_z)
      else -- Windows and Linux
        gx_camera._rotate_camera_orbit(camera, mx, my, lookat_x, lookat_y, lookat_z)
      end  
		end
	end
end

function gx_camera.init_orientation(camera, lookat_x, lookat_y, lookat_z, pitch, yaw)
	gx_camera._init_camera_angles(camera, pitch, yaw)
	gx_camera._rotate_camera_position_around_point(camera, lookat_x, lookat_y, lookat_z, pitch, yaw, 0)
end


function gx_camera.move_along_view(camera, distance)
	local px, py, pz = gh_camera.get_position(camera._id)
	local vx, vy, vz = gh_camera.get_view_vector(camera._id)
	px = px + (vx * distance)
	py = py + (vy * distance)
	pz = pz + (vz * distance)
	gh_camera.set_position(camera._id, px, py, pz)
end

function gx_camera.move_along_view_xz(camera, distance)
	local px, py, pz = gh_camera.get_position(camera._id)
	local vx, vy, vz = gh_camera.get_view_vector(camera._id)
	px = px + (vx * distance)
	pz = pz + (vz * distance)
	gh_camera.set_position(camera._id, px, py, pz)
end

function gx_camera.rotate_view(camera, pitch, yaw)
  gh_camera.set_yaw(camera._id, yaw)
  gh_camera.set_pitch(camera._id, pitch)
end

function gx_camera.strafe_h(camera, dist, update_lookat)
  gx_camera.strafe_h_v2(camera, dist, 1)
end

function gx_camera.strafe_h_v2(camera, dist, update_lookat)
	local v = mathmod.new_vec3()
	local u = mathmod.new_vec3()
	v.x, v.y, v.z = gh_camera.get_view_vector(camera._id)
  v:neg()
	u.x, u.y, u.z = gh_camera.get_up_vector(camera._id)
  local xvec = v:cross(u)
  local p = mathmod.new_vec3()
	p.x, p.y, p.z = gh_camera.get_position(camera._id)
  p = p + (xvec * dist)
	gh_camera.set_position(camera._id, p.x, p.y, p.z)
  
  if (update_lookat == 1) then
    local lookat_x = camera._lookat_x + (xvec.x * dist)
    local lookat_y = camera._lookat_y + (xvec.y * dist)
    local lookat_z = camera._lookat_z + (xvec.z * dist)
    gx_camera.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)  
  end
end

function gx_camera.strafe_h_xz(camera, dist, update_lookat)
	local v = mathmod.new_vec3()
	local u = mathmod.new_vec3()
	v.x, v.y, v.z = gh_camera.get_view_vector(camera._id)
  v:neg()
	u.x, u.y, u.z = gh_camera.get_up_vector(camera._id)
  local xvec = v:cross(u)
  local p = mathmod.new_vec3()
	p.x, p.y, p.z = gh_camera.get_position(camera._id)
  p.x = p.x + (xvec.x * dist)
  p.z = p.z + (xvec.z * dist)
	gh_camera.set_position(camera._id, p.x, p.y, p.z)
  
  if (update_lookat == 1) then
    local lookat_x = camera._lookat_x + (xvec.x * dist)
    local lookat_y = camera._lookat_y + (xvec.y * dist)
    local lookat_z = camera._lookat_z + (xvec.z * dist)
    gx_camera.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)  
  end
end

function gx_camera.strafe_v(camera, dist)
  gx_camera.strafe_v_v2(camera, dist, 1)
end

function gx_camera.strafe_v_v2(camera, dist, update_lookat)
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
  
  if (update_lookat == 1) then
    local lookat_x = camera._lookat_x + (u.x * dist)
    local lookat_y = camera._lookat_y + (u.y * dist)
    local lookat_z = camera._lookat_z + (u.z * dist)
    gx_camera.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)  
  end
  
end

function gx_camera.set_keyboard_speed(camera, speed)
  camera._keyboard_speed = speed
end  

function gx_camera.set_move_view_speed(camera, speed)
  camera._move_view_speed = speed
end  

function gx_camera.set_mouse_sensitivity_orbit_mode(camera, sx, sy)
  camera._mouse_speed_x = sx
  camera._mouse_speed_y = sy
end  

function gx_camera.set_mouse_sensitivity_fly_mode(camera, sx, sy)
  camera._mouse_speed_fly_x = sx
  camera._mouse_speed_fly_y = sy
end  


function gx_camera.ComputeProjectiveScaleFactor(camera, lookat_x, lookat_y, lookat_z, screen_height, fov)
  local fov_rad = fov * 3.14159 / 180.0
	local focalLength = (0.5 * screen_height) / (math.tan(fov_rad / 2))
  local px, py, pz = gh_camera.get_position(camera._id)
  local dx = lookat_x - px
  local dy = lookat_y - py
  local dz = lookat_z - pz
	local pivotDistance = math.sqrt((dx*dx) + (dy*dy) + (dz*dz))
  local S = pivotDistance / focalLength
	return S
end

function gx_camera.pan(camera, speed_factor)
  local KC_LEFT_CTRL = 29
  local is_ctrl_down = gh_input.keyboard_is_key_down(KC_LEFT_CTRL) 
	local is_leftbutton_down = 0
  
  local dx = 0
  local dy = 0
  
  camera._ctrl_key = is_ctrl_down
  
  if (is_ctrl_down == 1) then
    local LEFT_BUTTON = 1
    is_leftbutton_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
    if ((is_leftbutton_down == 1) and (camera._do_pan == 0)) then
      local mx, my = gh_input.mouse_getpos()
      camera._pan_mx = mx
      camera._pan_my = my
      camera._do_pan = 1
    end
    
    local mx, my = gh_input.mouse_getpos()
    dx = mx - camera._pan_mx
    dy = my - camera._pan_my
    camera._pan_mx = mx
    camera._pan_my = my
  end
  
	if (is_leftbutton_down == 0) then
		camera._do_pan = 0
	end
  
  if (camera._do_pan == 1) then
    gx_camera.strafe_h(camera, dx * speed_factor)
    gx_camera.strafe_v(camera, dy * speed_factor)
  end  
end


function gx_camera.is_moving(camera)
  return camera._is_moving
end


function gx_camera.update_fly(camera, dt)

  -- OSX platform.
  local	KC_UP = 200
  local	KC_LEFT = 203
  local KC_RIGHT = 205
  local	KC_DOWN = 208
  
  --[[
  -- Override for Windows plateform.
  if (gh_utils.get_platform() == 1) then
    KC_UP = 72
    KC_DOWN = 80
    KC_RIGHT = 77
    KC_LEFT = 75
  end
  --]]

  local KC_W = 17
  local KC_S = 31
  local KC_A = 30
  local KC_D = 32
  local KC_R = 19
  local KC_F = 33
  

  local cam_dist = camera._keyboard_speed * dt
  if ((gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)) then
    gx_camera.move_along_view(camera, cam_dist)
    camera._is_moving = 1
  end
  if ((gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)) then
    gx_camera.move_along_view(camera, -cam_dist)
    camera._is_moving = 1
  end
  if ((gh_input.keyboard_is_key_down(KC_A) == 1) or (gh_input.keyboard_is_key_down(KC_LEFT) == 1)) then
    gx_camera.strafe_h_v2(camera, cam_dist, 0)
    camera._is_moving = 1
  end
  if ((gh_input.keyboard_is_key_down(KC_D) == 1) or (gh_input.keyboard_is_key_down(KC_RIGHT) == 1)) then
    gx_camera.strafe_h_v2(camera, -cam_dist, 0)
    camera._is_moving = 1
  end
  
  if (gh_input.keyboard_is_key_down(KC_R) == 1) then
    gx_camera.strafe_v_v2(camera, cam_dist, 0)
    camera._is_moving = 1
  end
  if (gh_input.keyboard_is_key_down(KC_F) == 1) then
    gx_camera.strafe_v_v2(camera, -cam_dist, 0)
    camera._is_moving = 1
  end
  

  local LEFT_BUTTON = 1
  local is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
  if ((is_down == 1) and (camera._do_rotate == 0)) then
    camera._old_mouse_x, camera._old_mouse_y = gh_input.mouse_getpos()
    camera._do_rotate = 1
  end

  if (is_down == 0) then
    camera._do_rotate = 0
  end

  if (camera._do_rotate == 1) then
    local mx
    local my
    mx, my = gh_input.mouse_getpos()
    
    local mouse_dx = (mx - camera._old_mouse_x) * mathmod._PI_OVER_180
    local mouse_dy =(my - camera._old_mouse_y) * mathmod._PI_OVER_180

    camera._old_mouse_x = mx
    camera._old_mouse_y = my
    
    --local mouse_speed = 10.0
    gx_camera.rotate_view(camera, -mouse_dy * camera._mouse_speed_fly_y, -mouse_dx * camera._mouse_speed_fly_x)
  end
end


function gx_camera.update_walk(camera, dt)

  -- OSX platform.
  local	KC_UP = 200
  local	KC_LEFT = 203
  local KC_RIGHT = 205
  local	KC_DOWN = 208
  
  --[[
  -- Override for Windows plateform.
  if (gh_utils.get_platform() == 1) then
    KC_UP = 72
    KC_DOWN = 80
    KC_RIGHT = 77
    KC_LEFT = 75
  end
  --]]

  local KC_W = 17
  local KC_S = 31
  local KC_A = 30
  local KC_D = 32
  local KC_R = 19
  local KC_F = 33
  

  local cam_dist = camera._keyboard_speed * dt
  if ((gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)) then
    gx_camera.move_along_view_xz(camera, cam_dist)
    camera._is_moving = 1
  end
  if ((gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)) then
    gx_camera.move_along_view_xz(camera, -cam_dist)
    camera._is_moving = 1
  end
  if ((gh_input.keyboard_is_key_down(KC_A) == 1) or (gh_input.keyboard_is_key_down(KC_LEFT) == 1)) then
    gx_camera.strafe_h_xz(camera, cam_dist, 0)
    camera._is_moving = 1
  end
  if ((gh_input.keyboard_is_key_down(KC_D) == 1) or (gh_input.keyboard_is_key_down(KC_RIGHT) == 1)) then
    gx_camera.strafe_h_xz(camera, -cam_dist, 0)
    camera._is_moving = 1
  end
  
  if (gh_input.keyboard_is_key_down(KC_R) == 1) then
    gx_camera.strafe_v_v2(camera, cam_dist, 0)
    camera._is_moving = 1
  end
  if (gh_input.keyboard_is_key_down(KC_F) == 1) then
    gx_camera.strafe_v_v2(camera, -cam_dist, 0)
    camera._is_moving = 1
  end
  

  local LEFT_BUTTON = 1
  local is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
  if ((is_down == 1) and (camera._do_rotate == 0)) then
    camera._old_mouse_x, camera._old_mouse_y = gh_input.mouse_getpos()
    camera._do_rotate = 1
  end

  if (is_down == 0) then
    camera._do_rotate = 0
  end

  if (camera._do_rotate == 1) then
    local mx
    local my
    mx, my = gh_input.mouse_getpos()
    
    local mouse_dx = (mx - camera._old_mouse_x) * mathmod._PI_OVER_180
    local mouse_dy =(my - camera._old_mouse_y) * mathmod._PI_OVER_180

    camera._old_mouse_x = mx
    camera._old_mouse_y = my
    
    local mouse_speed = 10.0
    gx_camera.rotate_view(camera, -mouse_dy * mouse_speed, -mouse_dx * mouse_speed)
  end
end




function gx_camera.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)
  camera._lookat_x = lookat_x
  camera._lookat_y = lookat_y
  camera._lookat_z = lookat_z
  gh_camera.set_lookat(camera._id, lookat_x, lookat_y, lookat_z, 1)
end

function gx_camera.update_orbit(camera, dt, lookat_x, lookat_y, lookat_z)
  local LEFT_BUTTON = 1
  gx_camera.update_orbit_v2(camera, dt, lookat_x, lookat_y, lookat_z, LEFT_BUTTON)
end

function gx_camera.update_orbit_v2(camera, dt, lookat_x, lookat_y, lookat_z, mouse_button)
  -- OSX platform.
  local	KC_UP = 200
  local	KC_LEFT = 203
  local KC_RIGHT = 205
  local	KC_DOWN = 208
  --[[
  -- Override for Windows plateform.
  if (gh_utils.get_platform() == 1) then
    KC_UP = 72
    KC_DOWN = 80
    KC_RIGHT = 77
    KC_LEFT = 75
  end
  --]]

  local KC_W = 17
  local KC_S = 31
  local KC_A = 30
  local KC_D = 32

  
  local wheel_delta = gh_input.mouse_get_wheel_delta()
  camera._mouse_wheel_delta = wheel_delta
  gh_input.mouse_reset_wheel_delta()
  
  local distance = camera._keyboard_speed * dt * camera._move_view_speed
  
  if ((wheel_delta > 0) or (gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)) then
    gx_camera.move_along_view(camera, distance)
  end
  if ((wheel_delta < 0) or (gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)) then
    gx_camera.move_along_view(camera, -distance)
  end
  
  gx_camera.orbit_v2(camera, lookat_x, lookat_y, lookat_z, mouse_button)
end

function gx_camera.update(camera, dt)

  -- Windows platform.
  if (gh_utils.get_platform() == 1) then
    gh_window.keyboard_update_buffer(0)
  end
 
  camera._is_moving = 0
  gx_camera.pan(camera, camera._pan_speed_factor)
  
  if (camera._do_pan == 0) then
    if (camera._mode == gx_camera._MODE_ORBIT) then
      gx_camera.update_orbit(camera, dt, camera._lookat_x, camera._lookat_y, camera._lookat_z)  
    
    elseif (camera._mode == gx_camera._MODE_FLY) then
      gx_camera.update_fly(camera, dt)  
      
    elseif (camera._mode == gx_camera._MODE_FPS) then
      gx_camera.update_walk(camera, dt)  
     
    end
  end

end




function gx_camera.draw_tripod(camera)
  --local w, h = gh_window.getsize(0)
  gh_utils.tripod_visualizer_camera_render(camera._id, 0, 0, 100, 100)
end


function gx_camera.draw_ref_grid(x_size, z_size, x_subdiv, z_subdiv)
  local grid = gx_camera._grid
  if (grid == 0) then
    grid = gh_utils.grid_create()
    gx_camera._grid = grid
    
    gh_utils.grid_set_lines_color(grid, 0.7, 0.7, 0.7, 1.0)
    gh_utils.grid_set_main_lines_color(grid, 1.0, 1.0, 0.0, 1.0)
    gh_utils.grid_set_main_x_axis_color(grid, 1.0, 0.0, 0.0, 1.0)
    gh_utils.grid_set_main_z_axis_color(grid, 0.0, 0.0, 1.0, 1.0)
    local display_main_lines = 1
    local display_lines = 1
    gh_utils.grid_set_display_lines_options(grid, display_main_lines, display_lines)
    
    local grid_program_vs_gl3=" \
    #version 150 \
    in vec4 gxl3d_Position; \
    in vec4 gxl3d_Color; \
    uniform mat4 gxl3d_ModelViewProjectionMatrix; \
    out vec4 Vertex_Color; \
    void main() \
    { \
      gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position; \
      Vertex_Color = gxl3d_Color; \
    }"

    local grid_program_ps_gl3=" \
    #version 150 \
    in vec4 Vertex_Color; \
    out vec4 FragColor; \
    void main (void) \
    { \
      FragColor = Vertex_Color;  \
    }"
    
    local grid_program_vs_gl2=" \
    #version 120 \
    uniform mat4 gxl3d_ModelViewProjectionMatrix; \
    varying vec4 Vertex_Color; \
    void main() \
    { \
      gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex; \
      Vertex_Color = gl_Color; \
    }"

    local grid_program_ps_gl2=" \
    #version 120 \
    varying vec4 Vertex_Color; \
    void main (void) \
    { \
      gl_FragColor = Vertex_Color;  \
    }"

    if (gh_renderer.get_api_version_major() >= 3) then
      gx_camera._grid_program = gh_gpu_program.create(grid_program_vs_gl3, grid_program_ps_gl3)
    else
      gx_camera._grid_program = gh_gpu_program.create(grid_program_vs_gl2, grid_program_ps_gl2)
    end
  end
  
  gh_utils.grid_set_geometry_params(grid, x_size, z_size, x_subdiv, z_subdiv)
  gh_gpu_program.bind(gx_camera._grid_program)
  gh_object.render(grid)
end

