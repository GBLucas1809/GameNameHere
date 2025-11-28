extends Node

static var is_mode_on = false


static func get_defense_shield(node_path):
	pass

static func defense(node_path):
	var _shield_node = get_defense_shield(node_path)

	if not _shield_node:
		print("Node not found...")
		return null
	 
	if _shield_node.visible == false: 
		_shield_node.visible

