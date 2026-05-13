extends Node

@export var sounds: Dictionary = { 
	"click": preload("res://assets/audio/sfx/click.ogg"), 
	"break_block": preload("res://assets/audio/sfx/break_block.ogg"), 
}

@export var music_list: Array = [ 
	[preload("res://assets/audio/music/New_world.ogg"), 100, "menu"], 
	[preload("res://assets/audio/music/Memories.ogg"), 60, "game"], 
	[preload("res://assets/audio/music/We_will_mourn.ogg"), 50, "game"] 
]

var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_pool_3d: Array[AudioStreamPlayer3D] = []
var music_player: AudioStreamPlayer
var music_tween: Tween

var pool_size: int = 5
var is_forced: bool = false
var current_target_track: AudioStream

# Индексы глобальных аудио-автобусов Godot
var music_bus_idx: int
var sfx_bus_idx: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Автоматически находим системные шины по их именам
	music_bus_idx = AudioServer.get_bus_index(&"Music")
	sfx_bus_idx = AudioServer.get_bus_index(&"SFX")
	
	# Если шины с такими именами не созданы в аудио-микшере, создаем их программно
	if music_bus_idx == -1:
		AudioServer.add_bus()
		music_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(music_bus_idx, &"Music")
	if sfx_bus_idx == -1:
		AudioServer.add_bus()
		sfx_bus_idx = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(sfx_bus_idx, &"SFX")
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = &"Music"
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	
	sync_music_volume()
	
	for i in range(pool_size):
		var p = AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		sfx_pool.append(p)
		
		var p3d = AudioStreamPlayer3D.new()
		p3d.bus = &"SFX"
		p3d.area_mask = 1
		p3d.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
		add_child(p3d)
		sfx_pool_3d.append(p3d)

# Мгновенно меняет громкость на глобальной аудио-шине без прерывания трека
func sync_music_volume() -> void:
	var vol = float(GlobalValues.music_volume)
	var target_db = -80.0 if vol <= 0.0 else linear_to_db(vol)
	AudioServer.set_bus_volume_db(music_bus_idx, target_db)

func play_2d(sound_name: String, volume: float = 0.0) -> void:
	if not sounds.has(sound_name): return
	
	# Синхронизируем общую громкость эффектов через глобальную шину SFX
	var sfx_vol = float(GlobalValues.sfx_volume)
	var target_sfx_db = -80.0 if sfx_vol <= 0.0 else linear_to_db(sfx_vol)
	AudioServer.set_bus_volume_db(sfx_bus_idx, target_sfx_db)
	
	for p in sfx_pool:
		if not p.playing:
			p.stream = sounds[sound_name]
			p.volume_db = volume # Локальное смещение громкости конкретного звука
			p.play()
			return

func play_3d(sound_name: String, position: Vector3, volume: float = 0.0) -> void:
	if not sounds.has(sound_name): return
	
	# Синхронизируем общую громкость эффектов через глобальную шину SFX
	var sfx_vol = float(GlobalValues.sfx_volume)
	var target_sfx_db = -80.0 if sfx_vol <= 0.0 else linear_to_db(sfx_vol)
	AudioServer.set_bus_volume_db(sfx_bus_idx, target_sfx_db)
	
	for p in sfx_pool_3d:
		if not p.playing:
			p.global_position = position
			p.stream = sounds[sound_name]
			p.volume_db = volume # Локальное смещение громкости конкретного звука
			p.play()
			return

func play_random_music():
	is_forced = false
	if not get_tree().current_scene: return
	
	var cur_scene_name = get_tree().current_scene.name.to_lower()
	var valid = music_list.filter(func(track): return track[2] in cur_scene_name)
	
	if valid.is_empty(): return
	
	var selected_track = valid.pick_random()
	_fade_to_track(selected_track[0]) 
	var file_path = selected_track[0].resource_path
	var track_name = file_path.get_file().get_basename().replace("_", " ")
	TextAnim.spawn_top_text(self, "now playning : " + track_name)

func play_specific_music(track: AudioStream):
	is_forced = true
	_fade_to_track(track)
	var file_path = track.resource_path
	var track_name = file_path.get_file().get_basename().replace("_", " ")
	TextAnim.spawn_top_text(self, "now playing: " + track_name)

# Твин управляет только внутренним затуханием плеера при переключении треков, 
# не ломая общую громкость из настроек
func _fade_to_track(new_stream: AudioStream):
	if current_target_track == new_stream: return
	current_target_track = new_stream
	
	if music_tween: music_tween.kill()
	music_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	if music_player.playing:
		music_tween.tween_property(music_player, "volume_db", -80.0, 0.2)
	
	music_tween.tween_callback(func():
		music_player.stop()
		music_player.volume_db = -80.0 # Плеер стартует с полной тишины относительно шины
		music_player.stream = current_target_track
		if current_target_track:
			music_player.play()
	)
	
	# Выводим плеер на 0.0 dB (исходный уровень трека, регулируемый аудио-автобусом)
	music_tween.tween_property(music_player, "volume_db", 0.0, 0.4)

func _on_music_finished():
	if is_forced:
		music_player.play()
	else:
		play_random_music()
