extends AnimatedSprite2D

const RAPIDEZ: float = 200.0
const TAMANO_MAPA: Vector2 = Vector2(2160.0, 1440.0)
const MARGEN_LIMITE: float = 32.0
const VIDA_MAXIMA: float = 100.0
const DANIO_POR_SEGUNDO: float = 5.0

var vida: float = VIDA_MAXIMA
var enemigos_en_contacto: Array[Area2D] = []
var barra_vida: TextureProgressBar


func _ready() -> void:
	barra_vida = get_node("../HealthHUD/HealthBar") as TextureProgressBar
	$DamageArea.area_entered.connect(_on_damage_area_entered)
	$DamageArea.area_exited.connect(_on_damage_area_exited)
	_actualizar_barra_vida()


func _process(delta: float) -> void:
# Compruebo si el personaje sigue vivo (temporal)
	if vida <= 0.0:
		return

# Movimineto del personaje
	var x: float = Input.get_axis("ui_left", "ui_right")
	var y: float = Input.get_axis("ui_up", "ui_down")
	var direccion: Vector2 = Vector2(x, y).normalized()
	position += direccion * RAPIDEZ * delta

# Control del mapa y limites de movimiento. 
	position.x = clampf(position.x, MARGEN_LIMITE, TAMANO_MAPA.x - MARGEN_LIMITE)
	position.y = clampf(position.y, MARGEN_LIMITE, TAMANO_MAPA.y - MARGEN_LIMITE)

# Compruebo si algun enemigo esta tocando el personaje
	if not enemigos_en_contacto.is_empty():
		vida = maxf(0.0, vida - DANIO_POR_SEGUNDO * delta)
		_actualizar_barra_vida()
		if vida <= 0.0:    # Si la vida llega a 0 el personaje muere y desaparece. 
			visible = false
			$DamageArea.set_deferred("monitoring", false)

# Añadimos los enemigos en contacto con el personaje a la zona de daño
func _on_damage_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and not enemigos_en_contacto.has(area):
		enemigos_en_contacto.append(area)

# Eliminamos del daño a los enemigos de los que se aleja le personaje.
func _on_damage_area_exited(area: Area2D) -> void:
	enemigos_en_contacto.erase(area)

# Actualizo el daño en la barra de vida
func _actualizar_barra_vida() -> void:
	if is_instance_valid(barra_vida):
		barra_vida.value = vida
