extends Spatial

onready var ray_cast = get_parent().get_node("Camera/RayCast3D")
onready var inventory = $Inventory
onready var context_inventory = $ContextInventory
onready var settings = $Settings
onready var scope = $Scope


func _ready():
	inventory.hide()
	context_inventory.hide()
	settings.hide()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_scope_visibility()

	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat_settings.connect(
		"value_changed_gui_scope", self, "_on_scope_settings_changed"
	)

func _input(event):
	if goat.game_mode != goat.GameMode.EXPLORING:
		return
	
	if Input.is_action_just_pressed("goat_toggle_inventory"):
		goat.game_mode = goat.GameMode.INVENTORY
		get_parent().deactivate()
	
	if Input.is_action_just_pressed("goat_dismiss"):
		goat.game_mode = goat.GameMode.SETTINGS

func update_scope_visibility():
	scope.visible = (
		goat.game_mode == goat.GameMode.EXPLORING and
		goat_settings.get_value("gui", "scope")
	)

func _on_game_mode_changed(new_game_mode):
	var exploring_mode = new_game_mode == goat.GameMode.EXPLORING
	var inventory_mode = new_game_mode == goat.GameMode.INVENTORY
	var settings_mode = new_game_mode == goat.GameMode.SETTINGS
	var context_inventory_mode = new_game_mode == goat.GameMode.CONTEXT_INVENTORY
	scope.visible = exploring_mode
	ray_cast.enabled = exploring_mode
	
	update_scope_visibility()
	var camera = get_viewport().get_camera()
	camera.environment.dof_blur_far_enabled = inventory_mode
	
	if exploring_mode:
		get_parent().activate()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if settings_mode or context_inventory_mode:
		get_parent().deactivate()

func _on_scope_settings_changed():
	update_scope_visibility()
