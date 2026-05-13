@tool extends PanelContainer

var slot_scene : PackedScene = preload("res://scenes/gui/inventory/slot/slot.tscn")

var block_atlas := preload("res://assets/textures/block_atlas.png")

@onready var grid_cont : Node = get_tree().get_first_node_in_group("grid_cont")
@onready var options : Node = get_tree().get_first_node_in_group("options")

# Твой словарь полностью восстановлен
var blocks : Dictionary = {
	"grass": {"id": 1, "atlas_pos": Vector2i(1, 0), "category": "nature"},
	"dirt": {"id": 2, "atlas_pos": Vector2i(0, 0), "category": "nature"},
	"moss": {"id": 9, "atlas_pos": Vector2i(2, 2), "category": "nature"},
	"clay": {"id": 21, "atlas_pos": Vector2i(1, 5), "category": "nature"},
	"short grass": {"id": 12, "atlas_pos": Vector2i(3, 0), "category": "nature"},
	"buttercup": {"id": 13, "atlas_pos": Vector2i(4, 0), "category": "nature"},
	"roses": {"id": 17, "atlas_pos": Vector2i(5, 0), "category": "nature"},
	"bush": {"id": 14, "atlas_pos": Vector2i(3, 2), "category": "nature"},
	"berry bush": {"id": 15, "atlas_pos": Vector2i(4, 2), "category": "nature"},
	"oak sapling": {"id": 32, "atlas_pos": Vector2i(3, 1), "category": "nature"},
	"dead bush": {"id": 18, "atlas_pos": Vector2i(4, 3), "category": "nature"},
	"sand": {"id": 19, "atlas_pos": Vector2i(2, 3), "category": "nature"},
	"sandstone": {"id": 20, "atlas_pos": Vector2i(3, 3), "category": "nature"},
	"stone": {"id": 3, "atlas_pos": Vector2i(0, 1), "category": "nature"},
	"little_stones": {"id": 36, "atlas_pos": Vector2i(2, 0), "category": "nature"},
	"little_stone": {"id": 37, "atlas_pos": Vector2i(2, 0), "category": "nature"},
	"granite": {"id": 23, "atlas_pos": Vector2i(3, 5), "category": "nature"},
	"gravel": {"id": 24, "atlas_pos": Vector2i(2, 4), "category": "nature"},
	"basalt": {"id": 25, "atlas_pos": Vector2i(4, 5), "category": "nature"},
	"magma": {"id": 35, "atlas_pos": Vector2i(5, 5), "category": "nature"},
	"сobblestone": {"id": 10, "atlas_pos": Vector2i(0, 4), "category": "nature"},
	"mossy cobblestone": {"id": 16, "atlas_pos": Vector2i(0, 5), "category": "nature"}, 
	"oak": {"id": 4, "atlas_pos": Vector2i(1, 1), "category": "nature"},
	"oak planks": {"id": 8, "atlas_pos": Vector2i(1, 3), "category": "building"},
	"oak chest": {"id": 33, "atlas_pos": Vector2i(0, 0), "category": "building"},
	"leaves": {"id": 5, "atlas_pos": Vector2i(2, 1), "category": "nature"},
	"stone bricks": {"id": 6, "atlas_pos": Vector2i(0, 2), "category": "building"},
	"mossy stone bricks": {"id": 7, "atlas_pos": Vector2i(0, 3), "category": "building"}, 
	"lamp": {"id": 34, "atlas_pos": Vector2i(3, 4), "category": "building"},
	"desk_lamp": {"id": 38, "atlas_pos": Vector2i(0, 0), "category": "building"},
	"glass": {"id": 11, "atlas_pos": Vector2i(1, 4), "category": "building"},
	"bricks": {"id": 22, "atlas_pos": Vector2i(2, 5), "category": "building"},
	"cookie": {"id": 26, "atlas_pos": Vector2i(2, 7), "category": "other"},
	"pizza": {"id": 27, "atlas_pos": Vector2i(3, 7), "category": "other"},
	"red bubblegum": {"id": 28, "atlas_pos": Vector2i(2, 6), "category": "other"},
	"pink bubblegum": {"id": 29, "atlas_pos": Vector2i(3, 6), "category": "other"},
	"purple bubblegum": {"id": 30, "atlas_pos": Vector2i(4, 6), "category": "other"},
	"blue bubblegum": {"id": 31, "atlas_pos": Vector2i(5, 6), "category": "other"},
}

func _ready() -> void:
	render_inventory("all")

func render_inventory(filter: String) -> void:
	for child in grid_cont.get_children():
		child.queue_free()
	
	for b_name in blocks:
		var b_data = blocks[b_name]
		if filter == "all" or b_data.get("category", "") == filter:
			var slot_new = slot_scene.instantiate()
			grid_cont.add_child(slot_new)
			
			# Передаем ID, Имя и координаты в атласе
			slot_new.setup_slot(
				b_data["id"], 
				b_name, 
				b_data["atlas_pos"]
			)





func _input(event: InputEvent) -> void:
	if event.is_action_pressed("e"):
		SoundManager.play_2d("click")
		visible = !visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED

func _on_button_pressed(action: String) -> void:
	SoundManager.play_2d("click")
	TextAnim.call("spawn_floating_text", self, action)
	
	
	match action:
		"other":
			render_inventory("other")
		"nature":
			render_inventory("nature")
		"building":
			render_inventory("building")
		"all":
			render_inventory("all")
