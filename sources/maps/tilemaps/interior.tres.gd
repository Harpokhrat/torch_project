tool
extends TileSet


func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	if drawn_id in [0, 1] and neighbor_id in [0, 1]:
		return true
	return false
