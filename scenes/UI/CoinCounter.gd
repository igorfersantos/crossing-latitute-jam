extends HBoxContainer

func _ready():
	var baseLevels = get_tree().get_nodes_in_group("base_level")

	if (baseLevels.size() > 0):
		baseLevels[0].connect("coin_total_changed", self, "on_coin_total_changed")
		update_display(baseLevels[0].total_coins, baseLevels[0].collected_coins)

func update_display(total_coins, collected_coins):
	$CoinLabel.text = str(collected_coins, "/", total_coins)

func on_coin_total_changed(total_coins, collected_coins):
	update_display(total_coins, collected_coins)
