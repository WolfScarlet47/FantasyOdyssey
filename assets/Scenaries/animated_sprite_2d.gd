extends AnimatedSprite2D

const RAPIDEZ: float = 200.0
const TAMANO_MAPA: Vector2 = Vector2(2160.0, 1440.0)
const MARGEN_LIMITE: float = 32.0
const VIDA_MAXIMA: float = 100.0
const DANIO_POR_SEGUNDO: float = 5.0
const ALCANCE_DISPARO: float = 250.0
const MAX_ENEMIGOS: int = 10

const ESCENA_ENEMIGO: PackedScene = preload("res://assets/Scenaries/enemy.tscn")
const ESCENA_PROYECTIL: PackedScene = preload("res://assets/Scenaries/projectile.tscn")

var vida: float = VIDA_MAXIMA
var enemigos_en_contacto: Array[Area2D] = []
var barra_vida: TextureProgressBar
var generador_aleatorio := RandomNumberGenerator.new()


func _ready() -> void:
	barra_vida = get_node("../HealthHUD/HealthBar") as TextureProgressBar
	$DamageArea.area_entered.connect(_on_damage_area_entered)
	$DamageArea.area_exited.connect(_on_damage_area_exited)
	generador_aleatorio.randomize()
	_actualizar_barra_vida()

	# Los dos temporizadores funcionan por separado y esperan 10 segundos.
	_crear_temporizador(10.0, _disparar_al_enemigo_mas_cercano)
	_crear_temporizador(10.0, _crear_enemigo)


func _process(delta: float) -> void:
	# Si Zuo ha muerto, no puede moverse ni recibir más daño.
	if vida <= 0.0:
		return

	# Movimiento del personaje.
	var x: float = Input.get_axis("ui_left", "ui_right")
	var y: float = Input.get_axis("ui_up", "ui_down")
	var direccion: Vector2 = Vector2(x, y).normalized()
	position += direccion * RAPIDEZ * delta

	# Mantiene al personaje dentro de los límites del mapa.
	position.x = clampf(position.x, MARGEN_LIMITE, TAMANO_MAPA.x - MARGEN_LIMITE)
	position.y = clampf(position.y, MARGEN_LIMITE, TAMANO_MAPA.y - MARGEN_LIMITE)

	# Si un enemigo está tocando a Zuo, le resta vida poco a poco.
	if not enemigos_en_contacto.is_empty():
		vida = maxf(0.0, vida - DANIO_POR_SEGUNDO * delta)
		_actualizar_barra_vida()
		if vida <= 0.0:
			visible = false
			$DamageArea.set_deferred("monitoring", false)


# Crea un temporizador independiente para cada acción automática.
func _crear_temporizador(intervalo: float, accion: Callable) -> void:
	var temporizador := Timer.new()
	temporizador.wait_time = intervalo
	temporizador.timeout.connect(accion)
	add_child(temporizador)
	temporizador.start()


# Busca el enemigo más cercano que esté dentro de los 250 píxeles.
func _disparar_al_enemigo_mas_cercano() -> void:
	if vida <= 0.0 or not visible:
		return

	var enemigo_cercano: Area2D
	var distancia_menor: float = ALCANCE_DISPARO

	for nodo in get_tree().get_nodes_in_group("enemies"):
		var enemigo := nodo as Area2D
		if not is_instance_valid(enemigo):
			continue

		var distancia := global_position.distance_to(enemigo.global_position)
		if distancia <= distancia_menor:
			distancia_menor = distancia
			enemigo_cercano = enemigo

	# Si no hay enemigos cerca, este disparo se omite.
	if not is_instance_valid(enemigo_cercano):
		return

	var proyectil := ESCENA_PROYECTIL.instantiate() as Area2D
	get_parent().add_child(proyectil)
	proyectil.global_position = global_position
	proyectil.launch(global_position.direction_to(enemigo_cercano.global_position))


# Crea enemigos alrededor de Zuo sin superar el máximo de diez.
func _crear_enemigo() -> void:
	if vida <= 0.0 or not visible:
		return

	if get_tree().get_nodes_in_group("enemies").size() >= MAX_ENEMIGOS:
		return

	# Prueba varias posiciones para encontrar una que quede dentro del mapa.
	for intento in range(20):
		var angulo := generador_aleatorio.randf_range(0.0, TAU)
		var distancia := generador_aleatorio.randf_range(500.0, 750.0)
		var posicion := global_position + Vector2.RIGHT.rotated(angulo) * distancia

		if posicion.x < MARGEN_LIMITE or posicion.x > TAMANO_MAPA.x - MARGEN_LIMITE:
			continue
		if posicion.y < MARGEN_LIMITE or posicion.y > TAMANO_MAPA.y - MARGEN_LIMITE:
			continue

		var enemigo := ESCENA_ENEMIGO.instantiate() as Area2D
		get_parent().add_child(enemigo)
		enemigo.global_position = posicion
		return


# Añade a la lista los enemigos que entran en contacto con Zuo.
func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and not enemigos_en_contacto.has(area):
		enemigos_en_contacto.append(area)


# Quita de la lista a los enemigos que dejan de tocar a Zuo.
func _on_damage_area_exited(area: Area2D) -> void:
	enemigos_en_contacto.erase(area)


# Actualiza la barra de vida.
func _actualizar_barra_vida() -> void:
	if is_instance_valid(barra_vida):
		barra_vida.value = vida
