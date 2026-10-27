extends CanvasLayer

@onready var car: CharacterBody2D = get_node("../Car")
@onready var speed_label: Label = $SpeedLabel
@onready var battery_bar: ProgressBar = $BatteryBar
@onready var gear_label: Label = $GearLabel

func _ready() -> void:
	$BtnGas.button_down.connect(func(): car.throttle_pressed = true)
	$BtnGas.button_up.connect(func(): car.throttle_pressed = false)
	
	$BtnBrake.button_down.connect(func(): car.brake_pressed = true)
	$BtnBrake.button_up.connect(func(): car.brake_pressed = false)

	$BtnXMode.toggled.connect(func(pressed): car.is_x_mode = pressed)
	$BtnOverride.button_down.connect(func(): car.is_override = true)
	$BtnOverride.button_up.connect(func(): car.is_override = false)

func _process(_delta: float) -> void:
	if car:
		speed_label.text = str(int(car.current_speed)) + " KM/H"
		battery_bar.value = car.ers_battery
		
		var calculated_gear = int(clamp(car.current_speed / 45.0, 1.0, 8.0))
		gear_label.text = "GEAR: " + str(calculated_gear)
