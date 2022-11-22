extends Spatial


func _process(delta):
	$Text.rotation_degrees.y += delta * 20
