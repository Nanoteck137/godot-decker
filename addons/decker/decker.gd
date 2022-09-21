@tool
extends EditorPlugin

var steamdeck_icon = preload("res://addons/decker/Steamdeck.svg")

var custom_panel: PanelContainer
var accept: AcceptDialog
var settings: ConfirmationDialog
var devkit_address: String = ""
var use_debug_mode: bool = false

func _enter_tree():
	var base_control = get_editor_interface().get_base_control();
	var style_box = base_control.get_theme_stylebox("LaunchPadNormal", "EditorStyles").duplicate() as StyleBox;

	custom_panel = PanelContainer.new()
	custom_panel.add_theme_stylebox_override("panel", style_box)

	var steamdeck_button = Button.new()
	steamdeck_button.flat = true
	steamdeck_button.focus_mode = Control.FOCUS_NONE
	steamdeck_button.icon = steamdeck_icon
	steamdeck_button.pressed.connect(func(): settings.popup_centered())

	custom_panel.add_child(steamdeck_button)

	accept = AcceptDialog.new()
	accept.title = "Test"
	custom_panel.add_child(accept)

	settings = ConfirmationDialog.new()
	settings.title = "Deploy"
	settings.ok_button_text = "Deploy"
	settings.confirmed.connect(func(): deploy_steamdeck(devkit_address));
	custom_panel.add_child(settings)

	var container = GridContainer.new()
	container.columns = 2
	settings.add_child(container)

	var address = LineEdit.new()
	address.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	address.custom_minimum_size = Vector2i(200, 30)
	address.text_changed.connect(func(text): devkit_address = text )
	var devkit_address_label = Label.new()
	devkit_address_label.text = "Devkit Address:"
	container.add_child(devkit_address_label)
	container.add_child(address)

	var debug_mode = CheckBox.new()
	debug_mode.button_pressed = use_debug_mode
	debug_mode.toggled.connect(func(t): use_debug_mode = t)
	var debug_mode_label = Label.new()
	debug_mode_label.text = "Debug Build:"
	container.add_child(debug_mode_label)
	container.add_child(debug_mode)

	add_control_to_container(CustomControlContainer.CONTAINER_TOOLBAR, custom_panel)
	custom_panel.get_parent().move_child(custom_panel, -3)

func _exit_tree():
	if custom_panel:
		remove_control_from_container(CustomControlContainer.CONTAINER_TOOLBAR, custom_panel)
		custom_panel.queue_free()

func deploy_steamdeck(devkit_address):
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