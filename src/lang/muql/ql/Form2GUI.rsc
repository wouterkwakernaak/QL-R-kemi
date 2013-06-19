module lang::muql::ql::Form2GUI

import lang::muql::ql::QL;
import lang::muql::ql::GUI;
import lang::muql::ql::Types;
import ParseTree;

GUI form2gui(Form f) = gui(( [] | it + toGUI(q, (Expr)`true`) | q <- f.questions ));

list[Widget] toGUI((Question)`if (<Expr c>) <Question q>`, Expr cond) = 
   toGUI(q, (Expr)`<Expr cond> && <Expr c>`);

list[Widget] toGUI((Question)`if (<Expr c>) <Question q1> else <Question q2>`) 
  = toGUI(q1, (Expr)`<Expr cond> && <Expr c>`)
  + toGUI(q2, (Expr)`<Expr cond> && !(<Expr c>)`);

list[Widget] toGUI((Question)`{ <Question* qs> }`, Expr cond) 
  = ( [] | it + toGUI(q, cond) |  q <- qs );

list[Widget] toGUI(q:(Question)`<Label l> <Var n>: <Type t> = <Expr e>`, Expr cond) 
  = [toWidget(t, q)];

list[Widget] toGUI(q:(Question)`<Label l> <Var n>: <Type t>`, Expr cond)  
  = [toWidget(t, q)];

// Ugly!
Widget toWidget((Type)`boolean`, Question q) = checkbox("<q.label>", qName(q));
default Widget toWidget(Type t, Question q) = textbox("<q.label>", qName(q), qlType(t));

str qName(Question q) = "<q.var>_<q@\loc.offset>";

