// TensorScript grammar sketch.
//
// This PEG file documents the current hand-written C++ parser. It is not used
// to generate parser.cpp; keep parser.cpp, lexer.cpp, and this file in sync.

Start
  = _ Program _

Program
  = TopStatement*

TopStatement
  = Attribute? TemplateDeclaration
  / Attribute? Modifier* ImportDeclaration
  / Attribute? Modifier* ClassDeclaration
  / Attribute? Modifier* ObjectDeclaration
  / Attribute? Modifier* FunctionDeclaration
  / Statement

Modifier
  = "constexpr" __
  / "external" __
  / "unsafe" __

Attribute
  = "[@" _ AttributeExpression _ "]" _

AttributeExpression
  = Identifier CallArguments?
  / StringLiteral
  / IntegerLiteral

ImportDeclaration
  = "import" __ QualifiedName StatementEnd?

TemplateDeclaration
  = "template" _ "<" _ TemplateParameter (_ "," _ TemplateParameter)* _ ">" _
    ("def" __ FunctionRest / "class" __ ClassRest)

TemplateParameter
  = ("typename" / "class") __ Identifier
  / IntegralType __ Identifier

ClassDeclaration
  = "class" __ ClassRest

ClassRest
  = Identifier _ ParameterList? _ ("extends" __ Identifier _)? ClassBody?

ClassBody
  = "{" _ (FunctionDeclaration / VariableDeclaration StatementEnd?)* _ "}"

ObjectDeclaration
  = "object" __ Identifier _ ("{" _ Statement* _ "}" / "=" _ ("{" _ Statement* _ "}" / Expression))

FunctionDeclaration
  = "def" __ FunctionRest

FunctionRest
  = Identifier _ "(" _ Parameters? _ ")" _ (":" _ Type)? _
    ("=" _ Expression / "{" _ Statement* _ "}")?

Parameters
  = Parameter (_ "," _ Parameter)*

Parameter
  = Identifier _ ":" _ Type

VariableDeclaration
  = ("val" / "var") __ Identifier _ (":" _ Type)? _ "=" _ Expression

Statement
  = "constexpr" __ Statement
  / "unsafe" _ ("{" _ Statement* _ "}" / FunctionDeclaration)
  / "unatomic" _ "{" _ Statement* _ "}"
  / VariableDeclaration StatementEnd?
  / IfStatement
  / ForStatement
  / WhileStatement
  / FunctionDeclaration
  / ReturnStatement
  / MapStatement
  / PMapStatement
  / ReduceStatement
  / FilterStatement
  / ObjectDeclaration
  / Expression StatementEnd?

IfStatement
  = "if" _ "constexpr"? _ "(" _ Expression _ ")" _ Block (_ "else" _ (Block / IfStatement))?

ForStatement
  = "for" _ "(" _ Identifier _ "<-" _ Expression (_ ("to" / "until") __ Expression)? _ ")" _ Block

WhileStatement
  = "while" _ "(" _ Expression _ ")" _ Block

MapStatement
  = "map" _ "(" _ Identifier _ "<-" _ Expression _ ")" _ Block

PMapStatement
  = "pmap" _ "(" _ Identifier _ "<-" _ Expression _ ")" _ Block

ReduceStatement
  = "reduce" _ "(" _ Identifier _ "<-" _ Expression _ "," _ Expression _ ")" _ Block

FilterStatement
  = "filter" _ "(" _ Identifier _ "<-" _ Expression _ ")" _ Block

ReturnStatement
  = "return" (__ Expression)? StatementEnd?

Block
  = "{" _ Statement* _ "}"

Expression
  = MatchExpression
  / AssignmentExpression

MatchExpression
  = OrExpression (_ "match" _ "{" _ MatchCase* _ "}")?

MatchCase
  = "case" __ PrimaryExpression _ "=>" _ Expression

AssignmentExpression
  = OrExpression (_ ("=" / "<-" / "+=" / "-=" / "*=" / "/=" / "%=") _ Expression)?

OrExpression
  = AndExpression (_ "or" __ AndExpression)*

AndExpression
  = BitwiseOrExpression (_ "and" __ BitwiseOrExpression)*

BitwiseOrExpression
  = XorExpression (_ "|" _ XorExpression)*

XorExpression
  = BitwiseAndExpression (_ ("xor" / "^") _ BitwiseAndExpression)*

BitwiseAndExpression
  = EqualityExpression (_ "&" _ EqualityExpression)*

EqualityExpression
  = ComparisonExpression (_ ("==" / "!=") _ ComparisonExpression)*

ComparisonExpression
  = ShiftExpression (_ ("<=" / ">=" / "<" / ">") _ ShiftExpression)*

ShiftExpression
  = AdditiveExpression (_ ("<<" / ">>") _ AdditiveExpression)*

AdditiveExpression
  = MultiplicativeExpression (_ ("+" / "-") _ MultiplicativeExpression)*

MultiplicativeExpression
  = PrefixExpression (_ ("*" / "/" / "%" / "@" / "inner" / "outer" / "tensor") _ PrefixExpression)*

PrefixExpression
  = ("++" / "--" / "<-" / "&mut" / "&" / "+" / "-" / "!" / "~" / "*") _ PrefixExpression
  / PostfixExpression

PostfixExpression
  = PrimaryExpression (_ ("++" / "--" / IndexSuffix))*

IndexSuffix
  = "[" _ Expression (_ "," _ Expression)* _ "]"

PrimaryExpression
  = IfStatement
  / LambdaExpression
  / NewExpression
  / ArrayLiteral
  / Block
  / "(" _ Expression _ ")"
  / QualifiedName TemplateArguments? CallArguments?
  / Literal
  / InlineMath
  / BlockMath
  / "_"

LambdaExpression
  = "[" _ ("&" / "=" / IdentifierList?) _ "]" _ "(" _ LambdaParameters? _ ")" _ "->" _ Block

LambdaParameters
  = LambdaParameter (_ "," _ LambdaParameter)*

LambdaParameter
  = Identifier (_ ":" _ Type)?

NewExpression
  = "new" __ Identifier TemplateArguments? (_ "[" _ Expression (_ "," _ Expression)* _ "]" / CallArguments)?

ArrayLiteral
  = "[" _ (Expression (_ "," _ Expression)*)? _ "]"

CallArguments
  = "(" _ (Expression (_ "," _ Expression)*)? _ ")"

TemplateArguments
  = "<" _ TemplateArgument (_ "," _ TemplateArgument)* _ ">"

TemplateArgument
  = Type
  / Literal

Type
  = "box" __ Type
  / "&" _ "mut"? _ Type
  / "unsafe" _ "*" _ Type
  / FunctionType
  / Identifier TemplateArguments?

FunctionType
  = "(" _ (Type (_ "," _ Type)*)? _ ")" _ "=>" _ Type

Literal
  = BooleanLiteral
  / CharLiteral
  / StringLiteral
  / HexLiteral
  / BinaryLiteral
  / OctalLiteral
  / FloatLiteral
  / IntegerLiteral

InlineMath
  = "$" (!"$" .)* "$"

BlockMath
  = "$$" (!"$$" .)* "$$"

IdentifierList
  = Identifier (_ "," _ Identifier)*

QualifiedName
  = Identifier (_ "." _ Identifier)*

Identifier
  = !ReservedWord [A-Za-z_\u0080-\uFFFF] [A-Za-z0-9_\u0080-\uFFFF]*
  / "box"

ReservedWord
  = ("abstract" / "case" / "catch" / "class" / "def" / "do" / "else" /
     "extends" / "external" / "false" / "final" / "finally" / "for" /
     "if" / "import" / "match" / "mut" / "new" / "null" / "object" /
     "return" / "super" / "template" / "this" / "true" / "typename" /
     "unsafe" / "unatomic" / "val" / "var" / "while") ![A-Za-z0-9_]

IntegralType
  = "Int" / "Long" / "Short" / "Byte" / "Boolean" / "Bool"

BooleanLiteral
  = "true" / "false"

StringLiteral
  = "\"" ("\\" . / !"\"" .)* "\""

CharLiteral
  = "'" ("\\" . / !"'" .) "'"

HexLiteral
  = "0" [xX] [0-9a-fA-F]+

BinaryLiteral
  = "0" [bB] [01]+

OctalLiteral
  = "0" [oO] [0-7]+

FloatLiteral
  = [0-9]+ "." [0-9]* ([eE] [+-]? [0-9]+)?
  / [0-9]+ [eE] [+-]? [0-9]+

IntegerLiteral
  = [0-9]+

StatementEnd
  = _ ";" _

_
  = ([ \t\r\n] / Comment)*

__
  = ([ \t\r\n] / Comment)+

Comment
  = "//" (![\r\n] .)*
  / "/*" (!"*/" .)* "*/"
