extends CharacterBody2D

@onready var shield_light: PointLight2D = $DarknessShield/PointLight2D

var shield_strength = 100.0 # 100% shield
var max_shield_strength = 100.0
var is_shield_active = true
@export() var shield_weakening_rate = 30 # percentage weakened per second

var health = 100.0

func weaken_shield(delta: float) -> void:
	if is_shield_active:
		shield_strength -= shield_weakening_rate * delta
		shield_strength = clamp(shield_strength, 0, max_shield_strength)
		if shield_strength <= 0:
			is_shield_active = false


func _process(_delta: float) -> void:
	var shield_energy = shield_strength / max_shield_strength
	shield_light.energy = shield_energy

func take_damage(amount: float) -> void:
	if not is_shield_active:
		health -= amount
		if health <= 0:
			die()
	else:
		pass

func die() -> void:
	queue_free()