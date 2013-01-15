module lang::qls::syntax::QLS

// TODO support trailing empty lines
start syntax QLS
  = qls: Statement+ statements
  ;

syntax Statement
  = @Foldable statement: ClassDefinition
  | @Foldable statement: TypeStyleDefinition
  | @Foldable statement: ClassStyleDefinition
  | @Foldable statement: IdentStyleDefinition
  ;

syntax ClassDefinition
  = classDefinition: "class" Ident "{" QuestionIdent+ "}"
  ;

syntax TypeStyleDefinition
  = typeStyleDefinition: Type "{" StyleRule+ "}"
  ;

syntax ClassStyleDefinition
  = classStyleDefinition: ClassIdent "{" StyleRule+ "}"
  ;

syntax IdentStyleDefinition
  = identStyleDefinition: QuestionIdent "{" StyleRule+ "}"
  ;

syntax StyleRule
  = styleRule: StyleAttr StyleAttrValue
  ; 

lexical ClassIdent
  = [.]Ident
  ; 

lexical QuestionIdent
  = [#]Ident
  ;

lexical Ident
  = @category="Variable" ([a-z A-Z 0-9 _] !<< [a-z A-Z][a-z A-Z 0-9 _]* !>> [a-z A-Z 0-9 _]) \ Keywords;

lexical Type
  = @category="Type" "boolean"
  | @category="Type" "integer"
  | @category="Type" "money"
  | @category="Type" "date"
  | @category="Type" "string"
  ; 

lexical StyleAttr
  = @category="Constant" "type"
  | @category="Constant" "width"
  ;

syntax StyleAttrValue
  = styleAttrValue: StyleTypeValue
  | styleAttrValue: Int
  ;

lexical StyleTypeValue
  = @category="Constant" "radio"
  | @category="Constant" "checkbox"
  ;

lexical Int
  = [0-9]+ !>> [0-9]
  ;

syntax WhitespaceOrComment 
  = whitespace: Whitespace whitespace
  | comment: Comment comment
  ;
  
lexical Comment 
  = @category="Comment" "/*" CommentChar* "*/"
  | @category="Comment" "//" ![\n]* $
  ;

lexical CommentChar
  = ![*]
  | [*] !>> [/]
  ;

lexical Whitespace = [\u0009-\u000D \u0020 \u0085 \u00A0 \u1680 \u180E \u2000-\u200A \u2028 \u2029 \u202F \u205F \u3000];

layout Standard = WhitespaceOrComment* !>> [\ \t\n\f\r] !>> "//" !>> "/*";

keyword Keywords 
  = boolean: "boolean"
  | \int: "integer"
  | money: "money"
  | date: "date"
  | string: "string"
  | form: "class"
  | \type: "type"
  | width: "width"
  | radio: "radio"
  | checkbox: "checkbox"
  ;
