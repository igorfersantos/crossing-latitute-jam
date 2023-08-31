extends CanvasLayer

onready var continueButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/ContinueButton
onready var optionsButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/OptionsButton
onready var quitToMenuButton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/QuitButton

var optionsMenuScrene = preload("res://scenes/UI/OptionsMenu.tscn")

func _ready():
	continueButton.connect("pressed", self, "on_continue_pressed")
	optionsButton.connect("pressed", self, "on_options_pressed")
	quitToMenuButton.connect("pressed", self, "on_quit_pressed")
	get_tree().paused = true

func _unhandled_input(event):
	if (event.is_action_pressed("pause")):
		unpause()
		get_tree().set_input_as_handled()

func unpause():
	queue_free()
	get_tree().paused = false

func on_continue_pressed():
	unpause()

func on_options_pressed():
	var optionsMenuInstance = optionsMenuScrene.instance()
	add_child(optionsMenuInstance)
	optionsMenuInstance.connect("back_pressed", self, "on_options_back_pressed")
	$MarginContainer.visible = false

func on_options_back_pressed():
	$OptionsMenu.queue_free()
	$MarginContainer.visible = true

func on_quit_pressed():
	$"/root/ScreenTransitionManager".transition_to_menu()
	unpause()
