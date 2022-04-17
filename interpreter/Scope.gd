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

func print_scope():
	print('local')
	__print_scope_subset(local)
	print('exported')
	__print_scope_subset(exported)
	print()
	
func __print_scope_subset(__subset):
	for key in __subset.keys():
		if __subset[key] and typeof(__subset[key]) == TYPE_DICTIONARY:
			print('\t' + key + ': ')
			for __key in local[key].keys():
				print('\t\t' + __key + ': ' + str(local[key][__key]))
		else:
			print('\t' + key + ': ' + str(local[key]))
