

_ftgl_all_fonts = {}
_ftgl_num_fonts = 0

_ftgl_initialized = 0
_ftgl_camera_ortho = 0
_ftgl_font_program = 0


function ftgl_init_font_gpu_program()
  if (_ftgl_font_program > 0) then
    return
  end
  
  local ftgl_font_program_vs_gl3=" \
  #version 150 \
  in vec4 gxl3d_Position; \
  in vec4 gxl3d_TexCoord0; \
  in vec4 gxl3d_Color; \
  uniform mat4 gxl3d_ModelViewProjectionMatrix; \
  uniform vec4 gxl3d_Viewport; \
  out vec4 Vertex_UV; \
  out vec4 Vertex_Color; \
  void main() \
  { \
    vec4 V = vec4(gxl3d_Position.xyz, 1); \
    V.x = V.x - gxl3d_Viewport.z / 2.0; \
    V.y = V.y + gxl3d_Viewport.w / 2.0; \
    gl_Position = gxl3d_ModelViewProjectionMatrix * V; \
    Vertex_UV = gxl3d_TexCoord0; \
    Vertex_Color = gxl3d_Color; \
  }"
    
  local ftgl_font_program_ps_gl3=" \
  #version 150 \
  uniform sampler2D tex0; \
  in vec4 Vertex_UV; \
  in vec4 Vertex_Color; \
  out vec4 FragColor; \
  void main (void) \
  { \
    vec2 uv = Vertex_UV.xy; \
    vec3 t = texture(tex0,uv).rgb; \
    FragColor = vec4(t.r*Vertex_Color.rgb, Vertex_Color.a * t.r); \
  }"
    
  local ftgl_font_program_vs_gl2=" \
  #version 120 \
  attribute vec4 gxl3d_Position; \
  attribute vec4 gxl3d_TexCoord0; \
  attribute vec4 gxl3d_Color; \
  uniform mat4 gxl3d_ModelViewProjectionMatrix; \
  uniform vec4 gxl3d_Viewport; \
  varying vec4 Vertex_UV; \
  varying vec4 Vertex_Color; \
  void main() \
  { \
    vec4 V = vec4(gxl3d_Position.xyz, 1); \
    V.x = V.x - gxl3d_Viewport.z / 2.0; \
    V.y = V.y + gxl3d_Viewport.w / 2.0; \
    gl_Position = gl_ModelViewProjectionMatrix * V;		 \
    Vertex_UV = gxl3d_TexCoord0; \
    Vertex_Color = gxl3d_Color; \
  }"
    
  local ftgl_font_program_ps_gl2=" \
  #version 120 \
  uniform sampler2D tex0; \
  varying vec4 Vertex_UV; \
  varying vec4 Vertex_Color; \
  void main (void) \
  { \
    vec2 uv = Vertex_UV.xy; \
    vec3 t = texture2D(tex0,uv).rgb; \
    gl_FragColor = vec4(t.r*Vertex_Color.rgb, Vertex_Color.a * t.r); \
  }"
  
  
  
  local ftgl_font_program_vs_gles2=" \
  attribute vec4 gxl3d_Position; \
  attribute vec4 gxl3d_TexCoord0; \
  attribute vec4 gxl3d_Color; \
  uniform mat4 gxl3d_ModelViewProjectionMatrix; \
  uniform vec4 gxl3d_Viewport; \
  varying vec4 Vertex_UV; \
  varying vec4 Vertex_Color; \
  void main() \
  { \
    vec4 V = vec4(gxl3d_Position.xyz, 1.0); \
    V.x = V.x - gxl3d_Viewport.z / 2.0; \
    V.y = V.y + gxl3d_Viewport.w / 2.0; \
    gl_Position = gxl3d_ModelViewProjectionMatrix * V;		 \
    Vertex_UV = gxl3d_TexCoord0; \
    Vertex_Color = gxl3d_Color; \
  }"
    
  local ftgl_font_program_ps_gles2=" \
  uniform sampler2D tex0; \
  varying vec4 Vertex_UV; \
  varying vec4 Vertex_Color; \
  void main (void) \
  { \
    vec2 uv = Vertex_UV.xy; \
    vec3 t = texture2D(tex0,uv).rgb; \
    gl_FragColor = vec4(t.r*Vertex_Color.rgb, Vertex_Color.a * t.r); \
    //gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0); \
  }"
  
  if (gh_utils.get_platform() == 4) then
    -- Raspberry Pi
    _ftgl_font_program = gh_gpu_program.create_v2("ftgl_font_program", ftgl_font_program_vs_gles2, ftgl_font_program_ps_gles2)
  else
    if (gh_renderer.get_api_version_major() >= 3) then
      _ftgl_font_program = gh_gpu_program.create_v2("ftgl_font_program", ftgl_font_program_vs_gl3, ftgl_font_program_ps_gl3)
    else
      _ftgl_font_program = gh_gpu_program.create_v2("ftgl_font_program", ftgl_font_program_vs_gl2, ftgl_font_program_ps_gl2)
    end
  end
end  


function ftgl_init()
  if (_ftgl_initialized == 0) then
    ftgl_init_font_gpu_program()
    local winW, winH = gh_window.getsize(0)
    _ftgl_camera_ortho = gh_camera.create_ortho(-winW/2, winW/2, -winH/2, winH/2, 1.0, 10.0)
    gh_camera.set_viewport(_ftgl_camera_ortho, 0, 0, winW, winH)
    gh_camera.set_position(_ftgl_camera_ortho, 0, 0, 4)
    gh_camera.set_lookat(_ftgl_camera_ortho, 0, 0, 0, 1)
    _ftgl_initialized = 1
  end
end

function ftgl_kill()
  if (_ftgl_num_fonts > 0) then
    for i=1, _ftgl_num_fonts do
      local f = _ftgl_all_fonts[i]
      gh_utils.ftgl_font_kill(f.font)
    end
    gh_utils.ftgl_font_texture_killall()
  end
end


function ftgl_load_font(font_filename, font_size)
  return ftgl_load_font_v3(font_filename, font_size, 2048, 0, 0)
end

function ftgl_load_font_v2(font_filename, font_size, outline_type, outline_size)
  return ftgl_load_font_v3(font_filename, font_size, 2048, outline_type, outline_size)
end

function ftgl_load_font_v3(font_filename, font_size, font_texture_size, outline_type, outline_size)
  local ftglfont = { texture=0, font=0 }
  if (font_filename == "") then
    local app_dir = gh_utils.get_host_app_dir() 		
    ftglfont.texture = gh_utils.ftgl_font_texture_load(app_dir .. "fonts/impact.ttf", font_size, font_texture_size, font_texture_size, outline_type, outline_size)
  else
    ftglfont.texture = gh_utils.ftgl_font_texture_load(font_filename, font_size, font_texture_size, font_texture_size, outline_type, outline_size)
  end
  if (ftglfont.texture > 0) then
    ftglfont.font = gh_utils.ftgl_font_create(ftglfont.texture)
    _ftgl_num_fonts = _ftgl_num_fonts + 1
    _ftgl_all_fonts[_ftgl_num_fonts] = ftglfont
  end
  return ftglfont.font
end


function ftgl_resize(w, h)
  gh_camera.update_ortho(_ftgl_camera_ortho, -w/2, w/2, -h/2, h/2, 1.0, 10.0)
  gh_camera.set_viewport(_ftgl_camera_ortho, 0, 0, w, h)
end

function ftgl_begin(font)
  gh_utils.ftgl_font_clear(font)
end

function ftgl_begin_v2(font)
  gh_utils.ftgl_font_clear(font)
end

function ftgl_print(font, x, y, r, g, b, a, text)
  gh_utils.ftgl_font_add_text2d(font, x, y, r, g, b, a, text)
end  


function ftgl_end(font)
  ftgl_end_v2(font, 0)
end

function ftgl_end_v2(font, camera_ortho)
  ftgl_init()
  if (camera_ortho > 0) then
    gh_camera.bind(camera_ortho)
  else
    gh_camera.bind(_ftgl_camera_ortho)
  end
  gh_renderer.set_depth_test_state(0)
  gh_gpu_program.bind(_ftgl_font_program)
  gh_gpu_program.uniform1i(_ftgl_font_program, "tex0", 0)
  gh_utils.ftgl_font_render(font)
  gh_renderer.set_depth_test_state(1)
end

