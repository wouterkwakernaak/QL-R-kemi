@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}
@contributor{Tijs van der Storm - storm@cwi.nl}

module lang::ql::Plugin

import Configuration;
import IO;
import ParseTree;
import util::IDE;
import util::Prompt;

import lang::ql::\analysis::SemanticChecker;
import lang::ql::\analysis::State;
import lang::ql::\analysis::CommentCheck;
import lang::ql::\ast::AST;
import lang::ql::compiler::PrettyPrinter;
import lang::ql::compiler::web::Web;
import lang::ql::ide::Outline;
import lang::ql::\syntax::QL;
import lang::ql::util::ParseHelper;
import lang::ql::ide::CrossRef;
import lang::ql::ide::Hover;
import lang::ql::ide::Visualize;
import vis::Render;

private str actionBuild = "Build form";
private str actionFormat = "Format (removes comments)";
private str actionVisualize = "Visualize form";

private void format(Form f, loc l) = writeFile(l, prettyPrint(f));
  
private void build(Form form, loc source) {
  messages = buildAndReturnMessages(form, getCompileTarget());
  
  errors = {m | m <- messages, error(_, _) := m};
  
  if(errors != {}) {
    alert("The form cannot be built when it still contains errors.");
  } else {
    alert("The form is built in <getCompileTarget()>.");
  }
  return;
}
  
public set[Message] buildAndReturnMessages(Form form, loc target) {
  print("building ");
  println(target);
  messages = semanticChecker(form);
  
  errors = {m | m <- messages, error(_, _) := m};
  
  if(errors != {}) {
    return messages;
  }
  buildForm(form, target);
  
  return {};
}

public void setupQL() {
  registerLanguage(getQLLangName(), getQLLangExt(), Tree(str src, loc l) {
    return parse(src, l);
  });
  
  contribs = {
    outliner(node(Tree input) {
      return outlineForm(implode(input));
    }),
    
    annotator(Tree(Tree input) {
      ast = implode(input);
      input = addDocLinks(xref(input));
      SAS sas = <(), ()>;
      <sas, msgs> = analyzeSemantics(sas, ast);
      msgs += filenameDoesNotMatchErrors(ast);
      msgs += checkComments(sas, input);
      return input[@messages=msgs];
    }),
    
    popup(
      menu(getQLLangName(),[
        action(actionBuild, (Tree tree, loc source) {
          build(implode(tree), source);
        }),
        action(actionFormat, (Tree tree, loc source) {
          format(implode(tree), source);
        }),
        action(actionVisualize, (Tree tree, loc source) {
          render(form2figure(implode(tree)));
        })
      ])
    ), 
    
    builder(set[Message] (Tree input) {
      messages = buildAndReturnMessages(implode(input), getCompileTarget());
      return messages;
    })
  };
  
  registerContributions(getQLLangName(), contribs);
}
