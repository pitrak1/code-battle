var Scope = preload("res://interpreter/Scope.gd")

var scopes = []

func _init():
	scopes.push_back(Scope.new())

func find_variable(__key):
	var __index = scopes.size() - 1
	while __index >= 0:
		var __value = scopes[__index].find_variable(__key)
		if __value:
			return __value
		else:
			__index -= 1

func create_new_scope():
	scopes.push_back(Scope.new())

func add_local_variable(__key, __value):
	add_variable(false, __key, __value)

func add_exported_variable(__key, __value):
	add_variable(true, __key, __value)

func add_variable(__exported, __key, __value):
	scopes[scopes.size() - 1].add_variable(__exported, __key, __value)

func destroy_scope():
	scopes.pop_back()

func import_scope(__scopes):
	var __scope = __scopes.get_scope(0)
	for __key in __scope.exported.keys():
		add_local_variable(__key, __scope.exported[__key])

func get_export():
	return scopes[scopes.size() - 1].exported

func get_scope(__index):
	return scopes[__index]
	
func print_scopes():
	for __scope in scopes:
		print('local')
		for key in __scope.local.keys():
			print('\t' + key + ': ' + str(__scope.local[key]))
		print('exported')
		for key in __scope.exported.keys():
			print('\t' + key + ': ' + str(__scope.exported[key]))
		print()
