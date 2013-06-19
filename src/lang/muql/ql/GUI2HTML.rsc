module lang::muql::ql::GUI2HTML

import lang::muql::ql::GUI;
import lang::muql::ql::Types;
import lang::muql::ql::QL;
import lang::muql::ql::Expr2JS;
import lang::muql::ql::Form2Model;
import lang::muql::ql::Form2GUI;
import IO;

loc TEMPLATE = |project://QL-R-kemi/src/lang/muql/template.html|;

str widgetName(Var n) = "<n>_<n@\loc.offset>";

str form2html(Form f) {
  name = "<f.name>";
  t = readFile(TEMPLATE);
  return top-down-break visit (t) {
    case /TITLE/ => name
    case /CONTENT/ => gui2html(form2gui(f))
    case /INIT/ => "<form2model(f, name)>
                   '$(document).ready(function() {
                   '   ko.applyBindings(new <name>Model());
                   '});"
  }
}

str gui2html(gui(es)) = "\<ul\>
                        '  <for (e <- es) {>
                        '   <question2html(e)>
                        '  <}>
                        '\</ul\>"; 

str expr2js(Expr e) = expr2js(e, str(str x) { return x; });

str question2html(Widget w) 
  = "\<li data-bind=\"visible: <w.name>_visible\"\>
    '  <widget2html(w)>
    '\</li\>";

str widget2html(checkbox(l, n)) = 
  labeledWidget(l,inputWidget(n, "checkbox", "checked: <n>")); 

str widget2html(textbox(l, n, _)) = // ignore type for now 
  labeledWidget(l, inputWidget(n, "text", "value: <n>"));

str inputWidget(str name, str tipe, str bind) 
  = "\<input name=\"<name>\" id=\"<name>\" type=\"<tipe>\" data-bind=\"<bind>\" /\>";

str labeledWidget(str l, str w, str n) = "\<label for=\"<n>\"\><l>\</label\>\n<w>";



