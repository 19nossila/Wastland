extends Node
class_name PerformanceMonitor

## Performance Monitor - Tracks game performance metrics

signal fps_changed(fps: int)
signal memory_warning(memory_mb: float)
signal performance_degradation(severity: String)

var frame_times: Array = []
var memory_samples: Array = []
var max_frame_count: int = 60
var performance_threshold: float = 15.0  # milliseconds

var current_fps: int = 0
var average_fps: float = 60.0
var min_fps: int = 60
var max_fps: int = 60
var frame_time_ms: float = 0.0

var memory_usage_mb: float = 0.0
var peak_memory_mb: float = 0.0
var memory_warning_threshold_mb: float = 1024.0

var system_info: Dictionary = {}
var performance_history: Array = []

func _ready():
	"""Initialize performance monitor"""
	add_to_group("performance_monitor")
	_gather_system_info()
	print("Performance monitor initialized")

func _process(delta):
	"""Monitor performance metrics"""
	frame_times.append(delta * 1000.0)  # Convert to milliseconds
	
	if frame_times.size() > max_frame_count:
		frame_times.pop_front()
	
	frame_time_ms = delta * 1000.0
	current_fps = int(1.0 / delta) if delta > 0 else 0
	
	_update_fps_stats()
	_update_memory_stats()
	_check_performance()

func _gather_system_info():
	"""Gather system information"""
	var ram_gb = OS.get_static_memory_usage() / (1024.0 * 1024.0 * 1024.0)
	var processor_count = OS.get_processor_count()
	var processor_name = OS.get_processor_name()
	
	system_info = {
		"os": OS.get_name(),
		"processor_name": processor_name,
		"processor_count": processor_count,
		"ram_gb": ram_gb,
		"render_api": RenderingServer.get_video_adapter_name(),
		"max_texture_size": RenderingServer.get_maximum_atlas_size(),
		"godot_version": Engine.get_version_info()
	}
	
	print("System Info:")
	print("  OS: %s" % system_info["os"])
	print("  Processor: %s (%d cores)" % [system_info["processor_name"], system_info["processor_count"]])
	print("  RAM: %.1f GB" % system_info["ram_gb"])
	print("  GPU: %s" % system_info["render_api"])

func _update_fps_stats():
	"""Update FPS statistics"""
	if frame_times.size() == 0:
		return
	
	var total = 0.0
	var min_frame = frame_times[0]
	var max_frame = frame_times[0]
	
	for frame_time in frame_times:
		total += frame_time
		min_frame = min(min_frame, frame_time)
		max_frame = max(max_frame, frame_time)
	
	average_fps = 1000.0 / (total / frame_times.size()) if total > 0 else 0.0
	min_fps = int(1000.0 / max_frame) if max_frame > 0 else 0
	max_fps = int(1000.0 / min_frame) if min_frame > 0 else 0
	
	# Emit signal if FPS changed significantly
	if current_fps % 10 == 0:  # Update every 10 FPS
		fps_changed.emit(current_fps)

func _update_memory_stats():
	"""Update memory statistics"""
	var static_mem = OS.get_static_memory_usage() / (1024.0 * 1024.0)
	var dynamic_mem = OS.get_dynamic_memory_usage() / (1024.0 * 1024.0)
	
	memory_usage_mb = static_mem + dynamic_mem
	peak_memory_mb = max(peak_memory_mb, memory_usage_mb)
	
	memory_samples.append(memory_usage_mb)
	if memory_samples.size() > 60:
		memory_samples.pop_front()
	
	# Emit warning if threshold exceeded
	if memory_usage_mb > memory_warning_threshold_mb:
		memory_warning.emit(memory_usage_mb)

func _check_performance():
	"""Check for performance issues"""
	if frame_time_ms > performance_threshold:
		var severity = "warning" if frame_time_ms < 30 else "critical"
		performance_degradation.emit(severity)
		performance_history.append({
			"time": Time.get_ticks_msec(),
			"frame_time": frame_time_ms,
			"severity": severity
		})

func get_fps_stats() -> Dictionary:
	"""Get FPS statistics"""
	return {
		"current": current_fps,
		"average": int(average_fps),
		"min": min_fps,
		"max": max_fps,
		"frame_time_ms": frame_time_ms
	}

func get_memory_stats() -> Dictionary:
	"""Get memory statistics"""
	return {
		"current_mb": memory_usage_mb,
		"peak_mb": peak_memory_mb,
		"average_mb": _get_average_memory(),
		"available_mb": OS.get_available_memory() / (1024.0 * 1024.0)
	}

func _get_average_memory() -> float:
	"""Get average memory usage"""
	if memory_samples.size() == 0:
		return 0.0
	
	var total = 0.0
	for sample in memory_samples:
		total += sample
	
	return total / memory_samples.size()

func get_performance_report() -> String:
	"""Generate performance report"""
	var report = "\n=== PERFORMANCE REPORT ===\n"
	
	var fps_stats = get_fps_stats()
	report += "FPS: %d (avg: %d, min: %d, max: %d)\n" % [
		fps_stats["current"],
		fps_stats["average"],
		fps_stats["min"],
		fps_stats["max"]
	]
	report += "Frame Time: %.2f ms\n" % fps_stats["frame_time_ms"]
	
	var mem_stats = get_memory_stats()
	report += "\nMemory:\n"
	report += "  Current: %.1f MB\n" % mem_stats["current_mb"]
	report += "  Peak: %.1f MB\n" % mem_stats["peak_mb"]
	report += "  Average: %.1f MB\n" % mem_stats["average_mb"]
	report += "  Available: %.1f MB\n" % mem_stats["available_mb"]
	
	report += "\nSystem:\n"
	report += "  OS: %s\n" % system_info["os"]
	report += "  Processor: %s (%d cores)\n" % [system_info["processor_name"], system_info["processor_count"]]
	report += "  RAM: %.1f GB\n" % system_info["ram_gb"]
	report += "  GPU: %s\n" % system_info["render_api"]
	
	report += "\nPerformance Issues: %d\n" % performance_history.size()
	
	report += "========================\n"
	
	return report

func get_system_info() -> Dictionary:
	"""Get system information"""
	return system_info.duplicate()

func is_performance_degraded() -> bool:
	"""Check if performance is degraded"""
	return frame_time_ms > performance_threshold

func get_recommended_quality_preset() -> String:
	"""Recommend quality preset based on hardware"""
	var ram_gb = system_info.get("ram_gb", 4.0)
	var cores = system_info.get("processor_count", 2)
	
	if ram_gb < 4.5 or cores < 2:
		return "very_low"
	elif ram_gb < 8 or cores < 4:
		return "low"
	elif ram_gb < 16:
		return "medium"
	else:
		return "high"

func reset_statistics():
	"""Reset performance statistics"""
	frame_times.clear()
	memory_samples.clear()
	performance_history.clear()
	min_fps = 60
	max_fps = 60
	peak_memory_mb = memory_usage_mb
	print("Performance statistics reset")
