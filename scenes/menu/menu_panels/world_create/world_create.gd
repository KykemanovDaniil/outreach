extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%seed.text = str(randi())
	GlobalValues.world_type = str("basic")



func _on_seed_text_changed(new_text: String) -> void:
	var old_caret: int = %seed.caret_column  # Добавили : int
	var filtered: String = ""
	
	for c in new_text:
		if c in "0123456789":
			filtered += c
			
	%seed.text = filtered
	%seed.caret_column = old_caret


func _on_world_type_selected(id: int) -> void:
	SoundManager.play_2d("click")
	var item_name : String = %world_type_btn.get_popup().get_item_text(id)
	GlobalValues.world_type = item_name

func create_world() -> void:
	var input_text: String = %seed.text
	
	if input_text.is_empty():
		GlobalValues.world_seed = randi()
	elif input_text.is_valid_int():
		GlobalValues.world_seed = input_text.to_int()
	else:
		GlobalValues.world_seed = input_text.hash()
	
	GlobalValues.cave_seed = GlobalValues.world_seed + 10
	GlobalValues.tree_seed = GlobalValues.world_seed + 20
	GlobalValues.cloud_seed = GlobalValues.world_seed + 30
	
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
