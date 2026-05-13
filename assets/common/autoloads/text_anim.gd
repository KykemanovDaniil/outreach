extends Node

@export var speed: float = 50.0
@export var duration: float = 1.0

var canvas := CanvasLayer.new()
var settings := LabelSettings.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)
	canvas.layer = 150
	settings.outline_size = 5
	settings.outline_color = Color.BLACK

func spawn_floating_text(target: Node, message: String) -> void:
	var l := Label.new()
	l.text = message
	l.label_settings = settings
	canvas.add_child(l)
	
	# Центрирование относительно объекта и смещение вверх
	var pos = target.get_global_mouse_position() - (l.get_combined_minimum_size() / 2)
	l.global_position = pos
	
	var tw := l.create_tween().set_parallel()
	tw.tween_property(l, "global_position:y", pos.y - speed, duration)
	tw.tween_property(l, "modulate:a", 0.0, duration)
	tw.finished.connect(l.queue_free)

func spawn_top_text(_target: Node, message: String) -> void:
	# 1. Удаляем все старые сообщения в этом слое
	for child in canvas.get_children():
		child.queue_free()
	
	var l := Label.new()
	l.text = message
	l.label_settings = settings
	canvas.add_child(l)
	
	# Центрирование
	var screen_size = get_viewport().get_visible_rect().size
	var text_size = l.get_combined_minimum_size()
	l.global_position = Vector2((screen_size.x - text_size.x) / 2, 30)
	
	# 2. Анимация появления и исчезновения
	l.modulate.a = 0
	var tw := l.create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.3) # Быстрое появление
	tw.tween_interval(duration * 3)              # Удержание текста
	tw.tween_property(l, "modulate:a", 0.0, 1.0) # Плавное затухание
	
	tw.finished.connect(l.queue_free)
