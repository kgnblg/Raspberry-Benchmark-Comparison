import gh_node
import gh_object
import gh_camera
import gh_mesh
import gh_gpu_program
import gh_texture
import gh_utils
import gh_renderer
import gh_window


class moon3d_py:
  
  def __init__(self):
    self._version_major = 0
    self._version_minor = 1
    self._version_patch = 0
    self._use_opengl2 = 1
    self._math = 0
    self._elapsed_time = 0
    self._last_time = 0

  def set_version(self, major, minor, patch):
    self._version_major = major
    self._version_minor = minor
    self._version_patch = patch
    
  def getVersionMajor(self):
   return self._version_major

  def getVersionMinor(self):
   return self._version_minor

  def getVersionPatch(self):
   return self._version_patch
    
    
  def init(self, gl_version_major, gl_version_minor):
    self.set_version(1, 2, 3)
  
    if (gl_version_major >= 3):
      self._use_opengl2 = 0
    else:
      self._use_opengl2 = 1
    
  def startFrame(self, r, g, b, a):
    self._elapsed_time = gh_window.timer_get_seconds(0)
    time_step = self._elapsed_time - self._last_time
    self._last_time = self._elapsed_time

    gh_renderer.clear_color_depth_buffers(r, g, b, a, 1.0)
    gh_renderer.set_depth_test_state(1)
  
  def endFrame():
    x = 0
    #gh_utils.tripod_visualizer_camera_render(camera_persp, winW-100, -10, 100, 100)
  
