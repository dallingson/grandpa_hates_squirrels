extends Node

func _ready():
	# Get the background sprite
	var bg_sprite = get_node("ParallaxBackground/ParallaxLayer/BackyardSprite")
	if bg_sprite:
		# Enable region and set to top half
		bg_sprite.region_enabled = true
		var texture_size = bg_sprite.texture.get_size()
		bg_sprite.region_rect = Rect2(0, 0, texture_size.x, texture_size.y / 2)
		
		# Position it higher to show more sky
		bg_sprite.position.y = -texture_size.y / 4