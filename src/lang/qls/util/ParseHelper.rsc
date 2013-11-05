@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}

module lang::qls::util::\ParseHelper

import lang::ql::\syntax::Comment;
import lang::ql::\syntax::Int;
import lang::ql::\syntax::Layout;
import lang::ql::\syntax::Money;
import lang::ql::\syntax::String;
import lang::ql::\syntax::Type;
import lang::qls::\ast::AST;
import lang::qls::\syntax::Color;
import lang::qls::\syntax::Keyword;
import lang::qls::\syntax::QLS;
import \ParseTree;
import IO;

start[Stylesheet] parse(str src, loc l) { 
	println("parsing QLS");
	return parse(#start[Stylesheet], src, l);
}

Stylesheet implode(Tree t) = implode(#lang::qls::\ast::AST::Stylesheet, t);

Stylesheet parseStylesheet(str src) {
	println("parsing QLS");
  	return implode(parse(#start[Stylesheet], src, |file:///-|));
}

Stylesheet parseStylesheet(loc f) {
	println("parsing QLS");
	return implode(parse(#start[Stylesheet], f));
}
