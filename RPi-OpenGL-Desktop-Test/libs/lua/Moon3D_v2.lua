
package.path = gh_utils.get_scripting_libs_dir() ..  "lua/?.lua;" .. package.path
demolib = require "DemoLib"




moon3d_image = {}

function moon3d_image.load2d(filename)
  local absolute_path = 0
  local t = demolib.load_texture(filename, absolute_path)
  --local t = gh_texture.create_from_file_v2(filename, 0, absolute_path, 0)
  --[[
  SAMPLER_FILTERING_NEAREST = 1,
  SAMPLER_FILTERING_LINEAR = 2,
  SAMPLER_ADDRESSING_WRAP = 1,
  SAMPLER_ADDRESSING_CLAMP_TO_EDGE = 2,
  SAMPLER_ADDRESSING_MIRROR = 3,
  local filtering_mode = 2
  local addressing_mode = 1
  gh_texture.set_sampler_params(t, filtering_mode, addressing_mode, 1.0)
  --]]
  return t
end

function moon3d_image.loadCubeMap(posx_filename, negx_filename, posy_filename, negy_filename, posz_filename, negz_filename)
  local absolute_path = 0
  local pf = 3 -- RGBA_U8
  local cm = gh_texture.create_cube_from_file(posx_filename, negx_filename, posy_filename, negy_filename, posz_filename, negz_filename, pf, absolute_path, 0)
  return cm
end



moon3d_render_target = {}

function moon3d_render_target.createU8(width, height)
  return demolib.render_target_create_rgba_u8(width, height)
end  

function moon3d_render_target.createF32(width, height)
  return demolib.render_target_create_rgba_f32(width, height)
end  

function moon3d_render_target.bind(rt)
  gh_render_target.bind(rt)
end  

function moon3d_render_target.bindColor(rt, texture_unit)
  gh_texture.rt_color_bind(rt, texture_unit)
end  

function moon3d_render_target.resize(rt, w, h)
  gh_render_target.resize(rt, w, h)
end




moon3d_gpu_program = {}

function moon3d_gpu_program.bind(gpu_prog)
  gh_gpu_program.bind(gpu_prog)
end

function moon3d_gpu_program.get(name)
  return demolib.get_gpu_program(name)
end  

function moon3d_gpu_program.setUniform1i(gpu_prog, uniform_name, x)
  gh_gpu_program.uniform1i(gpu_prog, uniform_name, x)
end

function moon3d_gpu_program.setUniform1f(gpu_prog, uniform_name, x)
  gh_gpu_program.uniform1f(gpu_prog, uniform_name, x)
end

function moon3d_gpu_program.setUniform2f(gpu_prog, uniform_name, x, y)
  gh_gpu_program.uniform2f(gpu_prog, uniform_name, x, y)
end

function moon3d_gpu_program.setUniform3f(gpu_prog, uniform_name, x, y, z)
  gh_gpu_program.uniform3f(gpu_prog, uniform_name, x, y, z)
end

function moon3d_gpu_program.setUniform4f(gpu_prog, uniform_name, x, y, z, w)
  gh_gpu_program.uniform4f(gpu_prog, uniform_name, x, y, z, w)
end

function moon3d_gpu_program.setUniform4f(gpu_prog, uniform_name, x, y, z, w)
  gh_gpu_program.uniform4f(gpu_prog, uniform_name, x, y, z, w)
end




moon3d_graphics = {
  _use_opengl2 = 1,
  glsl = moon3d_gpu_program,
  rt = moon3d_render_target
}

function moon3d_graphics.init0(use_opengl2)
  moon3d_graphics._use_opengl2 = use_opengl2
end  

--[[
====== Graphics state ======
--]]
function moon3d_graphics.wireframe(state)
  if (state == 1) then
    demolib.wireframe(1)
  else
    demolib.wireframe(0)
  end
end 

function moon3d_graphics.vsync(state)
  if (state == 1) then
    demolib.vsync(1)
  else
    demolib.vsync(0)
  end
end 

function moon3d_graphics.depthTest(state)
  if (state == 1) then
    gh_renderer.set_depth_test_state(1)
  else
    gh_renderer.set_depth_test_state(0)
  end
end 


function moon3d_graphics.blendColor(state, src_factor, dst_factor)
  --[[
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
  --]]
  if (state == 1) then
    gh_renderer.set_blending_state(1)
    gh_renderer.set_blending_factors(src_factor, dst_factor)
  else
    gh_renderer.set_blending_state(0)
  end
end 


function moon3d_graphics.clearColorDepthBuffers(r, g, b, a, z)
  gh_renderer.clear_color_depth_buffers(r, g, b, a, z)
end  

function moon3d_graphics.clearColorBuffer(r, g, b, a)
  gh_renderer.clear_color_buffer(r, g, b, a)
end  

function moon3d_graphics.clearDepthBuffer(z)
  gh_renderer.clear_depth_buffer(z)
end  


function moon3d_graphics.getNumOpenGLExtensions()
  return gh_renderer.get_num_opengl_extensions()
end  

function moon3d_graphics.getOpenGLExtensionName(index)
  local ext_name = gh_renderer.get_opengl_extension(index)
  return ext_name
end  


--[[
====== Object creation ======
--]]
function moon3d_graphics.newTorus(major_radius, minor_radius, slices)
  local mesh = demolib.create_torus(major_radius, minor_radius, slices, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.newSphere(radius, slices, stacks)
  local mesh = demolib.create_sphere(radius, slices, stacks, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.newPlane(width, height, num_div_w, num_div_h)
  local mesh = demolib.create_plane(width, height, num_div_w, num_div_h, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.newBox(width, height, depth, num_div_w, num_div_h, num_div_d)
  local mesh = demolib.create_box(width, height, depth, num_div_w, num_div_h, num_div_d, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.newCylinder(radius, height, stacks, slices)
  local mesh = demolib.create_cylinder(radius, height, stacks, slices, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.newEllipse(major_radius, minor_radius, slices, radius_segments, opening_angle)
  local mesh = demolib.create_ellipse(major_radius, minor_radius, slices, radius_segments, opening_angle, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.newQuad(width, height)
  local mesh = demolib.create_quad(width, height, moon3d_graphics._use_opengl2)
  return mesh
end

function moon3d_graphics.resizeQuad(quad, width, height)
  demolib.resize_quad(quad, width, height)
end


function moon3d_graphics._prepare_model(model, load_textures, textures_directory, update_normals)
  if (model > 0) then
  
    gh_object.use_opengl21(model, moon3d_graphics._use_opengl2)
    --gh_object.use_opengl21(model, 0)
  
    if (load_textures == 1) then
      -- WARNING: texture filenames are case-sensitive especially under Linux! 
      -- So my_kool_texture.jpg is different from MY_KOOL_TEXTURE.JPG !!!
      -- Check how the texture filenames are stored in the 3D file 
      -- if you have problem to load textures...
      gh_model.load_textures(model, textures_directory)
      
      -- With some algorithms (shadow mapping for example), it can be useful 
      -- to specify the texture unit starting offset (default is 0: the first texture unit
      -- will be 0).
      gh_object.set_materials_texture_unit_offset(model, 0)
    end

    gh_object.set_position(model, 0, 0, 0)
    gh_object.set_euler_angles(model, 0, 0, 0)
  
    if (update_normals == 1) then
      gh_object.compute_faces_normal(model)
      gh_object.compute_vertices_normal(model)
    end
  end   
end

function moon3d_graphics.new3DS(object_filename, object_folder, resource_folder, load_textures, update_normals)
  local demo_dir = gh_utils.get_scenegraph_dir() 		
  local model_directory = demo_dir .. "/" .. object_folder 
  local resource_directory = demo_dir .. "/" .. resource_folder 
  local model = gh_model.create_from_file_loader_3ds(object_filename, model_directory, resource_directory)
  moon3d_graphics._prepare_model(model, load_textures, resource_directory, update_normals)
  return model
end

function moon3d_graphics.newOBJ(object_filename, object_folder, resource_folder, load_textures, update_normals)
  local demo_dir = gh_utils.get_scenegraph_dir()
  local model_directory = demo_dir .. "/" .. object_folder 
  local resource_directory = demo_dir .. "/" .. resource_folder 
  local model = gh_model.create_from_file_loader_obj(object_filename, model_directory, resource_directory)
  moon3d_graphics._prepare_model(model, load_textures, resource_directory, update_normals)
  return model
end

function moon3d_graphics.newFBX(object_filename, object_folder, resource_folder, load_textures, update_normals)
  -- The FBX loader can load *.FBX, *.3DS and *.OBJ files.
  local demo_dir = gh_utils.get_scenegraph_dir()
  local model_directory = demo_dir .. "/" .. object_folder 
  local resource_directory = demo_dir .. "/" .. resource_folder 
  local model = gh_model.create_from_file_loader_fbx(object_filename, model_directory, resource_directory)
  moon3d_graphics._prepare_model(model, load_textures, resource_directory, update_normals)
  return model
end


--[[
====== Drawing ======
--]]

function moon3d_graphics.checkOpenGLExtension(extension_name)
  -- returns 1 if the extension is supported.
  return gh_renderer.check_opengl_extension(extension_name)
end  


function moon3d_graphics.draw(obj)
  gh_object.render(obj)
end  

function moon3d_graphics.draw2(obj, gpu_program)
  demolib.render_object(obj, gpu_program)
end  

function moon3d_graphics.draw3(obj, gpu_program, texture)
  demolib.render_textured_object(obj, texture, gpu_program)
end  

function moon3d_graphics.drawWithColor(obj, r, g, b, a)
  if (obj > 0) then
    --demolib.bind_camera_persp()
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 0, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_object.render(obj)
  end
end

function moon3d_graphics.drawWithTexturing(obj, texture, u_tile, v_tile, r, g, b, a)
  if ((obj > 0) and (texture > 0)) then
    --demolib.bind_camera_persp()
    gh_texture.bind(texture, 0)
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", u_tile, v_tile, 0, 0)
    gh_object.render(obj)
  end
end

function moon3d_graphics.drawModelWithTexturing(model, u_tile, v_tile, r, g, b, a)
  if (model > 0)  then
    -- The model textures are managed by the model rendering code.
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", u_tile, v_tile, 0, 0)
    gh_object.render(model)
  end
end

function moon3d_graphics.setLightingParams(x, y, z, ar, ag, ab, aa, dr, dg, db, da, sr, sg, sb, sa)
  local p = demolib.get_uber_phong_texture_prog() 
  gh_gpu_program.bind(p)
  gh_gpu_program.uniform4f(p, "light_position", x, y, z, 1)
  gh_gpu_program.uniform4f(p, "light_ambient", ar, ag, ab, aa)
  gh_gpu_program.uniform4f(p, "light_diffuse", dr, dg, db, da)
  gh_gpu_program.uniform4f(p, "light_specular", sr, sg, sb, sa)
end

function moon3d_graphics.setLightPosition(x, y, z)
  local p = demolib.get_uber_phong_texture_prog() 
  gh_gpu_program.bind(p)
  gh_gpu_program.uniform4f(p, "light_position", x, y, z, 1)
end

function moon3d_graphics.setMaterialParams(ar, ag, ab, aa, dr, dg, db, da, sr, sg, sb, sa, shininess)
  local p = demolib.get_uber_phong_texture_prog() 
  gh_gpu_program.bind(p)
  gh_gpu_program.uniform4f(p, "material_ambient", ar, ag, ab, aa)
  gh_gpu_program.uniform4f(p, "material_diffuse", dr, dg, db, da)
  gh_gpu_program.uniform4f(p, "material_specular", sr, sg, sb, sa)
  gh_gpu_program.uniform1f(p, "material_shininess", shininess)
end

function moon3d_graphics.drawWithLighting(obj, r, g, b, a)
  if (obj > 0) then
    --demolib.bind_camera_persp()
    gh_gpu_program.bind(demolib.phong_prog)
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 0, 1, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_object.render(obj)
  end
end

function moon3d_graphics.drawWithTexturingLighting(obj, texture, u_tile, v_tile, r, g, b, a)
  if ((obj > 0) and (texture > 0)) then
    --demolib.bind_camera_persp()
    gh_texture.bind(texture, 0)
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 1, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", u_tile, v_tile, 0, 0)
    gh_object.render(obj)
  end
end

function moon3d_graphics.drawModelWithTexturingLighting(model, u_tile, v_tile, r, g, b, a)
  if (model > 0) then
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 1, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", u_tile, v_tile, 0, 0)
    gh_object.render(model)
  end
end


function moon3d_graphics.drawBkgImage(image)
  demolib.render_bkg_image(image)
end  

function moon3d_graphics.drawBkgImageV2(image, u_tile, v_tile, r, g, b, a)
  demolib.render_bkg_image_v2(image, u_tile, v_tile, r, g, b, a)
end  


function moon3d_graphics.drawHudQuad(obj, r, g, b, a)
  if (obj > 0) then
    gh_renderer.set_depth_test_state(0)
    gh_camera.bind(camera_ortho)
    gh_texture.bind(texture, 0)
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 0, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_object.render(obj)
    gh_renderer.set_depth_test_state(1)
  end
end

function moon3d_graphics.drawHudQuadWithTexturing(obj, texture, u_tile, v_tile, r, g, b, a)
  if ((obj > 0) and (texture > 0)) then
    gh_renderer.set_depth_test_state(0)
    gh_camera.bind(camera_ortho)
    gh_texture.bind(texture, 0)
    local p = demolib.get_uber_phong_texture_prog() 
    gh_gpu_program.bind(p)
    gh_gpu_program.uniform4i(p, "render_params", 1, 0, 0, 0)
    gh_gpu_program.uniform4f(p, "color", r, g, b, a)
    gh_gpu_program.uniform1i(p, "tex0", 0)
    gh_gpu_program.uniform4f(p, "uv_tiling", u_tile, v_tile, 0, 0)
    gh_object.render(obj)
    gh_renderer.set_depth_test_state(1)
  end
end


function moon3d_graphics.bindGpuProgram(gpu_prog)
  gh_gpu_program.bind(gpu_prog)
end

function moon3d_graphics.getGpuProgram(name)
  return demolib.get_gpu_program(name)
end  

--[[
function moon3d_graphics.atomicCounterCreateBuffer(num_elements, binding_point_index)
  return demolib.atomic_counter_create_buffer(num_elements, binding_point_index)
end  

function moon3d_graphics.atomicCounterKillBuffer(ac_buf)
  demolib.atomic_counter_kill_buffer(ac_buf)    
end  

function moon3d_graphics.atomicCounterBind(ac_buf, binding_point_index)
  demolib.atomic_counter_bind(ac_buf, binding_point_index)
end

function moon3d_graphics.atomicCounterSetValue(ac_buf, index, value)
  demolib.atomic_counter_set_value(ac_buf, index, value)
end  

function moon3d_graphics.atomicCounterGetValue(ac_buf, index)
  return demolib.atomic_counter_get_value(ac_buf, index)
end  
--]]







moon3d_object = {}

function moon3d_object.setPosition(obj, x, y, z)
  gh_object.set_position(obj, x, y, z)
end

function moon3d_object.setEulerAngles(obj, pitch, yaw, roll)
  gh_object.set_euler_angles(obj, pitch, yaw, roll)
end

function moon3d_object.setScale(obj, x, y, z)
  gh_object.set_scale(obj, x, y, z)
end

function moon3d_object.getNumVertices(obj)
  return gh_object.get_num_vertices(obj)
end

function moon3d_object.getNumFaces(obj)
  return gh_object.get_num_faces(obj)
end





moon3d_camera = {
  _mode = 0,
  _lookat = {x=0, y=0, z=0}
}

function moon3d_camera.bindPersp()
  demolib.bind_camera_persp()
end  

function moon3d_camera.bindOrtho()
  demolib.bind_camera_ortho()
end  

function moon3d_camera.bind(cam)
  gh_camera.bind(cam)
end  

function moon3d_camera.setMode(mode)
	-- Camera mode: 
	-- 0: (manual control in the code with CameraUpdate)
	-- 1: (fly)
	-- 2: (orbit) 
  moon3d_camera._mode = mode 
end

function moon3d_camera.getMode()
  return moon3d_camera._mode 
end

function moon3d_camera.getDefaultPersp()
  return demolib.get_camera_persp()
end

function moon3d_camera.setDefaultPersp(cam)
  return demolib.set_camera_persp(cam)
end

function moon3d_camera.getDefaultOrtho()
  return demolib.get_camera_ortho()
end

function moon3d_camera.setDefaultOrtho(cam)
  return demolib.set_camera_ortho(cam)
end

function moon3d_camera.newOrtho(width, height)
  return demolib.camera_ortho_create(width, height)
end  

function moon3d_camera.newPersp(fov, aspect, znear, zfar)
  local viewport_width, viewport_height = demolib.get_window_size()
  return demo.camera_persp_create(fov, aspect, znear, zfar, 0, 0, viewport_width, viewport_height)
end  

function moon3d_camera.setPosition(cam, x, y, z)
  gh_camera.set_position(cam, x, y, z)
  gh_camera.set_lookat(cam, moon3d_camera._lookat.x, moon3d_camera._lookat.y, moon3d_camera._lookat.z, 1)
end

function moon3d_camera.setLookat(cam, x, y, z)
  moon3d_camera._lookat.x = x
  moon3d_camera._lookat.y = y
  moon3d_camera._lookat.z = z
  gh_camera.set_lookat(cam, moon3d_camera._lookat.x, moon3d_camera._lookat.y, moon3d_camera._lookat.z, 1)
end

function moon3d_camera.initOrbitModeRotation(camera, vec3_lookat, pitch, yaw)
  local cam_mod = demolib.get_mod_camera()
  cam_mod.InitCameraRotation(camera, vec3_lookat, pitch, yaw)
end  

function moon3d_camera.updatePerspectiveProjection(camera, fov, aspect, znear, zfar)
  demolib.camera_persp_update_proj(camera, fov, aspect, znear, zfar)
end

function moon3d_camera.updatePerspectiveSettings(fov, x, y, z, lookat_x, lookat_y, lookat_z, pitch, yaw, strafe) 
  demolib.update_camera_perspective(fov, x, y, z, lookat_x, lookat_y, lookat_z, pitch, yaw, strafe) 
end





moon3d_font = {
  _use_opengl2 = 1
}

function moon3d_font.init0(use_opengl2)
  moon3d_font._use_opengl2 = use_opengl2
end  

function moon3d_font.create(bm_font_filename, bm_font_folder)
  local is_absolute_path=0
  local bm_font = demolib.bm_font_create(bm_font_filename, bm_font_folder, is_absolute_path, moon3d_font._use_opengl2)
  return bm_font
end

function moon3d_font.getTexture(bm_font)
  local t = demolib.bm_font_get_texture(bm_font)
  return t
end

function moon3d_font.draw2D(bm_font, bm_font_texture, gpu_prog, camera)
  demolib.bm_font_draw_prepare(1, 2)
  demolib.bm_font_draw2d(bm_font, bm_font_texture, gpu_prog, camera)
  demolib.bm_font_draw_finish()
end

function moon3d_font.draw2D_v2(bm_font, bm_font_texture, gpu_prog, camera, blending_src_factor, blending_dst_factor)
  demolib.bm_font_draw_prepare(blending_src_factor, blending_dst_factor)
  demolib.bm_font_draw2d(bm_font, bm_font_texture, gpu_prog, camera)
  demolib.bm_font_draw_finish()
end

function moon3d_font.draw3D(bm_font, bm_font_texture, gpu_prog, camera)
  demolib.bm_font_draw_prepare(1, 2)
  demolib.bm_font_draw3d(bm_font, bm_font_texture, gpu_prog, camera)
  demolib.bm_font_draw_finish()
end

function moon3d_font.resetWrite(bm_font)
  demolib.bm_font_write_reset(bm_font)
end

function moon3d_font.write2D(bm_font, x, y, r, g, b, a, text)
  demolib.bm_font_write2d(bm_font, x, y, r, g, b, a, text)
end

function moon3d_font.write3D(bm_font, x, y, z, r, g, b, a, text)
  demolib.bm_font_write3d(bm_font, x, y, z, r, g, b, a, text)
end

function moon3d_font.update(bm_font, font_scale)
  demolib.bm_font_update(bm_font, font_scale)
end










moon3d_madshaders = {
  benchmark_mode = 0,
  command_line = "",
  winW = 0,
  winH = 0,
  winW_start = 0,
  winH_start = 0,
  benchmark_ok = 1,
  benchmark_title = "GLSL Hacker / Moon3D - MadShaders",
  duration = 60, -- BENCHMARK DURATION in seconds!!!
  elapsed_time = 0,
  last_elapsed_time_fps = 0,
  last_time = 0,
  total_frames = 0,
  fps_frames = 0,
  sum_fps = 0,
  n_sum_fps = 0,
  fps_avg = 0,
  fps = 0,
  fps_min = 10000,
  fps_max = 0,
  fps_score = 0,
  renderer = gh_renderer.get_renderer_model(),
  _bm_font = 0,
  _bm_font_texture = 0,
  
  _osi = 1, -- On Screen Info
  
  _gpumon_ftgl_font = 0,
  _gpumon_ftgl_texture = 0,
  _gpumon_font_prog = 0,
  _gpumon_camera_ortho = 0,
  _gpumon_initialized = 0
}


function moon3d_madshaders.initGpuMonitoring()

  if (moon3d_madshaders._gpumon_initialized == 1) then
    return
  end
  
  print("moon3d_madshaders.initGpuMonitoring() -  winW=" .. moon3d_madshaders.winW .. " winH=" .. moon3d_madshaders.winH)
 
  local demo_dir = gh_utils.get_demo_dir()
  moon3d_madshaders._gpumon_ftgl_texture = gh_utils.ftgl_font_texture_load(demo_dir .. "data/unispace bd.ttf", 14, 512, 512, 0, 0)
  print("moon3d_madshaders._gpumon_ftgl_texture = " .. moon3d_madshaders._gpumon_ftgl_texture)

  moon3d_madshaders._gpumon_ftgl_font = gh_utils.ftgl_font_create(moon3d_madshaders._gpumon_ftgl_texture)
  print("moon3d_madshaders._gpumon_ftgl_font = " .. moon3d_madshaders._gpumon_ftgl_font)
  

  gh_gpumon.init()
  gh_gpumon.set_viewport(0, 0, moon3d_madshaders.winW, moon3d_madshaders.winH)
  gh_gpumon.set_gpu_data_color(0, 0, 1, 0, 1)
  gh_gpumon.set_gpu_data_color(1, 1, 1, 0, 1)

  gh_gpumon.set_bkg_quad_color(1.0, 1.0, 1.0, 1)
  gh_gpumon.set_bkg_quad_vertex_color(0, 0, 0.2, 0.4, 1)
  gh_gpumon.set_bkg_quad_vertex_color(1, 0, 0.2, 0.4, 1)
  gh_gpumon.set_bkg_quad_vertex_color(2, 1, 1, 1, 1)
  gh_gpumon.set_bkg_quad_vertex_color(3, 1, 1, 1, 1)
  
  moon3d_madshaders._gpumon_camera_ortho = gh_camera.create_ortho(-moon3d_madshaders.winW/2, moon3d_madshaders.winW/2, -moon3d_madshaders.winH/2, moon3d_madshaders.winH/2, 1.0, 10.0)
  gh_camera.set_viewport(moon3d_madshaders._gpumon_camera_ortho, 0, 0, moon3d_madshaders.winW, moon3d_madshaders.winH)
  gh_camera.set_position(moon3d_madshaders._gpumon_camera_ortho, 0, 0, 4)
  
    
  local gpumon_font_prog_vs_gl2=" \
#version 120 \
uniform mat4 gxl3d_ModelViewProjectionMatrix; \
uniform vec4 gxl3d_Viewport; \
varying vec4 Vertex_UV; \
varying vec4 Vertex_Color; \
void main() \
{ \
  vec4 V = vec4(gl_Vertex.xyz, 1); \
  V.x = V.x - gxl3d_Viewport.z/2; \
  V.y = V.y + gxl3d_Viewport.w/2; \
  gl_Position = gxl3d_ModelViewProjectionMatrix * V; \
  Vertex_UV = gl_MultiTexCoord0; \
  Vertex_Color = gl_Color; \
}"

  local gpumon_font_prog_ps_gl2=" \
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
  
  moon3d_madshaders._gpumon_font_prog = gh_gpu_program.create(gpumon_font_prog_vs_gl2, gpumon_font_prog_ps_gl2)
  gh_gpu_program.uniform1i(moon3d_madshaders._gpumon_font_prog, "tex0", 0)
  
  moon3d_madshaders._gpumon_initialized = 1
end

function moon3d_madshaders.cleanupGpuMonitoring()
  if (moon3d_madshaders._gpumon_initialized == 0) then
    return
  end

  gh_utils.ftgl_font_kill(moon3d_madshaders._gpumon_ftgl_font)
  moon3d_madshaders._gpumon_ftgl_font = 0
  gh_utils.ftgl_font_texture_killall()

  gh_gpumon.cleanup()
  moon3d_madshaders._gpumon_initialized = 1
end  


function moon3d_madshaders.resetBenchmarkData()
  moon3d_madshaders.benchmark_mode = 0
  moon3d_madshaders.command_line = gh_utils.get_command_line()
  local ss, es = string.find(moon3d_madshaders.command_line, "/madshaders_benchmark")
  if (ss ~= nil) then
    moon3d_madshaders.benchmark_mode = 1
  end  
  
  ss, es = string.find(moon3d_madshaders.command_line, "/disable_osi")
  if (ss ~= nil) then
    moon3d_madshaders._osi = 0
  end  
  
  moon3d_madshaders.winW, moon3d_madshaders.winH = moon3d.window.getSize()
  moon3d_madshaders.winW_start, moon3d_madshaders.winH_start = moon3d_madshaders.winW, moon3d_madshaders.winH
  moon3d_madshaders.benchmark_ok = 1
  moon3d_madshaders.duration = 60 -- BENCHMARK DURATION in seconds!!!
  moon3d_madshaders.elapsed_time = 0
  moon3d_madshaders.last_elapsed_time_fps = 0
  moon3d_madshaders.last_time = 0
  moon3d_madshaders.total_frames = 0
  moon3d_madshaders.fps_frames = 0
  moon3d_madshaders.sum_fps = 0
  moon3d_madshaders.n_sum_fps = 0
  moon3d_madshaders.fps_avg = 0
  moon3d_madshaders.fps = 0
  moon3d_madshaders.fps_min = 10000
  moon3d_madshaders.fps_max = 0
  moon3d_madshaders.fps_score = 0
  moon3d_madshaders.renderer = gh_renderer.get_renderer_model() 
end
  
function moon3d_madshaders.updateBenchmarkData(global_time)
  if ((moon3d_madshaders.benchmark_mode == 1) and (moon3d_madshaders.benchmark_ok == 1)) then
    local cur_time = global_time
    local dt = cur_time - moon3d_madshaders.last_time
    moon3d_madshaders.last_time = cur_time;
    moon3d_madshaders.elapsed_time = moon3d_madshaders.elapsed_time + dt

    moon3d_madshaders.fps_frames = moon3d_madshaders.fps_frames + 1

    if ((moon3d_madshaders.elapsed_time - moon3d_madshaders.last_elapsed_time_fps) > 1.0) then
      moon3d_madshaders.last_elapsed_time_fps = moon3d_madshaders.elapsed_time
      moon3d_madshaders.fps = moon3d_madshaders.fps_frames
      moon3d_madshaders.fps_frames = 0
      if (moon3d_madshaders.fps_min > moon3d_madshaders.fps) then
        moon3d_madshaders.fps_min = moon3d_madshaders.fps
      end
      if (moon3d_madshaders.fps_max < moon3d_madshaders.fps) then
        moon3d_madshaders.fps_max = moon3d_madshaders.fps
      end
      moon3d_madshaders.sum_fps = moon3d_madshaders.sum_fps + moon3d_madshaders.fps
      moon3d_madshaders.fps_avg = moon3d_madshaders.sum_fps / moon3d_madshaders.elapsed_time;
      moon3d_madshaders.n_sum_fps = moon3d_madshaders.n_sum_fps + 1
    end
    
    moon3d_madshaders.renderer = gh_renderer.get_renderer_model() 
  end
  
  moon3d_madshaders.winW, moon3d_madshaders.winH = moon3d.window.getSize()
end

function moon3d_madshaders.displayBenchmarkInfo()
  if (moon3d_madshaders.benchmark_mode == 1) then
    if (moon3d_madshaders.benchmark_ok == 1) then
      if (moon3d_madshaders.elapsed_time < moon3d_madshaders.duration) then
        if ((moon3d_madshaders.winW_start ~= moon3d_madshaders.winW) or (moon3d_madshaders.winH_start ~= moon3d_madshaders.winH)) then
          moon3d_madshaders.benchmark_ok = 0
        end
        moon3d_madshaders.total_frames = moon3d_madshaders.total_frames + 1
        moon3d_madshaders.fps_score = moon3d_madshaders.fps_avg
        demolib.print(10, 60, string.format("BENCHMARKING... %d %% completed", (moon3d_madshaders.elapsed_time/moon3d_madshaders.duration)*100))
      else  
        demolib.print(10, 60, string.format(">>>>>> SCORE: %d points, FPS: %d <<<<<<", moon3d_madshaders.total_frames, moon3d_madshaders.fps_score))
        demolib.print(10, 80, string.format(">>>>>> Renderer: %s, res: %d x %d <<<<<<", moon3d_madshaders.renderer, moon3d_madshaders.winW_start, moon3d_madshaders.winH_start))
      end
    else  
      demolib.print(10, 60, "Do not resize the window during the benchmark. Benchmark aborted!")
    end
  else
    demolib.print(10, 60, string.format("> Renderer: %s | Res: %dx%d", moon3d_madshaders.renderer, moon3d_madshaders.winW, moon3d_madshaders.winH))
  end  
end
  
function moon3d_madshaders.updateShadertoyCommonParams(gpu_prog, global_time)
  gh_gpu_program.uniform1f(gpu_prog, "iGlobalTime", global_time)
  local screen_width, screen_height = demolib.get_window_size()
  gh_gpu_program.uniform3f(gpu_prog, "iResolution", screen_width, screen_height, 0)
  local mouse_x, mouse_y = gh_input.mouse_getpos() 
  gh_gpu_program.uniform4f(gpu_prog, "iMouse", mouse_x, screen_height-mouse_y, 0, 0)
end

function moon3d_madshaders.setShadertoyTexture(gpu_prog, texture, texture_unit)
  gh_gpu_program.uniform1i(gpu_prog, "iChannel" .. texture_unit, texture_unit);
  local w, h = gh_texture.get_size(texture)
  gh_gpu_program.uniform3f(gpu_prog, "iChannelResolution" .. texture_unit, w, h, 0);
  gh_texture.bind(texture, texture_unit)
end

function moon3d_madshaders.updateGLSLSandboxCommonParams(gpu_prog, global_time)
  gh_gpu_program.uniform1f(gpu_prog, "time", global_time)
  local screen_width, screen_height = demolib.get_window_size()
  gh_gpu_program.uniform2f(gpu_prog, "resolution", screen_width, screen_height)
  --local mouse_x, mouse_y = gh_input.mouse_getpos() 
  --gh_gpu_program.uniform2f(gpu_prog, "mouse", mouse_x/screen_width, 1 - mouse_y/screen_height)
end

function moon3d_madshaders.setGLSLSandboxBackBuffer(gpu_prog, texture_unit)
  gh_gpu_program.uniform1i(gpu_prog, "backbuffer", texture_unit)
end


function moon3d_madshaders.setBmFontData(bm_font, bm_font_texture)
  moon3d_madshaders._bm_font = bm_font
  moon3d_madshaders._bm_font_texture = bm_font_texture

  gh_object.use_generic_va(bm_font, 0)
end

function moon3d_madshaders.displayBenchmarkInfoV3(demo_name, global_time, r, g, b, a, blending_src_factor, blending_dst_factor)
  if (moon3d_madshaders._osi == 0) then 
    return 
  end
  
  moon3d.font.resetWrite(moon3d_madshaders._bm_font)
  local y_offset = 20
  local y_inc = 25
  moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, "MadShaders - " .. demo_name)
  y_offset = y_offset + y_inc
  moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, string.format("Time = %.3f sec.", global_time))
  y_offset = y_offset + y_inc

  if (moon3d_madshaders.benchmark_mode == 1) then
    if (moon3d_madshaders.benchmark_ok == 1) then
      if (moon3d_madshaders.elapsed_time < moon3d_madshaders.duration) then
        if ((moon3d_madshaders.winW_start ~= moon3d_madshaders.winW) or (moon3d_madshaders.winH_start ~= moon3d_madshaders.winH)) then
          moon3d_madshaders.benchmark_ok = 0
        end
        moon3d_madshaders.total_frames = moon3d_madshaders.total_frames + 1
        moon3d_madshaders.fps_score = moon3d_madshaders.fps_avg
        moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, string.format("BENCHMARKING... %d %% completed", (moon3d_madshaders.elapsed_time/moon3d_madshaders.duration)*100))
        y_offset = y_offset + y_inc
      else  
        moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, string.format(">>>>>> SCORE: %d points, FPS: %d <<<<<<", moon3d_madshaders.total_frames, moon3d_madshaders.fps_score))
        y_offset = y_offset + y_inc
        moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, string.format(">>>>>> Renderer: %s, res: %d x %d <<<<<<", moon3d_madshaders.renderer, moon3d_madshaders.winW_start, moon3d_madshaders.winH_start))
        y_offset = y_offset + y_inc
      end
    else  
      moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, "Do not resize the window during the benchmark. Benchmark aborted!")
      y_offset = y_offset + y_inc
    end
  else
    moon3d.font.write2D(moon3d_madshaders._bm_font, 10, y_offset, r, g, b, a, string.format("> Renderer: %s | Res: %dx%d", moon3d_madshaders.renderer, moon3d_madshaders.winW, moon3d_madshaders.winH))
    y_offset = y_offset + y_inc
  end  
  
  moon3d.font.update(moon3d_madshaders._bm_font, 0.85)
  
  --gh_renderer.set_scissor(0,320,200, 320)
  --gh_renderer.set_scissor_state(1)


  moon3d.font.draw2D_v2(moon3d_madshaders._bm_font, moon3d_madshaders._bm_font_texture, 0, 0, blending_src_factor, blending_dst_factor)
  
  --gh_renderer.set_scissor_state(0)
  
  
  --[[
  moon3d_madshaders.initGpuMonitoring()
  if (moon3d_madshaders._gpumon_initialized == 1) then
    gh_gpumon.update_dynamic_data()
    gh_gpumon.draw_gpu_data_v4(20, 20, moon3d_madshaders.winW, 200, moon3d_madshaders._gpumon_ftgl_font, moon3d_madshaders._gpumon_font_prog, moon3d_madshaders._gpumon_camera_ortho, 1.0, 30, moon3d_madshaders.winH - 204, 14)
  end
  --]]
  
end

function moon3d_madshaders.displayBenchmarkInfoV2(demo_name, global_time, r, g, b, a)
  moon3d_madshaders.displayBenchmarkInfoV3(demo_name, global_time, r, g, b, a, 1, 2)
end  





moon3d_window = {

}

function moon3d_window.getSize()
  return demolib.get_window_size()
end

function moon3d_window.resize()
  demolib.resize()
end




moon3d_keyboard = {
  _speed = 50
}

function moon3d_keyboard.setSpeed(speed)
  moon3d_keyboard._speed = speed
end

function moon3d_keyboard.getSpeed()
  return moon3d_keyboard._speed
end




moon3d = {
  _version_major = 0,
  _version_minor = 1,
  _version_patch = 0,
  _use_opengl2 = 1,
  _math = 0,
  camera = moon3d_camera,
  graphics = moon3d_graphics,
  image = moon3d_image,
  object = moon3d_object,
  font = moon3d_font,
  window = moon3d_window,
  keyboard = moon3d_keyboard,
  madshaders = moon3d_madshaders,
}

function moon3d.set_version(major, minor, patch)
  moon3d._version_major = major
  moon3d._version_minor = minor
  moon3d._version_patch = patch
end

function moon3d.init(gl_version_major, gl_version_minor)
  moon3d.set_version(1, 2, 3)
  
  if (gl_version_major >= 3) then
    moon3d._use_opengl2 = 0
  else  
    moon3d._use_opengl2 = 1
  end
  moon3d.graphics.init0(moon3d._use_opengl2)
  moon3d.font.init0(moon3d._use_opengl2)
  demolib.init(moon3d._use_opengl2)
  _math = demolib.get_mod_math()
end

function moon3d.getVersionMajor()
 return moon3d._version_major
end 

function moon3d.getVersionMinor()
 return moon3d._version_minor
end 

function moon3d.getVersionPatch()
 return moon3d._version_patch
end 

function moon3d.random(a, b)
 return _math.random(a, b)
end 


function moon3d.processCameraPersp()
  if (moon3d.camera.getMode() == 1) then
    local dt = demolib.get_time_step()
    demolib.process_camera_v2(dt, moon3d.keyboard.getSpeed())
  elseif (moon3d.camera.getMode() == 2) then	
    local dt = demolib.get_time_step()
    demolib.process_camera_orbit(dt, moon3d.keyboard.getSpeed(), 0, 0, 0)
  end
end  

function moon3d.startFrame(r, g, b, a)
  demolib.frame_begin(r, g, b, a)
  moon3d.processCameraPersp()
end

function moon3d.startFrame_v2()
  demolib.frame_begin_v2()
end

function moon3d.startFrame_v3()
  demolib.frame_begin_v3()
  moon3d.processCameraPersp()
end

function moon3d.endFrame()
  demolib.frame_end()
end

function moon3d.getTime()
  return demolib.get_time()
end

function moon3d.getTimeStep()
  return demolib.get_time_step()
end


function moon3d.print(x, y, text)
  demolib.print(x, y, text)
end

function moon3d.printRGBA(x, y, r, g, b, a, text)
  demolib.print_rgba(x, y, r, g, b, a, text)
end


function moon3d.writeTrace(trace)
  gh_utils.trace(trace)
end

function moon3d.getDemoDir()
    return gh_utils.get_demo_dir()
end    

function moon3d.isWindows()
  if (gh_utils.get_platform() == 1) then
    return 1
  end
  return 0
end    

function moon3d.isOSX()
  if (gh_utils.get_platform() == 2) then
    return 1
  end
  return 0
end    

function moon3d.isLinux()
  if (gh_utils.get_platform() == 3) then
    return 1
  end
  return 0
end    

function moon3d.isRPi()
  if (gh_utils.get_platform() == 4) then
    return 1
  end
  return 0
end    

function moon3d.newVec3()
  local m = demolib.get_mod_math()
  return m.new_vec3()
end    

