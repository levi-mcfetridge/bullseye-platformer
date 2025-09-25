extends CanvasLayer


func trans_black():
	print("wowow")
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards("fade")
