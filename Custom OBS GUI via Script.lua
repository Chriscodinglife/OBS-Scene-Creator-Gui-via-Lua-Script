-- Chris O
-- For OBS -- A Script for Setting up predesigned OBS Scenes (or like a template)
-- February 2021

-- REFERENCES: https://obsproject.com/forum/threads/tips-and-tricks-for-lua-scripts.132256/


-- VARIABLES
local logo="place base 64 image data here"
local picture="place base 65 image data here"
local description = [[
<hr/>
<center><h2>Title</h2></center>
<p>
<center><img  width=148 height=84 src=']] .. product .. [['/></center>
<hr/>
<p>
<center><img width=60 height=60 src=']] .. logo .. [['/></center>
<p>
<center>Example Link: <a href="www.google.com">Custom Link</a></center>
<p>Message 1
<p>Message 2
<hr/>
<center><h3> Header 1</h3></center>
<p>
<p>Message 3
<hr/>
</p>]]

-- IMPORT
obs = obslua
local bit = require('bit')


--FUNCTIONS 
function script_description()
    
    return description

end

function scene_exists(scene_name)

	local scene_names = obs.obs_frontend_get_scene_names()
	local scene_list = obs.obs_frontend_get_scenes()
	local value = 0


	for i, name in ipairs(scene_names) do
		if string.find(scene_names[i], scene_name) then
			value = value + 1
		end
	end

	return value
end

function create_scene(scene_name)

	if scene_exists(scene_name) >= 1 then
		scene_name = scene_name .. " " .. scene_exists(scene_name)
	end

	local new_scene = obs.obs_scene_create(scene_name)

	obs.obs_frontend_set_current_scene(obs.obs_scene_get_source(new_scene))
	local current_scene = obs.obs_frontend_get_current_scene()
	local scene = obs.obs_scene_from_source(current_scene)

	obs.obs_scene_release(new_scene)
	obs.obs_scene_release(scene)

	return new_scene, scene

end

function create_looping_background(file_location, name, new_scene)

	local bg_settings = obs.obs_data_create()
	obs.obs_data_set_string(bg_settings, "local_file", script_path() .. file_location)
	obs.obs_data_set_bool(bg_settings, "looping", true)
	local bg_source = obs.obs_source_create("ffmpeg_source", name, bg_settings, nil)
	obs.obs_scene_add(new_scene, bg_source)
	obs.obs_data_release(bg_settings)
	obs.obs_source_release(bg_source)

end

function create_text(face, size, style, text, align, name, scene, x, y)

	local pos = obs.vec2()
	local scale = obs.vec2()

	local text_settings = obs.obs_data_create()
	local text_font_object = obs.obs_data_create_from_json('{}')
	obs.obs_data_set_string(text_font_object, "face", face)
	obs.obs_data_set_int(text_font_object, "flags", 0)
	obs.obs_data_set_int(text_font_object, "size", size)
	obs.obs_data_set_string(text_font_object, "style", style)
	obs.obs_data_set_obj(text_settings, "font", text_font_object)
	obs.obs_data_set_string(text_settings, "text", text)
	obs.obs_data_set_string(text_settings, "align", align)
	local text_source = obs.obs_source_create("text_gdiplus", name, text_settings, nil)
	obs.obs_scene_add(new_scene, text_source)

	local text_sceneitem = obs.obs_scene_find_source(scene, name)
	local text_location = pos
	if text_sceneitem then
		text_location.x = x
		text_location.y = y
		obs.obs_sceneitem_set_pos(text_sceneitem, text_location)
	end

	obs.obs_data_release(text_settings)
	obs.obs_data_release(text_font_object)
	obs.obs_source_release(text_source)

end

function create_image(file_location, name, new_scene, scene, xpos, ypos, xscale, yscale)

	local pos = obs.vec2()
	local scale = obs.vec2()

	local image_settings = obs.obs_data_create()
	obs.obs_data_set_string(image_settings, "file", script_path() .. file_location)
	local image_source = obs.obs_source_create("image_source", name, image_settings, nil)
	obs.obs_scene_add(new_scene, image_source)

	local image_sceneitem = obs.obs_scene_find_source(scene, name)
	local image_location = pos
	local image_scale = scale
	if image_sceneitem then
		image_location.x = xpos
		image_location.y = ypos
		image_scale.x = xscale
		image_scale.y = yscale
		obs.obs_sceneitem_set_pos(image_sceneitem, image_location)
		obs.obs_sceneitem_set_scale(image_sceneitem, image_scale)

	end

	obs.obs_data_release(image_settings)
	obs.obs_source_release(image_source)

end

function create_looping_overlay(file_location, name, new_scene, scene, xpos, ypos, xscale, yscale)

	local pos = obs.vec2()
	local scale = obs.vec2()

	local overlay_settings = obs.obs_data_create()
	obs.obs_data_set_string(overlay_settings, "local_file", script_path() .. file_location)
	obs.obs_data_set_bool(overlay_settings, "looping", true)
	local overlay_source = obs.obs_source_create("ffmpeg_source", name, overlay_settings, nil)
	obs.obs_scene_add(new_scene, overlay_source)

	local overlay_sceneitem = obs.obs_scene_find_source(scene, name)
	local overlay_location = pos
	local overlay_scale = scale
	if overlay_sceneitem then
		overlay_location.x = xpos
		overlay_location.y = ypos
		overlay_scale.x = xscale
		overlay_scale.y = yscale
		obs.obs_sceneitem_set_pos(overlay_sceneitem, overlay_location)
		obs.obs_sceneitem_set_scale(overlay_sceneitem, overlay_scale)
	end

	obs.obs_data_release(overlay_settings)
	obs.obs_source_release(overlay_source)

end

function create_all_scenes()

	create_welcome_scene()
	create_starting_soon_scene()
	create_be_right_back_scene()
	create_thanks_for_watching_scene()
	create_stack_scene()
	create_bar_scene()

	local scene_names = obs.obs_frontend_get_scene_names()
	local scene_list = obs.obs_frontend_get_scenes()
	
	for i, name in ipairs(scene_names) do
		if scene_names[i] == "Welcome" then
			scene = scene_list[i]
			obs.obs_frontend_set_current_scene(scene)
			break
		end
	end

end

function create_welcome_scene()

	new_scene, scene = create_scene("Welcome")

	create_looping_background("Screens/1920x1080x60_Blank_Backdrop_Screen.mp4", "Welcome BG", new_scene)

	create_text("Azonix", 120, "Regular", "Welcome to\nDiagonal Shapes", "center", "Welcome Text", scene, 323, 419)

	create_text("Azonix", 30, "Regular", "Thank you for purchasing our Stream Package!\nPlease find these preset scenes useful\nin getting you ready for your next stream.", "center", "Thank You", scene, 500, 720)

end

function create_starting_soon_scene()

	scene_name = "Starting Soon"
	new_scene, scene = create_scene(scene_name)

	create_looping_background("Screens/1920x1080x60_Starting_Stream_Screen.mp4", scene_name .. " BG", new_scene)

	create_image("Icons/50x50_Facebook_Icon.png", scene_name .. " Icon 1", new_scene, scene, 270, 722, 1, 1)

	create_image("Icons/50x50_Instagram_Icon.png", scene_name .. " Icon 2", new_scene, scene, 770, 722, 1, 1)

	create_image("Icons/50x50_Twitter_Icon.png", scene_name .. " Icon 3", new_scene, scene, 1280, 722, 1, 1)

	create_text("Azonix", 40, "Regular", "@Facebook", "left", scene_name .. " Text 1", scene, 410, 730)

	create_text("Azonix", 40, "Regular", "@Instagram", "left", scene_name .. " Text 2", scene, 900, 730)

	create_text("Azonix", 40, "Regular", "@Twitter", "left", scene_name .. " Text 3", scene, 1420, 730)

end

function create_be_right_back_scene()

	scene_name = "Be Right Back"
	new_scene, scene = create_scene(scene_name)

	create_looping_background("Screens/1920x1080x60_Be_Right_Back_Screen.mp4", scene_name .. " BG", new_scene)

	create_image("Icons/50x50_Facebook_Icon.png", scene_name .. " Icon 1", new_scene, scene, 270, 722, 1, 1)

	create_image("Icons/50x50_Instagram_Icon.png", scene_name .. " Icon 2", new_scene, scene, 770, 722, 1, 1)

	create_image("Icons/50x50_Twitter_Icon.png", scene_name .. " Icon 3", new_scene, scene, 1280, 722, 1, 1)

	create_text("Azonix", 40, "Regular", "@Facebook", "left", scene_name .. " Text 1", scene, 410, 730)

	create_text("Azonix", 40, "Regular", "@Instagram", "left", scene_name .. " Text 2", scene, 900, 730)

	create_text("Azonix", 40, "Regular", "@Twitter", "left", scene_name .. " Text 3", scene, 1420, 730)

end

function create_thanks_for_watching_scene()

	scene_name = "Thanks For Watching"
	new_scene, scene = create_scene(scene_name)

	create_looping_background("Screens/1920x1080x60_Thanks_For_Watching_Screen.mp4", scene_name .. " BG", new_scene)

	create_image("Icons/50x50_Facebook_Icon.png", scene_name .. " Icon 1", new_scene, scene, 270, 722, 1, 1)

	create_image("Icons/50x50_Instagram_Icon.png", scene_name .. " Icon 2", new_scene, scene, 770, 722, 1, 1)

	create_image("Icons/50x50_Twitter_Icon.png", scene_name .. " Icon 3", new_scene, scene, 1280, 722, 1, 1)

	create_text("Azonix", 40, "Regular", "@Facebook", "left", scene_name .. " Text 1", scene, 410, 730)

	create_text("Azonix", 40, "Regular", "@Instagram", "left", scene_name .. " Text 2", scene, 900, 730)

	create_text("Azonix", 40, "Regular", "@Twitter", "left", scene_name .. " Text 3", scene, 1420, 730)

end

function create_stack_scene()

	scene_name = "Game Scene With Support Stack"
	new_scene, scene = create_scene(scene_name)

	create_looping_overlay("Camera_Overlays/1600x1200x60_4-3_Camera_Overlay.webm", scene_name .. " 4:3 Camera Overlay", new_scene, scene, 0, 390, 0.25, 0.25)

	create_looping_overlay("Camera_Overlays/1920x1080x60_16-9_Camera_Overlay.webm", scene_name .. " 16:9 Camera Overlay", new_scene, scene, 0, 405, 0.25, 0.25)

	create_looping_overlay("Support_Overlays/450x160x60_Support_Stack.webm", scene_name .. " Support Stack", new_scene, scene, 0, 690, 1, 1)

	create_image("Icons/50x50_Games_Icon.png", scene_name .. " Icon 1", new_scene, scene, 67, 697, 0.6, 0.6)

	create_image("Icons/50x50_Contacts_Icon.png", scene_name .. " Icon 2", new_scene, scene, 67, 749, 0.6, 0.6)

	create_image("Icons/50x50_Donate_Icon.png", scene_name .. " Icon 3", new_scene, scene, 67, 800, 0.6, 0.6)

	create_text("Azonix", 15, "Regular", "Top Tipper", "left", scene_name .. " Text 1", scene, 110, 708)

	create_text("Azonix", 15, "Regular", "New Follow", "left", scene_name .. " Text 2", scene, 110, 758)

	create_text("Azonix", 15, "Regular", "New Tip", "left", scene_name .. " Text 3", scene, 110, 809)

end

function create_bar_scene()

	scene_name = "Game Scene With Support Bar"
	new_scene, scene = create_scene(scene_name)

	create_looping_overlay("Camera_Overlays/1600x1200x60_4-3_Camera_Overlay.webm", scene_name .. " 4:3 Camera Overlay", new_scene, scene, 0, 390, 0.25, 0.25)

	create_looping_overlay("Camera_Overlays/1920x1080x60_16-9_Camera_Overlay.webm", scene_name .. " 16:9 Camera Overlay", new_scene, scene, 0, 405, 0.25, 0.25)

	create_looping_overlay("Support_Overlays/1920x90x60_Long_Support Bar.webm", scene_name .. " Long Support Bar", new_scene, scene, 0, 990, 1, 1)

	create_looping_overlay("Support_Overlays/960x90x60_Mini_Support_Bar.webm", scene_name .. " Mini Support Bar", new_scene, scene, 480, 0, 1, 1)

	create_image("Icons/50x50_Facebook_Icon.png", scene_name .. " Icon 1", new_scene, scene, 182, 1008, 0.6, 0.6)

	create_image("Icons/50x50_Games_Icon.png", scene_name .. " Icon 2", new_scene, scene, 550, 1010, 1, 1)

	create_image("Icons/50x50_Donate_Icon.png", scene_name .. " Icon 3", new_scene, scene, 1100, 1010, 1, 1)

	create_image("Icons/50x50_Instagram_Icon.png", scene_name .. " Icon 4", new_scene, scene, 1711, 1008, 0.6, 0.6)

	create_text("Azonix", 30, "Regular", "@Facebook", "left", scene_name .. " Text 1", scene, 257, 1020)

	create_text("Azonix", 30, "Regular", "@Instagram", "left", scene_name .. " Text 2", scene, 1452, 1020)

end

function script_properties()
	local properties = obs.obs_properties_create()
	
	--buttons
	local create_all_scenes_btn = obs.obs_properties_add_button(properties, "create_all_scenes", "Import All Scenes", create_all_scenes)
	obs.obs_property_set_long_description(create_all_scenes_btn, "Insert all available scenes from this kit to your current OBS Session.")

	local create_welcome_scene_btn = obs.obs_properties_add_button(properties, "create_welcome_scene", "Import Welcome Scene", create_welcome_scene)
	obs.obs_property_set_long_description(create_welcome_scene_btn, "Insert the Welcome scene to your OBS Session.")

	local create_starting_soon_scene_btn = obs.obs_properties_add_button(properties, "create_starting_soon_scene", "Import Starting Soon Scene", create_starting_soon_scene)
	obs.obs_property_set_long_description(create_starting_soon_scene_btn, "Insert the Starting Soon scene to your OBS Session.")

	local create_be_back_scene_btn = obs.obs_properties_add_button(properties, "create_be_back_scene", "Import Be Right Back Scene", create_be_right_back_scene)
	obs.obs_property_set_long_description(create_be_back_scene_btn, "Insert the Be Right Back scene to your OBS Session.")

	local create_later_scene_btn = obs.obs_properties_add_button(properties, "create_later_scene", "Import Thanks For Watching Scene", create_thanks_for_watching_scene)
	obs.obs_property_set_long_description(create_later_scene_btn, "Insert the Thanks For Watching scene to your OBS Session.")

	local create_game_stack_scene_btn = obs.obs_properties_add_button(properties, "create_game_stack_scene", "Import Game Scene With Support Stack", create_stack_scene)
	obs.obs_property_set_long_description(create_game_stack_scene_btn, "Insert the Game with Support Stack scene to your OBS Session.")

	local create_game_bar_scene_btn = obs.obs_properties_add_button(properties, "create_game_bar_scene", "Import Game Scene With Support Bar", create_bar_scene)
	obs.obs_property_set_long_description(create_game_bar_scene_btn, "Insert the Game with Support Bar scene to your OBS Session.")

	return properties

end