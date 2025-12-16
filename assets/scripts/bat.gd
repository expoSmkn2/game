extends CharacterBody2D

const speed = 50
var dir: Vector2

var is_bat_chase: bool

var player: CharacterBody2D

func _ready():
	is_bat_chase = true

func _process(delta):
	move(delta)
	handle_animation()
	
func handle_animation():
	var animated_sprite = $anibat
	animated_sprite.play("fly")
	if dir.x ==  -1:
		animated_sprite.flip_h = true
	if dir.x ==  1:
		animated_sprite.flip_h = false
		

func  move(delta):
	if is_bat_chase:
		player = Global.playerBody
		velocity = position.direction_to(player.position) * speed
		dir.x = abs(velocity.x) / velocity.x
	elif  !is_bat_chase:
		velocity+= dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0])
	if  !is_bat_chase:
		dir = choose ([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])

func choose(array):
	array.shuffle()
	return array.front()
