extends Particles2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var collision = true
# Called when the node enters the scene tree for the first time.
func _ready():
	if collision:
		emitting = true
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	queue_free()
