@license{
  Copyright (c) 2013 
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Kevin van der Vlist - kevin@kevinvandervlist.nl}
@contributor{Jimi van der Woning - Jimi.vanderWoning@student.uva.nl}

module lang::qls::analysis::SemanticChecker

import IO;
import List;
import Set;
import String;
import util::IDE;

import lang::qls::ast::AST;
import lang::qls::compiler::PrettyPrinter;
import util::LocationHelper;

import lang::qls::util::ParseHelper;

public set[Message] semanticChecker(Stylesheet s) =
  filenameDoesNotMatchErrors(s) +
  accompanyingFormNotFoundErrors(s) +
  alreadyUsedQuestionErrors(s) +
  undefinedQuestionErrors(s) +
  doubleNameWarnings(s) +
  defaultRedefinitionWarnings(s) +
  accompanyingFormNotFoundWarnings(s);


public default set[Message] filenameDoesNotMatchErrors(Stylesheet s) = 
  {};

public set[Message] filenameDoesNotMatchErrors(Stylesheet s) =
  {error(
    "Stylesheet name (<s.ident>) does not match filename " +
      "(<basename(s@location)>)",
    s@location
  )}
    when s.ident != basename(s@location);

private default set[Message] accompanyingFormNotFoundErrors(Stylesheet s) =
  {};

private set[Message] accompanyingFormNotFoundErrors(Stylesheet s) =
  {error("No form found with name <s.ident>", s@location)}
    when !isFile(accompanyingFormLocation(s));


public set[Message] alreadyUsedQuestionErrors(Stylesheet s) {
  errors = {};
  questionDefinitions = getQuestionDefinitions(s);
  idents = [];
  for(d <- questionDefinitions) {
    i = indexOf(idents, d.ident);
    if(i >= 0) {
      errors += error(
        "Question already used at line " +
          "<questionDefinitions[i]@location.begin.line>",
        d@location
      );
    }
    idents += d.ident;
  }
  return errors;
}

public set[Message] undefinedQuestionErrors(Stylesheet s) {
  if(!isFile(accompanyingFormLocation(s)))
    return {};
  
  errors = {};
  typeMap = getTypeMap(accompanyingForm(s));
  visit(s) {
    case QuestionDefinition d: {
      if(identDefinition(d.ident) notin typeMap) {
        errors += error("Question undefined in form", d@location);
      }
    }
  }
  return errors;
}

public set[Message] doubleNameWarnings(Stylesheet s) {
  return doublePageNameWarnings(s) +
    doubleSectionNameWarnings(s);
}

public set[Message] doublePageNameWarnings(Stylesheet s) {
  warnings = {};
  pageDefinitions = getPageDefinitions(s);
  names = [];
  for(d <- pageDefinitions) {
    i = indexOf(names, d.ident);
    if(i >= 0) {
      warnings += warning(
        "Page name already used at line " +
          "<pageDefinitions[i]@location.begin.line>",
        d@location
      );
    }
    names += d.ident;
  }
  return warnings;
}

public set[Message] doubleSectionNameWarnings(Stylesheet s) {
  warnings = {};
  sectionDefinitions = getSectionDefinitions(s);
  names = [];
  for(d <- sectionDefinitions) {
    i = indexOf(names, d.ident);
    if(i >= 0) {
      warnings += warning(
        "Section name already used at line " +
          "<sectionDefinitions[i]@location.begin.line>",
        d@location
      );
    }
    names += d.ident;
  }
  return warnings;
}

public set[Message] defaultRedefinitionWarnings(Stylesheet s) {
  warnings = {};
  for(r <- getDefaultRedefinitions(s.definitions))
    warnings += warning(
      "Default already declared at this level",
      r@location
    );
  top-down visit(s) {
    case pageDefinition(_, rules):
      for(r <- getDefaultRedefinitions(rules))
        warnings += warning(
          "Default already declared at this level",
          r@location
        );
    case sectionDefinition(_, rules):
      for(r <- getDefaultRedefinitions(rules))
        warnings += warning(
          "Default already declared at this level",
          r@location
        );
  }
  return warnings;
}

private list[DefaultDefinition] getDefaultRedefinitions(list[&T] definitions) {
  idents = [];
  redefinitions = [];
  for(def <- definitions) {
    if(!def.defaultDefinition?)
      continue;
    
    d = def.defaultDefinition;
    i = indexOf(idents, d.ident);
    if(i >= 0) redefinitions += d;
    idents += d.ident;
  }
  return redefinitions;
}

private default set[Message] accompanyingFormNotFoundWarnings(Stylesheet s) =
  {};

private set[Message] accompanyingFormNotFoundWarnings(Stylesheet s) =
  {warning("No form found with name <s.ident>", s@location)}
    when !isFile(|project://QL-R-kemi/forms/| + "<s.ident>.q");


public list[QuestionDefinition] getQuestionDefinitions(Stylesheet s) =
  [d | /QuestionDefinition d <- s];

public list[PageDefinition] getPageDefinitions(Stylesheet s) =
  [d | /PageDefinition d <- s];

public list[str] getPageNames(Stylesheet s) =
  [name | /PageDefinition d:pageDefinition(name, _) <- s];

public list[SectionDefinition] getSectionDefinitions(Stylesheet s) =
  [d | /SectionDefinition d <- s];

public list[str] getSectionNames(Stylesheet s) =
  [name | /SectionDefinition d:sectionDefinition(name, _) <- s];


public void main() {
  s = parseStylesheet(|project://QL-R-kemi/stylesheets/proposedSyntax.qs|);
  //iprintln(getQuestionDefinitions(s));
  //iprintln(getPageNames(s));
  //iprintln(getSectionNames(s));
  errors = semanticChecker(s);
  iprintln(errors);
}
