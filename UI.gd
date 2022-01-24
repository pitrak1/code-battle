extends Control

func setup(parent):
	$RestartPanel/RestartButton.connect("pressed", parent, "_on_restart")
	$NextPanel/NextButton.connect("pressed", parent, "_on_next")
	$SelectFilePanel/SelectFileButton.connect("pressed", self, "__on_select_file_pressed")
	$FileDialog.connect("file_selected", parent, "_on_select_file")
	
func set_code_position(line, instruction):
	$CodePositionPanel/InstructionValue.text = line
	$CodePositionPanel/InstructionValue.text = instruction
	
func set_file(file):
	$FilePanel/FileValue.text = file
	
func __on_select_file_pressed():
	$FileDialog.popup()
