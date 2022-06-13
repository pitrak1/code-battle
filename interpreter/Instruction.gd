var type
var operator
var left
var right
var value
var exported
var expression
var instructions
var function
var args
var index

func set_operation(__type, __operator, __left, __right):
	type = __type
	operator = __operator
	left = __left
	right = __right
	return self

func set_value(__type, __value, __exported = null):
	type = __type
	value = __value
	exported = __exported
	return self

func set_call(__type, __function, __args):
	type = __type
	function = __function
	args = __args
	return self

func set_if(__type, __expression):
	type = __type
	expression = __expression
	instructions = []
	return self

func set_index(__type, __value, __index):
	type = __type
	value = __value
	index = __index
	return self

func set_function(__type, __value, __args):
	type = __type
	value = __value
	args = __args
	instructions = []
	return self

func set_class(__type):
	type = __type
	instructions = []
	return self
