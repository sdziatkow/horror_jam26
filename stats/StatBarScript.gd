class_name StatBar
extends ProgressBar

var _stat: StatVal
func give_stat(stat: StatVal) -> void:
	_stat = stat
	
func _ready() -> void:
	set_up()
	
func set_up() -> void:
	_stat.val_changed.connect(update_val)
	_stat.max_changed.connect(update_max)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	match(_stat._type):
		StatVal.StatType.HEALTH:
			style.bg_color = Color.DARK_RED
		StatVal.StatType.STAMINA:
			style.bg_color = Color.DARK_GREEN
	style.bg_color.a = 0.5
	add_theme_stylebox_override("fill", style)
	self.min_value = 0.0
	self.max_value = _stat.get_max()
	self.value = _stat.get_val()
	
func update_val(new_val: float) -> void:
	self.value = new_val
	
func update_max(new_max: float) -> void:
	self.max_value = new_max
