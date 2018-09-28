"""
Moon3D Python version.
Work in progress.
Check the Lua version for all available functions

http://www.geeks3d.com/glslhacker/moon3d.php

"""


import gh_node
import gh_object
import gh_camera
import gh_mesh
import gh_gpu_program
import gh_texture
import gh_utils
import gh_renderer
import gh_window


VERSION = "0.1.0"
_version_major = 0
_version_minor = 1
_version_patch = 0

_use_opengl2 = 1
_math = 0
_elapsed_time = 0
_last_time = 0
_time_step = 0
_font = 0
_winW = 0
_winH = 0
_camera_persp = 0
_old_camera_persp = 0
_camera_persp_fov = 50
_camera_ortho = 0
_bkg_quad = 0




class moon3d_image:
  def create2dRgbU8(self, width, height):
    PF_U8_RGB = 1
    texture = gh_texture.create_2d_v2(width, height, PF_U8_RGB, 0)
    return texture
    
  def create2dRgbaU8(self, width, height):
    PF_U8_RGBA = 3
    texture = gh_texture.create_2d_v2(width, height, PF_U8_RGBA, 0)
    return texture

  def updatePixmap(self, texture, pixmap):
    gh_texture.update_gpu_memory_from_buffer(texture, pixmap)
    
  def load2d(self, filename):
    absolute_path = 0
    gen_mipmaps = 1
    RGBA_U8 = 3
    texture = gh_texture.create_from_file_v2(filename, RGBA_U8, absolute_path, gen_mipmaps)
    #texture = gh_texture.create_from_file(filename, 0, absolute_path)
    return texture

  def load2dRgbaF32(self, filename, absolute_path, gen_mipmaps):
    PF_F32_RGBA = 6
    texture = gh_texture.create_from_file_v2(filename, PF_F32_RGBA, absolute_path, gen_mipmaps)
    return texture

  def loadCubeMap(self, posx_filename, negx_filename, posy_filename, negy_filename, posz_filename, negz_filename):
    absolute_path = 0
    RGBA_U8 = 3
    cm = gh_texture.create_cube_from_file(posx_filename, negx_filename, posy_filename, negy_filename, posz_filename, negz_filename, RGBA_U8, absolute_path, 0)
    return cm


class moon3d_graphics:
  
  def __init__(self):
    self._use_opengl2 = 1
  
  def init0(self, use_opengl2):
    self._use_opengl2 = use_opengl2
  
  def wireframe(self, state):
    RENDERER_POLYGON_FACE_BACK = 0
    RENDERER_POLYGON_FACE_FRONT = 1
    RENDERER_POLYGON_FACE_BACK_FRONT = 2
    RENDERER_POLYGON_MODE_POINT = 0
    RENDERER_POLYGON_MODE_LINE = 1
    RENDERER_POLYGON_MODE_SOLID = 2
    if (state == 1):
      gh_renderer.rasterizer_set_polygon_mode(RENDERER_POLYGON_FACE_BACK_FRONT, RENDERER_POLYGON_MODE_LINE)
    else:
      gh_renderer.rasterizer_set_polygon_mode(RENDERER_POLYGON_FACE_BACK_FRONT, RENDERER_POLYGON_MODE_SOLID)
    gh_renderer.rasterizer_apply_states()
      
  def vsync(self, state):
    if (state == 1):
      gh_renderer.set_vsync(1)
    else:
      gh_renderer.set_vsync(0)
      
  def blendColor(self, state, src_factor, dst_factor):
    """
    GXL3D_RENDERER_BLEND_FACTOR_ZERO = 0
    GXL3D_RENDERER_BLEND_FACTOR_ONE = 1
    GXL3D_RENDERER_BLEND_FACTOR_SRC_ALPHA = 2
    GXL3D_RENDERER_BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 3
    GXL3D_RENDERER_BLEND_FACTOR_ONE_MINUS_DST_COLOR = 4
    GXL3D_RENDERER_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 5
    GXL3D_RENDERER_BLEND_FACTOR_DST_COLOR = 6
    GXL3D_RENDERER_BLEND_FACTOR_DST_ALPHA = 7
    GXL3D_RENDERER_BLEND_FACTOR_SRC_COLOR = 8
    GXL3D_RENDERER_BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 9
    """
    if (state == 1):
      gh_renderer.set_blending_state(1)
      gh_renderer.set_blending_factors(src_factor, dst_factor)
    else:
      gh_renderer.set_blending_state(0)

  def getNumOpenGLExtensions(self):
    return gh_renderer.get_num_opengl_extensions()

  def getOpenGLExtensionName(self, index):
    ext_name = gh_renderer.get_opengl_extension(index)
    return ext_name
    
  def createQuad(self, width, height):
    quad = gh_mesh.create_quad(width, height)
    if (self._use_opengl2 == 1):
      gh_object.use_opengl21(quad, 1)
    return quad

  def resizeQuad(self, quad, width, height):
    gh_mesh.update_quad_size(quad, width, height)
    
  def bindGpuProgram(self, gpu_prog):
    gh_gpu_program.bind(gpu_prog)

  def getGpuProgram(self, name):
    gpu_prog = gh_node.getid(name)
    if (gpu_prog > 0):
      # Workaround for Intel GPUs - START
      gh_gpu_program.bind(gpu_prog)
      gh_gpu_program.bind(0)
      # Workaround for Intel GPUs - END
    return gpu_prog
    
  def bindTexture(self, texture, texture_unit):
    gh_texture.bind(texture, texture_unit)
    
  def draw(self, obj):
    gh_object.render(obj)

  def draw2(self, obj, gpu_program):
    gh_gpu_program.bind(gpu_program)
    gh_object.render(obj)
  
    
    
   
    


class moon3d_window:
  #def __init__(self):

  def getSize(self):
    return gh_window.getsize(0)

  def resize(self):
    global _font
    global _winW
    global _winH
    global _camera_persp
    global _camera_persp_fov
    global _camera_ortho
    global _bkg_quad
    _winW, _winH = gh_window.getsize(0)
    aspect = 1.333
    if (_winH > 0):
      aspect = _winW / _winH
    gh_camera.update_persp(_camera_persp, _camera_persp_fov, aspect, 0.1, 1000.0)
    gh_camera.set_viewport(_camera_persp, 0, 0, _winW, _winH)
    gh_camera.update_ortho(_camera_ortho, -_winW/2, _winW/2, -_winH/2, _winH/2, 1.0, -1.0)
    gh_camera.set_viewport(_camera_ortho, 0, 0, -_winW, _winH)
    gh_mesh.update_quad_size(_bkg_quad, _winW, _winH)
    gh_utils.font_set_viewport_info(_font, 0, 0, _winW, _winH)


    
    
class moon3d_object:
  def setPosition(self, obj, x, y, z):
    gh_object.set_position(obj, x, y, z)

  def setEulerAngles(self, obj, pitch, yaw, roll):
    gh_object.set_euler_angles(obj, pitch, yaw, roll)

  def setScale(self, obj, x, y, z):
    gh_object.set_scale(obj, x, y, z)

  def getNumVertices(self, obj):
    return gh_object.get_num_vertices(obj)

  def getNumFaces(self, obj):
    return gh_object.get_num_faces(obj)


    

    
class moon3d_camera:    
  def __init__(self):
    self._lookat_x = 0
    self._lookat_y = 0
    self._lookat_z = 0
       
  def newPersp(self, fov, aspect, znear, zfar):
    viewport_width, viewport_height = gh_window.getsize(0)
    c = gh_camera.create_persp(fov, aspect,  znear, zfar)
    gh_camera.set_viewport(c, 0, 0, viewport_width, viewport_height)
    return c

  def setPosition(self, cam, x, y, z):
    gh_camera.set_position(cam, x, y, z)
    gh_camera.set_lookat(cam, self._lookat_x, self._lookat_y, self._lookat_z, 1)

  def setLookat(self, cam, x, y, z):
    self._lookat_x = x
    self._lookat_y = y
    self._lookat_z = z
    gh_camera.set_lookat(cam, self._lookat_x, self._lookat_y, self._lookat_z, 1)
    
  def bind(self, cam):
    gh_camera.bind(cam)
    
  def updatePerspective(self, camera, fov, aspect, znear, zfar):
    gh_camera.update_persp(camera, fov, aspect, znear, zfar)
    viewport_width, viewport_height = gh_window.getsize(0)
    gh_camera.set_viewport(camera, 0, 0, viewport_width, viewport_height)
  
    


      
graphics = moon3d_graphics()
window = moon3d_window()
camera = moon3d_camera()    
image = moon3d_image()
object = moon3d_object()
      

def set_version(major, minor, patch):
  global _version_major
  global _version_minor
  global _version_patch
  _version_major = major
  _version_minor = minor
  _version_patch = patch
  
def getVersionMajor():
  global _version_major
  return _version_major

def getVersionMinor():
  global _version_minor
  return _version_minor

def getVersionPatch():
  global _version_patch
  return _version_patch
  
def init_camera_perspective():
  global _camera_persp
  global _winW
  global _winH
  global _camera_persp_fov
  global _old_camera_persp
  aspect = _winW/_winH
  _camera_persp = gh_camera.create_persp(_camera_persp_fov, aspect, 0.1, 1000.0)
  gh_camera.set_viewport(_camera_persp, 0, 0, _winW, _winH)
  gh_camera.set_position(_camera_persp, 0, 10, 50)
  gh_camera.set_lookat(_camera_persp, 0, 0, 0, 1)
  gh_camera.setupvec(_camera_persp, 0, 1, 0, 0)
  _old_camera_persp = _camera_persp
  
def init_camera_ortho():
  global _camera_ortho
  global _winW
  global _winH
  _camera_ortho = gh_camera.create_ortho(-_winW/2, _winW/2, -_winH/2, _winH/2, 1.0, -1.0)
  gh_camera.set_viewport(_camera_ortho, 0, 0, _winW, _winH)
  gh_camera.set_position(_camera_ortho, 0, 0, 1)
  _old_camera_ortho = _camera_ortho
  
def init_font():
  global _font
  global _winW
  global _winH
  _font = gh_utils.font_create("Tahoma", 14)
  gh_utils.font_set_viewport_info(_font, 0, 0, _winW, _winH)

def get_font():
  global _font
  return _font

def init_bkg_quad():
  global _use_opengl2
  global _bkg_quad
  global _winW
  global _winH
  _bkg_quad = gh_mesh.create_quad(_winW, _winH)
  if (_use_opengl2 == 1):
    gh_object.use_opengl21(_bkg_quad, 1)
  
  
def init(gl_version_major, gl_version_minor):
  global _use_opengl2
  global _elapsed_time
  global _last_time
  global _winW
  global _winH
  
  _winW, _winH = gh_window.getsize(0)
  
  set_version(0, 1, 0)
  
  if (gl_version_major >= 3):
    _use_opengl2 = 0
  else:
    _use_opengl2 = 1

  graphics.init0(_use_opengl2)
  init_font()
  init_camera_perspective()
  init_camera_ortho()
  init_bkg_quad()
  
  _elapsed_time = gh_window.timer_get_seconds(0)
  _last_time = _elapsed_time
  
  gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
  gh_renderer.set_vsync(0)
  gh_renderer.set_scissor_state(0)
  gh_renderer.set_depth_test_state(1)

  
def startFrame(r, g, b, a):
  global _elapsed_time
  global _last_time
  global _time_step
  _elapsed_time = gh_window.timer_get_seconds(0)
  _time_step = _elapsed_time - _last_time
  _last_time = _elapsed_time

  gh_renderer.clear_color_depth_buffers(r, g, b, a, 1.0)
  gh_renderer.set_depth_test_state(1)

def endFrame():
  x = 0
  #gh_utils.tripod_visualizer_camera_render(camera_persp, winW-100, -10, 100, 100)

def getTime():
  global _elapsed_time
  return _elapsed_time

def getTimeStep():
  return _time_step
  
def getDemoDir():
  return gh_utils.get_demo_dir()
  
def print_(x, y, text):
  gh_utils.font_render(_font, x, y, 0.2, 1.0, 0.0, 1.0, text)

def printRGBA(x, y, r, g, b, a, text):
  gh_utils.font_render(_font, x, y, r, g, b, a, text)

def writeTrace(trace):
  gh_utils.trace(trace)
  
  