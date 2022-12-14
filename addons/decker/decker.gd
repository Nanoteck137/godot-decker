@tool
extends EditorPlugin

var steamdeck_icon = preload("res://addons/decker/Steamdeck.svg")
var gui_scene = preload("res://addons/decker/scenes/Gui.tscn")

var gui: Gui

func _enter_tree():
	gui = gui_scene.instantiate()
	gui.deploy.connect(func(devkit_address, use_debug_mode): deploy_steamdeck(devkit_address, use_debug_mode))
	add_control_to_container(CustomControlContainer.CONTAINER_TOOLBAR, gui)
	gui.get_parent().move_child(gui, -3)

func _exit_tree():
	remove_control_from_container(CustomControlContainer.CONTAINER_TOOLBAR, gui)
	gui.queue_free()

func deploy_steamdeck(devkit_address, use_debug_mode):
	get_editor_interface().save_scene()
	var project_path = ProjectSettings.globalize_path("res://")

	var dir = Directory.new()
	var err = dir.open("res://")
	if err == OK:
		dir.make_dir("export")
	print(error_string(err))

	var args = [];
	args.push_back("--export")
	args.push_back("Linux/X11")
	args.push_back("export/linux.x86_64")
	args.push_back("--path")
	args.push_back(project_path)
	args.push_back("--headless")

	OS.execute(OS.get_executable_path(), args)
	
	var game_id = ProjectSettings.get("application/config/name")
	var export_path = ProjectSettings.globalize_path("res://export")

	var decker_args = []
	decker_args.push_back("-d");
	decker_args.push_back(devkit_address);
	decker_args.push_back("deploy");
	decker_args.push_back(game_id);
	decker_args.push_back("linux.x86_64");
	decker_args.push_back(export_path);

	var exitcode = OS.execute("decker", decker_args)
	if exitcode != 0:
		print("Failed to execute 'decker'")
	else:
		print("Deployment successful")