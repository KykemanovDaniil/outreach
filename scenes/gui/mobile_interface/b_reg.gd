extends Button

# Включает режим "проскальзывания" (как в TouchScreenButton)
@export var passby: bool = false

func _ready() -> void:
	# Регистрируем кнопку в глобальной системе
	ButtonManager.register_button(self)
	
