extends RefCounted
## 测试断言工具：每个断言立即 print PASS/FAIL，累计计数

var _pass_count: int = 0
var _fail_count: int = 0


func assert_eq(actual, expected, msg: String) -> void:
	if actual == expected:
		_pass(msg)
	else:
		_fail(msg, "expected %s, got %s" % [str(expected), str(actual)])


func assert_true(value: bool, msg: String) -> void:
	if value:
		_pass(msg)
	else:
		_fail(msg, "expected true, got false")


func assert_false(value: bool, msg: String) -> void:
	if not value:
		_pass(msg)
	else:
		_fail(msg, "expected false, got true")


func assert_not_null(value, msg: String) -> void:
	if value != null:
		_pass(msg)
	else:
		_fail(msg, "expected non-null, got null")


func assert_is_null(value, msg: String) -> void:
	if value == null:
		_pass(msg)
	else:
		_fail(msg, "expected null, got %s" % str(value))


func assert_approx_eq(actual: float, expected: float, tolerance: float, msg: String) -> void:
	if absf(actual - expected) <= tolerance:
		_pass(msg)
	else:
		_fail(msg, "expected ~%s (±%s), got %s" % [str(expected), str(tolerance), str(actual)])


func assert_gt(actual: float, threshold: float, msg: String) -> void:
	if actual > threshold:
		_pass(msg)
	else:
		_fail(msg, "expected > %s, got %s" % [str(threshold), str(actual)])


func assert_lte(actual: float, threshold: float, msg: String) -> void:
	if actual <= threshold:
		_pass(msg)
	else:
		_fail(msg, "expected <= %s, got %s" % [str(threshold), str(actual)])


func get_pass_count() -> int:
	return _pass_count


func get_fail_count() -> int:
	return _fail_count


func reset() -> void:
	_pass_count = 0
	_fail_count = 0


func _pass(msg: String) -> void:
	_pass_count += 1
	print("  PASS: %s" % msg)


func _fail(msg: String, detail: String) -> void:
	_fail_count += 1
	print("  FAIL: %s -- %s" % [msg, detail])
