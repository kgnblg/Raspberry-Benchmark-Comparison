import gh_node
import gh_object
import gh_camera
import gh_gpu_program
import gh_utils
import gh_renderer
import gh_window
import gh_input
import gh_texture
import gh_mesh
import math
#import random # Generates ton of warning on Raspbian... 
import sys


libdir = gh_utils.get_scripting_libs_dir() 		
sys.path.append(libdir + "python/")
from gx_font import * # for all ftgl_xxxx() functions


#----------------------------------------------------------------------
class gfx_window:
  def __init__(self):
    self._initialized = 1
  
  def getsize(self):
    return gh_window.getsize(0)

#----------------------------------------------------------------------
class gfx_texture:
  def __init__(self):
    self._initialized = 1
  
  def load_rgba_u8(self, filename, abs_path):
    PF_U8_RGB = 1
    PF_U8_BGR = 2
    PF_U8_RGBA = 3
    PF_U8_BGRA = 4
    PF_F32_RGB = 5
    PF_F32_RGBA = 6
    PF_F32_R = 7
    PF_F16_RGB = 8
    PF_F16_RGBA = 9
    PF_F16_R = 10
    PF_U8_R = 11
    t = gh_texture.create_from_file(filename, PF_U8_RGBA, abs_path)
    return t


#----------------------------------------------------------------------
class gfx_01:

  def __init__(self):
    self.window = gfx_window()
    self.texture = gfx_texture()
    self._font_default = 0
    self._font_title_default = 0
    self._font_default_user = 0
    self._elapsed_time = 0
    self._last_time = 0
    self._time_step = 0
    self._fps = 0
    self._fps_counter = 0
    self._fps_last_time = 0
    self._frames = 0
    self._gl_version = ""
    self._gl_renderer = ""
    self._GL_SAMPLES = 0
    self._client_width = 0
    self._client_height = 0
    self._main_title = "GLSL Hacker"
    self._user_texts = [] 
    self._user_texts_index = 0
    self._color_program = 0
    self._texture_program = 0
    self._camera_ortho = 0
    self._mouse_quad = 0
    self._mouse_quad_width = 20
    self._mouse_quad_height = 30
    self._tex_mouse = 0
    self._show_mouse = 1
    self._mouse_color = [1.0, 1.0, 1.0, 1.0]
    

  def initialize(self):
    self._last_time = gh_utils.get_elapsed_time()
    lib_dir = gh_utils.get_scripting_libs_dir() 		
    #self._font_title_default = ftgl_load_font_v2(lib_dir + "common/Vampire Raves.otf", 30, 0, 0)
    self._font_title_default = ftgl_load_font_v2(lib_dir + "common/coolvetica rg.ttf", 30, 0, 0)
    self._font_default = ftgl_load_font_v2(lib_dir + "common/BebasNeue.otf", 20, 0, 0)
    self._font_default_user = ftgl_load_font_v2(lib_dir + "common/coolvetica rg.ttf", 20, 0, 0)
    self._gl_version = gh_renderer.get_api_version()
    self._gl_renderer = gh_renderer.get_renderer_model()
    self._GL_SAMPLES, y, z, w = gh_renderer.get_capability_4i("GL_SAMPLES")
    self._client_width, self._client_height = gh_window.getsize(0)
    if (gh_utils.get_platform() == 1):
       self._main_title = "GLSL Hacker (Windows 64-bit)"
    elif (gh_utils.get_platform() == 2):
      self._main_title = "GLSL Hacker (Mac OS X 64-bit)"
    elif (gh_utils.get_platform() == 3):
      self._main_title = "GLSL Hacker (Linux 64-bit)"
    elif (gh_utils.get_platform() == 4):
      self._main_title = "GLSL Hacker (Raspberry Pi x32)"
      
    PF_U8_RGBA = 3
    self._tex_mouse = gh_texture.create_from_file(lib_dir + "common/mouse-pointer-md.png", PF_U8_RGBA, 1)
    
    
    color_program_vs_gl3=" \
    #version 150\
    in vec4 gxl3d_Position;\
    uniform mat4 gxl3d_ModelViewProjectionMatrix; \
    void main() \
    { \
      gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
    }"

    color_program_ps_gl3=" \
    #version 150\
    uniform vec4 color;\
    out vec4 gl_FragColor;\
    void main() \
    { \
      gl_FragColor = color;  \
    }"
  
    color_program_vs_gles2=" \
    attribute vec4 gxl3d_Position;\
    uniform mat4 gxl3d_ModelViewProjectionMatrix; \
    void main() \
    { \
      gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
    }"

    color_program_ps_gles2=" \
    uniform vec4 color;\
    void main() \
    { \
      gl_FragColor = color;  \
    }"

    if (gh_utils.get_platform() == 4):
      self._color_program = gh_gpu_program.create_v2("gfx_color_program", color_program_vs_gles2, color_program_ps_gles2)
    else:
      self._color_program = gh_gpu_program.create("gfx_color_program", color_program_vs_gl3, color_program_ps_gl3)
  
  
  
 
    texture_program_vs_gl3=" \
    #version 150\
    in vec4 gxl3d_Position;\
    in vec4 gxl3d_TexCoord0;\
    uniform mat4 gxl3d_ModelViewProjectionMatrix; \
    out vec4 Vertex_UV;\
    void main() \
    { \
      gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
      Vertex_UV = gxl3d_TexCoord0;\
    }"

    texture_program_ps_gl3=" \
    #version 150\
    uniform sampler2D tex0;\
    uniform vec4 color;\
    varying vec4 Vertex_UV;\
    out vec4 gl_FragColor;\
    void main() \
    { \
      vec2 uv = Vertex_UV.xy;\
      uv.y *= -1.0;\
      vec4 t = texture(tex0,uv);\
      if ((t.r == 1.0) && (t.g < 1.0) && (t.g < 1.0))\
        gl_FragColor = color;  \
      else \
       discard;\
    }"
  
    texture_program_vs_gles2=" \
    attribute vec4 gxl3d_Position;\
    attribute vec4 gxl3d_TexCoord0;\
    uniform mat4 gxl3d_ModelViewProjectionMatrix; \
    varying vec4 Vertex_UV;\
    void main() \
    { \
      gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
      Vertex_UV = gxl3d_TexCoord0;\
    }"

    texture_program_ps_gles2=" \
    uniform sampler2D tex0;\
    uniform vec4 color;\
    varying vec4 Vertex_UV;\
    void main() \
    { \
      vec2 uv = Vertex_UV.xy;\
      uv.y *= -1.0;\
      vec4 t = texture2D(tex0,uv);\
      if ((t.r == 1.0) && (t.g < 1.0) && (t.b < 1.0))\
        gl_FragColor = color;  \
      else \
       discard;\
    }"
    

    if (gh_utils.get_platform() == 4):
      self.texture_program = gh_gpu_program.create_v2("gfx_texture_program", texture_program_vs_gles2, texture_program_ps_gles2)
    else:
      self.texture_program = gh_gpu_program.create("gfx_texture_program", texture_program_vs_gl3, texture_program_ps_gl3)
      
    gh_gpu_program.uniform1i(self.texture_program, "tex0", 0)

    winW, winH = gh_window.getsize(0)  
    self._camera_ortho = gh_camera.create_ortho(-winW/2.0, winW/2.0, -winH/2.0, winH/2.0, 1.0, 10.0)
    gh_camera.set_viewport(self._camera_ortho, 0, 0, winW, winH)
    gh_camera.set_position(self._camera_ortho, 0, 0, 4)

    self._mouse_quad = gh_mesh.create_quad(self._mouse_quad_width, self._mouse_quad_height)
    #self._mouse_quad_width = 20.0,
    #self._mouse_quad_height = 30.0,
    #self._mouse_quad = gh_mesh.create_quad(20, 30)



  def terminate(self):
    ftgl_kill()


  def resize(self, w, h):
    ftgl_resize(w, h)
    

  def begin_frame(self):
    elapsed_time = gh_utils.get_elapsed_time()
    self._time_step = elapsed_time - self._last_time
    self._last_time = elapsed_time
    self._elapsed_time = self._elapsed_time + self._time_step
    self._frames = self._frames + 1
    self._fps_counter = self._fps_counter + 1
    if ((self._elapsed_time - self._fps_last_time) >= 1.0):
      self._fps = self._fps_counter
      self._fps_counter = 0
      self._fps_last_time = self._elapsed_time
      
    del self._user_texts[:]
    

  
      

  def end_frame(self, show_info):
    if (show_info == 1):
      self.display_info(30)

    if (self._show_mouse == 1):
      winW, winH = gh_window.getsize(0)  
      screen_mx, screen_my = self.get_mouse_position()
      self.draw_mouse(screen_mx - winW/2, winH/2 - screen_my, self._mouse_color[0], self._mouse_color[1], self._mouse_color[2], self._mouse_color[3], 0)


  def get_time(self):
    return self._elapsed_time

  def get_dt(self):
    return self._time_step

  def display_info(self, y_offset):
    y = y_offset
    if (self._font_title_default > 0):
      f = self._font_title_default
      ftgl_begin(f)
      ftgl_print(f, 10, y, 1, 1, 1, 1, self._main_title)
      y = y + 30
      ftgl_end(f)

    if (self._font_default > 0):
      f = self._font_default
      ftgl_begin(f)
      ftgl_print(f, 10, y, 0.9, 0.9, 0.9, 1, ("- Res: %d x %d - AA: %dX") % (self._client_width, self._client_height, self._GL_SAMPLES))
      y = y + 20
      ftgl_print(f, 10, y, 0.9, 0.9, 0.9, 1, ("- FPS: %d - frames: %d - time: %.1f sec.") % (self._fps, self._frames, self._elapsed_time))
      y = y + 20
      ftgl_print(f, 10, y, 0.8, 0.8, 0.8, 1, ("- GL_VERSION: %s.") % (self._gl_version))
      y = y + 20
      ftgl_print(f, 10, y, 0.7, 0.7, 0.7, 1, ("- GL_RENDERER: %s.") % (self._gl_renderer))
      y = y + 20
      ftgl_end(f)
      

    if (self._font_default_user > 0):
      f = self._font_default_user
      ftgl_begin(f)
      for i in range(0, len(self._user_texts)-1):
        t = self._user_texts[i]
        ftgl_print(f, t[0], t[1], t[2], t[3], t[4], t[5], t[6])
      ftgl_end(f)
      
      
  def write_text(self, x, y, r, g, b, a, text):
    self._user_texts.append([x, y, r, g, b, a, text])
      

  def rand_init(self, theseed):
    """
    if (theseed == -1):
      random.seed(None)
    else:
      random.seed(theseed)
    """  
    gh_utils.trace("gfx.rand_init(): not implemented")
    

  def rand(self, a, b):
    """
    if (a > b):
      c = b
      b = a
      a = c
    delta = b-a
    return (a + random.random()*delta)
    """
    gh_utils.trace("gfx.rand(): not implemented")


  def trace(self, trace):
    gh_utils.trace(trace)
  
  def is_windows(self):
    if (gh_utils.get_platform() == 1):
      return 1
    return 0

  def is_oSX(self):
    if (gh_utils.get_platform() == 2):
      return 1
    return 0

  def is_linux(self):
    if (gh_utils.get_platform() == 3) :
      return 1
    return 0

  def is_rpi(self):
    if (gh_utils.get_platform() == 4):
      return 1
    return 0

  def vsync(self, state):
    gh_renderer.set_vsync(state)
    
  def msaa(self, state):
    if (state == 1):
      gh_renderer.enable_state("GL_MULTISAMPLE")
    else:
      gh_renderer.disable_state("GL_MULTISAMPLE")



  def get_mouse_position(self):
    mx, my = gh_input.mouse_getpos()
    if (gh_utils.get_platform() == 4):
      w, h = gh_window.getsize(0)
      return (mx + w/2), -(my - h/2) 
    return mx, my


  def show_mouse(self, state):
    self._show_mouse = state

  def draw_mouse(self, x, y, r, g, b, a, tex):
    gh_camera.bind(self._camera_ortho)
    t = self._tex_mouse
    if (tex > 0):
      t = tex
    gh_texture.bind(t, 0)
    gh_gpu_program.bind(self.texture_program)
    gh_gpu_program.uniform4f(self.texture_program, "color", r, g, b, a)
    gh_object.set_position(self._mouse_quad, x+self._mouse_quad_width/2, y-self._mouse_quad_height/2, 0)
    gh_object.render(self._mouse_quad)

  def set_mouse_color(self, r, g, b, a):
    self._mouse_color[0] = r
    self._mouse_color[1] = g
    self._mouse_color[2] = b
    self._mouse_color[3] = a

