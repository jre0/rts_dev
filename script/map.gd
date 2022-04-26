extends StaticBody3D

@export var point_count_x = 300
@export var point_count_z = 300
var half_point_count_x = point_count_x/2
var half_point_count_z = point_count_z/2
@export var point_spacing = 1
@export var rift_count_min = 3 
@export var rift_count_max = 15
@export var rift_radius_min = 50
@export var rift_radius_max = 150
@export var arc_fade_min = 2 
@export var arc_fade_max = 8
@export var rift_height_min = 4
@export var rift_height_max = 8
var rift_count = 0
var points = []
var rifts = []
var rng = RandomNumberGenerator.new()
var half_pi = PI/2
var tex_shift_constant = (1/half_pi) * 796
var height_array = PackedFloat32Array()
@onready var collision_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	make_rifts() #define basic rift geometry
	make_points() #make a grid of points at various heights based on rifts
	make_mesh() #build a mesh and assign to this MeshInstance3D

#map generation
func make_rifts():
	rift_count = rng.randi_range(rift_count_min, rift_count_max)
	for r in range(rift_count):
		var center = Vector2(rng.randi_range(0, point_count_x), rng.randi_range(0, point_count_z))
		var angle = rng.randf_range(-PI, PI)
		var distance = rng.randf_range(rift_radius_min, rift_radius_max)
		var arc_midpoint = center + Vector2(cos(angle),sin(angle))*distance
		var direction = center.direction_to(arc_midpoint)
		var arc_fade = rng.randf_range(arc_fade_min, arc_fade_max)
		var height = rng.randf_range(rift_height_min, rift_height_max)
		rifts.append([center,direction,distance,height,arc_fade])
func make_points():
	for z in range(point_count_z):
		points.append([])
		for x in range(point_count_x):
			var total_height = 0
			for r in range(rift_count):
				var center = rifts[r][0]
				var direction = rifts[r][1]
				var distance = rifts[r][2]
				var height = rifts[r][3] 
				var arc_fade = rifts[r][4] 
				var angle = center.direction_to(Vector2(x,z)).angle_to(direction)
				angle = angle*arc_fade
				height *= (cos(clamp(angle,-PI,PI))+1)/2
				var distance_diff = distance-center.distance_to(Vector2(x,z))
				height *= atan(distance_diff)/half_pi
				distance_diff = (distance_diff/(distance*0.9))*PI
				height *= (cos(clamp(distance_diff,-PI,PI))+1)/2
				total_height += height
			points[z].append(Vector3((x-half_point_count_x)*point_spacing,total_height,(z-half_point_count_z)*point_spacing))
			height_array.append(total_height)
	collision_shape.shape.set_map_width(point_count_x)
	collision_shape.shape.set_map_depth(point_count_z)
	collision_shape.shape.set_map_data(height_array)

#mesh generation
func make_mesh():
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	for z in range(point_count_z-1):
		for x in range(point_count_x-1):
			make_triangle(vertices,normals,uvs,[points[z][x],points[z][x+1],points[z+1][x]])
			make_triangle(vertices,normals,uvs,[points[z+1][x+1],points[z+1][x],points[z][x+1]])
	# Initialize the ArrayMesh.
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	arrays[ArrayMesh.ARRAY_TEX_UV] = uvs
	# Create the Mesh and assign to MeshInstance3D 
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh_instance.mesh = array_mesh
func make_triangle(vertices,normals,uvs,new_vertices):
	vertices.push_back(new_vertices[0])
	vertices.push_back(new_vertices[1])
	vertices.push_back(new_vertices[2])
	var normal = get_triangle_normal(new_vertices)
	for i in range(3): normals.push_back(normal)
	var tex_shift = Vector3(0,1,0).angle_to(normal)
	tex_shift = tex_shift * tex_shift_constant
	uvs.push_back(Vector2(tex_shift,512)/1024)
	uvs.push_back(Vector2(tex_shift + 226,390)/1024)
	uvs.push_back(Vector2(tex_shift + 226,616)/1024)
func get_triangle_normal(verts): # find the surface normal given 3 vertices
	var side1 = verts[1] - verts[0]
	var side2 = verts[2] - verts[0]
	var normal = -side1.cross(side2)
	return normal
