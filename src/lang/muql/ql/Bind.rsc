module lang::muql::ql::Bind

import lang::muql::ql::QL;
import lang::muql::ql::Types;
import Message;
import IO;
import ParseTree;

anno set[QLType] Expr@\types;

// should not be needed 
anno bool Question@redecl;

// Bug:
//start[Form] bind(start[Form] f) {
Form bind(Form f, rel[str,loc, QLType] defs) {
  return visit (f) {
    case Expr e:(Expr)`<Id name>`: {
      x = "<e.name>";
      locs = defs<0,1>[x];
      types = defs<0,2>[x];
      insert e[@links=locs][@types=types];
    } 
  }
}

tuple[Form, rel[str, loc, QLType]] definitions(Form f) {
  defs = {};
  
  Question addDef(Question q, Var x, Type t) {
    s = "<x>";
    qt = qlType(t);
    if (<s, _, qt2> <- defs, qt2 != qt) {
      println("REDECL!!! <x>");
      q@redecl = true;
    }
    defs += {<s, q@\loc, qt>};
    return q;
  }
  
  f = top-down visit (f) {
    case q:(Question)`<Label l> <Var x>: <Type t>` => addDef(q, x, t)
    case q:(Question)`<Label l> <Var x>: <Type t> = <Expr e>` => addDef(q, x, t)
  }

  return <f, defs>;
}

