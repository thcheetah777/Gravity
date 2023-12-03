extends Node
class_name LevelManager

@export var targets: Array[Target]
@export var target_counter: HBoxContainer
@export var target_ui_lit: Texture2D
@export var target_ui_unlit: Texture2D
@export var ui_scale = 1.4
@export var ui_scale_smoothing = 3
@export var end_panel: Panel
@export var rank: TextureRect
@export var time_container: Control
@export var time_text: Label

var targets_left: Array[Target]
var level_ended = false

func _enter_tree() -> void:
	Globals.level_manager = self
	targets_left = targets.duplicate()

func _ready() -> void:
	for target in targets:
		var target_ui = TextureRect.new()
		target_ui.texture = target_ui_unlit
		target_ui.pivot_offset = Vector2(4, 8)
		target_counter.add_child(target_ui)

func _process(delta: float) -> void:
	rank.scale = rank.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)
	time_container.scale = time_container.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)

	for target in target_counter.get_children():
		target.scale = target.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)

func update_current_target():
	targets_left.front().on_opened()

func pop_target():
	var popped_target = targets_left.pop_front()
	popped_target.on_touched()

	var target_ui = target_counter.get_child(targets.size() - targets_left.size() - 1)
	target_ui.texture = target_ui_lit
	target_ui.scale = ui_scale * Vector2.ONE

	if targets_left.size() <= 0:
		end_level()
	else:
		update_current_target()

	Globals.alert.show_alert(str(targets_left.size()) + " more to go!")

func end_level():
	level_ended = true
	Events.level_end.emit()
	target_counter.hide()
	end_panel.show()

	await get_tree().create_timer(1.0).timeout

	rank.scale = ui_scale * Vector2.ONE
	rank.show()

	await get_tree().create_timer(1.0).timeout

	time_container.scale = ui_scale * Vector2.ONE
	time_text.text = str(Globals.timer.text)
	time_container.show()
