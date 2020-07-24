extends Node

export(int) var max_health = 4
onready var health = max_health setget set_health

signal no_health

func set_health(new_health):
	health = new_health
	if health <= 0:
		emit_signal("no_health")