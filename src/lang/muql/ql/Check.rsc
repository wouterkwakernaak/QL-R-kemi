module lang::muql::ql::Check


import lang::muql::ql::Types;
import lang::muql::ql::QL;
import lang::muql::qlBind;
import Message;
import ParseTree;
import IO;

// presupposes binding

set[Message] tc(Form f) = ( {} | it + tc(q) | q <- f.questions );

set[Message] tc((Question)`if (<Expr c>) <Question q>`) = checkCond(c) + tc(q);

set[Message] tc((Question)`if (<Expr c>) <Question q1> else <Question q2>`)
  = checkCond(c) + tc(q1) + tc(q2);

set[Message] tc((Question)`{ <Question* qs> }`) 
  = ( {} | it + tc(q) |  q <- qs );

set[Message] tc(q:(Question)`<Label l> <Var n>: <Type t> = <Expr e>`) 
  = { error("Redeclared with different type", q@\loc) | q@redecl? } 
  + tc(e);

set[Message] tc(q:(Question)`<Label l> <Var n>: <Type t>`)  
  = { error("Redeclared with different type", q@\loc) | q@redecl? }; 

default set[Message] tc(Question q) = {};

set[Message] checkCond(Expr c) 
   = { error("Condition should be boolean", c@\loc) | qlTypeOf(c) != boolean() }
   + tc(c);

default set[Message] tc(Expr _) = {};

set[Message] tc(e:(Expr)`<Id x>`) = {error("Undefined name", e@\loc)} 
  when e@types == {};
  
set[Message] tc((Expr)`(<Expr e>)`) = tc(e);
set[Message] tc(n:(Expr)`!<Expr e>`) = tc(n, checkBoolean, e);
set[Message] tc(e:(Expr)`<Expr lhs> * <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> / <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> + <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> - <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \> <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \>= <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \< <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> \<= <Expr rhs>`) = tc(e, checkNumeric, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> == <Expr rhs>`) = tc(e, checkEq, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> != <Expr rhs>`) = tc(e, checkEq, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> && <Expr rhs>`) = tc(e, checkBoolean, lhs, rhs);
set[Message] tc(e:(Expr)`<Expr lhs> || <Expr rhs>`) = tc(e, checkBoolean, lhs, rhs);

/*
 * Helper function to do automatic calling of tc on sub-expressions
 * and to prevent type-checking if the sub-expressions can't be typed.
 */

set[Message] tc(Expr e, set[Message](list[QLType], loc) check, Expr kids...) {
  ts = [ qlTypeOf(k) | k <- kids ];
  errs = ( {} | it + tc(k) | k <- kids );
  if (bottom() notin ts) {
    errs += check(ts, e@\loc);
  }
  return errs;
}

set[Message] checkBoolean(list[QLType] ts, loc l)  
  = ( true | it && boolean() !:= t | t <- ts )
  ? { error("Expression should have boolean type", l) }
  : {}; 

set[Message] checkNumeric(list[QLType] ts, loc l)  
  = ( true | it && (integer() := t || money() := t) | t <- ts )
  ? {}
  : { error("Expression should have numeric type", l) }; 

set[Message] checkString(list[QLType] ts, loc l)  
  = ( true | it && string() !:= t | t <- ts ) 
  ? { error("Expression should have string type", l) } 
  : {}; 

set[Message] checkEq(list[QLType] ts, loc l) 
  = { error("Incomparable types", l) | ts[0] != ts[1] }; 


default QLType qlTypeOf(Expr _) = QLType::bottom()
  when bprintln("Returning bottom");
  
QLType qlTypeOf(e:(Expr)`<Id x>`) = t 
  when bprintln("types anno: <e@types>"), QLType t <- e@types;
   
QLType qlTypeOf((Expr)`(<Expr e>)`) = qlTypeOf(e);
QLType qlTypeOf((Expr)`<Integer _>`) = integer();
QLType qlTypeOf((Expr)`true`) = boolean();
QLType qlTypeOf((Expr)`false`) = boolean();
QLType qlTypeOf((Expr)`<String _>`) = string();
QLType qlTypeOf(n:(Expr)`!<Expr e>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> * <Expr rhs>`) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> / <Expr rhs>`) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> + <Expr rhs>`) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> - <Expr rhs>`) = lub(qlTypeOf(lhs), qlTypeOf(rhs));
QLType qlTypeOf(e:(Expr)`<Expr lhs> \> <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \>= <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \< <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> \<= <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> == <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> != <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> && <Expr rhs>`) = boolean();
QLType qlTypeOf(e:(Expr)`<Expr lhs> || <Expr rhs>`) = boolean();


QLType lub(money(), QLType::integer()) = money();
QLType lub(QLType::integer(), money()) = money();
QLType lub(QLType t1, QLType t2) = t1 when t1 == t2;
default QLType lub(QLType t1, QLType t2) = bottom();
