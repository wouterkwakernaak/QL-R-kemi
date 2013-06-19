module lang::muql::ql::GUI

import lang::muql::ql::Types;
import lang::muql::ql::QL;

data GUI
  = gui(list[Widget] elts)
  ;
  
data Widget
  = checkbox(str label, str name)
  | textbox(str label, str name, QLType \type)
  ;