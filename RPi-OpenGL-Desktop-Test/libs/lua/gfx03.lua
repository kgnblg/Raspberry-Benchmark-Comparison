

--[[
-----------------------------------------------------------------------
--]]
gfx_utils = {

}

function gfx_utils.create_gpu_program(gpu_prog_name, vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  local vs = ""
  local ps = ""
  if (gh_utils.get_platform() == 4) then
    vs = vs_gles2
    ps = ps_gles2
  else
    if (gh_renderer.get_api_version_major() > 3) then
      vs = "#version 150\n" .. vs_gl3
      ps = "#version 150\n" .. ps_gl3
    elseif (gh_renderer.get_api_version_major() == 3) then
      if (gh_renderer.get_api_version_minor() < 2) then
        vs = "#version 130\n" .. vs_gl3
        ps = "#version 130\n" .. ps_gl3
      else
        vs = "#version 150\n" .. vs_gl3
        ps = "#version 150\n" .. ps_gl3
      end
    elseif (gh_renderer.get_api_version_major() < 3) then
      vs = vs_gl2
      ps = ps_gl2
    end
  end
  local p = gh_gpu_program.create_v2(gpu_prog_name, vs, ps)
  return p
end  




--[[
-----------------------------------------------------------------------
--]]
gfx_window = {

}

function gfx_window.getsize()
  return gh_window.getsize(0)
end



--[[
-----------------------------------------------------------------------
--]]
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

function gfx_texture.load(filename, pixel_format)
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

  local pf = PF_U8_RGBA
  if (pixel_format == "rgb_u8") then
    pf = PF_U8_RGB 
  elseif (pixel_format == "bgr_u8") then
    pf = PF_U8_BGR
  elseif (pixel_format == "rgba_u8") then
    pf = PF_U8_RGBA
  elseif (pixel_format == "bgra_u8") then
    pf = PF_U8_BGRA
  elseif (pixel_format == "r_u8") then
    pf = PF_U8_R
  elseif (pixel_format == "rgb_f32") then
    pf = PF_F32_RGB
  elseif (pixel_format == "rgba_f32") then
    pf = PF_F32_RGBA
  elseif (pixel_format == "r_f32") then
    pf = PF_F32_R
  end
  local gen_mipmaps = 1
  local compressed_format = ""
  local t = gh_texture.create_from_file_v6(filename, PF_U8_RGBA, gen_mipmaps, compressed_format)
  return t
end  



--[[
-----------------------------------------------------------------------
--]]
gfx_camera = {

}

function gfx_camera.create_ortho(viewport_x, viewport_y, viewport_width, viewport_height)
  local c = gh_camera.create_ortho(-viewport_width/2, viewport_width/2, -viewport_height/2, viewport_height/2, 1.0, 10.0)
  gh_camera.set_viewport(c, viewport_x, viewport_y, viewport_width, viewport_height)
  gh_camera.set_position(c, 0, 0, 4)
  return c
end

function gfx_camera.update_ortho(cam, viewport_x, viewport_y, viewport_width, viewport_height)
  gh_camera.update_ortho(cam, -viewport_width/2, viewport_width/2, -viewport_height/2, viewport_height/2, 1.0, 10.0)
  gh_camera.set_viewport(cam, viewport_x, viewport_y, viewport_width, viewport_height)
end


--[[
-----------------------------------------------------------------------
--]]
gfx_mouse = {
  _color = {1.0, 1.0, 1.0, 1.0},
  _show = 0,
  _tex = 0, 
  _quad  = 0,
  _program = 0,
  _quad_width = 20,
  _quad_height = 30
}

function gfx_mouse.init_gpu_program()

  local vs_gl3=" \
in vec4 gxl3d_Position;\
in vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 Vertex_UV;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  Vertex_UV = gxl3d_TexCoord0;\
}"

  local ps_gl3=" \
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
  
  local vs_gl2=" \
varying vec4 Vertex_UV;\
void main() \
{ \
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;\
  Vertex_UV = gl_MultiTexCoord0;\
}"

  local ps_gl2=" \
uniform sampler2D tex0;\
uniform vec4 color;\
varying vec4 Vertex_UV;\
void main() \
{ \
  vec2 uv = Vertex_UV.xy;\
  uv.y *= -1.0;\
  vec4 t = texture2D(tex0,uv);\
  if ((t.r == 1.0) && (t.g < 1.0) && (t.g < 1.0))\
    gl_FragColor = color;  \
  else \
   discard;\
}"

  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 Vertex_UV;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  Vertex_UV = gxl3d_TexCoord0;\
}"

  local ps_gles2=" \
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

  local p = gfx_utils.create_gpu_program("gfx_mouse_program", vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  gh_gpu_program.uniform1i(p, "tex0", 0)
  gfx_mouse._program = p
end  


function gfx_mouse.get_position()
  local mx, my = gh_input.mouse_getpos()
  
  if (gh_utils.get_platform() == 2) then -- OSX     
    w, h = gh_window.getsize(0)
    my = h - my
  end
    
  if (gh_utils.get_platform() == 4) then -- RPi
    local w, h = gh_window.getsize(0)
    mx = mx + w/2
    my = -(my - h/2) 
  end
  
  return mx, my
end    

-----------------------------------------------------------------------
function gfx_mouse.set_color(r, g, b, a)
  gfx_mouse._color[1] = r
  gfx_mouse._color[2] = g
  gfx_mouse._color[3] = b
  gfx_mouse._color[4] = a
end  


function gfx_mouse.init()
  if (gfx_mouse._tex == 0) then
    --local PF_U8_RGBA = 3
    --gfx._tex_mouse = gh_texture.create_from_file(lib_dir .. "common/mouse-pointer-md.png", PF_U8_RGBA, 1)
    local lib_dir = gh_utils.get_scripting_libs_dir() 		
    gfx_mouse._tex = gfx.texture.load(lib_dir .. "common/mouse-pointer-md.png", rgba_u8)
  end
  
  if (gfx_mouse._quad == 0) then
    gfx_mouse._quad = gh_mesh.create_quad(gfx_mouse._quad_width, gfx_mouse._quad_height)
  end
  
  if (gfx_mouse._program == 0) then
    gfx_mouse.init_gpu_program()
  end
  
end  

function gfx_mouse.terminate()
  gh_input.mouse_show_cursor(1)
end

----------------------------------------------------------------------------------------
function gfx_mouse.show(state)
  gfx_mouse._show = state
  if (state == 0) then
    gh_input.mouse_show_cursor(1)
  else
    gh_input.mouse_show_cursor(0)
  end
end


function gfx_mouse.draw(ortho_cam, x, y)
  gh_camera.bind(ortho_cam)
  gh_renderer.set_depth_test_state(0)
  gh_texture.bind(gfx_mouse._tex, 0)
  gh_gpu_program.bind(gfx_mouse._program)
  gh_gpu_program.uniform4f(gfx_mouse._program, "color", gfx_mouse._color[1], gfx_mouse._color[2], gfx_mouse._color[3], gfx_mouse._color[4])
  gh_object.set_position(gfx_mouse._quad, x + gfx_mouse._quad_width/2, y - gfx_mouse._quad_height/2, 0)
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
  gh_object.render(gfx_mouse._quad)
  --gh_renderer.set_blending_state(0)
end  


--[[
-----------------------------------------------------------------------
--]]
gfx = {
  window = gfx_window,
  texture = gfx_texture,
  camera = gfx_camera,
  mouse = gfx_mouse,
  gpu_program = 0,
  _font_default = 0,
  _font_title_default = 0,
  _font_default_user_40 = 0,
  _font_default_user_30 = 0,
  _font_default_user_20 = 0,
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
  _user_texts_20 = {}, 
  _user_texts_index_20 = 0,
  _user_texts_30 = {}, 
  _user_texts_index_30 = 0,
  _user_texts_40 = {}, 
  _user_texts_index_40 = 0,
  _mouse_program = 0,
  _camera_ortho = 0,
  _bkg_quad = 0,
  _display_bkg_quad = 1,
  _info_quad = 0,
  _display_info_quad = 1,
  _info_quad_size = {w=400, h=300},
  _quad = 0
}



--------------------------------------------------------

----------------------------------------------------------------------------------------
function gfx.init()

  local ldir = gh_utils.get_scripting_libs_dir() 		
  dofile(ldir .. "lua/shaderlib.lua")
  dofile(ldir .. "lua/gx_font2.lua")
  
  gfx.gpu_program = shaderlib
  
  gfx._last_time = gh_utils.get_elapsed_time()
  
  local lib_dir = gh_utils.get_scripting_libs_dir() 		
  gfx._font_title_default = ftgl_load_font_v2(lib_dir .. "common/Roboto-Bold.ttf", 36, 0, 0) -- 
  gfx._font_default = ftgl_load_font_v2(lib_dir .. "common/Roboto-BoldCondensed.ttf", 18, 0, 0)
  gfx._font_default_user_40 = ftgl_load_font_v2(lib_dir .. "common/coolvetica rg.ttf", 40, 0, 0)
  gfx._font_default_user_30 = ftgl_load_font_v2(lib_dir .. "common/coolvetica rg.ttf", 30, 0, 0)
  gfx._font_default_user_20 = ftgl_load_font_v2(lib_dir .. "common/coolvetica rg.ttf", 20, 0, 0)
  gfx._font_default_user = ftgl_load_font_v2(lib_dir .. "common/coolvetica rg.ttf", 16, 0, 0)

  gfx._gl_version = gh_renderer.get_api_version()
  gfx._gl_renderer = gh_renderer.get_renderer_model()
  gfx._GL_SAMPLES = gh_renderer.get_capability_4i("GL_SAMPLES")

  
  local winW, winH = gfx.window.getsize()  
  gfx._client_width = winW
  gfx._client_height = winH
  

  if (gh_utils.get_platform() == 1) then
    gfx._platform = "windows"
  elseif (gh_utils.get_platform() == 2) then
    gfx._platform = "osx"
  elseif (gh_utils.get_platform() == 3) then
    gfx._platform = "linux"
  elseif (gh_utils.get_platform() == 4) then
    gfx._platform = "rpi"
  end
  

   
  

  shaderlib.init()
  
  gfx._camera_ortho = gfx.camera.create_ortho(0, 0, winW, winH)
  
  gfx.mouse.init()
  

  
  gfx._info_quad = gh_mesh.create_quad(gfx._info_quad_size.w, gfx._info_quad_size.h)
  gh_mesh.set_vertex_color(gfx._info_quad, 0, 0.0, 0.1, 0.2, 0.4) -- bottom left
  gh_mesh.set_vertex_color(gfx._info_quad, 1, 0.0, 0.1, 0.2, 0.95) -- top left
  gh_mesh.set_vertex_color(gfx._info_quad, 2, 0.0, 0.1, 0.2, 0.95) -- top right
  gh_mesh.set_vertex_color(gfx._info_quad, 3, 0.0, 0.1, 0.2, 0.4) -- bottom right
  
  
  gfx._bkg_quad = gh_mesh.create_quad(winW, winH)
  gh_mesh.set_vertex_color(gfx._bkg_quad, 0, 0.2, 0.2, 0.3, 1.0) -- bottom left
  gh_mesh.set_vertex_color(gfx._bkg_quad, 1, 0.6, 0.6, 0.7, 1.0) -- top left
  gh_mesh.set_vertex_color(gfx._bkg_quad, 2, 0.6, 0.6, 0.7, 1.0) -- top right
  gh_mesh.set_vertex_color(gfx._bkg_quad, 3, 0.2, 0.2, 0.3, 1.0) -- bottom right
  
    
end

----------------------------------------------------------------------------------------
function gfx.terminate()
  ftgl_kill()
  gfx.mouse.terminate()
end

----------------------------------------------------------------------------------------
function gfx.get_shaderlib()
  return shaderlib
end  

----------------------------------------------------------------------------------------
function gfx.resize(w, h)
  ftgl_resize(w, h)
  gfx._client_width = w
  gfx._client_height = h
  
  gfx.camera.update_ortho(gfx._camera_ortho, 0, 0, w, h)
  
  gh_mesh.update_quad_size(gfx._bkg_quad, w, h)
end


----------------------------------------------------------------------------------------
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

  for k in pairs (gfx._user_texts_20) do
    gfx._user_texts_20[k] = nil
  end  
  gfx._user_texts_index_20 = 0

  for k in pairs (gfx._user_texts_30) do
    gfx._user_texts_30[k] = nil
  end  
  gfx._user_texts_index_30 = 0

  for k in pairs (gfx._user_texts_40) do
    gfx._user_texts_40[k] = nil
  end  
  gfx._user_texts_index_40 = 0
  
  
  --if (gfx._display_bkg_quad == 1) then
  --  gfx.draw_bkg_quad()
  --end
  
end

----------------------------------------------------------------------------------------
function gfx.end_frame(show_info)
  if (show_info == 1) then
    gfx.display_info(40)
  end

  if (gfx.mouse._show == 1)  then
    local winW, winH = gfx.window.getsize()  
    local screen_mx, screen_my = gfx.mouse.get_position()
    gfx.mouse.draw(ortho_cam, screen_mx - winW/2, winH/2 - screen_my)
  end
  
end

----------------------------------------------------------------------------------------
function gfx.get_time()
  return gfx._elapsed_time
end

----------------------------------------------------------------------------------------
function gfx.get_dt()
  return gfx._time_step
end

----------------------------------------------------------------------------------------
function gfx.get_fps()
  return gfx._fps
end


----------------------------------------------------------------------------------------
function gfx.display_common_info(state)
  gfx._display_common_info = state
end

----------------------------------------------------------------------------------------
function gfx.display_user_info(state)
  gfx._display_user_info = state
end

----------------------------------------------------------------------------------------
function gfx.display_info(y_offset)

  if (gfx._display_info_quad == 1) then
    gh_renderer.set_depth_test_state(0)
    
    gh_camera.bind(gfx._camera_ortho)
    
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
      
      --ftgl_print(f, 160, y_offset, 0.9, 0.9, 0.9, 1, string.format("(%s)", gfx._platform))
      
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

    if (gfx._font_default_user_20 > 0) then
      local f = gfx._font_default_user_20
      ftgl_begin(f)
      for i=1, gfx._user_texts_index_20 do
        local t = gfx._user_texts_20[i]
        ftgl_print(f, t._x, t._y, t._r, t._g, t._b, t._a, t._text)
      end
      ftgl_end(f)
    end

    if (gfx._font_default_user_30 > 0) then
      local f = gfx._font_default_user_30
      ftgl_begin(f)
      for i=1, gfx._user_texts_index_30 do
        local t = gfx._user_texts_30[i]
        ftgl_print(f, t._x, t._y, t._r, t._g, t._b, t._a, t._text)
      end
      ftgl_end(f)
    end

    if (gfx._font_default_user_40 > 0) then
      local f = gfx._font_default_user_40
      ftgl_begin(f)
      for i=1, gfx._user_texts_index_40 do
        local t = gfx._user_texts_40[i]
        ftgl_print(f, t._x, t._y, t._r, t._g, t._b, t._a, t._text)
      end
      ftgl_end(f)
    end
  end
  
end

----------------------------------------------------------------------------------------
function gfx.set_main_title(text)
  gfx._main_title = text
end  

function gfx.write_text(x, y, r, g, b, a, text)
  local t = {_x=x, _y=y, _r=r, _g=g, _b=b, _a=a, _text=text} 
  gfx._user_texts_index = gfx._user_texts_index + 1
  gfx._user_texts[gfx._user_texts_index] = t
end

function gfx.write_text_20(x, y, r, g, b, a, text)
  local t = {_x=x, _y=y, _r=r, _g=g, _b=b, _a=a, _text=text} 
  gfx._user_texts_index_20 = gfx._user_texts_index_20 + 1
  gfx._user_texts_20[gfx._user_texts_index_20] = t
end

function gfx.write_text_30(x, y, r, g, b, a, text)
  local t = {_x=x, _y=y, _r=r, _g=g, _b=b, _a=a, _text=text} 
  gfx._user_texts_index_30 = gfx._user_texts_index_30 + 1
  gfx._user_texts_30[gfx._user_texts_index_30] = t
end

function gfx.write_text_40(x, y, r, g, b, a, text)
  local t = {_x=x, _y=y, _r=r, _g=g, _b=b, _a=a, _text=text} 
  gfx._user_texts_index_40 = gfx._user_texts_index_40 + 1
  gfx._user_texts_40[gfx._user_texts_index_40] = t
end

----------------------------------------------------------------------------------------
function gfx.show_info_quad(state)
  gfx._display_info_quad = state
end

----------------------------------------------------------------------------------------
function gfx.update_info_quad_size(new_w, new_h)
  gfx._info_quad_size.w = new_w
  gfx._info_quad_size.h = new_h
  gh_mesh.update_quad_size(gfx._info_quad, gfx._info_quad_size.w, gfx._info_quad_size.h)
end

----------------------------------------------------------------------------------------
function gfx.show_bkg_quad(state)
  gfx._display_bkg_quad = state
end


----------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------
function gfx.rand_init(seed)
  if (seed == -1) then
    math.randomseed(os.time())
  else
    math.randomseed(seed)
  end
end

----------------------------------------------------------------------------------------
function gfx.rand(a, b)
	if (a > b) then
		local c = b
		b = a
		a = c
	end
	local delta = b-a
	return (a + math.random()*delta)
end

----------------------------------------------------------------------------------------
function gfx.trace(s)
  gh_utils.trace(s)
end

----------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------
function gfx.msaa(state)
  if (state == 1) then
    gh_renderer.enable_state("GL_MULTISAMPLE")
  else
    gh_renderer.disable_state("GL_MULTISAMPLE")
  end
end      

----------------------------------------------------------------------------------------
function gfx.vsync(state)
  gh_renderer.vsync(state)
end    

 
----------------------------------------------------------------------------------------
function gfx.draw_quad(x, y, width, height)
  if (gfx._quad == 0) then
    gfx._quad = gh_mesh.create_quad(width, height)
  end
  gh_mesh.update_quad_size(gfx._quad, width, height)
  gh_object.set_position(gfx._quad, x, y, 0)
  gh_object.render(gfx._quad)
end  
 
function gfx.get_quad()
  return gfx._quad
end  

----------------------------------------------------------------------------------------
function gfx.draw_bkg_quad()
  gh_renderer.set_depth_test_state(0)
  gh_camera.bind(gfx._camera_ortho)
  gh_renderer.clear_color_depth_buffers(0.0, 0.0, 0.0, 1.0, 1.0)
  gfx.gpu_program.bind_by_name("vertex_color")
  gh_object.render(gfx._bkg_quad)
end  

