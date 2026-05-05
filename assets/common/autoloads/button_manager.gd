extends Node

# Мапинг имен кнопок на действия или кнопки мыши
# Теперь поддерживаем и клавиши, и мышь
const KEY_MAP = {
	"W": KEY_W,
	"A": KEY_A,
	"S": KEY_S,
	"D": KEY_D,
	"Space": KEY_SPACE,
	"Shift": KEY_SHIFT,
	"Esc": KEY_ESCAPE,
	"E": KEY_E,
	"Right_click": MOUSE_BUTTON_RIGHT,
	"Left_click": MOUSE_BUTTON_LEFT,
}

@onready var viewport : Viewport = get_viewport()
var touches : Dictionary = {}

func _ready() -> void:
	# Чтобы кнопки не перехватывали фокус и не мешали друг другу
	for btn in get_tree().get_nodes_in_group("touch_buttons"):
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_PASS

func _input(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return

	var tid = event.index
	var curr_btn = viewport.gui_get_hovered_control()
	
	# ЖЕСТКАЯ ФИЛЬТРАЦИЯ: 
	# Если это новое нажатие, и мы попали НЕ в нашу кнопку — нахер этот палец, не регистрируем его
	if event is InputEventScreenTouch and event.pressed:
		if curr_btn and curr_btn.is_in_group("touch_buttons"):
			touches[tid] = {"last": null, "start": curr_btn}
		else:
			return # Игнорируем это касание полностью

	# Если этого пальца нет в нашем списке (значит он нажат мимо кассы), выходим
	if not touches.has(tid): 
		return
	
	var state = touches[tid]
	var target : Control = null
	
	# Теперь проверяем только кнопки из нужной группы
	if curr_btn and curr_btn.is_in_group("touch_buttons") and curr_btn.is_visible_in_tree():
		if KEY_MAP.has(curr_btn.name):
			# Логика Passby: соскальзывание разрешено, только если кнопка в группе
			if curr_btn.get("passby") == true or state["start"] == curr_btn:
				target = curr_btn

	if state["last"] != target:
		if state["last"]:
			_send_input(state["last"].name, false)
		if target:
			_send_input(target.name, true)
		state["last"] = target

	if event is InputEventScreenTouch and not event.pressed:
		if state["last"]:
			_send_input(state["last"].name, false)
		touches.erase(tid)


func _send_input(btn_name: String, pressed: bool) -> void:
	var code : Dictionary = KEY_MAP[btn_name]
	
	# Если это кнопки мыши
	if btn_name == "Right_click" or btn_name == "Left_click":
		var ev : InputEvent = InputEventMouseButton.new()
		ev.button_index = code
		ev.pressed = pressed
		ev.position = get_viewport().get_mouse_position() # Важно для корректного клика
		Input.parse_input_event(ev)
	# Если это обычные клавиши
	else:
		var ev : InputEvent = InputEventKey.new()
		ev.physical_keycode = code
		ev.pressed = pressed
		Input.parse_input_event(ev)


func register_button(btn: Control) -> void:
	btn.add_to_group("touch_buttons") # Добавляем в группу для фильтрации
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
