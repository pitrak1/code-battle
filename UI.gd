extends Control

func setup(parent):
	$RestartPanel/RestartButton.connect("pressed", parent, "_on_restart")
	$NextPanel/NextButton.connect("pressed", parent, "_on_next")
	$SelectFilePanel/SelectFileButton.connect("pressed", self, "__on_select_file_pressed")
	$FileDialog.connect("file_selected", parent, "_on_select_file")
	clear_code_position()
	clear_file()
	
func clear_code_position():
	set_code_position('', '')
	
func set_code_position(line, instruction):
	$CodePositionPanel/LineValue.text = line
	$CodePositionPanel/InstructionValue.text = instruction
	
func clear_file():
	$FilePanel/FileValue.text = ''
	
func set_file(path):
	var words = path.rsplit('/', false, 1)
	$FilePanel/FileValue.text = words[1]
	
func __on_select_file_pressed():
	$FileDialog.popup()
