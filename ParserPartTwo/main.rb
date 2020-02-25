load "Parser.rb"
load "Lexer.rb"
load "Token.rb"
load "AST.rb"

parse = Parser.new("input4.tiny")
mytree = parse.program()
puts mytree.toStringList()
