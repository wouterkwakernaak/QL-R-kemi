module lang::muql::Types

import lang::muql::ql::QL;

data QLType
  = integer()
  | boolean()
  | money()
  | string()
  | bottom()
  ;
  
QLType qlType((Type)`boolean`) = boolean();
QLType qlType((Type)`string`) = string();
QLType qlType((Type)`integer`) = integer();
QLType qlType((Type)`money`) = money();
  