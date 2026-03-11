extends Node2D

@export var base_energy := 1.2
@export var energy_variation := 0.18
@export var base_flame_scale := Vector2.ONE
@export var scale_variation := 0.05
@export var flicker_speed := 14.0

@onready var flame_sprite: Sprite2D = $Sprite2D
@onready var point_light: PointLight2D = $PointLight2D

var _rng := RandomNumberGenerator.new()
var _target_energy := base_energy
var _target_scale := base_flame_scale

func _ready() -> void:
	_rng.randomize()
	_target_energy = base_energy
	_target_scale = base_flame_scale
	point_light.energy = base_energy
	flame_sprite.scale = base_flame_scale

func _process(delta: float) -> void:
	_target_energy = base_energy + _rng.randf_range(-energy_variation, energy_variation)
	var scale_offset := _rng.randf_range(-scale_variation, scale_variation)
	_target_scale = base_flame_scale + Vector2(scale_offset, scale_offset)

	var blend := clampf(delta * flicker_speed, 0.0, 1.0)
	point_light.energy = lerpf(point_light.energy, _target_energy, blend)
	flame_sprite.scale = flame_sprite.scale.lerp(_target_scale, blend)
