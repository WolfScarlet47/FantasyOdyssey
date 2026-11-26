extends Node

signal boss_fight_ready

const TOTAL_WAVES: int = 10
const MAX_ENEMIES_ON_SCREEN: int = 25
const MAP_SIZE: Vector2 = Vector2(2160.0, 1440.0)
const EDGE_MARGIN: float = 32.0
const SPAWN_DISTANCE_MIN: float = 500.0
const SPAWN_DISTANCE_MAX: float = 750.0
const INTERMISSION_SECONDS: float = 3.0

@export var spawn_interval: float = 0.8
@export var player_path: NodePath = NodePath("../Character")
@export var counter_path: NodePath = NodePath("../HealthHUD/WaveCounter")

const ENEMY_SCENE: PackedScene = preload("res://assets/Scenaries/enemy.tscn")

var player: Node2D
var counter: Label
var spawn_timer: Timer
var random_generator := RandomNumberGenerator.new()

var current_wave: int = 1
var enemies_in_wave: int = 10
var enemies_spawned: int = 0
var enemies_defeated: int = 0
var waiting_for_next_wave: bool = false
var boss_phase_started: bool = false


func _ready() -> void:
	player = get_node_or_null(player_path) as Node2D
	counter = get_node_or_null(counter_path) as Label
	random_generator.randomize()

	if player == null:
		push_error("WaveManager: no se encontró el personaje.")
		return

	if counter == null:
		push_error("WaveManager: no se encontró el contador de oleadas.")
		return

	# El temporizador crea enemigos poco a poco, respetando el máximo en pantalla.
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_next_enemy)
	add_child(spawn_timer)
	spawn_timer.start()

	_actualizar_contador()


func _process(_delta: float) -> void:
	if boss_phase_started or player == null:
		return

	# Los enemigos derrotados son los que ya aparecieron y dejaron de existir.
	var enemigos_activos := get_tree().get_nodes_in_group("enemies").size()
	enemies_defeated = enemies_spawned - enemigos_activos
	_actualizar_contador()

	# La siguiente oleada empieza cuando ya no queda ningún enemigo de la actual.
	if enemies_spawned >= enemies_in_wave and enemigos_activos == 0 and not waiting_for_next_wave:
		_completar_oleada()


# Crea un enemigo si todavía quedan enemigos por aparecer y hay espacio.
func _spawn_next_enemy() -> void:
	if boss_phase_started or waiting_for_next_wave or player == null:
		return

	if enemies_spawned >= enemies_in_wave:
		return

	var enemigos_activos := get_tree().get_nodes_in_group("enemies").size()
	if enemigos_activos >= MAX_ENEMIES_ON_SCREEN:
		return

	var posicion := _buscar_posicion_de_aparicion()
	if posicion == Vector2(-1.0, -1.0):
		return

	var enemigo := ENEMY_SCENE.instantiate() as Area2D
	get_parent().add_child(enemigo)
	enemigo.global_position = posicion
	enemies_spawned += 1
	_actualizar_contador()


# Busca una posición aleatoria a una distancia segura del personaje.
func _buscar_posicion_de_aparicion() -> Vector2:
	for intento in range(30):
		var angulo := random_generator.randf_range(0.0, TAU)
		var distancia := random_generator.randf_range(SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
		var posicion := player.global_position + Vector2.RIGHT.rotated(angulo) * distancia

		if posicion.x < EDGE_MARGIN or posicion.x > MAP_SIZE.x - EDGE_MARGIN:
			continue
		if posicion.y < EDGE_MARGIN or posicion.y > MAP_SIZE.y - EDGE_MARGIN:
			continue

		return posicion

	# Si el personaje está demasiado cerca de un borde, se volverá a intentar.
	return Vector2(-1.0, -1.0)


# Espera unos segundos entre oleadas para que se note el cambio.
func _completar_oleada() -> void:
	waiting_for_next_wave = true
	spawn_timer.stop()

	if current_wave >= TOTAL_WAVES:
		boss_phase_started = true
		counter.text = "10/10 OLEADAS SUPERADAS | JEFE FINAL"
		boss_fight_ready.emit()
		return

	counter.text = "OLEADA %d COMPLETADA" % current_wave
	await get_tree().create_timer(INTERMISSION_SECONDS).timeout

	current_wave += 1
	enemies_in_wave = current_wave * 10
	enemies_spawned = 0
	enemies_defeated = 0
	waiting_for_next_wave = false
	spawn_timer.start()
	_actualizar_contador()


# Muestra la oleada actual y todos los enemigos que faltan por derrotar.
func _actualizar_contador() -> void:
	if not is_instance_valid(counter):
		return

	var restantes := enemies_in_wave - enemies_defeated
	counter.text = "OLEADA %d/%d     ENEMIGOS RESTANTES: %d" % [
		current_wave,
		TOTAL_WAVES,
		maxi(0, restantes)
	]
