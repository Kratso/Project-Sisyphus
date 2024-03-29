extends Node3D

@export var enemy_settings: BasicEnemySettings

var curved_path: Curve3D
var progress: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	curved_path = Curve3D.new()
	
	for point in PathGenSingleton.get_path_route():
		curved_path.add_point(Vector3(point.x, 0, point.y))
	$Path3D.curve = curved_path
	$Path3D/PathFollow3D.progress_ratio = 0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spawning_state_entered():
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling")


func _on_travelling_state_entered():
	print("Ayo!")


func _on_travelling_state_processing(delta):
	progress = delta * enemy_settings.speed
	$Path3D/PathFollow3D.progress += progress

	if $Path3D/PathFollow3D.progress >= PathGenSingleton.get_path_route().size() - 1 :
		$EnemyStateChart.send_event("to_despawning")


func _on_despawning_state_entered():
	# TODO: Deal the damage
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	queue_free()
