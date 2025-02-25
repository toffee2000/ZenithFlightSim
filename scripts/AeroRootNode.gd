extends Node3D

class_name AeroRootNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Control mode
# 0 = player controlled 
# 1 = AI
var control_mode = 0

# Input variables
var input_pitch = 0.00
var input_roll = 0.00
var input_yaw = 0.00
var input_thrust = 0.00

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	# Pitch input
	input_pitch = Input.get_axis("pitch_down", "pitch_up")
	
	# Roll input
	input_roll = Input.get_axis("roll_left", "roll_right")
	
	# Yaw input
	input_yaw = Input.get_axis("yaw_left", "yaw_right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
