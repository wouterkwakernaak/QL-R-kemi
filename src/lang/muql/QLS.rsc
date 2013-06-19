module lang::muql::QLS

extend lang::muql::Lexical;

start syntax Stylesheet
  = stylesheet: "stylesheet" Ident "{" Rule* rules "}";

syntax Rule
  = @Foldable page: "page" String title "{" Rule* rules "}"
  | @Foldable section: "section" String title "{" Rule* rules "}"
  | @Foldable question: "question" Id name
  | @Foldable styledQuestion: "question" Id name "{" Style* "}"
  | @Foldable defaultStyle: "default" Type type "{" Style* "}"
  ;

syntax Style
  = style: Id property ":" Value val
  ;

syntax Value
  = Integer
  | Money
  | String
  | Id
  ;
  
