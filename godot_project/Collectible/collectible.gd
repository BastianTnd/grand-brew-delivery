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
		# Destroy Collectible
		self.queue_free()
	
# Sets Sprite depending on collectible Type
func change_sprite() -> void:
	# Malt Sprite
	if collectible == collectible_type.MALT:
		var texture = load(malt_sprite)
		collectible_sprite.texture = texture
		
	# Hops Sprite
	if collectible == collectible_type.HOPS:
		var texture = load(hops_sprite)
		collectible_sprite.texture = texture
	
	# Yeast Sprite
	if collectible == collectible_type.YEAST:
		var texture = load(yeast_sprite)
		collectible_sprite.texture = texture
