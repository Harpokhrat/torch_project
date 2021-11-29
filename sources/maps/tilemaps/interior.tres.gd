tool
extends TileSet

var neighbor_tilesets = [0, 1, 2]


func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	if drawn_id in neighbor_tilesets and neighbor_id in neighbor_tilesets:
		return true
	return false
