extends Node
class_name TestReportGenerator

## Test Report Generator - Generates comprehensive test and optimization reports

signal report_generated(report_type: String, filepath: String)

var multiplayer_test_system: MultiplayerTestSystem
var balance_test_system: BalanceTestSystem
var optimization_system: OptimizationSystem
var performance_monitor: PerformanceMonitor

var report_directory: String = "user://reports/"

func _ready():
	"""Initialize test report generator"""
	add_to_group("test_report_generator")
	_find_systems()
	_ensure_report_directory()
	print("Test report generator initialized")

func _find_systems():
	"""Find all test systems"""
	multiplayer_test_system = get_tree().get_first_node_in_group("multiplayer_test_system")
	balance_test_system = get_tree().get_first_node_in_group("balance_test_system")
	optimization_system = get_tree().get_first_node_in_group("optimization_system")
	performance_monitor = get_tree().get_first_node_in_group("performance_monitor")

func _ensure_report_directory():
	"""Ensure report directory exists"""
	if not DirAccess.dir_exists_absolute(report_directory):
		DirAccess.make_absolute(report_directory)

func generate_full_test_report() -> String:
	"""Generate complete test report with all subsystems"""
	var timestamp = Time.get_datetime_string_from_system()
	var filename = "full_test_report_%s.txt" % timestamp.replace(" ", "_").replace(":", "-")
	var filepath = report_directory + filename
	
	var report = ""
	report += "╔════════════════════════════════════════════════════════════════════╗\n"
	report += "║         WASTLAND REBORN - COMPLETE TEST REPORT                     ║\n"
	report += "║         Generated: %s\n" % timestamp
	report += "╚════════════════════════════════════════════════════════════════════╝\n\n"
	
	# Multiplayer Tests
	report += _generate_multiplayer_test_section()
	report += "\n"
	
	# Balance Tests
	report += _generate_balance_test_section()
	report += "\n"
	
	# Performance Report
	report += _generate_performance_section()
	report += "\n"
	
	# Optimization Report
	report += _generate_optimization_section()
	report += "\n"
	
	# Final Summary
	report += _generate_final_summary()
	
	# Save report
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file:
		file.store_string(report)
		print("Full test report saved to: %s" % filepath)
		report_generated.emit("full", filepath)
		return filepath
	else:
		print("Failed to save report")
		return ""

func _generate_multiplayer_test_section() -> String:
	"""Generate multiplayer test section"""
	var section = ""
	section += "┌─ MULTIPLAYER TESTS ─────────────────────────────────────────────────┐\n"
	
	if multiplayer_test_system:
		var results = multiplayer_test_system.get_test_summary()
		
		section += "│ Total Tests: %d                                                      │\n" % results["total_tests"]
		section += "│ Passed: %d | Failed: %d                                            │\n" % [results["passed"], results["failed"]]
		section += "│ Pass Rate: %.1f%%                                                   │\n" % results["pass_rate"]
		section += "│                                                                    │\n"
		
		for result in results["results"]:
			var status = "✓" if result.passed else "✗"
			section += "│ %s %-50s │\n" % [status, result.test_name]
	else:
		section += "│ Multiplayer test system not initialized                             │\n"
	
	section += "└────────────────────────────────────────────────────────────────────────┘"
	
	return section

func _generate_balance_test_section() -> String:
	"""Generate balance test section"""
	var section = ""
	section += "┌─ BALANCE TESTS ─────────────────────────────────────────────────────┐\n"
	
	if balance_test_system:
		var results = balance_test_system.get_balance_summary()
		
		section += "│ Total Issues: %d                                                   │\n" % results["total_issues"]
		section += "│ Warnings: %d | Critical: %d                                      │\n" % [results["warnings"], results["critical_issues"]]
		section += "│ Status: %s                                                    │\n" % results["status"]
		section += "│                                                                    │\n"
		
		if results["total_issues"] > 0:
			section += "│ Issues Found:                                                      │\n"
			for issue in results["issues"]:
				var issue_symbol = "⚠" if issue["type"] == "warning" else "✗"
				section += "│ %s %s: %s │\n" % [issue_symbol, issue["type"].to_upper(), issue["message"]]
		else:
			section += "│ ✓ No balance issues found!                                         │\n"
	else:
		section += "│ Balance test system not initialized                                │\n"
	
	section += "└────────────────────────────────────────────────────────────────────────┘"
	
	return section

func _generate_performance_section() -> String:
	"""Generate performance section"""
	var section = ""
	section += "┌─ PERFORMANCE METRICS ───────────────────────────────────────────────┐\n"
	
	if performance_monitor:
		var fps_stats = performance_monitor.get_fps_stats()
		var memory_stats = performance_monitor.get_memory_stats()
		var system_info = performance_monitor.get_system_info()
		
		section += "│ FPS: %d (Avg: %d, Min: %d, Max: %d)                                 │\n" % [
			fps_stats["current"], fps_stats["average"], fps_stats["min"], fps_stats["max"]
		]
		section += "│ Frame Time: %.2f ms                                                 │\n" % fps_stats["frame_time_ms"]
		section += "│                                                                    │\n"
		
		section += "│ Memory Usage: %.1f MB (Peak: %.1f MB)                              │\n" % [
			memory_stats["current_mb"], memory_stats["peak_mb"]
		]
		section += "│ Available Memory: %.1f MB                                           │\n" % memory_stats["available_mb"]
		section += "│                                                                    │\n"
		
		section += "│ System: %s                                          │\n" % system_info.get("os", "Unknown")
		section += "│ CPU: %s (%d cores)                    │\n" % [
			system_info.get("processor_name", "Unknown"), system_info.get("processor_count", 1)
		]
		section += "│ GPU: %s                   │\n" % system_info.get("render_api", "Unknown")
	else:
		section += "│ Performance monitor not initialized                                │\n"
	
	section += "└────────────────────────────────────────────────────────────────────────┘"
	
	return section

func _generate_optimization_section() -> String:
	"""Generate optimization section"""
	var section = ""
	section += "┌─ OPTIMIZATIONS ─────────────────────────────────────────────────────┐\n"
	
	if optimization_system:
		var results = optimization_system.get_optimization_results()
		var total_improvement = 0.0
		var applied = 0
		
		for result in results:
			if result.applied:
				applied += 1
				total_improvement += result.improvement_percent
		
		section += "│ Total Optimizations: %d                                             │\n" % results.size()
		section += "│ Applied: %d/%d                                                      │\n" % [applied, results.size()]
		section += "│ Total Improvement: %.1f%%                                           │\n" % total_improvement
		section += "│                                                                    │\n"
		
		for result in results:
			var status = "✓" if result.applied else "○"
			section += "│ %s %-40s +%.1f%% │\n" % [status, result.name, result.improvement_percent]
	else:
		section += "│ Optimization system not initialized                                │\n"
	
	section += "└────────────────────────────────────────────────────────────────────────┘"
	
	return section

func _generate_final_summary() -> String:
	"""Generate final summary"""
	var section = ""
	section += "┌─ FINAL SUMMARY ─────────────────────────────────────────────────────┐\n"
	
	# Overall status determination
	var status = "READY FOR RELEASE"
	var details = []
	
	if multiplayer_test_system:
		var mp_results = multiplayer_test_system.get_test_summary()
		if mp_results["pass_rate"] < 90:
			status = "NEEDS MORE TESTING"
			details.append("Multiplayer test pass rate: %.1f%%" % mp_results["pass_rate"])
	
	if balance_test_system:
		var balance_results = balance_test_system.get_balance_summary()
		if balance_results["critical_issues"] > 0:
			status = "CRITICAL ISSUES FOUND"
			details.append("Balance critical issues: %d" % balance_results["critical_issues"])
	
	if performance_monitor:
		var metrics = performance_monitor.get_fps_stats()
		if metrics["current"] < 30:
			status = "PERFORMANCE CRITICAL"
			details.append("FPS below 30: %d" % metrics["current"])
	
	section += "│ Status: %s\n" % status
	section += "│\n"
	
	if details.size() > 0:
		for detail in details:
			section += "│ • %s\n" % detail
	else:
		section += "│ ✓ All systems operational\n"
		section += "│ ✓ No critical issues detected\n"
		section += "│ ✓ Performance acceptable\n"
	
	section += "│\n"
	section += "│ Recommendation: %s\n" % _get_recommendation(status)
	section += "└────────────────────────────────────────────────────────────────────────┘"
	
	return section

func _get_recommendation(status: String) -> String:
	"""Get recommendation based on status"""
	match status:
		"READY FOR RELEASE":
			return "Proceed with release preparation"
		"NEEDS MORE TESTING":
			return "Run additional tests and validate fixes"
		"CRITICAL ISSUES FOUND":
			return "Fix critical balance issues before release"
		"PERFORMANCE CRITICAL":
			return "Apply aggressive optimizations before release"
		_:
			return "Review results and address issues"

func generate_quick_summary() -> String:
	"""Generate quick summary report"""
	var summary = ""
	summary += "WASTLAND REBORN - QUICK TEST SUMMARY\n"
	summary += "=====================================\n\n"
	
	if multiplayer_test_system:
		var mp = multiplayer_test_system.get_test_summary()
		summary += "Multiplayer Tests: %d/%d passed (%.1f%%)\n" % [mp["passed"], mp["total_tests"], mp["pass_rate"]]
	
	if balance_test_system:
		var balance = balance_test_system.get_balance_summary()
		summary += "Balance Tests: %d issues (%d critical)\n" % [balance["total_issues"], balance["critical_issues"]]
	
	if optimization_system:
		var opt = optimization_system.get_optimization_results()
		var applied = 0
		for result in opt:
			if result.applied:
				applied += 1
		summary += "Optimizations: %d/%d applied\n" % [applied, opt.size()]
	
	if performance_monitor:
		var perf = performance_monitor.get_fps_stats()
		summary += "Performance: %d FPS (avg: %d)\n" % [perf["current"], perf["average"]]
	
	return summary

func get_test_status() -> Dictionary:
	"""Get overall test status"""
	var status = {
		"multiplayer_ready": false,
		"balance_valid": false,
		"performance_acceptable": false,
		"ready_for_release": false
	}
	
	if multiplayer_test_system:
		var mp = multiplayer_test_system.get_test_summary()
		status["multiplayer_ready"] = mp["pass_rate"] >= 90
	
	if balance_test_system:
		var balance = balance_test_system.get_balance_summary()
		status["balance_valid"] = balance["critical_issues"] == 0
	
	if performance_monitor:
		var perf = performance_monitor.get_fps_stats()
		status["performance_acceptable"] = perf["current"] >= 30
	
	status["ready_for_release"] = status["multiplayer_ready"] and status["balance_valid"] and status["performance_acceptable"]
	
	return status
