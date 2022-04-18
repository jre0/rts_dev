extends RigidDynamicBody3D

var selected
@onready var hp_bar = $hp_bar
@onready var camera = get_tree().root.get_node('game/camera/pivot_x/camera')

func _ready():
	pass 

func _process(_delta):
	hp_bar.position = camera.unproject_position(position)

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select()
			
func select():
	selected = true
	hp_bar.show()
	
func deselect():
	selected = false
	hp_bar.hide()
