class_name MoveTimer extends Timer

signal SPEED_5 # 0.05s
signal SPEED_4 # 0.10s
signal SPEED_3 # 0.15s
signal SPEED_2 # 0.20s
signal SPEED_1 # 0.25s

var speed_trackers: Array = []


func _init() -> void:
	self.speed_trackers.append(SpeedTracker.new(0.05, 5))
	self.speed_trackers.append(SpeedTracker.new(0.1, 4))
	self.speed_trackers.append(SpeedTracker.new(0.15, 3))
	self.speed_trackers.append(SpeedTracker.new(0.2, 2))
	self.speed_trackers.append(SpeedTracker.new(0.25, 1))


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
			var speed_signal = get_speed_signal(speed_tracker.speed_number)
			speed_signal.emit()


class SpeedTracker:
	var interval_time: float
	var current_time_elapsed: float = 0.0
	var speed_number: int

	func _init(interval_time: float, speed_number: int) -> void:
		self.interval_time = interval_time
		self.speed_number = speed_number


	func increment_interval(delta_time: float) -> bool:
		self.current_time_elapsed += delta_time

		if self.current_time_elapsed >= self.interval_time:
			self.current_time_elapsed = 0.0
			return true

		return false
