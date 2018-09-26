
--local demo = {}
local demo = module("DemoLib", package.seeall)
-- package.preload["DemoLib"] = demo


package.loaded["mod_math"] = nil
demo.mod_math = require "mod_math"

package.loaded["mod_camera"] = nil
demo.mod_camera = require "mod_camera"

demo.is_opengl2 = 0
demo.winW = 0
demo.winH = 0
demo.old_camera_persp = 0
demo.camera_persp_fov = 60
demo.camera_ortho = 0
demo.old_camera_ortho = 0
demo.font = 0
demo.elapsed_time = 0
demo.last_time = 0
demo.time_step = 0
demo.bkg_img_gpu_program = 0
demo.uber_phong_texture_prog = 0
demo.bm_font_program = 0
demo.cam_lookat = mod_math.new_vec3()
demo.bkg_quad = 0


function demo.get_mod_math() return mod_math end
function demo.get_mod_camera() return mod_camera end


--[[
==============================================================================
Initialization functions
==============================================================================
--]]
function demo.init(is_gl2)

  is_opengl2 = is_gl2
  
  winW, winH = gh_window.getsize(0)
  
  init_camera_perspective() 
  init_camera_ortho() 
  
  init_font()
  init_bkg_quad()
  
  init_bm_font_program()
  init_uber_phong_texture_prog()
  
  gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
  
  gh_renderer.set_vsync(0)
  gh_renderer.set_scissor_state(0)
  gh_renderer.set_depth_test_state(1)
  
  --elapsed_time = gh_utils.get_elapsed_time()
  elapsed_time = gh_window.timer_get_seconds(0)
  last_time = elapsed_time
end

function demo.get_time()
  return elapsed_time
end  

function demo.get_time_step()
  return time_step
end  

function demo.get_window_size()
  return gh_window.getsize(0)
end  

function demo.resize()
  winW, winH = gh_window.getsize(0)

  local aspect = 1.333
  if (winH > 0) then
    aspect = winW / winH
  end  
  gh_camera.update_persp(camera_persp, camera_persp_fov, aspect, 0.1, 1000.0)
  gh_camera.set_viewport(camera_persp, 0, 0, winW, winH)
  
  gh_camera.update_ortho(camera_ortho, -winW/2, winW/2, -winH/2, winH/2, 1.0, -1.0)
  gh_camera.set_viewport(camera_ortho, 0, 0, winW, winH)
  
  gh_mesh.update_quad_size(bkg_quad, winW, winH)

  gh_utils.font_set_viewport_info(font, 0, 0, winW, winH)
end


function demo.init_bm_font_program()
  local bm_font_program_vs_gl3=" \
in vec4 gxl3d_Position; \
in vec4 gxl3d_TexCoord0; \
in vec4 gxl3d_Color; \
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
out vec4 Vertex_UV; \
out vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gxl3d_Position; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gxl3d_TexCoord0; \
  Vertex_Color = gxl3d_Color; \
}"

  local bm_font_program_ps_gl3=" \
uniform sampler2D tex0; \
in vec4 Vertex_UV; \
in vec4 Vertex_Color; \
out vec4 Out_Color; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  vec3 t = texture(tex0,uv).rgb; \
  Out_Color = vec4(t * Vertex_Color.rgb, 1.0);  \
}"

  local bm_font_program_vs_gl2=" \
#version 120 \
uniform mat4 gxl3d_ViewProjectionMatrix; \
uniform mat4 gxl3d_ModelMatrix; \
uniform vec4 gxl3d_Viewport; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  vec4 P = gl_Vertex; \
  vec4 Pw = gxl3d_ModelMatrix * P; \
  Pw.x = Pw.x - gxl3d_Viewport.z/2; \
  Pw.y = Pw.y + gxl3d_Viewport.w/2; \
  gl_Position = gxl3d_ViewProjectionMatrix * Pw; \
  Vertex_UV = gl_MultiTexCoord0; \
  Vertex_Color = gl_Color; \
}"

  local bm_font_program_ps_gl2=" \
#version 120 \
uniform sampler2D tex0; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main (void) \
{ \
  vec2 uv = Vertex_UV.xy; \
  uv.y *= -1.0; \
  vec3 t = texture2D(tex0,uv).rgb; \
  gl_FragColor = vec4(t * Vertex_Color.rgb, 1.0);  \
  //gl_FragColor = vec4(t, 1.0);  \
}"

  bm_font_program = 0
  if (is_opengl2 == 1) then
    bm_font_program = gh_gpu_program.create(bm_font_program_vs_gl2, bm_font_program_ps_gl2)
  else
    local vs = ""
    local ps = ""
    if (gh_renderer.get_api_version_major() >= 3) then
      if (gh_renderer.get_api_version_major() == 3) then
        if (gh_renderer.get_api_version_minor() >= 2) then
          vs = "#version 150\n" .. bm_font_program_vs_gl3
          ps = "#version 150\n" .. bm_font_program_ps_gl3
        else
          vs = "#version 130\n" .. bm_font_program_vs_gl3
          ps = "#version 130\n" .. bm_font_program_ps_gl3
        end
      else
        vs = "#version 150\n" .. bm_font_program_vs_gl3
        ps = "#version 150\n" .. bm_font_program_ps_gl3
      end
    end
    bm_font_program = gh_gpu_program.create(vs, ps)
  end
  gh_node.set_name(bm_font_program, "demolib_bm_font_prog")
 
  -- Workaround for Intel GPUs - START
  gh_gpu_program.bind(bm_font_program)
  gh_gpu_program.bind(0)
  -- Workaround for Intel GPUs - END
end

function demo.bm_font_get_gpu_program()
  return bm_font_program
end



function demo.init_uber_phong_texture_prog()
  local phong_texture_prog_vs_gl3=" \
in vec4 gxl3d_Position; \
in vec4 gxl3d_Normal; \
in vec4 gxl3d_TexCoord0; \
in vec4 gxl3d_Color; \
out vec4 Vertex_UV; \
out vec4 Vertex_C; \
out vec4 Vertex_Normal; \
out vec4 Vertex_LightDir; \
out vec4 Vertex_EyeVec; \
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GLSL Hacker \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GLSL Hacker \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GLSL Hacker \
uniform vec4 light_position; \
uniform vec4 uv_tiling; \
// render_params: <do_texturing, do_lighting, 0, 0> \
uniform ivec4 render_params; \
void main() \
{ \
  vec4 P = gxl3d_Position; \
  P.w = 1.0; \
  gl_Position = gxl3d_ModelViewProjectionMatrix * P; \
  Vertex_C = gxl3d_Color; \
  Vertex_UV = gxl3d_TexCoord0 * uv_tiling; \
  if (render_params.y == 1)\
  {\
    Vertex_Normal = gxl3d_ModelViewMatrix  * gxl3d_Normal; \
    vec4 view_vertex = gxl3d_ModelViewMatrix * P; \
    vec4 lp = gxl3d_ViewMatrix * light_position; \
    Vertex_LightDir = lp - view_vertex; \
    Vertex_EyeVec = -view_vertex; \
  }\
}"
  local phong_texture_prog_ps_gl3=" \
uniform vec4 color; \
uniform sampler2D tex0; \
uniform vec4 light_ambient; \
uniform vec4 light_diffuse; \
uniform vec4 light_specular; \
uniform vec4 material_ambient; \
uniform vec4 material_diffuse; \
uniform vec4 material_specular; \
uniform float material_shininess; \
// render_params: <do_texturing, do_lighting, 0, 0> \
uniform ivec4 render_params; \
in vec4 Vertex_UV; \
in vec4 Vertex_C; \
in vec4 Vertex_Normal; \
in vec4 Vertex_LightDir; \
in vec4 Vertex_EyeVec; \
out vec4 Out_Color; \
void main() \
{ \
  vec4 tex01_color = vec4(1,1,1,1); \
  if (render_params.x == 1) \
  { \
    vec2 uv = Vertex_UV.xy; \
    uv.y *= -1.0; \
    tex01_color = texture(tex0, uv).rgba; \
  } \
  vec4 final_color = tex01_color;  \
  if (render_params.y == 1) \
  { \
    final_color *= light_ambient * material_ambient;  \
    vec4 N = normalize(Vertex_Normal); \
    vec4 L = normalize(Vertex_LightDir); \
    float lambertTerm = dot(N,L); \
    if (lambertTerm > 0.0) \
    { \
      final_color += light_diffuse * material_diffuse * lambertTerm * tex01_color;	 \
      vec4 E = normalize(Vertex_EyeVec); \
      vec4 R = reflect(-L, N); \
      float specular = pow( max(dot(R, E), 0.0), material_shininess); \
      final_color += light_specular * material_specular * specular;	 \
    } \
  } \
  Out_Color.rgb = final_color.rgb * Vertex_C.rgb * color.rgb; \
  Out_Color.a = Vertex_C.a * color.a; \
}"

  local phong_texture_prog_vs_gl2=" \
#version 120 \
varying vec4 Vertex_UV; \
varying vec4 Vertex_C; \
varying vec4 Vertex_Normal; \
varying vec4 Vertex_LightDir; \
varying vec4 Vertex_EyeVec; \
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GLSL Hacker \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GLSL Hacker \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GLSL Hacker \
uniform vec4 light_position; \
uniform vec4 uv_tiling; \
// render_params: <do_texturing, do_lighting, 0, 0> \
uniform ivec4 render_params; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex; \
  Vertex_C = gl_Color; \
  Vertex_UV = gl_MultiTexCoord0 * uv_tiling; \
  if (render_params.y == 1)\
  {\
    Vertex_Normal = gxl3d_ModelViewMatrix  * vec4(gl_Normal, 0.0); \
    vec4 view_vertex = gxl3d_ModelViewMatrix * gl_Vertex; \
    vec4 lp = gxl3d_ViewMatrix * light_position; \
    Vertex_LightDir = lp - view_vertex; \
    Vertex_EyeVec = -view_vertex; \
  }\
}"
  local phong_texture_prog_ps_gl2=" \
#version 120 \
uniform vec4 color; \
uniform sampler2D tex0; \
uniform vec4 light_ambient; \
uniform vec4 light_diffuse; \
uniform vec4 light_specular; \
uniform vec4 material_ambient; \
uniform vec4 material_diffuse; \
uniform vec4 material_specular; \
uniform float material_shininess; \
// render_params: <do_texturing, do_lighting, 0, 0> \
uniform ivec4 render_params; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_C; \
varying vec4 Vertex_Normal; \
varying vec4 Vertex_LightDir; \
varying vec4 Vertex_EyeVec; \
void main() \
{ \
  vec4 tex01_color = vec4(1,1,1,1); \
  if (render_params.x == 1) \
  { \
    vec2 uv = Vertex_UV.xy; \
    uv.y *= -1.0; \
    tex01_color = texture2D(tex0, uv).rgba; \
  } \
  vec4 final_color = tex01_color;  \
  if (render_params.y == 1) \
  { \
    final_color *= light_ambient * material_ambient;  \
    vec4 N = normalize(Vertex_Normal); \
    vec4 L = normalize(Vertex_LightDir); \
    float lambertTerm = dot(N,L); \
    if (lambertTerm > 0.0) \
    { \
      final_color += light_diffuse * material_diffuse * lambertTerm * tex01_color;	 \
      vec4 E = normalize(Vertex_EyeVec); \
      vec4 R = reflect(-L, N); \
      float specular = pow( max(dot(R, E), 0.0), material_shininess); \
      final_color += light_specular * material_specular * specular;	 \
    } \
  } \
  gl_FragColor.rgb = final_color.rgb * Vertex_C.rgb * color.rgb; \
  gl_FragColor.a = Vertex_C.a * color.a; \
}"

  uber_phong_texture_prog = 0
  if (is_opengl2 == 1) then
    uber_phong_texture_prog = gh_gpu_program.create(phong_texture_prog_vs_gl2, phong_texture_prog_ps_gl2)
  else
    local vs = ""
    local ps = ""
    if (gh_renderer.get_api_version_major() >= 3) then
      if (gh_renderer.get_api_version_major() == 3) then
        if (gh_renderer.get_api_version_minor() >= 2) then
          vs = "#version 150\n" .. phong_texture_prog_vs_gl3
          ps = "#version 150\n" .. phong_texture_prog_ps_gl3
        else
          vs = "#version 130\n" .. phong_texture_prog_vs_gl3
          ps = "#version 130\n" .. phong_texture_prog_ps_gl3
        end
      else
        vs = "#version 150\n" .. phong_texture_prog_vs_gl3
        ps = "#version 150\n" .. phong_texture_prog_ps_gl3
      end
    end
    uber_phong_texture_prog = gh_gpu_program.create(vs, ps)
  end
  
  gh_node.set_name(uber_phong_texture_prog, "demolib_uber_phong_texture_prog")
 
  -- Workaround for Intel GPUs - START
  gh_gpu_program.bind(uber_phong_texture_prog)
  gh_gpu_program.bind(0)
  -- Workaround for Intel GPUs - END
  
  gh_gpu_program.bind(uber_phong_texture_prog)
  gh_gpu_program.uniform4i(uber_phong_texture_prog, "render_params", 0, 0, 0, 0)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "color", 1, 1, 1, 1)
  gh_gpu_program.uniform1i(uber_phong_texture_prog, "tex0", 0)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "uv_tiling", 1.0, 1.0, 0, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "light_position", 0, 100, 50, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "light_ambient", 0.2, 0.2, 0.2, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "light_diffuse", 1.0, 1.0, 0.9, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "light_specular", 0.8, 0.8, 0.9, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "material_ambient", 0.7, 0.7, 0.7, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "material_diffuse", 0.7, 0.7, 0.7, 1)
  gh_gpu_program.uniform4f(uber_phong_texture_prog, "material_specular", 0.7, 0.7, 0.7, 1)
  gh_gpu_program.uniform1f(uber_phong_texture_prog, "material_shininess", 60.0)
  gh_gpu_program.bind(0)
  
end

function demo.get_uber_phong_texture_prog()
  return uber_phong_texture_prog
end

function demo.init_camera_perspective() 
  cam_lookat:set(0, 0, 0)
  local aspect = winW/winH
  camera_persp = gh_camera.create_persp(camera_persp_fov, aspect, 0.1, 1000.0)
  gh_camera.set_viewport(camera_persp, 0, 0, winW, winH)
  gh_camera.set_position(camera_persp, 0, 10, 50)
  gh_camera.set_lookat(camera_persp, cam_lookat.x, cam_lookat.y, cam_lookat.z, 1)
  gh_camera.setupvec(camera_persp, 0, 1, 0, 0)
  mod_camera.InitCameraRotation(camera_persp, cam_lookat, 20, 90)
  old_camera_persp = camera_persp
end   

function demo.update_camera_perspective(fov, x, y, z, lookat_x, lookat_y, lookat_z, pitch, yaw, strafe) 
  cam_lookat:set(lookat_x, lookat_y, lookat_z)
  local aspect = winW/winH
  camera_persp_fov = fov
  gh_camera.update_persp(camera_persp, fov, aspect, 0.1, 1000.0)
  gh_camera.set_viewport(camera_persp, 0, 0, winW, winH)
  gh_camera.set_position(camera_persp, x, y, z)
  gh_camera.set_lookat(camera_persp, cam_lookat.x, cam_lookat.y, cam_lookat.z, 1)
  gh_camera.setupvec(camera_persp, 0, 1, 0, 0)
  mod_camera.InitCameraRotation(camera_persp, cam_lookat, pitch, yaw)
  mod_camera.CameraStrafe(camera_persp, strafe)
end   

  
function demo.get_camera_persp()
  return camera_persp
end

function demo.set_camera_persp(cam)
  if (cam == 0) then
    camera_persp = old_camera_persp
  else
    old_camera_persp = camera_persp
    camera_persp = cam
  end
end

function demo.init_camera_persp_position_orientation(pos_x, pos_y, pos_z, lookat_x, lookat_y, lookat_z, pitch, yaw, strafe)
  gh_camera.set_position(camera_persp, pos_x, pos_y, pos_z)
  gh_camera.set_lookat(camera_persp, lookat_x, lookat_y, lookat_z, 1)
  mod_camera.CameraStrafe(camera_persp, strafe)
end

  
function demo.init_camera_ortho()  
  camera_ortho = gh_camera.create_ortho(-winW/2, winW/2, -winH/2, winH/2, 1.0, -1.0)
  gh_camera.set_viewport(camera_ortho, 0, 0, winW, winH)
  gh_camera.set_position(camera_ortho, 0, 0, 1)
  gh_camera.set_lookat(camera_ortho, 0, 0, 0, 1)
  old_camera_ortho = camera_ortho
end
  
function demo.get_camera_ortho()
  return camera_ortho
end

function demo.set_camera_persp(cam)
  if (cam == 0) then
    camera_ortho = old_camera_ortho
  else
    old_camera_ortho = camera_ortho
    camera_ortho = cam
  end
end


function demo.init_font()
  font = gh_utils.font_create("Tahoma", 14)
  gh_utils.font_set_viewport_info(font, 0, 0, winW, winH)
end

function demo.get_font()
  return font
end

function demo.init_bkg_quad()
  bkg_quad = gh_mesh.create_quad(winW, winH)
  if (is_opengl2 == 1) then
    gh_object.use_opengl21(bkg_quad, 1)
  end
end

function demo.get_bkg_quad()
  return bkg_quad
end

function demo.get_gpu_program(name)
  local gpu_prog = gh_node.getid(name)
  if (gpu_prog > 0) then
    -- Workaround for Intel GPUs - START
    gh_gpu_program.bind(gpu_prog)
    gh_gpu_program.bind(0)
    -- Workaround for Intel GPUs - END
  end
  return gpu_prog
end


--[[
==============================================================================
Object creation
==============================================================================
--]]
  

function demo.camera_ortho_create(width, height)
  local c = gh_camera.create_ortho(-width/2, width/2, -height/2, height/2, 1.0, -1.0)
  gh_camera.set_viewport(c, 0, 0, width, height)
  gh_camera.set_position(c, 0, 0, 1)
  return c
end  

function demo.camera_ortho_update(camera, width, height)
  local c = camera_ortho
  if (camera > 0) then
    c = camera
  end
  gh_camera.update_ortho(c, -width/2, width/2, -height/2, height/2, 1.0, -1.0)
  gh_camera.set_viewport(c, 0, 0, width, height)
  gh_camera.set_position(c, 0, 0, 1)
end  

function demo.camera_persp_create(fov, aspect, znear, zfar, viewport_x, viewport_y, viewport_width, viewport_height)
  local c = gh_camera.create_persp(fov, aspect,  znear, zfar)
  gh_camera.set_viewport(c, viewport_x, viewport_y, viewport_width, viewport_height)
  return c
end

--[[
function demo.camera_persp_update_proj(camera, fov, aspect, znear, zfar, viewport_x, viewport_y, viewport_width, viewport_height)
  local c = camera_persp
  if (camera > 0) then
    c = camera
  end
  gh_camera.update_persp(c, fov, aspect,  znear, zfar)
  gh_camera.set_viewport(c, viewport_x, viewport_y, viewport_width, viewport_height)
end
--]]
function demo.camera_persp_update_proj(camera, fov, aspect, znear, zfar)
  local c = camera_persp
  if (camera > 0) then
    c = camera
  end
  gh_camera.update_persp(c, fov, aspect, znear, zfar)
end

function demo.camera_update_viewport(camera, x, y, width, height) 
  local c = camera_persp
  if (camera > 0) then
    c = camera
  end
  gh_camera.set_viewport(c, x, y, width, height)
end   


--[[
function demo.create_ground_plane(w, h)
  ground_plane = gh_mesh.create_plane(w, h, 10, 10)
  gh_object.use_opengl21(ground_plane, is_opengl2)
  gh_object.set_position(ground_plane, 0, 0, 0)
  return ground_plane
end
--]]

function demo.bm_font_create(bm_font_filename, bm_font_folder, is_absolute_path, use_opengl2)
  local font = gh_utils.font_bm_create(bm_font_filename, bm_font_folder, is_absolute_path)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(font, 1)
  end
  gh_object.set_scale(font, 1.0, 1.0, 1.0)
  return font
end  

function demo.bm_font_get_texture(bm_font)
  local font_texture = gh_utils.font_bm_get_charset_texture(bm_font)
  return font_texture
end

function demo.create_quad(width, height, use_opengl2)
  local quad = gh_mesh.create_quad(width, height)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(quad, 1)
  end
  return quad
end

function demo.resize_quad(quad, width, height)
  gh_mesh.update_quad_size(quad, width, height)
end

function demo.quad_set_vertex_color(quad, vertex_index, r, g, b, a)
  gh_mesh.set_vertex_color(quad, vertex_index, r, g, b, a)
end

function demo.create_torus(major_radius, minor_radius, slices, use_opengl2)
  local mesh = gh_mesh.create_torus(major_radius, minor_radius, slices)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(mesh, 1)
  end
  return mesh
end

function demo.create_sphere(radius, stacks, slices, use_opengl2)
  local mesh = gh_mesh.create_sphere(radius, stacks, slices)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(mesh, 1)
  end
  return mesh
end


function demo.create_cylinder(radius, height, stacks, slices, use_opengl2)
  local mesh = gh_mesh.create_cylinder(radius, height, stacks, slices)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(mesh, 1)
  end
  return mesh
end

function demo.create_ellipse(major_radius, minor_radius, slices, radius_segments, opening_angle, use_opengl2)
  local mesh = gh_mesh.create_ellipse(major_radius, minor_radius, slices, radius_segments, opening_angle)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(mesh, 1)
  end
  return mesh
end

function demo.create_plane(width, height, num_div_x, num_div_z, use_opengl2)
  local mesh = gh_mesh.create_plane(width, height, num_div_x, num_div_z)
  --[[
  local separate_vertex_arrays = 0
  local vertex_alignment = 0
  local vertex_format = 0
  local mesh = gh_mesh.create_plane_v2(width, height, num_div_x, num_div_z, separate_vertex_arrays, vertex_alignment, vertex_format)
  --]]
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(mesh, 1)
  end
  return mesh
end

function demo.create_box(width, height, depth, num_div_x, num_div_y, num_div_z, use_opengl2)
  local mesh = gh_mesh.create_box(width, height, depth, num_div_x, num_div_y, num_div_z)
  if (use_opengl2 == 1) then
    gh_object.use_opengl21(mesh, 1)
  end
  return mesh
end



function demo.load_texture(filename, abs_path)
  local texture = gh_texture.create_from_file(filename, 0, abs_path)
  return texture
end

function demo.load_texture_rgba_f32_mipmaps(filename, abs_path, gen_mipmaps)
  local PF_F32_RGBA = 6
  local texture = gh_texture.create_from_file_v2(filename, PF_F32_RGBA, abs_path, gen_mipmaps)
  return texture
end


--[[
==============================================================================
Object manipulation
==============================================================================
--]]

function demo.object_get_num_vertices(object)
  return gh_object.get_num_vertices(object)
end

function demo.set_object_position(object, x, y, z)
  gh_object.set_position(object, x, y, z)
end

function demo.set_object_euler_angles(object, pitch, yaw, roll)
  gh_object.set_euler_angles(object, pitch, yaw, roll)
end



--[[
==============================================================================
Drawing / rendering
==============================================================================
--]]

function demo.frame_begin(r, g, b, a)

  demo.frame_begin_v3()
  
  gh_renderer.clear_color_depth_buffers(r, g, b, a, 1.0)
  --gh_renderer.clear_depth_buffer(1.0)
  gh_renderer.set_depth_test_state(1)
end

function demo.frame_begin_v2()
  elapsed_time = gh_window.timer_get_seconds(0)
  time_step = elapsed_time - last_time
  last_time = elapsed_time
end

function demo.frame_begin_v3()
  demo.frame_begin_v2()

  -- Windows platform.
  if (gh_utils.get_platform() == 1) then
    gh_window.keyboard_update_buffer(0)
  end
end


function demo.frame_end()

  -- Rendering of the camera tripod (on the bottom-right of the screen)
  gh_utils.tripod_visualizer_camera_render(camera_persp, winW-100, -10, 100, 100)

  --gh_utils.font_render(font, 10, 20, 0.2, 1.0, 0.0, 1.0, "GLSL Hacker - DemoLib code sample")
end

function demo.bind_camera_persp()
  gh_camera.bind(camera_persp)
end

function demo.bind_camera_persp_with_settings(fov, x, y, z, lookat_x, lookat_y, lookat_z)
  gh_camera.set_position(camera_persp, x, y, z)
  gh_camera.set_lookat(camera, lookat_x, lookat_y, lookat_z, 1)
  gh_camera.bind(camera)
end

function demo.bind_camera_ortho()
  gh_camera.bind(camera_ortho)
end


function demo.process_camera_persp(dt)
  mod_camera.ProcessCamera(camera_persp, dt)
  --gh_camera.bind(camera_persp)
end  

function demo.process_camera_v2(dt, keyboard_speed)
  mod_camera.SetCameraKeyboardSpeed(keyboard_speed)
  mod_camera.ProcessCamera(camera_persp, dt)
  --gh_camera.bind(camera_persp)
end  

function demo.process_camera_fly_v2(dt, keyboard_speed)
  mod_camera.SetCameraKeyboardSpeed(keyboard_speed)
  mod_camera.ProcessCameraFly_v2(camera_persp, dt)
  --gh_camera.bind(camera_persp)
end  

function demo.process_camera_orbit(dt, keyboard_speed, lookat_x, lookat_y, lookat_z)
  mod_camera.SetCameraKeyboardSpeed(keyboard_speed)
  mod_camera.ProcessCameraOrbit(camera_persp, dt, lookat_x, lookat_y, lookat_z)
  --gh_camera.bind(camera_persp)
end  

function demo.print(x, y, text)
  gh_utils.font_render(font, x, y, 0.2, 1.0, 0.0, 1.0, text)
end

function demo.print_rgba(x, y, r, g, b, a, text)
  gh_utils.font_render(font, x, y, r, g, b, a, text)
end



function demo.bm_font_write_reset(bm_font)
  gh_utils.font_bm_draw_reset(bm_font)
end

function demo.bm_font_write2d(bm_font, x, y, r, g, b, a, text)
  gh_utils.font_bm_draw_text_2d(bm_font, x, y, r, g, b, a, text)
end

function demo.bm_font_write3d(bm_font, x, y, z, r, g, b, a, text)
  gh_utils.font_bm_draw_text_3d(bm_font, x, y, z, r, g, b, a, text)
end

function demo.bm_font_update(bm_font, font_scale)
  gh_utils.font_bm_set_scale(bm_font, font_scale)
  -- mapped_gpu_mem allows to specify if GLSL Hacker updates directly the GPU memory or updates
  -- CPU memory and then copies it to the GPU memory. Updating directly the GPU memory is faster
  -- but has some synchronization issues with multi-GPU systems (SLI).
  local mapped_gpu_mem = 1
  gh_utils.font_bm_update(bm_font, mapped_gpu_mem)
end

function demo.bm_font_draw_prepare(blending_src_factor, blending_dst_factor)
  gh_renderer.rasterizer_set_cull_state(0)
  gh_renderer.rasterizer_apply_states()
  gh_renderer.set_depth_test_state(0)

  gh_renderer.set_blending_state(1)
  gh_renderer.set_blending_factors(blending_src_factor, blending_dst_factor) -- default: (1, 2)
 end  

function demo.bm_font_draw2d(bm_font, bm_font_texture, gpu_prog, camera)
  if ((bm_font > 0) and (bm_font_texture > 0)) then
    
--[[
    if (camera > 0) then
      gh_camera.bind(camera)
    else
      gh_camera.bind(camera_ortho)
    end
    --]]

    gh_camera.bind_v2(camera_ortho, 1, 0, 1, 1, 1)


    if (gpu_prog > 0) then
      gh_gpu_program.bind(gpu_prog)
    else
      gh_gpu_program.bind(bm_font_program)
    end
    gh_texture.bind(bm_font_texture, 0)
    gh_utils.font_bm_render(bm_font)
  end
end
  
function demo.bm_font_draw3d(bm_font, bm_font_texture, gpu_prog, camera)
  if ((bm_font > 0) and (bm_font_texture > 0)) then
    if (camera > 0) then
      gh_camera.bind(camera)
    else
      gh_camera.bind(camera_persp)
    end
    if (gpu_prog > 0) then
      gh_gpu_program.bind(gpu_prog)
    else
      gh_gpu_program.bind(bm_font_program)
    end
    gh_texture.bind(bm_font_texture, 0)
    gh_utils.font_bm_render(bm_font)
  end
end

function demo.bm_font_draw_finish()
  gh_renderer.set_blending_state(0)
  gh_renderer.set_depth_test_state(1)
  gh_renderer.rasterizer_set_cull_state(0)
  gh_renderer.rasterizer_apply_states()
end


function demo.render_bkg_image(texture)
  if ((texture > 0) and (bkg_quad > 0) and (uber_phong_texture_prog > 0)) then
    gh_renderer.set_depth_test_state(0)
    gh_camera.bind(camera_ortho)
    local p = uber_phong_texture_prog 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", 1, 1, 1, 1)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", 1.0, 1.0, 0, 1)
    gh_texture.bind(texture, 0)
    gh_object.render(bkg_quad)
    gh_renderer.set_depth_test_state(1)
  end
end

function demo.render_bkg_image_v2(texture, u_tile, v_tile, r, g, b, a)
  if ((texture > 0) and (bkg_quad > 0) and (uber_phong_texture_prog > 0)) then
    gh_renderer.set_depth_test_state(0)
    gh_camera.bind(camera_ortho)
    local p = uber_phong_texture_prog 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", u_tile, v_tile, 0, 1)
    gh_texture.bind(texture, 0)
    gh_object.render(bkg_quad)
    gh_renderer.set_depth_test_state(1)
  end
end


function demo.render_quad(quad, texture, glsl_program)
  if ((texture > 0) and (quad > 0) and (glsl_program > 0)) then
    gh_gpu_program.bind(glsl_program)
    gh_texture.bind(texture, 0)
    gh_object.render(quad)
  end
end

function demo.render_quad_camera_ortho(quad, texture, glsl_program)
  if ((texture > 0) and (quad > 0) and (glsl_program > 0)) then
    gh_renderer.set_depth_test_state(0)
    gh_camera.bind(camera_ortho)
    gh_gpu_program.bind(glsl_program)
    gh_texture.bind(texture, 0)
    gh_object.render(quad)
    gh_renderer.set_depth_test_state(1)
  end
end

function demo.render_object(object, glsl_program)
  if (glsl_program > 0) then
    gh_gpu_program.bind(glsl_program)
  end
  if (object > 0)then
    gh_object.render(object)
  end
end

function demo.render_textured_object(object, texture, glsl_program)
  if (glsl_program > 0) then
    gh_gpu_program.bind(glsl_program)
  end
  if (texture > 0) then
    gh_texture.bind(texture, 0)
  end
  if (object > 0) then
    gh_object.render(object)
  end
end

function demo.render_object_persp_cam(object, glsl_program)
  if ((object > 0) and (glsl_program > 0)) then
    gh_renderer.set_depth_test_state(1)
    gh_camera.bind(camera_persp)
    gh_gpu_program.bind(glsl_program)
    gh_object.render(object)
  end
end

function demo.render_textured_object_persp_cam(object, texture, glsl_program)
  if ((texture > 0) and (object > 0) and (glsl_program > 0)) then
    gh_renderer.set_depth_test_state(1)
    gh_camera.bind(camera_persp)
    gh_gpu_program.bind(glsl_program)
    gh_texture.bind(texture, 0)
    gh_object.render(object)
  end
end


--[[
==============================================================================
Graphics state
==============================================================================
--]]

function demo.wireframe(state)
  local RENDERER_POLYGON_FACE_BACK = 0
  local RENDERER_POLYGON_FACE_FRONT = 1
  local RENDERER_POLYGON_FACE_BACK_FRONT = 2

  local RENDERER_POLYGON_MODE_POINT = 0
  local RENDERER_POLYGON_MODE_LINE = 1
  local RENDERER_POLYGON_MODE_SOLID = 2

  if (state == 1) then
    gh_renderer.rasterizer_set_polygon_mode(RENDERER_POLYGON_FACE_BACK_FRONT, RENDERER_POLYGON_MODE_LINE)
  else
    gh_renderer.rasterizer_set_polygon_mode(RENDERER_POLYGON_FACE_BACK_FRONT, RENDERER_POLYGON_MODE_SOLID)
  end
  gh_renderer.rasterizer_apply_states()
end

function demo.vsync(state)
  if (state == 1) then
    gh_renderer.set_vsync(1)
  else
    gh_renderer.set_vsync(0)
  end
end


--[[
==============================================================================
Atomic counters
==============================================================================
--]]

--[[
function demo.atomic_counter_create_buffer(num_elements, binding_point_index)
  local BUFFER_OBJECT_USAGE_STATIC_WRITE = 1
  local BUFFER_OBJECT_USAGE_STATIC_READ = 2
  local BUFFER_OBJECT_USAGE_DYNAMIC_WRITE = 3
  local BUFFER_OBJECT_USAGE_DYNAMIC_READ = 4
  local BUFFER_OBJECT_USAGE_STREAM_WRITE = 5
  local BUFFER_OBJECT_USAGE_STREAM_READ = 6
  local ac_buffer_usage = BUFFER_OBJECT_USAGE_DYNAMIC_WRITE
  local ac_buffer = gh_renderer.atomic_counter_create_buffer(num_elements, ac_buffer_usage, binding_point_index)
  return ac_buffer
end
  
function demo.atomic_counter_kill_buffer(ac_buffer)
  if (ac_buffer > 0) then
    gh_renderer.atomic_counter_kill_buffer(ac_buffer)
    ac_buffer = 0
  end
end

function demo.atomic_counter_bind(ac_buffer, binding_point_index)
  gh_renderer.atomic_counter_buffer_bind(ac_buffer)
  gh_renderer.atomic_counter_buffer_bind_base(ac_buffer, binding_point_index)
end

function demo.atomic_counter_set_value(ac_buffer, index, value)
  gh_renderer.atomic_counter_set_value(ac_buffer, index, value)
end

function demo.atomic_counter_get_value(ac_buffer, index)
  local value = gh_renderer.atomic_counter_get_value(ac_buffer, index)
  return value
end
--]]


--[[
==============================================================================
Render targets
==============================================================================
--]]

function demo.render_target_create_depth(width, height)
  local depth_rt = gh_render_target.create_depth(width, height, 0)
  return depth_rt
end

function demo.render_target_create_rgba_u8(width, height)
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
  local linear_filtering = 1
  local samples = 0
  local rt = gh_render_target.create_ex(width, height, PF_U8_RGBA, linear_filtering, samples)
  return rt
end

function demo.render_target_create_rgba_f32(width, height)
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
  local linear_filtering = 1
  local samples = 0
  local rt = gh_render_target.create_ex(width, height, PF_F32_RGBA, linear_filtering, samples)
  return rt
end

function demo.render_target_create_rb_rgba_u8_ms(width, height, samples)
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
  local rt_ms = gh_render_target.create_rb(width, height, PF_U8_RGBA, samples)
  return rt_ms
end

function demo.render_target_create_rb_rgba_f32_ms(width, height, samples)
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
  local rt_ms = gh_render_target.create_rb(width, height, PF_F32_RGBA, samples)
  return rt_ms
end

--[[
==============================================================================
DemoLib END
==============================================================================
--]]

return demo
