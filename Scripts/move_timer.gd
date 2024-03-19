class_name MoveTimer extends Timer

signal SPEED_5
signal SPEED_4
signal SPEED_3
signal SPEED_2
signal SPEED_1

var speed_trackers: Array = []


func _init() -> void:
	paused = false
	self.speed_trackers.append(SpeedTracker.new(0.05, 5))
	self.speed_trackers.append(SpeedTracker.new(0.1, 4))
	self.speed_trackers.append(SpeedTracker.new(0.15, 3))
	self.speed_trackers.append(SpeedTracker.new(0.25, 2))
	self.speed_trackers.append(SpeedTracker.new(0.35, 1))


func get_speed_signal(speed_number: int) -> Signal:
	match speed_number:
		5:
			return self.SPEED_5
		4:
			return self.SPEED_4
		3:
			return self.SPEED_3
		2:
			return self.SPEED_2
		1:
			return self.SPEED_1
	return self.SPEED_3


func _on_timeout() -> void:
	var should_emit: bool = false
	for speed_tracker in self.speed_trackers:
		should_emit = speed_tracker.increment_interval(self.wait_time)
		if should_emit:
			var speed_signal = self.get_speed_signal(speed_tracker.speed_number)
			speed_signal.emit()


class SpeedTracker:
	var interval_time: float
	var current_time_elapsed: float = 0.0
	var speed_number: int

	func _init(p_interval_time: float, p_speed_number: int) -> void:
		interval_time = p_interval_time
		speed_number = p_speed_number

	func increment_interval(delta_time: float) -> bool:
		self.current_time_elapsed += delta_time

		if self.current_time_elapsed >= self.interval_time:
			self.current_time_elapsed = 0.0
			return true

		return false
