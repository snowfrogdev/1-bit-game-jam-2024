extends CharacterBody2D

@export var speed := 1000
@export var damage := 25
var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		if collision.get_collider().is_in_group("enemy"):
			collision.get_collider().take_damage(damage)
		queue_free()

func _on_screen_exited():
	queue_free() # Destroy the bullet when it exits the screen
