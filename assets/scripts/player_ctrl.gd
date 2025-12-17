extends CharacterBody2D

@onready var animation = $animator/animation
@onready var deal_damage_zone = $DealDamageZone

@export var base_speed: float = 150.0
@export var la_speed: float = 20.0
@export var air_speed: float = 75.0
@export var dash: float = 400

@export var health: float = 100
@export var max_health = 100
var min_health = 0
var can_take_damage: bool
var dead: bool

var speed: float = base_speed
var can_dash = true
var dashing = false
const  jump_power = -290

var gravity = 900
var was_running = false

var is_light_attack := false
var is_heavy_attack := false

var is_double_jump_attack := false

var attack_type: String
var current_attack: bool

func _physics_process(delta):
	Global.playerDamageZone = deal_damage_zone
		
	if !is_on_floor():
		velocity.y += gravity * delta
	
	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_power
		
		if Input.is_action_just_pressed("dash") and can_dash:
			dashing = true
			can_dash = false
			$animator/dashTime.start()
			$animator/dashCooldown.start()
			animation.play("dash")
		
		var direction = Input.get_axis("left", "right")
		if direction:
			if !dashing:
				velocity.x = direction * speed
			else:
				velocity.x = direction * dash
		else: 
			velocity.x = 0.0
		
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
			
		if current_attack:
			set_damage(attack_type)
			handle_attack_animation(attack_type)
			Global.playerBody = self
			
		if is_on_floor() and !current_attack:
			is_double_jump_attack = false
			if abs(velocity.x) > 1:
				if dashing:
					animation.play("dash")
				else:
					animation.play("run")
			else:
				animation.play("idle")
			if Input.is_action_just_pressed("jump"):
				animation.play("jump")
		handle_movement_animation(direction)
		check_hitbox()
	move_and_slide()
	
func check_hitbox():
	var hitbox_areas = $playerHitbox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is BatEnemy:
			damage = Global.batDamageAmount
			
	if can_take_damage:
		take_damage(damage)
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			print("player health: ", health)
			if health <= 0:
				health = 0
				dead = true
				Global.playerAlive = false
				handle_death_animation()
			take_damage_cooldown(1.0)
		
func handle_death_animation():
	$Hitbox.position.y = 5
	animation.play("die")
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 4
	$Camera2D.zoom.y = 4
	self.queue_free()
		
func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true
	
func _ready():
	animation.connect("animation_finished", Callable(self, "_on_animation_finished"))
	Global.playerBody = self
	current_attack = false
	dead = false
	can_take_damage = true
	Global.playerAlive = true
	
func _on_animation_finished():
	if animation.animation in ["light_attack", "heavy_attack", "air"]:
		current_attack = false
		is_light_attack = false
		is_heavy_attack = false
		speed = base_speed

		if is_on_floor():
			animation.play("idle")
		else:
			animation.play("fall")
			
func handle_movement_animation(dir):
	if is_heavy_attack:
		return

	if current_attack and is_light_attack and !is_on_floor():
		return
	toggle_flip_sprite(dir)
	
func toggle_flip_sprite(dir):
	if dir == 1:
		animation.flip_h = false
		deal_damage_zone.scale.x = 1
	if dir == -1:
		animation.flip_h = true
		deal_damage_zone.scale.x = -1
		
func handle_attack_animation(_attack_type):
	if current_attack:
		speed = 0.0
		var anim = str(attack_type)
		animation.play(anim)
		if str(attack_type) == "light_attack":
			speed = la_speed
		toggle_damage_collisions(_attack_type)
		
func toggle_damage_collisions(_attack_type):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float 
	if attack_type == "air":
		wait_time = 0.6
	elif attack_type == "light_attack":
		wait_time = 0.4
	elif attack_type == "heavy_attack":
		wait_time = 1
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func _on_dash_time_timeout() -> void:
	dashing = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func set_damage(_attack_type):
	var current_damage_to_deal: int
	if attack_type == "light_attack":
		current_damage_to_deal = 12
	elif attack_type == "heavy_attack":
		current_damage_to_deal = 25
	elif attack_type == "air":
		current_damage_to_deal = 10
	Global.playerDamageAmount = current_damage_to_deal
