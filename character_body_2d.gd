extends CharacterBody2D

@export var speed = 300.0

@onready var flashlight: PointLight2D = $Flashlight

# Battery properties
@export var battery_drain_speed = 20.0 # percentage drained per second
@export var battery_recharge_speed = 50.0 # percentage recharged per second
var battery_level = 100.0 # 100% battery
var max_battery_level = 100.0
var min_battery_level = 0.0
var is_boosting = false
signal battery_level_changed(battery_level: float)


func _physics_process(delta: float) -> void:
	get_input()
	update_flashlight()
	update_battery(delta)
	move_and_slide()

func _process(_delta):
	point_flashlight_towards_mouse()
	# var mouse_direction = get_global_mouse_position() - global_position
	# var angle_to_velocity = velocity.angle_to(mouse_direction)

	# if velocity.length() > 0:
	# 	if abs(angle_to_velocity) < strafe_threshold:
	# 		# Walking forward
			
	# 		feet_animated_sprite.play("walk_forewards")
	# 		flashlight_animated_sprite.play("move")
	# 	elif angle_to_velocity > strafe_threshold and angle_to_velocity < backward_threshold:
	# 		# Strafing right
	# 		feet_animated_sprite.play("strafe_right")
	# 		flashlight_animated_sprite.play("move")
	# 	elif angle_to_velocity < -strafe_threshold and angle_to_velocity > -backward_threshold:
	# 		# Strafing left
	# 		feet_animated_sprite.play("strafe_left")
	# 		flashlight_animated_sprite.play("move")
	# 	elif abs(angle_to_velocity) >= backward_threshold:
	# 		# Moving backward
	# 		feet_animated_sprite.play("walk_backwards")  # Play the same walk animation, but you can add a backward one if needed
	# 		flashlight_animated_sprite.play("move")
	# else:
	# 	# If the player is not moving, play idle animation
	# 	feet_animated_sprite.play("idle")
	# 	flashlight_animated_sprite.play("idle")

func get_input():
	if Input.is_action_pressed("Boost Flashlight") and battery_level > min_battery_level:
		is_boosting = true
	else:
		is_boosting = false

	var input_direction = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	#look_at(get_global_mouse_position())
	velocity = input_direction * speed

func update_flashlight():
	if is_boosting:
		flashlight.scale = Vector2(1, 0.5)
		flashlight.scale.y *= battery_level / max_battery_level
		flashlight.energy = 4
	else:
		flashlight.scale = Vector2(1, 1)
		flashlight.energy = 1

	flashlight.energy *= battery_level / max_battery_level

func update_battery(delta: float) -> void:
	var previous_battery_level = battery_level
	if is_boosting:
		battery_level = clamp(battery_level - battery_drain_speed * delta, min_battery_level, max_battery_level)
		if battery_level == min_battery_level:
			is_boosting = false
	else:
		battery_level = clamp(battery_level + battery_recharge_speed * delta, min_battery_level, max_battery_level)

	if previous_battery_level != battery_level:
		battery_level_changed.emit(battery_level / max_battery_level)

func point_flashlight_towards_mouse():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - flashlight.global_position).normalized()
	var angle = direction.angle() + PI
	flashlight.rotation = angle