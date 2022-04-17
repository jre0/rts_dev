extends SubViewportContainer

@export var start_position = Vector3(0,0,0)
@export var start_zoom = 0

@onready var pivot_y = $subViewport/pivot_y
@onready var pivot_x = $subViewport/pivot_y/pivot_x
@onready var camera =  $subViewport/pivot_y/pivot_x/camera
var mouseStartPosition = Vector2(0,0)
var pivot_start_x
var pivot_start_y 
var orbitSpeed = 0.005
var zoomSpeed = 0.05
var orbit = false

func _ready():
	pivot_y.set_position(start_position)
	camera.set_position(Vector3.BACK * start_zoom)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed==true:
				mouseStartPosition = event.position
				pivot_start_x = pivot_x.get_transform()
				pivot_start_y = pivot_y.get_transform()
				orbit = true
			elif event.pressed==false:
				orbit = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.translate(Vector3.BACK * camera.position.z * zoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.translate(Vector3.FORWARD * camera.position.z * zoomSpeed)
	elif event is InputEventMouseMotion:
		if orbit==true:
			var delta =  mouseStartPosition - event.position
			pivot_x.set_transform(pivot_start_x)
			pivot_x.rotate_x(orbitSpeed * delta.y)
			pivot_y.set_transform(pivot_start_y)
			pivot_y.rotate_y(orbitSpeed * delta.x)

