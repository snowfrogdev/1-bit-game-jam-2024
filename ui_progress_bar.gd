extends ProgressBar

func _on_battery_level_changed(battery_level: float) -> void:
	value = battery_level * 100
