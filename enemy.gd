extends CharacterBody2D

@onready var shield_light: PointLight2D = $DarknessShield/PointLight2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var shield_strength = 100.0 # 100% shield
var max_shield_strength = 100.0
var is_shield_active = true
@export() var shield_weakening_rate = 30 # percentage weakened per second

var health = 100.0

enum State {IDLE, CHASING, ATTACKING}
var state := State.IDLE

# Movement variables
@export var speed := 100.0

# Attack variables
@export var damage := 10
@export var attack_cooldown := 1.0 # Time in seconds between attacks
var attack_timer := 0.0

@onready var player_detection_area: Area2D = $PlayerDetectionArea
var player: Player = null

@onready var attack_area: Area2D = $AttackArea

func _ready() -> void:
	player_detection_area.connect("body_entered", _on_PlayerDetectionArea_body_entered)
	player_detection_area.connect("body_exited", _on_PlayerDetectionArea_body_exited)

	attack_area.connect("body_entered", _on_AttackArea_body_entered)
	attack_area.connect("body_exited", _on_AttackArea_body_exited)

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			idle_behavior(delta)
		State.CHASING:
			chase_behavior(delta)
		State.ATTACKING:
			attacking_behavior(delta)

func _process(_delta: float) -> void:
	var shield_energy = shield_strength / max_shield_strength
	shield_light.energy = shield_energy

func idle_behavior(_delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()

func chase_behavior(_delta: float) -> void:
	if player:
		navigation_agent.target_position = player.global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * speed
		move_and_slide()
	else:
		state = State.IDLE

func attacking_behavior(delta: float) -> void:
	attack_timer -= delta
	if attack_timer <= 0:
		perform_attack()
		attack_timer = attack_cooldown
	
	velocity = Vector2.ZERO
	move_and_slide()

func perform_attack() -> void:
	if player:
		player.take_damage(damage)

func _on_PlayerDetectionArea_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		state = State.CHASING

func _on_PlayerDetectionArea_body_exited(body: Node) -> void:
	if body == player:
		player = null
		state = State.IDLE

func _on_AttackArea_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		state = State.ATTACKING

func _on_AttackArea_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if player_detection_area.get_overlapping_bodies().has(body):
			state = State.CHASING
		else:
			state = State.IDLE

func weaken_shield(delta: float) -> void:
	if is_shield_active:
		shield_strength -= shield_weakening_rate * delta
		shield_strength = clamp(shield_strength, 0, max_shield_strength)
		if shield_strength <= 0:
			is_shield_active = false


func take_damage(amount: float) -> void:
	if not is_shield_active:
		health -= amount
		if health <= 0:
			die()
	else:
		pass

func die() -> void:
	queue_free()
