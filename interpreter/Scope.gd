var local = {}
var exported = {}

func add_local_variable(__key, __value):
	add_variable(false, __key, __value)

func add_exported_variable(__key, __value):
	add_variable(true, __key, __value)

func add_variable(__exported, __key, __value):
	if __exported:
		exported[__key] = __value
	else:
		local[__key] = __value

func find_variable(__key):
	if local.has(__key):
		return local[__key]
	if exported.has(__key):
		return exported[__key]