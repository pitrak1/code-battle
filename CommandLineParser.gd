var __whitespace_regex

func setup():
	__whitespace_regex = RegEx.new()
	__whitespace_regex.compile("\\S+")

func parse(line):
	var words = __get_words(line)
	__first_word(words)
		
func __get_words(line):
	var words = []
	for word in __whitespace_regex.search_all(line):
		words.push_back(word.get_string())
	return words
	
func __first_word(words):
	match words[0]:
		'ls':
			self.__ls(words)
		'run':
			self.__run(words)
		_:
			print('error')
	
func __ls(words):
	print('ls')
	
func __run(words):
	print('run')
	

