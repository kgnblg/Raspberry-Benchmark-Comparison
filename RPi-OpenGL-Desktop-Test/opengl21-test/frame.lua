
gfx.begin_frame()
local elapsed_time = gfx.get_time()
local dt = gfx.get_dt()

local mx, my = gfx.mouse.get_position()

gfx.draw_bkg_quad()
    
    
  

gh_renderer.set_depth_test_state(1)

-- local cam_x = 50.0 * math.cos(elapsed_time*0.5)
-- local cam_y = 40.0 + 10.0 * math.cos(elapsed_time*0.8)
-- local cam_z = 50.0 * math.sin(elapsed_time*0.5)
local cam_x = 0.0
local cam_y = 0.0
local cam_z = 20.0
gh_camera.set_position(camera, cam_x, cam_y, cam_z)
gh_camera.setlookat(camera, 0, 0, 0, 1)
gh_camera.bind(camera)


-- gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)

gh_gpu_program.bind(toon_prog)

-- All uniforms are set every frame. Useful for live coding but
-- these function calls should be removed in a final demo.
--
gh_gpu_program.uniform4f(toon_prog, "light_position", 0.0, 50.0, 50.0, 1.0)
gh_gpu_program.uniform4f(toon_prog, "color1", 0.1,0.7,0.9,1.0)
gh_gpu_program.uniform4f(toon_prog, "color2", 0.1,0.45,0.6,1.0)
gh_gpu_program.uniform4f(toon_prog, "color3", 0.05,0.25,0.4,1.0)
gh_gpu_program.uniform4f(toon_prog, "color4", 0.0,0.0,0.1,1.0)

--[[
gh_gpu_program.uniform4f(toon_prog, "color1", 1.0,0.5,0.5,1.0)
gh_gpu_program.uniform4f(toon_prog, "color2", 0.6,0.3,0.3,1.0)
gh_gpu_program.uniform4f(toon_prog, "color3", 0.4,0.2,0.2,1.0)
gh_gpu_program.uniform4f(toon_prog, "color4", 0.2,0.0,0.0,1.0)
--]]

gh_object.set_euler_angles(mesh, elapsed_time*20, elapsed_time*50, elapsed_time*10)
gh_object.render(mesh)




local BLEND_FACTOR_ZERO = 0
local BLEND_FACTOR_ONE = 1
local BLEND_FACTOR_SRC_ALPHA = 2
local BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 3
local BLEND_FACTOR_ONE_MINUS_DST_COLOR = 4
local BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 5
local BLEND_FACTOR_DST_COLOR = 6
local BLEND_FACTOR_DST_ALPHA = 7
local BLEND_FACTOR_SRC_COLOR = 8
local BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 9

gh_camera.bind(camera_ortho)
gh_gpu_program.bind(texture_prog)
gh_gpu_program.uniform1i(texture_prog, "tex0", 0)
gh_texture.bind(tex0, 0)

gh_renderer.set_depth_test_state(0)
gh_renderer.set_blending_state(1)
gh_renderer.set_blending_factors(BLEND_FACTOR_ONE, BLEND_FACTOR_ONE)
gh_texture.bind(tex0, 0)
gh_object.set_position(quad, winW/2-70, -winH/2 + 60, 0)
gh_object.render(quad)
gh_renderer.set_blending_state(0)

local fps = gfx.get_fps()
local fps_threshold = 20


if (winW >= 380) and (winH >= 330) then
	gfx.write_text_40(winW/2 - 110, 50, 1.0, 1.0, 1.0, 1, "Raspberry Pi")
	gfx.write_text_40(winW/2 - 190, 90, 1.0, 1.0, 1.0, 1, "OpenGL Desktop Test")

	if (fps > fps_threshold) then
	  gfx.write_text_30(winW/2 - 50, winH/2 - 20, 1.0, 1.0, 0.8, 1, "Yeah!")
	  gfx.write_text_30(winW/2 - 180, winH/2 + 10, 1.0, 1.0, 0.8, 1, "Hardware OpenGL enabled!")
	end
end	


if (winW >= 150) and (winH >= 150) then
	gfx.write_text_20(20, winH - 120, 1.0, 1.0, 1.0, 1, "GL_RENDERER")
	gfx.write_text_20(20, winH - 100, 1.0, 1.0, 1.0, 1, "> " .. gpu_name)

	gfx.write_text_20(20, winH - 70, 1.0, 1.0, 1.0, 1, "GL_VERSION")
	gfx.write_text_20(20, winH - 50, 1.0, 1.0, 1.0, 1,  "> " .. opengl_version)
end


local fps = gfx.get_fps()
gfx.write_text(20, winH - 10, 0.8, 0.8, 0.8, 1,  "Framerate: " .. fps .. " FPS")



gfx.end_frame(1)


