# Player.gd
extends CharacterBody2D
# Node references
@onready var animation_sprite = $AnimatedSprite2D

# Velocidad de movimiento del jugador
@export var speed = 50
var new_direction = 0
var animation = 0
var is_attacking = false

func _physics_process(delta):
	# Inputs del jugador (left, right, up, down)
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Si el input es digital, se normaliza para movimientos diagonales
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	if Input.is_action_pressed("ui_sprint"):
		speed = 100
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50
	
	# Aplicar movimiento
	var movement = speed * direction * delta
	
	if is_attacking == false:
		# Se mueve el personaje y cuando choca con objetos que tengan colision también colisiona
		move_and_collide(movement)
		# Ejecutar animaciones
		player_animations(direction)
	# Si no estoy presionando ninguna tecla, devuelve animación idle
	if !Input.is_anything_pressed():
		if is_attacking == false:
			animation = "idle"
			animation_sprite.play(animation)

func _input(event):
	# Input para atacar
	if event.is_action_pressed("ui_attack"):
		# Animación de ataque
		is_attacking = true
		animation = "attack"
		animation_sprite.play(animation)

# Animaciones
func player_animations(direction: Vector2):
	# Vector2.ZERO es la manera corta de escribir Vector2(0, 0)
	if direction != Vector2.ZERO:
		# direction es new_direction
		new_direction = direction
		# Nos estamos moviendo, asi que ejecuto la animacion walk
		animation = returned_direction_walk(new_direction)
		animation_sprite.play(animation)
	else:
		# Ejecutar animación idle porque estamos quietos
		animation = "idle"
		animation_sprite.play(animation)

# Direccion de Animaciones
func returned_direction_walk(direction: Vector2):
	# Normaliza la dirección del vector
	var normalized_direction = direction.normalized()
	var default_return = "walk"
	
	if normalized_direction.x > 0:
		# Derecha
		animation_sprite.flip_h = false
	elif normalized_direction.x < 0:
		# Izquierda
		animation_sprite.flip_h = true
	
	# Valor por default es la animación walk
	return default_return

# Resetear animación de ataque
func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
