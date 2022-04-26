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
var map_mouse_position = Vector3(0,0,0)
var map_center_position = Vector3(0,0,0)
var mouse_ray_args = PhysicsRayQueryParameters3D.new()
var center_ray_args = PhysicsRayQueryParameters3D.new()

func _physics_process(_delta):
	var space_state = camera.get_world_3d().direct_space_state
	var mouse_ray = space_state.intersect_ray(mouse_ray_args)
	if len(mouse_ray) > 0: map_mouse_position = mouse_ray.position
	var center_ray = space_state.intersect_ray(center_ray_args)
	if len(center_ray) > 0: map_center_position = center_ray.position
	
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
			mouse_ray_args.from = camera.project_ray_origin(event.position)
			var mouse_ray_normal = camera.project_ray_normal(event.position) 
			mouse_ray_args.to = mouse_ray_args.from + mouse_ray_normal*10000
			var move = mouse_ray_normal*camera.position.z*zoomSpeed
			camera.global_translate(move)
			center_ray_args.from = camera.project_ray_origin(DisplayServer.screen_get_size()/2)
			center_ray_args.to = center_ray_args.from + camera.project_ray_normal(DisplayServer.screen_get_size()/2)*10000
			var global_transform = camera.get_global_transform()
			pivot_y.position = map_center_position
			camera.set_global_transform(global_transform) 
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.translate(Vector3.BACK * camera.position.z * zoomSpeed)
	elif event is InputEventMouseMotion:
		if orbit==true:
			var delta = mouseStartPosition - event.position
			pivot_x.set_transform(pivot_start_x)
			pivot_x.rotate_x(orbitSpeed * delta.y)
			pivot_y.set_transform(pivot_start_y)
			pivot_y.rotate_y(orbitSpeed * delta.x)
