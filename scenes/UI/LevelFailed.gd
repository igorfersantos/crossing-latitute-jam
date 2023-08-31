extends CanvasLayer

onready var play_again_button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/PlayAgainButton
onready var quit_to_menu_button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/QuitToMenuButton


func _ready():
	play_again_button.connect("pressed", self, "on_play_again_button_pressed")
	quit_to_menu_button.connect("pressed", self, "on_quit_to_menu_button_pressed")

func on_play_again_button_pressed():
	$"/root/LevelManager".restart_level()

func on_quit_to_menu_button_pressed():
	$"/root/ScreenTransitionManager".transition_to_scene("res://scenes/UI/MainMenu.tscn")
