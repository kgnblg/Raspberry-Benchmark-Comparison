

--[[
-----------------------------------------------------------------------
--]]
gfx_window = {

}

function gfx_window.getsize()
  return gh_window.getsize(0)
end



gfx_texture = {

}

function gfx_texture.load_rgba_u8(filename, abs_path)
  local PF_U8_RGB = 1
  local PF_U8_BGR = 2
  local PF_U8_RGBA = 3
  local PF_U8_BGRA = 4
  local PF_F32_RGB = 5
  local PF_F32_RGBA = 6
  local PF_F32_R = 7
  local PF_F16_RGB = 8
  local PF_F16_RGBA = 9
  local PF_F16_R = 10
  local PF_U8_R = 11
  local t = gh_texture.create_from_file(filename, PF_U8_RGBA, abs_path)
  return t
end  


--[[
-----------------------------------------------------------------------
--]]
gfx = {
  window = gfx_window,
  texture = gfx_texture,
  _font_default = 0,
  _font_title_default = 0,
  _font_default_user = 0,
  _display_common_info = 1,
  _display_user_info = 1,
  _elapsed_time = 0,
  _last_time = 0,
  _time_step = 0,
  _fps = 0,
  _fps_counter = 0,
  _fps_last_time = 0,
  _frames = 0,
  _gl_version = "",
  _gl_renderer = "",
  _GL_SAMPLES = 0,
  _client_width = 0,
  _client_height = 0,
  _main_title = "GeeXLab",
  _platform = "win64",
  _user_texts = {}, 
  _user_texts_index = 0,
  _color_program = 0 ,
  _texture_program = 0 ,
  _camera_ortho = 0,
  _mouse_quad = 0,
  _mouse_quad_width = 20,
  _mouse_quad_height = 30,
  _tex_mouse = 0,
  _show_mouse = 1,
  _mouse_color = {1.0, 1.0, 1.0, 1.0},
  _info_quad = 0,
  _vertex_color_program = 0,
  _display_info_quad = 1,
  _info_quad_size = {w=400, h=300}
}

function gfx.init()
  local ldir = gh_utils.get_scripting_libs_dir() 		
  dofile(ldir .. "lua/gx_font2.lua")
  gfx._last_time = gh_utils.get_elapsed_time()
  local lib_dir = gh_utils.get_scripting_libs_dir() 		
  gfx._font_title_default = ftgl_load_font_v2(lib_dir .. "common/Roboto-Bold.ttf", 36, 0, 0) -- 
  gfx._font_default = ftgl_load_font_v2(lib_dir .. "common/Roboto-BoldCondensed.ttf", 18, 0, 0)
  gfx._font_default_user = ftgl_load_font_v2(lib_dir .. "common/coolvetica rg.ttf", 20, 0, 0)
  gfx._gl_version = gh_renderer.get_api_version()
  gfx._gl_renderer = gh_renderer.get_renderer_model()
  gfx._GL_SAMPLES = gh_renderer.get_capability_4i("GL_SAMPLES")
  gfx._client_width, gfx._client_height = gh_window.getsize(0)
  if (gh_utils.get_platform() == 1) then
    gfx._platform = "windows"
  elseif (gh_utils.get_platform() == 2) then
    gfx._platform = "osx"
  elseif (gh_utils.get_platform() == 3) then
    gfx._platform = "linux"
  elseif (gh_utils.get_platform() == 4) then
    gfx._platform = "rpi"
  end
  

  local PF_U8_RGBA = 3
  gfx._tex_mouse = gh_texture.create_from_file(lib_dir .. "common/mouse-pointer-md.png", PF_U8_RGBA, 1)
  
  
  
  
  local color_program_vs_gl3=" \
in vec4 gxl3d_Position;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
}"

  local color_program_ps_gl3=" \
uniform vec4 color;\
out vec4 FragColor;\
void main() \
{ \
  FragColor = color;  \
}"
  
  local color_program_vs_gles2=" \
attribute vec4 gxl3d_Position;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
}"

  local color_program_ps_gles2=" \
uniform vec4 color;\
void main() \
{ \
  gl_FragColor = color;  \
}"



  if (gh_utils.get_platform() == 4) then
    gfx._color_program = gh_gpu_program.create_v2("gfx_color_program", color_program_vs_gles2, color_program_ps_gles2)
  else
    local vs = ""
    local ps = ""
    if (gh_renderer.get_api_version_major() > 3) then
      vs = "#version 150\n" .. color_program_vs_gl3
      ps = "#version 150\n" .. color_program_ps_gl3
      gfx._color_program = gh_gpu_program.create_v2("gfx_color_program", vs, ps)
    elseif (gh_renderer.get_api_version_major() == 3) then
      if (gh_renderer.get_api_version_minor() < 2) then
        vs = "#version 130\n" .. color_program_vs_gl3
        ps = "#version 130\n" .. color_program_ps_gl3
      else
        vs = "#version 150\n" .. color_program_vs_gl3
        ps = "#version 150\n" .. color_program_ps_gl3
      end
      gfx._color_program = gh_gpu_program.create_v2("gfx_color_program", vs, ps)
    end
	end



  local texture_program_vs_gl3=" \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 Vertex_UV;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  Vertex_UV = gxl3d_TexCoord0;\
}"

  local texture_program_ps_gl3=" \
uniform sampler2D tex0;\
uniform vec4 color;\
in vec4 Vertex_UV;\
out vec4 FragColor;\
void main() \
{ \
  vec2 uv = Vertex_UV.xy;\
  uv.y *= -1.0;\
  vec4 t = texture(tex0,uv);\
  if ((t.r == 1.0) && (t.g < 1.0) && (t.g < 1.0))\
    FragColor = color;  \
  else \
   discard;\
}"
  
  local texture_program_vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 Vertex_UV;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  Vertex_UV = gxl3d_TexCoord0;\
}"

  local texture_program_ps_gles2=" \
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

  if (gh_utils.get_platform() == 4) then
    gfx.texture_program = gh_gpu_program.create_v2("gfx_texture_program", texture_program_vs_gles2, texture_program_ps_gles2)
  else
    local vs = ""
    local ps = ""
    if (gh_renderer.get_api_version_major() > 3) then
      vs = "#version 150\n" .. texture_program_vs_gl3
      ps = "#version 150\n" .. texture_program_ps_gl3
      gfx.texture_program = gh_gpu_program.create_v2("gfx_texture_program", vs, ps)
    elseif (gh_renderer.get_api_version_major() == 3) then
      if (gh_renderer.get_api_version_minor() < 2) then
        vs = "#version 130\n" .. texture_program_vs_gl3
        ps = "#version 130\n" .. texture_program_ps_gl3
      else
        vs = "#version 150\n" .. texture_program_vs_gl3
        ps = "#version 150\n" .. texture_program_ps_gl3
      end
      gfx.texture_program = gh_gpu_program.create_v2("gfx_texture_program", vs, ps)
    end
  end
  gh_gpu_program.uniform1i(gfx.texture_program, "tex0", 0)
  
  
  
  
  
  
  
  
  --[[
  local vertex_color_program_vs_gl3=" \
in vec4 gxl3d_Position;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 v_color;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_color = gxl3d_Color;\
}"

  local vertex_color_program_ps_gl3=" \
in vec4 v_color;\
out vec4 FragColor;\
void main() \
{ \
  FragColor = v_color;  \
}"
  
  local vertex_color_program_vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 v_color;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_color = gxl3d_Color;\
}"

  local vertex_color_program_ps_gles2=" \
varying vec4 v_color;\
void main() \
{ \
  gl_FragColor = v_color;  \
}"

  if (gh_utils.get_platform() == 4) then
    gfx._vertex_color_program = gh_gpu_program.create_v2("gfx_vertex_color_program", vertex_color_program_vs_gles2, vertex_color_program_ps_gles2)
  else
    local vs = ""
    local ps = ""
    if (gh_renderer.get_api_version_major() > 3) then
      vs = "#version 150\n" .. vertex_color_program_vs_gl3
      ps = "#version 150\n" .. vertex_color_program_ps_gl3
      gfx._vertex_color_program = gh_gpu_program.create_v2("gfx_vertex_color_program", vs, ps)
    elseif (gh_renderer.get_api_version_major() == 3) then
      if (gh_renderer.get_api_version_minor() < 2) then
        vs = "#version 130\n" .. vertex_color_program_vs_gl3
        ps = "#version 130\n" .. vertex_color_program_ps_gl3
      else
        vs = "#version 150\n" .. vertex_color_program_vs_gl3
        ps = "#version 150\n" .. vertex_color_program_ps_gl3
      end
      gfx._vertex_color_program = gh_gpu_program.create_v2("gfx_vertex_color_program", vs, ps)
    end
	end
  
  --]]
  
  
  
  
  
  
  
  
  
  


  local winW, winH = gh_window.getsize(0)  
  gfx._camera_ortho = gh_camera.create_ortho(-winW/2, winW/2, -winH/2, winH/2, 1.0, 10.0)
  gh_camera.set_viewport(gfx._camera_ortho, 0, 0, winW, winH)
  gh_camera.set_position(gfx._camera_ortho, 0, 0, 4)
  
  gfx._mouse_quad = gh_mesh.create_quad(gfx._mouse_quad_width, gfx._mouse_quad_height)
  
  gh_input.mouse_show_cursor(0)
  
  
  
  
  gfx._info_quad = gh_mesh.create_quad(gfx._info_quad_size.w, gfx._info_quad_size.h)
  gh_mesh.set_vertex_color(gfx._info_quad, 0, 0.0, 0.1, 0.2, 0.4) -- bottom left
  gh_mesh.set_vertex_color(gfx._info_quad, 1, 0.0, 0.1, 0.2, 0.95) -- top left
  gh_mesh.set_vertex_color(gfx._info_quad, 2, 0.0, 0.1, 0.2, 0.95) -- top right
  gh_mesh.set_vertex_color(gfx._info_quad, 3, 0.0, 0.1, 0.2, 0.4) -- bottom right
    
  
end

function gfx.terminate()
  ftgl_kill()
  gh_input.mouse_show_cursor(1)
end


function gfx.resize(w, h)
  ftgl_resize(w, h)
  gfx._client_width = w
  gfx._client_height = h
  gh_camera.update_ortho(gfx._camera_ortho, -w/2, w/2, -h/2, h/2, 1.0, 10.0)
  gh_camera.set_viewport(gfx._camera_ortho, 0, 0, w, h)
end


function gfx.begin_frame()
  local elapsed_time = gh_utils.get_elapsed_time()
  gfx._time_step = elapsed_time - gfx._last_time
  gfx._last_time = elapsed_time
  gfx._elapsed_time = gfx._elapsed_time + gfx._time_step
  --gfx._elapsed_time = elapsed_time
  gfx._frames = gfx._frames + 1
  gfx._fps_counter = gfx._fps_counter + 1
  if ((gfx._elapsed_time - gfx._fps_last_time) >= 1.0) then
    gfx._fps = gfx._fps_counter
    gfx._fps_counter = 0
    gfx._fps_last_time = gfx._elapsed_time
  end
  
 
  for k in pairs (gfx._user_texts) do
    gfx._user_texts[k] = nil
  end  
  gfx._user_texts_index = 0
  
end

function gfx.end_frame(show_info)
  if (show_info == 1) then
    gfx.display_info(40)
  end

  if (gfx._show_mouse == 1)  then
    local winW, winH = gh_window.getsize(0)  
    local screen_mx, screen_my = gfx.get_mouse_position()
    gfx.draw_mouse(screen_mx - winW/2, winH/2 - screen_my, gfx._mouse_color[1], gfx._mouse_color[2], gfx._mouse_color[3], gfx._mouse_color[4], 0)
  end
  
end

function gfx.get_time()
  return gfx._elapsed_time
end

function gfx.get_dt()
  return gfx._time_step
end

function gfx.get_fps()
  return gfx._fps
end


function gfx.display_common_info(state)
  gfx._display_common_info = state
end

function gfx.display_user_info(state)
  gfx._display_user_info = state
end

function gfx.display_info(y_offset)

  ---[[
  if (gfx._display_info_quad == 1) then
    gh_renderer.set_depth_test_state(0)
    
    gh_renderer.set_blending_state(1)
    --BLEND_FACTOR_ZERO = 0
    --BLEND_FACTOR_ONE = 1
    local BLEND_FACTOR_SRC_ALPHA = 2
    --BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 3
    --BLEND_FACTOR_ONE_MINUS_DST_COLOR = 4
    local BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 5
    --BLEND_FACTOR_DST_COLOR = 6
    --BLEND_FACTOR_DST_ALPHA = 7
    --BLEND_FACTOR_SRC_COLOR = 8
    --BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 9
    gh_renderer.set_blending_factors(BLEND_FACTOR_SRC_ALPHA, BLEND_FACTOR_ONE_MINUS_SRC_ALPHA)
    
    gh_gpu_program.bind(gfx._vertex_color_program)
    gh_object.set_position(gfx._info_quad, -gfx._client_width/2 + gfx._info_quad_size.w/2, gfx._client_height/2 - gfx._info_quad_size.h/2)
    gh_object.render(gfx._info_quad)
    gh_renderer.set_blending_state(0)
  end
  --]]


  if (gfx._display_common_info == 1) then
    local y = y_offset
    if (gfx._font_title_default > 0) then
      local f = gfx._font_title_default
      ftgl_begin(f)
      ftgl_print(f, 10, y, 1, 1, 1, 1, gfx._main_title)
      y = y + 20
      ftgl_end(f)
    end

    if (gfx._font_default > 0) then
      local f = gfx._font_default
      ftgl_begin(f)
      
      ftgl_print(f, 160, y_offset, 0.9, 0.9, 0.9, 1, string.format("(%s)", gfx._platform))
      
      ftgl_print(f, 10, y, 0.9, 0.9, 0.4, 1, string.format("- Res: %d x %d - AA: %dX", gfx._client_width, gfx._client_height, gfx._GL_SAMPLES))
      y = y + 20
      ftgl_print(f, 10, y, 0.9, 0.9, 0.4, 1, string.format("- FPS: %d - frames: %d - time: %.1f sec.", gfx._fps, gfx._frames, gfx._elapsed_time))
      y = y + 20
      ftgl_print(f, 10, y, 0.9, 0.9, 0.4, 1, string.format("- GL_VERSION: %s.", gfx._gl_version))
      y = y + 20
      ftgl_print(f, 10, y, 0.9, 0.9, 0.4, 1, string.format("- GL_RENDERER: %s.", gfx._gl_renderer))
      y = y + 20
      ftgl_end(f)
    end
  end
  
  if (gfx._display_user_info == 1) then
    if (gfx._font_default_user > 0) then
      local f = gfx._font_default_user
      ftgl_begin(f)
      for i=1, gfx._user_texts_index do
        local t = gfx._user_texts[i]
        ftgl_print(f, t._x, t._y, t._r, t._g, t._b, t._a, t._text)
      end
      ftgl_end(f)
    end
  end
  
  
  
end


function gfx.write_text(x, y, r, g, b, a, text)
  local t = {_x=x, _y=y, _r=r, _g=g, _b=b, _a=a, _text=text} 
  gfx._user_texts_index = gfx._user_texts_index + 1
  gfx._user_texts[gfx._user_texts_index] = t
end


function gfx.show_info_quad(state)
  gfx._display_info_quad = state
end

function gfx.update_info_quad_size(new_w, new_h)
  gfx._info_quad_size.w = new_w
  gfx._info_quad_size.h = new_h
  gh_mesh.update_quad_size(gfx._info_quad_size.w, gfx._info_quad_size.h)
end


function gfx.show_mouse(state)
  gfx._show_mouse = state
  if (state == 0) then
    gh_input.mouse_show_cursor(1)
  else
    gh_input.mouse_show_cursor(0)
  end
end

function gfx.draw_mouse(x, y, r, g, b, a, tex)
  gh_camera.bind(gfx._camera_ortho)
  local t = gfx._tex_mouse
  if (tex > 0) then
    t = tex
  end
  gh_renderer.set_depth_test_state(0)
  gh_texture.bind(t, 0)
  gh_gpu_program.bind(gfx.texture_program)
  gh_gpu_program.uniform4f(gfx.texture_program, "color", r, g, b, a)
  gh_object.set_position(gfx._mouse_quad, x+gfx._mouse_quad_width/2, y-gfx._mouse_quad_height/2, 0)
  --[[
  gh_renderer.set_blending_state(1)
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
  gh_renderer.set_blending_factors(1, 2)
  --]]
  gh_object.render(gfx._mouse_quad)
  --gh_renderer.set_blending_state(0)
end  



function gfx.rand_init(seed)
  if (seed == -1) then
    math.randomseed(os.time())
  else
    math.randomseed(seed)
  end
end

function gfx.rand(a, b)
	if (a > b) then
		local c = b
		b = a
		a = c
	end
	local delta = b-a
	return (a + math.random()*delta)
end

function gfx.trace(s)
  gh_utils.trace(s)
end

function gfx.is_windows()
  if (gh_utils.get_platform() == 1) then
    return 1
  end
  return 0
end    

function gfx.is_oSX()
  if (gh_utils.get_platform() == 2) then
    return 1
  end
  return 0
end    

function gfx.is_linux()
  if (gh_utils.get_platform() == 3) then
    return 1
  end
  return 0
end    

function gfx.is_rpi()
  if (gh_utils.get_platform() == 4) then
    return 1
  end
  return 0
end   

function gfx.msaa(state)
  if (state == 1) then
    gh_renderer.enable_state("GL_MULTISAMPLE")
  else
    gh_renderer.disable_state("GL_MULTISAMPLE")
  end
end      

function gfx.vsync(state)
  gh_renderer.vsync(state)
end    


function gfx.get_mouse_position()
  local mx, my = gh_input.mouse_getpos()
  if (gh_utils.get_platform() == 4) then
    local w, h = gh_window.getsize(0)
    return (mx + w/2), -(my - h/2) 
  end
  return mx, my
end    

function gfx.set_mouse_color(r, g, b, a)
  gfx._mouse_color[1] = r
  gfx._mouse_color[2] = g
  gfx._mouse_color[3] = b
  gfx._mouse_color[4] = a
end  


 


