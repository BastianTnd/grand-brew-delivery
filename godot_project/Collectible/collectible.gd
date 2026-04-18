class_name Collectible
extends Area2D

@onready var collectible_sprite: Sprite2D = $Sprite2D
@export var collectible: collectible_type
enum collectible_type {MALT, HOPS, YEAST}



var malt_sprite = "res://Collectible/Sprites/Malz_M.png"
var hops_sprite = "res://Collectible/Sprites/Hops_H.png"
var yeast_sprite = "res://Collectible/Sprites/Yeast_Y.png"

func _ready() -> void:
	change_sprite()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if ScoreManager:
			ScoreManager.collect_item()
		self.queue_free()
	
func change_sprite() -> void:
	if collectible == collectible_type.MALT:
		collectible_sprite.texture = load(malt_sprite)
	elif collectible == collectible_type.HOPS:
		collectible_sprite.texture = load(hops_sprite)
	elif collectible == collectible_type.YEAST:
		collectible_sprite.texture = load(yeast_sprite)
