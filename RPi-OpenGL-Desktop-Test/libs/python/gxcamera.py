import gh_node
import gh_object
import gh_camera
import gh_gpu_program
import gh_utils
import gh_renderer
import gh_window
import gh_input
import math


class vec3:
  def __init__(self):
    self.x = 0
    self.y = 0
    self.z = 0
    
  def neg(self):
    self.x = -self.x
    self.y = -self.y
    self.z = -self.z
    
  def dot(self, v2):
    return self.x*v2.x + self.y*v2.y + self.z*v2.z

  def cross(self, v2):
    v = vec3()
    v.x = self.y*v2.z - self.z*v2.y
    v.y = self.z*v2.x - self.x*v2.z
    v.z = self.x*v2.y - self.y*v2.x
    return v

  def square_len(self):
    return self.x*self.x + self.y*self.y + self.z*self.z
  
  def len(self):
    return math.sqrt(self.square_len())
    
  def normalize(self):
    norm = self.len()
    multiplier = 1
    if (norm > 0):
      multiplier = 1.0/norm
    else:
      multiplier = 0.00001
		
    self.x = self.x * multiplier
    self.y = self.y * multiplier
    self.z = self.z * multiplier
    
  def distance(self, v2):
    return math.sqrt(self.square_distance(v2))
    
    

class cViewport:
  def __init__(self):
    self.x = 0
    self.y = 0
    self.width = 0
    self.height = 0
    
class cCamera:
  def __init__(self):
    self._id = 0
    self._name= ""
    self._viewport = cViewport()
    self._fov = 60
    self._znear = 1
    self._zfar = 1000
    self._ctrl_key = 0
    self._mouse_wheel_delta = 0
    self._do_rotate = 0
    self._do_pan = 0
    self._pan_mx = 0
    self._pan_my = 0
    self._pan_speed_factor = 0.25
    self._old_mouse_x = 0
    self._old_mouse_y = 0
    self._orbit_yaw = 0
    self._orbit_pitch = 0
    self._keyboard_speed = 0.5
    self._lookat_x = 0
    self._lookat_y = 0
    self._lookat_z = 0
    self._mode = 1 # _MODE_ORBIT
    self._is_moving = 0



class g2x_camera:

  def __init__(self):
    self._lib_name = "gxCamera"
    self._version_str = "0.1.0"
    self._version_major = 0
    self._version_minor = 1
    self._version_patch = 0
    self._all_cameras = []
    self._num_cameras = 0
    self._MODE_ORBIT = 1
    self._MODE_FLY = 2
    self._MODE_FPS = 3
    self._grid = 0
    self._grid_program = 0


  def get_lib_name(self):
    return self._lib_name

  def get_lib_version_str(self):
    s = ("%d.%d.%d") % (self._version_major, self._version_minor, self._version_patch)
    return s

  def get_lib_version(self):
    return self._version_major, self._version_minor, self._version_patch


  def _create(self):
    """
    camera = (
      _id = 0,
      _name= "",
      _viewport = (x=0, y=0, width=0, height=0),
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
      _orbit_yaw = 0,
      _orbit_pitch = 0,
      _keyboard_speed = 0.5,
      _lookat_x = 0,
      _lookat_y = 0,
      _lookat_z = 0,
      _mode = self._MODE_ORBIT,
      _is_moving = 0
    )
    """
    camera = cCamera()
    self._num_cameras = self._num_cameras + 1
    #self._all_cameras[self._num_cameras] = camera
    self._all_cameras.append(camera)
    return camera

    
  def getid(self, camera):
    return camera._id

  def set_mode(self, camera, mode):
    camera._mode = mode

  def set_mode_orbit(self, camera):
    camera._mode = self._MODE_ORBIT

  def set_mode_fly(self, camera):
    camera._mode = self._MODE_FLY

  def set_mode_fps(self, camera):
    camera._mode = self._MODE_FPS

  def create_perspective(self, fov, is_vertical_fov, viewport_x, viewport_y, viewport_width, viewport_height, znear, zfar):
    camera = self._create()
    camera._viewport.x = viewport_x
    camera._viewport.y = viewport_y
    camera._viewport.width = viewport_width
    camera._viewport.height = viewport_height
    camera._fov = fov
    camera._znear = znear
    camera._zfar = zfar
    aspect = float(viewport_width) / float(viewport_height)
    #camera._id = gh_camera.create_persp_v2(fov, is_vertical_fov, aspect, znear, zfar)
    camera._id = gh_camera.create_persp(fov, aspect, znear, zfar)
    gh_camera.set_viewport(camera._id, viewport_x, viewport_y, viewport_width, viewport_height)
    gh_camera.set_position(camera._id, 0, 0, 20)
    gh_camera.set_lookat(camera._id, 0, 0, 0, 1)
    gh_camera.setupvec(camera._id, 0, 1, 0, 0)
    return camera
    

  def update_perspective(self, camera, fov, is_vertical_fov, viewport_x, viewport_y, viewport_width, viewport_height, znear, zfar):
    camera._viewport.x = viewport_x
    camera._viewport.y = viewport_y
    camera._viewport.width = viewport_width
    camera._viewport.height = viewport_height
    camera._fov = fov
    camera._znear = znear
    camera._zfar = zfar
    aspect = float(viewport_width) / float(viewport_height)
    #gh_camera.update_persp_v2(camera._id, fov, is_vertical_fov, aspect, znear, zfar)
    gh_camera.update_persp(camera._id, fov, aspect, znear, zfar)
    gh_camera.set_viewport(camera._id, viewport_x, viewport_y, viewport_width, viewport_height)


  def _init_camera_angles(self, camera, pitch, yaw):
    camera._orbit_yaw = yaw
    camera._orbit_pitch = pitch

  def _init_camera_orbit(self, camera, x, y):
    camera._old_mouse_x = x
    camera._old_mouse_y = y

  def _rotate_camera_position_around_point(self, camera, lookat_point_x, lookat_point_y, lookat_point_z, pitch, yaw, roll):
    cam_pos_x, cam_pos_y, cam_pos_z = gh_object.get_position(camera._id)
    vx = cam_pos_x - lookat_point_x
    vy = cam_pos_y - lookat_point_y
    vz = cam_pos_z - lookat_point_z
    angX = pitch * math.pi / 180.0
    angY = yaw * math.pi / 180.0
    angZ = roll * math.pi / 180.0
    mag = math.sqrt(vx*vx + vy*vy + vz*vz)
    new_cam_pos_x = lookat_point_x + mag * math.cos(angY) * math.cos(angX)
    new_cam_pos_y = lookat_point_y + mag * math.sin(angX)
    new_cam_pos_z = lookat_point_z + mag * math.sin(angY) * math.cos(angX)
    gh_camera.set_position(camera._id, new_cam_pos_x, new_cam_pos_y, new_cam_pos_z)
    camera._lookat_x = lookat_point_x
    camera._lookat_y = lookat_point_y
    camera._lookat_z = lookat_point_z
    gh_camera.set_lookat(camera._id, lookat_point_x, lookat_point_y, lookat_point_z, 1)

  def _rotate_camera_orbit(self, camera, mouse_x, mouse_y, lookat_x, lookat_y, lookat_z):
    dx = mouse_x - camera._old_mouse_x
    dy = mouse_y - camera._old_mouse_y

    camera._old_mouse_x = mouse_x
    camera._old_mouse_y = mouse_y

    dyaw = dx * 0.1
    dpitch = dy * 0.1

    camera._orbit_yaw = camera._orbit_yaw + dyaw
    camera._orbit_pitch = camera._orbit_pitch + dpitch
	
    if (camera._orbit_pitch >= 80.0):
      camera._orbit_pitch = 80.0

    if (camera._orbit_pitch <= -80.0):
      camera._orbit_pitch = -80.0

    self._rotate_camera_position_around_point(camera, lookat_x, lookat_y, lookat_z, camera._orbit_pitch, camera._orbit_yaw, 0.0)

    
  def orbit(self, camera, lookat_x, lookat_y, lookat_z):
    LEFT_BUTTON = 1
    self.orbit_v2(camera, lookat_x, lookat_y, lookat_z, LEFT_BUTTON)

    
  def orbit_v2(self, camera, lookat_x, lookat_y, lookat_z, mouse_button):
    is_down = gh_input.mouse_get_button_state(mouse_button) 
    if ((is_down == 1) and (camera._do_rotate == 0)):
      mx, my = gh_input.mouse_getpos()

      if (gh_utils.get_platform() == 2): # OSX    
        self._init_camera_orbit(camera, mx, -my)
      else:  # Windows and Linux
        self._init_camera_orbit(camera, mx, my)
      
      camera._do_rotate = 1
	
    if (is_down == 0):
      camera._do_rotate = 0
	
    if (camera._do_rotate == 1):
      mx, my = gh_input.mouse_getpos()
		
      if ((mx != camera._old_mouse_x) or (my != camera._old_mouse_y)):
        if (gh_utils.get_platform() == 2): # OSX    
          self._rotate_camera_orbit(camera, mx, -my, lookat_x, lookat_y, lookat_z)
        else: # Windows and Linux
          self._rotate_camera_orbit(camera, mx, my, lookat_x, lookat_y, lookat_z)
          

  def init_orientation(self, camera, lookat_x, lookat_y, lookat_z, pitch, yaw):
    self._init_camera_angles(camera, pitch, yaw)
    self._rotate_camera_position_around_point(camera, lookat_x, lookat_y, lookat_z, pitch, yaw, 0)


  def move_along_view(self, camera, distance):
    px, py, pz = gh_camera.get_position(camera._id)
    vx, vy, vz = gh_camera.get_view_vector(camera._id)
    px = px + (vx * distance)
    py = py + (vy * distance)
    pz = pz + (vz * distance)
    gh_camera.set_position(camera._id, px, py, pz)

  def move_along_view_xz(self, camera, distance):
    px, py, pz = gh_camera.get_position(camera._id)
    vx, vy, vz = gh_camera.get_view_vector(camera._id)
    px = px + (vx * distance)
    pz = pz + (vz * distance)
    gh_camera.set_position(camera._id, px, py, pz)

  def rotate_view(self, camera, pitch, yaw):
    gh_camera.set_yaw(camera._id, yaw)
    gh_camera.set_pitch(camera._id, pitch)

  def strafe_h(self, camera, dist):
    self.strafe_h_v2(camera, dist, 1)

    
  def strafe_h_v2(self, camera, dist, update_lookat):
    v = vec3()
    u = vec3()
    v.x, v.y, v.z = gh_camera.get_view_vector(camera._id)
    v.neg()
    u.x, u.y, u.z = gh_camera.get_up_vector(camera._id)
    xvec = v.cross(u)
    p = vec3()
    p.x, p.y, p.z = gh_camera.get_position(camera._id)
    p.x = p.x + (xvec.x * dist)
    p.y = p.y + (xvec.y * dist)
    p.z = p.z + (xvec.z * dist)
    gh_camera.set_position(camera._id, p.x, p.y, p.z)
    
    if (update_lookat == 1):
      lookat_x = camera._lookat_x + (xvec.x * dist)
      lookat_y = camera._lookat_y + (xvec.y * dist)
      lookat_z = camera._lookat_z + (xvec.z * dist)
      self.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)  

      
  def strafe_h_xz(self, camera, dist, update_lookat):
    v = vec3()
    u = vec3()
    v.x, v.y, v.z = gh_camera.get_view_vector(camera._id)
    v.neg()
    u.x, u.y, u.z = gh_camera.get_up_vector(camera._id)
    xvec = v.cross(u)
    p = vec3()
    p.x, p.y, p.z = gh_camera.get_position(camera._id)
    p.x = p.x + (xvec.x * dist)
    p.z = p.z + (xvec.z * dist)
    gh_camera.set_position(camera._id, p.x, p.y, p.z)
    
    if (update_lookat == 1):
      lookat_x = camera._lookat_x + (xvec.x * dist)
      lookat_y = camera._lookat_y + (xvec.y * dist)
      lookat_z = camera._lookat_z + (xvec.z * dist)
      self.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)  

      
  def strafe_v(self, camera, dist):
    self.strafe_v_v2(camera, dist, 1)

    
  def strafe_v_v2(self, camera, dist, update_lookat):
    # Vertical strafe
    v = vec3()
    u = vec3()
    v.x, v.y, v.z = gh_camera.get_view_vector(camera._id)
    v.neg()
    u.x, u.y, u.z = gh_camera.get_up_vector(camera._id)
    xvec = v.cross(u)
    p = vec3()
    p.x, p.y, p.z = gh_camera.get_position(camera._id)
    p.x = p.x + (u.x * dist)
    p.y = p.y + (u.y * dist)
    p.z = p.z + (u.z * dist)
    gh_camera.set_position(camera._id, p.x, p.y, p.z)
    
    if (update_lookat == 1):
      lookat_x = camera._lookat_x + (u.x * dist)
      lookat_y = camera._lookat_y + (u.y * dist)
      lookat_z = camera._lookat_z + (u.z * dist)
      self.set_orbit_lookat(camera, lookat_x, lookat_y, lookat_z)  

      
  def set_keyboard_speed(self, camera, speed):
    camera._keyboard_speed = speed


  def ComputeProjectiveScaleFactor(self, camera, lookat_x, lookat_y, lookat_z, screen_height, fov):
    fov_rad = fov * math.pi / 180.0
    focalLength = (0.5 * screen_height) / (math.tan(fov_rad / 2))
    px, py, pz = gh_camera.get_position(camera._id)
    dx = lookat_x - px
    dy = lookat_y - py
    dz = lookat_z - pz
    pivotDistance = math.sqrt((dx*dx) + (dy*dy) + (dz*dz))
    S = pivotDistance / focalLength
    return S

    
  def pan(self, camera, speed_factor):
    KC_LEFT_CTRL = 29
    is_ctrl_down = gh_input.keyboard_is_key_down(KC_LEFT_CTRL) 
    is_leftbutton_down = 0
    
    dx = 0
    dy = 0
  
    camera._ctrl_key = is_ctrl_down
  
    if (is_ctrl_down == 1):
      LEFT_BUTTON = 1
      is_leftbutton_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
      if ((is_leftbutton_down == 1) and (camera._do_pan == 0)):
        mx, my = gh_input.mouse_getpos()
        camera._pan_mx = mx
        camera._pan_my = my
        camera._do_pan = 1
    
      mx, my = gh_input.mouse_getpos()
      dx = mx - camera._pan_mx
      dy = my - camera._pan_my
      camera._pan_mx = mx
      camera._pan_my = my
  
    if (is_leftbutton_down == 0):
      camera._do_pan = 0
  
    
    if (camera._do_pan == 1):
      self.strafe_h(camera, dx * speed_factor)
      self.strafe_v(camera, dy * speed_factor)
    


  def is_moving(self, camera):
    return camera._is_moving


  def update_fly(self, camera, dt):

    # OSX platform.
    KC_UP = 200
    KC_LEFT = 203
    KC_RIGHT = 205
    KC_DOWN = 208
  
    """
    #Override for Windows plateform.
    if (gh_utils.get_platform() == 1):
      KC_UP = 72
      KC_DOWN = 80
      KC_RIGHT = 77
      KC_LEFT = 75
    """

    KC_W = 17
    KC_S = 31
    KC_A = 30
    KC_D = 32
    KC_R = 19
    KC_F = 33
  

    cam_dist = camera._keyboard_speed * dt
    if ((gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)):
      self.move_along_view(camera, cam_dist)
      camera._is_moving = 1
  
  
    if ((gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)):
      self.move_along_view(camera, -cam_dist)
      camera._is_moving = 1
      
    if ((gh_input.keyboard_is_key_down(KC_A) == 1) or (gh_input.keyboard_is_key_down(KC_LEFT) == 1)):
      self.strafe_h_v2(camera, cam_dist, 0)
      camera._is_moving = 1
      
    if ((gh_input.keyboard_is_key_down(KC_D) == 1) or (gh_input.keyboard_is_key_down(KC_RIGHT) == 1)):
      self.strafe_h_v2(camera, -cam_dist, 0)
      camera._is_moving = 1
  
    if (gh_input.keyboard_is_key_down(KC_R) == 1):
      self.strafe_v_v2(camera, cam_dist, 0)
      camera._is_moving = 1
      
    if (gh_input.keyboard_is_key_down(KC_F) == 1):
      self.strafe_v_v2(camera, -cam_dist, 0)
      camera._is_moving = 1
  

    LEFT_BUTTON = 1
    is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
    if ((is_down == 1) and (camera._do_rotate == 0)):
      camera._old_mouse_x, camera._old_mouse_y = gh_input.mouse_getpos()
      camera._do_rotate = 1

    if (is_down == 0):
      camera._do_rotate = 0

    if (camera._do_rotate == 1):
      mx, my = gh_input.mouse_getpos()
    
      mouse_dx = float(mx - camera._old_mouse_x) * math.pi / 180
      mouse_dy = float(my - camera._old_mouse_y) * math.pi / 180

      camera._old_mouse_x = mx
      camera._old_mouse_y = my
    
      mouse_speed = 10.0
      self.rotate_view(camera, -mouse_dy * mouse_speed, -mouse_dx * mouse_speed)


      
  def update_walk(self, camera, dt):

    # OSX platform.
    KC_UP = 200
    KC_LEFT = 203
    KC_RIGHT = 205
    KC_DOWN = 208
  
    """
    # Override for Windows plateform.
    if (gh_utils.get_platform() == 1):
      KC_UP = 72
      KC_DOWN = 80
      KC_RIGHT = 77
      KC_LEFT = 75
    """
    KC_W = 17
    KC_S = 31
    KC_A = 30
    KC_D = 32
    KC_R = 19
    KC_F = 33
    

    cam_dist = camera._keyboard_speed * dt
    if ((gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)):
      self.move_along_view_xz(camera, cam_dist)
      camera._is_moving = 1
  
  
    if ((gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)):
      self.move_along_view_xz(camera, -cam_dist)
      camera._is_moving = 1
      
    if ((gh_input.keyboard_is_key_down(KC_A) == 1) or (gh_input.keyboard_is_key_down(KC_LEFT) == 1)):
      self.strafe_h_xz(camera, cam_dist, 0)
      camera._is_moving = 1
      
    if ((gh_input.keyboard_is_key_down(KC_D) == 1) or (gh_input.keyboard_is_key_down(KC_RIGHT) == 1)):
      self.strafe_h_xz(camera, -cam_dist, 0)
      camera._is_moving = 1
    
    if (gh_input.keyboard_is_key_down(KC_R) == 1):
      self.strafe_v_v2(camera, cam_dist, 0)
      camera._is_moving = 1
      
    if (gh_input.keyboard_is_key_down(KC_F) == 1):
      self.strafe_v_v2(camera, -cam_dist, 0)
      camera._is_moving = 1
    

    LEFT_BUTTON = 1
    is_down = gh_input.mouse_get_button_state(LEFT_BUTTON) 
    if ((is_down == 1) and (camera._do_rotate == 0)):
      camera._old_mouse_x, camera._old_mouse_y = gh_input.mouse_getpos()
      camera._do_rotate = 1

    if (is_down == 0):
      camera._do_rotate = 0

    if (camera._do_rotate == 1):
      mx, my = gh_input.mouse_getpos()
      
      mouse_dx = (mx - camera._old_mouse_x) * math.pi / 180
      mouse_dy = (my - camera._old_mouse_y) * math.pi / 180

      camera._old_mouse_x = mx
      camera._old_mouse_y = my
      
      mouse_speed = 10.0
      self.rotate_view(camera, -mouse_dy * mouse_speed, -mouse_dx * mouse_speed)




  def set_orbit_lookat(self, camera, lookat_x, lookat_y, lookat_z):
    camera._lookat_x = lookat_x
    camera._lookat_y = lookat_y
    camera._lookat_z = lookat_z
    gh_camera.set_lookat(camera._id, lookat_x, lookat_y, lookat_z, 1)


  def update_orbit(self, camera, dt, lookat_x, lookat_y, lookat_z):
    LEFT_BUTTON = 1
    self.update_orbit_v2(camera, dt, lookat_x, lookat_y, lookat_z, LEFT_BUTTON)


  def update_orbit_v2(self, camera, dt, lookat_x, lookat_y, lookat_z, mouse_button):
    # OSX platform.
    KC_UP = 200
    KC_LEFT = 203
    KC_RIGHT = 205
    KC_DOWN = 208
    """
    # Override for Windows plateform.
    if (gh_utils.get_platform() == 1):
      KC_UP = 72
      KC_DOWN = 80
      KC_RIGHT = 77
      KC_LEFT = 75
    """
    KC_W = 17
    KC_S = 31
    KC_A = 30
    KC_D = 32

  
    wheel_delta = gh_input.mouse_get_wheel_delta()
    camera._mouse_wheel_delta = wheel_delta
    gh_input.mouse_reset_wheel_delta()
    
    distance = camera._keyboard_speed * dt * 10
    
    if ((wheel_delta > 0) or (gh_input.keyboard_is_key_down(KC_W) == 1) or (gh_input.keyboard_is_key_down(KC_UP) == 1)):
      self.move_along_view(camera, distance)
    
    if ((wheel_delta < 0) or (gh_input.keyboard_is_key_down(KC_S) == 1) or (gh_input.keyboard_is_key_down(KC_DOWN) == 1)):
      self.move_along_view(camera, -distance)
    
    self.orbit_v2(camera, lookat_x, lookat_y, lookat_z, mouse_button)
    
    

  def update(self, camera, dt):
    # Windows platform.
    if (gh_utils.get_platform() == 1):
      gh_window.keyboard_update_buffer(0)
 
    camera._is_moving = 0
    self.pan(camera, camera._pan_speed_factor)
  
    if (camera._do_pan == 0):
      if (camera._mode == self._MODE_ORBIT):
        self.update_orbit(camera, dt, camera._lookat_x, camera._lookat_y, camera._lookat_z)  
      
      elif (camera._mode == self._MODE_FLY):
        self.update_fly(camera, dt)  
        
      elif (camera._mode == self._MODE_FPS):
        self.update_walk(camera, dt)  
     


  def draw_tripod(self, camera):
    gh_utils.tripod_visualizer_camera_render(camera._id, 0, 0, 100, 100)


