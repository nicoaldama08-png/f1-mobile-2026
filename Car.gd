extends CharacterBody2D

var current_speed: float = 0.0
var max_speed: float = 330.0
var acceleration_rate: float = 120.0
var braking_rate: float = 240.0
var steering_angle: float = 0.0

# Reglamento 2026: Modos X / Z y Batería
var is_x_mode: bool = false
var is_override: bool = false
var ers_battery: float = 100.0

var throttle_pressed: bool = false
var brake_pressed: bool = false

func _physics_process(delta: float) -> void:
	# 1. Giroscopio / Inclinación del teléfono móvil
	var accel = Input.get_accelerometer()
	var steer_input = 0.0
	
	if abs(accel.x) > 0.4:
		steer_input = clamp(accel.x / 5.0, -1.0, 1.0)
	else:
		# Controles de respaldo para pruebas en PC (Teclas A y D)
		steer_input = Input.get_axis("ui_left", "ui_right")

	# 2. Aceleración y Frenos
	var active_accel = acceleration_rate
	var active_top_speed = max_speed

	# Modo X (Baja carga aerodinámica en rectas)
	if is_x_mode:
		active_top_speed += 25.0
	
	# Despliegue eléctrico Override (350 kW)
	if is_override and ers_battery > 0.0:
		active_accel += 60.0
		ers_battery = max(0.0, ers_battery - (18.0 * delta))
	elif not is_override and ers_battery < 100.0:
		ers_battery = min(100.0, ers_battery + (6.0 * delta))

	if throttle_pressed or Input.is_action_pressed("ui_up"):
		current_speed = move_toward(current_speed, active_top_speed, active_accel * delta)
	elif brake_pressed or Input.is_action_pressed("ui_down"):
		current_speed = move_toward(current_speed, 0.0, braking_rate * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, 30.0 * delta)

	# 3. Aplicar rotación y movimiento
	if current_speed > 5.0:
		rotation += steer_input * 2.2 * (current_speed / active_top_speed) * delta

	velocity = Vector2.UP.rotated(rotation) * (current_speed * 4.0)
	move_and_slide()
