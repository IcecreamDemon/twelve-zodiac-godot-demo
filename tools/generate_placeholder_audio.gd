extends SceneTree

const SAMPLE_RATE := 22050
const OUTPUT_DIR := "res://assets/audio/"

const SOUND_DEFINITIONS: Dictionary = {
	&"hit_light": 0.09,
	&"hit_heavy": 0.16,
	&"block": 0.09,
	&"parry": 0.24,
	&"dodge": 0.08,
	&"burrow": 0.2,
	&"emerge": 0.18,
	&"ui": 0.06,
	&"enemy_death": 0.34,
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var failures: Array[String] = []

	for sound_id: StringName in SOUND_DEFINITIONS:
		var duration: float = SOUND_DEFINITIONS[sound_id]
		var stream := _create_stream(sound_id, duration)
		var path := "%s%s.res" % [OUTPUT_DIR, sound_id]
		var error := ResourceSaver.save(stream, path)
		if error != OK:
			failures.append("%s: %s" % [path, error_string(error)])

	if failures.is_empty():
		print("PLACEHOLDER AUDIO GENERATION PASS")
		quit(0)
		return

	for failure: String in failures:
		push_error(failure)
	quit(1)


func _create_stream(sound_id: StringName, duration: float) -> AudioStreamWAV:
	var frame_count := int(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(frame_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(sound_id)

	for frame: int in range(frame_count):
		var time := float(frame) / SAMPLE_RATE
		var envelope := pow(maxf(1.0 - time / duration, 0.0), 2.0)
		var sample := _sample_sound(sound_id, time, duration, rng) * envelope
		data.encode_s16(frame * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _sample_sound(
	sound_id: StringName,
	time: float,
	duration: float,
	rng: RandomNumberGenerator,
) -> float:
	var noise := rng.randf_range(-1.0, 1.0)
	match sound_id:
		&"hit_light":
			return sin(TAU * 220.0 * time) * 0.55 + noise * 0.35
		&"hit_heavy":
			return sin(TAU * 92.0 * time) * 0.7 + noise * 0.28
		&"block":
			return sin(TAU * 360.0 * time) * 0.48 + sin(TAU * 720.0 * time) * 0.22 + noise * 0.12
		&"parry":
			return (
				sin(TAU * 880.0 * time) * 0.42
				+ sin(TAU * 1320.0 * time) * 0.3
				+ sin(TAU * 1760.0 * time) * 0.18
			)
		&"dodge":
			return noise * 0.25 + sin(TAU * 520.0 * time) * 0.12
		&"burrow":
			return noise * 0.42 + sin(TAU * 110.0 * time) * 0.22
		&"emerge":
			var frequency := lerpf(150.0, 520.0, time / duration)
			return sin(TAU * frequency * time) * 0.55 + noise * 0.18
		&"ui":
			return sin(TAU * 660.0 * time) * 0.5
		&"enemy_death":
			var frequency := lerpf(180.0, 55.0, time / duration)
			return sin(TAU * frequency * time) * 0.58 + noise * 0.18
		_:
			return 0.0
