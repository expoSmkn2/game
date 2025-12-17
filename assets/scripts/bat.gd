extends CharacterBody2D

class_name BatEnemy

const speed = 50
var dir: Vector2

var is_bat_chase: bool

var player: CharacterBody2D

@export var damage_to_deal = 20
@export var health = 40
@export var health_max = 40
@export var health_min = 0

var dead = false
var taking_damage = false
var is_roaming: bool
var death_complete = false  # Tambah flag untuk track kematian selesai

func _ready():
	is_bat_chase = true
	# Hapus timer dari sini karena kondisi dead awal false

func _process(delta):
	Global.batDamageAmount = damage_to_deal
	Global.batDamageZone = $batDealDamageArea
	
	if Global.playerAlive:
		is_bat_chase = true
	elif !Global.playerAlive:
		is_bat_chase = false
	
	move(delta)
	handle_animation()
	
func handle_animation():
	var animated_sprite = $anibat
	
	# Jika sudah mati dan animasi selesai, langsung return
	if death_complete:
		return
	
	if !dead:
		if !taking_damage:
			animated_sprite.play("fly")
			if dir.x ==  -1:
				animated_sprite.flip_h = true
			if dir.x ==  1:
				animated_sprite.flip_h = false
		elif taking_damage:
			animated_sprite.play("hurt")
			await get_tree().create_timer(0.8).timeout
			taking_damage = false
	else:
		# Play animasi death hanya sekali
		if animated_sprite.animation != "death":
			animated_sprite.play("death")
		else:
			# Cek jika animasi death sudah selesai
			if !animated_sprite.is_playing():
				death_complete = true
				is_roaming = false
				set_collision_layer_value(1, true)
				set_collision_layer_value(2, false)
				set_collision_mask_value(1, true)
				set_collision_mask_value(2, false)
				
				# Setelah animasi selesai, mulai timer untuk menghapus node
				await get_tree().create_timer(2.0).timeout
				self.queue_free()

func move(delta):
	player = Global.playerBody
	if !dead:
		if is_bat_chase:
			if !taking_damage:
				velocity = position.direction_to(player.position) * speed
				dir.x = abs(velocity.x) / velocity.x
			elif taking_damage:
				var knockback_dir = (position.direction_to(player.position) * -50) * 1.5
				velocity = knockback_dir
		elif !is_bat_chase:
			velocity+= dir * speed * delta
	elif dead:
		velocity.y += 12 * delta  # Gravity effect
		velocity.x = 0
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
		
		# Jika sudah menyentuh ground, langsung hapus
		if is_on_floor() and !death_complete:
			death_complete = true
			await get_tree().create_timer(0.5).timeout  # Tunggu sebentar di ground
			self.queue_free()
	
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0])
	if  !is_bat_chase:
		dir = choose ([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])

func choose(array):
	array.shuffle()
	return array.front()

func _on_bat_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		var damage = Global.playerDamageAmount
		take_damage(damage)
		
func take_damage(damage):
	if dead:  # Jangan terima damage jika sudah mati
		return
		
	health -= damage
	taking_damage = true
	
	if health <= 0:
		health = 0
		dead = true
		taking_damage = false  # Pastikan tidak dalam state hurt saat mati
	
	print(str(self), "current health is ", health)
