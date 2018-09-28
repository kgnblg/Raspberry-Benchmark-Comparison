
--[[
-----------------------------------------------------------------------
Available GPU programs:

"color"
"vertex_color"
"texture"
"phong"
"phong_texture"

--]]

shaderlib = {
  _gpu_programs_list = {},
}


--------------------------------------------------------
function shaderlib.add(gpu_prog_name, p)
  shaderlib._gpu_programs_list[gpu_prog_name] = p
end

function shaderlib.bind_by_name(gpu_prog_name)
  local p = shaderlib._gpu_programs_list[gpu_prog_name]
  gh_gpu_program.bind(p)
  --gh_gpu_program.uniform4f(gfx._color_program, "color", r, g, b, a)
end

function shaderlib.bind(p)
  gh_gpu_program.bind(p)
end

function shaderlib.getid(gpu_prog_name)
  local p = shaderlib._gpu_programs_list[gpu_prog_name]
  return p
end


--------------------------------------------------------
function shaderlib.create_gpu_program(gpu_prog_name, vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
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

--------------------------------------------------------
function shaderlib.init_gpu_program_color()

  local vs_gl3=" \
in vec4 gxl3d_Position;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
}"

  local ps_gl3=" \
uniform vec4 color;\
out vec4 FragColor;\
void main() \
{ \
  FragColor = color;  \
}"
  
  local vs_gl2=" \
void main() \
{ \
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;\
}"

  local ps_gl2=" \
uniform vec4 color;\
void main() \
{ \
  gl_FragColor = color;  \
}"

  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
}"

  local ps_gles2=" \
uniform vec4 color;\
void main() \
{ \
  gl_FragColor = color;  \
}"

  local p = shaderlib.create_gpu_program("gfx_color_program", vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  --shaderlib._color_program = p
  shaderlib.add("color", p)
end  

--------------------------------------------------------------------
function shaderlib.init_gpu_program_vertex_color()

  local vs_gl3=" \
in vec4 gxl3d_Position;\
in vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
out vec4 v_color;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_color = gxl3d_Color;\
}"

  local ps_gl3=" \
in vec4 v_color;\
out vec4 FragColor;\
void main() \
{ \
  FragColor = v_color;  \
}"
  
  local vs_gl2=" \
varying vec4 v_color;\
void main() \
{ \
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;\
  v_color = gl_Color;\
}"

  local ps_gl2=" \
varying vec4 v_color;\
void main() \
{ \
  gl_FragColor = v_color;  \
}"

  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_Color;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
varying vec4 v_color;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_color = gxl3d_Color;\
}"

  local ps_gles2=" \
varying vec4 v_color;\
void main() \
{ \
  gl_FragColor = v_color;  \
}"

  local p = shaderlib.create_gpu_program("gfx_vertex_color_program", vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  --shaderlib._vertex_color_program = p
  shaderlib.add("vertex_color", p)
end  


--------------------------------------------------------
function shaderlib.init_gpu_program_texture()

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
uniform vec2 uv_tiling;\
in vec4 Vertex_UV;\
out vec4 FragColor;\
void main() \
{ \
  vec2 uv = Vertex_UV.xy * uv_tiling;\
  uv.y *= -1.0;\
  vec4 t = texture(tex0,uv);\
  FragColor = t;  \
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
uniform vec2 uv_tiling;\
varying vec4 Vertex_UV;\
void main() \
{ \
  vec2 uv = Vertex_UV.xy * uv_tiling;\
  uv.y *= -1.0;\
  vec4 t = texture2D(tex0,uv);\
  gl_FragColor = t;  \
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
uniform vec2 uv_tiling;\
uniform vec4 color;\
varying vec4 Vertex_UV;\
void main() \
{ \
  vec2 uv = Vertex_UV.xy * uv_tiling;\
  uv.y *= -1.0;\
  vec4 t = texture2D(tex0,uv);\
  gl_FragColor = t;  \
}"

  local p = shaderlib.create_gpu_program("gfx_texture_program", vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  gh_gpu_program.uniform1i(p, "tex0", 0)
  gh_gpu_program.uniform2f(p, "uv_tiling", 1.0, 1.0)
  --shaderlib._texture_program = p
  shaderlib.add("texture", p)
end  


--------------------------------------------------------
function shaderlib.init_gpu_program_phong_texture()

  local vs_gl3=" \
in vec4 gxl3d_Position;\
in vec3 gxl3d_Normal; \
in vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GeeXLab \
uniform vec4 light_position; \
out vec4 v_uv;\
out vec4 v_normal;\
out vec4 v_lightdir;\
out vec4 v_eye;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_uv = gxl3d_TexCoord0;\
  v_normal = gxl3d_ModelViewMatrix  * vec4(gxl3d_Normal.xyz, 0.0);\
  vec4 view_vertex = gxl3d_ModelViewMatrix * gxl3d_Position;\
  vec4 LP = gxl3d_ViewMatrix * light_position;\
  v_lightdir = LP - view_vertex;\
  v_eye = -view_vertex;\
}"

  local ps_gl3=" \
uniform sampler2D tex0;\
uniform vec4 light_diffuse;\
uniform vec4 material_diffuse;\
uniform vec4 light_specular;\
uniform vec4 material_specular;\
uniform float material_shininess;\
uniform vec2 uv_tiling;\
in vec4 v_uv;\
in vec4 v_normal;\
in vec4 v_lightdir;\
in vec4 v_eye;\
out vec4 FragColor;\
void main() \
{ \
  vec2 uv = v_uv.xy * uv_tiling;\
  uv.y *= -1.0;\
  vec4 tex0_color = texture(tex0, uv);\
  vec4 final_color = vec4(0.2, 0.15, 0.15, 1.0) * tex0_color; \
  vec4 N = normalize(v_normal);\
  vec4 L = normalize(v_lightdir);\
  float lambertTerm = dot(N,L);\
  if (lambertTerm > 0.0)\
  {\
    final_color += light_diffuse * material_diffuse * lambertTerm * tex0_color;	\
    vec4 E = normalize(v_eye);\
    vec4 R = reflect(-L, N);\
    float specular = pow( max(dot(R, E), 0.0), material_shininess);\
    final_color += light_specular * material_specular * specular;	\
  }\
  FragColor = final_color;\
}"
  

  local vs_gl2=" \
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GeeXLab \
uniform vec4 light_position; \
varying vec4 v_uv;\
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex;\
  v_uv = gl_MultiTexCoord0;\
  v_normal = gxl3d_ModelViewMatrix  * vec4(gl_Normal.xyz, 0.0);\
  vec4 view_vertex = gxl3d_ModelViewMatrix * gl_Vertex;\
  vec4 LP = gxl3d_ViewMatrix * light_position;\
  v_lightdir = LP - view_vertex;\
  v_eye = -view_vertex;\
}"

  local ps_gl2=" \
uniform sampler2D tex0;\
uniform vec4 light_diffuse;\
uniform vec4 material_diffuse;\
uniform vec4 light_specular;\
uniform vec4 material_specular;\
uniform float material_shininess;\
uniform vec2 uv_tiling;\
varying vec4 v_uv;\
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  vec2 uv = v_uv.xy * uv_tiling;\
  uv.y *= -1.0;\
  vec4 tex0_color = texture2D(tex0, uv);\
  vec4 final_color = vec4(0.2, 0.15, 0.15, 1.0) * tex0_color; \
  vec4 N = normalize(v_normal);\
  vec4 L = normalize(v_lightdir);\
  float lambertTerm = dot(N,L);\
  if (lambertTerm > 0.0)\
  {\
    final_color += light_diffuse * material_diffuse * lambertTerm * tex0_color;	\
    vec4 E = normalize(v_eye);\
    vec4 R = reflect(-L, N);\
    float specular = pow( max(dot(R, E), 0.0), material_shininess);\
    final_color += light_specular * material_specular * specular;	\
  }\
  gl_FragColor = final_color;\
}"


  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_Normal; \
attribute vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GeeXLab \
uniform vec4 light_position; \
varying vec4 v_uv;\
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_uv = gxl3d_TexCoord0;\
  v_normal = gxl3d_ModelViewMatrix  * vec4(gxl3d_Normal.xyz, 0.0);\
  vec4 view_vertex = gxl3d_ModelViewMatrix * gxl3d_Position;\
  vec4 LP = gxl3d_ViewMatrix * light_position;\
  v_lightdir = LP - view_vertex;\
  v_eye = -view_vertex;\
}"

  local ps_gles2=" \
uniform sampler2D tex0;\
uniform vec4 light_diffuse;\
uniform vec4 material_diffuse;\
uniform vec4 light_specular;\
uniform vec4 material_specular;\
uniform float material_shininess;\
uniform vec2 uv_tiling;\
varying vec4 v_uv;\
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  vec2 uv = v_uv.xy * uv_tiling;\
  uv.y *= -1.0;\
  vec4 tex0_color = texture2D(tex0, uv);\
  vec4 final_color = vec4(0.2, 0.15, 0.15, 1.0) * tex0_color; \
  vec4 N = normalize(v_normal);\
  vec4 L = normalize(v_lightdir);\
  float lambertTerm = dot(N,L);\
  if (lambertTerm > 0.0)\
  {\
    final_color += light_diffuse * material_diffuse * lambertTerm * tex0_color;	\
    vec4 E = normalize(v_eye);\
    vec4 R = reflect(-L, N);\
    float specular = pow( max(dot(R, E), 0.0), material_shininess);\
    final_color += light_specular * material_specular * specular;	\
  }\
  gl_FragColor = final_color;\
}"

  local p = shaderlib.create_gpu_program("gfx_phong_texture_program", vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  gh_gpu_program.uniform1i(p, "tex0", 0)
  gh_gpu_program.uniform2f(p, "uv_tiling", 1.0, 1.0)
  gh_gpu_program.uniform4f(p, "light_position", 20.0, 50.0, 100.0, 1.0)
  gh_gpu_program.uniform4f(p, "light_diffuse", 0.9, 0.9, 0.8, 1.0)
  gh_gpu_program.uniform4f(p, "material_diffuse", 0.9, 0.9, 0.9, 1.0)
  gh_gpu_program.uniform4f(p, "light_specular", 0.6, 0.6, 0.6, 1.0)
  gh_gpu_program.uniform4f(p, "material_specular", 0.6, 0.6, 0.6, 1.0)
  gh_gpu_program.uniform1f(p, "material_shininess", 60.0)
  --shaderlib._phong_texture_program = p
  shaderlib.add("phong_texture", p)
  
end  

--------------------------------------------------------------------------------
function shaderlib.init_gpu_program_phong()

  local vs_gl3=" \
in vec4 gxl3d_Position;\
in vec4 gxl3d_Normal; \
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GeeXLab \
uniform vec4 light_position; \
out vec4 v_normal;\
out vec4 v_lightdir;\
out vec4 v_eye;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_normal = gxl3d_ModelViewMatrix  * vec4(gxl3d_Normal.xyz, 0.0);\
  vec4 view_vertex = gxl3d_ModelViewMatrix * gxl3d_Position;\
  vec4 LP = gxl3d_ViewMatrix * light_position;\
  v_lightdir = LP - view_vertex;\
  v_eye = -view_vertex;\
}"

  local ps_gl3=" \
uniform vec4 light_diffuse;\
uniform vec4 material_diffuse;\
uniform vec4 light_specular;\
uniform vec4 material_specular;\
uniform float material_shininess;\
in vec4 v_normal;\
in vec4 v_lightdir;\
in vec4 v_eye;\
out vec4 FragColor;\
void main() \
{ \
  vec4 final_color = vec4(0.2, 0.15, 0.15, 1.0); \
  vec4 N = normalize(v_normal);\
  vec4 L = normalize(v_lightdir);\
  float lambertTerm = dot(N,L);\
  if (lambertTerm > 0.0)\
  {\
    final_color += light_diffuse * material_diffuse * lambertTerm;	\
    vec4 E = normalize(v_eye);\
    vec4 R = reflect(-L, N);\
    float specular = pow( max(dot(R, E), 0.0), material_shininess);\
    final_color += light_specular * material_specular * specular;	\
  }\
  FragColor = final_color;\
  //FragColor = vec4(vec3(L), 1.0);\
}"
  

  local vs_gl2=" \
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GeeXLab \
uniform vec4 light_position; \
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gl_Vertex;\
  v_normal = gxl3d_ModelViewMatrix  * vec4(gl_Normal.xyz, 0.0);\
  vec4 view_vertex = gxl3d_ModelViewMatrix * gl_Vertex;\
  vec4 LP = gxl3d_ViewMatrix * light_position;\
  v_lightdir = LP - view_vertex;\
  v_eye = -view_vertex;\
}"

  local ps_gl2=" \
uniform vec4 light_diffuse;\
uniform vec4 material_diffuse;\
uniform vec4 light_specular;\
uniform vec4 material_specular;\
uniform float material_shininess;\
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  vec4 final_color = vec4(0.2, 0.15, 0.15, 1.0); \
  vec4 N = normalize(v_normal);\
  vec4 L = normalize(v_lightdir);\
  float lambertTerm = dot(N,L);\
  if (lambertTerm > 0.0)\
  {\
    final_color += light_diffuse * material_diffuse * lambertTerm;	\
    vec4 E = normalize(v_eye);\
    vec4 R = reflect(-L, N);\
    float specular = pow( max(dot(R, E), 0.0), material_shininess);\
    final_color += light_specular * material_specular * specular;	\
  }\
  gl_FragColor = final_color;\
}"


  local vs_gles2=" \
attribute vec4 gxl3d_Position;\
attribute vec4 gxl3d_Normal; \
attribute vec4 gxl3d_TexCoord0;\
uniform mat4 gxl3d_ModelViewProjectionMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ModelViewMatrix; // Automatically passed by GeeXLab \
uniform mat4 gxl3d_ViewMatrix; // Automatically passed by GeeXLab \
uniform vec4 light_position; \
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  gl_Position = gxl3d_ModelViewProjectionMatrix * gxl3d_Position;\
  v_normal = gxl3d_ModelViewMatrix  * vec4(gxl3d_Normal.xyz, 0.0);\
  vec4 view_vertex = gxl3d_ModelViewMatrix * gxl3d_Position;\
  vec4 LP = gxl3d_ViewMatrix * light_position;\
  v_lightdir = LP - view_vertex;\
  v_eye = -view_vertex;\
}"

  local ps_gles2=" \
uniform vec4 light_diffuse;\
uniform vec4 material_diffuse;\
uniform vec4 light_specular;\
uniform vec4 material_specular;\
uniform float material_shininess;\
varying vec4 v_normal;\
varying vec4 v_lightdir;\
varying vec4 v_eye;\
void main() \
{ \
  vec4 final_color = vec4(0.2, 0.15, 0.15, 1.0); \
  vec4 N = normalize(v_normal);\
  vec4 L = normalize(v_lightdir);\
  float lambertTerm = dot(N,L);\
  if (lambertTerm > 0.0)\
  {\
    final_color += light_diffuse * material_diffuse * lambertTerm;	\
    vec4 E = normalize(v_eye);\
    vec4 R = reflect(-L, N);\
    float specular = pow( max(dot(R, E), 0.0), material_shininess);\
    final_color += light_specular * material_specular * specular;	\
  }\
  gl_FragColor = final_color;\
}"

  local p = shaderlib.create_gpu_program("gfx_phong_program", vs_gl2, ps_gl2, vs_gl3, ps_gl3, vs_gles2, ps_gles2)
  gh_gpu_program.uniform4f(p, "light_position", 20.0, 50.0, 100.0, 1.0)
  gh_gpu_program.uniform4f(p, "light_diffuse", 0.9, 0.9, 0.8, 1.0)
  gh_gpu_program.uniform4f(p, "material_diffuse", 0.9, 0.9, 0.9, 1.0)
  gh_gpu_program.uniform4f(p, "light_specular", 0.6, 0.6, 0.6, 1.0)
  gh_gpu_program.uniform4f(p, "material_specular", 0.6, 0.6, 0.6, 1.0)
  gh_gpu_program.uniform1f(p, "material_shininess", 60.0)
  --shaderlib._phong_program = p
  shaderlib.add("phong", p)
  
end  

----------------------------------------------------------------------------------------
function shaderlib.init()

  shaderlib.init_gpu_program_color()
  shaderlib.init_gpu_program_vertex_color()
  shaderlib.init_gpu_program_texture()
  shaderlib.init_gpu_program_phong()
  shaderlib.init_gpu_program_phong_texture()
    
end

----------------------------------------------------------------------------------------
function shaderlib.bind_color(r, g, b, a)
  local p = shaderlib.getid("color")
  gh_gpu_program.bind(p)
  gh_gpu_program.uniform4f(p, "color", r, g, b, a)
end

----------------------------------------------------------------------------------------
function shaderlib.bind_phong_texture(light_pos_x, light_pos_y, light_pos_z, light_diff_r, light_diff_g, light_diff_b)
  local p = shaderlib.getid("phong_texture")
  gh_gpu_program.bind(p)
  gh_gpu_program.uniform4f(p, "light_position", light_pos_x, light_pos_y, light_pos_z, 1.0)
  gh_gpu_program.uniform4f(p, "light_diffuse", light_diff_r, light_diff_g, light_diff_b, 1.0)
end

----------------------------------------------------------------------------------------
function shaderlib.bind_phong(light_pos_x, light_pos_y, light_pos_z, light_diff_r, light_diff_g, light_diff_b)
  local p = shaderlib.getid("phong")
  gh_gpu_program.bind(p)
  gh_gpu_program.uniform4f(p, "light_position", light_pos_x, light_pos_y, light_pos_z, 1.0)
  gh_gpu_program.uniform4f(p, "light_diffuse", light_diff_r, light_diff_g, light_diff_b, 1.0)
end

 


