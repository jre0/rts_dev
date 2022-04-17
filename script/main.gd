extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.target_fps = 40
	DisplayServer.window_set_vsync_mode(2,0) #adaptive
	DisplayServer.window_set_title('Yo RTS', 0)
	DisplayServer.window_set_mode(2,0) #WINDOW_MODE_MAXIMIZED = 2
