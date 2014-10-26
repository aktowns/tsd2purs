require 'parslet'

class TSDParser < Parslet::Parser
  rule(:space) {
    match('\s').repeat(1)
  }

  rule(:space?) {
    space.maybe
  }

  rule(:newline) {
    str("\n") >> str("\r").maybe
  }

  rule(:line_comment) {
    space? >> (str('//') >> (newline.absent? >> any).repeat) >> space?
  }

  rule(:multiline_comment) {
    space? >> (str('/*') >> (str('*/').absent? >> any).repeat >> str('*/') >> space?)
  }

  rule(:declare) {
    space? >> str('declare') >> space?
  }

  rule(:var) {
    space? >> str('var') >> space?
  }

  rule(:function) {
    space? >> str('function') >> space?
  }

  rule(:interface) {
    space? >> str('interface') >> space?
  }

  rule(:extends) {
    space? >> str('extends') >> space?
  }

  rule(:identifier) {
    space? >> splat >> match['A-Za-z_0-9'].repeat(1).as(:id) >> question >> space?
  }

  rule(:type) {
    ntype.as(:ntype) | fntype.as(:fntype) | otype.as(:otype)
  }

  # String
  rule(:ntype) {
    space? >> (match['A-Za-z_0-9'] >> str('[]').repeat.maybe).repeat(1).as(:type) >> space?
  }

  # Arguments: { length: number; Item(n: number): string; };
  rule(:otype) {
    lbrack >> (interface_def | interface_fun_def).repeat >> rbrack
  }

  # (substring: string, ...args: any[]) => string
  rule(:fntype) {
    lparen >> arglist.as(:args) >> rparen >> fatarrow >> type >> space?
  }

  rule(:colon) {
    space? >> str(':') >> space?
  }

  rule(:semi) {
    space? >> str(';') >> space?
  }

  rule(:comma) {
    space? >> str(',') >> space?
  }

  rule(:question) {
    str('?').as(:nullable).maybe
  }

  rule(:splat) {
    str('...').as(:splat).maybe
  }

  rule(:fatarrow) {
    space? >> str('=>') >> space?
  }

  rule(:arg) {
    space? >> identifier.as(:name) >> (colon >> type).maybe >> space?
  }

  rule(:arglist) {
    space? >> arg >> (comma >> arg).repeat >> space?
  }

  rule(:extlist) {
    space? >> identifier >> (comma >> identifier).repeat >> space?
  }

  rule(:lparen) {
    space? >> str('(') >> space?
  }

  rule(:rparen) {
    space? >> str(')') >> space?
  }

  rule(:lbrack) {
    space? >> str('{') >> space?
  }

  rule(:rbrack) {
    space? >> str('}') >> space?
  }

  rule(:lblock) {
    space? >> str('[') >> space?
  }

  rule(:rblock) {
    space? >> str(']') >> space?
  }

  rule(:decl) {
    declare >> var >> identifier.as(:name) >> colon >> type >> semi
  }

  rule(:func_decl) {
    declare >> function >> identifier.as(:name) >> lparen >>
      arglist.maybe.as(:args) >> rparen >> colon >> type >> semi
  }
  # [s: string]: PropertyDescriptor;
  rule(:interface_ary_def) {
    lblock >> (identifier.as(:name) >> colon >> type).as(:array) >> rblock >> colon >> type >> semi
  }

  rule(:interface_def) {
    identifier.as(:name) >> colon >> type >> semi
  }

  # Item(n: number): string;
  rule(:interface_fun_def) {
    identifier.maybe.as(:name) >> lparen >> arglist.maybe.as(:args) >> rparen >> (colon >> type).maybe >> semi
  }

  # interface PropertyDescriptor {
  rule(:interface_decl) {
    interface >> identifier.as(:name) >> (extends >> extlist.as(:extensions)).maybe >> lbrack >>
      (interface_ary_def.as(:arrdef) |
       interface_def.as(:attdef) |
       interface_fun_def.as(:fundef) |
       line_comment).repeat.as(:body) >> rbrack
  }

  # declare var Number: {
  rule(:object_decl) {
    declare >> var >> identifier.as(:name) >> colon >> lbrack >>
      (interface_def | interface_fun_def).repeat.as(:body) >> rbrack >> semi.maybe
  }

  rule(:root_doc) {
    (decl.as(:decl) |
     func_decl.as(:func_decl) |
     interface_decl.as(:interface) |
     object_decl.as(:object) |
     line_comment |
     multiline_comment).repeat(0)
  }

  root :root_doc
end
