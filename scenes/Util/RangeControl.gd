extends HBoxContainer

signal percentage_changed

var currentPercentange = 1.0

func _ready():
	$SubtractButton.connect("pressed", self, "on_button_pressed", [-0.1])
	$AddButton.connect("pressed", self, "on_button_pressed", [0.1])

func set_current_percentage(percent):
	currentPercentange = clamp(percent, 0, 1)
	
	var labelNumber = currentPercentange * 10
	labelNumber = round(labelNumber)
	
	$Label.text = str(labelNumber)
	emit_signal("percentage_changed", currentPercentange)

func on_button_pressed(change):
	set_current_percentage(currentPercentange + change)
