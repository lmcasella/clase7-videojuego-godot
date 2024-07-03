# Enemy.gd
extends CharacterBody2D

# Velocidad de movimiento del enemigo
var speed = 50
# Dirección a la que se mueve el enemigo
var direction: Vector2
# Dirección y animación que se va a actualizar a lo largo del estado del juego
var new_direction = Vector2(0, 1) # Solo se mueve 1 espacio
var animation
var is_attacking = false

# Se genera un número aleatorio para el timer
var rng = RandomNumberGenerator.new()
# Referencia al timer para redireccionar al enemigo si colisionó o el timer llegó a 0
var timer = 0

# Referencia a la escena del Jugador
@onready var player = get_tree().root.get_node("Main/Player")
@onready var animation_sprite = $AnimatedSprite2D

func _ready():
	rng.randomize()

# Aplicar movimiento al enemigo
func _physics_process(delta):
	var movement = speed * direction * delta
	var collision = move_and_collide(movement)
	
	# Si el enemigo colisiona con otros objetos, se da vuelta y se reinicia el timer
	if collision != null and collision.get_collider().name != "Player":
		# Rotar dirección
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		# Nuevo valor al timer
		timer = rng.randf_range(2, 5)
	# Si colisiona con el jugador,
	# activo la funcion timeout() asi el enemigo puede chasear o moverse hacia el jugador
	else:
		timer = 0
	# Ejecuto animaciones solo si no estoy atacando
	if !is_attacking:
		enemy_animations(direction)

func _on_timer_timeout():
	# Calcular la distancia de la posición relativa del jugador a la del enemigo
	var player_distance = player.position - self.position
	speed = 50
	# Gira hacia el jugador asi puede atacarlo si está dentro del radio
	if player_distance.length() <= 20:
		new_direction = player_distance.normalized()
	elif player_distance.length() <= 100 and timer == 0:
		direction = player_distance.normalized()
	elif timer == 0:
		speed = 30
		# Número aleatorio para la dirección del enemigo
		var random_direction = rng.randf()
		# Esta dirección se obtiene rotando Vector2.DOWN a un ángulo aleatorio
		if random_direction < 0.05:
			# El enemigo para
			direction = Vector2.ZERO
		elif random_direction < 0.1:
			# El enemigo se mueve
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
		
		sync_new_direction()

# Actualizo la dirección del enemigo cada vez que cambia su comportamiento
func sync_new_direction():
	if direction != Vector2.ZERO:
		new_direction = direction.normalized()

# Animaciones
func enemy_animations(direction: Vector2):
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
