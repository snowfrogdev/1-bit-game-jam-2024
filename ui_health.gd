extends ProgressBar


func _on_health_level_changed(health_level: float) -> void:
	value = health_level * 100
