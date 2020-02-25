# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# EPSILON    -->   ""
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Lexer.rb"
class Parser < Scanner

    def initialize(filename)
        super(filename)
        consume()
    end

    def consume()
        @lookahead = nextToken()
        while(@lookahead.type == Token::WS)
            @lookahead = nextToken()
        end
    end

    def match(dtype)
        if (@lookahead.type != dtype)
            puts "Expected #{dtype} found #{@lookahead.text}"
			@errors_found+=1
        end
        consume()
    end

    def program() # correct
    	@errors_found = 0
		
		p = AST.new(Token.new("program","program"))
		
	    while( @lookahead.type != Token::EOF)
            p.addChild(statement()) # since each node can have more than 2 children, but statement is not included in the AST tree.
        end
        puts "There were #{@errors_found} parse errors found."
      
		return p
    end

    def statement() # correct
		stmt = AST.new(Token.new("statement","statement")) # create AST subtree
        if (@lookahead.type == Token::PRINT)
			stmt = AST.new(@lookahead) # set subtree equal to lookahead when it's the expected token in grammar rule.
            match(Token::PRINT)
            stmt.addChild(exp()) # add the second half of the rule as a child
        else
            stmt = assign() # else, simply let stmt be the other possible rule
        end
		return stmt
    end

    def exp() # term etail
		exp = AST.new(Token.new("expression", "expression"))
		term = term()
		etail = etail()
		if etail != nil
			etail_child = etail.getFirstChild()
			exp = AST.new(etail)
			exp.addChild(term)
			exp.addChild(etail_child)
		else
			exp = term
		end
		return exp
    end

    def term() # factor ttail
		term = AST.new(Token.new("term", "term"))
		factor = factor()
		ttail = ttail()
		if ttail != nil
			ttail_child = ttail.getFirstChild()
			term = AST.new(ttail)
			term.addChild(factor)
			term.addChild(ttail_child)
		else
			term = factor
		end
		return term
    end

    def factor() # ( exp ) | int | id
		factor = AST.new(Token.new("factor", "factor"))
        if (@lookahead.type == Token::LPAREN)
            match(Token::LPAREN)
            if (@lookahead.type == Token::RPAREN)
                match(Token::RPAREN)
            else
				factor = exp()
				match(Token::RPAREN)
            end
        elsif (@lookahead.type == Token::INT)
			inttoken = AST.new(@lookahead)
            match(Token::INT)
			factor = inttoken
        elsif (@lookahead.type == Token::ID)
			factor = AST.new(@lookahead)
            match(Token::ID)
        else
            puts "Expected ( or INT or ID found #{@lookahead.text}"
            @errors_found+=1
            consume()
        end
		return factor
    end

    def ttail() # * factor ttail
		ttail = AST.new(Token.new("ttail", "ttail"))
        if (@lookahead.type == Token::MULTOP)
			ttail = AST.new(@lookahead)
            match(Token::MULTOP)
			ttail.addChild(factor())
			ttail.addChild(ttail())
			
        elsif (@lookahead.type == Token::DIVOP)
            ttail = AST.new(@lookahead)
			match(Token::DIVOP)
            ttail.addChild(factor())
            ttail.addChild(ttail())
		else
			return nil
        end
		return ttail
    end

    def etail()
		etail = AST.new(Token.new("etail", "etail"))
        if (@lookahead.type == Token::ADDOP)
			etail = AST.new(@lookahead)
			match(Token::ADDOP)
			etail.addChild(term())
			etail.addChild(etail())
        elsif (@lookahead.type == Token::SUBOP)
			etail = AST.new(@lookahead)
            match(Token::SUBOP)
            etail.addChild(term())
            etail.addChild(etail())
		else
			return nil
        end
		return etail
    end

    def assign()
        assgn = AST.new(Token.new("assignment","assignment"))
		if (@lookahead.type == Token::ID)
			idtok = AST.new(@lookahead)
			match(Token::ID)
			if (@lookahead.type == Token::ASSGN)
				assgn = AST.new(@lookahead)
            	match(Token::ASSGN)
				assgn.addChild(idtok)
				assgn.addChild(exp())
        	else
				match(Token::ASSGN)
			end
		else
			match(Token::ID)
        end
		return assgn
	end
end
