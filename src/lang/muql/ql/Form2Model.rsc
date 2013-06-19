module lang::muql::ql::Form2Model

import lang::muql::ql::QL;
import lang::muql::ql::Expr2JS;
import lang::muql::ql::Types;
import ParseTree;
import List;

// todo: separate qName in utils or something
str qName(Question q) = "<q.var>_<q@\loc.offset>";

// needs bind
str form2model(Form f, str name) {
   fields = form2fields(f);
   return "function <name>Model() {
          '  var self = this;
          '  <intercalate("\n", fields)>
          '}";
}

list[str] form2fields(Form f) = ( [] | it + toFields(q, (Expr)`true`) | q <- f.questions );

list[str] toFields((Question)`if (<Expr c>) <Question q>`, Expr cond) = 
   toFields(q, (Expr)`<Expr cond> && <Expr c>`);

list[str] toFields((Question)`if (<Expr c>) <Question q1> else <Question q2>`) 
  = toFields(q1, (Expr)`<Expr cond> && <Expr c>`)
  + toFields(q2, (Expr)`<Expr cond> && !(<Expr c>)`);

list[str] toFields((Question)`{ <Question* qs> }`, Expr cond) 
  = ( [] | it + toFields(q, cond) |  q <- qs );

list[str] toFields(q:(Question)`<Label l> <Var n>: <Type t>`, Expr cond)  
  = ["self.<qName(q)> = ko.observable(<initValue(t)>);",
     "self.<qName(q)>_visible = <computed(cond)>;"];
  
list[str] toFields(q:(Question)`<Label l> <Var n>: <Type t> = <Expr e>`, Expr cond) 
  = ["self.<qName(q)> = <computed(e)>;",
     "self.<qName(q)>_readonly = true;",
     "self.<qName(q)>_visible = <computed(cond)>;"];

str computed(Expr e) = "ko.computed(function() {
                       '  console.log(\"Computing: <e>\\n\");
                       '  return <expr2js(e, selectVisibleWrap)>;
                       '}, self, {deferEvaluation: true})";

str selectVisibleWrap(Expr var) { // TODO: should be ID; modify bind to annotate id
  qLocs = var@links;
  x = "<var>";
  str selfVar(loc l) = "self.<x>_<l.offset>";
  
  if ({loc l} := qLocs) 
    return "<selfVar(l)>()";
  
  return ( "null" | "(<v>_visible() ? <v>() : <it>)" | l <- qLocs, v := selfVar(l) );
}

str initValue((Type)`boolean`) = "false";
str initValue((Type)`integer`) = "0";
str initValue((Type)`money`) = "0.0";
str initValue((Type)`string`) = "\'\'";
