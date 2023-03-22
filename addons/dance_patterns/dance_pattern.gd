extends Node

var step_array:Array
var index=0
var deltaTime=0.001
var state_c = true
var dancePatternKey:String
var dance_pattern
var current_step
#Seconds Per Beat
var spb = 3
#Threshold multiplier for acceptance
var threshold = 0.8
# Called when the node enters the scene tree for the first time.
func _init(dancePatternKey:String="salsa_basic"):
	self.dancePatternKey = dancePatternKey
func _ready():
	var pattern_manager = get_node("/root/Singleton")
	print(pattern_manager)
	var dance_pattern = pattern_manager.get_dance_pattern(self.dancePatternKey)
	var step_pool = dance_pattern.split(";")
	for step in step_pool:
		self.step_array.append(step)
	print("STEP ARRAY", step_array)
	current_step = DanceStep.new(step_array.pop_front())
	self.add_child(current_step)
	
func _process(delta):
	deltaTime+=delta
	index += 1
	if deltaTime > spb:
		deltaTime=0.001		
	
func check_controller(body, area):
	print ("===============================")
	print ("")
	print(body.name)
	print(area.name)
	print ("")
	print("================================")
	area.get_parent().remove_child(self)
		


class DanceStep extends Node:
	var nodes:Array
	var node_count
	var StepString:String
	var DanceStep:Array
	var score_accum=0
	signal mysignal
	func _init(DanceStep:String):
		self.node_count = 0
		print("=========   DANCE STEP ==========")
		var DanceNodeArray = DanceStep.split(',')
		for node_def in DanceNodeArray:
			print("NODE NODE NODE")
			var node_obj = DanceNode.new(node_def)
			self.nodes.append(node_obj)
			node_count +=1
			node_obj.connect("status_callback", self, "score", [node_obj])
			self.add_child(node_obj)
	func score(node:DanceNode):
		print("ACTIVE SIGNALs")
		print(node)
		self.score_accum += node.score
		print("Callback: ", self.score_accum)
	func _ready():
		print("DanceStep")
		
		
class DanceNode extends Node:
	var nodes = []
	signal status_callback
	var area:Area
	var deltaTime = 0.001
	var index=1
	var score =0
	#Seconds Per Beat
	var spb = 3
	#Threshold multiplier for acceptance
	var threshold = 0.8
	var state_c
	func _init(DanceNode:String):
		print("DanceNode Init ", DanceNode)
	func _ready():
		self.area = create_node()
		self.add_child(self.area)
	func _process(delta):
		deltaTime+=delta
		index += 1
		if deltaTime > spb:
			deltaTime=0.001	
		setColour()
		
	func create_node(area_name:String = "noname", location:Vector3 = Vector3(0, 1, 0)):
		print("Generating Node")
		var area = Area.new()
		area.name = area_name
		area.connect("body_entered", self, "check_controller", [area])
		
		var dance_mesh = MeshInstance.new()
		area.add_child(dance_mesh)
		dance_mesh.owner = area
		dance_mesh.name = "Dance_Mesh"
		
		var mesh = CubeMesh.new()
		mesh.size = Vector3(0.25, 0.025, 0.25)
		dance_mesh.mesh = mesh
		
		var dance_mesh_collision = CollisionShape.new()
		area.add_child(dance_mesh_collision)
		dance_mesh_collision.owner = area
		
		var dance_mesh_collision_shape = BoxShape.new()
		dance_mesh_collision_shape.extents = Vector3(0.25, 0.025, 0.2)
		dance_mesh_collision.shape = dance_mesh_collision_shape
		
		area.transform.origin = location
		add_child(area)
		test_signal()
		return area
		
	func setColour(state=null):
		area = self.area
		var material = SpatialMaterial.new()
		if state == "reset":
			state_c = true
		if state_c == true:
			var max_hue:float = 8.0/36.0
			var hue = (deltaTime / spb) * max_hue
			#print("DeltaTime = " + str(deltaTime) + " SPB = " + str(spb) + " MaxHue: " + str(max_hue) + " Current Hue: " + str(hue))
			material.albedo_color = Color.from_hsv(hue, 1, 1, 1)
			area.get_child(0).set_surface_material(0, material)

		if state == "goal":
			material.albedo_color = Color(1, .5, .2)
			state_c = false
			area.get_child(0).set_surface_material(0, material)
		elif state == "fail":
			material.albedo_color = Color(1, 0, 0)
			state_c = false
			area.get_child(0).set_surface_material(0, material)
		elif state == "success": # && deltaTime > spb * threshold:
			print ("deltaTime: " + str(deltaTime) + " spb: " + str(spb) + " spb*threshold: " + str(spb*threshold))
			material.albedo_color = Color(0,0,1)
			state_c = false
			area.get_child(0).set_surface_material(0, material)
	func moveMesh(change_in_location: Vector3 = Vector3(0,0,0)):	
		var node = self.area
		node.global_transform.origin = node.global_transform.origin + change_in_location
		node.global_transform.origin = node.global_transform.origin + change_in_location
	func _input(ev):
		if ev is InputEventKey and ev.scancode == KEY_SPACE and not ev.echo:
				self.moveMesh(Vector3(0.05, 0, 0.05))
		if ev is InputEventKey and ev.scancode == KEY_0 and not ev.echo:
			setColour("goal")
		if ev is InputEventKey and ev.scancode == KEY_1 and not ev.echo:
			setColour("fail")
		if ev is InputEventKey and ev.scancode == KEY_2 and not ev.echo:
			setColour("success")
		if ev is InputEventKey and ev.scancode == KEY_3 and not ev.echo:
			setColour("reset")
	func test_signal():
		print ("TESTING SIGNAL")
		self.score = 18
		emit_signal("status_callback")
		return self.score
	func check_controller(body, area):
		print ("===============================")
		print ("")
		print(body.name)
		print(area.name)
		if body.name == self.collision_target.name:
			emit_signal("status_callback")
		print ("")
		print("================================")
		area.get_parent().remove_child(self)

class LearnDance extends DanceNode:
	pass
