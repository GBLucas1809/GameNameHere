extends Label3D

var elapsed_time := 0.0

@export var max_seconds = 0 

var time_is_up = false

func _process(delta: float) -> void:
	
	elapsed_time += delta

	var _current_time = max_seconds - int(elapsed_time)

	text = str(_current_time)

	if(_current_time <= 0):
		time_is_up = true
		elapsed_time = 0
	


	

