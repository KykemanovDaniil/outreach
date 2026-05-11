extends PanelContainer

# Прописываем пути вручную. Это заставит Godot включить их в EXE.
# Убедись, что пути ТОЧНО совпадают с твоими файлами в папке res://
var tutorial_paths : Array[String] = [
	"res://scenes/menu/menu_panels/tutorial/page_class/page_items/page1.tres",
	"res://scenes/menu/menu_panels/tutorial/page_class/page_items/page2.tres",
	"res://scenes/menu/menu_panels/tutorial/page_class/page_items/page3.tres",
	"res://scenes/menu/menu_panels/tutorial/page_class/page_items/page4.tres"
]

@onready var slide_texture = %page_texture
@onready var slide_text = %page_text
@onready var slide_name = %page_name
@onready var counter_label = %page_counter

var all_slides_data : Array[Resource] = []
var current_idx : int = 0

func _ready():
	
	var track = preload("res://assets/audio/music/Only_forward.ogg")
	SoundManager.play_specific_music(track)
	
	load_resources_manually()
	if all_slides_data.size() > 0:
		show_slide(0)
	else:
		# Если это выскочит в EXE, значит пути в массиве выше написаны с ошибкой
		push_error("ОШИБКА: Ресурсы не найдены по указанным путям!")

func load_resources_manually():
	all_slides_data.clear()
	for path in tutorial_paths:
		if ResourceLoader.exists(path):
			var res = load(path)
			if res:
				all_slides_data.append(res)
		else:
			push_error("Файл не найден: " + path)

func show_slide(index: int):
	if index < 0 or index >= all_slides_data.size():
		return
	
	current_idx = index
	var data = all_slides_data[current_idx]
	
	# Используем get(), чтобы не было вылета, если поле названо иначе
	slide_texture.texture = data.get("PAGE_IMAGE")
	slide_text.text = data.get("PAGE_DESCRIPTION")
	slide_name.text = data.get("PAGE_NAME")
	
	if counter_label:
		counter_label.text = "%d / %d" % [current_idx + 1, all_slides_data.size()]

func next_page():
	SoundManager.play_2d("click")
	if current_idx < all_slides_data.size() - 1:
		# SoundManager.play_2d("click") # Убедись, что SoundManager доступен
		show_slide(current_idx + 1)

func prev_page():
	SoundManager.play_2d("click")
	if current_idx > 0:
		show_slide(current_idx - 1)
