
var __whitespace_regex

func setup():
	__whitespace_regex = RegEx.new()
	__whitespace_regex.compile("\\S+")

func parse(line):
	var words = __get_words(line)
	print(words)
		
func __get_words(line):
	var words = []
	for word in __whitespace_regex.search_all(line):
		words.push_back(word.get_string())
	return words
	
