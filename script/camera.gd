extends Node3D

@onready var pivot_y = self
@onready var pivot_x = $pivot_x
@onready var camera =  $pivot_x/camera
var mouseStartPosition = Vector2(0,0)
var pivot_start_x
var pivot_start_y 
var orbitSpeed = 0.005
var zoomSpeed = 0.07
var orbit = false
var map_pointer_position = Vector3(0,0,0)
var ray_args = PhysicsRayQueryParameters3D.new()

func _physics_process(_delta):
	var space_state = camera.get_world_3d().direct_space_state
	var ray = space_state.intersect_ray(ray_args)
	if len(ray) > 0: map_pointer_position = ray.position

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
			ray_args.from = camera.project_ray_origin(event.position)
			var ray_normal = camera.project_ray_normal(event.position) 
			ray_args.to = ray_args.from + ray_normal*10000
			var move = -ray_normal * pivot_y.position.distance_to(map_pointer_position) * zoomSpeed
			pivot_y.global_translate(move)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			ray_args.from = camera.project_ray_origin(event.position)
			var ray_normal = camera.project_ray_normal(event.position) 
			ray_args.to = ray_args.from + ray_normal * 10000
			var move = ray_normal* pivot_y.position.distance_to(map_pointer_position) * zoomSpeed
			pivot_y.global_translate(move)
	elif event is InputEventMouseMotion:
		if orbit==true:
			var delta = mouseStartPosition - event.position
			pivot_x.set_transform(pivot_start_x)
			pivot_x.rotate_x(orbitSpeed * delta.y)
			pivot_y.set_transform(pivot_start_y)
			pivot_y.rotate_y(orbitSpeed * delta.x)
