class_name BehaviorRecorder
extends RefCounted

const DISTANCE_BUCKETS: Array[Vector2] = [
	Vector2(0.0, 80.0),
	Vector2(80.0, 140.0),
	Vector2(140.0, 240.0),
	Vector2(240.0, 9999.0),
]

var _distance_counts: Dictionary = {}
var _attack_sequence: Array[AttackData] = []
var _dodge_counts: Dictionary = {-1: 0, 1: 0}
var _last_attack_msec: int = -100000


func record_attack(attack_data: AttackData, distance: float) -> void:
	if attack_data == null:
		return

	var bucket_index := _find_distance_bucket(distance)
	_distance_counts[bucket_index] = int(_distance_counts.get(bucket_index, 0)) + 1

	var now := Time.get_ticks_msec()
	if now - _last_attack_msec > 900:
		_attack_sequence.clear()
	_attack_sequence.append(attack_data)
	if _attack_sequence.size() > 3:
		_attack_sequence.pop_front()
	_last_attack_msec = now


func record_dodge(direction: int) -> void:
	if Time.get_ticks_msec() - _last_attack_msec > 600:
		return
	var normalized := 1 if direction >= 0 else -1
	_dodge_counts[normalized] = int(_dodge_counts.get(normalized, 0)) + 1


func build_profile() -> OldSelfProfile:
	var profile := OldSelfProfile.new()
	var preferred_bucket := _most_common_bucket()
	if preferred_bucket >= 0:
		var range := DISTANCE_BUCKETS[preferred_bucket]
		profile.preferred_distance_min = range.x
		profile.preferred_distance_max = range.y

	profile.combo_sequence = _attack_sequence.duplicate()
	profile.dodge_direction = -1 if int(_dodge_counts.get(-1, 0)) > int(_dodge_counts.get(1, 0)) else 1
	return profile


func reset() -> void:
	_distance_counts.clear()
	_attack_sequence.clear()
	_dodge_counts = {-1: 0, 1: 0}
	_last_attack_msec = -100000


func _find_distance_bucket(distance: float) -> int:
	for index: int in range(DISTANCE_BUCKETS.size()):
		var range := DISTANCE_BUCKETS[index]
		if distance >= range.x and distance < range.y:
			return index
	return DISTANCE_BUCKETS.size() - 1


func _most_common_bucket() -> int:
	var best_bucket := -1
	var best_count := 0
	for bucket: int in _distance_counts:
		var count := int(_distance_counts[bucket])
		if count > best_count:
			best_count = count
			best_bucket = bucket
	return best_bucket
