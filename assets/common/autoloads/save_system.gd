extends Node

const PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Сохранить любое значение (bool, int, float, String)
func set_val(section: String, key: String, value):
	config.load(PATH) # Загружаем текущий файл, чтобы не затереть другие настройки
	config.set_value(section, key, value)
	config.save(PATH)

# Загрузить значение (с дефолтным ответом, если файла еще нет)
func get_val(section: String, key: String, default):
	config.load(PATH)
	return config.get_value(section, key, default)
