extends Node

class_name Utils

static func disableNode(node : Node):
	node.hide()
	node.process_mode = PROCESS_MODE_DISABLED
	
static func enableNode(node : Node):
	node.show()
	node.process_mode = PROCESS_MODE_INHERIT
