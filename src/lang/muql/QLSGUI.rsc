module lang::muql::QLSGUI

extend lang::muql::GUI;

data Widget
  = slider(str label, str name, int min, int max)
  | yesNo(str label, str name, str yes, str no)
  | spinbox(str label, str name)
  | dropdown(str label, str name, map[str, str] choices)
  | section(str title, list[Widget] widgets)
  | pages(list[list[Widget]])
  ;