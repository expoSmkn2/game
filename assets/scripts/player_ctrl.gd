extends CharacterBody2D

@onready var animation = $animator/animation
@onready var deal_damage_zone = $DealDamageZone

@export var w_speed = 150
<<<<<<< HEAD
@export var l_speed = 20
@export var a_speed = 75
@export var dash = 400

var can_dash = true
var dashing = false
=======
@export var l_speed = 50
@export var a_speed = 75
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
var speed = 150
var speed_atk = 0 
const  jump_power = -290

var gravity = 900
var was_running = false

var is_light_attack := false
var is_heavy_attack := false

var is_double_jump_attack := false

var attack_type: String
var current_attack: bool

<<<<<<< HEAD
func _physics_process(delta):
	if !is_on_floor():
=======

func _physics_process(delta):
	if not is_on_floor():
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
<<<<<<< HEAD
		
=======
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
	
	if Input.is_action_just_pressed("jump") and !is_on_floor() and !is_double_jump_attack:
		velocity.y = jump_power / 1.25
		is_double_jump_attack = true
	
<<<<<<< HEAD
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		$animator/dashTime.start()
		$animator/dashCooldown.start()
		animation.play("dash")
	
	var current_dir := 1
	var  direction = Input.get_axis("left", "right")
	
	if direction != 0:
		current_dir = sign(direction)
	if direction:
		if dashing:
			velocity.x = current_dir * dash
		else:
			velocity.x = direction * speed
	else: 
		velocity.x = move_toward(velocity.x, 0, speed)
	
=======
	var  direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else: 
		velocity.x = move_toward(velocity.x, 0, speed)
		
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
	if !current_attack:
		if Input.is_action_just_pressed("M2") and is_on_floor():
			current_attack = true
			is_heavy_attack = true
			attack_type = "heavy_attack"

		elif Input.is_action_just_pressed("M1") and is_on_floor():
			current_attack = true
			is_light_attack = true
			attack_type = "light_attack"
	
		elif Input.is_action_just_pressed("M1") and !is_on_floor() and !is_double_jump_attack:
			current_attack = true
			is_light_attack = true
			is_double_jump_attack = true
			attack_type = "air"
			velocity.y = jump_power / 1.25
		
<<<<<<< HEAD
=======
		

>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
	if current_attack:
		handle_attack_animation(attack_type)
		Global.playerBody = self
		
	if is_on_floor() and !current_attack:
		is_double_jump_attack = false
		if abs(velocity.x) > 1:
<<<<<<< HEAD
			if dashing:
				animation.play("dash")
			else:
				animation.play("run")
		else:
			animation.play("idle")
		if Input.is_action_just_pressed("jump"):
			animation.play("jump")
		
	move_and_slide()
	handle_movement_animation(direction)
=======
			animation.play("run")
		else:
			animation.play("idle")
	
	move_and_slide()
	handle_movement_animation(direction)
	
	
	
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
func _ready():
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	Global.playerBody = self
	current_attack = false
	
func _on_animation_finished():
	if animation.animation in ["light_attack", "heavy_attack", "air"]:
		current_attack = false
		is_light_attack = false
		is_heavy_attack = false
		speed = (speed * speed_atk) + w_speed

		if is_on_floor():
			animation.play("idle")
		else:
			animation.play("fall")
<<<<<<< HEAD
	
=======
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
func handle_movement_animation(dir):
	if is_heavy_attack:
		return

	if current_attack and is_light_attack and !is_on_floor():
		return
	toggle_flip_sprite(dir)
<<<<<<< HEAD
	
=======
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
func toggle_flip_sprite(dir):
	if dir == 1:
		animation.flip_h = false
	if dir == -1:
		animation.flip_h = true
		
<<<<<<< HEAD
func handle_attack_animation(_attack_type):
=======

func handle_attack_animation(attack_type):
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
	if current_attack:
		speed = speed * speed_atk
		var anim = str(attack_type)
		animation.play(anim)
		if str(attack_type) == "light_attack":
			speed = l_speed
<<<<<<< HEAD
		
func _on_dash_time_timeout() -> void:
	dashing = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
=======
		elif str(attack_type) == "air":
			speed = a_speed
>>>>>>> 61aee4f2655cbbf50bdd94a2031b5b8c5662b045
