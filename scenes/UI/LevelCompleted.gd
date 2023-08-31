extends CanvasLayer

onready var next_level_button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/NextLevelButton
onready var quit_to_menu_button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/QuitToMenuButton


func _ready():
	next_level_button.connect("pressed", self, "on_next_level_buttonn_pressed")
	quit_to_menu_button.connect("pressed", self, "on_quit_to_menu_button_pressed")

func on_next_level_buttonn_pressed():
	$"/root/LevelManager".change_to_next_level()

func on_quit_to_menu_button_pressed():
	$"/root/ScreenTransitionManager".transition_to_scene("res://scenes/UI/MainMenu.tscn")
