extends CanvasLayer

func _ready() -> void:
	var track = preload("res://assets/audio/music/Quest.ogg")
	SoundManager.play_specific_music(track)
