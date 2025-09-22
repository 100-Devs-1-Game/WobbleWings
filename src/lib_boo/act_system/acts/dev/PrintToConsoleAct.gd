class_name PrintToConsoleAct extends NodeAct

signal printed_to_console(theMsg)
@export_multiline var printText:String

func Execute(param = null):
	var msg_to_print: String
	
	# Handle different parameter types
	if param == null:
		msg_to_print = printText
	elif param is String:
		msg_to_print = param
	else:
		msg_to_print = "PrintToConsoleAct: Unsupported type: " + str(typeof(param)) + " - " + str(param) # Convert any other type to string
	
	print(msg_to_print)
	printed_to_console.emit(msg_to_print)
